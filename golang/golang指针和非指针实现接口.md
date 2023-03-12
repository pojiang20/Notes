先介绍背景和每一个例子，最后有完整代码。
#### 定义
定义了`Intr`接口类型，`noPointer`是值接收者，`receiverPointer`是指针接受者。`pointerArgument`是以指针作为参数，`noPointerArgument`是以值作为参数。
```go
type Intr interface {
	print()
}

type noPointer struct {
}

func (t noPointer) print() {
	fmt.Println("noPointer")
}

type receiverPointer struct {
}

func (s *receiverPointer) print() {
	fmt.Println("receiverPointer")
}
func pointerArgument(i *Intr) {
	(*i).print()
}
func noPointerArgument(i Intr) {
	i.print()
}
```
#### 值接收者+值入参
可执行：方法接受者和函数入参都非指针
```go
t1 := noPointer{}
noPointerArgument(t1)
```
#### 值接收者+指针入参
不可执行：符合函数入参的非指针，但由于方法接收为指针，因此无法执行
传入指针类型即可执行
```go
	// t2 := receiverPointer{}
	// noPointerArgument(t2)
	t2_1 := receiverPointer{}
	noPointerArgument(&t2_1)
```
#### 指针接收者+值入参
可执行：因为`*receiverPointer`实现了`Intr`
```go
	t3 := &receiverPointer{}
	noPointerArgument(t3)
```
#### 值接收者+指针入参
不可执行是因为`*noPointer`没有实现`*Intr`，但由于`noPointer`实现了`Intr`，`*noPointer`也可以作为`Intr`接口类型，所以`var t4_2 Intr = t4_1`成立，再`pointerArgument(&t4_2)`传入指针类型即可。
```go
	//t4 := &noPointer{}
	//pointerArgument(t4)
	t4_1 := &noPointer{}
	var t4_2 Intr = t4_1
	pointerArgument(&t4_2)
```
#### 指针接收者+指针入参
`*receiverPointer实现了Intr`所以`var t7 Intr = t6`正确，然后传入`pointerArgument(&t7)`指针类型即可。
```go
//不可执行：*receiverPointer没有实现*Intr（是*receiverPointer实现了Intr）
	//t5 := &receiverPointer{}
	//pointerArgument(t5)
	//可执行：*receiverPointer实现了Intr
	t6 := &receiverPointer{}
	//因此可以转型
	var t7 Intr = t6
	//传入*Intr
	pointerArgument(&t7)
```
#### 示例代码
```go
type Intr interface {
	print()
}

type noPointer struct {
}

func (t noPointer) print() {
	fmt.Println("noPointer")
}

type receiverPointer struct {
}

func (s *receiverPointer) print() {
	fmt.Println("receiverPointer")
}
func pointerArgument(i *Intr) {
	(*i).print()
}
func noPointerArgument(i Intr) {
	i.print()
}
func Test_mytest(t *testing.T) {
	//可执行：方法接受者和函数入参都非指针
	t1 := noPointer{}
	noPointerArgument(t1)

	//不可执行：符合函数入参的非指针，但由于方法接收为指针，因此无法执行
	//t2 := receiverPointer{}
	//noPointerArgument(t2)
    //可执行写法
	t2_1 := receiverPointer{}
	noPointerArgument(&t2_1)

	//可执行：*receiverPointer实现了Intr
	t3 := &receiverPointer{}
	noPointerArgument(t3)

	//不可执行：*noPointer没有实现*Intr（是noPointer实现了Intr）
	//t4 := &noPointer{}
	//pointerArgument(t4)

    //可执行
	t4_1 := &noPointer{}
	var t4_2 Intr = t4_1
	pointerArgument(&t4_2)

	//不可执行：*receiverPointer没有实现*Intr（是*receiverPointer实现了Intr）
	//t5 := &receiverPointer{}
	//pointerArgument(t5)
	//可执行：*receiverPointer实现了Intr
	t6 := &receiverPointer{}
	//因此可以转型
	var t7 Intr = t6
	//传入*Intr
	pointerArgument(&t7)
}

```
