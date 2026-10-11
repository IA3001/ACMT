==== #text("计算几何-圆")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/Notes/计算几何-圆.md`]

#quote(block: true)[
圆相关 （圆为最大维度）
]

- 圆 的 创建方式
  - 圆属性 Circle{Vec o, db r}
  - static Circle Circle::Or(Vec o, db r)
  - static Circle Circle::abc(Vec a, Vec b, Vec c)
- 圆 与 圆 关系（含初步判断）
  - 圆 与 圆 包含关系
  - 圆 与 圆 距离
  - 圆 与 圆 交点
  - 圆 与 圆 切线
- 圆 与 线段 关系（含初步判断）
  - 圆 与 线段 距离
  - 圆 与 线段 交点
- 圆 与 直线
  - 圆 与 直线 距离
  - 圆 与 直线 交点
- 圆 与 点 关系（含初步判断）
  - 圆 与 点 距离
  - 圆 与 点 切线
- 圆 与 多边形
  - 圆 与 多边形 关系
  - 圆 与 凸多边形 相交判定
  - 圆 与 多边形 交点
  - 圆 与 多边形 公共面积
- 圆覆盖
  - 两圆 公共面积
- 点集 最小覆盖圆

===== 圆 的 创建方式

圆保存圆心 `o` 和半径 `r`，通常要求 `r>0`；最小覆盖圆和退化圆会用到 `r=0`，此时圆周退化为一个点。各函数的半径前置条件以对应输入说明为准。给定三个点时，三点必须不共线，圆心是两条弦的垂直平分线交点。

====== 圆心 与 半径 创建

#quote(block: true)[
#strong[输入];：圆心 `o`、非负半径 `r`。

#strong[输出];：圆心为 `o`、半径为 `r` 的圆。

#strong[范围];：$O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
struct Circle {
    Vec o;
    db r;

    static Circle Or(Vec o, db r) {
        Circle Cir;
        Cir.o = o;
        Cir.r = r;
        return Cir;
    }

    static Circle abc(Vec a, Vec b, Vec c) {
        Vec u = b - a, v = c - a;
        db det = 2 * (u % v);
        db uu = dot(u, u), vv = dot(v, v);
        Vec w((uu * v.y - vv * u.y) / det,
              (u.x * vv - v.x * uu) / det);

        Circle Cir;
        Cir.o = a + w;
        Cir.r = dist(Cir.o, a);
        return Cir;
    }
};
```

====== 三点 创建

令 `u=b-a`、`v=c-a`。圆心相对 `a` 的位移同时满足 $2 u dot.op w = \| u \|^2$、$2 v dot.op w = \| v \|^2$；解这个二元一次方程即可得到外心。

#quote(block: true)[
#strong[输入];：三个不共线点 `a,b,c`。

#strong[输出];：经过这三点的唯一圆。

#strong[范围];：$O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
Circle Cir = Circle::abc(a, b, c);
```

调用 `Circle::abc(a,b,c)` 前保证三点不共线；近共线时外心对误差敏感，应按题目数据范围选用精度和判零方式。

===== 圆 与 圆 关系（含初步判断）

设圆心距为 `d`，半径和为 `r1+r2`，半径差绝对值为 `|r1-r2|`。圆周关系按 `d` 与半径和、半径差比较；圆盘包含还要区分是谁包含谁，以及是否允许边界相切。

====== 圆 与 圆 初步判断

#quote(block: true)[
#strong[输入];：两个半径为正的圆 `A,B`。

#strong[输出];：圆周相离、外切、相交、内切、包含或重合。

#strong[范围];：$O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
enum class CircleRelation {
    Separate, ExternalTangent, Intersect,
    AContainsB, BContainsA,
    AContainsBInternalTangent, BContainsAInternalTangent,
    Coincident
};

