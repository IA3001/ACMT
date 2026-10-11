#pagebreak(weak: true)
==== #text("数学-微积分")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/Notes/数学-微积分.md`]

===== 一、重要极限与等价无穷小（$x arrow.r 0$）

- 基本极限：
  - $lim_(x arrow.r 0) frac(sin x, x) = 1$，$lim_(x arrow.r 0) frac(tan x, x) = 1$
  - $lim_(x arrow.r 0) frac(1 - cos x, x^2) = 1 / 2$
  - $lim_(x arrow.r 0) frac(e^x - 1, x) = 1$，$lim_(x arrow.r 0) frac(ln \( 1 + x \), x) = 1$
  - $lim_(x arrow.r 0) \( 1 + x \)^(1 \/ x) = e$，$lim_(x arrow.r oo) \( 1 + 1 / x \)^x = e$
  - $lim_(x arrow.r 0) frac(\( 1 + x \)^alpha - 1, x) = alpha$
  - $lim_(x arrow.r oo) x^k / e^x = 0$，$lim_(x arrow.r 0^(+)) x ln x = 0$
- 等价无穷小（用于极限替换）：
  - $sin x tilde.op x$，$tan x tilde.op x$，$arcsin x tilde.op x$，$arctan x tilde.op x$
  - $1 - cos x tilde.op 1 / 2 x^2$，$e^x - 1 tilde.op x$，$ln \( 1 + x \) tilde.op x$
  - $\( 1 + x \)^alpha - 1 tilde.op alpha x$

===== 二、求导公式全表

- #strong[基本初等函数];：
  - $\( C \)' = 0$，$\( x^n \)' = n x^(n - 1)$，$\( sqrt(x) \)' = frac(1, 2 sqrt(x))$
  - $\( e^x \)' = e^x$，$\( a^x \)' = a^x ln a$
  - $\( ln x \)' = 1 / x$，$\( log_a x \)' = frac(1, x ln a)$
- #strong[三角函数];：
  - $\( sin x \)' = cos x$，$\( cos x \)' = - sin x$
  - $\( tan x \)' = sec^2 x$，$\( cot x \)' = - csc^2 x$
  - $\( sec x \)' = sec x tan x$，$\( csc x \)' = - csc x cot x$
- #strong[反三角函数];：
  - $\( arcsin x \)' = 1 / sqrt(1 - x^2)$，$\( arccos x \)' = - 1 / sqrt(1 - x^2)$
  - $\( arctan x \)' = frac(1, 1 + x^2)$，$\( "arccot" x \)' = - frac(1, 1 + x^2)$
- #strong[双曲函数];：
  - $\( sinh x \)' = cosh x$，$\( cosh x \)' = sinh x$
  - $\( tanh x \)' = "sech"^2 x$，$\( coth x \)' = - "csch"^2 x$
- #strong[运算法则];：
  - $\( u v \)' = u' v + u v'$，$\( u / v \)' = frac(u' v - u v', v^2)$
  - 链式法则：$frac(d y, d x) = frac(d y, d u) dot.op frac(d u, d x)$
  - 反函数求导：$\[ f^(- 1) \( x \) \]' = frac(1, f' \( f^(- 1) \( x \) \))$
  - 参数方程求导：$frac(d y, d x) = frac(d y \/ d t, d x \/ d t)$，$frac(d^2 y, d x^2) = frac(d, d t) \( frac(d y, d x) \) \/ frac(d x, d t)$
- #strong[高阶导数];：
  - $\( x^n \)^(\( n \)) = n !$，$\( e^x \)^(\( n \)) = e^x$
  - $\( sin x \)^(\( n \)) = sin \( x + frac(n pi, 2) \)$，$\( cos x \)^(\( n \)) = cos \( x + frac(n pi, 2) \)$
  - $\( x^n \)^(\( k \)) = frac(n !, \( n - k \) !) x^(n - k) med \( k lt.eq n \)$
  - 莱布尼茨公式：$\( u v \)^(\( n \)) = sum_(k = 0)^n binom(n, k) u^(\( k \)) v^(\( n - k \))$

