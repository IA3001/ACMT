=== #text("Attention is all you need(3)")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/NC/Daily/注意力训练（3）.md`]

#quote(block: true)[
2026年9月26日
]

- 今日伏笔：
  - 三重积分限写错了
  - n m 二维清空为了图方便，没有使用 t = max(n, m)
  -

===== 【高数】球缺体积计算公式

直接三重积分

$ V = integral_(R - h)^R integral_0^(2 pi) integral_0^(sqrt(R^2 - z^2)) rho d rho d theta d z = pi h^2 (R - h/3), quad (0 <= h <= R) $

```cpp
double cal(double R, double h) {
    if (sign(h - R) == 1) return pi * R * R * R * 4 / 3 - cal(R, R*2 - h);
    return pi * h * h * (R - h / 3);
}
```

===== 【强化认知】卡特兰数

- 定义可以是：
  - 1 - n 的数字，按顺序逐个入栈 / 出栈的合法方案数
- 拓展 $C a t a l a n' \( n \) = C a t a l a n \( n \) - C a t a l a n \( n - 1 \)$
  - 表示固定第一个数字 1 入栈立即出栈，所有的方案数

$ C a t a l a n \( n \) = frac(1, n + 1) binom(2 n, n) $