CircleRelation circle_relation(Circle A, Circle B) {
    db d = dist(A.o, B.o);
    db sum = A.r + B.r;
    db diff = abs(A.r - B.r);

    if (sign(d) == 0 && sign(A.r - B.r) == 0)
        return CircleRelation::Coincident;
    if (sign(d - sum) > 0) return CircleRelation::Separate;
    if (sign(d - sum) == 0) return CircleRelation::ExternalTangent;
    if (sign(d - diff) > 0) return CircleRelation::Intersect;
    if (sign(d - diff) == 0) {
        return A.r > B.r ? CircleRelation::AContainsBInternalTangent
                         : CircleRelation::BContainsAInternalTangent;
    }
    if (A.r > B.r) return CircleRelation::AContainsB;
    return CircleRelation::BContainsA;
}
```

结果含义：`Separate` 是圆周外离；`ExternalTangent` 是外切；`Intersect` 是两个交点；`AContainsB` / `BContainsA` 是圆周严格分离且对应圆盘严格包含；`AContainsBInternalTangent` / `BContainsAInternalTangent` 表示圆盘包含且内切；`Coincident` 表示两圆完全重合。

====== 圆 与 圆 包含关系

先区分题目说的“圆”是哪一个对象：#strong[圆周];只有边界，#strong[圆盘];包含边界和内部。竞赛题里“圆 A 包含圆 B”通常指圆盘包含；若题目实际问两条圆周是否有交点，应使用后面的圆周关系分类，不能只看半径谁大。

令 `d=|A.o-B.o|`、`rA=A.r`、`rB=B.r`。判断 `A` 是否包含 `B` 时，看 `A` 最靠近 `B` 圆心的边界与 `B` 最远点：最远点到 `A.o` 的距离为 `d+rB`。所以闭圆盘包含的充要条件是 `d+rB<=rA`，等价于 `rA-rB-d>=0`。这个判定是#strong[有方向的];：`disk_contains(A,B)` 与 `disk_contains(B,A)` 不能互换。

由此可以把关系拆成以下几类：

- `rA > d+rB`：`A` 严格包含 `B`，两圆周没有公共点。
- `rA = d+rB`：`A` 内切 `B`，`A` 包含 `B`，两圆周有一个公共点。
- `rB > d+rA`：`B` 严格包含 `A`。
- `rB = d+rA`：`B` 内切 `A`。
- `d=0` 且 `rA=rB`：两圆重合；闭圆盘互相包含，严格包含均为假。
- 其余情况：没有包含关系；圆周可能相离、外切或交于两点，具体看 `d` 与 `rA+rB`、`|rA-rB|` 的关系。

特别注意：内切时仍然是圆盘包含，只是边界接触；严格包含则要求两个圆盘连边界都不接触。若只问“`B` 的圆周是否在 `A` 的圆盘内”，条件仍是 `d+rB<=rA`；若问“`B` 的圆周是否严格位于 `A` 内部”，条件是严格小于。重合时，圆周在对方闭圆盘内，但不在对方内部。

#quote(block: true)[
#strong[输入];：两个半径为正的圆 `A,B`。

#strong[输出];：`disk_contains(A,B)` 判断闭圆盘 `A` 是否包含 `B`；`disk_strictly_contains(A,B)` 判断严格包含。

#strong[范围];：每次判断 $O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
bool disk_contains(Circle A, Circle B) {
    return sign(A.r - B.r - dist(A.o, B.o)) >= 0;
}

bool disk_strictly_contains(Circle A, Circle B) {
    return sign(A.r - B.r - dist(A.o, B.o)) > 0;
}
```

例如 `A=(o=(0,0), r=5)`、`B=(o=(2,0), r=3)`，有 `d+rB=5=rA`，所以 `A` 闭圆盘包含 `B`，且两圆内切；把 `B` 的半径改为 `2`，则 `d+rB=4<5`，变成严格包含；把 `B` 的圆心改为 `(4,0)` 且半径仍为 `3`，则 `d+rB=7>5`，`A` 不包含 `B`，但 `B` 也不包含 `A`，两圆周相交。

几何关系可按下表读取：

