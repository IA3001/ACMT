#import "../lib.typ": *

#set math.equation(numbering: "(1)")

= 数论自学

#note[
  这也是第一次笔记示范！

  整除是基石 定义 1 命题 1 2\
  进一步形式 定理 1 2 3 命题 3 4 5\
  带余除法和例子 定理 4 例 2 - 5\
]

== 整数的可除性

=== 整除的概念与带余除法

- *Definition 1*

  $ 
    a,b in ZZ and b eq.not 0 , exists q in ZZ, a = q b\
    arrow.double\
    b "is a factor/divisor of" a  "Or"\
    a "is mutiple of" b "Or"\
    b "can divide" a "evenly" "Or"\
    a "can be divided by" b  
  $

- *Proposition 1(命题)*

  Assuming $a,0 eq.not b in ZZ$ then\
  + $b divides 0$;
  + $1 divides a$;
  + When $a eq.not 0$, $a divides a$.

- *Proposition 2*

  Let $a,b,s in ZZ$ with $b eq.not 0$ Then:\
  + if $b divides a$, then $b divides a s$;
  + $b divides a $ iff $-b divides a$.(That is, the divisors of a always occur in pairs.);
  + $b divides a$ iff $b divides |a|$.(That is, $a$ and $|a|$ have exactly the same set of divisors)

- *Proof of Proposition 2*

  Let $a,b,c in ZZ$ with $b eq.not 0$.\
  + $because b divides a$. $therefore exists q in ZZ$, such that $a = b q => a s = b(q s) => b divides a s$.
  + (Necessity)(必要性 前提必须满足自己的推导)

    $because b divides a$. \
    $therefore exists q in ZZ$, such that  $a = b q = (-b)(-q) => -b divides a$.
    
    (Sufficiency)(充分性 前提可以推导出自己)

    $because -b divides a$.\ 
    $therefore exists q in ZZ$, such that $a = (-b)q = b (-q) => b divides a$. 
  + (Necessity)

    $because b divides a$.\
    $therefore exists q in ZZ$, such that $ a = b q => |a| = |b||q|$\
    + if $b>0$, then $|a|=b|q| => b divides |a|$.\
    + if $b<0$, then $|a|=(-b)|q| = b(-|q|) => b divides |a|$\

    (Sufficiency)

    $because b divides |a|$.\
    $therefore exists q in ZZ$, such that $|a| = b q$.\
    + if $a=0$, then $b|0=a$ (Proposition 1).\
    + if $a>0$, then $a=b q => b divides a$.\
    + if $a<0$, then $-a=b q => a = b(-q) => b divides a$.\

- *Theorem 1(整除的传递性)*

  Let $a,b,c in ZZ$ with $b eq.not 0$ and $c eq.not 0$.\
  if $b divides a$ and $c divides b$, then $c divides a$.

- *Theorem 2*

  Let $a,b in ZZ$ be mutiples of $m in ZZ$. Then $a plus.minus b$ is also a mutiple of $m$.

- *Proof of Theorem 2*

  $cases(
    m divides a => exists p in ZZ\, "such that" a = m p,
    m divides b => exists q in ZZ\, "such that" b = m q)
  $\
  
  $=>$

  $a plus.minus b = m p plus.minus m q = m(p plus.minus q) => m divides a plus.minus b$

#example[
  Given $x, y in ZZ$, suppose $5 divides (x-y)$. Prove that $5 divides (3x+2y)$
]

- *Theorem 3*

  if $m divides a_i$ for all $i = 1,2,dots,n$, and $q_i in ZZ$, then $m divides sum_(i=1)^n q_i a_i$

- *Proposition 3*

  + $c divides a and c divides.not b => c divides.not (a plus.minus b)$.\
  + $b divides a and c eq.not 0 => b c divides a c$, Conversely, $b c divides a c and c eq.not 0 => b divides a$.\
  + $b divides a and c divides d => b c divides a d$.\
  + $a = b+c and d divides a and d divides b => d divides c$\
  
- *Proposition 4(立方差/和公式 推广)*

  + $n in NN^+ and a eq.not b => a-b divides a^n - b^n$;\
    
    *Proof:* $a^n - b^n = (a-b)(a^(n-1)+a^(n-2)b+dots+a b^(n-2)+b^(n-1))$ 

  + $n "is odd" and a eq.not -b => a+b divides a^n + b^n$;\

    *Proof:* replace $b$ with $-b$

  + $n "is even" and a eq.not -b => a+b divides a^n - b^n$.\

    *Proof:* $a^n - b^n = (a+b)(a^(n-1)-a^(n-2)b+...+a b(n-2)-b(n-1))$

- *Proposition 5(最大公约数/最小公倍数引入)*

  + $c divides a b and (b,c) = 1 => c divides a$;\
  + $b divides a and c divides a and (b,c)=1 => b c divides a$;\
  + $b divides a and c divides a => [b,c] divides a$.\

  (Proof needs Bezout's Identity)

- *Theorem 4(带余除法)*

  Let $a,b in Z$ with $b>0$.\ 
  Then there exist *unique* integers $q$ and $r$ such that 
  $ a=b q + r, "where" 0 <=r<b $ 
  The integer $q$ is called the *quotient(不完全商)*, and $r$ is called the *remainder(余数)*.

- *Corollary 1(推论)*
  
  Let $a,b in Z$ with $b eq.not 0$.\
  Then there exist *unique* integers $q$ and $r$ such that
  $ a = b q + r. "where" 0<=r<|b| $

- *Definition 2*

  In *Theorem 4*, $q$ is called the *quotient* of $a$ divided by $b$, and $r$ is called the *remainder* of $a$ divided by $b$.

#example[
  In general, among any $n$ consecutive integers, at least one is divisible by $n$.
]

#example[
  Prove that $3 divides n(n+1)(2n+1)$ 
  
  *Proof:* Traverse all remainders.
]

