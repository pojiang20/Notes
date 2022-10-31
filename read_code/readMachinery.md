### Server
`server`是业务主体，通过`machinery.NewServer`获取，后续用`server`使用各种服务。`config`处理配置信息、`registeredTasks`缓存任务，`broker`、`backend`、`lock`规定好接口，这样可以支持多种类型的实现并且不影响`server`。
```go
// Server is the main Machinery object and stores all configuration
// All the tasks workers process are registered against the server
type Server struct {
	config            *config.Config
	registeredTasks   *sync.Map
	broker            brokersiface.Broker
	backend           backendsiface.Backend
	lock              lockiface.Lock
    
	scheduler         *cron.Cron
	prePublishHandler func(*tasks.Signature)
}
```
#### RegisterTasks
`ValidateTask`校验`task`签名的合法性，`namedTaskFuncs`在`server`中用`sync.map`存储，`broker`中用`[]string`存储名称
```go
// RegisterTasks registers all tasks at once
func (server *Server) RegisterTasks(namedTaskFuncs map[string]interface{}) error {
	for _, task := range namedTaskFuncs {
		if err := tasks.ValidateTask(task); err != nil {
			return err
		}
	}

	for k, v := range namedTaskFuncs {
		server.registeredTasks.Store(k, v)
	}

	server.broker.SetRegisteredTaskNames(server.GetRegisteredTaskNames())
	return nil
}
```
#### SendTaskWithContext
发送任务执行请求，`server.backend.SetStatePending(signature)`后端标记状态，`server.broker.Publish(ctx, signature)`发布任务。
```go
// SendTaskWithContext will inject the trace context in the signature headers before publishing it
func (server *Server) SendTaskWithContext(ctx context.Context, signature *tasks.Signature) (*result.AsyncResult, error) {
	...
	// Auto generate a UUID if not set already
	if signature.UUID == "" {
		taskID := uuid.New().String()
		signature.UUID = fmt.Sprintf("task_%v", taskID)
	}

	// Set initial task state to PENDING
	if err := server.backend.SetStatePending(signature); err != nil {
		return nil, fmt.Errorf("Set state pending error: %s", err)
	}

	if server.prePublishHandler != nil {
		server.prePublishHandler(signature)
	}

	if err := server.broker.Publish(ctx, signature); err != nil {
		return nil, fmt.Errorf("Publish message error: %s", err)
	}

	return result.NewAsyncResult(signature, server.backend), nil
}
```
### worker
`worker`中包含`server`，通过组合完成`server`的扩展。
```go
// Worker represents a single worker process
type Worker struct {
	server            *Server
	ConsumerTag       string
	Concurrency       int
	Queue             string
	errorHandler      func(err error)
	preTaskHandler    func(*tasks.Signature)
	postTaskHandler   func(*tasks.Signature)
	preConsumeHandler func(*Worker) bool
}
```
#### LaunchAsync
异步启动任务，不阻塞。内部是启动两个`goroutine`，一个不断消费`broker`，另一个处理信号量来终止程序。
`broker.StartConsuming(worker.ConsumerTag, worker.Concurrency, worker)`这里`broker`中传入`worker`来消费其任务。
```go
// LaunchAsync is a non blocking version of Launch
func (worker *Worker) LaunchAsync(errorsChan chan<- error) {
	...
	var signalWG sync.WaitGroup
	// Goroutine to start broker consumption and handle retries when broker connection dies
	go func() {
		for {
			retry, err := broker.StartConsuming(worker.ConsumerTag, worker.Concurrency, worker)
			...
		}
	}()
	if !cnf.NoUnixSignals {
		sig := make(chan os.Signal, 1)
		signal.Notify(sig, os.Interrupt, syscall.SIGTERM)
		var signalsReceived uint

		// Goroutine Handle SIGINT and SIGTERM signals
		go func() {
			for s := range sig {
				...
			}
		}()
	}
}
```
`broker`中`StartConsuming`如下，`b.Broker.StartConsuming(consumerTag, concurrency, taskProcessor)`是为了重用`broker`的公共部分。然后创建`deliveries`，一边一个协程从`redis`队列中取出任务放入`deliveries`，另一边`b.consume(deliveries, concurrency, taskProcessor)`在消费。
```go
func (b *Broker) StartConsuming(consumerTag string, concurrency int, taskProcessor iface.TaskProcessor) (bool, error) {
	...
	b.Broker.StartConsuming(consumerTag, concurrency, taskProcessor)

	conn := b.open()
	defer conn.Close()
	...
	// initialize worker pool with maxWorkers workers
	for i := 0; i < concurrency; i++ {
		pool <- struct{}{}
	}

	// A receiving goroutine keeps popping messages from the queue by BLPOP
	// If the message is valid and can be unmarshaled into a proper structure
	// we send it to the deliveries channel
	go func() {
    	...
		for {
			select {
			// A way to stop this goroutine from b.StopConsuming
			case <-b.GetStopChan():
				close(deliveries)
				return
			case <-pool:
				select {
				case <-b.GetStopChan():
					close(deliveries)
					return
				default:
				}

				if taskProcessor.PreConsumeHandler() {
					task, _ := b.nextTask(getQueue(b.GetConfig(), taskProcessor))
					//TODO: should this error be ignored?
					if len(task) > 0 {
						deliveries <- task
					}
				}

				pool <- struct{}{}
			}
		}
	}()


	if err := b.consume(deliveries, concurrency, taskProcessor); err != nil {
		return b.GetRetry(), err
	}

	// Waiting for any tasks being processed to finish
	b.processingWG.Wait()

	return b.GetRetry(), nil
}
```
```broker.consume`的消费也是不停的循环，从`diliveries`中取出任务，分发执行`b.consumeOne(d, taskProcessor)`。
```go
// consume takes delivered messages from the channel and manages a worker pool
// to process tasks concurrently
func (b *Broker) consume(deliveries <-chan []byte, concurrency int, taskProcessor iface.TaskProcessor) error {
	...
	for {
		select {
		case err := <-errorsChan:
			return err
		case d, open := <-deliveries:
			if !open {
				return nil
			}
			if concurrency > 0 {
				// get execution slot from pool (blocks until one is available)
				select {
				case <-b.GetStopChan():
					b.requeueMessage(d, taskProcessor)
					continue
				case <-pool:
				}
			}

			b.processingWG.Add(1)

			// Consume the task inside a goroutine so multiple tasks
			// can be processed concurrently
			go func() {
				if err := b.consumeOne(d, taskProcessor); err != nil {
					errorsChan <- err
				}

				b.processingWG.Done()

				if concurrency > 0 {
					// give slot back to pool
					pool <- struct{}{}
				}
			}()
		}
	}
}
```
`consumeOne`则是构造签名执行函数
```go
// consumeOne processes a single message using TaskProcessor
func (b *Broker) consumeOne(delivery []byte, taskProcessor iface.TaskProcessor) error {
	...
	return taskProcessor.Process(signature)
}
```
`Process`中使用`task.Call()`执行具体函数，其中还包括`Pedding->Received->Started`的状态转换。
```go
// Process handles received tasks and triggers success/error callbacks
func (worker *Worker) Process(signature *tasks.Signature) error {
	...
	// Update task state to RECEIVED
	if err = worker.server.GetBackend().SetStateReceived(signature); err != nil {
		return fmt.Errorf("Set state to 'received' for task %s returned error: %s", signature.UUID, err)
	}
    ...
	// Update task state to STARTED
	if err = worker.server.GetBackend().SetStateStarted(signature); err != nil {
		return fmt.Errorf("Set state to 'started' for task %s returned error: %s", signature.UUID, err)
	}
	...
	// Call the task
	results, err := task.Call()
	if err != nil {
		// If a tasks.ErrRetryTaskLater was returned from the task,
		// retry the task after specified duration
		retriableErr, ok := interface{}(err).(tasks.ErrRetryTaskLater)
		if ok {
			return worker.retryTaskIn(signature, retriableErr.RetryIn())
		}

		// Otherwise, execute default retry logic based on signature.RetryCount
		// and signature.RetryTimeout values
		if signature.RetryCount > 0 {
			return worker.taskRetry(signature)
		}

		return worker.taskFailed(signature, err)
	}

	return worker.taskSucceeded(signature, results)
}

```
### Broker
`broker`在`NewServer`阶段`BrokerFactory`构造，`broker`是接口类型，这样可以很好的支持多种不同的实现。
```go
// BrokerFactory creates a new object of iface.Broker
// Currently only AMQP/S broker is supported
func BrokerFactory(cnf *config.Config) (brokeriface.Broker, error) {
	if strings.HasPrefix(cnf.Broker, "amqp://") {
		return amqpbroker.New(cnf), nil
	}

	if strings.HasPrefix(cnf.Broker, "amqps://") {
		return amqpbroker.New(cnf), nil
	}
	...
}
```
以`redis`的实现为例，`startConsuming`前面已经介绍过了，`Publish`是向`redis`队列中发送任务。
```go
// Publish places a new message on the default queue
func (b *Broker) Publish(ctx context.Context, signature *tasks.Signature) error {
	...
	_, err = conn.Do("RPUSH", signature.RoutingKey, msg)
	return err
}
```
### Backend
同样是接口类型，可以支持不同的实现。主要用途是在后端记录任务状态
```go
// Backend - a common interface for all result backends
type Backend interface {
    ...
	// Setting / getting task state
	SetStatePending(signature *tasks.Signature) error
	SetStateReceived(signature *tasks.Signature) error
	SetStateStarted(signature *tasks.Signature) error
	SetStateRetry(signature *tasks.Signature) error
	SetStateSuccess(signature *tasks.Signature, results []*tasks.TaskResult) error
	SetStateFailure(signature *tasks.Signature, err string) error
	GetState(taskUUID string) (*tasks.TaskState, error)
	...
}
```
`SendTask`中将任务设置为`Pending`状态，表示任务待执行。而其他的状态转换基本在`worker.Process`中。验证签名注册->`Received`->根据签名构造任务->`Started`->执行任务->执行成功`Success`、执行失败`Failure`
```go
// Process handles received tasks and triggers success/error callbacks
func (worker *Worker) Process(signature *tasks.Signature) error {
	...
	// Update task state to RECEIVED
	if err = worker.server.GetBackend().SetStateReceived(signature); err != nil {
		return fmt.Errorf("Set state to 'received' for task %s returned error: %s", signature.UUID, err)
	}
    ...
	// Update task state to STARTED
	if err = worker.server.GetBackend().SetStateStarted(signature); err != nil {
		return fmt.Errorf("Set state to 'started' for task %s returned error: %s", signature.UUID, err)
	}
	...
	// Call the task
	results, err := task.Call()
	if err != nil {
    	...
		return worker.taskFailed(signature, err)
	}

	return worker.taskSucceeded(signature, results)
}

```
#### 结果`AsyncResult`
由于多个`gorotine`是异步执行的，然后会`setXX()`来向后端设置状态，因此当前任务状态是不确定的，这里的`AsyncResult`提供的是后端的查询操作，在需要获取结果时调用查询来获取状态。
```go
// Get returns task results (synchronous blocking call)
func (asyncResult *AsyncResult) Get(sleepDuration time.Duration) ([]reflect.Value, error) {
	for {
		results, err := asyncResult.Touch()

		if results == nil && err == nil {
			time.Sleep(sleepDuration)
		} else {
			return results, err
		}
	}
}
```
### 任务编排
`Machinery`包含`Group`、`Chain`、`Chord`三种编排方式。
```go

// Chain creates a chain of tasks to be executed one after another
type Chain struct {
	Tasks []*Signature
}

// Group creates a set of tasks to be executed in parallel
type Group struct {
	GroupUUID string
	Tasks     []*Signature
}

// Chord adds an optional callback to the group to be executed
// after all tasks in the group finished
type Chord struct {
	Group    *Group
	Callback *Signature
}
```
#### group
`group`就是维护了一个`groupID`作为统一`ID`，以及数组包含一组签名。分发`group`就是遍历签名并且发布即可，这样就可以做到异步执行`group`中的任务。
分发后，`group`并不保证任务的统一完成，但可以用`Bachend.GroupCompleted()`来查看该`group`是否完成
```go
// SendGroupWithContext will inject the trace context in all the signature headers before publishing it
func (server *Server) SendGroupWithContext(ctx context.Context, group *tasks.Group, sendConcurrency int) ([]*result.AsyncResult, error) {
	...
	var wg sync.WaitGroup
	wg.Add(len(group.Tasks))
	errorsChan := make(chan error, len(group.Tasks)*2)

	// Init group
	server.backend.InitGroup(group.GroupUUID, group.GetUUIDs())

	// Init the tasks Pending state first
	for _, signature := range group.Tasks {
		if err := server.backend.SetStatePending(signature); err != nil {
			errorsChan <- err
			continue
		}
	}
	...
	for i, signature := range group.Tasks {

		if sendConcurrency > 0 {
			<-pool
		}

		go func(s *tasks.Signature, index int) {
			defer wg.Done()

			// Publish task

			err := server.broker.Publish(ctx, s)

			if sendConcurrency > 0 {
				pool <- struct{}{}
			}

			if err != nil {
				errorsChan <- fmt.Errorf("Publish message error: %s", err)
				return
			}

			asyncResults[index] = result.NewAsyncResult(s, server.backend)
		}(signature, i)
	}

	done := make(chan int)
	go func() {
		wg.Wait()
		done <- 1
	}()

	select {
	case err := <-errorsChan:
		return asyncResults, err
	case <-done:
		return asyncResults, nil
	}
}
```
#### chord
`chord`是在`group`完成后执行回调函数，其实现逻辑主要在`taskSucceeded`。`ChordCallback`判断回调函数存在，如果存在回调函数且`group`完成就会将`group`执行结果作为参数执行`callback`。
```go
// taskSucceeded updates the task state and triggers success callbacks or a
// chord callback if this was the last task of a group with a chord callback
func (worker *Worker) taskSucceeded(signature *tasks.Signature, taskResults []*tasks.TaskResult) error {
	...
	// There is no chord callback, just return
	if signature.ChordCallback == nil {
		return nil
	}

	// Check if all task in the group has completed
	groupCompleted, err := worker.server.GetBackend().GroupCompleted(
		signature.GroupUUID,
		signature.GroupTaskCount,
	)
	if err != nil {
		return fmt.Errorf("Completed check for group %s returned error: %s", signature.GroupUUID, err)
	}

	// If the group has not yet completed, just return
	if !groupCompleted {
		return nil
	}
	...

	// Trigger chord callback
	shouldTrigger, err := worker.server.GetBackend().TriggerChord(signature.GroupUUID)
	if err != nil {
		return fmt.Errorf("Triggering chord for group %s returned error: %s", signature.GroupUUID, err)
	}

	// Chord has already been triggered
	if !shouldTrigger {
		return nil
	}

	// Get task states
	taskStates, err := worker.server.GetBackend().GroupTaskStates(
		signature.GroupUUID,
		signature.GroupTaskCount,
	)
	if err != nil {
		log.ERROR.Printf(
			"Failed to get tasks states for group:[%s]. Task count:[%d]. The chord may not be triggered. Error:[%s]",
			signature.GroupUUID,
			signature.GroupTaskCount,
			err,
		)
		return nil
	}

	// Append group tasks' return values to chord task if it's not immutable
	for _, taskState := range taskStates {
		if !taskState.IsSuccess() {
			return nil
		}

		if signature.ChordCallback.Immutable == false {
			// Pass results of the task to the chord callback
			for _, taskResult := range taskState.Results {
				signature.ChordCallback.Args = append(signature.ChordCallback.Args, tasks.Arg{
					Type:  taskResult.Type,
					Value: taskResult.Value,
				})
			}
		}
	}

	// Send the chord task
	_, err = worker.server.SendTask(signature.ChordCallback)
	if err != nil {
		return err
	}

	return nil
}
```
#### chain
链式执行的基本逻辑就是，按照任务的先后构造一个链表，并且在当前任务完成后尝试访问该任务的`next`，并且把当前执行结果作为下一个执行的入参。
这是链式执行的初始化`signatures[i-1].OnSuccess = []*Signature{signatures[i]}`每一个`signatures`的`OnSuccess`是下一个`signatures`
```go
// NewChain creates a new chain of tasks to be processed one by one, passing
// results unless task signatures are set to be immutable
func NewChain(signatures ...*Signature) (*Chain, error) {
	// Auto generate task UUIDs if needed
	for _, signature := range signatures {
		if signature.UUID == "" {
			signatureID := uuid.New().String()
			signature.UUID = fmt.Sprintf("task_%v", signatureID)
		}
	}

	for i := len(signatures) - 1; i > 0; i-- {
		if i > 0 {
			signatures[i-1].OnSuccess = []*Signature{signatures[i]}
		}
	}

	chain := &Chain{Tasks: signatures}

	return chain, nil
}
```
`worker`执行完当前任务之后，会遍历`OnSuccess`并且`worker.server.SendTask(successTask)`加入`worker`执行。
```go
func (worker *Worker) taskSucceeded(signature *tasks.Signature, taskResults []*tasks.TaskResult) error {
    ...    
    for _, successTask := range signature.OnSuccess {
		if signature.Immutable == false {
			// Pass results of the task to success callbacks
			for _, taskResult := range taskResults {
				successTask.Args = append(successTask.Args, tasks.Arg{
					Type:  taskResult.Type,
					Value: taskResult.Value,
				})
			}
		}
		worker.server.SendTask(successTask)
	}
    ...
}
```
