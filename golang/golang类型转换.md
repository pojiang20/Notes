`golang`存在断言、强制、显式和隐式四种类型转换。
#### 断言
类型断言用于接口类型，一个接口类型的变量 `varI` 中可以包含任何类型的值，必须有一种方式来检测它的 `动态` 类型，即运行时在变量中存储的值的实际类型。在执行过程中动态类型可能会有所不同，但是它总是可以分配给接口变量本身的类型。通常我们可以使用 `类型断言` 来测试在某个时刻 `varI` 是否包含类型 `T` 的值：
```json
v := varI.(T)       // unchecked type assertion
```
#### 强制类型转换
使用`unsafe`包可以使用指针，在内存层面来转换类型，下面是一个简单的例子。
```go
var f float64
bits = *(*uint64)(unsafe.Pointer(&f))

type ptr unsafe.Pointer
bits = *(*uint64)(ptr(&f))

var p ptr = nil
```
#### 显示类型转换
显示类型转换[规则](https://go.dev/ref/spec#Conversions)
一个显式转换的表达式 `T (x)` ，其中 T 是一种类型并且 `x` 是可转换为类型的表达式 `T`，例如：`uint(666)`、`[]byte("123")`。在以下任何一种情况下，变量 x 都可以转换成 T 类型：

- x 可以分配成 T 类型。
- 忽略 struct 标签 x 的类型和 T 具有相同的基础类型。
- 忽略 struct 标记 x 的类型和 T 是未定义类型的指针类型，并且它们的指针基类型具有相同的基础类型。
- x 的类型和 T 都是整数或浮点类型。
- x 的类型和 T 都是复数类型。
- x 的类型是整数或 [] byte 或 [] rune，并且 T 是字符串类型。
- x 的类型是字符串，T 类型是 [] byte 或 [] rune。
#### 隐式类型转换
`ReadCloser`组合了`Reader`，而在`r1=rc`中，隐含了`ReadCloser`到`Reader`的转换。这是因为`rc`也实现了`r1`。
```go
type Reader interface {
    Read(p []byte) (n int, err error)
}
type ReadCloser interface {
    Reader
    Close() error
}
var rc ReadCloser
var r1 Reader
r1 = rc
```
[参考](https://learnku.com/articles/42797)
