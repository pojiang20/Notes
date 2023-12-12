# Notes
这是我在学习过程中的记录和总结

## Golang
| 类型  | 文章                                                                                                                                   |
|-----|--------------------------------------------------------------------------------------------------------------------------------------|
| 基础  | [日常开发问题记录](./golang/%E6%97%A5%E5%B8%B8%E5%BC%80%E5%8F%91%E9%97%AE%E9%A2%98%E8%AE%B0%E5%BD%95.md)                                     |
| 总结  | [channel问题记录](./golang/channel.md)                                                                                                   |
| 对比  | [指针类型和非指针类型实现接口在使用时的区别](/golang/golang%E6%8C%87%E9%92%88%E5%92%8C%E9%9D%9E%E6%8C%87%E9%92%88%E5%AE%9E%E7%8E%B0%E6%8E%A5%E5%8F%A3.md) |
| 对比  | [函数返回值和返回指针的区别](./golang/%E8%BF%94%E5%9B%9E%E6%8C%87%E9%92%88vs%E8%BF%94%E5%9B%9E%E5%80%BC.md)                                       |
| 笔记  | [类型转换和类型比较](./golang/golang%E7%B1%BB%E5%9E%8B%E8%BD%AC%E6%8D%A2.md)                                                                  |
| 笔记  | [Runner和Worker并发模型](./golang/%E5%B9%B6%E5%8F%91%E6%A8%A1%E5%9E%8B.md)                                                                |

## Algorithm
| 类型  | 文章                                                                                                     |
|-----|--------------------------------------------------------------------------------------------------------|
| 练习  | [hot100](./algorithm/hot100.md) |

## MongoDB
| 类型  | 文章                                                                                                     |
|-----|--------------------------------------------------------------------------------------------------------|
| 基础  | [日常开发问题记录](./mongo/notes.md)                                                                           |
| 练习  | [本地部署MongoDB分片集群](./mongo/%E6%9C%AC%E5%9C%B0%E9%83%A8%E7%BD%B2%E5%88%86%E7%89%87%E9%9B%86%E7%BE%A4.md) |
| 笔记  | [《MongoDB权威指南2》笔记](./mongo/MongoDB%E6%9D%83%E5%A8%81%E6%8C%87%E5%8D%972%20%E7%AC%94%E8%AE%B0.md)       |
| 总结  | [MongoDB分片集群](./mongo/MongoDB%E5%88%86%E7%89%87%E9%9B%86%E7%BE%A4.md)                                  |


## Redis
| 类型  | 文章                                                                                                     |
|-----|--------------------------------------------------------------------------------------------------------|
| 笔记  | [《Redis开发与运维》](./redis/Redis开发与运维.md)                                                                        |
| 笔记  | [redis实现分页和模糊搜索](./redis/使用redis实现分页和多条件模糊查询.md)                                                      |


## Tools
| 类型  | 文章                                                                                    |
|-----|---------------------------------------------------------------------------------------|
| 基础  | [Git日常使用笔记](./tools/Git%E6%97%A5%E5%B8%B8%E4%BD%BF%E7%94%A8%E7%AC%94%E8%AE%B0.md)     |
| 练习  | [Git rebase练习](./tools/Git%20rebasePractice.md)                                       |
| 笔记  | [Git提交规范](./tools/Git%E6%8F%90%E4%BA%A4%E8%A7%84%E8%8C%83.md)                         |
| 基础  | [Shell日常使用笔记](./tools/Shell%E6%97%A5%E5%B8%B8%E4%BD%BF%E7%94%A8%E7%AC%94%E8%AE%B0.md) |
| 笔记  | [Shell学习笔记](./tools/Shell%E5%AD%A6%E4%B9%A0%E7%AC%94%E8%AE%B0.md)                     |
| 练习  | [Shell 练习](./tools/shellPractice/)                                                    |
| 基础  | [Vim日常使用笔记](./tools/Vim%E6%97%A5%E5%B8%B8%E4%BD%BF%E7%94%A8%E7%AC%94%E8%AE%B0.md)     |

## 读代码
| 文章                                                          | 简介                                                                       |
|-------------------------------------------------------------|--------------------------------------------------------------------------|
| [machinery源码笔记](https://github.com/pojiang20/machineryDemo) | machinery是分布式任务处理工具，它由server提供接口、broker分发、worker执行，支持任务的注册和链式、批量、回调执行操作。 |
| [dumpling笔记](./read_code/dumpling.md)                       | dumpling是Tidb的数据导出工具，支持多格式导出、上传到s3、分文件存储等功能，这里对其部分功能做了简单的笔记。             |
| [cron笔记](https://github.com/pojiang20/cronDemo)             | cron是golang中管理定时任务的库，可以添加一系列任务并制定执行规则来执行这些任务。其关键在于对一系列任务进行调度。            |
| [go-redis pool笔记](https://github.com/pojiang20/redis-pool)  | demo简单使用连接池，并学习go-redis中连接池管理，且自己简单实现了连接池的put\get。                       |

## 其他
| 类型  | 文章                                                                                                      |
|-----|---------------------------------------------------------------------------------------------------------|
| 笔记  | [RabbitMQ消息模型](./other/RabbitMQ%E6%B6%88%E6%81%AF%E6%A8%A1%E5%9E%8B.md)                                 |
| 笔记  | [设计模式之美](./design_patterns/%E8%AE%BE%E8%AE%A1%E6%A8%A1%E5%BC%8F%E4%B9%8B%E7%BE%8E%E7%AC%94%E8%AE%B0.md) |
| 笔记  | [websocket握手](./other/websocket握手.md) |
| 总结  | [get的参数不适合复杂数据结构](./other/get的参数不适合复杂数据结构.md) |
| 总结  | [raft、gossip和flooding](./other/raft、gossip和flooding.md) |

[零碎知识](./other/%E9%9B%B6%E7%A2%8E%E7%9F%A5%E8%AF%86%E7%82%B9.md)