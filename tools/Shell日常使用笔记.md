#### 2 &> 1
`2>&1`代表将`stderr`重定向到文件描述符为1的文件(即`/dev/stdout`)中。
以`ls >list.txt 2>&1`为例，从左往右执行，执行到`>list.txt`即标准输出重定向到`list.txt`文件，执行到`2>&1`即`stderr`重定向到`stdout`也就是`list.txt`文件中

#### ps的aux和ef区别
都是输出所有进程信息，只是输出格式不同。

#### 先筛选再将筛选结果作为参数批量操作
比如先筛选启动的`mongo`进程获取`pid`，再将所有相关的`pid`都`kill`。
`ps -ef | grep mongo | awk '{print $2}'| xargs kill`，这里筛选出进程，再用awk获取第二列字段，再用xargs作为kill参数结束进程。