#figure(
  align(center)[#table(
    columns: 3,
    align: (auto,auto,auto,),
    table.header([条件], [圆周关系], [圆盘关系],),
    table.hline(),
    [`d > r1+r2`], [相离], [不相交],
    [`d = r1+r2`], [外切], [仅边界接触],
    [`|r1-r2| < d < r1+r2`], [相交于两点], [部分重叠],
    [`0 < d = |r1-r2|`], [内切], [一盘包含另一盘，边界接触],
    [`0 <= d < |r1-r2|`], [无交点], [半径较大的圆盘严格包含较小圆盘],
    [`d=0, r1=r2`], [重合], [两圆盘相同，互相闭包含],
  )]
  , kind: table
  )

表中的等号在浮点代码中由 `sign` 判定。内切时通过 `A.r` 与 `B.r` 的大小区分包含方向；同心异半径则属于严格包含，不是内切。

====== 圆 与 圆 距离

这里的距离指#strong[两个圆周之间的最短距离];。相交或相切时为 `0`；分离时是外侧间隔；一圆严格包含另一圆时，是两圆周之间的内侧间隔。

#quote(block: true)[
#strong[输入];：两个半径为正的圆 `A,B`。

#strong[输出];：两圆周的最短距离。

#strong[范围];：$O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
db dist_circle_circle(Circle A, Circle B) {
    db d = dist(A.o, B.o);
    return max({(db)0, d - A.r - B.r, abs(A.r - B.r) - d});
}
```

若要求两个#strong[圆盘];的距离，公式不同：只需 `max(0, d-A.r-B.r)`。

====== 圆 与 圆 交点

先判断两圆周关系。相交时，公共弦垂直于圆心连线；从圆心 `A.o` 沿圆心连线走距离 `x` 得到公共弦中点，再沿垂线偏移高度 `h` 得到交点。重合圆有无穷多个公共点，单独用 `coincident` 标记。

#quote(block: true)[
#strong[输入];：两个半径为正的圆 `A,B`。

#strong[输出];：交点列表，最多两个；重合时列表为空且 `coincident=true`。

#strong[范围];：$O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
struct CircleIntersection {
    vector<Vec> points;
    bool coincident = false;
};

CircleIntersection circle_intersection(Circle A, Circle B) {
    CircleIntersection Ans;
    Vec v = B.o - A.o;
    db d2 = dot(v, v);
    db d = sqrt(d2);

    if (sign(d) == 0) {
        Ans.coincident = sign(A.r - B.r) == 0;
        return Ans;
    }

    db x = (d2 + A.r * A.r - B.r * B.r) / (2 * d);
    db h2 = A.r * A.r - x * x;
    if (sign(h2) < 0) return Ans;

    Vec mid = A.o + v * (x / d);
    if (sign(h2) == 0) {
        Ans.points.push_back(mid);
        return Ans;
    }

    Vec offset(-v.y, v.x);
    offset = offset * (sqrt(max((db)0, h2)) / d);
    Ans.points.push_back(mid + offset);
    Ans.points.push_back(mid - offset);
    return Ans;
}
```

===== 圆 与 线段 关系（含初步判断）

线段与圆周最多有两个交点。先把圆心投影到线段所在直线，比较垂距与半径得到直线交点，再用 `on_segment` 过滤到闭线段上；线段退化为点时单独判断。

====== 圆 与 线段 交点

#quote(block: true)[
#strong[输入];：半径为正的圆 `Cir` 和闭线段 `L`；允许线段退化为点。

#strong[输出];：圆周与线段的交点，返回 0、1 或 2 个点。

