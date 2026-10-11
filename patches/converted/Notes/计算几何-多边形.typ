==== #text("计算几何-多边形")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/Notes/计算几何-多边形.md`]

- 多边形 表示与前置条件
- 多边形 的 有向面积与周长
- 多边形 方向规范化
- 多边形 的 重心
- 多边形 的 凸性判断
- 点 与 简单多边形 关系（含初步判断）
  - 点 到 多边形区域 距离

===== 多边形 表示与前置条件

多边形用顶点数组 `P[0..n-1]` 表示，边为 `P[i] -> P[(i+1)%n]`，首尾不重复存储。下面的点内外判断、重心和凸性代码以#strong[简单多边形];为输入：边界不自交，允许相邻边共线；点内外判断也允许顺时针或逆时针顶点序。

以下代码沿用前文的 `Vec`、叉积 `%`、`sign` 和 `len`。为避免与线段专题中参数不同的同名函数混淆，本文件用 `polygon_on_segment(a,b,q)` 表示点 `q` 在线段 `ab` 上。

```cpp
bool polygon_on_segment(Vec a, Vec b, Vec q) {
    return sign((b - a) % (q - a)) == 0 &&
           sign(dot(q - a, q - b)) <= 0;
}
```

===== 多边形 的 有向面积与周长

鞋带公式的叉积和保留方向信息：逆时针为正，顺时针为负。普通面积取绝对值的一半；周长累加每条边的长度。

#quote(block: true)[
#strong[输入];：顶点按边界顺序排列的多边形；允许空数组和退化输入。

#strong[输出];：有向面积二倍值、普通面积和周长。

#strong[范围];：每项 $O \( n \)$ 时间、$O \( 1 \)$ 额外空间。
]

```cpp
db polygon_area2(const vector<Vec>& P) {
    db area2 = 0;
    int n = P.size();
    for (int i = 0; i < n; ++i)
        area2 += P[i] % P[(i + 1) % n];
    return area2;
}

db polygon_area(const vector<Vec>& P) {
    return abs(polygon_area2(P)) / 2;
}

db polygon_perimeter(const vector<Vec>& P) {
    db perimeter = 0;
    int n = P.size();
    for (int i = 0; i < n; ++i)
        perimeter += len(P[(i + 1) % n] - P[i]);
    return perimeter;
}
```

空数组循环不执行，面积和周长为 `0`。两点退化输入按闭合边界计算，周长为两点距离的两倍。

===== 多边形 方向规范化

有向面积为负时顶点为顺时针，反转顶点顺序即可变成逆时针。此操作只统一方向，不删除重复点、不检查自交，也不改变多边形形状。面积为零时方向未定义，返回 `false`。

#quote(block: true)[
#strong[输入];：面积非零、按边界顺序排列的简单多边形 `p`。

#strong[输出];：成功后 `p` 为逆时针顺序并返回 `true`；零面积返回 `false`。

#strong[范围];：$O \( n \)$ 时间、$O \( 1 \)$ 额外空间。
]

```cpp
bool polygon_make_ccw(vector<Vec>& P) {
    db area2 = polygon_area2(P);
    if (sign(area2) == 0) return false;
    if (sign(area2) < 0) reverse(P.begin(), P.end());
    return true;
}
```

===== 多边形 的 重心

把多边形拆成以原点为公共顶点的有向三角形。每个三角形的面积权重是 `P[i] % P[i+1]`，加权后得到面积重心：

$ C_x = frac(sum_i \( x_i + x_(i + 1) \) \( p_i times p_(i + 1) \), 3 A_2) \, #h(2em) C_y = frac(sum_i \( y_i + y_(i + 1) \) \( p_i times p_(i + 1) \), 3 A_2) \, $

其中 $A_2 = sum_i p_i times p_(i + 1)$ 是有向面积的二倍。顺时针输入时分子和分母同时反号，结果不变。零面积时重心没有定义，函数返回 `false`。

#quote(block: true)[
#strong[输入];：按边界顺序排列、面积非零的简单多边形。

#strong[输出];：成功时写入面积重心并返回 `true`；零面积返回 `false`。

#strong[范围];：$O \( n \)$ 时间、$O \( 1 \)$ 额外空间。
]

