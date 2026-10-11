==== #text("数学-生成函数")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/Notes/数学-生成函数.md`]

#quote(block: true)[
在算法竞赛的生成函数（OGF/EGF）中，常用的对象是#strong[形式幂级数];及其系数运算。

若把它当作实数或复数级数求值，还要检查收敛范围；若按形式幂级数理解，则关注每个系数的代数恒等式，不讨论数值收敛。
]


===== 生成函数常用封闭形式（无限和分类表）

- 纯等比（基础积木）
- 幂乘等比（难求，衍生 $sum i^k x^i$）
- 组合数 乘 等比（好求）
  - 上指标同步
    - $sum binom(i, k) x^i$
  - 下指标同步
    - $sum binom(n, i) x^i$（仅当 $n$ 为常数时的无穷和退化为有限和）


====== 一、 纯等比（基础积木）

下表的有理函数等式在形式幂级数意义下成立；按数值级数理解时，几何级数需要 $\| x \| < 1$（换成 $alpha x$ 时需要 $\| alpha x \| < 1$）。

#figure(
  align(center)[#table(
    columns: (20%, 20%, 20%, 20%, 20%),
    align: (left,left,left,left,left,),
    table.header([序号], [形式幂级数 (和式)], [封闭形式 (原函数)], [推导核心操作], [竞赛实用备注],),
    table.hline(),
    [1], [$sum_(i = 0)^oo x^i$], [$frac(1, 1 - x)$], [#strong[等比数列求和];], [所有 OGF 的基石，$\| x \| < 1$],
    [2], [$sum_(i = 0)^oo alpha^i x^i$], [$frac(1, 1 - alpha x)$], [#strong[换元];：令 $q = alpha x$], [带常数系数的递推],
    [3], [$sum_(i = 0)^oo x^(2 i)$], [$frac(1, 1 - x^2)$], [#strong[换元];：令 $q = x^2$], [隔项求和（偶数项）],
    [4], [$sum_(i = 0)^oo x^(2 i + 1)$], [$frac(x, 1 - x^2)$], [#strong[提取 $x$] + 换元 $q = x^2$], [隔项求和（奇数项）],
  )]
  , kind: table
  )


====== 二、 "幂" 乘 等比（难求）

这些恒等式按形式幂级数理解时对系数成立；按数值级数理解时，右侧的有理函数展开要求 $\| x \| < 1$。

#figure(
  align(center)[#table(
    columns: (20%, 20%, 20%, 20%, 20%),
    align: (left,left,left,left,left,),
    table.header([序号], [形式幂级数 (和式)], [封闭形式 (原函数)], [推导核心操作], [竞赛实用备注],),
    table.hline(),
    [5], [$sum_(i = 0)^oo \( i + 1 \) x^i$], [$frac(1, \( 1 - x \)^2)$], [#strong[求导];：对公式 1 两边对 $x$ 求导], [系数是线性递增 $\( i + 1 \)$],
    [6], [$sum_(i = 0)^oo i x^i$], [$frac(x, \( 1 - x \)^2)$], [#strong[乘 $x$];：对公式 5 两边乘 $x$], [系数是 $i$，注意下标从 $0$ 变 $1$],
    [7], [$sum_(i = 0)^oo i^2 x^i$], [$frac(x \( 1 + x \), \( 1 - x \)^3)$], [#strong[求导];：对公式 6 继续求导并乘 $x$], [二阶矩/方差计算。],
    [8], [$sum_(i = 0)^oo i^3 x^i$], [$frac(x \( 1 + 4 x + x^2 \), \( 1 - x \)^4)$], [#strong[求导];：连续求导乘 $x$], [三阶矩计算。],
  )]
  , kind: table
  )

#quote(block: true)[
#strong[💡 降维打击（组合数代换）];： 无穷和由于没有尾巴，你可以放心大胆地用“用组合数表示幂”的方法，进行纯代数平移，无需微积分！ 核心代换：$i^2 = 2 binom(i, 2) + binom(i, 1)$，$i^3 = 6 binom(i, 3) + 6 binom(i, 2) + binom(i, 1)$ 配合“上指标同步”神器：$sum_(i = 0)^oo binom(i, j) x^i = frac(x^j, \( 1 - x \)^(j + 1))$ 例如求 $sum i^2 x^i = 2 dot.op frac(x^2, \( 1 - x \)^3) + frac(x, \( 1 - x \)^2) = frac(x \( 1 + x \), \( 1 - x \)^3)$。
]


====== 三、 组合数 乘 等比（好求）

======= 1. 上指标同步

#strong[特征];：组合数的上指标是求和变量 $i$，下指标固定为 $k$。

#figure(
  align(center)[#table(
    columns: (20%, 20%, 20%, 20%, 20%),
    align: (left,left,left,left,left,),
    table.header([序号], [形式幂级数 (和式)], [封闭形式 (原函数)], [推导核心操作], [竞赛实用备注],),
    table.hline(),
    [9], [$sum_(i = 0)^oo binom(i, k) x^i$], [$frac(x^k, \( 1 - x \)^(k + 1))$], [#strong[负二项定理/连续求导];], [$k$ 为非负整数；按数值级数理解需 $\| x \| < 1$],
    [10], [$sum_(i = 0)^oo binom(n + i, i) x^i$], [$frac(1, \( 1 - x \)^(n + 1))$], [#strong[广义二项式定理];], [$n$ 为非负整数；$binom(n + i, i) = binom(n + i, n)$],
  )]
  , kind: table
  )

======= 2. 下指标同步（有限和）

当 $n$ 是非负整数时，$binom(n, i) = 0$（$i > n$），所以可以把有限和写成从 $0$ 到 $oo$ 的形式：

- $sum_(i = 0)^oo binom(n, i) x^i = \( 1 + x \)^n$

这只是有限二项式定理的零项延拓，不是一个新的无穷级数恒等式。若上指标不是非负整数，广义二项式系数通常不会在有限位置后变成 $0$，需要另行说明收敛范围。


====== 四、 特殊形式（积分与 EGF）

其中 $sum_(i = 1)^oo x^i \/ i = - ln \( 1 - x \)$ 按数值级数理解要求 $\| x \| < 1$；指数函数及其奇偶项展开对所有实数或复数 $x$ 收敛。

#figure(
  align(center)[#table(
    columns: (20%, 20%, 20%, 20%, 20%),
    align: (left,left,left,left,left,),
    table.header([序号], [形式幂级数 (和式)], [封闭形式 (原函数)], [推导核心操作], [竞赛实用备注],),
    table.hline(),
    [11], [$sum_(i = 1)^oo x^i / i$], [$- ln \( 1 - x \)$], [#strong[积分];：对公式 1 两边积分], [分母有 $i$，积分降幂],
    [12], [$sum_(i = 0)^oo frac(x^i, i !)$], [$e^x$], [#strong[泰勒展开];], [EGF 的基石],
    [13], [$sum_(i = 0)^oo frac(x^(2 i), \( 2 i \) !)$], [$frac(e^x + e^(- x), 2)$], [#strong[泰勒展开组合];], [双曲余弦 $cosh x$（偶数 EGF）],
    [14], [$sum_(i = 0)^oo frac(x^(2 i + 1), \( 2 i + 1 \) !)$], [$frac(e^x - e^(- x), 2)$], [#strong[泰勒展开组合];], [双曲正弦 $sinh x$（奇数 EGF）],
  )]
  , kind: table
  )


===== 后记：生成函数（无限和）推导口诀

+ #strong[基础靠等比];：$sum x^i = frac(1, 1 - x)$。
+ #strong[求导升幂，积分降幂];：遇到系数 $i$，就求导；遇到分母 $i$，就积分。
+ #strong[乘 $x$ 移下标];：求导之后如果发现最高次数少了一次（比如 $sum i x^(i - 1)$），就乘一个 $x$ 把次数补回来（变成 $sum i x^i$）。
+ #strong[换元看周期];：遇到 $2 i$ 或 $2 i + 1$，直接把 $x^2$ 当作整体代换。
+ #strong[幂转组合降维打击];：不要死磕求导！$i^2 = 2 binom(i, 2) + binom(i, 1)$，配合上指标同步 $sum binom(i, k) x^i = frac(x^k, \( 1 - x \)^(k + 1))$ 直接代数平移。
+ #strong[EGF 找泰勒];：分母出现 $i !$，立刻联想 $e^x$ 的展开式（奇数项/偶数项对应双曲函数）。

