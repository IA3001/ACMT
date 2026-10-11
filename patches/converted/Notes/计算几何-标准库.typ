==== #text("计算几何-标准库")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/Notes/计算几何-标准库.md`]

===== c++的适用于计算几何的库

以下只介绍 C++ 标准库中计算几何常用的头文件和函数。代码片段中的 `Vec`、`db`、`dot`、`sign` 沿用 ACMT；`std::` 前缀不省略，便于查对应接口。

====== `<cmath>`

`<cmath>` 提供平方根、三角函数、反三角函数和绝对值等。几何里常用 `std::hypot(x,y)` 求向量长度，`std::atan2(y,x)` 求极角，`std::sqrt` 求平方根。

```cpp
#include <algorithm>
#include <cmath>

db length(Vec v) {
    return std::hypot(v.x, v.y); // sqrt(x*x + y*y)，hypot 对溢出/下溢更稳健
}

db polar_angle(Vec v) {
    return std::atan2(v.y, v.x); // 返回 [-pi, pi]
}

db angle_between(Vec a, Vec b) {
    db cos_value = dot(a, b) / (length(a) * length(b));
    cos_value = std::max((db)-1, std::min((db)1, cos_value)); // 防止舍入误差使 acos 越界
    return std::acos(cos_value); // a、b 非零，结果在 [0, pi]
}

db distance(Vec a, Vec b) {
    return std::hypot(a.x - b.x, a.y - b.y);
}
```

距离比较优先比较平方距离，避免不必要的 `sqrt`：`dot(a-b, a-b)`。`std::numeric_limits<db>::epsilon()` 是浮点类型在 1 附近的机器精度，不是适用于所有坐标范围的几何 `eps`；判零仍按 ACMT 的 `sign` 约定。

====== `<complex>`

`std::complex<T>` 可以直接表示二维向量。实部、虚部分别是 $x \, y$；复数乘法对应旋转与缩放。`std::norm(z)` 返回模长平方，`std::abs(z)` 返回模长，`std::arg(z)` 返回辐角，`std::conj(z)` 返回共轭。

```cpp
#include <complex>

using Point = std::complex<db>;

db dot(Point a, Point b) {
    return std::real(std::conj(a) * b);
}

db cross(Point a, Point b) {
    return std::imag(std::conj(a) * b);
}

Point rotate(Point v, db theta) {
    return v * std::polar((db)1, theta); // 逆时针旋转 theta
}

db distance2(Point a, Point b) {
    return std::norm(a - b); // |a-b|^2，不开方
}
```

使用复数时，`a * b` 是复数乘法，不是点积；点积和叉积分别取 `real(conj(a)*b)` 与 `imag(conj(a)*b)`。如果代码需要大量自定义几何运算或要保持 ACMT 的 `Vec` 接口，继续用 `Vec` 更直观。

====== `<algorithm>`

`<algorithm>` 提供排序、反转、极值和二分等通用算法。计算几何中常见的是 `std::sort` 对点排序，以及 `std::min_element` / `std::max_element` 找最值。

```cpp
#include <algorithm>
#include <vector>

std::sort(p.begin(), p.end(), [](Vec a, Vec b) {
    if (a.x != b.x) return a.x < b.x;
    return a.y < b.y;
}); // Andrew 凸包的字典序

auto lowest = std::min_element(p.begin(), p.end(), [](Vec a, Vec b) {
    if (a.y != b.y) return a.y < b.y;
    return a.x < b.x;
}); // 最低点；空 vector 时不能解引用

std::reverse(p.begin(), p.end()); // 反转顶点环序：逆时针 <-> 顺时针
```

排序比较器必须构成严格弱序；不要在比较器里用会随比较对象变化的容差关系。整数坐标可直接用整数比较；浮点坐标的相等和退化处理要与整套几何谓词统一。

====== `<numeric>`

`<numeric>` 中的 `std::gcd` 可约分整数方向向量，常用于整数点的斜率归一化、方向去重。它要求整数类型，浮点方向不能传给 `gcd`；`std::gcd` 从 C++17 起提供。

```cpp
#include <cstdlib>
#include <numeric>

std::pair<long long, long long> normalize_direction(long long dx,
                                                     long long dy) {
    long long g = std::gcd(std::abs(dx), std::abs(dy));
    if (g != 0) dx /= g, dy /= g;
    if (dx < 0 || (dx == 0 && dy < 0)) dx = -dx, dy = -dy;
    return {dx, dy}; // 无向直线方向统一到同一表示
}
```

`dx=dy=0` 表示零向量，代码保留 `(0,0)`；使用处应按问题语义单独处理。调用前还要保证坐标差能由 `long long` 表示。若输入可能达到 `LLONG_MIN`，`std::abs` 不能安全取其绝对值，且符号统一时取负也可能溢出；应先扩大到更宽整数类型。

====== `<limits>`

`std::numeric_limits<T>` 提供类型边界和特殊值。几何算法常用正无穷初始化最小值答案；不要把机器 `epsilon()` 直接当作几何判零阈值。

```cpp
#include <cmath>
#include <limits>

db nearest = std::numeric_limits<db>::infinity();
db farthest = -std::numeric_limits<db>::infinity();

if (std::isinf(nearest)) {
    // 仍没有处理到任何候选点/线段
}
```

若竞赛代码使用 ACMT 的 `const db inf`，也可以沿用模板常量；只有需要可靠区分“无穷”哨兵时，才使用 `numeric_limits` 的无穷值。

====== `<numbers>`

C++20 的 `<numbers>` 提供类型匹配的圆周率常量 `std::numbers::pi_v<T>`。若评测使用 C++17 或更早标准，不能使用这个头文件，沿用 ACMT 的 `PI = acos(-1.0)`。

```cpp
#include <numbers>

db theta = std::numbers::pi_v<db> / 2; // C++20：db 类型的 pi/2
Vec u = Vec(1, 0); // 后续旋转角度统一用弧度
```

