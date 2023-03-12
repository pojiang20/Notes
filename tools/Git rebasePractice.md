`git log`可以看到当前有两个提交
```text
commit 80b5e067aa7e16ca19fe2470821a341fec73f094 (HEAD -> testRebase)
Author: pojiang20 <1021465760@qq.com>
Date:   Wed Feb 15 11:52:08 2023 +0800

    docs: add b

commit 0a7e8d89804abedb81bbf81231fec8eaa0265d16
Author: pojiang20 <1021465760@qq.com>
Date:   Wed Feb 15 11:51:47 2023 +0800

    docs: add a
```
使用`git rebase -i HEAD~2`
```text
1 pick 0a7e8d8 docs: add a
2 pick 80b5e06 docs: add b
```
进行编辑
```text
1 pick 0a7e8d8 docs: add a
2 s 80b5e06 docs: add b
```
编辑合并后的git message
```text
1 # This is a combination of 2 commits.
2 # This is the 1st commit message:
3
4 docs: add a
5
6 # This is the commit message #2:
7
8 docs: add b
9
10 # Please enter the commit message for your changes. Lines starting
11 # with '#' will be ignored, and an empty message aborts the commit.
12 #
13 # Date:      Wed Feb 15 11:51:47 2023 +0800
14 #
15 # interactive rebase in progress; onto 1a6f6f5
16 # Last commands done (2 commands done):
17 #    pick 0a7e8d8 docs: add a
18 #    squash 80b5e06 docs: add b
19 # No commands remaining.
20 # You are currently rebasing branch 'testRebase' on '1a6f6f5'.
```
查看合并后的结果
```text
☁  git [testRebase] ⚡  git rebase -i HEAD~2
[detached HEAD 73a50d2] docs: add a
Date: Wed Feb 15 11:51:47 2023 +0800
2 files changed, 2 insertions(+)
create mode 100644 git/a
create mode 100644 git/b
Successfully rebased and updated refs/heads/testRebase.
commit 73a50d2915e42f57d62e5ac9e5d6ce50edb539c8 (HEAD -> testRebase)
Author: pojiang20 <1021465760@qq.com>
Date:   Wed Feb 15 11:51:47 2023 +0800

    docs: add a

    docs: add b
```