===== 三、不定积分全表

#quote(block: true)[
口诀的核心是选择被积函数 进 d 后面的顺序

其实是 三 指 幂 对 反 啊啊啊啊啊

排在前面的选作 u（求导），排在后面的选作 dv（积分）。
]

- #strong[基本幂指对];：
  - $integral x^n d x = frac(x^(n + 1), n + 1) + C med \( n eq.not - 1 \)$
  - $integral 1 / x d x = ln \| x \| + C$
  - $integral e^x d x = e^x + C$，$integral a^x d x = frac(a^x, ln a) + C$
  - $integral ln x d x = x ln x - x + C$
  - $integral x^n ln x d x = frac(x^(n + 1), n + 1) ln x - frac(x^(n + 1), \( n + 1 \)^2) + C quad \( n eq.not - 1 \, med x > 0 \)$
- #strong[基本三角];：
  - $integral sin x d x = - cos x + C$，$integral cos x d x = sin x + C$
  - $integral tan x d x = - ln \| cos x \| + C$，$integral cot x d x = ln \| sin x \| + C$
  - $integral sec x d x = ln \| sec x + tan x \| + C$，$integral csc x d x = ln \| csc x - cot x \| + C$
  - $integral sec^2 x d x = tan x + C$，$integral csc^2 x d x = - cot x + C$
- #strong[含 $a x + b$];：
  - $integral \( a x + b \)^n d x = frac(\( a x + b \)^(n + 1), a \( n + 1 \)) + C quad \( a eq.not 0 \, med n eq.not - 1 \)$
  - $integral frac(1, a x + b) d x = 1 / a ln \| a x + b \| + C$
  - $integral frac(x, a x + b) d x = x / a - b / a^2 ln \| a x + b \| + C$
  - $integral frac(1, x \( a x + b \)) d x = 1 / b ln \| frac(x, a x + b) \| + C$
- #strong[含 $a^2 plus.minus x^2$];：
  - $integral frac(1, a^2 + x^2) d x = 1 / a arctan x / a + C$
  - $integral frac(1, a^2 - x^2) d x = frac(1, 2 a) ln \| frac(a + x, a - x) \| + C$
  - $integral frac(x, a^2 plus.minus x^2) d x = plus.minus 1 / 2 ln \| a^2 plus.minus x^2 \| + C$
- #strong[含根式];：
  - $integral 1 / sqrt(a^2 - x^2) d x = arcsin x / a + C$
  - $integral 1 / sqrt(x^2 plus.minus a^2) d x = ln \| x + sqrt(x^2 plus.minus a^2) \| + C$
  - $integral sqrt(a^2 - x^2) d x = x / 2 sqrt(a^2 - x^2) + a^2 / 2 arcsin x / a + C$
  - $integral sqrt(x^2 plus.minus a^2) d x = x / 2 sqrt(x^2 plus.minus a^2) plus.minus a^2 / 2 ln \| x + sqrt(x^2 plus.minus a^2) \| + C$
  - $integral frac(1, x sqrt(x^2 - a^2)) d x = 1 / a arccos a / x + C quad \( a > 0 \, med x > a \)$。在 $x < - a$ 时，原函数为 $- 1 / a arccos a / x + C$。
