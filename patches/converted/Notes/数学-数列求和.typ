==== #text("数学-数列求和")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/Notes/数学-数列求和.md`]

#quote(block: true)[
在算法竞赛的生成函数（OGF/EGF）和组合数学中，#strong[有限和] 经常出现

而且通常会伴随#strong[二项式系数];或#strong[多项式系数];。
]


===== 数列求和

- 纯等比
  - 高中知识
- 幂 乘 等比（比较纯粹 但是难求）
  - 衍生： $sum i^k$
- 组合数 乘 等比（不太纯粹 但是好求 ）
  - 上指标同步
    - $sum binom(i, k) x^i$
  - 下指标同步
    - $sum binom(k, i) x^i$


====== 1. 纯等比

#figure(
  align(center)[#table(
    columns: (25%, 25%, 25%, 25%),
    align: (left,left,left,left,),
    table.header([形式幂级数 (和式)], [封闭形式 (原函数)], [推导核心操作], [竞赛实用备注],),
    table.hline(),
    [$sum_(i = 0)^n x^i$], [$frac(1 - x^(n + 1), 1 - x)$（$x eq.not 1$）；$n + 1$（$x = 1$）], [#strong[错位相减法];], [表示“取 $0 tilde.op n$ 个”的有限约束。],
    [$sum_(i = m)^n x^i$], [$frac(x^m - x^(n + 1), 1 - x)$（$x eq.not 1$）；$n - m + 1$（$x = 1$）], [#strong[提取公因式] $x^m$], [表示取下标区间 $\[ m \, n \]$ 的约束。],
  )]
  , kind: table
  )


====== 2. "幂" 乘 等比

#figure(
  align(center)[#table(
    columns: (25%, 25%, 25%, 25%),
    align: (left,left,left,left,),
    table.header([形式幂级数 (和式)], [封闭形式 (原函数)], [推导核心操作], [竞赛实用备注],),
    table.hline(),
    [$sum_(i = 1)^n i x^i$], [$frac(x - \( n + 1 \) x^(n + 1) + n x^(n + 2), \( 1 - x \)^2)$（$x eq.not 1$）；$frac(n \( n + 1 \), 2)$（$x = 1$）], [#strong[求导];：对基础式两边求导后乘 $x$], [求加权和的期望或组合计数。],
    [$sum_(i = 1)^n i^2 x^i$], [$frac(x \( 1 + x \) - x^(n + 1) \[ \( n + 1 \)^2 - \( 2 n^2 + 2 n - 1 \) x + n^2 x^2 \], \( 1 - x \)^3)$（$x eq.not 1$）；$frac(n \( n + 1 \) \( 2 n + 1 \), 6)$（$x = 1$）], [#strong[求导];：对 $sum i x^i$ 的结果再求导后乘 $x$], [二阶矩/方差计算。],
  )]
  , kind: table
  )

#quote(block: true)[
$sum i^2 x^i$ 推导方法：#strong[无穷和与降维打击]

#strong[\1. 先求无穷和（按数值级数解释时要求 $\| x \| < 1$）]

已知无穷和基础 $sum_(i = 0)^oo x^i = frac(1, 1 - x)$

求导乘 $x$：$sum_(i = 1)^oo i x^i = frac(x, \( 1 - x \)^2)$

再求导乘 $x$：$sum_(i = 1)^oo i^2 x^i = x dot.op frac(d, d x) (frac(x, \( 1 - x \)^2)) = x dot.op frac(\( 1 - x \)^2 + 2 x \( 1 - x \), \( 1 - x \)^4) = frac(x \( 1 + x \), \( 1 - x \)^3)$

#strong[这就是最清爽的封闭形式（分子只有两项！）]

#strong[\2. 减去尾巴（有限和）]

当 $\| x \| < 1$ 时，有限和可写为 $sum_(i = 1)^n i^2 x^i = sum_(i = 1)^oo i^2 x^i - sum_(i = n + 1)^oo i^2 x^i$。若 $\| x \| gt.eq 1$，不能用收敛数值级数作此解释；应直接对有限几何和求导，或代入有限和公式（$x = 1$ 单独计算）。

