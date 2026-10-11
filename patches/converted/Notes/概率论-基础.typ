==== #text("概率论-基础")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/Notes/概率论-基础.md`]

===== 基础定义

====== 概率

======= 连续型的概率

- 概率密度函数（PDF）
  - 若 $X$ 有密度 $f$，则 $P \( X = k \) = 0$；$f \( k \)$ 是密度值，不是点概率。
- 累积分布函数（CDF）
  - $F \( k \) = integral_(- oo)^k f \( x \) d x$
  - 在适当条件下，$F' \( k \) = f \( k \)$ 几乎处处成立。

$P \( a < X lt.eq b \) = integral_a^b f \( x \) d x = F \( b \) - F \( a \)$

======= 离散型的概率

#quote(block: true)[
一般存在 $p_i$ 的写法
]

- 概率质量函数（PMF）
  - $p_k = P \( X = k \) gt.eq 0$，并且 $sum_k p_k = 1$。
- 累积分布函数（CDF）
  - $F \( k \) = sum_(i lt.eq k) p_i$

$P \( a < X lt.eq b \) = sum_(a < i lt.eq b) p_i = F \( b \) - F \( a \)$

====== 期望/矩

以下期望与矩公式要求相应的绝对矩有限；方差公式要求二阶矩有限。

======= 连续型的 期望/矩

$E \( X \) = integral_(- oo)^oo x f \( x \) thin d x$

$E \( X^k \) = integral_(- oo)^oo x^k f \( x \) thin d x$

======= 离散型的 期望/矩

$E \( X \) = sum i dot.op p_i$

$E \( X^k \) = sum i^k dot.op p_i$

======= 期望公式

- 线性性
  - $E \( a X + b Y + c \) = a E \( X \) + b E \( Y \) + c$（相关期望存在且有限时）
- 可乘性(若独立)
  - $E \( X Y \) = E \( X \) E \( Y \)$（独立且相关期望存在时）

======= 期望公式 Plus

#quote(block: true)[
这是期望DP、树上随机游走的绝对核心。
]

- 全期望公式
  - $E \( X \) = E \( E \( X \| Y \) \)$
  - 比如
    - 若从状态 $u$ 以概率 $p_(u v)$ 转移到 $v$，并在转移时支付代价 $c_(u v)$，则 $E \( u \) = sum_v p_(u v) \( c_(u v) + E \( v \) \)$（需满足期望有限等条件）。

====== 方差

======= 连续型的 方差

$D \( X \) = integral \( x - E \( X \) \)^2 dot.op f \( x \) d x$

======= 离散型的 方差

$D \( X \) = sum \( i - E \( X \) \)^2 dot.op p_i$

======= 方差公式

$ D(X) = E((X - E(X))^2) $

$ = E(X^2) - (E(X))^2 $

- 基本计算
  - $D \( a X + b \) = a^2 D \( X \)$
- 可加性(若独立)
  - $D \( X + Y \) = D \( X \) + D \( Y \)$（$X \, Y$ 有有限二阶矩时）
- 可加性(一般)
  - $D \( X + Y \) = D \( X \) + D \( Y \) + 2 C o v \( X \, Y \)$（$X \, Y$ 有有限二阶矩时）

======= 方差公式 Plus

#quote(block: true)[
这是期望DP、树上随机游走的绝对核心。
]

- 全方差公式：按 $Y$ 分组，把组内波动与组间均值差异相加。
  - $D \( X \) = E \( D \( X divides Y \) \) + D \( E \( X divides Y \) \)$（$X$ 有有限二阶矩时）。

====== 协方差

- 定义
  - $C o v \( X \, Y \) = E \( X Y \) - E \( X \) E \( Y \)$