#exercise[
  Prove that:

  + $6 divides n(n+1)(n+2)$
  + $12 divides n(n+1)(n+2)(n+3)$
  + $30 divides (n^5 - n)$
  
  *Proof 3:* $(n^5-n) = (n-1)n(n+1)(n^2 +1)$ and Traverse 5's remainders 
]

#example[
  Find all integers $n$ such that $n-1 divides n^2 + 3n + 2$

  *Solution:* replace $n-1$ with $t$ and simplify the right expression.
]

#exercise[
  Find all integers $n$ such that:

  + $n divides n^2 + 4$ 
  + $n+1 divides n^2 + 5$
  + $n-2 divides n^2 +5n$
  + $n-1 divides n^3 + 5$
]

=== 最大公因数与辗转相除法

#note[
  定义略
]

#note[
  一个重要的定理：

  设 $a,b,c$ 是三个不全为零的整数，且 $a=b q + c (q eq.not 0)$ 则 $a,b$ 与 $b,c$ 有相同的公因数 从而有 $(a,b) = (b,c)$
]

#note[
  补充定理：

  设 $a,b,d in ZZ, d>0$, 若 存在 $s,t in ZZ$ 有 $a s + b t = d$, 且 $d$ 是 $a,b$ 的公因数， 则 $(a,b) = d$

  看起来不好想，其实就是 裴蜀定理 整体乘了个 d， d 就是最大公约数。   
]

#note[
  补充定理：

  设 $a$ 是大于 $1$ 的整数，则 $a$ 的除 $1$ 外的最小正因数 $p$ 一定是质数 并且当 $a$ 为合数时$p<=sqrt(a)$ 
]

=== 质数和算数基本定理

#note[
  补充证明：

  质数有无穷个，设 $N = p_1 p_2 p_3 dots.c p_k + 1$ (一种无限生成大质数的方式)
]

#note[
  费马数 $F_m = 2^(2^m) + 1$ 费马数 $F_0 -- F_4$ 都是素数， 但可能 $F_5$ 往后都不是素数
]

#note[
  梅森数 $M_n = 2^n -1$

  是素数的前几个： 2 3 5 7, 13 17 19, 31, 61

  #table(
      columns: (auto, auto, auto),
  inset: 5pt,
  align: horizon,
  [n],[$M_n$],[分解],
  [*$2$*],[*$M_2$*],[$2^2 - 1 = 3$],
  [*$3$*],[*$M_3$*],[$2^3 - 1 = 7$],
  [*$5$*],[*$M_5$*],[$2^5 - 1 = 31$],
  [*$7$*],[*$M_7$*],[$2^7 - 1 = 127$],
  [$11$],[$M_11$],[$2^11 - 1 = 2047 = 23 times 89$],
  [*$13$*],[*$M_13$*],[$2^13 - 1 = 8191$],
  [*$17$*],[*$M_17$*],[$2^17 - 1 = 131071$],
  [*$19$*],[*$M_19$*],[$2^19 - 1 = 524287$],
  [$23$],[$M_23$],[$2^23 - 1 = 8388607 = 47 times 178481$],
  [$29$],[$M_29$],[$2^29 - 1 = 536870911 = 233 times 1103 times 2089$],
  [*$31$*],[*$M_31$*],[$2^31 - 1 = 2147483647$],
  [$37$],[$M_37$],[$2^37 - 1 = 137438953471 = 223 times 616318177$],
  [$41$],[$M_41$],[$2^41 - 1 = 2199023255551 = 13367 times 164511353$],
  [$43$],[$M_43$],[$2^43 - 1 = 8796093022207 = 431 times 9719 times 2099863$],
  [$47$],[$M_47$],[$2^47 - 1 = 140737488355327 = 2351 times 4513 times 13264529$],
  [$53$],[$M_53$],[$2^53 - 1 = 9007199254740991 = 6361 times 69431 times 20394401$],
  [$59$],[$M_59$],[$2^59 - 1 = 576460752303423487 = 179951 times 3203431780337$],
  [*$61$*],[*$M_61$*],[$2^61 - 1 = 2305843009213693951$],
  )
]

=== 函数[x]{x}

#note[
  新定义函数

  + $[x]$ 是取整函数/高斯函数 小于等于 x 的最大整数
  + ${x} = x - [x] $ 是 x 的小数部分 

  + $[x] <= x < [x]+1$
  + $x-1<[x]<=x$
  + $[x] + [y] <= [x+y]$
  + ${x} + {y} >= {x+y}$
]

#note[
  $n!$ 的标准分解式中 $p$ 的指数 就是 Legendre 定理 
]


== 不定方程
=== 二元一次不定方程

#note[
  补充定理：

  二元一次不定方程 $a x + b y = c$ 有整数解的充要条件是 $d = (a,b) divides c$

  若 $a x + b y = d$ 的一个特解是 $x_0,y_0$ 通解为 $x' = x_0 + b/d t, y' = y_0 - a/d t$ 

  则 原式等同于 两边同时乘以 $c\/d$ 通解为 $ x = c/d x', y = c/d y'$
]

=== 多元一次不定方程
#note[
  推广到多元一次不定方程， 类似的定理都成立 
]

=== 勾股数

#note[
  常见的勾股数\
  3 4 5\
  5 12 13\
  8 15 17\
  
]

#note[
  三元数组 构成勾股数 $x^2 + y^2 = z^2$

  不定方程的整数解满足 
  
  + $x_0,y_0,z_0 > 0$
  + (x_0,y_0) = 1
  + (x_0,y_0) 其中一个是奇数，另一个是偶数(奇奇不存在证法:模4不同余,奇数的平方模4等于1)

]

#note[
  啊？？？ *勾股数的终极解决方案*

  适合条件
  $ x,y,z>0, (x,y) = 1, 2 divides x $
  的*一切正整数解* 都可以用下列公式表示出来 
  $ x = 2 a b, y = a^2 - b^2, z = a^2 + b^2 $
  
  所有整数解为 
  $ (plus.minus 2 a b t  , plus.minus (a^2-b^2)t, plus.minus(a^2+b^2)t) $
  $ (plus.minus (a^2-b^2), plus.minus 2 a b t   , plus.minus(a^2+b^2)t) $
]

