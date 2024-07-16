## 2024.02.06
#### 584. 寻找用户推荐人
> MySQL 使用三值逻辑 —— TRUE, FALSE 和 UNKNOWN
因此对于『筛选除了x!=2但x列又存在null』这种情况，需要有 `x is NULL or x <> 2`，因为null!=2的结果是UNKnown而不是TRUE

#### 1378. 使用唯一标识码替换员工ID
- [x] 不记得join on

#### 1581. 进店却未进行过交易的顾客
- [x] 加强记忆