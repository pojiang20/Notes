## rabbitMQ支持五种消息模型：
#### hello world
![示例](https://www.rabbitmq.com/img/tutorials/python-one.png)
单生产者单消费者+有缓存队列。其缓存大小受物理设备限制。

#### worker模型
![示例](https://www.rabbitmq.com/img/tutorials/python-two.png)  
单生产者多消费者，消息消费一次且消费者先到先得。

#### 订阅者发布者模型
![示例](https://www.rabbitmq.com/img/tutorials/python-two.png)  
生产者的消息被广播到所有订阅者，是一对多的。

#### 路由模型
![示例](https://www.rabbitmq.com/img/tutorials/python-four.png)
消费者可以有选择性的获取数据。

#### topics模型
![示例](https://www.rabbitmq.com/img/tutorials/python-five.png)
基于表达式，将消息匹配到不同的消费者。

[官方教程](https://www.rabbitmq.com/getstarted.html)
[参考文章](https://www.cnblogs.com/ZhuChangwu/p/14093107.html)