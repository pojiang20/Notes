#### 2 &> 1
`2>&1`代表将`stderr`重定向到文件描述符为1的文件(即`/dev/stdout`)中。
以`ls >list.txt 2>&1`为例，从左往右执行，执行到`>list.txt`即标准输出重定向到`list.txt`文件，执行到`2>&1`即`stderr`重定向到`stdout`也就是`list.txt`文件中