- #strong[三角函数高次与乘积];：
  - $integral sin^2 x d x = x / 2 - frac(sin 2 x, 4) + C$，$integral cos^2 x d x = x / 2 + frac(sin 2 x, 4) + C$
  - $integral tan^2 x d x = tan x - x + C$，$integral cot^2 x d x = - cot x - x + C$
  - $integral sin^n x d x = - frac(sin^(n - 1) x cos x, n) + frac(n - 1, n) integral sin^(n - 2) x d x$
  - $integral cos^n x d x = frac(cos^(n - 1) x sin x, n) + frac(n - 1, n) integral cos^(n - 2) x d x$
  - $integral tan^n x d x = frac(tan^(n - 1) x, n - 1) - integral tan^(n - 2) x d x$
  - $integral sec^n x d x = frac(sec^(n - 2) x tan x, n - 1) + frac(n - 2, n - 1) integral sec^(n - 2) x d x$
  - $integral sin a x cos b x d x = - frac(cos \( \( a - b \) x \), 2 \( a - b \)) - frac(cos \( \( a + b \) x \), 2 \( a + b \)) + C quad \( a eq.not plus.minus b \)$
  - $integral sin a x sin b x d x = frac(sin \( \( a - b \) x \), 2 \( a - b \)) - frac(sin \( \( a + b \) x \), 2 \( a + b \)) + C quad \( a eq.not plus.minus b \)$
  - $integral cos a x cos b x d x = frac(sin \( \( a - b \) x \), 2 \( a - b \)) + frac(sin \( \( a + b \) x \), 2 \( a + b \)) + C quad \( a eq.not plus.minus b \)$
  - 当 $a = plus.minus b$ 时，上述乘积公式中的分母为 $0$，应先用积化和差恒等式化简，再单独积分。
- #strong[反三角函数];：
  - $integral arcsin x d x = x arcsin x + sqrt(1 - x^2) + C$
  - $integral arccos x d x = x arccos x - sqrt(1 - x^2) + C$
  - $integral arctan x d x = x arctan x - 1 / 2 ln \( 1 + x^2 \) + C$
- #strong[指数与对数乘积];：
  - $integral x e^(a x) d x = e^(a x) / a^2 \( a x - 1 \) + C$
  - $integral x^n e^(a x) d x = frac(x^n e^(a x), a) - n / a integral x^(n - 1) e^(a x) d x$（递推）
  - $integral e^(a x) sin b x d x = frac(e^(a x), a^2 + b^2) \( a sin b x - b cos b x \) + C$
  - $integral e^(a x) cos b x d x = frac(e^(a x), a^2 + b^2) \( a cos b x + b sin b x \) + C$
- #strong[双曲函数];：
  - $integral sinh x d x = cosh x + C$，$integral cosh x d x = sinh x + C$
  - $integral tanh x d x = ln \( cosh x \) + C$，$integral coth x d x = ln \| sinh x \| + C$
  - $integral 1 / sqrt(x^2 + a^2) d x = "arsinh" x / a + C = ln \( x + sqrt(x^2 + a^2) \) + C$

===== 四、定积分与特殊函数

- #strong[Wallis 公式];：
  - $integral_0^(pi \/ 2) sin^n x d x = integral_0^(pi \/ 2) cos^n x d x = frac(\( n - 1 \) ! !, n ! !) times cases(delim: "{", pi / 2 & n upright(" 偶"), 1 & n upright(" 奇"))$
- #strong[Beta 函数];：
  - 定义：$B \( a \, b \) = integral_0^1 x^(a - 1) \( 1 - x \)^(b - 1) d x$
  - 阶乘形式：$integral_0^1 x^a \( 1 - x \)^b d x = frac(a ! b !, \( a + b + 1 \) !)$
  - 与 Gamma 关系：$B \( a \, b \) = frac(Gamma \( a \) Gamma \( b \), Gamma \( a + b \))$
- #strong[Gamma 函数];：
  - 定义：$Gamma \( s \) = integral_0^oo x^(s - 1) e^(- x) d x$
  - 递推：$Gamma \( s + 1 \) = s Gamma \( s \)$，$Gamma \( n + 1 \) = n !$
  - 余元公式：$Gamma \( x \) Gamma \( 1 - x \) = frac(pi, sin \( pi x \)) quad \( x in.not bb(Z) \)$