#strong[范围];：$O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
vector<Vec> circle_segment_intersection(Circle Cir, Seg L) {
    if (L.s == L.t) {
        if (sign(len2(L.s - Cir.o) - Cir.r * Cir.r) == 0)
            return {L.s};
        return {};
    }

    Vec foot = project_line(Cir.o, L);
    db h2 = Cir.r * Cir.r - len2(foot - Cir.o);
    if (sign(h2) < 0) return {};

    db h = sqrt(max((db)0, h2));
    Vec offset = L.v * (h / sqrt(len2(L.v)));
    vector<Vec> Ans;
    for (Vec p : vector<Vec>{foot + offset, foot - offset}) {
        if (!on_segment(p, L)) continue;
        if (Ans.empty() || !(Ans[0] == p)) Ans.push_back(p);
    }
    return Ans;
}
```

====== 圆 与 线段 距离

这里的距离指圆周到线段的最短距离。线段上点到圆心的距离连续取遍 `[d_min,d_max]`，其中 `d_min` 是圆心到线段距离，`d_max` 是两个端点到圆心距离的较大值；若半径落在该区间内就有交点，否则取半径与区间端点的最近差值。

#quote(block: true)[
#strong[输入];：半径为正的圆 `Cir` 和闭线段 `L`；允许线段退化为点。

#strong[输出];：圆周到线段的最短距离。

#strong[范围];：$O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
db dist_circle_segment(Circle Cir, Seg L) {
    db d_min = dist(Cir.o, project_segment(Cir.o, L));
    db d_max = max(dist(Cir.o, L.s), dist(Cir.o, L.t));
    if (sign(d_min - Cir.r) <= 0 && sign(d_max - Cir.r) >= 0)
        return 0;
    return min(abs(d_min - Cir.r), abs(d_max - Cir.r));
}
```

===== 圆 与 直线

直线用两个不同端点 `L.s,L.t` 表示，方向向量为 `L.v`，但只取其所在的#strong[无限直线];，不限制在线段范围内。以下函数要求 `L.s != L.t`。

====== 圆 与 直线 距离

圆心到直线的距离为 `d`。直线与圆周相交或相切时距离为 `0`；否则最短距离为 `d-r`。直线到闭圆盘的距离公式相同。

#quote(block: true)[
#strong[输入];：正半径圆 `Cir` 和非退化直线 `L`。

#strong[输出];：直线到圆周（等价于到圆盘）的最短距离。

#strong[范围];：$O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
db dist_line_circle(Seg L, Circle Cir) {
    db d = dist(Cir.o, project_line(Cir.o, L));
    return max((db)0, d - Cir.r);
}
```

====== 圆 与 直线 交点

先将圆心投影到直线上得到弦中点 `foot`。若圆心到直线距离大于半径则无交点；相等时投影点就是切点；小于时沿直线方向从 `foot` 两侧各走半弦长。

#quote(block: true)[
#strong[输入];：正半径圆 `Cir` 和非退化直线 `L`。

#strong[输出];：直线与圆周的交点，返回 0、1 或 2 个点。

#strong[范围];：$O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
vector<Vec> circle_line_intersection(Circle Cir, Seg L) {
    Vec foot = project_line(Cir.o, L);
    db h2 = Cir.r * Cir.r - len2(foot - Cir.o);
    if (sign(h2) < 0) return {};
    if (sign(h2) == 0) return {foot};

    Vec offset = L.v * (sqrt(max((db)0, h2) / len2(L.v)));
    return {foot + offset, foot - offset};
}
```

===== 圆 与 点 关系（含初步判断）

比较 `|p-o|^2` 与 `r^2` 可判断点在圆内、圆上或圆外。点到#strong[圆周];距离是 `||p-o|-r|`；若题目问点到#strong[圆盘];距离，则圆内为 `0`，圆外为 `|p-o|-r`。

====== 圆 与 点 初步判断

#quote(block: true)[
#strong[输入];：半径为正的圆 `Cir` 和点 `p`。

#strong[输出];：`-1` 圆内、`0` 圆上、`1` 圆外。

#strong[范围];：$O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
int point_circle_position(Circle Cir, Vec p) {
    return sign(len2(p - Cir.o) - Cir.r * Cir.r);
}

db dist_point_circle(Vec p, Circle Cir) {
    return abs(dist(p, Cir.o) - Cir.r); // 到圆周的距离
}

