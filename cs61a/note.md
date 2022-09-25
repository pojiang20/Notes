#### 1.2.6纯函数与非纯函数
纯函数可以看做一个机器，对于固定的输入一定有固定的返回值。
非纯函数则不是这样，并且有副作用。如`print(a)`的返回值是`none`，副作用是打印。
#### 1.3.6函数抽象
下面是一个函数抽象的简单例子，抽象的作用在于`sum_squares`的计算，不用关心`square`是如何实现的，关心的只是`square`的输入和输出。
```go
from operator import add, mul
def square(x):
    return mul(x, x)

def sum_squares(x, y):
    return add(square(x), square(y))

result = sum_squares(5, 12)
```
对于函数抽象，需要关注一下三点：

- 输入的定义域
- 输出的值域
- 函数意图。
#### 1.6.4 函数作为返回值
这个例子非常有趣，`composel`的传入和返回都是函数，实现了将函数传入来构造新函数。
```go
def square(x):
    return x * x

def successor(x):
    return x + 1

def compose1(f, g):
    def h(x):
        return f(g(x))
    return h

def f(x):
    """Never called."""
    return -x

square_successor = compose1(square, successor)
result = square_successor(12)
```
#### 1.6.6 curry
`g(x)(y)`与`f(x,y)`之间可以相互转换，这种转换适用于只有能传入单参数的情况。如下面的例子，即可遍历计算出以`2`为基数，`0~10`为幂的情况。
```go
def curried_pow(x):
    def h(y):
        return pow(x, y)
    return h
def map_to_range(start, end, f):
    while start < end:
        print(f(start))
        start = start + 1
>>> map_to_range(0, 10, curried_pow(2))

```
而`g(x)(y)`与`f(x,y)`之间的转换可以用一下的模板
```go
>>> def curry2(f):
    """Return a curried version of the given two-argument function."""
    def g(x):
        def h(y):
            return f(x, y)
        return h
    return g
>>> def uncurry2(g):
    """Return a two-argument version of the given curried function."""
    def f(x, y):
        return g(x)(y)
    return f
```
#### data abstraction
用面向对象的思想看待数据：

- _Objects_ combine data values with behavior. 
- Objects are both information and processes, bundled together to represent the properties, interactions, and behaviors of complex things.
- 通过对象的行为来操作数据。

比如下面这个例子，就是对city这个对象进行操作，而对于它数据的计算，都是基于方法如：`get_lat\get_lon\get_name`
```python
from math import sqrt


def distance(city_a, city_b):
    """
    >>> city_a = make_city('city_a', 0, 1)
    >>> city_b = make_city('city_b', 0, 2)
    >>> distance(city_a, city_b)
    1.0
    >>> city_c = make_city('city_c', 6.5, 12)
    >>> city_d = make_city('city_d', 2.5, 15)
    >>> distance(city_c, city_d)
    5.0
    """
    "*** YOUR CODE HERE ***"
    return sqrt((get_lat(city_a) - get_lat(city_b))**2 + (get_lon(city_a) - get_lon(city_b))**2)

def closer_city(lat, lon, city_a, city_b):
    """
    Returns the name of either city_a or city_b, whichever is closest to
    coordinate (lat, lon). If the two cities are the same distance away
    from the coordinate, consider city_b to be the closer city.

    >>> berkeley = make_city('Berkeley', 37.87, 112.26)
    >>> stanford = make_city('Stanford', 34.05, 118.25)
    >>> closer_city(38.33, 121.44, berkeley, stanford)
    'Stanford'
    >>> bucharest = make_city('Bucharest', 44.43, 26.10)
    >>> vienna = make_city('Vienna', 48.20, 16.37)
    >>> closer_city(41.29, 174.78, bucharest, vienna)
    'Bucharest'
    """
    "*** YOUR CODE HERE ***"
    city_target = make_city("target",lat,lon)
    d1,d2 = distance(city_target,city_a),distance(city_target,city_b)
    if d1<d2:
        return get_name(city_a)
    else:
        return get_name(city_b)

def check_city_abstraction():
    """
    There's nothing for you to do for this function, it's just here for the extra doctest
    >>> change_abstraction(True)
    >>> city_a = make_city('city_a', 0, 1)
    >>> city_b = make_city('city_b', 0, 2)
    >>> distance(city_a, city_b)
    1.0
    >>> city_c = make_city('city_c', 6.5, 12)
    >>> city_d = make_city('city_d', 2.5, 15)
    >>> distance(city_c, city_d)
    5.0
    >>> berkeley = make_city('Berkeley', 37.87, 112.26)
    >>> stanford = make_city('Stanford', 34.05, 118.25)
    >>> closer_city(38.33, 121.44, berkeley, stanford)
    'Stanford'
    >>> bucharest = make_city('Bucharest', 44.43, 26.10)
    >>> vienna = make_city('Vienna', 48.20, 16.37)
    >>> closer_city(41.29, 174.78, bucharest, vienna)
    'Bucharest'
    >>> change_abstraction(False)
    """


    # Treat all the following code as being behind an abstraction layer, you shouldn't need to look at it!

def make_city(name, lat, lon):
    """
    >>> city = make_city('Berkeley', 0, 1)
    >>> get_name(city)
    'Berkeley'
    >>> get_lat(city)
    0
    >>> get_lon(city)
    1
    """
    if change_abstraction.changed:
        return {"name": name, "lat": lat, "lon": lon}
    else:
        return [name, lat, lon]


def get_name(city):
    """
    >>> city = make_city('Berkeley', 0, 1)
    >>> get_name(city)
    'Berkeley'
    """
    if change_abstraction.changed:
        return city["name"]
    else:
        return city[0]


def get_lat(city):
    """
    >>> city = make_city('Berkeley', 0, 1)
    >>> get_lat(city)
    0
    """
    if change_abstraction.changed:
        return city["lat"]
    else:
        return city[1]


def get_lon(city):
    """
    >>> city = make_city('Berkeley', 0, 1)
    >>> get_lon(city)
    1
    """
    if change_abstraction.changed:
        return city["lon"]
    else:
        return city[2]
```
#### hw05
```python
class VendingMachine:
    """A vending machine that vends some product for some price.

    >>> v = VendingMachine('candy', 10)
    >>> v.vend()
    'Inventory empty. Restocking required.'
    >>> v.add_funds(15)
    'Inventory empty. Restocking required. Here is your $15.'
    >>> v.restock(2)
    'Current candy stock: 2'
    >>> v.vend()
    'You must add $10 more funds.'
    >>> v.add_funds(7)
    'Current balance: $7'
    >>> v.vend()
    'You must add $3 more funds.'
    >>> v.add_funds(5)
    'Current balance: $12'
    >>> v.vend()
    'Here is your candy and $2 change.'
    >>> v.add_funds(10)
    'Current balance: $10'
    >>> v.vend()
    'Here is your candy.'
    >>> v.add_funds(15)
    'Inventory empty. Restocking required. Here is your $15.'

    >>> w = VendingMachine('soda', 2)
    >>> w.restock(3)
    'Current soda stock: 3'
    >>> w.restock(3)
    'Current soda stock: 6'
    >>> w.add_funds(2)
    'Current balance: $2'
    >>> w.vend()
    'Here is your soda.'
    """
    "*** YOUR CODE HERE ***"
    def __init__(self, name, price):
        self.name = name
        self.price = price
        self.stock = 0
        self.input = 0

    def vend(self):
        if self.stock == 0:
            return f'Inventory empty. Restocking required.'
        else:
            if self.input < self.price:
                return f'You must add ${self.price - self.input} more funds.'
            elif self.input == self.price:
                self.stock -= 1
                self.input -= self.price
                return f'Here is your {self.name}.'
            else:
                fund = self.input
                self.input = 0
                self.stock -= 1
                return f'Here is your {self.name} and ${fund - self.price} change.'

    def add_funds(self,funds):
        self.input += funds
        if self.stock == 0:
            fund = self.input
            self.input = 0
            return f'Inventory empty. Restocking required. Here is your ${fund}.'
        else:
            return f'Current balance: ${self.input}'
    def restock(self,num):
        self.stock += num
        return f'Current {self.name} stock: {self.stock}'

```
#### disc 06
通过三个不同的类 (Server, Client, and Email) 来模拟邮件系统。
建议的处理路线：`Email`类 → `Server`类的`register_client` → `Client`类 → `Server`类的`send`方法。
**思路：**