对于尾项，做换元令 $j = i - \( n + 1 \)$，则 $i = n + 1 + j$：

尾项 $= sum_(j = 0)^oo \( n + 1 + j \)^2 x^(n + 1 + j) = x^(n + 1) sum_(j = 0)^oo \( n + 1 + j \)^2 x^j$

然后利用 $\( n + 1 + j \)^2 = \( n + 1 \)^2 + 2 \( n + 1 \) j + j^2$ 展开，代回前面求出的无穷和公式 $sum x^j \, sum j x^j \, sum j^2 x^j$，合并同类项即可得到与“暴力求导法”完全一致的结果。

#strong[懂了];，就是用无穷和的自相残杀，得到有限和

但是啊但是，即使如此，我依然没有看到我想看到的那个求法：

用组合数 表示 一个幂！！！

那么， Ta 来啦！！！
]

======= 幂 $arrow.l.r$ 组合数

将高次幂 $i^k$ 拆解为#strong[下降幂];和#strong[组合数];的线性组合，彻底规避求导的繁琐。

- #strong[核心代换];：
  - $i = binom(i, 1)$
  - $i^2 = 2 binom(i, 2) + binom(i, 1)$
  - $i^3 = 6 binom(i, 3) + 6 binom(i, 2) + binom(i, 1)$
  - $i^4 = 24 binom(i, 4) + 36 binom(i, 3) + 14 binom(i, 2) + binom(i, 1)$
- #strong[通用公式（第二类斯特林数 $S \( k \, j \)$）];：
  - $i^k = sum_(j = 0)^k S \( k \, j \) j ! binom(i, j)$


====== 3. "二项式" 乘 等比

======= 下指标同步（有限和）

#figure(
  align(center)[#table(
    columns: (25%, 25%, 25%, 25%),
    align: (left,left,left,left,),
    table.header([形式幂级数 (和式)], [封闭形式 (原函数)], [推导核心操作], [竞赛实用备注],),
    table.hline(),
    [$sum_(i = 0)^n binom(n, i) x^i$], [$\( 1 + x \)^n$], [#strong[二项式定理];], [生成函数中处理组合数卷积。],
    [$sum_(i = 0)^n binom(n, i)$], [$2^n$], [取 $x = 1$], [组合数求和经典结论。],
    [$sum_(i = 0)^n \( - 1 \)^i binom(n, i)$], [$0$], [取 $x = - 1$], [奇偶项抵消结论。],
    [$sum_(i = 0)^n i binom(n, i) x^i$], [$n x \( 1 + x \)^(n - 1)$], [#strong[对二项式定理求导后乘 $x$];（最直观）], [带权组合数和（求期望常客）。],
    [$sum_(i = 0)^n i^2 binom(n, i) x^i$], [$n x \( 1 + n x \) \( 1 + x \)^(n - 2)$（$n gt.eq 2$；$n = 0 \, 1$ 直接代入）], [#strong[组合数代换] + 吸收恒等式（也可以同上）], [二阶矩/方差计算。],
  )]
  , kind: table
  )

#quote(block: true)[
#strong[推导过程（以 $i^2$ 为例，吸收恒等式代数平移）];：

+ 组合数代换：$i^2 = 2 binom(i, 2) + binom(i, 1)$

+ 代入求和：$sum_(i = 0)^n i^2 binom(n, i) x^i = 2 sum_(i = 0)^n binom(i, 2) binom(n, i) x^i + sum_(i = 0)^n binom(i, 1) binom(n, i) x^i$

+ 应用#strong[吸收恒等式] $binom(i, j) binom(n, i) = binom(n, j) binom(n - j, i - j)$： $= 2 sum_(i = 0)^n binom(n, 2) binom(n - 2, i - 2) x^i + sum_(i = 0)^n binom(n, 1) binom(n - 1, i - 1) x^i$

+ 提取常数，凑二项式定理： $= 2 binom(n, 2) x^2 \( 1 + x \)^(n - 2) + binom(n, 1) x \( 1 + x \)^(n - 1) = n x \( 1 + n x \) \( 1 + x \)^(n - 2)$
]

