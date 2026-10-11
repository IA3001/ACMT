==== #text("【杂项】")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/Notes/【杂项】.md`]

===== Raney 引理

设 $x_1, x_2, dots, x_m$ 为整数且 $sum_(i=1)^m x_i = 1$。按起点编号的 $m$ 个循环位移中，恰好有一个位移的所有非空前缀和都为正数。即使数列有周期，循环位移也按起点分别计数。


===== K-th Max / Min 期望

====== 前置引理：尾和公式

对#strong[非负整数];随机变量 $X$，有（允许期望为 $+ oo$）： $ E \[ X \] = sum_(x = 1)^oo P \( X gt.eq x \) $ #strong[推导];： $ E \[ X \] & = sum_(x = 1)^oo x dot.op P \( X = x \)\
 & = sum_(x = 1)^oo sum_(k = 1)^x P \( X = x \)\
 & = sum_(k = 1)^oo sum_(x = k)^oo P \( X = x \)\
 & = sum_(k = 1)^oo P \( X gt.eq k \) $ 交换求和次序是关键。对非负连续型变量，换成积分：$E \[ X \] = integral_0^oo P \( X gt.eq x \) thin d x$。

这个引理把“求期望”转化为“求概率”，而概率往往更容易算。


====== 最大值期望

设 $X_1 \, dots.h \, X_n$ 是相互独立的非负整数值随机变量（可以不同分布）。 $ P \( max gt.eq x \) = 1 - P \( max < x \) = 1 - product_(i = 1)^n P \( X_i < x \) $ 所以 $ E \[ max \] = sum_(x = 1)^oo (1 - product_(i = 1)^n P \( X_i < x \)) $

#strong[直观];：最大值 $gt.eq x$ 的对立事件是“所有变量都 $< x$”，概率相乘即可。


====== 最小值期望

设 $X_1 \, dots.h \, X_n$ 相互独立且为非负整数值随机变量。 $ P \( min gt.eq x \) = P \( X_1 gt.eq x \, dots.h \, X_n gt.eq x \) = product_(i = 1)^n P \( X_i gt.eq x \) $ 所以 $ E \[ min \] = sum_(x = 1)^oo product_(i = 1)^n P \( X_i gt.eq x \) $

#strong[直观];：最小值 $gt.eq x$ 意味着所有变量都 $gt.eq x$。


====== 连续均匀分布 $U \[ 0 \, 1 \]$ 的第 $k$ 小期望

设 $X_1 \, dots.h \, X_n$ 独立同分布 $tilde.op U \[ 0 \, 1 \]$，排序后 $X_(\( 1 \)) lt.eq X_(\( 2 \)) lt.eq dots.h lt.eq X_(\( n \))$。 其中 $1 lt.eq k lt.eq n$。#strong[求 $E \[ X_(\( k \)) \]$];：

+ #strong[分布函数];： $ F_k \( x \) = P \( X_(\( k \)) lt.eq x \) = sum_(j = k)^n binom(n, j) x^j \( 1 - x \)^(n - j) $ 含义：至少 $k$ 个变量 $lt.eq x$。

+ #strong[密度函数];（对 $x$ 求导）： $ f_k \( x \) = frac(n !, \( k - 1 \) ! \( n - k \) !) x^(k - 1) \( 1 - x \)^(n - k) $ 这是参数为 $\( k \, n - k + 1 \)$ 的 Beta 分布密度。

+ #strong[期望];： $ E \[ X_(\( k \)) \] = integral_0^1 x f_k \( x \) d x = frac(k, n + 1) $

#strong[结论];：$E \[ X_(\( k \)) \] = frac(k, n + 1)$。 特别地，$E \[ min \] = E \[ X_(\( 1 \)) \] = frac(1, n + 1)$，$E \[ max \] = E \[ X_(\( n \)) \] = frac(n, n + 1)$。

#strong[应用];：随机 $n$ 个数中第 $k$ 小的期望值。


#quote(block: true)[
这是推导：
]

======= 第一步：代入密度函数

已知 $f_k \( x \) = frac(n !, \( k - 1 \) ! \( n - k \) !) x^(k - 1) \( 1 - x \)^(n - k)$。 代入期望公式：

$ E \[ X_(\( k \)) \] = integral_0^1 x dot.op frac(n !, \( k - 1 \) ! \( n - k \) !) x^(k - 1) \( 1 - x \)^(n - k) d x $

======= 第二步：合并 $x$ 的幂次

把常数项提出来，$x dot.op x^(k - 1) = x^k$：

$ E \[ X_(\( k \)) \] = frac(n !, \( k - 1 \) ! \( n - k \) !) integral_0^1 x^k \( 1 - x \)^(n - k) d x $

======= 第三步：套 Beta 函数公式

Beta 函数的定义（对于非负整数 $a \, b$）：

$ B \( a + 1 \, b + 1 \) = integral_0^1 x^a \( 1 - x \)^b d x = frac(a ! dot.op b !, \( a + b + 1 \) !) $

这里 $a = k$，$b = n - k$，所以：

$ integral_0^1 x^k \( 1 - x \)^(n - k) d x = frac(k ! dot.op \( n - k \) !, \( n + 1 \) !) $

======= 第四步：代入并化简

把积分结果代回：

$ E \[ X_(\( k \)) \] = frac(n !, \( k - 1 \) ! \( n - k \) !) dot.op frac(k ! dot.op \( n - k \) !, \( n + 1 \) !) $

约掉 $\( n - k \) !$，利用 $k ! = k dot.op \( k - 1 \) !$ 和 $\( n + 1 \) ! = \( n + 1 \) dot.op n !$：