- #strong[高斯积分与正态分布];：
  - $integral_(- oo)^oo e^(- x^2) d x = sqrt(pi)$
  - $integral_(- oo)^oo e^(- x^2 \/ 2) d x = sqrt(2 pi)$
  - $integral_(- oo)^oo x^(2 k) e^(- x^2 \/ 2) d x = \( 2 k - 1 \) ! ! sqrt(2 pi)$
  - $integral_0^oo x^n e^(- a x) d x = frac(n !, a^(n + 1))$
- #strong[Dirichlet 积分];：
  - $integral_0^oo frac(sin x, x) d x = pi / 2$
  - $integral_0^oo frac(sin^2 x, x^2) d x = pi / 2$
- #strong[欧拉常数与近似];：
  - $gamma = lim_(n arrow.r oo) \( sum_(k = 1)^n 1 / k - ln n \) approx 0.5772$
  - 调和数近似：$H_n approx ln n + gamma + frac(1, 2 n)$
  - Stirling 公式：$n ! approx sqrt(2 pi n) \( n / e \)^n$

===== 五、泰勒展开与级数

- $e^x = 1 + x + frac(x^2, 2 !) + frac(x^3, 3 !) + dots.h$
- $ln \( 1 + x \) = x - x^2 / 2 + x^3 / 3 - dots.h$
- $sin x = x - frac(x^3, 3 !) + frac(x^5, 5 !) - dots.h$
- $cos x = 1 - frac(x^2, 2 !) + frac(x^4, 4 !) - dots.h$
- $tan x = x + x^3 / 3 + frac(2 x^5, 15) + dots.h$
- $arcsin x = x + x^3 / 6 + frac(3 x^5, 40) + dots.h$
- $arctan x = x - x^3 / 3 + x^5 / 5 - dots.h$
- $frac(1, 1 - x) = 1 + x + x^2 + dots.h$
- $frac(1, 1 + x) = 1 - x + x^2 - dots.h$
- $\( 1 + x \)^alpha = 1 + alpha x + frac(alpha \( alpha - 1 \), 2 !) x^2 + dots.h$
- $sinh x = x + frac(x^3, 3 !) + frac(x^5, 5 !) + dots.h$
- $cosh x = 1 + frac(x^2, 2 !) + frac(x^4, 4 !) + dots.h$

===== 六、竞赛实用微积分技巧

- #strong[分部积分];：$integral u d v = u v - integral v d u$（优先选 $u$ 的顺序：反、对、幂、指、三）
- #strong[换元积分];：三角换元、根式换元、倒代换（$x = 1 \/ t$）。
- #strong[区间再现];：$integral_a^b f \( x \) d x = integral_a^b f \( a + b - x \) d x$
- #strong[对称性];：奇函数在对称区间积分为 0，偶函数为 $2 integral_0^a f \( x \) d x$
- #strong[积分放缩];：$sum_(i = 1)^n f \( i \) approx integral_1^n f \( x \) d x$（欧拉-麦克劳林公式）
- #strong[洛必达法则];：$0 / 0$ 或 $oo / oo$ 型，$lim f / g = lim f' / g'$
- #strong[拉格朗日中值定理];：$f \( b \) - f \( a \) = f' \( xi \) \( b - a \)$，$xi in \( a \, b \)$
- #strong[积分中值定理];：$integral_a^b f \( x \) d x = f \( xi \) \( b - a \)$，$xi in \( a \, b \)$


===== 七、示范使用示例（竞赛向·平衡版）

#strong[1. 指数分布期望与方差]

- #strong[问题];：$X tilde.op E \( lambda \)$，求 $E \[ X \]$ 和 $D \[ X \]$。
- #strong[公式];：$integral_0^oo x^n e^(- a x) d x = frac(n !, a^(n + 1))$
- #strong[代入];：$E \[ X \] = integral_0^oo x lambda e^(- lambda x) d x = lambda dot.op frac(1 !, lambda^2) = 1 / lambda$
- #strong[结果];：$E \[ X \] = 1 / lambda$，$E \[ X^2 \] = 2 / lambda^2$，$D \[ X \] = 1 / lambda^2$。
- #strong[应用];：概率期望题直接写答案。

