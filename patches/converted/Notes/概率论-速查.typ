==== #text("概率论-速查")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/Notes/概率论-速查.md`]

===== 常见分布速查表（算法竞赛特供版）

参数约定：二项分布 $n$ 为非负整数、$0 lt.eq p lt.eq 1$；几何分布 $0 < p lt.eq 1$；负二项分布 $r$ 为正整数、$0 < p lt.eq 1$；泊松分布 $lambda gt.eq 0$。连续型分布要求 $a < b$、指数分布率参数 $lambda > 0$、正态分布标准差 $sigma > 0$。表中 $k$ 阶矩公式默认 $k$ 为非负整数，矩不存在时公式不适用。

====== 一、 离散型分布

#figure(
  align(center)[#table(
    columns: (14.29%, 14.29%, 14.29%, 14.29%, 14.29%, 14.29%, 14.29%),
    align: (left,left,left,left,left,left,left,),
    table.header([分布名称], [记号], [类型], [定义 (PMF)], [$E \( X \)$], [$D \( X \)$], [$k$ 阶原点矩 $E \( X^k \)$],),
    table.hline(),
    [#strong[0-1分布];], [$B \( 1 \, p \)$], [离散型], [$P \( X = 0 \) = 1 - p \, med P \( X = 1 \) = p$], [$p$], [$p \( 1 - p \)$], [$E \( X^k \) = p$ ($k gt.eq 1$)],
    [#strong[二项分布];], [$B \( n \, p \)$], [离散型], [$P \( X = k \) = binom(n, k) p^k \( 1 - p \)^(n - k)$], [$n p$], [$n p \( 1 - p \)$], [$E \( X^k \) = sum_(j = 0)^k S \( k \, j \) n^(underline(j)) p^j$],
    [#strong[几何分布];], [$G \( p \)$], [离散型], [$P \( X = k \) = \( 1 - p \)^(k - 1) p$，$k = 1 \, 2 \, dots.h$], [$1 / p$], [$frac(1 - p, p^2)$], [$E \[ binom(X, r) \] = frac(\( 1 - p \)^(r - 1), p^r)$（$r gt.eq 1$），可转为原点矩],
    [#strong[泊松分布];], [$P \( lambda \)$], [离散型], [$P \( X = k \) = frac(lambda^k, k !) e^(- lambda)$，$k = 0 \, 1 \, dots.h$], [$lambda$], [$lambda$], [$E \( X^k \) = sum_(j = 0)^k S \( k \, j \) lambda^j$],
  )]
  , kind: table
  )

#quote(block: true)[
#strong[补充说明（离散型高阶矩）];： \* $S \( k \, j \)$ 为第二类斯特林数。 \* $n^(underline(j)) = n \( n - 1 \) dots.h.c \( n - j + 1 \)$ 为 $n$ 的 $j$ 阶下降阶乘。 \* #strong[竞赛避坑];：直接求离散分布的高阶原点矩很复杂，通常利用概率生成函数（PGF）$G \( s \) = E \( s^X \)$，通过 $E \( X^(underline(k)) \) = G^(\( k \)) \( 1 \)$ 先求出下降幂的期望，再转换为原点矩。
]


表中连续型矩公式也默认 $k$ 为非负整数且期望存在。

====== 二、 连续型分布

#figure(
  align(center)[#table(
    columns: (14.29%, 14.29%, 14.29%, 14.29%, 14.29%, 14.29%, 14.29%),
    align: (left,left,left,left,left,left,left,),
    table.header([分布名称], [记号], [类型], [定义 (PDF)], [$E \( X \)$], [$D \( X \)$], [$k$ 阶原点矩 $E \( X^k \)$],),
    table.hline(),
    [#strong[均匀分布];], [$U \( a \, b \)$], [连续型], [$f \( x \) = frac(1, b - a)$，$a < x < b$], [$frac(a + b, 2)$], [$frac(\( b - a \)^2, 12)$], [$E \( X^k \) = frac(b^(k + 1) - a^(k + 1), \( k + 1 \) \( b - a \))$],
    [#strong[指数分布];], [$E \( lambda \)$], [连续型], [$f \( x \) = lambda e^(- lambda x)$，$x > 0$], [$1 / lambda$], [$1 / lambda^2$], [$E \( X^k \) = frac(k !, lambda^k)$],
    [#strong[正态分布];], [$N \( mu \, sigma^2 \)$], [连续型], [$f \( x \) = frac(1, sqrt(2 pi) sigma) e^(- frac(\( x - mu \)^2, 2 sigma^2))$], [$mu$], [$sigma^2$], [$E \( X^k \) = sum_(j = 0)^k binom(k, j) mu^(k - j) sigma^j E \( Z^j \)$],
  )]
  , kind: table
  )

#quote(block: true)[
#strong[补充说明（连续型高阶矩）];： \* 对于#strong[正态分布];，令 $Z = frac(X - mu, sigma) tilde.op N \( 0 \, 1 \)$，其标准正态分布的 $k$ 阶原点矩为：$E \( Z^k \) = \( k - 1 \) ! !$（当 $k$ 为偶数），$0$（当 $k$ 为奇数）。由此可导出一般正态分布的高阶矩。 \* 对于#strong[指数分布];，其高阶矩 $E \( X^k \) = frac(k !, lambda^k)$ 非常好记，也是竞赛中常考的结论。
]