#note(title:"推论")[
  单位圆周上的一切有理点可以表示成
  $ (plus.minus (2 a b)/(a^2 + b^2), plus.minus (a^2 - b^2)/(a^2 + b^2)) $ 
  及  
  $ (plus.minus (a^2 - b^2)/(a^2 + b^2), plus.minus (2 a b)/(a^2 + b^2)) $ 

]

== 同余

=== 同余的概念及其基本性质

#note[
  同余关系是 *等价关系*: 满足 *自反* *对称* *传递* 

  显然可以自由地进行 加法 减法 乘法

  对于 *除法* 是可以的 $a/gcd(a,b) equiv b/gcd(a,b) pmod(m)$

  并且 
  $ a equiv b pmod(m) <=> a/gcd(a,b,m) equiv b/gcd(a,b,m) pmod(m/gcd(a,b,m)) $
]

#note(title:"补充")[
  $ a equiv b pmod(m_i), i = 1,2,dots.c,k => a equiv b pmod([m_1,m_2,dots.c,m_k]) $
]

#note(title:"补充")[

  $ a equiv b pmod(m), d divides m, d>0 => a equiv b pmod(d) $
]

#note(title:"补充")[
  $ a equiv b pmod(m) => (a,m) = (b,m) $ 
  因而若 $d$ 能整除 $m$ 及 $a,b$ 二数之一 则 $d$ 必定能整除 $a,b$ 中的另一个
]

#note(title:"可整除性特征")[
能被 3(9) 整除的 充要条件是 它的十进制数码的和能被 3(9) 整除
]

#note(title:"整除特性 更新了！！！")[
  千进制数 
  $ a = a_n 1000^n + a_(n-1)1000^(n-1) + dots.c + a_0, 0<= a_i < 1000 $
  则 7 (11、13) 整除 $a$ 充要条件是 7(11、13) 整除 
  $ (a_0 + a_2 + dots.c) - (a_1 + a_3 + dots.c) = sum_(i=0)^n (-1)^i a_i $ 
]

#note(title:"又是一堆")[
  + 能被 $2$ 整除 $<=>$ 末位数字是 偶数 (10)
  + 能被 $5$ 整除 $<=>$ 末位数字是 $0$ 或 $5$ (10)
  + 能被 $4$ 或 $25$ 整除 $<=>$ 末 $2$ 位数字能被 $4$ 或 $25$ 整除 (100)
  + 能被 $8$ 或 $125$ 整除 $<=>$ 末 $3$ 位数字能被 $8$ 或 $125$ 整除 (1000)
  + 能被 $99$ 整除 $<=>$ 两位一段 所有数段之和能被 $99$ 整除 (百进制 取模得1)
]

#note(title:"新符号")[
  $overline(5 a b) = 5 times 100 + a times 10 + b$ 表示数位的 *10进制* 拼接
]

#note(title:"弃9法验证计算正确性")[
  一个数 与 它的各个数位的和 关于 $9$ 同余

  排错性的原因:
  命题 
  $ a b = p => a b equiv p pmod(m) $ 
  的 逆否命题
  $ a b equiv.not p pmod(m) => a b eq.not p $ 
]

=== 剩余类和完全剩系

#note(title:"定理 1")[

设 $m in ZZ_+$ 的 全部整数 可以分成 $m$ 个集合 记作 $K_0, K_1, dots.c, K_(m-1)$ 其中 $K_r (r=0, 1, dots.c, m-1)$ 是由一切形如 $q m + r (q in ZZ)$ 的整数组成的， 这些集合具有下列性质:

+ 每一个整数必须包含而且仅在上述的一个集合里面
+ 两个整数同在一个集合的充要条件是这两个整数对模 $m$ 同余 

+ $K_0, K_1, dots.c, K_(m-1)$ 叫做模 $m$ 的剩余类
+ 一个剩余类中任一数叫做*它同类的数的剩余*
+ 若 $a_0, a_1, dots.c, a_(m-1)$ 是 $m$ 个 两两不在同一剩余类中的整数， 则 $a_0, a_1, dots.c, a_(m-1)$ 叫做 模 $m$ 的一个 *完全剩余系*

注意： 
+ *剩余类* 是一个无穷大的集合
+ *完全剩余类* 是含 $m$ 个剩余类的集合 
+ *完全剩余系* 是一个 含 $m$ 个数的集合 

其实 (就是模 等价关系 限定的一个划分)
]

=== 简化剩余系与欧拉函数

#note(title:text("欧拉函数"))[
    设 $n in ZZ_+, 在 0, 1, 2, dots.c, n-1$ 中 与 $n$ *互素* 的数的 *个数* 叫做 $n$ 的*欧拉函数*， 记作 $phi(n)$ 

    欧拉函数是 $ZZ_+ -> ZZ_+$ 的函数

    设 $phi(n)$ 是 欧拉函数，则

    + $phi(n) = 1$ 当且仅当 $n=1,2$;
    + $phi(n)>=2$ 当且仅当 $n>=3$;
    + 欧拉函数 不是单调函数;
    + 若 $p$ 是素数 $phi(p) = p-1$;
    + 若 $p$ 是素数，则 $phi(p^n) = p^n - p^(n-1)$.     
]

#note(title:text("既约剩余系"))[
  + 如果一个模 $m$ 的剩余类里面 的数 与 $m$ 互素， 就把它叫做一个*与 $m$ 互素的剩余类*

  + 在与模 $m$ 互素的全部剩余类中， 从每一个各取一数所做成的集合，叫做模 $m$ 的一个*既约剩余系*。
]

#note(title:text("定理1"))[
  + 模 $m$ 的剩余类 与模 $m$ 互素的 *充分必要条件* 是 此类中 有一个数 与 $m$ 互素，因此 与 模 $m$ 互素的剩余类的个数是 $phi(m)$， 模 $m$ 的每一既约剩余类 是由 与 $m$ 互素的 $phi(m)$ 个对模 $m$ 不同余的整数组成的
]