#strong[2. 均匀分布次序统计量]

- #strong[问题];：$n$ 个 $U \[ 0 \, 1 \]$ 变量，求第 $k$ 小的期望。
- #strong[公式];：Beta 积分 $integral_0^1 x^a \( 1 - x \)^b d x = frac(a ! b !, \( a + b + 1 \) !)$
- #strong[代入];：密度 $f_k \( x \) prop x^(k - 1) \( 1 - x \)^(n - k)$，乘 $x$ 后套公式。
- #strong[结果];：$E \[ X_(\( k \)) \] = frac(k, n + 1)$。
- #strong[应用];：随机采样与次序统计量问题。

#strong[3. 正态分布归一化]

- #strong[问题];：证明 $integral_(- oo)^oo 1 / sqrt(2 pi) e^(- x^2 \/ 2) d x = 1$。
- #strong[公式];：高斯积分 $integral_(- oo)^oo e^(- x^2 \/ 2) d x = sqrt(2 pi)$
- #strong[代入];：直接除以 $sqrt(2 pi)$。
- #strong[结果];：归一化成立。
- #strong[应用];：概率论推导、特征函数。

#strong[4. 最大值期望（离散均匀）]

- #strong[问题];：$X_i tilde.op U { 1 \, dots.h \, m }$，求 $E \[ max X_i \]$。
- #strong[公式];：尾和 $E \[ max \] = sum_(x = 1)^m P \( max gt.eq x \)$
- #strong[代入];：$P \( max gt.eq x \) = 1 - (frac(x - 1, m))^n$
- #strong[结果];：$E \[ max \] = sum_(x = 1)^m [1 - (frac(x - 1, m))^n]$
- #strong[应用];：掷骰子、随机最大值估计。

#strong[5. 赠券收集期望]

- #strong[问题];：集齐 $n$ 种卡片的期望次数。
- #strong[公式];：几何分布期望 $E = 1 / p$，调和数 $H_n$
- #strong[代入];：已有 $k$ 种时，抽新卡概率 $p = frac(n - k, n)$，期望 $frac(n, n - k)$。
- #strong[结果];：$E = sum_(k = 0)^(n - 1) frac(n, n - k) = n H_n approx n ln n$
- #strong[应用];：等概率收集问题。

#strong[6. 组合数取对数（Stirling）]

- #strong[问题];：$n$ 很大时估计 $ln binom(n, k)$。
- #strong[公式];：$ln \( n ! \) approx n ln n - n + 1 / 2 ln \( 2 pi n \)$
- #strong[代入];：$ln binom(n, k) = ln \( n ! \) - ln \( k ! \) - ln \( \( n - k \) ! \)$
- #strong[结果];：$ln binom(n, k) approx n H \( k \/ n \)$，$H$ 为熵函数。
- #strong[应用];：信息论、概率估计。

#strong[7. 分部积分求矩]

- #strong[问题];：计算 $integral x e^x d x$。
- #strong[公式];：$integral u d v = u v - integral v d u$，按“反对幂指三”选 $u$。
- #strong[代入];：$u = x$，$d v = e^x d x$，得 $x e^x - integral e^x d x$。
- #strong[结果];：$x e^x - e^x + C$。
- #strong[应用];：期望矩计算、生成函数。

#strong[8. 泰勒展开求极限]

- #strong[问题];：求 $lim_(x arrow.r 0) frac(e^x - 1 - x, x^2)$。
- #strong[公式];：$e^x = 1 + x + x^2 / 2 + o \( x^2 \)$
- #strong[代入];：分子 $= x^2 / 2 + o \( x^2 \)$。
- #strong[结果];：$1 / 2$。
- #strong[应用];：复杂极限、概率近似。

#strong[9. Wallis 公式求三角积分]

