## 类型转换
`golang`存在断言、强制、显式和隐式四种类型转换。
#### 断言
类型断言用于接口类型，一个接口类型的变量 `varI` 中可以包含任何类型的值，必须有一种方式来检测它的 `动态` 类型，即运行时在变量中存储的值的实际类型。在执行过程中动态类型可能会有所不同，但是它总是可以分配给接口变量本身的类型。通常我们可以使用 `类型断言` 来测试在某个时刻 `varI` 是否包含类型 `T` 的值：
```go
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

## 类型比较
[参考](https://medium.com/golangspec/equality-in-golang-ff44da79b7f1)
#### 接口类型比较
接口类型的比较，需要类型X实现了接口并且X是可比较类型
> Slice, map, and function values are not comparable.
因此下面的比较会报错
```go
type A []byte
func main() {
    var i interface{} = A{}
    var j interface{} = A{}
    fmt.Println(i == j)
}
```
如果是不同类型实现了接口，但接口值是不可比较类型，则返回`false`。
```go
type A []byte
type B []byte
func main() {
    // A{} == A{} // slice can only be compared to nil
    var i interface{} = A{}
    var j interface{} = B{}
    fmt.Println(i == j) // false
}
```
#### 结构体比较
如果结构体相同，但是名字不相同，则比较失败[运行](https://go.dev/play/p/XZ5YUaTZmrx)
```go
package main

import (
	"fmt"
)

type A struct {
	_  float64
	f1 int
	F2 string
}

type B struct {
	_  float64
	f1 int
	F2 string
}

func main() {
	fmt.Println(A{1.1, 2, "x"} == A{0.1, 2, "x"}) // true
	//fmt.Println(A{} == B{})                       // mismatched types A and B
}
```
#### 接口类型之静态类型和动态类型
[参考](https://medium.com/golangspec/interfaces-in-go-part-i-4ae53a97479c)
静态类型是在定义时就确定了，在编译期间会检查静态类型。动态类型只有在赋值时才会确定。  
对于下面这个例子，`i`的静态类型是`I`，`var i I = T1{}`过程中`i`的动态类型是`T1{}`，`i = T2{}`后`i`的动态类型是`T2`，当接口类型值是`nil`这时不会设置动态类型值。
```go
type I interface {
    M()
}
type T1 struct {}
func (T1) M() {}
type T2 struct {}
func (T2) M() {}
func main() {
    var i I = T1{}
    i = T2{}
    _ = i
}
```
对于下面这个例子，`v`的静态类型是`interface{}`而赋值过程中动态类型是`""`。所以比较时`v==""`比较的是动态类型。
> The type set of a blank interface type is composed of all non-interface types. [ref](https://go101.org/article/interface.html)
```go
func Test_myinterface(t *testing.T) {
	var v interface{} = ""
	log.Info(reflect.TypeOf(v), reflect.TypeOf(""))
	if v == "" {
		log.Info("OK")
	}
}
```
`interface{}`的断言，即`v.(string)`修改了静态类型。