#note(title:text("定理 2"))[
  若 $a_1, a_2, dots.c, a_(phi(m))$ 是 $phi(m)$ 个与 $m$ 互素的数， 并且两两对模 $m$ 不同余， 则 $a_1, a_2, dots.c, a_(phi(m))$ 是 模 $m$ 的一个既约剩余系 
]

#note(title:text("推论 1"))[
  $a_1, a_2, dots.c, a_phi(m)$ 是 模 $m$ 的一个既约剩余系 当且仅当 对任意的 $i,(a_i,m)=1$， 对任意的 $i eq.not j,a_i equiv.not a_j pmod(m)$
]

#note(title:text("推论 2"))[
  $a_1, a_2, dots.c, a_phi(m)$ 是 模 $m$ 的一个既约剩余系 当且仅当 $a_1, a_2, dots.c, a_phi(m)$ 是模 $m$ 的一个完全剩余系与 $m$ 互素的整数组成
]

#note(title:text("推论 3 奇怪的定义"))[
  $x$ 通过 模 $m$ 的即约剩余系 当且仅当 $x$ 通过模 $m$ 的完全剩余系，且对任意的 $i$， $(x_i,m)=1$.

  唉，别人也怀疑这个定义， 我觉得应该是 $x$ 序列包含了 模 $m$ 的完全剩余系??? 
]

#note(title:text("定理 3"))[
  若 $(a,m) =1$ $x$ 通过 模 $m$ d 既约剩余系， 则 $a x$ 通过 模 $m$ 的既约剩余系
  
  MD! 老师不给看 完全剩余系的讲解 
  
  意思可能就是 一个完全剩余系都 乘上一个 与 $m$ 互质的数 会得到一个新的 完全剩余系 这个置换 映射很迷 

  既约剩余系同理 
]

#note(title:text("定理 4 剩余系与欧拉函数的平行关系"))[
  若 $m,n$ 是两个 互素的正整数 $x,y$ 分别通过模 $m,n$ 的即约剩余系， 则 $n x + m y$ 通过模 $m n$ 的即约剩余系

  类似 笛卡尔积 吧

  所以 新的 序列包含了正交后的性质 
]

#note(title:"欧拉函数性质")[
  若 $m,n$ 是两个 *互素的* 正整数， 则 $phi(m n) = phi(m)phi(n)$
]

#note(title:text("定理 5 欧拉函数公式"))[
  设 $a = p_1^(alpha_1)p_2^(alpha_2)dots.c p_k^(alpha_k)$ 则
  $ phi(a) = a(1-1/p_1)(1-1/p_2)dots.c(1-1/p_k) $
]

=== 欧拉定理 费马定理 及其对循环小数的应用

#note(title:text("定理 1 欧拉定理"))[
  设 $m$ 是大于 $1$ 的整数， $(a,m)=1$ 则 
  $ a^(phi(m)) equiv 1 pmod(m) $

  证明： 既约剩余系的应用 MD 
]

#note(title:text("推论 1 费马小定理"))[
  若 $p$ 是素数 $a^p equiv a pmod(m)$

  证明：分类讨论 
  + 要么 $p divides a$ 显然 $0 equiv 0$
  + 要么 $p divides.not a$ 即 $(p,a)=1$ 用欧拉定理
]

#note(title:text("费马小定理的应用"))[
  + 设 $a in ZZ_+$， 则 $a^5$ 与 $a$ 的个位数相同

    WC 欧拉定理 不只是来个系数 $alpha : 1$ 两边还可以继续平方 继续拼凑！ 

  + 进一步 设 $a,m in ZZ_+$， 则 $a^(m+4), a^m$ 的各位数字相同

    提取出来 $a^5 - a$ 就模 $10$ 同余了！

  正整数的正整数次幂的*个位*数字是以 *$4$ 为周期* 循环变化的

  费马小定理专门可以解 尾数问题/末尾数问题/个位数字问题
]

=== 循环小数 

#note(title:text("循环小数的定义"))[
  小数 0-1 
  + 有限小数:0.1145
  + 循环小数
    + 纯循环小数:0.787878...(一开始就循环)
    + 混循环小数:0.91787878...(一开始不是循环)
  + 无限不循环小数:0.78778877788877778888...(没有循环节)
]

#note(title:text("定理 2"))[
  有理数 $a/b, 0<a<b, (a,b) = 1$ 能表示成 *纯循环小数* 的 *充分必要条件* 是 $(b,10) = 1$  
] 

#note(title:text("定理 3"))[
  若 $a/b$ 是有理数， 其中 $0<a<b,(a,b) = 1,b=2^alpha 5^beta b_1,(b_1,10)=1,b_1 eq.not 1$， $alpha,beta$ 不全为 $0$， 则 $a/b$ 可以表示成混循环小数，其中不循环的位数是 $mu = max(alpha,beta)$
]

== 同余式

=== 同余式和同余式的解
 
#note(title:text("定义 1 同余式"))[
  设 $m in ZZ_+ f(x) = a_x x^n + a_(n-1) x^(n-1) + dots.c + a_1 x + a_0 , a_i in ZZ$, 则 
  $ f(x) equiv 0 pmod(m) $
  叫做模 $m$ 的同余式， 若 $a_n equiv.not 0 pmod(m)$, 则 $n$ 叫做上述同余式的*次数*
]

#note(title:text("命题 1"))[
  设 $f(x) equiv 0 pmod(m)$ 是一个模 $m$ 的同余式, $a in ZZ, K_a 为 a$ 所在的模 $m$ 的剩余类\
  如果 $f(a) equiv 0 pmod(m),$ 则对任意的 $b in K_a$, 都有 $f(b) equiv 0 pmod(m)$
]

