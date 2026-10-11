=== #text("Codeforces Round 2084")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/CF/2084.md`]

===== G2 区间博弈 DP

====== Problem Description

有一个在序列 $c$ 上的博弈，$A$ 先手：

- $A$ 选择 $i$：`c[i] = min(c[i], c[i + 1])` 并删除 $c \[ i + 1 \]$
- $B$ 选择 $i$：`c[i] = max(c[i], c[i + 1])` 并删除 $c \[ i + 1 \]$

$A$ 希望最大化最后剩下的 $c \[ 1 \]$，定义最终剩下的值为 $f \( c \)$。

给定长度为 $n$ 的排列 $p$（有空缺项），求所有可能中#strong[最大的] $p$ 的所有子数组的 $f \( \)$ 之和。

数据范围：$1 lt.eq n lt.eq 5 times 10^5$

====== Solution

#strong[博弈公式、乘法原理、奇偶二分类、黑白二分类、路径贡献法、Slope Trick、斜率优化 DP]

首先一定要推导博弈公式：

- 使用#strong[01二分答案];求解博弈答案
- 假设答案为 $m$，那么 $gt.eq m$ 的都设置为 $1$，其他都是 $0$
- 首先考虑奇偶性：
  - 奇数长度最后取 $max$：
    - $k = 1$：需要 $max \( c \[ 1 \] \, c \[ m \] \) gt.eq m$
    - $k = 3$：一旦两侧有 $1$，一定可以避免操作有 $1$ 的位置，然后到达 $k - 2$ 状态（true）
    - 否则全 $0$，那么 $B$ 一定可以避免操作两端，达到 $00$ 状态（false）
  - 偶数长度最后取 $min$，必然要求 $m lt.eq c \[ 1 \]$：
    - $k = 2$：需要 $min \( c \[ 1 \] \, c \[ 2 \] \) gt.eq m$
    - $k = 4$：全 $1$ 那么一定可以达到 $11$ 状态（true）
    - 否则一旦两侧有 $0$，那么 $B$ 一定会避免操作有 $0$ 的位置，剩下至少一个 $0$ 给 $A$ 操作（false）
- 所以博弈公式为 $f \( c \) = k & 1 ? max \( c \[ 1 \] \, c \[ k \] \) : min \( c \[ 1 \] \, c \[ k \] \)$

但是为了求解这个 DP 答案，需要公式转化：

$ upright("ans") & = sum_(i lt.eq j) \[ i equiv j med mod med 2 \] max \( p_i \, p_j \) + sum_(i lt.eq j) \[ i equiv.not j med mod med 2 \] min \( p_i \, p_j \)\
upright("补偿法") & = sum_(i lt.eq j) max \( p_i \, p_j \) + sum_(i lt.eq j) \[ i equiv.not j med mod med 2 \] \( min \( p_i \, p_j \) - max \( p_i \, p_j \) \)\
upright("枚举答案法") & = sum_(i = 1)^n i^2 - sum_(i < j) \[ i equiv.not j med mod med 2 \] \| p_i - p_j \|\
 & = frac(n \( n + 1 \) \( 2 n + 1 \), 6) - upright("数轴上两种阵营异色距离之和") $

而一个#strong[数轴];可以看作一个#strong[链状树];，答案要求的是#strong[数轴上] #strong[最小] #strong[两阵营] #strong[距离之和];；可以看作是一个树，因此可以考虑边的贡献：一个边被使用了多少次？当然是左右两侧对应的异色点之积。

由于#strong[二分类 DP] 的#strong[补集可预测性];，这大大化简了求解 DP 的难度：

- 设 $upright("dp") \[ i \] \[ j \]$ 表示数轴上前 $i$ 个数字染 $j$ 个黑点（即染 $i - j$ 个白点）#strong["至少需要的"];（因为仅计算前 $i$ 个边）的最小异色距离之和
- #strong[溯源法];：
  - $i$ 可染黑色：$upright("dp") \[ i \] \[ j \] arrow.l^(upright("chmin")) upright("dp") \[ i - 1 \] \[ j - 1 \] + j times \( floor.l n \/ 2 floor.r - \( i - j \) \) + \( i - j \) times \( ceil.l n \/ 2 ceil.r - j \)$
  - $i$ 可染白色：$upright("dp") \[ i \] \[ j \] arrow.l^(upright("chmin")) upright("dp") \[ i - 1 \] \[ j \] + j times \( floor.l n \/ 2 floor.r - \( i - j \) \) + \( i - j \) times \( ceil.l n \/ 2 ceil.r - j \)$
- #strong[贡献法];：
  - $i + 1$ 可染黑色：$upright("dp") \[ i + 1 \] \[ j + 1 \] arrow.l^(upright("chmin")) upright("dp") \[ i \] \[ j \] + \( j + 1 \) times \( floor.l n \/ 2 floor.r - \( \( i + 1 \) - \( j + 1 \) \) \) + \( \( i + 1 \) - \( j + 1 \) \) times \( ceil.l n \/ 2 ceil.r - \( j + 1 \) \)$
  - $i + 1$ 可染白色：$upright("dp") \[ i + 1 \] \[ j \] arrow.l^(upright("chmin")) upright("dp") \[ i \] \[ j \] + j times \( floor.l n \/ 2 floor.r - \( \( i + 1 \) - j \) \) + \( \( i + 1 \) - j \) times \( ceil.l n \/ 2 ceil.r - j \)$
- 显然#strong[溯源法];更简洁

答案为 $frac(n \( n + 1 \) \( 2 n + 1 \), 6) - upright("dp") \[ n \] \[ ceil.l n \/ 2 ceil.r \]$。

