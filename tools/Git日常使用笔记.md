### push远程分支
在本地创建分支`git checkout -b` 本地分支名称
将本地分支推送到远端`git push origin 本地分支:远端希望创建的分支`

### clone指定分支
`git clone 地址` 用于clone项目
`git clone -b 分支名称 地址` 可以clone指定分支

### git worktree在本地同时开启两个分支
开发过程中，需要一边测试即将上线的分支和在自己分支中开发新功能。
#### 切换
我以往的做法是：
1. 使用`git stash`暂存代码
2. 使用`git checkout`切换分支测试代码，
3. 再切换回来
4. 使用`git stash pop`来恢复代码。
#### workTree
由于主分支测试过程需要等待，因此我想**同时开启**两个分支，这时候就可以用`workTree`
[这篇](https://louis383.medium.com/git-worktree-%E7%B0%A1%E5%96%AE%E4%BB%8B%E7%B4%B9%E8%88%87%E4%BD%BF%E7%94%A8-876897c797bf)介绍非常好。
即使用`git worktree add 文件路径 分支A`，会在文件路径下创建该分支的代码，这时候使用`ide`打开，即可同时处理两个分支。如果需要开启新分支，即可使用`git worktree -b 新分支名 文件路径 分支`。`git worktree list`可以查看建立的`worktree`列表。
注意在使用`worktree`之后，无法从工作目录`git checkout 分支A`切换到该分支。会报错`fatal: '分支A' is already checked out`，使用`git worktree prune`则可以断开与新目录中`分支A`的连接，这样就可以切换到该分支中了。

### 本地删除文件与仓库同步
如果在工作区将已经`push`到仓库的文件删除，则用`git status`可以看到文件删除提示
```shell
$ git status
On branch master
Changes not staged for commit:
  (use "git add/rm <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	deleted:    test.txt
```
如果同样想要删除远程仓库，则`git rm`删除指定文件即可，然后再`git commit`提交。
```shell
$ git rm test.txt
rm 'test.txt'

$ git commit -m "remove test.txt"
[master d46f35e] remove test.txt
 1 file changed, 1 deletion(-)
 delete mode 100644 test.txt
```
如果想在工作区恢复已经删除的文件，则使用`git checkout -- test.txt`
- `git checkout [<options>] [<branch>] -- <file>`可以签出后的文件将会覆盖【工作目录】中的相同文件；若【工作目录】中的文件已删除，会创建签出的文件。
- 从指定提交历史中签出`git checkout 830cf95f56ef9a7d6838f6894796dac8385643b7 -- a.txt`
- 从指定分支中签出`git checkout master -- a.txt`

### 从远程拉取并创建新分支
git checkout -b 新的本地分支名称 远端仓库/远端分支名

### rebase和merge
`git merge`是把两个分支的新修改的内容以及最近的共同祖先进行三方合并，结果是生成一个新的快照。`git commit`的路径是二合一
`git rebase`是对于两个分支C4、C3，找到共同最近的祖先C2，把C4自己的修改应用到C3上，得到新的快照。`git commit`的路径是一条，因此rebase更加简洁。
[参考](https://git-scm.com/book/zh/v2/Git-%E5%88%86%E6%94%AF-%E5%8F%98%E5%9F%BA)