#note(title:text("定义 2"))[
  若 $a$ 是使得 $f(a) equiv 0 pmod(m)$ 成立的一个整数\
  则称 $a$ 所在的 模 $m$ 的剩余类 $K_a$ 为同余式 $f(x) equiv 0 pmod(m)$ 的一个(类)解, 记为 $x equiv a pmod(m)$
]

=== 一次同余式的解

#note(title:text("定理 1"))[
  一次同余式 $a x equiv b pmod(m), a equiv.not 0 pmod(m)$ 
  当 $(a,m) = 1$ 时有唯一解 
]

#note(title:text("定理 2"))[
  设 $(a,m) = d$, 则一次同余式 
  $ a x equiv b pmod(m), a equiv.not 0 pmod(m) $ 
  有解的充分必要条件时 $d divides b$, 而且当 有解时, 它有 $d$ 类解.
]


=== 一次同余式组的解（孙子定理）

#note[
  就是中国剩余定理
]

#note(title:text("命题 1"))[
  已知 $a = m q + r$, 则同余式 $a x equiv b pmod(m)$ 与 $r x equiv b pmod(m)$ 同解.
]

#note(title:text("命题 2"))[
  设 $a equiv b pmod(m), m_1 divides m$, 则 $a equiv b pmod(m)$  
]

#note(title:text("命题 3"))[
  设 $x equiv a + k m pmod(m)$, 则 $x equiv a pmod(m)$
]

#note(title:text("命题 4"))[
  设 $(m_1,m_2) = 1$, 若 $a equiv b pmod(m_1), a equiv b pmod(m_2)$, 则 $a equiv b pmod(m_1 m_2)$
]

#note(title:text("定理 1"))[
  设 $m_1,m_2,dots.c,m_k$ 是 $k$ 个两两互素的正整数, $m=m_1 m_2 dots.c m_k, m = m_i M_i, i = 1,2,dots.c,k$, 则同余式组的解是:
  $ x equiv M_1 ' M_1b_1 + M_2 ' M_2 b_2 + dots.c + M_k ' M_k b_k pmod(m), $
  其中 $M_i ' M_i equiv 1 pmod(m_i), i = 1,2,dots.c,k$.
]

=== 高次同余式的解的情况

#note[
  求解 $n$ 元一次方程 $f(x) equiv 0 pmod(m)$
]

#note[
  我勒个穷举法
]

#note[
  解决两类问题:
  
  本节内容:
  + m 素数幂因子相乘
  + m 是素数数幂

  + 而 $p$ 比较大的时候 to be continued
]

#note(title:text("定理 1"))[
  若 $m_1, m_2, dots.c, m_k$ 是 $k$ 个两两互素的正整数, $m=m_1 m_2, dots.c, m_k$ 则同余式 
  $ f(x) equiv 0 pmod(m) quad (1) $
  与同余式组 
  $ f(x) equiv 0 pmod(m_i), i = 1,2, dots.c, k quad (2) $
  等价(即任意适合(1)的整数都适合(2) 式，反之也成立). 并且若用 $T_i$ 表示 $f(x) equiv (mod m_i), i = 1,2,dots.c, k$ 对模 $m_i$ 的解数, $T$ 表示 (1) 对模 $m$ 的解数, 则
  $ T = T_1 T_2 dots.c T_k. $

  这么好！
]

#note[
  设 $alpha$ 式大于等于 $2$ 的正整数, 则适合 
  $ f(x) equiv 0 pmod(p^alpha),p "为素数". quad (6) $
  的每一个整数都适合同余式 
  $ f(x) equiv 0 pmod(p^(alpha -1)) quad (6') $
  进而适合 $(6)$ 的每一个整数都适合同余式.
  $ f(x) equiv 0 pmod(p) quad (7) $ 
  因此欲求 $(6)$ 的解, 可以从 $7$ 式的解出发.

  例子： 求 $(mod 27)$ 先验证 $0,1,2 pmod(3)$ 得到 $r_1, r_2, dots.c, r_k $ 再验证 $r_1, r_2, dots.c, r_k pmod(9)$ 最后得到 $r_1, r_2, dots.c, r_k (mod 27)$ 
]

#note(title:text("推论 1 泰勒公式在 数论中的接入"))[
  设 $f(x)$ 是一个 $n$ 次多项式, 则 $f(x)$ 在点 $x_0$ 处的泰勒展开式为:
  $ f(x) = f(x_0) + (f'(x_0))/(1!)(x-x_0) + (f''(x_0))/(2!)(x-x_0)^2 + dots.c + (f^((n))(x_0))/(n!)(x-x_0)^n $
  因为 $f^((n+1))(x) = 0$ 
]

#note(title:text("命题 2 泰勒展开式的系数"))[
  设 $f(x)$ 是一个 $n$ 次整系数多项式, $k$ 式一个小于等于 $n$ 的正整数, 则对于任意的整数 $x_0$, $(f^((k))(x_0))/(k!)$ 是一个整数
]

#note(title:text("定理 2"))[
  设 
  $ x equiv x_1 pmod(p) $
  即 
  $ x = x_1 + p t_1 , t_1 in ZZ quad (8) $
  是 (7) 的解 并且 $p divides.not f'(x_1)$ ($f'(x)$ 是 $f(x)$ 的导函数), 则 (8) 刚好给出 (6) 的一解(对模 $p^alpha$ 来说):
  $ x=x_alpha + p^alpha t_alpha, t_alpha in ZZ $
  即 $x equiv x_alpha pmod(p^alpha)$, 其中 $x_alpha equiv x_1 pmod(p)$  

  有点看不懂了, 这是 $p$ 不整除 即不互素 导数 就可以直接得到 一个公共的解吗 

  这里类似 一层一层解出来 t 回代 t 最终得到 $x = f(t_alpha)$ 

  求解方法好像是 
  + 先求 $p$ 的情况的所有解 $x(t_1)$
  + 然后 将 $p$ 的解代入 $f(x)$ 方程算出 exp1 
  + 将 $p$ 的解代入 $f'(x)$ 算出来 exp2
  + 将 $f(x)$ 进行 二阶展开 代入 exp1 exp2 右边 $equiv p^2$
  + 化简得到 $t_1(t_2)$...

]

