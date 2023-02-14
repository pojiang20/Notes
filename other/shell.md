#### 2 &> 1
`2>&1`代表将`stderr`重定向到文件描述符为1的文件(即`/dev/stdout`)中。
以`ls >list.txt 2>&1`为例，从左往右执行，执行到`>list.txt`即标准输出重定向到`list.txt`文件，执行到`2>&1`即`stderr`重定向到`stdout`也就是`list.txt`文件中

#### ps的aux和ef区别
都是输出所有进程信息，只是输出格式不同。


## 学习笔记
#### shell脚本的几种执行方式
1. `sh/bash xx.sh` 
2. 直接执行脚本，但是文件本身需要是可执行的即`chmod +x xxx.sh`。在同级目录中无法直接使用脚本名执行，而是`./xx.sh`执行脚本。 
3. `source xx.sh`或者`. xx.sh`。（比如您在一个脚本里export $KKK=111 ,假如您用./a.sh执行该脚本，执行完毕后，您运行 echo $KKK，发现没有值，假如您用source来执行 ，然后再echo，就会发现KKK=111。因为调用./a.sh来执行shell是在一个子shell里运行的，所以执行后，结构并没有反应到父shell里，但是source不同他就是在本shell中执行的，所以能够看到结果。

### 变量
#### 变量设置
系统预定义了一系列全局变量如$HOME\$PWD，这些变量在任何shell脚本中都可以使用。`my_var=aa`语句可以直接设置局部变量，但仅供当前shell使用，`export my_var`来将局部变量设置为全局变量，任何父子shell切换后都可以使用。

#### 字符串处理
单引号
- 单引号里的任何字符都会原样输出，单引号字符串中的变量是无效的；
- 单引号字串中不能出现单独一个的单引号（对单引号使用转义符后也不行），但可成对出现，作为字符串拼接使用
双引号
- 双引号里可以有变量
- 双引号里可以出现转义字符
```shell
name="kkk"
str="Hello, I know you are \"$name\"! \n"
echo -e $str
```
获取字符串长度
```shell
string="abcd"
echo ${#string}
```

#### 数组
赋值：`array_name=(value0 value1 value2 value3)`
读取：`value=${array_name[n]}`
读取所有元素：`echo ${array_name[@]}`或者`echo ${array_name[*]}`

#### 注释
多行注释
```shell
:<<EOF
注释内容...
注释内容...
注释内容...
EOF
```

### 传参
`$n`表示第n个参数，如`$1`表示执行脚本的第一个参数。`$0`为执行的文件名。
`$#`	传递到脚本的参数个数
`$*`	以一个单字符串显示所有向脚本传递的参数。如"$*"用「"」括起来的情况、以"$1 $2 … $n"的形式输出所有参数。
`$$`	脚本运行的当前进程ID号
`$!`	后台运行的最后一个进程的ID号
`$@`	与$*相同，但是使用时加引号，并在引号中返回每个参数。如"$@"用「"」括起来的情况、以"$1" "$2" … "$n" 的形式输出所有参数。
`$-`	显示Shell使用的当前选项，与set命令功能相同。
`$?`	显示最后命令的退出状态。0表示没有错误，其他任何值表明有错误。

### test命令
test通常和if一起使用，用法是`test exprression`也可以简写成`[ expression ]`注意这里的空格是必须的

### 流程控制
#### if else
```shell
if condition
then
    command1 
    command2
    ...
    commandN
else
    command
fi
```
下面是两个变量是否相等判断
```shell
a=10
b=20
if [ $a == $b ]
then 
    echo "a等于b"
elif [ $a -gt $b ]
then
    echo "a大于b"
elif [ $a -lt $b ]
then
    echo "a小于b"
else 
    echo "没有符合的条件"
fi
```
#### for循环
```shell
for var in item1 item2 ... itemN
do
    command1
    command2
    ...
    commandN
done
```
下面是遍历数字的例子
```shell
for loop in 1 2 3 4 5
do 
    echo "The value is：$loop"
done 
```
#### while
```shell
while condition
do
    command
done
```

### awk
awk是一种文本分析工具，其基本格式为『awk \`条件1 {动作 1} 条件2 {动作 2} ...\` 文件名』，它读入有\n换行符分割的一条记录，荣获将记录按照指定的分隔符划分域，$0表示所有域，$1表示第一个域以此类推。默认域分隔符是space或tab

如下面这个例子，就是查看df -h输出的结果中，筛选出第1和3个区域的值。
```shell
df -h | awk '{print $1 "\t" $3}'
Filesystem	Used
/dev/disk1s5s1	24Gi
devfs	191Ki
/dev/disk1s4	3.0Gi
/dev/disk1s2	324Mi
/dev/disk1s6	107Mi
/dev/disk1s1	132Gi
map	0Bi
/dev/disk1s5	24Gi
```

-F指定域分隔符为":"
```shell
cat /etc/passwd | awk -F ':' '{print $1}'
nobody
root
daemon
```
#### 条件
先执行BEGIN，然后读取文件，以\n作为一条记录，然后对每条记录以域分隔符划分域得到一组域，执行action。所有记录都读取和执行完毕之后，再执行END。
```shell
df -h | awk 'BEGIN {print "start"} {print $1} END {print "end"}'
start
Filesystem
/dev/disk1s5s1
devfs
/dev/disk1s4
/dev/disk1s2
/dev/disk1s6
/dev/disk1s1
map
/dev/disk1s5
end
```

也可以在行为之前添加条件，这里筛选出/dev/
```shell
df -h | awk 'BEGIN {print "start"} /dev/{print $1} END {print "end"}'
start
/dev/disk1s5s1
devfs
/dev/disk1s4
/dev/disk1s2
/dev/disk1s6
/dev/disk1s1
/dev/disk1s5
end
```