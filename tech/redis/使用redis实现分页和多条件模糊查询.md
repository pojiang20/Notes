[参考](https://developer.aliyun.com/article/1171184)

### redis分页
对于指定id排序进行分页，可以使用zset实现，其中id作为score，能够符合数据有序+分页查找。其中分页通过计算offset即可。

### 多条件模糊查询
使用哈希表+HScan的模式匹配来实现模糊搜索，比如key=users下将field设计为**id:name:gender**的模式，value是详细信息。在Hscan中指定patern=`*:*:男`的模式即可检索到所有男性users。

#### redis分页+模糊检索
1. 使用哈希表+hscan做模糊检索
2. 将结果存储到zset中
3. 后续查询如果命中，则直接使用zset。如果未命中，则需要进行1、2操作。主要需要一定的淘汰策略，这里可以使用简单的设置key的过期时间来淘汰数据。