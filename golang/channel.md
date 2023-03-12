### 未初始化的channel
参考 [https://stackoverflow.com/questions/39015602/how-does-a-non-initialized-channel-behave](https://stackoverflow.com/questions/39015602/how-does-a-non-initialized-channel-behave)
未初始化的`channel`值为`nil`，对于`nil`的读和写，有如下规则：
- 向`nil channel` 发送消息，会永久阻塞
- 向`nil channel` 读取消息，会永久阻塞
- `close nil channel`会`panic`
- 从`close`的`nil channel`中读取值，会马上返回0。 
> An "uninitialized" field or variable of [channel type](https://golang.org/ref/spec#Channel_types) will have the [zero value](https://golang.org/ref/spec#The_zero_value) of all channel types which is nil. So let's examine how a nil channel or operations on it behave.
> **It is worth collecting the _channel axioms_ in one post:**
> - a send on a nil channel blocks forever ([Spec: Send statements](https://golang.org/ref/spec#Send_statements))
> - a receive from a nil channel blocks forever ([Spec: Receive operator](https://golang.org/ref/spec#Receive_operator))
> - a send to a closed channel panics ([Spec: Send statements](https://golang.org/ref/spec#Send_statements))
> - a receive from a closed channel returns the zero value immediately ([Spec: Receive operator](https://golang.org/ref/spec#Receive_operator))

### select channel
- 每个 case 都必须是一个通信
- 所有 channel 表达式都会被求值
- 所有被发送的表达式都会被求值
- 如果任意某个通信可以进行，它就执行，其他被忽略。
- 如果有多个 case 都可以运行，Select 会随机公平地选出一个执行。其他不会执行。
否则：
   1. 如果有 default 子句，则执行该语句。
   2. 如果没有 default 子句，select 将阻塞，直到某个通信可以运行；Go 不会重新对 channel 或值进行求值。
```go
select {
    case communication clause  :
       statement(s);      
    case communication clause  :
       statement(s);
    /* 你可以定义任意数量的 case */
    default : /* 可选 */
       statement(s);
}
```

### range对channel访问是send+检查
对于已经close关闭的channel，接收者仍然可以从中读数据，close后channel中没有数据也不会阻塞，得到nil。
对于已经close关闭的channel，range读取channel会退出。
结论：`range <=> res,ok := <-ch`
```go
func Test_range(t *testing.T) {
	ch := make(chan struct{})

	////箭头获取：会打印
	//go func() {
	//	res := <-ch
	//	log.Printf("res: %v", res)
	//}()
	//close(ch)
	//time.Sleep(time.Second)

	////range获取：不会打印
	//go func() {
	//	for res := range ch {
	//		log.Printf("res: %v", res)
	//	}
	//}()
	//close(ch)
	//time.Sleep(time.Second)

	//range获取
	//可打印
	go func() {
		for res := range ch {
			log.Printf("res: %v", res)
		}
	}()
	ch <- struct{}{}
	time.Sleep(time.Second)
}
```

### close+channel同时启动多个协程
首先构造一个无缓冲的`channel`
```go
ready := make(chan struct{})
```
然后使用`<-ready`阻塞某一段代码，最后在需要启动的时候使用`close（ready)`，这样所有`<-ready`被阻塞的`channel`就会非阻塞，来运行后续代码。
#### 等待完成
```go
done := make(chan struct{})
go func() {
  doA()
  close(done)
}()
// 等待A完成
<-done
```
#### 同时启动
```go
start := make(chan struct{})
for i := 0; i < 10000; i++ {
  go func() {
    <-start // wait for the start channel to be closed
    doWork(i) // do something
 }()
}
//这时候所有阻塞的协程都可以继续运行
close(start)
```
#### 暂停循环
```go
loop:
for {
  select {
  case m := <-email:
    sendEmail(m)
  case <-stop: // triggered when the stop channel is closed
    break loop // exit
  }
}
```