db dist_point_disk(Vec p, Circle Cir) {
    return max((db)0, dist(p, Cir.o) - Cir.r); // 到圆盘的距离
}
```

===== 圆 与 多边形

本节多边形顶点按边界顺序给出，首尾不重复。边界是由顶点依次连接成的闭折线。圆与多边形相交判定按#strong[圆盘];理解；求交点则是圆周与多边形边界的交点。

====== 圆 与 凸多边形 相交判定

闭圆盘与闭凸多边形相交，当且仅当圆心在多边形内，或圆心到某条边的距离不大于半径。若要判断圆周与多边形边界相交，不能用这个条件替代：圆盘包含多边形时两者仍可能不相交于边界。

#quote(block: true)[
#strong[输入];：逆时针凸多边形 `p`（点/线段退化也允许）和正半径圆 `Cir`。

#strong[输出];：闭圆盘与多边形是否有公共点。

#strong[范围];：$O \( n \)$ 时间、$O \( 1 \)$ 额外空间。
]

```cpp
bool disk_intersects_convex_polygon(Circle Cir, const vector<Vec>& p) {
    if (p.empty()) return false;
    if (p.size() >= 3 && point_in_convex(p, Cir.o) >= 0) return true;

    int edge_count = p.size() == 1 ? 0 : (int)p.size();
    if (p.size() == 1) return sign(dist(Cir.o, p[0]) - Cir.r) <= 0;
    for (int i = 0; i < edge_count; i++) {
        Seg L = Seg::st(p[i], p[(i + 1) % p.size()]);
        if (sign(dist(Cir.o, project_segment(Cir.o, L)) - Cir.r) <= 0)
            return true;
    }
    return false;
}
```

`point_in_convex` 的返回值约定沿用凸包章节：内或边界为非负，外部为负。多边形退化成线段时，上面的边循环会检查该线段及其反向边，不影响结果。

====== 圆 与 多边形 交点

逐条边调用圆与线段交点，再对顶点处重复命中的交点去重。圆与多边形相切时返回一个点；每条多边形边是线段，与圆周至多有两个交点，因此结果始终是有限点集。

#quote(block: true)[
#strong[输入];：简单多边形顶点 `p` 和正半径圆 `Cir`。

#strong[输出];：圆周与多边形边界的所有交点，每个几何点只保留一次。

#strong[范围];：$O \( n \)$ 时间、$O \( n \)$ 空间，`k<=2n` 为交点数。
]

```cpp
vector<Vec> circle_polygon_intersection(Circle Cir, const vector<Vec>& p) {
    vector<Vec> ans;
    int n = p.size();
    if (n < 2) return ans;

    for (int i = 0; i < n; i++) {
        Seg L = Seg::st(p[i], p[(i + 1) % n]);
        for (Vec x : circle_segment_intersection(Cir, L)) {
            // 顶点交点只由从该顶点出发的边收录，避免相邻边重复。
            if (!(x == L.t)) ans.push_back(x);
        }
    }
    return ans;
}
```

====== 圆 与 多边形 关系

先确认“圆与多边形有关系”具体问什么。以下三个判断对象不同，不能相互替代：

#figure(
  align(center)[#table(
    columns: (33.33%, 33.33%, 33.33%),
    align: (auto,auto,auto,),
    table.header([问题], [判断对象], [常见判定],),
    table.hline(),
    [圆盘与多边形相交], [圆盘内部及边界，与多边形区域及边界有公共点], [凸多边形用圆心在多边形内，或圆心到某边距离不大于半径],
    [圆周与多边形边界相交], [圆周与多边形边界有公共点], [枚举多边形边，求圆与线段交点],
    [圆盘包含多边形], [多边形的每个点都在闭圆盘内], [检查所有顶点是否在圆盘内],
  )]
  , kind: table
  )

例如圆盘完全位于多边形内部时，第一种判断为真，第二种为假；多边形完全位于圆盘内部时，第三种判断为真，第二种仍为假。边界相切也算“有公共点”。

======= 圆周 与 多边形边界 是否相交

调用上面的 `circle_polygon_intersection` 即可。它返回空列表表示没有公共点，非空表示有公共点；切点和顶点接触也会被计入。函数要求简单多边形。

#quote(block: true)[
#strong[输入];：简单多边形顶点 `p` 和正半径圆 `Cir`。

#strong[输出];：圆周与多边形边界是否有公共点。

#strong[范围];：$O \( n \)$ 时间；空间复杂度由交点列表决定，最多 $O \( n \)$。
]

```cpp
bool circle_boundary_intersects_polygon(Circle Cir, const vector<Vec>& p) {
    return !circle_polygon_intersection(Cir, p).empty();
}
```

该判定不回答“圆盘与多边形区域是否相交”。圆盘可能完全在多边形内，也可能完全包含多边形；这两种情况下圆周与多边形边界都没有交点。

======= 圆盘 是否包含多边形

闭圆盘是凸集。若多边形所有顶点都在闭圆盘内，则这些顶点的凸包也在圆盘内，多边形区域自然也在其中。因此只需检查顶点，无需枚举多边形内部点。此结论对简单凹多边形同样成立。

#quote(block: true)[
#strong[输入];：简单多边形顶点 `p` 和正半径圆 `Cir`。

#strong[输出];：多边形区域及其边界是否全部包含在闭圆盘内；边界接触允许。

#strong[范围];：$O \( n \)$ 时间、$O \( 1 \)$ 额外空间。
]

```cpp
bool disk_contains_polygon(Circle Cir, const vector<Vec>& p) {
    for (Vec x : p)
        if (sign(len2(x - Cir.o) - Cir.r * Cir.r) > 0)
            return false;
    return true;
}
```

空顶点集按数学上的全称命题会返回 `true`；若题目不接受空多边形，应在调用前保证 `p` 非空。若题目要判断多边形是否严格位于圆盘内部，把判定中的 `> 0` 改为 `>= 0`，表示任何顶点落在圆周上都不算严格包含。

====== 圆 与 多边形 公共面积

把多边形拆成有向边。对每条边 `a->b`，求三角形 `Oab` 与圆扇形 `Oab` 对公共面积的贡献：将边按与圆的交点切成小段；小段中点在圆内时加有向三角形面积，否则加有向扇形面积。所有边贡献相加后取绝对值。该方法适用于简单多边形，可处理凹多边形；顶点顺/逆时针均可。

#quote(block: true)[
#strong[输入];：简单多边形 `p` 和正半径圆 `Cir`。

#strong[输出];：多边形与闭圆盘的公共面积。

#strong[范围];：$O \( n \)$ 时间、$O \( 1 \)$ 额外空间（不计交点临时数组）。
]

```cpp
db circle_edge_area(Vec a, Vec b, db r) {
    vector<db> cut{0, 1};
    Vec v = b - a;
    db A = dot(v, v), B = 2 * dot(a, v), C = dot(a, a) - r * r;
    db delta = B * B - 4 * A * C;

    if (sign(A) > 0 && sign(delta) > 0) {
        db root = sqrt(max((db)0, delta));
        db t1 = (-B - root) / (2 * A);
        db t2 = (-B + root) / (2 * A);
        if (sign(t1) > 0 && sign(1 - t1) > 0) cut.push_back(t1);
        if (sign(t2) > 0 && sign(1 - t2) > 0) cut.push_back(t2);
    }

    sort(cut.begin(), cut.end());
    db area = 0;
    for (int i = 0; i + 1 < (int)cut.size(); i++) {
        Vec x = a + v * cut[i], y = a + v * cut[i + 1];
        Vec mid = (x + y) * 0.5;
        // 恰好相切时整段在线外，只能按圆弧贡献；不能当作三角形。
        if (sign(dot(mid, mid) - r * r) < 0)
            area += (x % y) / 2;
        else
            area += r * r * atan2(x % y, dot(x, y)) / 2;
    }
    return area;
}

