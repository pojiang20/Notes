### 分支命名
#### master分支
master 为主分支，也是用于部署生产环境的分支，确保master分支稳定性， master 分支一般由develop以及hotfix分支合并，任何时间都不能直接修改代码
#### develp分支
develop 为开发分支，始终保持最新完成以及bug修复后的代码，一般开发的新功能时，feature分支都是基于develop分支下创建的。
- feature 分支
开发新功能时，以develop为基础创建feature分支。
分支命名: feature/ 开头的为特性分支， 命名规则: feature/user_module、 feature/cart_module
- release 分支
release 为预上线分支，发布提测阶段，会release分支代码为基准提测。当有一组feature开发完成，首先会合并到develop分支，进入提测时会创建release分支。如果测试过程中若存在bug需要修复，则直接由开发者在release分支修复并提交。当测试完成之后，合并release分支到master和develop分支，此时master为最新代码，用作上线。
- hotfix 分支
分支命名: hotfix/ 开头的为修复分支，它的命名规则与feature分支类似。线上出现紧急问题时，需要及时修复，以master分支为基线，创建hotfix分支，修复完成后，需要合并到master分支和develop分支
[参考](https://mp.weixin.qq.com/s/Fs0BcwZiaJjUNLlPUW-pVg)
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