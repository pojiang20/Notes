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


#### 如何修改git commit
1. git rebase -i HEAD~n来表示向后查看多少个提交记录以找到要修改的提交
2. 将指令修改了edit
3. git commit --amend，修改对应commit
4. git rebase --continue提交
5. 同步到远程：git push --force

#### 处理分支时，使用git rebase和git merge的区别
下面合并分支的过程，使用了git rebase
```
 1761  git pull
 1762  git pull origin master
 1763  git checkout feat/xx
 1764  git rebase master
 ...
 1772  git rebase --continue
```
这个git rebaes的作用，是将feat/xx分支的更改，应用到master分支的最新提交之上。
git rebase master 命令的作用是将 feat/management 分支的提交重新应用到 master 分支的最新提交之上。这可以被视为一种将分支上的更改"迁移"到另一条更为最新的基础线上的操作。具体步骤如下：

首先，Git 会将 feat/management 分支上的所有提交（即 master 分支从你创建 feat/management 分支后所新增的提交）保存到临时区域。
然后，Git 会将 feat/management 分支的基线移动到 master 分支的最新提交。
最后，Git 会将临时区域中的提交依次应用到新的基线上。
这样做的结果是，你的 feat/management 分支会包含所有 master 分支上的最新更改，而你的开发历史会显得更加线性和整洁。

以下是两种行为的时间线对比：
对于git rebase master
```
时间线:
1. 在 `feat/management` 上进行开发
A - B - C (master)
          \
           D - E (feat/management)

2. `master` 上有新的提交
A - B - C - F - G (master)
          \
           D - E (feat/management)

3. `feat/management` 执行 `git rebase master`
A - B - C - F - G (master)
                    \
                     D' - E' (feat/management)
```

对于git merge master
```
时间线:
1. 在 `feat/management` 上进行开发
A - B - C (master)
          \
           D - E (feat/management)

2. `master` 上有新的提交
A - B - C - F - G (master)
          \
           D - E (feat/management)

3. `feat/management` 执行 `git merge master`
A - B - C - F - G (master)
          \         \
           D - E ----H (feat/management)

```

总结：选择 rebase 还是 merge 取决于你的团队工作流程和对提交历史整洁度的需求。rebase 更适合于保持线性历史和简洁的提交记录，而 merge 更适合于保留完整的开发过程历史。






