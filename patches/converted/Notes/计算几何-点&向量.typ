==== #text("计算几何-点&向量")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/Notes/计算几何-点&向量.md`]

#quote(block: true)[
点&向量 相关 （点为最大维度）

点&向量 是计算几何的基础，所以在这里介绍一下首先有这些

- `using db = long double;`
- `const db eps = 1e-12l;`
- `int sign(db x)`
- `bool operator==(Vec / Seg / Circle) const`
]

- 点&向量 创建
  - 属性 Vec{db x=0, db y=0} （默认唯一构造）
- 点&向量 本身
  - 数乘
  - 单位化
  - 射线化（无限延伸至在题目中可以视作射线方向）
    - 这个非常重要吗？
- 点 与 点 关系
  - 点 与 点 距离
- 向量 与 向量 关系（含初步判断）
  - 向量 与 向量 夹角
  - 向量 加减 -\> 向量
  - 向量 内积 -\> 数值
  - 向量 在 向量 上 投影（投影长度 / 投影向量）
  - 向量 叉积 -\> 数值

===== 点&向量 创建

二维点和向量统一用 `Vec` 表示：点是位置，向量是位移。坐标比较使用统一的 `sign`，避免在不同函数里各写一套浮点判零。

====== Vec

```cpp
#include <bits/stdc++.h>
using namespace std;

using db = long double;
const db eps = 1e-12L;

int sign(db x) {
    if (x > eps) return 1;
    if (x < -eps) return -1;
    return 0;
}

struct Vec {
    db x = 0, y = 0;

    Vec() = default;
    Vec(db x, db y) : x(x), y(y) {}

    Vec operator+(Vec b) const { return Vec(x + b.x, y + b.y); }
    Vec operator-(Vec b) const { return Vec(x - b.x, y - b.y); }
    Vec operator*(db k) const { return Vec(x * k, y * k); }
    Vec operator/(db k) const { return Vec(x / k, y / k); }

    db operator%(Vec b) const { return x * b.y - y * b.x; }

    bool operator==(Vec b) const {
        return sign(x - b.x) == 0 && sign(y - b.y) == 0;
    }
};

db dot(Vec a, Vec b) { return a.x * b.x + a.y * b.y; }
db len2(Vec a) { return dot(a, a); }
db len(Vec a) { return sqrtl(len2(a)); }
```

`%` 按 ACMT 码风表示二维叉积。`Seg`、`Circle` 的相等判断放在各自的数据结构专题中；比较时也应使用同一套 `sign`。

===== 点&向量 本身

====== 数乘

数乘按比例放大或缩小向量；负数会同时反转方向。

```cpp
Vec a(3, 4);
Vec twice = a * 2; // (6, 8)
Vec reverse = a * -1; // (-3, -4)
```

====== 单位化

单位化只保留方向，要求输入非零；零向量没有方向。除法的除数也必须非零。

```cpp
Vec unit(Vec a) {
    db d = len(a);
    if (sign(d) == 0) return Vec();
    return a / d;
}

Vec a(3, 4);
Vec direction = unit(a); // (0.6, 0.8)
```

若题目能保证输入非零，也可简写为 `return a / len(a);`。

====== 射线化（无限延伸至在题目中可以视作射线方向）

一般不需要把向量“射线化”。射线不是 `Vec` 自身能完整表示的对象：它还需要起点。只有题目明确只关心射线方向时，才把非零向量单位化；真正的射线由起点和方向表示，放在线段专题的 `Seg` 中处理。多数向量运算不需要单位化，只有公式明确要求单位方向时才调用 `unit`。

===== 点 与 点 关系

====== 点 与 点 距离

两点相减得到位移向量；距离是该向量的模长。比较距离时优先比较平方距离，避免不必要的开方。

```cpp
db dist2(Vec a, Vec b) {
    return len2(a - b);
}

db dist(Vec a, Vec b) {
    return sqrtl(dist2(a, b));
}

Vec a(1, 2), b(4, 6);
Vec ab = b - a;       // 从 a 指向 b 的向量
db d2 = dist2(a, b);  // 25
db d = dist(a, b);    // 5
```

===== 向量 与 向量 关系（含初步判断）

====== 向量 与 向量 夹角

两向量夹角取 $\[ 0 \, pi \]$。输入向量必须非零；计算反余弦前把余弦值截到 $\[ - 1 \, 1 \]$，消除浮点舍入造成的越界。

```cpp
db angle(Vec a, Vec b) {
    db value = dot(a, b) / (len(a) * len(b));
    value = max((db)-1, min((db)1, value));
    return acosl(value); // 弧度
}
```

====== 向量 加减 -\> 向量

```cpp
Vec a(2, 1), b(1, 3);
Vec sum = a + b; // (3, 4)
Vec sub = a - b; // (1, -2)
```

====== 向量 内积 -\> 数值

内积反映夹角与投影关系：正数表示夹角为锐角，零表示垂直，负数表示钝角。`dot(a,b)` 等于 `|a||b|cos(theta)`。

```cpp
Vec a(2, 1), b(1, 3);
db value = dot(a, b);
int relation = sign(value); // 1: 锐角，0: 垂直，-1: 钝角
```

====== 向量 在 向量 上 投影（投影长度 / 投影向量）

把 `a` 投影到非零向量 `b` 的方向上：带符号的投影长度为 $\( a dot.op b \) \/ \| b \|$，投影向量为 $b \( a dot.op b \) \/ \| b \|^2$。若只要不带方向的长度，再对投影长度取绝对值。

```cpp
db projection_length(Vec a, Vec b) {
    return dot(a, b) / len(b); // 带符号；b 必须非零
}

Vec projection_vector(Vec a, Vec b) {
    return b * (dot(a, b) / len2(b)); // b 必须非零
}

Vec a(3, 4), b(1, 0);
db length = projection_length(a, b); // 3
Vec projected = projection_vector(a, b); // (3, 0)
```

====== 向量 叉积 -\> 数值

二维叉积是有正负的标量。`sign(a % b)` 判断从 `a` 转向 `b` 的方向：正数为逆时针，负数为顺时针，零表示共线。它也用于后续的点线位置、面积和凸包转向判断。

```cpp
Vec a(2, 1), b(1, 3);
db value = a % b;
int turn = sign(value); // 1: 逆时针，0: 共线，-1: 顺时针
```

