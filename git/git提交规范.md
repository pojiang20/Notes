### Commit message的格式
基本结构如下
```text
<type>(<scope): <subject>
// 空一行
<body>
// 空一行
<footer>
```
#### header
type用于说明commit的类别（必须）：
- feat: 新功能
- fix：修补bug
- docs：文档
- style：格式（不影响代码运行的变动）
- refactor：重构（即不是新增功能，也是不修改bug的代码变动）
- test：增加测试
- chore：构建过程或辅助工具的变动
scope说明commit的影响范围（可选）
subject是commit目的的简短描述（必须）：
- 动词开头，使用第一人称现在时。『change the xx』
- 第一个字母小写
- 结尾不加句号『.』

#### Body
commit的详细描述

#### Footer
不兼容变动
关闭Issue


[参考](http://jartto.wang/2018/07/08/git-commit/)