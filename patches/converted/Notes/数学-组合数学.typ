==== #text("数学-组合数学")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/Notes/数学-组合数学.md`]

===== 组合数学-结论

====== 基础恒等式

- $binom(n, k) = binom(n, n - k)$
- $binom(n, k) = binom(n - 1, k) + binom(n - 1, k - 1)$（帕斯卡）
- $k binom(n, k) = n binom(n - 1, k - 1)$（吸收恒等式）
- $binom(n, k) binom(k, m) = binom(n, m) binom(n - m, k - m)$
- $sum_(i = 0)^k binom(n, i) binom(m, k - i) = binom(n + m, k)$（范德蒙德）
  - 两个组合数相乘
  - 上标是常数 $n \, m$
  - 下标相加为常数 $i + \( k - i \) = k$
  - 求和变量 $i$ 跑遍所有整数（约定越界项为 0）
- $sum_(i = 0)^n binom(i, k) = binom(n + 1, k + 1)$（曲棍球棒）
- $sum_(i = 0)^n binom(n, i) = 2^n$
- $sum_(i = 0)^n \( - 1 \)^i binom(n, i) = 0$


====== 特殊数

======= 卡特兰数

- $C_n = frac(1, n + 1) binom(2 n, n)$
- 递推：$C_0 = 1 \, C_(n + 1) = sum_(i = 0)^n C_i C_(n - i)$
- 生成函数：$frac(1 - sqrt(1 - 4 x), 2 x)$
- 应用：括号序列、出栈顺序、二叉树计数。

======= 贝尔数（集合划分数）

- $B_n = sum_(k = 0)^n S \( n \, k \)$
- 递推：$B_(n + 1) = sum_(i = 0)^n binom(n, i) B_i$
- EGF：$e^(e^x - 1)$

======= 斯特林数

======== 第二类斯特林数 $S \( n \, k \)$：$n$ 个不同元素分成 $k$ 个非空集合的方案数

- 递推：$S \( n \, k \) = S \( n - 1 \, k - 1 \) + k S \( n - 1 \, k \)$
- 通项：$S \( n \, k \) = frac(1, k !) sum_(i = 0)^k \( - 1 \)^i binom(k, i) \( k - i \)^n$
- 与幂的关系：$x^n = sum_(k = 0)^n S \( n \, k \) x^(underline(k))$

======== 第一类斯特林数 $lr([frac(n, k)])$：$n$ 个不同元素排列成 $k$ 个环的方案数

- 递推：$lr([frac(n, k)]) = lr([frac(n - 1, k - 1)]) + (n - 1) lr([frac(n - 1, k)])$

======= 错排数

- $D_0 = 1 \, D_1 = 0$；对 $n gt.eq 2$，$D_n = \( n - 1 \) \( D_(n - 1) + D_(n - 2) \)$
- 通项：$D_n = n ! sum_(i = 0)^n frac(\( - 1 \)^i, i !)$

======= 斐波那契数

- $F_0 = 0 \, F_1 = 1$；对 $n gt.eq 2$，$F_n = F_(n - 1) + F_(n - 2)$
- 通项：$F_n = 1 / sqrt(5) [(frac(1 + sqrt(5), 2))^n - (frac(1 - sqrt(5), 2))^n]$
- 生成函数：$frac(x, 1 - x - x^2)$


====== 容斥原理

- $\| A_1 ∪ dots.h ∪ A_n \| = sum \| A_i \| - sum \| A_i ∩ A_j \| + dots.h + \( - 1 \)^(n - 1) \| A_1 ∩ dots.h ∩ A_n \|$
  - 等价写法：$\| union.big_(i = 1)^n A_i \| = sum_(nothing eq.not S subset.eq \[ n \]) \( - 1 \)^(\| S \| + 1) \| inter.big_(i in S) A_i \|$。
- 补集形式：$\| overline(A_1) ∩ dots.h ∩ overline(A_n) \| = sum_(S subset.eq \[ n \]) \( - 1 \)^(\| S \|) \| inter.big_(i in S) A_i \|$
- 经典应用：错排、欧拉函数、有禁位的排列。

======= 模型一：BZOJ 1042 \[HAOI2008\] 硬币购物

- #strong[问题];：4 种硬币，面值 $c_1 \, c_2 \, c_3 \, c_4$。每次询问给出每种硬币的数量上限 $d_i$ 和目标金额 $s$，求凑出 $s$ 的方案数。
- #strong[套路];：
  + 先跑#strong[完全背包];（无数量限制），预处理 $f \[ s \]$ = 用无限个硬币凑出 $s$ 的方案数。
  + 对每次询问，容斥：设 $A_i$ = 第 $i$ 种硬币超过上限的事件。
  + $upright("ans") = sum_(S subset.eq { 1 \, 2 \, 3 \, 4 }) \( - 1 \)^(\| S \|) f \[ s - sum_(i in S) c_i \( d_i + 1 \) \]$
  + 若下标 $< 0$ 则该项为 0。