$ E \[ X_(\( k \)) \] = frac(n !, \( k - 1 \) !) dot.op frac(k dot.op \( k - 1 \) !, \( n + 1 \) dot.op n !) = frac(k, n + 1) $

======= 结论

$ E \[ X_(\( k \)) \] = frac(k, n + 1) $


====== 赠券收集问题（Coupon Collector）

有 $n$ 种卡片，每次等概率抽到一种，求集齐所有 $n$ 种卡片所需次数的期望。

#strong[推导];： 设 $T_k$ = 从已有 $k$ 种到集齐 $k + 1$ 种所需的次数。 已有 $k$ 种时，抽到新卡片的概率 $p_k = frac(n - k, n)$。 $T_k$ 服从参数为 $p_k$ 的几何分布，所以 $E \[ T_k \] = 1 / p_k = frac(n, n - k)$。 总次数 $T = sum_(k = 0)^(n - 1) T_k$，由期望线性性： $ E \[ T \] = sum_(k = 0)^(n - 1) frac(n, n - k) = n sum_(j = 1)^n 1 / j = n H_n $ 其中 $H_n$ 是第 $n$ 个调和数。当 $n$ 很大时， $ E \[ T \] = n ln n + gamma n + 1 / 2 + O #h(-1em) (1 / n) \, $ 其中 $gamma$ 是欧拉常数。

若题目要求模意义下的期望，需要把推导得到的有理数写成模逆；只有分母在模数下可逆时才能这样做。若模数是素数 $p$，分母不能被 $p$ 整除时才可取逆。


====== 离散均匀分布的最大值/最小值期望

设 $X_i tilde.op U { 1 \, 2 \, dots.h \, m }$ 独立同分布。

- #strong[最大值];： $ P \( max < x \) = (frac(x - 1, m))^n $ 所以 $ E \[ max \] = sum_(x = 1)^m [1 - (frac(x - 1, m))^n] $

- #strong[最小值];： $ P \( min gt.eq x \) = (frac(m - x + 1, m))^n $ 所以 $ E \[ min \] = sum_(x = 1)^m (frac(m - x + 1, m))^n $

#strong[应用];：掷骰子取最大值的期望。


====== 离散均匀分布的第 $k$ 大期望

设 $X_i tilde.op U { 1 \, dots.h \, m }$ 独立同分布，求第 $k$ 大的期望。

记从大到小排序后的值为 $X_(\[ 1 \]) gt.eq X_(\[ 2 \]) gt.eq dots.h gt.eq X_(\[ n \])$，其中 $1 lt.eq k lt.eq n$，以免与前文从小到大的 $X_(\( k \))$ 混淆。

#strong[方法];：利用尾和公式 $ E \[ X_(\[ k \]) \] = sum_(x = 1)^m P \( upright("至少 ") k upright(" 个变量") gt.eq x \) $ 而 $ P \( upright("至少 ") k upright(" 个") gt.eq x \) = sum_(j = k)^n binom(n, j) (frac(m - x + 1, m))^j (frac(x - 1, m))^(n - j) $ 代入求和即可。

#strong[复杂度];：直接枚举阈值 $x$ 并计算二项分布尾和为 $O \( m n \)$。若使用更快递推，需要单独给出并证明递推式，不能仅凭“尾概率递推”记为 $O \( m \)$。


====== 独立不同分布的第 $k$ 大期望（DP法）

设 $X_i$ 是取值范围为整数 $\[ 0 \, V \]$ 的相互独立随机变量，但分布可以不同。记从大到小排序后的第 $k$ 个值为 $X_(\[ k \])$，其中 $1 lt.eq k lt.eq n$。此时不能直接用二项分布；对每个阈值 $x$ 跑一次 DP。假设能在 $O \( 1 \)$ 时间内取得每个 $P \( X_i gt.eq x \)$；若需现算这些概率，还要把预处理成本另计。 设 $d p \[ j \]$ = 恰好 $j$ 个变量 $gt.eq x$ 的概率。 初始 $d p \[ 0 \] = 1$。 对每个变量 $i$，令 $p_i = P \( X_i gt.eq x \)$，更新： $ d p \[ j \] = d p \[ j \] dot.op \( 1 - p_i \) + d p \[ j - 1 \] dot.op p_i $ 每个阈值 $x$ 都要重新初始化 $d p \[ 0 \] = 1$。处理变量 $i$ 时，按 $j = n \, n - 1 \, dots.h \, 1$ 倒序更新上式，并令 $d p \[ 0 \] arrow.l d p \[ 0 \] \( 1 - p_i \)$；倒序可避免本轮刚更新的 $d p \[ j - 1 \]$ 被重复使用。

则 $P \( upright("至少 ") k upright(" 个") gt.eq x \) = sum_(j gt.eq k) d p \[ j \]$。 最后对 $x = 1 \, 2 \, dots.h \, V$ 求和得到 $E \[ X_(\[ k \]) \]$。从 $x = 1$ 开始是因为变量取非负整数值，尾和公式不需要加 $x = 0$ 项。

#strong[复杂度];：$O \( n^2 dot.op V \)$，$V$ 为值域。若 $n$ 较小可以接受。


====== 总结与识别标志

- 看到“期望” + “最大/最小/第k大/第k小”，优先想尾和公式。
- 独立同分布：用二项分布或次序统计量密度。
- 独立不同分布：对每个阈值 DP。
- 均匀分布：连续用 $k \/ \( n + 1 \)$，离散用求和公式。
- 赠券收集：$n H_n$。