======= 上指标同步

未加权的有限和有曲棍球棒恒等式；加入 $x^i$ 权重后，一般不能直接套用它。

#figure(
  align(center)[#table(
    columns: (25%, 25%, 25%, 25%),
    align: (left,left,left,left,),
    table.header([形式幂级数 (和式)], [封闭形式 (原函数)], [推导核心操作], [竞赛实用备注],),
    table.hline(),
    [$sum_(i = 0)^oo binom(i, k) x^i$], [$frac(x^k, \( 1 - x \)^(k + 1))$], [#strong[负二项定理/连续求导];], [作为解析级数时要求 $\| x \| < 1$；也可按形式幂级数理解。],
  )]
  , kind: table
  )

#quote(block: true)[
#strong[推导过程];：由 $sum_(i = 0)^oo x^i = frac(1, 1 - x)$，两边连续求导 $k$ 次再除以 $k !$，得到 $sum_(i = k)^oo binom(i, k) x^(i - k) = frac(1, \( 1 - x \)^(k + 1))$；再乘 $x^k$，得到表中的 $sum_(i = 0)^oo binom(i, k) x^i = frac(x^k, \( 1 - x \)^(k + 1))$。前 $k$ 项的二项式系数为 $0$。

#strong[实战（求 $sum i^2 x^i$）];：

$i^2 = 2 binom(i, 2) + binom(i, 1)$

$= 2 sum binom(i, 2) x^i + sum binom(i, 1) x^i = 2 dot.op frac(x^2, \( 1 - x \)^3) + frac(x, \( 1 - x \)^2) = frac(x \( 1 + x \), \( 1 - x \)^3)$
]

======= 上指标有限和：曲棍球棒恒等式

未加权时有直接闭式：

$ sum_(i = 0)^n binom(i, k) = binom(n + 1, k + 1) . $

因此，即使 $n$ 很大，也不需要遍历 $0 tilde.op n$，更不需要拉格朗日插值。若结果需要取模，按模数类型计算右侧组合数：例如模素数 $p$ 且 $k + 1 < p$ 时，可用长度 $k + 1$ 的乘积并除以 $\( k + 1 \) !$；若条件不满足，则使用适用的 Lucas、质因数幂或 CRT 方法。

加权和 $sum_(i = 0)^n binom(i, k) x^i$ 不等于上述曲棍球棒闭式；需要根据具体的 $n \, k \, x$ 另行处理。


===== 后记：有限和 与 无穷和 转换

有限和的闭式可由有限几何和求导、组合数代换等方法直接得到。只有当 $\| x \| < 1$ 时，才可把有限和解释为无穷和减去收敛尾项：

+ #strong[先算无穷和];：利用收敛级数的封闭形式（如 $frac(1, 1 - x)$），并确保 $\| x \| < 1$。
+ #strong[再减去多余项];：无穷和减去从 $n + 1$ 开始的尾项，或者利用公式 $sum_(i = 0)^n x^i = frac(1 - x^(n + 1), 1 - x)$ 直接一步到位。

#strong[记忆口诀];：

- #strong[有限等比找错位];：基础 $sum x^i$ 用错位相减。
- #strong[组合系数找二项];：看到 $binom(n, i)$ 直接上 $\( 1 + x \)^n$。
- #strong[求导乘 $x$ 加权重];：遇到 $i$ 乘系数（$i binom(n, i)$ 或 $i x^i$），闭眼求导再乘 $x$。
- #strong[上指标有限和先看曲棍球棒];：$sum_(i = 0)^n binom(i, k) = binom(n + 1, k + 1)$；带权重时再单独分析。

