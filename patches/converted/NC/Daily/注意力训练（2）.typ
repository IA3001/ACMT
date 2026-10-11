=== #text("Attention is all you need(2)")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/NC/Daily/注意力训练（2）.md`]

#quote(block: true)[
2026年9月23日
]

===== 【意外】 空间分隔数 的结论（并没有用到）

- d 维空间最多被 n 个 d-1 维物体分为几份

$ f \( d \, n \) = sum_(k = 0)^d binom(n, k) $

例如

- d = 1
  - $f \( d \, n \) = binom(n, 0) + binom(n, 1) = n + 1$
- d = 2
  - $f \( d \, n \) = binom(n, 0) + binom(n, 1) + binom(n, 2)$
- d = 3
  - $f \( d \, n \) = binom(n, 0) + binom(n, 1) + binom(n, 2) + binom(n, 3)$

===== 完全图最大分隔数 （使用 欧拉公式）

#quote(block: true)[
只是题面答案多了个 n
]

- $V$ 点，$E$ 边，$F$ 面
  - $V - E + F = 2$
- 强大的欧拉公式方便我们数 面 的个数，因为
  - $E$ 边最好求
  - $V$ 点稍微好求
    - 需要求交点
  - $F$ 自然算出来
- 所以，不要认为，欧拉公式只是用于高维的图形，二维平面依然可以

$ F_(upright("inside")) = E - V + 1 $

- 先算 边
  - $E = binom(n, 2)$ ?
  - 边真的算对了吗？
  - 错！还有点，交点引发的小边，绝对不可以是算大边！
  - 每有一个交点，显然他就切割了2次边，所以贡献是 2
  - $E = binom(n, 2) + 2 binom(n, 4)$
- 再算点
  - 基本点 $n$
  - 交点（由两条线的交点确定？）
    - 我们不那么枚举
    - 而是枚举，一个四边形，因为一个交点确定对应一个四边形的对角线交点
    - $binom(n, 4)$
  - $V = n + binom(n, 4)$
- 所以
  - $F = binom(n, 2) + binom(n, 4) - n + 1$

#quote(block: true)[
这个题目的答案就是 $F = binom(n, 2) + binom(n, 4) + 1$
]