- #strong[问题];：计算 $integral_0^(pi \/ 2) sin^4 x d x$。
- #strong[公式];：Wallis 公式。
- #strong[代入];：$n = 4$（偶），$frac(3 ! !, 4 ! !) dot.op pi / 2 = 3 / 8 dot.op pi / 2$。
- #strong[结果];：$frac(3 pi, 16)$。
- #strong[应用];：三角积分、随机游走。

#strong[10. 拉格朗日中值定理证不等式]

- #strong[问题];：证明 $ln \( 1 + x \) < x$（$x > 0$）。
- #strong[公式];：$f \( b \) - f \( a \) = f' \( xi \) \( b - a \)$
- #strong[代入];：$f \( t \) = ln \( 1 + t \)$，在 $\[ 0 \, x \]$ 上得 $ln \( 1 + x \) = frac(x, 1 + xi)$。
- #strong[结果];：$frac(x, 1 + xi) < x$，得证。
- #strong[应用];：概率不等式、算法分析。

#strong[11. Beta 积分证卡特兰数]

- #strong[问题];：证明 $C_n = frac(1, n + 1) binom(2 n, n)$。
- #strong[公式];：Beta 积分表示 $C_n = frac(2 dot.op 4^n, pi) B \( n + 1 \/ 2 \, 3 \/ 2 \)$。
- #strong[代入];：$B \( n + 1 \/ 2 \, 3 \/ 2 \) = frac(Gamma \( n + 1 \/ 2 \) sqrt(pi) \/ 2, \( n + 1 \) !)$。
- #strong[结果];：化简得 $frac(1, n + 1) binom(2 n, n)$。
- #strong[应用];：组合计数、括号序列。

#strong[12. Dirichlet 积分]

- #strong[问题];：计算 $integral_0^oo frac(sin x, x) d x$。
- #strong[公式];：Dirichlet 积分。
- #strong[结果];：$pi / 2$。
- #strong[应用];：信号处理、傅里叶变换。

#strong[13. 随机变量函数的期望]

- #strong[问题];：$X tilde.op f \( x \)$，求 $E \[ g \( X \) \]$。
- #strong[公式];：$E \[ g \( X \) \] = integral_(- oo)^oo g \( x \) f \( x \) d x$
- #strong[示例];：$X tilde.op U \[ 0 \, 1 \]$，$E \[ X^2 \] = integral_0^1 x^2 d x = 1 / 3$。
- #strong[应用];：概率期望题的标准计算。

#strong[14. 概率母函数求矩]

- #strong[问题];：$G \( s \) = E \[ s^X \]$，求 $E \[ X \]$、$D \[ X \]$。
- #strong[公式];：$E \[ X \] = G' \( 1 \)$，$E \[ X \( X - 1 \) \] = G'' \( 1 \)$
- #strong[示例];：几何分布 $G \( s \) = frac(p s, 1 - \( 1 - p \) s)$，$G' \( 1 \) = 1 / p$。
- #strong[应用];：离散期望的生成函数法。

#strong[15. 洛必达比较增长率]

- #strong[问题];：比较 $log n$ 与 $n^epsilon.alt$ 的增长速度。
- #strong[公式];：洛必达法则 $lim f / g = lim f' / g'$
- #strong[示例];：$lim_(n arrow.r oo) frac(ln n, n^epsilon.alt) = lim frac(1 \/ n, epsilon.alt n^(epsilon.alt - 1)) = 0$。
- #strong[应用];：算法复杂度渐进分析。

#strong[16. 斯特林公式估计组合数]

- #strong[问题];：$n$ 很大时估计 $binom(2 n, n)$。
- #strong[公式];：$n ! approx sqrt(2 pi n) \( n \/ e \)^n$
- #strong[示例];：$binom(2 n, n) approx 4^n / sqrt(pi n)$。
- #strong[应用];：中心二项式系数、随机游走。

#strong[17. 积分放缩求调和级数]