- #strong[复杂度];：预处理 $O \( 4 times max s \)$，单次询问 $O \( 2^4 \)$。
- #strong[本质];：先用完全背包处理”无限制”，再用容斥减去”超过限制”的非法解。

======= 模型二：CF 451E Devu and Flowers

- #strong[问题];：$n$ 种花，第 $i$ 种有 $f_i$ 朵。求取恰好 $s$ 朵的方案数。
- #strong[套路];：
  + 无限制时，方案数为 $binom(s + n - 1, n - 1)$（隔板法）。
  + 容斥：$A_i$ = 第 $i$ 种花取了超过 $f_i$ 朵。
  + $upright("ans") = sum_(S subset.eq \[ n \]) \( - 1 \)^(\| S \|) binom(s - sum_(i in S) \( f_i + 1 \) + n - 1, n - 1)$
  + 若 $N = s - sum_(i in S) \( f_i + 1 \) + n - 1 < n - 1$，该项为 0；否则本题 $n lt.eq 20$，组合数下标 $n - 1$ 很小，用短乘积计算 $binom(N, n - 1) med mod med 10^9 + 7$。分母 $\( n - 1 \) !$ 可逆，分子若含模数因子则结果为 0。
- #strong[复杂度];：预处理子集偏移 $O \( 2^n \)$，逐项计算组合数总计 $O \( n 2^n \)$。
- #strong[本质];：把”有限制”转化为”无限制 + 容斥”。

======= 通用公式（多重集有限制的组合计数）

- #strong[问题];：$x_1 + x_2 + dots.h + x_n = s$，其中 $0 lt.eq x_i lt.eq c_i$。
- #strong[无限制];：$binom(s + n - 1, n - 1)$。
- #strong[容斥];： $ upright("ans") = sum_(S subset.eq \[ n \]) \( - 1 \)^(\| S \|) binom(s - sum_(i in S) \( c_i + 1 \) + n - 1, n - 1) $

======= 识别标志

- 题目出现”每种物品有数量限制”、"求恰好凑出 $s$ 的方案数"。
- 数量限制种类少（$lt.eq 20$），但 $s$ 很大 → 容斥。
- 数量限制种类多，但 $s$ 不大 → 生成函数 / DP。


====== 鸽巢原理

- $n + 1$ 个物体放入 $n$ 个盒子，至少一个盒子有 $gt.eq 2$ 个物体。
- 推广：$n$ 个物体放入 $k$ 个盒子，至少一个盒子有 $ceil.l n \/ k ceil.r$ 个物体。


====== 组合数取模

======= 小模数，小 $n$

- 若模数 $p$ 为质数且 $n < p$，可预处理阶乘和逆阶乘，$O \( 1 \)$ 查询。
- 若 $n gt.eq p$，阶乘在模 $p$ 下不可逆，不能直接使用这套公式。

======= 大 $n$，质数模 $p$（Lucas 定理）

- $binom(n, m) equiv binom(n med mod med p, m med mod med p) binom(floor.l n \/ p floor.r, floor.l m \/ p floor.r) med \( mod med p \)$。
- 递归深度为 $O \( log_p n \)$；总复杂度还取决于每个数位组合数的求法。若预处理到 $p - 1$，可 $O \( 1 \)$ 求数位组合数，但预处理需 $O \( p \)$。
- #strong[经典];：P3807【模板】卢卡斯定理（质数模）。

======= 大 $n$，合数模 $M$（扩展卢卡斯）

- 将 $M$ 分解为互质的质数幂 $p_i^(e_i)$；分别计算 $binom(n, m) med mod med p_i^(e_i)$，再用中国剩余定理合并。
- 质数幂下需通过 $p_i$ 进赋值处理阶乘中的因子，并计算去掉 $p_i$ 因子的部分；不能直接套质数模的阶乘逆元公式。
- #strong[经典];：P4720【模板】扩展卢卡斯。

======= 任意模数

- 先看模数分解、$n \, m$ 的范围和时间限制。合数模数通常分解为质数幂、分别求余后 CRT 合并；不可逆分母不能用快速幂求逆。


====== 组合计数技巧

======= 隔板法

- $n$ 个相同物品放入 $k$ 个不同盒子，允许空：$binom(n + k - 1, k - 1)$。
- 不允许空：$binom(n - 1, k - 1)$。

======= 捆绑法 / 插空法

- 捆绑：相邻元素视为一个整体。
- 插空：不相邻元素插入空隙。

======= 映射法

- 将问题转化为已知模型（如卡特兰数、斯特林数）。

