```go
package worker

import (
	"errors"
	"github.com/qiniu/log.v1"
	"os"
	"os/signal"
	"time"
)

var (
	ErrTimeOut   = errors.New("received timeout")
	ErrInterrupt = errors.New("received interrupt")
)

type Runner struct {
	//操作系统信号量处理
	interrupt chan os.Signal
	//接收任务完成后的返回值
	complete chan error
	timeout  <-chan time.Time
	tasks    []func(id int)
}

func NewRunner(d time.Duration) *Runner {
	return &Runner{
		interrupt: make(chan os.Signal, 1),
		complete:  make(chan error),
		timeout:   time.After(d),
	}
}

func (r *Runner) AddTask(task func(id int)) {
	r.tasks = append(r.tasks, task)
}

// start意味着执行所有的任务
func (r *Runner) StartRunner() error {
	signal.Notify(r.interrupt, os.Interrupt)
	go func() {
		r.complete <- r.run()
	}()
	select {
	case err := <-r.complete:
		return err
	case <-r.timeout:
		return ErrTimeOut
	}
}

// FIFO来执行任务
func (r *Runner) run() error {
	for id, task := range r.tasks {
		select {
		case <-r.interrupt:
			signal.Stop(r.interrupt)
			return ErrInterrupt
		default:
			task(id)
		}
	}
	return nil
}

func runnerExample() {
	log.Println("start")
	defer func() {
		log.Println("end")
	}()
	runner := NewRunner(time.Second * 6)
	for i := 0; i < 3; i++ {
		runner.AddTask(func(id int) {
			log.Printf("task %d is running", id)
			time.Sleep(time.Second)
		})
	}
	err := runner.StartRunner()
	switch err {
	case ErrTimeOut:
		log.Println("timeout exit")
		os.Exit(1)
	case ErrInterrupt:
		log.Println("interrupt exit")
		os.Exit(2)
	}
}
```