- #strong[问题];：估算 $H_n = sum_(i = 1)^n 1 / i$。
- #strong[公式];：$integral_1^(n + 1) 1 / x d x < H_n < 1 + integral_1^n 1 / x d x$
- #strong[结果];：$H_n approx ln n + gamma$。
- #strong[应用];：赠券收集、快速估算。

#strong[18. 概率积分变换]

- #strong[问题];：生成服从分布 $F$ 的随机数。
- #strong[公式];：若 $U tilde.op U \[ 0 \, 1 \]$，则 $F^(- 1) \( U \)$ 服从分布 $F$。
- #strong[示例];：指数分布 $F \( x \) = 1 - e^(- lambda x)$，$X = - frac(ln \( 1 - U \), lambda)$。
- #strong[应用];：随机化算法、蒙特卡洛模拟。

#strong[19. 期望尾和公式（连续型）]

- #strong[问题];：$X gt.eq 0$，求 $E \[ X \]$。
- #strong[公式];：$E \[ X \] = integral_0^oo P \( X > x \) d x$
- #strong[示例];：指数分布 $P \( X > x \) = e^(- lambda x)$，$E \[ X \] = integral_0^oo e^(- lambda x) d x = 1 / lambda$。
- #strong[应用];：最大值/最小值期望、概率不等式。

#strong[20. 最大次序统计量期望（连续型）]

- #strong[问题];：$n$ 个 $U \[ 0 \, 1 \]$ 变量，求 $E \[ max X_i \]$。
- #strong[公式];：$F_max \( x \) = x^n$，密度 $f_max \( x \) = n x^(n - 1)$。
- #strong[结果];：$E \[ max \] = integral_0^1 x dot.op n x^(n - 1) d x = frac(n, n + 1)$。
- #strong[应用];：随机最大值估计。

#strong[21. 积分中值定理证平均性质]

- #strong[问题];：证明连续函数在区间上的平均值介于最小最大之间。
- #strong[公式];：$integral_a^b f \( x \) d x = f \( xi \) \( b - a \)$，$xi in \( a \, b \)$。
- #strong[应用];：概率密度平均、不等式证明。

#strong[22. 柯西-施瓦茨积分不等式]

- #strong[问题];：证明 $\[ E \( X Y \) \]^2 lt.eq E \( X^2 \) E \( Y^2 \)$。
- #strong[公式];：$(integral f g)^2 lt.eq integral f^2 integral g^2$
- #strong[应用];：协方差、相关系数、概率不等式。

#strong[23. 切比雪夫不等式（积分证明）]

- #strong[问题];：$P \( \| X - mu \| gt.eq k sigma \) lt.eq 1 / k^2$。
- #strong[公式];：$P \( \| X - mu \| gt.eq t \) lt.eq frac(E \[ \( X - mu \)^2 \], t^2)$
- #strong[应用];：概率界限、随机算法误差分析。

#strong[24. 特征函数求矩]

- #strong[问题];：$phi \( t \) = E \[ e^(i t X) \]$，求 $E \[ X^n \]$。
- #strong[公式];：$E \[ X^n \] = frac(phi^(\( n \)) \( 0 \), i^n)$
- #strong[示例];：正态分布 $phi \( t \) = e^(i mu t - sigma^2 t^2 \/ 2)$，求导得 $mu$ 和 $sigma^2$。
- #strong[应用];：中心极限定理、高阶矩。

#strong[25. 生成函数中的积分]

- #strong[问题];：计算 $integral_0^oo x^n e^(- x) d x$。
- #strong[公式];：$integral_0^oo x^n e^(- x) d x = n !$
- #strong[应用];：指数生成函数、排列组合计数。

#strong[26. 拉普拉斯变换（竞赛极少）]

- #strong[问题];：求解微分方程或概率分布。
- #strong[公式];：$F \( s \) = integral_0^oo f \( t \) e^(- s t) d t$
- #strong[应用];：概率论、信号处理，竞赛基本不考。

这些基本覆盖算法竞赛所需的微积分工具。再多就是纯数学内容，竞赛不会涉及。