db area_circle_polygon(Circle Cir, const vector<Vec>& p) {
    db area = 0;
    for (int i = 0; i < (int)p.size(); i++) {
        Vec a = p[i] - Cir.o, b = p[(i + 1) % p.size()] - Cir.o;
        area += circle_edge_area(a, b, Cir.r);
    }
    return abs(area);
}
```

===== 圆覆盖

====== 两圆 公共面积

先用圆心距和半径和/差判断完全分离、包含與相交。相交时公共部分由两个圆弓形组成；每个弓形面积为扇形面积减去等腰三角形面积。公式中的 `acos` 参数需夹到 `[-1,1]`，以免浮点误差导致定义域错误。

#quote(block: true)[
#strong[输入];：两个正半径圆 `A,B`。

#strong[输出];：两个闭圆盘的公共面积。

#strong[范围];：$O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
db area_circle_intersection(Circle A, Circle B) {
    db d = dist(A.o, B.o);
    if (sign(d - A.r - B.r) >= 0) return 0;
    if (sign(d + min(A.r, B.r) - max(A.r, B.r)) <= 0) {
        db r = min(A.r, B.r);
        return acos(-1) * r * r;
    }

    db c1 = (d * d + A.r * A.r - B.r * B.r) / (2 * d * A.r);
    db c2 = (d * d + B.r * B.r - A.r * A.r) / (2 * d * B.r);
    c1 = max((db)-1, min((db)1, c1));
    c2 = max((db)-1, min((db)1, c2));
    db alpha = acos(c1), beta = acos(c2);
    return A.r * A.r * (alpha - sin(2 * alpha) / 2)
         + B.r * B.r * (beta - sin(2 * beta) / 2);
}
```

