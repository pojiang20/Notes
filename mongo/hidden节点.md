> A hidden member maintains a copy of the primary's data set but is invisible to client applications. Hidden members are good for workloads with different usage patterns from the other members in the replica set. Hidden members must always be priority 0 members and so cannot become primary.[参考](https://www.mongodb.com/docs/manual/core/replica-set-hidden-member/)
隐藏节点处理请求，如果通过隐藏节点获取数据，可以减少服务器压力。