```cpp
bool polygon_centroid(const vector<Vec>& P, Vec& center) {
    db area2 = 0, sum_x = 0, sum_y = 0;
    int n = P.size();
    for (int i = 0; i < n; ++i) {
        Vec a = P[i], b = P[(i + 1) % n];
        db cross = a % b;
        area2 += cross;
        sum_x += (a.x + b.x) * cross;
        sum_y += (a.y + b.y) * cross;
    }
    if (sign(area2) == 0) return false;
    center = Vec(sum_x / (3 * area2), sum_y / (3 * area2));
    return true;
}
```

===== 多边形 的 凸性判断

沿边界依次看相邻两条边的转向。简单多边形若所有非零转向都同号，则为凸多边形；共线转向不影响判断。输入必须是简单多边形，函数不会检查边是否自交。

#quote(block: true)[
#strong[输入];：按边界顺序给出的简单多边形，至少三个顶点。

#strong[输出];：凸（允许连续共线边）返回 `true`；面积为零或出现相反方向转折返回 `false`。

#strong[范围];：$O \( n \)$ 时间、$O \( 1 \)$ 额外空间。
]

```cpp
bool polygon_is_convex(const vector<Vec>& P) {
    int n = P.size();
    if (n < 3 || sign(polygon_area2(P)) == 0) return false;

    int turn = 0;
    for (int i = 0; i < n; ++i) {
        Vec a = P[(i + 1) % n] - P[i];
        Vec b = P[(i + 2) % n] - P[(i + 1) % n];
        int now = sign(a % b);
        if (now == 0) continue;
        if (turn != 0 && turn != now) return false;
        turn = now;
    }
    return turn != 0;
}
```

这个判断只回答“是否凸”，不要求逆时针；如果后续算法要求逆时针，可用 `polygon_area2(P)` 的符号决定是否反转顶点序。

===== 点 与 简单多边形 关系（含初步判断）

先检查点是否落在任意边上；否则用水平射线的奇偶交点规则判断内外。每条边采用半开纵坐标区间，避免射线经过顶点时把同一个顶点重复计数。

约定返回 `-1` 表示外部、`0` 表示边界、`1` 表示内部。多边形必须是简单多边形；自交多边形需要先明确采用奇偶规则还是非零绕数规则，不能直接套用这里的定义。

#quote(block: true)[
#strong[输入];：简单多边形 `p` 和查询点 `q`；顶点可顺时针或逆时针给出。

#strong[输出];：`-1` 外部、`0` 边界、`1` 内部。

#strong[范围];：$O \( n \)$ 时间、$O \( 1 \)$ 额外空间。
]

```cpp
int point_in_polygon(const vector<Vec>& P, Vec q) {
    int n = P.size();
    bool inside = false;
    for (int i = 0; i < n; ++i) {
        Vec a = P[i], b = P[(i + 1) % n];
        if (polygon_on_segment(a, b, q)) return 0;

        if (a.y <= q.y && q.y < b.y && sign((b - a) % (q - a)) > 0)
            inside = !inside;
        if (b.y <= q.y && q.y < a.y && sign((b - a) % (q - a)) < 0)
            inside = !inside;
    }
    return inside ? 1 : -1;
}
```

对凸多边形，多次点定位应使用凸包专题中的 `point_in_convex`，单次查询可由这里的统一简单多边形版本处理。点在边界上的情况始终优先返回 `0`。

====== 点 到 多边形区域 距离

点在多边形内部或边界上时，到多边形区域的距离为 `0`；点在外部时，最近点必在边界的某条线段上，逐边取点到线段距离的最小值。这里求的是到#strong[区域];的距离；若要算内部点到边界的距离，应直接取到各边的最小距离，不要在内部时提前返回 `0`。

#quote(block: true)[
#strong[输入];：非退化简单多边形 `p` 和查询点 `q`。

#strong[输出];：点到多边形闭区域的最短距离。

#strong[范围];：$O \( n \)$ 时间、$O \( 1 \)$ 额外空间；复用线段专题的 `dist_to_seg(Vec, Seg)`。
]

```cpp
db dist_point_polygon(Vec q, const vector<Vec>& P) {
    if (P.empty()) return numeric_limits<db>::infinity();
    if (point_in_polygon(P, q) >= 0) return 0;

    db ans = numeric_limits<db>::infinity();
    int n = P.size();
    for (int i = 0; i < n; ++i) {
        Seg Edge = Seg::st(P[i], P[(i + 1) % n]);
        ans = min(ans, dist_to_seg(q, Edge));
    }
    return ans;
}
```