======= 生成函数法

- 构造 OGF/EGF，求系数。
- 常用：$frac(1, 1 - x)$、$e^x$、$\( 1 + x \)^n$。

====== 组合博弈（SG 定理）

- $S G \( u \) = m e x \( { S G \( v \) divides u arrow.r v } \)$
- 多个子游戏：$S G = S G_1 xor S G_2 xor dots.h$
- $S G eq.not 0$ 先手必胜。


====== 经典组合模型

- #strong[错排];：$D_n$。
- #strong[卡特兰数];：括号序列、出栈顺序。
- #strong[贝尔数];：集合划分。
- #strong[斯特林数];：集合划分 / 环排列。
- #strong[整数划分];：$p \( n \)$，五边形数定理。
- #strong[斐波那契];：爬楼梯、矩形覆盖。


#quote(block: true)[
一波\~
]

====== 二项式反演

#quote(block: true)[
噩梦副本
]

- #strong[标准形式];：
  - 若 $f \( n \) = sum_(i = 0)^n binom(n, i) g \( i \)$，则 $g \( n \) = sum_(i = 0)^n \( - 1 \)^(n - i) binom(n, i) f \( i \)$。
  - 等价形式：$f \( n \) = sum_(i = n)^m binom(i, n) g \( i \) arrow.l.r.double g \( n \) = sum_(i = n)^m \( - 1 \)^(i - n) binom(i, n) f \( i \)$。
- #strong[本质];：容斥原理的组合数推广，处理“恰好”与“至少/至多”的转化。
- #strong[识别标志];：题目要求“恰好 $k$ 个”的方案数，但容易算“至少 $k$ 个”的方案数。


====== min-max 容斥

#quote(block: true)[
K-th 期望啊啊啊啊啊啊啊啊
]

- #strong[公式];： $ max \( S \) = sum_(T subset.eq S \, T eq.not nothing) \( - 1 \)^(\| T \| - 1) min \( T \) $
- #strong[期望形式];（最重要）： $ E \[ max \( S \) \] = sum_(T subset.eq S \, T eq.not nothing) \( - 1 \)^(\| T \| - 1) E \[ min \( T \) \] $
- #strong[用途];：求“所有元素都出现”的期望时间，转化为“至少一个元素出现”的期望时间。
- 可用于把最大值期望转成若干子集最小值期望；具体能否高效计算，取决于子集规模和问题结构。


====== 球盒模型（8 种情况）

- #strong[球有标号（不同）];，盒有标号（不同）：
  - 允许空：$k^n$
  - 不允许空：$k ! dot.op S \( n \, k \)$
- #strong[球无标号（相同）];，盒有标号（不同）：
  - 允许空：$binom(n + k - 1, k - 1)$
  - 不允许空：$binom(n - 1, k - 1)$
- #strong[球有标号（不同）];，盒无标号（相同）：
  - 允许空：$sum_(i = 0)^k S \( n \, i \)$
  - 不允许空：$S \( n \, k \)$
- #strong[球无标号（相同）];，盒无标号（相同）：
  - 允许空：$p_k \( n \)$，表示把 $n$ 划分为至多 $k$ 个正整数之和（空盒不计入划分）。
  - 不允许空：$p \( n \, k \)$，表示把 $n$ 划分为恰好 $k$ 个正整数之和。


====== 整数划分

- #strong[分拆数] $p \( n \)$：将 $n$ 拆成若干个正整数之和的方案数。
- #strong[生成函数];：$sum_(n = 0)^oo p \( n \) x^n = product_(i = 1)^oo frac(1, 1 - x^i)$。
- #strong[五边形数定理];：$product_(i = 1)^oo \( 1 - x^i \) = sum_(k = - oo)^oo \( - 1 \)^k x^(k \( 3 k - 1 \) \/ 2)$。
- #strong[递推];：$p \( n \) = sum_(k eq.not 0) \( - 1 \)^(k - 1) p \( n - k \( 3 k - 1 \) \/ 2 \)$。
- #strong[扩展题];：#link("https://www.luogu.com.cn/problem/P4451")[P4451 整数的 lqp 拆分];：统计有序拆分并以斐波那契数乘积作为权值；它不是普通的无序整数划分计数。


====== Burnside 引理与 Polya 定理

- #strong[Burnside 引理];：群 $G$ 作用在集合 $X$ 上，轨道数 = $frac(1, \| G \|) sum_(g in G) \| F i x \( g \) \|$。
  - $F i x \( g \)$ = 在置换 $g$ 下保持不变的方案数。