=== 素数模同余式的解

#note(title:"举例")[
  素数模的同余式 $f(x) equiv 0 pmod(p)$ 
  当次数很大的时候 不适合 穷举
]

#note(title:text("定理 1"))[
  设 $p$ 是素数, 则同余式 
  $ f(x) = a_n x^n + a_(n-1) x^(n-1) + dots.c + a_0 pmod(p), a_n equiv 0 pmod(p), quad (1) $
  与一个次数不超过 $p-1$ 的素数模 $p$ 的同余式等价
  
  用法: 使用大除法消去整个的 $(x^p - x)$
]

#note(title:text("定理 2"))[
  设 $k<=n$, 而 $x equiv alpha_i pmod(p) quad (i = 1,2, dots.c, k)$ 是 (1) 的 $k$ 个不同解, 则对任何整数 $x$ 来说, 
  $ f(x) equiv (x-alpha_1)(x-alpha_2)dots.c(x-alpha_k)f_k (x) pmod(p), quad (2) $
  其中 $f_k (x)$ 是首项系数为 $a_n$ 的 $n-k$ 次多项式 
]

#note(title:text("定理 3"))[
  + 对任何整数 $x$ 来说

    $ x^(p-1) - 1 equiv (x-1)(x-2)dots.c(x-(p-1)) pmod(p) $

  + (威尔逊定理) $(p-1)! + 1 equiv 0 pmod(p)$
]

#note(title:text("定理 4"))[
  同余式 (1)$f(x) = a_n x^n + a_(n-1) x^(n-1) + dots.c + equiv 0 pmod(p)$ 的解数不超过它的次数.
]

#note(title:text("命题 1"))[
  同余式 (1)$f(x) = a_n x^n + a_(n-1) x^(n-1) + dots.c + a_0 equiv 0 pmod(p)$ 总和某个同次数的首一同余式$(a_n = 1)$等价
]

#note(title:text("定理 5"))[
  若 $n <= p$, 则同余式 
  $ f(x) equiv 0 pmod(p),f(x) = x^n + a_(n-1)x^(n-1) + dots.c + a_0 quad (3) $
  有 $n$ 个解的充分必要条件是 $f(x)$ 除 $x^p - x$ 所得余式的一切系数都是 $p$ 的倍数. 
]


== 二次同余式

=== 一般二次同余式

#note(title:text("定义 1"))[
  式子 
  $ a x^2 + b x + c equiv 0 pmod(m), a equiv.not 0, pmod(m) quad (1) $
  称为 *二次同余式*
]

#note(title:text("注解 1"))[
  设模 $m$ 的标准分解式是 $m = p_1^(alpha_1) dots.c p_k^(alpha_k)$, 则由 高次剩余式的解数和解法 的定理1(1) 式有解的充分必要条件是下列每一个同余式有解:
  $ a x^2 + b x + c equiv 0 pmod(p_i^(alpha_i)), i = 1,2,dots.c,k. $
  所以我们下面转而讨论以素数幂为模的同余式:
  $ f(x) equiv 0 pmod(p^alpha), f(x) = a x^2 + b x + c. quad (2) $ 
]

#note(title:text("定义 2"))[
  设 $p, a$ 是两个整数, $p>0$, 如果 $p^r divides a$, 但 $p^(r+1) divides.not a$, 则称 $p^r$ 恰整除 $a$, 记作 $p^r bar.v.double a$
]

#note(title:text("命题 1"))[
  对于二次同余式 (2) $a^x + b x + c equiv 0 pmod(p^alpha)$,
  + 若 $p^alpha divides (a,b,c)$, 则任一整数都满足 (2);
  + 若 $p^r bar.v.double (a,b,c), 2<r<alpha$, 则 (2) 式可化为一个形如 (2) 的同余式, 但 $p divides.not (a,b,c)$.  
]

#note(title:text("命题 2"))[
  设 $p divides.not (a,b,c)$, 则二次同余式 (2)$a x^2 + b x + c equiv 0 pmod(p^alpha)$ 的解的情况为:(五种完全分类)
  + 若 $p divides a, p divides b$, 但 $p divides.not c$, 则 (2) 式无解;
  + 若 $p divides a, p divides.not b$, 则 (2) 式有解;
  + 若 $p divides.not a,p>2$, 则 (2) 式有解的充分必要条件:\
    $ y ^2 - A equiv 0 pmod(p^alpha) quad (4) $
    有解;($ y = 2 a x + b , A = b^2 - 4 a c$)
  + 若 $p=2 divides.not a, 2 divides.not b$, 则 (2) 式有解的充分必要条件是 $2 divides c$.
  + 若 $p=2 divides.not a,2 divides b$, 则 (2) 式有解的充分必要条件式 (4) 式有解.($y = a x + b_1, A = b_1^2 - a c, b = 2 b_1$ )
]

#note(title:text("命题 3"))[
  若 $p^alpha divides A$, 则同余式 (4)$y^2 - A equiv 0 pmod(p^alpha)$ 有解.
  注意:
  $ y = p^r t , alpha/2 <= r < alpha,  p^r in ZZ $ 
]

=== 奇素数的平方剩余与平方非剩余

#note[
  讨论形如 
  $ x^2 equiv a pmod(p), (a,p) = 1 quad (1) $
  的同余式的解
]

#note(title:text("注解 1"))[
  模 $p$ 的平方剩余和平方非剩余构成模 $m$ 的既约剩余系: $1,2,dots.c,p-1$, 共偶数多个(p-1)
]

