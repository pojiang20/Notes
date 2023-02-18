## rabbitMQ支持五种消息模型：
#### hello world
![https://www.rabbitmq.com/img/tutorials/python-one.png](img.png)
单生产者单消费者+有缓存队列。其缓存大小受物理设备限制。

#### worker模型
![https://www.rabbitmq.com/img/tutorials/python-two.png](img_1.png)
单生产者多消费者，消息消费一次且消费者先到先得。

#### 订阅者发布者模型
![https://www.rabbitmq.com/img/tutorials/python-three.png](img_2.png)
生产者的消息被广播到所有订阅者，是一对多的。

#### 路由模型
![https://www.rabbitmq.com/img/tutorials/python-four.png](img_3.png)
消费者可以有选择性的获取数据。

#### topics模型
![https://www.rabbitmq.com/img/tutorials/python-five.png](img_4.png)
基于表达式，将消息匹配到不同的消费者。

https://www.rabbitmq.com/getstarted.html
[参考](https://www.cnblogs.com/ZhuChangwu/p/14093107.html)