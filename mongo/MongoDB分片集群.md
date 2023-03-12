#### 分片集群
[https://segmentfault.com/a/1190000038994491](https://segmentfault.com/a/1190000038994491)
### 分片
#### 为什么要用分片集群
MongoDB的由副本集保证高可用，由分片集群保证可扩展性。
当MongoDB副本集遇到下面的业务场景时，你就需要考虑使用分片集群

- 存储容量需求超出单机磁盘容量
- 活跃的数据集超出单机内存容量，导致很多请求都要从磁盘读取数据，影响性能
- 写IOPS超出单个MongoDB节点的写服务能力
#### 分片集群的结构
多个节点构成一个副本集（避免单点故障，高可用），可以将一个副本集`sh.addSharding()`作为一个分片。多个分片构成分片集群，通过`mongos`作为集群的访问入口，`mongos`进行路由而不实际持久化数据，集群的元数据存储在`config server`中。
![image.png](../static/img/%E5%88%86%E7%89%87%E9%9B%86%E7%BE%A41.png)
#### 范围分片
对于关键字`key`，将其以范围分配在不同的`chunk`中，每一个`chunk`会记录`$min~$max`对应的`key`，这些信息存储在`config server`中，当查询『key在xx~xx之间所有文档时』，`mongos`就能直接将请求路由到某一个`chunk`。
#### 哈希分片
对`key`做哈希，映射到某一个`chunk`。
#### config server
存储了集群的元数据，也可以是副本集保证其高可用。
config.shard查看分片信息
```go
mongos> db.shards.find().pretty()
{ "_id" : "rs0", "host" : "rs0/127.0.0.1:27017", "state" : 1 }
{ "_id" : "rs1", "host" : "rs1/127.0.0.1:27116", "state" : 1 }
```
config.database查看数据库分片情况
```go
mongos> db.databases.find().pretty()
{
	"_id" : "testDB",
	"primary" : "rs1",
	"partitioned" : true,
	"version" : {
		"uuid" : UUID("12817a63-a783-4488-9a65-3d10b7eb6fa"),
		"lastMod" : 1
	}
}
```
> sh.enableSharding("testDB")来对数据库开启分片，该数据库内容会存储到`primary shard`中

config.collections查看
```go
mongos> db.collections.find().pretty()
{
	"_id" : "testDB.testColl",
	"lastmodEpoch" : ObjectId("63622f58edb5ea91f1cb59d0"),
	"lastmod" : ISODate("1970-02-19T17:02:47.303Z"),
	"dropped" : false,
	"key" : {
		"_id" : 1
	},
	"unique" : false,
	"uuid" : UUID("6329a31c-d19c-4a99-93be-b81e242b0ad7")
}
```
> sh.shardCollection("testDB.testColl",{_id:1})对指定namespace添加range分片。哈希分片则是`{_id:hashed}`。

config.chunks查看分片
```go
mongos> db.chunks.find().pretty()
{
	"_id" : "sharding_test.test-_id_4242751136953196730",
	"ns" : "sharding_test.test",
	"min" : {
		"_id" : NumberLong("4242751136953196730")
	},
	"max" : {
		"_id" : NumberLong("4279644625100615832")
	},
	"shard" : "rs1",
	"lastmod" : Timestamp(1, 365),
	"lastmodEpoch" : ObjectId("6350e6a6c114726f63ffc21d"),
	"history" : [
		{
			"validAfter" : Timestamp(1666246310, 535),
			"shard" : "rs1"
		}
	]
}
```
[参考](https://developer.aliyun.com/article/32434)
### split与movechunk
> chunk （块）是均衡器迁移数据的最小单元，默认大小为 64MB，取值范围为 1-1024MB。一个块只存在于一个分片，每个块由片键特定范围内的文档组成，块的范围为左闭又开即 [start,end) 。一个文档属于且只属于一个块，当一个块增加到特定大小的时候，会通过拆分点（split point）被拆分成 2 个较小的块。在有些情况下，chunk 会持续增长，超过 ChunkSize，官方称为 jumbo chunk ，该块无法被 MongoDB 拆分，也不能被均衡器迁移，故久而久之会导致 chunk 在分片服务器上分布不均匀，从而成为性能瓶颈，表现之一为 insert 数据变慢。 所以不能balance。

对于`range`分片，一个`chunk`不断增长，到达阈值之后会触发`chunk`分裂，将一个`chunk`的范围分裂为多个，这个过程是`split`。
`mongos`的后台线程会进行自动负载均衡，即一个`shard`的`chunk`数量超过一定阈值就会触发迁移，这个过程是`movechunk`。
[MongoDB sharding迁移那些事（一）](https://developer.aliyun.com/article/60881) [MongoDB sharding迁移那些事（二）](https://developer.aliyun.com/article/60935)
