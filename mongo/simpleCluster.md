# 简单集群
这是平时用到的一个简单`mongo`集群

#### 集群关系
副本集是一份数据拷贝成多份冗余存储，分片是一份数据分割成多份分开存储。
该集群模型中，有两个副本集`rs0/rs1`，每个副本集中只有一台机器/节点。然后开启了`shard`分片，并且`sh.addShard("rs0/127.0.0.1:27017")`、`sh.addShard("rs1/127.0.0.1:27116")`添加了两台机器。也就是一份数据会划分分别存储到`27017/27116`中，又由于它们是副本集所以划分到内部的数据会复制冗余（这里只有单副本所以不会复制）。
再说路由关系，我们使用`mongos`处理请求，也就是`mongos`判断查询的内容在哪一个`shard`，而这个判断的内容存储在`mongo config`中，`config={_id:"configrs1",members:[{_id:0,host:"127.0.0.1:27019"},{_id:1,host:"127.0.0.1:27119"},{_id:2,host:"127.0.0.1:27219"}]}`这里有三台机器存储`config`。
#### 配置节点
`nohup mongod --port 27019 --dbpath /Users/ziyang/qbox/shard/myconfigrs/myconfigrs_27019 --replSet configrs1 --configsvr > cfg1 &`
`nohup mongod --port 27119 --dbpath /Users/ziyang/qbox/shard/myconfigrs/myconfigrs_27119 --replSet configrs1 --configsvr > cfg2 &`
`nohup mongod --port 27219 --dbpath /Users/ziyang/qbox/shard/myconfigrs/myconfigrs_27219 --replSet configrs1 --configsvr > cfg3 &`
内部配置
`config={_id:"configrs1",members:[{_id:0,host:"127.0.0.1:27019"},{_id:1,host:"127.0.0.1:27119"},{_id:2,host:"127.0.0.1:27219"}]}`
`rs.initiate(config)`
#### shard配置
##### rs0
`nohup mongod --port 27017 --shardsvr --dbpath /Users/ziyang/qbox/shard/rs0/mongodata_27017 --replSet rs0 > rs0 &`启动mongo
连接`mongo`：`mongo --port 27017`
修改配置文件，加入副本集`rs0``config = {_id:"rs0", members:[{_id:0,host:"127.0.0.1:27017"}]}`
##### rs1
`nohup mongod --port 27116 --shardsvr --dbpath /Users/ziyang/qbox/shard/rs1/mongodata_27116 --replSet rs1> rs1&`启动mongo
连接`mongo`：`mongo --port 27116`
修改配置文件，加入副本集`rs1` `config = {_id:"rs1", members:[{_id:0,host:"127.0.0.1:27116"}]}`
#### mongos
`nohup mongos --port 27777 --configdb=configrs1/localhost:27019,localhost:27119,localhost:27219 > mongos&`添加了配置节点
在`mongos`添加`shard`：先连接`mongo --port 27777`然后执行`sh.addShard("rs0/127.0.0.1:27017")`、`sh.addShard("rs1/127.0.0.1:27116")`
#### 数据查看
`use config`即可看到所有配置内容
`db.shards.find()`可以看到当前对应的`shard`
#### 导入csv
mongoimport --db testDB --collection testfile256m --type csv --headerline --ignoreBlanks --file /Users/ziyang/qbox/static/file256m.csv
#### 连接mongos
`mongo --port 27777`
#### 上述配置是单副本的
在启动阶段设置`--replSet rs0`、`--replSet rs1`设置了两个副本集，每个副本集中只有一个节点。（`mongo --port 27116/27017`可以看到它们都是`primary`）
```go
rs0:PRIMARY> rs.conf()
{
	"_id" : "rs0",
	"version" : 1,
	"protocolVersion" : NumberLong(1),
	"writeConcernMajorityJournalDefault" : true,
	"members" : [
		{
			"_id" : 0,
			"host" : "127.0.0.1:27017",
			"arbiterOnly" : false,
			"buildIndexes" : true,
			"hidden" : false,
			"priority" : 1,
			"tags" : {

			},
			"slaveDelay" : NumberLong(0),
			"votes" : 1
		}
	],
	"settings" : {
		"chainingAllowed" : true,
		"heartbeatIntervalMillis" : 2000,
		"heartbeatTimeoutSecs" : 10,
		"electionTimeoutMillis" : 10000,
		"catchUpTimeoutMillis" : -1,
		"catchUpTakeoverDelayMillis" : 30000,
		"getLastErrorModes" : {

		},
		"getLastErrorDefaults" : {
			"w" : 1,
			"wtimeout" : 0
		},
		"replicaSetId" : ObjectId("630f054fd9e1a05dbacfc5d4")
	}
}
```
要设置多副本应该在同一个副本集如`rs0`中添加多个节点如`27017/27116`。

##### 启动shell
```shell
#!/bin/bash
nohup mongod --port 27019 --dbpath /Users/ziyang/qbox/shard/myconfigrs/myconfigrs_27019 --replSet configrs1 --configsvr > cfg1 &
nohup mongod --port 27119 --dbpath /Users/ziyang/qbox/shard/myconfigrs/myconfigrs_27119 --replSet configrs1 --configsvr > cfg2 &
nohup mongod --port 27219 --dbpath /Users/ziyang/qbox/shard/myconfigrs/myconfigrs_27219 --replSet configrs1 --configsvr > cfg3 &

nohup mongod --port 27017 --shardsvr --dbpath /Users/ziyang/qbox/shard/rs0/mongodata_27017 --replSet rs0 > rs0_log &
nohup mongod --port 27116 --shardsvr --dbpath /Users/ziyang/qbox/shard/rs1/mongodata_27116 --replSet rs1 > rs1_log &

nohup mongos --port 27777 --configdb=configrs1/localhost:27019,localhost:27119,localhost:27219 > mongos&
```