===== 点集 最小覆盖圆

随机增量算法打乱点的顺序后依次维护前缀最小覆盖圆。若新点已在当前圆内则不变；否则新最小圆必经过该点。再扫描此前点，发现外点时将圆更新为通过两点的最小圆；若还有更早的点在圆外，则新圆由这三个边界点确定。随机打乱保证期望线性复杂度；最坏复杂度仍为 $O \( n^3 \)$。

#quote(block: true)[
#strong[输入];：点集 `p`，允许重复点；空集单独处理。

#strong[输出];：包含所有输入点的最小圆。

#strong[范围];：期望 $O \( n \)$ 时间，最坏 $O \( n^3 \)$；额外空间 $O \( 1 \)$（不计打乱数组）。
]

```cpp
bool disk_contains_point(Circle Cir, Vec p) {
    return sign(len2(p - Cir.o) - Cir.r * Cir.r) <= 0;
}

Circle diameter_circle(Vec a, Vec b) {
    Vec o = (a + b) * 0.5;
    return Circle::Or(o, dist(o, a));
}

Circle minimum_enclosing_circle(vector<Vec> p, mt19937& rng) {
    if (p.empty()) return Circle::Or(Vec(0, 0), 0);
    shuffle(p.begin(), p.end(), rng);
    Circle Cir = Circle::Or(p[0], 0);

    for (int i = 0; i < (int)p.size(); i++) {
        if (disk_contains_point(Cir, p[i])) continue;
        Cir = Circle::Or(p[i], 0);
        for (int j = 0; j < i; j++) {
            if (disk_contains_point(Cir, p[j])) continue;
            Cir = diameter_circle(p[i], p[j]);
            for (int k = 0; k < j; k++) {
                if (disk_contains_point(Cir, p[k])) continue;
                if (sign((p[j] - p[i]) % (p[k] - p[i])) == 0) {
                    Vec x = p[i], y = p[j];
                    if (dist(x, y) < dist(x, p[k])) y = p[k];
                    if (dist(x, y) < dist(p[j], p[k])) x = p[j], y = p[k];
                    Cir = diameter_circle(x, y);
                } else {
                    Cir = Circle::abc(p[i], p[j], p[k]);
                }
            }
        }
    }
    return Cir;
}
```

