## 2.2 名副其实
变量、函数或类的名称应该已经答复了所有的大问题。它该告诉你，它为什么会存在，它做什么事，应该怎么用。如果名称需要注释来补充，那就不算是名副其实。

## 2.3 避免误导
别用 accountList 来指称一组账号，除非它真的是 List 类型。List 一词对程序员有特殊意义。如果包纳账号的容器并非真是个 List，就会引起错误的判断[3]。所以，用 accountGroup 或 bunchOfAccounts，甚至直接用 accounts 都会好一些。


## 2.4 做有意义的区分
以数字系列命名（a1、a2，……aN）是依义命名的对立面。这样的名称纯属误导——完全没有提供正确信息；没有提供导向作者意图的线索。试看：
```
public static void copyChars(char a1[], char a2[]) {
  for (int i = 0; i < a1.length; i++) {
    a2[i] = a1[i];
  }
}
```
如果参数名改为 source 和 destination，这个函数就会像样许多。

废话是另一种没意义的区分。假设你有一个 Product 类。如果还有一个 ProductInfo 或 ProductData 类，那它们的名称虽然不同，意思却无区别。Info 和 Data 就像 a、an 和 the 一样，是意义含混的废话。

废话都是冗余。Variable 一词永远不应当出现在变量名中。Table 一词永远不应当出现在表名中。NameString 会比 Name 好吗？难道 Name 会是一个浮点数不成？如果是这样，就触犯了关于误导的规则。设想有个名为 Customer 的类，还有一个名为 CustomerObject 的类。区别何在呢？哪一个是表示客户历史支付情况的最佳途径？

有个应用反映了这种状况。为当事者讳，我们改了一下，不过犯错的代码的确就是这个样子：
```
getActiveAccount();
getActiveAccounts();
getActiveAccountInfo();
```
程序员怎么能知道该调用哪个函数呢？

如果缺少明确约定，变量 moneyAmount 就与 money 没区别， customerInfo 与 customer 没区别，accountData 与 account 没区别， theMessage 也与 message 没区别。要区分名称，就要以读者能鉴别不同之处的方式来区分。

## 2.6 使用可搜索的名称
单字母名称和数字常量有个问题，就是很难在一大篇文字中找出来。

找 MAX_CLASSES_PER_STUDENT 很容易，但想找数字 7 就麻烦了，它可能是某些文件名或其他常量定义的一部分，出现在因不同意图而采用的各种表达式中。如果该常量是个长数字，又被人错改过，就会逃过搜索，从而造成错误。


## 2.9 类名
类名和对象名应该是名词或名词短语，如 Customer、WikiPage、Account 和 AddressParser。避免使用 Manager、Processor、Data 或 Info 这样的类名。类名不应当是动词。

## 2.10 方法名
方法名应该是动词或者动词短语

## 2.12 每种概念对应一个词
给每个抽象概念选一个词，并且一以贯之。例如，使用 fetch、 retrieve 和 get 来给在多个类中的同种方法命名。你怎么记得住哪个类中是哪个方法呢？

在同一堆代码中有 controller，又有 manager，还有 driver，就会令人困惑。DeviceManager 和 Protocol-Controller 之间有何根本区别？为什么不全用 controllers 或 managers？他们都是 Drivers 吗？这种名称，让人觉得这两个对象是不同类型的，也分属不同的类。

