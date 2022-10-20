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