调用前需包含 `<random>`，并传入 `mt19937` 随机引擎。三点共线时不能调用 `Circle::abc`，代码改取三点中最远两点的直径圆。空集返回半径为 `0` 的退化圆。

===== 圆的切线算法

====== 类型

- #strong[点到圆];：圆心 $C$、半径 $r$、外点 $p$。令 $v = p - C \, d^2 = v dot.op v$。$d^2 < r^2$ 时无切线，等于时一条，大于时两条。
- #strong[两圆公切线];：外公切线比较 $\| r_1 - r_2 \|$ 与圆心距 $d$；内公切线比较 $r_1 + r_2$ 与 $d$。比较值小于 $d$ 时两条，等于时一条，大于时没有。两圆重合时有无穷多条外公切线。

====== Codes

点到圆的切点满足 `CT ⟂ PT`。两圆公切线令单位法向量为 $n$，接触点分别为 $O_1 + r_1 n$、$O_2 + s r_2 n$，其中外切线取 $s = 1$、内切线取 $s = - 1$。由两接触点连线垂直于 $n$，可解出 $n$ 的两个方向。`perp((x,y))=(-y,x)`。

#quote(block: true)[
#strong[输入];：圆 `Cir`（圆心 `o`、半径 `r>0`）和点 `p`；或两个正半径圆 `A,B`。

#strong[输出];：点到圆返回切点；两圆函数返回每条公切线、两个接触点及内/外切类型。重合圆用 `infinite=true` 表示有无穷多条外公切线。

#strong[范围];：每个函数 $O \( 1 \)$ 时间与空间；浮点判零使用 ACMT 的 `sign`。
]

```cpp
Vec perp(Vec v) { return Vec(-v.y, v.x); }

vector<Vec> tangent_points(Circle Cir, Vec p) {
    Vec v = p - Cir.o;
    db d2 = dot(v, v), r2 = Cir.r * Cir.r;
    if (sign(d2 - r2) < 0) return {};
    if (sign(d2 - r2) == 0) return {p};

    db k = Cir.r * Cir.r / d2;
    db h = Cir.r * sqrt(max((db)0, d2 - r2)) / d2;
    return {Cir.o + v * k + perp(v) * h,
            Cir.o + v * k - perp(v) * h};
}

struct CommonTangent {
    Seg Line;          // 公切线，按 ACMT 约定是有向直线
    Vec touch_a, touch_b;
    bool inner;        // true: 内公切线；false: 外公切线
};

struct CommonTangentResult {
    vector<CommonTangent> lines;
    bool infinite = false;
};

CommonTangentResult common_tangents(Circle A, Circle B, bool inner) {
    CommonTangentResult ans;
    Vec d = B.o - A.o;
    db d2 = dot(d, d);
    db len = sqrt(d2);
    db s = inner ? -1 : 1;

    if (sign(len) == 0) {
        if (!inner && sign(A.r - B.r) == 0) ans.infinite = true;
        return ans; // 同心异圆无公切线；同心等圆有无穷多条外公切线
    }

    db x = (A.r - s * B.r) / len;
    if (sign(abs(x) - 1) > 0) return ans;
    x = max((db)-1, min((db)1, x)); // 相切时消除微小舍入越界
    db y = sqrt(max((db)0, 1 - x * x));
    Vec e = d * (1 / len), ep = perp(e);

    for (int t : {1, -1}) {
        if (sign(y) == 0 && t == -1) break; // 两条解重合，只保留一条
        Vec normal = e * x + ep * (y * t);
        Vec touch_a = A.o + normal * A.r;
        Vec touch_b = B.o + normal * (s * B.r);
        ans.lines.push_back({Seg::st(touch_a, touch_a + perp(normal)),
                             touch_a, touch_b, inner});
    }
    return ans;
}
```

`tangent_points` 返回切点，直线由 `p` 和切点确定。两圆分别调用 `common_tangents(A, B, false)` 与 `common_tangents(A, B, true)`，合并结果即可得到全部外/内公切线；同心、包含、相切、重合都在函数中分支处理。