1. 每个email对象有三个实例属性： 信息、发件人名称、收件人名称
2. 注册：
   1. 服务器`Server`提供注册方法`register_client`，将`client`写入服务器`Server`的`clients`。`clients`是`name:client`的字典
   2. 创建`client`对象时，主动注册即调用`register_client`，将自己注册到`server`
3. `Client`类的`compose`方法：
   - 整合信息，构造对象`Email`实例
   - 使用服务器`Server`服务`send`
4. `Client`类的`recive`方法：向服务器`Server`提供收件方法，即将`msg`追加到`inbox`中
5. `Server`根据`recipient_name`获取`client`，调用`client.recive(email)`收取信息。
```python
class Email:
    """Every email object has 3 instance attributes: the
    message, the sender name, and the recipient name.
    """
    def __init__(self, msg, sender_name, recipient_name):
        "*** YOUR CODE HERE ***"
        self.msg = msg
        self.sender_name = sender_name
        self.recipient_name = recipient_name

class Server:
    """Each Server has an instance attribute clients, which
    is a dictionary that associates client names with
    client objects.
    """
    def __init__(self):
        self.clients = {}

    def send(self, email):
        """Take an email and put it in the inbox of the client
        it is addressed to.
        """
        "*** YOUR CODE HERE ***"
        self.clients[email.recipient_name].receive(email)


    def register_client(self, client, client_name):
        """Takes a client object and client_name and adds them
        to the clients instance attribute.
        """
        "*** YOUR CODE HERE ***"
        self.client[client_name] = client

class Client:
    """Every Client has instance attributes name (which is
    used for addressing emails to the client), server
    (which is used to send emails out to other clients), and
    inbox (a list of all emails the client has received).

    >>> s = Server()
    >>> a = Client(s, 'Alice')
    >>> b = Client(s, 'Bob')
    >>> a.compose('Hello, World!', 'Bob')
    >>> b.inbox[0].msg
    'Hello, World!'
    >>> a.compose('CS 61A Rocks!', 'Bob')
    >>> len(b.inbox)
    2
    >>> b.inbox[1].msg
    'CS 61A Rocks!'
    """
    def __init__(self, server, name):
        self.inbox = []
        "*** YOUR CODE HERE ***"
        self.server = server
        self.name = name
        self.server.register_client(self,name)

    def compose(self, msg, recipient_name):
        """Send an email with the given message msg to the
        given recipient client.
        """
        "*** YOUR CODE HERE ***"
        myEmail = Email(msg,self.name,recipient_name)
        self.server.send(myEmail)

    def receive(self, email):
        """Take an email and add it to the inbox of this
        client.
        """
        "*** YOUR CODE HERE ***"
        self.inbox.append(email)

```