- #strong[Pólya 定理];：用 $m$ 种颜色给 $n$ 个珠子染色，先明确允许的对称操作群；只考虑旋转与同时考虑旋转、翻转是不同模型。
  - 旋转 $k$ 格的不动点数 = $m^(gcd \( n \, k \))$。
  - 反射的不动点数为 $m^c$，其中 $c$ 是该反射置换的循环数；奇数个珠子时每条反射轴有 1 个固定点，偶数个珠子时分为穿过对顶点和对边的两类。
  - #link("https://www.luogu.com.cn/problem/P4980")[P4980] 只把旋转视为等价，不包含翻转。
- #strong[经典];：P4980 【模板】Polya 定理。


====== Lucas 定理的推论（奇偶性）

- $C \( n \, k \)$ 为奇数 $arrow.l.r.double$ $k$ 是 $n$ 的二进制子集（即 $k & n = k$）。
- 等价于：$n$ 的二进制表示中，$k$ 对应的位不能为 1 而 $n$ 为 0。
- #strong[应用];：杨辉三角中第 $n$ 行的奇数个数 = $2^(upright("popcount") \( n \))$。


====== 拉格朗日插值

- #strong[问题];：给定 $n + 1$ 个横坐标两两不同的点 $\( x_i \, y_i \)$，求次数不超过 $n$ 的插值多项式 $f \( x \)$ 在 $k$ 处的值。模质数时还要求横坐标模 $p$ 后两两不同。
- #strong[公式];： $ f \( k \) = sum_(i = 0)^n y_i product_(j eq.not i) frac(k - x_j, x_i - x_j) $
- #strong[特殊情形];（$x_i = i$）： $ f \( k \) = sum_(i = 0)^n y_i frac(\( - 1 \)^(n - i), i ! \( n - i \) !) product_(j = 0)^(i - 1) \( k - j \) product_(j = i + 1)^n \( k - j \) $
- #strong[复杂度];：一般横坐标下，直接计算分母乘积需 $O \( n^2 \)$；等间距节点 $x_i = i$ 时，可用阶乘逆元与前后缀积在 $O \( n \)$ 时间内求单点值。
- #strong[经典];：CF 622F、P4781。


====== 牛顿二项式定理（广义二项式）

- 作为形式幂级数（或在收敛条件满足时），$\( 1 + x \)^alpha = sum_(k = 0)^oo binom(alpha, k) x^k$，其中 $binom(alpha, k) = frac(alpha \( alpha - 1 \) dots.h.c \( alpha - k + 1 \), k !)$。
- #strong[应用];：
  - $frac(1, \( 1 - x \)^(n + 1)) = sum_(k = 0)^oo binom(n + k, k) x^k$。
  - $sqrt(1 + x) = sum_(k = 0)^oo binom(1 \/ 2, k) x^k$。
- #strong[经典];：生成函数求系数。


====== 组合数的前缀和

#quote(block: true)[
哦！
]

- $sum_(i = 0)^k binom(n, i)$：没有简单闭式，但可以用递推 $O \( n \)$ 计算。
- $sum_(i = 0)^n binom(i, k) = binom(n + 1, k + 1)$（曲棍球棒）。（有了）
- $sum_(i = 0)^n binom(n, i)^2 = binom(2 n, n)$（范德蒙德特例）。（可以）
- $sum_(i = 0)^n i binom(n, i) = n 2^(n - 1)$。（有了）


====== 多项式系数

- #strong[定义];：$binom(n, k_1 \, k_2 \, dots.h \, k_m) = frac(n !, k_1 ! k_2 ! dots.h.c k_m !)$，其中 $sum k_i = n$。
- #strong[含义];：$n$ 个不同物品分成 $m$ 组，第 $i$ 组有 $k_i$ 个的方案数。
- #strong[生成函数];：$\( x_1 + x_2 + dots.h + x_m \)^n = sum binom(n, k_1 \, dots.h \, k_m) x_1^(k_1) dots.h.c x_m^(k_m)$。
- #strong[经典];：多重集排列。


====== 组合数的对数计算方法

#quote(block: true)[
卧槽？神秘！牛逼！大的缩小

哦，原来这么简单啊 服了
]

- 比较 $binom(n, k)$ 的大小时，取对数： $ ln binom(n, k) = sum_(i = 1)^k ln \( n - k + i \) - sum_(i = 1)^k ln i $
- #strong[用途];：$n$ 极大（如 $10^9$）时，避免高精度计算。


====== 线性递推与 BM 算法

- #strong[问题];：数列项属于某个域，且已知其线性递推阶数不超过 $k$；用足够多的连续项（常用 $2 k$ 项）恢复最短递推，再求第 $n$ 项。
- #strong[BM 算法];：$O \( k^2 \)$ 求出最短线性递推式。
- #strong[线性递推求第 $n$ 项];：用多项式取模 + 快速幂，$O \( k^2 log n \)$ 或 $O \( k log k log n \)$（NTT 优化）。

