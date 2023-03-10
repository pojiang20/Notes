网上有很多关于如何使用http服务的教程，但是如何关闭服务似乎非常的少。
### 常规关闭
关于关闭的基本思路就是，通过开启线程来调用`Shutdown`方法，这时候`ListenAndServe()`就会返回`http.ErrServerClosed`
[How to stop http.ListenAndServe()](https://stackoverflow.com/questions/39320025/how-to-stop-http-listenandserve)

### 优雅关闭
就是在调用`Shutdown()`之前，进行一些操作来缓冲比如`sleep`一段时间等待任务的结束。
[读 "优雅关闭的 Go Web 服务器"](https://learnku.com/articles/33393)

### 简单示例
```go
func Demo() {
	//构造channel用于通知任务完成
	done := make(chan struct{})
	router := http.NewServeMux()
	router.HandleFunc("/do", func(w http.ResponseWriter, r *http.Request) {
        //如果满足的退出条件，则通知关闭
		if cond {
			done <- struct{}{}
		}
	})
	server := &http.Server{
		//设置具体的路由情况
		Handler: router, 
	}
	//shutdown等待
	go Shutdown(server, done)
	//进行服务
	if err := server.ListenAndServe(); err != http.ErrServerClosed {
		log.Fatalln("Http server ListenAndServe: ", err)
	}
}

func Shutdown(server *http.Server, done chan struct{}) {
	<-done
	//可以在调用Shutdown之前进行一些操作，来实现优雅关闭
	//ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)

	log.Info("Shutdown listen server")
	server.Shutdown(context.Background())
}
```