#note(title:text("定理 1 欧拉判别条件"))[
  若 $(a,p) = 1$\
  则 $a$ 是模 $p$ 的平方剩余的充分必要条件是 
  $ a^((p-1)/2) equiv 1 pmod(p); quad (2) $
  而 $a$ 是模 $p$ 的平方非剩余的充分必要条件是
  $ a^((p-1)/2) equiv -1 pmod(p); quad (3) $
  且若 $a$ 是模 $p$ 平方剩余, 则 (1) 式恰有二解.

  草, 证明看困了, 举个例子吧
  + $p=5$
  + 则可以穷举\
    $0^2 equiv 0 pmod(5)$\
    $1^2 equiv 4^2 equiv 1 pmod(5)$\
    $2^2 equiv 3^2 equiv 4 pmod(5)$\
  + 所以 $0,1,4$ 在 $5$ 的平方剩余系中 
  + 而根据欧拉判别条件 因为 $5$ 与 除了 $0$ 以外的数互质
  + 那么验证\
    $1^((5-1)/2) equiv 1 pmod(5)$\
    $4^((5-1)/2) equiv 1 pmod(5)$\
  + 而\
    $2^((5-1)/2) equiv -1 pmod(5)$\
    $3^((5-1)/2) equiv -1 pmod(5)$\
]

#note(title:text("定理 2"))[
  模 $p$ 的既约剩余系中平方剩余与平方非剩余的个数各为 $(p-1)/2$ 个, 而且 $(p-1)/2$ 个平方剩余分别与序列 
  $ 1^2,2^2,dots.c,((p-1)/2)^2 quad (4) $
  中之一数同余, 且仅与一数同余 
  
  计算技巧:*只需计算前一半* $(p-1)/2$ 个即可知道有哪些平方剩余
]

=== 勒让德符号

#note(title:text("定义 1"))[
  设 $p$ 是一个*奇*素数, $a$ 式任意一个整数, 定义 
  $ (a/p) = cases(
    1\, & a "是模" p "的平方剩余",
    -1\,& a "是模" p "的平方非剩余",
    0\, &    p divides a.
  ) $
  并称 $(a/p)$ 为*勒让德符号*, 读作 $a$ 对 $p$ 的勒让德符号.
  + $(a,p)=1$ 有解
  + $(a,p)=1$ 无解
  + $a=0$ 
]

#note(title:text("注解 1"))[
  + 勒让德符号是一个数论函数是一个(定义域和陪域都是整数集的函数)
  + 由勒让德符号的定义可以看出, 如果能很快的算出它的值, 那么也就会立即直到同余式 $x^2 equiv a pmod(p)$ 有解与否.
]

#note(title:text("命题 1 2 勒让德符号的几个简单性质"))[  
  + $ (a/p) equiv a^((p-1)/2) pmod(p) quad (1) $
  + $ (1/p) = 1 quad (2) $
  + $ (-1/p) = (-1)^((p-1)/2) quad (3) $
]

#note(title:text("推论 1"))[
  + 若 $p$ 是 $4m+1$ 形式的素数, 则 $-1$ 是模 $p$ 的平方剩余;
  + 若 $p$ 是 $4m+3$ 形式的素数, 则 $-1$ 是模 $p$ 的平方非剩余.
]

#note(title:text("命题 3"))[
  若 $a equiv a_1 pmod(p)$, 则
  $ (a/p) = (a_1/p) quad (4) $
]

#note(title:text("命题 4"))[
  + $ ((a_1 a_2 dots.c a_n)/p) = (a_1 / p)(a_2 / p)dots.c(a_n / p) quad (5) $
  + $ ((a b^2)/ p) = ( a/ p), p divides.not b $
]

#note(title:text("定理 1"))[
  + $ (2/p) = (-1)^((p^2-1)/8); quad (7) $
  + 若 $(a,p) = 1, 2 divides.not a$, 则\
    $ (a/p) = (-1)^(sum_(k=1)^((p-1)/2)[(a k)/p]) $
]

#note(title:text("推论 2"))[
  + 当 $p=8m plus.minus 1$ 时, 2 是平方剩余
  + 当 $p=8m plus.minus 3$ 是, 2 是平方非剩余
]

#note(title:text("引理 1"))[
  设 $(a,p)=1,a k (k=1,2,dots.c,(p-1)/2)$ 对模 $p$ 的最小非负剩余是 $r_k$, 若大于 $p/2$ 的 $r_k$ 个数是 $m$, 则
  $ (a/p) = (-1)^m. $
]

#note(title:text("定理 2 二次翻转定律"))[
  若 $p,q$ 都是奇素数, $(p,q)=1$, 则 
  $ (q/p) = (-1)^((p-1)/2 dot (q-1)/2) (p/q). quad (9) $
]

=== 雅可比符号

#note(title:text("定义 1"))[
  设 $m$ 是一个大于 $1$ 的*奇数*, $a$ 是任意一个整数, 且 $m = p_1 p_2 dots.c p_r$, $p_i$ 是素数, 定义
  $ (a/m) = (a/p_1) (a/p_2) dots.c (a/p_r), quad (1) $
  并称 $(a/m)$ *雅可比符号*, 读作 $a$ 对 $m$ 的雅可比符号, 这里 $(a/p_i)$ 是 $a$ 对 $p_i$ 的勒让德符号.
]

#note(title:text("注解 1"))[
  + 雅可比符号 可以视为 勒让德符号 的自然的推广.
  + 5.3 节 命题 5 表明 勒让德符号与 二次同余式 由密切的关系, 但是雅可比符号不如此.
    $ 
    (a,p) = 1 "则"\
    (a/p) = 1 <=> x^2 equiv a pmod(p) "有解"\
    (a/p) = -1 <=> x^2 equiv a pmod(p) "无解"
    $
]

#note(title:text("命题 1"))[
  若 $a equiv a_1 pmod(m)$, 则 
  $ (a/m) = (a_1/m). quad (2) $
]

#note(title:text("命题 2"))[
  $(1/m) = 1$.
]

#note(title:text("引理 1"))[
  若 $2 divides.not m, m = p_1 p_2 dots.c p_r$, 则 
  $ (m-1)/2 = (p_1-1)/2 + (p_2-1)/2 + dots.c + (p_r-1)/2 + 2N, $
  $ (m^2-1)/8 = (p_1^2 - 1)/8 + (p_2^2 - 1)/8 + dots.c + (p_r^2-1)/8 + 2N', $
  其中 $N,N'$ 是整数.
]

