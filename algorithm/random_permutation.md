```go
func Test_randomPermutation(t *testing.T) {
	n := 9
	res := make([]int, n)
	for i := 0; i < n; i++ {
		//随机选择一个位置j
		j := rand.Intn(i + 1)
		//将位置j的内容放到最后一个位置i
		res[i] = res[j]
		//位置j存放最新的i
		res[j] = i
	}
	log.Println(res)
}

```