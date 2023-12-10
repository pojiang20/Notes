websocket是一种基于HTTP协议的扩展，它提供了一种持久的、双向的通信通道，使得服务器能够实时向客户端推送数据。而建立这样的通道，websocket需要经过以此特殊的握手过程。
### websocket握手过程
1. 客户端发送websocket握手请求：为了将客户端升级到websocket协议。
```
Upgrade：websocket  // 指示客户端希望升级到WebSocket协议
Connection：Upgrade //指示客户端希望建立持久连接
Sec-WebSocket-Key：dGhlIHNhbXBsZSBub25jZQ==  //生成一个随机的Base64编码密钥，用于安全验证。
Sec-WebSocket-Version：13 //指示客户端使用的WebSocket协议版本
```
2. 服务器响应握手请求：响应101表示收到请求并切换到ws协议。
3. 握手响应确认：检查响应信息。
4. 建立ws链接，实现双向数据传输。
[参考](https://juejin.cn/post/7251974224922804261)

### 1xx状态码
101 switching protocols 是响应客户端的upgrade请求头发送的，指明服务器即将切换的协议。

[参考](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Status#%E4%BF%A1%E6%81%AF%E5%93%8D%E5%BA%94)