#note(title:text("命题 3"))[
  $ ((-1)/m) = (-1)^((m-1)/2), quad (4) $
]

#note(title:text("命题 4"))[
  + $ ((a_1 a_2 dots.c a_n )/m) = (a_1/m)(a_2/m)dots.c (a_n/m). quad (5) $
  + $ ((a b^2)/ m) = (a/m), (b,m) = 1 quad (6) $
]

#note(title:text("命题 5"))[
  $ (2/m) = (-1)^((m^2-1)/8) quad (7) $
]

#note(title:text("命题 6"))[
  设 $n,m$ 都是奇数
  $ (n/m) = (-1)^((m-1)/2 dot (n-1)/2) (m/n) quad (8)  $
]

#note(title:text("勒让德 与 雅可比 对比"))[
  + 分母 $p$: 奇素数(勒让德/雅可比) 非素奇数(雅可比)
  + 二次反转 $q,p, m,n$: $p,q$ 奇素数且互质(勒让德) $m,n$ 奇数(雅可比)
]

=== 合数模的情形

#note(title:text(""))[
  将讨论 合数模同余式 
  $ x^2 equiv a pmod(m), (a,m) = 1, m = 2^alpha p_1^(alpha_1) p_2^(alpha_2) dots.c p_k^(alpha_k) quad (1) $
]

#note(title:text("注解 1"))[
  设 $m = 2^alpha p_1^(alpha_1) p_2^(alpha_2) dots.c p_k^(alpha_k)$, 则 (1) 式 有解的充要条件是同余式组
  $ x^2 equiv a pmod(2^alpha), x^2 equiv a pmod(p_i^(alpha_i)), i = 1,2,dots.c,k quad (2) $
  有解, 并且 $(1)$ 的解数 等于 (2) 中各式解数的乘积.
] 

#note(title:text("定理 1"))[
  $ x^2 equiv a pmod(p^alpha), alpha >0, (a,p) = 1 quad (3) $ 
  有解的充分必要条件式 $(a/p) = 1$, 并且 在有解的情况下, (3) 式的解数是 2. 
]

#note(title:text("定理 2"))[
  设 $alpha > 1$, 则
  $ x^2 equiv a pmod(2^alpha), (a,2)=1 quad (4) $
  有解的必要条件是:
  + 当 $alpha =2$ 时, $alpha equiv 1 pmod(4)$
  + 当 $alpha >=3$ 时, $alpha equiv 1 pmod(8)$
  若上述条件成立, 则 (4) 式有解, 且当 $alpha = 2$ 时, 有两个解, $当 alpha >=3$ 时, 有 $4$ 个解.
]

#note(title:text("定理 3"))[
  同余式 
  $ x^2 equiv pmod(m), m = 2^alpha p_1^(alpha_1) p_2^(alpha_2) dots.c p_k^(alpha_k), (a,m) = 1 $
  有解的必要条件是: 
  + 当 $alpha = 2$ 时, $alpha equiv 1 pmod(4)$;
  + 当 $alpha>=3$ 时, $alpha equiv 1 pmod(8)$, 并且 $(a/p_i) = 1$.
  
  若上述条件成立, 则有解并且
  + 当 $alpha = 0 "或" 1$ 时, 解数是 $2^k$;
  + 当 $alpha = 2$ 时, 解数是 $2^(k+1)$;
  + 当 $alpha >= 3$ 时, 解数是 $2^(k+2)$.
]

== 原根

=== 指数及其基本性质

#note[
  讨论高次同余式 
  $ x^n equiv a pmod(m) $
  需要引入 *原根* 和 *指标* 两个概念
]

#note(title:text("定义 1 指数 原根"))[
  若 $m > 1, (a,m) = 1$, 使得同余式 $a^gamma equiv 1 pmod(m)$ 成立的最小正整数 $gamma$ 叫做 $a$ 对模 $m$ 的*指数*.
  
  若 $a$ 对模 $m$ 的指数等于 $phi(m)$, 则 $a$ 叫做模 $m$ 的一个*原根*
]

#note(title:text("定理 1"))[
  若 $a$ 对 $m$ 的指数是 $delta$, 则 $1 = a_0, a_1,dots.c ,a^(delta-1)$ 对模 $m$ 两两不同余.
]

#note(title:text("定理 2"))[
  若 $a$ 对模 $m$ 的指数为 $delta$, 则 $a^gamma equiv a^(gamma') pmod(m)$ 的充分必要条件是 
  $ gamma equiv gamma' pmod(delta) $ 
  特别地 $a^gamma equiv 1 pmod(m)$ 的充分必要条件是 
  $ delta divides gamma $ 
]

#note(title:text("推论 1"))[
  若 $a$ 对模 $m$ 的指数为 $delta$, 则 $delta divides phi(m)$.
]

#note(title:text("推论 2"))[
  设 $0<a<b, (a,b)=1,b=2^alpha 5^beta b_1, (b_1,10) = 1, b_1 equiv.not 1$, 若将有理数 $a/b$ 化成循环小数, 则此循环小数的循环节的长度 $delta divides phi(b_1)$.
]

#note(title:text("定理 3"))[
  若 $x$ 对模 $m$ 的指数为 $a b,a>0,b>0$, 则 $x^a$ 对模 $m$ 的指数是 $b$.
]

#note(title:text("定理 4"))[
  若 $x$ 对模 $m$ 的指数为 $a$, $y$ 对模 $m$ 的指数为 $b$, 并且 $(a,b) = 1$, 则 $x y$ 对模 $m$ 的指数是 $a b$.
]

=== 原根存在的条件

#note(title:text("命题 1"))[
  设 $a,m > 1$ 都是整数, $a = m q + r$, 则 $a$ 对模 $m$ 的指数等于 $r$ 对模 $m$ 的指数.
]

TO DO 无老师不更新了 555
