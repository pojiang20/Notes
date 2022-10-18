### 值返回还是指针返回
返回值还是指针，影响的是内存分配问题。
#### 逃逸分析
`Go`的垃圾回收机制是自动管理的，`Go`编译器决定内存分配位置的方式，即判断变量需要分配在栈上还是堆上，这种行为称作逃逸分析。
逃逸分析由编译器完成，作用域编译阶段。
#### 指针逃逸
函数中创建了一个对象，返回该对象的指针。这种情况导致函数虽然退出了，但由于指针的存在对象的内存不能随着函数结束而回收，因此只能分配在堆上。
```go
// main_pointer.go
package main

import "fmt"

type Demo struct {
	name string
}

func createDemo(name string) *Demo {
	d := new(Demo) // 局部变量 d 逃逸到堆
	d.name = name
	return d
}

func main() {
	demo := createDemo("demo")
	fmt.Println(demo)
}
```
即这种情况造成逃逸到堆上了。
#### interface{}动态类型逃逸
由于`interface{}`空接口可以表示任意的类型，如果参数为`interface{}`，编译期间很难确定其参数的具体类型，也会发生逃逸。如下面`Println`的interface{}参数
```go
func main() {
	demo := createDemo("demo")
	fmt.Println(demo)
}
```
demo 是 main 函数中的一个局部变量，该变量作为实参传递给 fmt.Println()，但是因为 fmt.Println() 的参数类型定义为 interface{}，因此也发生了逃逸。
#### 栈空间不足
对于 Go 语言来说，运行时(runtime) 尝试在 goroutine 需要的时候动态地分配栈空间，goroutine 的初始栈大小为 2 KB。当 goroutine 被调度时，会绑定内核线程执行，栈空间大小也不会超过操作系统的限制。
对 Go 编译器而言，超过一定大小的局部变量将逃逸到堆上，不同的 Go 版本的大小限制可能不一样。
#### 使用闭包
> 一个函数和对其周围状态（lexical environment，词法环境）的引用捆绑在一起（或者说函数被引用包围），这样的组合就是闭包（closure）。也就是说，闭包让你可以在一个内层函数中访问到其外层函数的作用域。
> — [闭包](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Closures)

```go
func Increase() func() int {
	n := 0
	return func() int {
		n++
		return n
	}
}

func main() {
	in := Increase()
	fmt.Println(in()) // 1
	fmt.Println(in()) // 2
}
```
Increase() 返回值是一个闭包函数，该闭包函数访问了外部变量 n，那变量 n 将会一直存在，直到 in 被销毁。很显然，变量 n 占用的内存不能随着函数 Increase() 的退出而回收，因此将会逃逸到堆上。
#### 传值 vs 传指针
传指针的好处是可以减少值的拷贝以及方便判断，但会导致内存分配逃逸到堆中，增加`GC`的负担。
一般情况下，对于需要修改原对象值，或占用内存比较大的结构体，选择传指针。对于只读的占用内存较小的结构体，直接传值能够获得更好的性能。
[参考1](https://segmentfault.com/q/1010000019133280)[参考2](https://geektutu.com/post/hpg-escape-analysis.html)