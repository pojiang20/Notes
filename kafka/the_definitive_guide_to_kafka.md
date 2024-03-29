### 1.2.4 生产者消费者
群组保证每个分区只能被一个消费者使用。消费者和分区之间的映射通常被称为消费者对分区的所有权关系。即消费者组与主题一一对应，而消费者组中的消费者与主题中的分区一一对应。

### 1.2.5 broker和集群
集群中，一个分区从属于一个broker，分区可以在多个broker中冗余，一个具体的分区在broker集群中会有首领，数据从首领同步到其他follower。

### 4.8 从特定偏移量处开始处理记录
作为消费者如果想持久化消息，可以同时存储偏移量+数据，这样可以在重启后从持久化的偏移量继续处理数据，防止重复处理。数据和偏移量的同时写入可以使用事务完成。

### 5.4.2 获取请求
Kafka使用零拷贝（zero-copy）技术向客户端发送消息————也就是说，kafka直接把消息从文件（更确切地说是Linux文件系统缓存）里发送到网络通道，而不需要结果任何中间缓冲区。这项技术避免了字节复制，也不需要管理内存缓冲区，从而获得更好的性能。

### 11.1 流式处理
- 什么是数据流：数据流是无边界数据集的抽象表示。无边界意味着无限和持续增长。无边界数据集之所以是无限的，是因为随着时间的推移，新的记录会不断加入进来。
- 批处理：批处理有高延迟和高吞吐的特点。它们每天加载巨大批次的数据，并生成报表，用户在下一次加载数据之前看到的都是相同的报表。
- 流式处理：流式处理不要求亚秒级别的响应（OLTP），不过也受不了要等到第二天才知道结果。
- 如何理解'半结构化的json和结构化的protobuf'，JSON是一种半结构化的数据格式，因为它既可以包含预定义的键值对（这部分具有结构化的特征），也可以包含任何合法的JSON数据类型作为值（例如数组、数字、字符串、布尔值等，这部分具有非结构化的特征）。

### 11.2.3 流和表的二元性
流包含了变更，流是一系列事件，每个事件就是一个变更。表包含了当前的状态，是多个变更所产生的结果。
为了将表转换成流，需要捕捉到表上所发生的变更，将insert\update\delete事件保存到流里。为了将流转换成表，需要应用流里所包含的所有变更，这个过程叫作流的物化。首先在内存里，内部状态存储或外部数据库创建一个表，然后从头到尾遍历流里的所有事件。逐个地改变状态，在完成这个过程之后，得到了一个表，它代表了某个时间点的状态。