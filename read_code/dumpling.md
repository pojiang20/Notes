# TiDB dumpling笔记

[dumpling](https://github.com/pingcap/tidb/blob/master/dumpling/export/writer.go)是`golang`实现的`tidb`数据导出工具。下面是部分笔记（以我目前`2022-11-03 15:11:39`的能力无法很好理解代码，以至于迷失在庞大的结构中。

### 指定名称
实现指定导出文件的名称，使用`text/template`库来实现。下面实现`bucketName_time_fileName`
#### 实现
按照`text/template`库解析规则规定输入格式，然后直接使用库来解析规则。`tmpl, err := ParseOutputFileTemplate(outputFilenameFormat)`就是直接将输入的字符串`outputFilenameFormat`解析成为`tmpl *Template template`。其中`ParseOutputFileTemplate`就是对`text/template`库的封装。
```go
func ParseOutputFileTemplate(text string) (*template.Template, error) {
	return template.Must(DefaultOutputFileTemplate.Clone()).Parse(text)
}
```
最后渲染`tmpl`然后拼接后缀即可。
```go
func (namer *outputFileNamer) NextName(tmpl *template.Template, fileType string) (string, error) {
	res, err := namer.render(tmpl, outputFileTemplateData)
	namer.FileIndex++
	return res + "." + fileType, err
}
```
### write工具
这一节是`writeInsert`实现。
```go
func WriteInsert(
	pCtx *tcontext.Context,
	cfg *Config,
	meta TableMeta,
	tblIR TableDataIR,
	w storage.ExternalFileWriter,
	metrics *metrics,
) (n uint64, err error) {
}
```

- `meta`存储元数据，也就是在导出数据开头需要添加部分信息，比如`csv`文件的起始部分需要`field`。
- `tblIR`存储中间数据`intermediate representation`，这里主要通过它获取迭代器。
```go
// TableDataIR is table data intermediate representation.
// A table may be split into multiple TableDataIRs.
type TableDataIR interface {
	Start(*tcontext.Context, *sql.Conn) error
	Rows() SQLRowIter
	Close() error
	RawRows() *sql.Rows
}
```

- `w`是外部存储接口，定义`write`。
```go
// ExternalFileWriter represents the streaming external file writer.
type ExternalFileWriter interface {
	// Write writes to buffer and if chunk is filled will upload it
	Write(ctx context.Context, p []byte) (int, error)
	// Close writes final chunk and completes the upload
	Close(ctx context.Context) error
}

```
#### 元数据处理
获取迭代器将数据写入`buffer`，并设置`fileSize`
```go
	specCmtIter := meta.SpecialComments()
	for specCmtIter.HasNext() {
		bf.WriteString(specCmtIter.Next())
		bf.WriteByte('\n')
	}
	wp.currentFileSize += uint64(bf.Len())
```
#### 管道模型
先初始化`writerPipe`，并将写功能`w`交给它
`wp := newWriterPipe(w, cfg.FileSize, cfg.StatementSize, metrics, cfg.Labels)`
使用迭代器获取数据写入`buffer`，`buffer`到达一定大小，使用`wp.input<-buffer`将`buffer`交给管道。并用`pool.Get()`重新获取`buffer`，迭代完成后，如果`buffer`有剩余内容也需要传输到`wp`
```go
for fileRowIter.HasNext() {
    fileRowIter.Next()
    //writing to buffer
    if bf.Len() >= lengthLimit {
        select {
        ...
        case wp.input <- bf:
            bf = pool.Get().(*bytes.Buffer)
            if bfCap := bf.Cap(); bfCap < lengthLimit {
                bf.Grow(lengthLimit - bfCap)
            }
            lastCounter = counter
        }
    }
}
if bf.Len() > 0 {
    wp.input <- bf
}
```
`writerPipe`的`run`则是在不断从`input`消费`buffer`，`writeBytes`写入数据，然后`reset()`清空`buffer`并`pool.Put(s)`交还给`pool`。
```go
func (b *writerPipe) Run(tctx *tcontext.Context) {
	for {
		select {
		case s, ok := <-b.input:
			if !ok {
				return
			}
			if errOccurs {
				continue
			}
			err := writeBytes(tctx, b.w, s.Bytes())
			s.Reset()
			pool.Put(s)
		case <-tctx.Done():
			return
		}
	}
}
```
### 分文件写
`writeInsert`在`tryToWriteTableData`来实现分文件写，这里构造`namer`使用`nextName`构造文件名，构造出新的文件名来初始化`fileWriter`执行`writeInsert`。
```go
func (w *Writer) tryToWriteTableData(tctx *tcontext.Context, meta TableMeta, ir TableDataIR, curChkIdx int) error {
	...
	namer := newOutputFileNamer(meta, curChkIdx, conf.Rows != UnspecifiedSize, conf.FileSize != UnspecifiedSize)
	fileName, err := namer.NextName(conf.OutputFileTemplate, w.fileFmt.Extension())

	somethingIsWritten := false
	for {
		fileWriter, tearDown := buildInterceptFileWriter(tctx, w.extStorage, fileName, conf.CompressType)
		n, err := format.WriteInsert(tctx, conf, meta, ir, fileWriter, w.metrics)
        ...
		fileName, err = namer.NextName(conf.OutputFileTemplate, w.fileFmt.Extension())
    	...
	}
	return nil
}
```
在`writeInsert`不断写入过程中，如果符合`ShouldSwitchFile`就直接退出循环写。交由`tryToWriteTableData`创建文件。
```go
    if wp.ShouldSwitchFile() {
        break
    }
```
