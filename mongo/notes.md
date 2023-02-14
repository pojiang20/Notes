#### mongo根据bindata的子类型进行查询
MongoDB comparison/sort order compares binary data in 3 steps:
1. First, the length or size of the data.
2. Then, by the BSON one-byte subtype.
3. Finally, by the data, performing a byte-by-byte comparison.
Since legacy and current UUIDs are the same length, you could search from the null UUID in type 3 to the null UUID in type 4, like:
```javascript
db.collection.find({ field: { 
                      $gte: BinData(3,"AAAAAAAAAAAAAAAAAA=="), 
                      $lt: UUID("00000000-0000-0000-0000-000000000000") 
}})
```
[来源](https://stackoverflow.com/questions/66426027/how-to-query-by-bindata-subtype)
#### mongo的writeConcer
write concern是多服务高可用数据库的一个重要概念。它允许你定义，对于一个写，在返回完成之前，它必须经历哪些失败情况。MongoDB支持的writeConcern选项如下
1. w：数据写入到number个节点才向客户端确认
- {w:0} 对客户端的写入不需要发送任何确认，适用于性能要求高，但不关注正确性的场景
```javascript
mongos> db.blogs.insert({ename:"leshami",url:"http://blog.csdn.net/leshami"},{writeConcern:{w:0}})
WriteResult({ })   //此处应答为空
```
- {w:1} 默认情况，数据写入到Primary就向客户端发送确认
```javascript
mongos> db.blogs.insert({ename:"john",url:"http://blog.csdn.net/john"},{writeConcern:{w:1}})
WriteResult({ "nInserted" : 1 })    //此处应答信息显示为1个文档已插入
```
- {w:"majority"} 数据写入到副本集大多数成员后向客户端发送确认，适用于对数据安全性要求比较高的场景，该选项会降低写入性能。
2. j：写入操作的journal持久化后才向客户端确认
- 默认{j:false}，如果要求Primary写入持久化了才向客户端确认，则指定该选项为true
3. wtimeout: 写入超时时间，仅w的值大于1时有效。
- 当指定{w: }时，数据需要成功写入number个节点才算成功，如果写入过程中有节点故障，可能导致这个条件一直不能满足，从而一直不能向客户端发送确认结果，针对这种情况，客户端可设置wtimeout选项来指定超时时间，当写入过程持续超过该时间仍未结束，则认为写入失败。

#### cmd中使用数组而不是map
golang使用mongo过程中，会用到bson格式，这里有如下两种。
```go
type D []DocElem
type M map[string]interface{}
```
bson.D是一个数组，存有的DocElem是k-v。bson.M是map，直接存储k-v。golang的map是无序的，有时候需要保证数据相对顺序，这时候就需要使用bson.D。比如下面的场景：
```go
cmd := bson.D{
    {Name: "insert", Value: w.session.Coll.Name},
    {Name: "documents", Value: data},
    //其他参数
}
err = w.session.Coll.Database.Run(cmd, &res)
```
这种情况如果使用map，就会因为map的不确定导致insert位置的不确定，从而导致命令错误。

#### mongo push
push操作可以直接追加内容，例如下面的例子，就是给`_id=1`的条目追加`scores=89`内容
```javascript
db.students.update(
   { _id: 1 },
   { $push: { scores: 89 } }
)
```

#### mongo contains
mongoDB中用正则来实现『字段中存在xx』的功能，如`db.testDB.find({_id:{$regex:"yyy"}})`这条命令查找的就是`_id`中存在`yyy`的所有数据。
`db.testDB.find({_id:{$regex:"^yyy"}})`查询以yyy为开头的所有数据。