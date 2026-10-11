==== #text("计算几何-线段")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/Notes/计算几何-线段.md`]

#quote(block: true)[
线段相关 （线段为最大维度）

在具体的计算中，我们可以把 #strong[线段] 当成 #strong[直线/射线] 来用

所以，下面的标题中如果出现 #strong[直线] 那么就把 #strong[线段] 当作 #strong[直线/射线] 理解
]

- 线段 创建方式
  - 线段属性：Seg{Vec s, Vec t, Vec v}
  - static Seg Seg::st(s, t) 起点+终点
  - static Seg Seg::sv(s, v) 起点+方向向量
- 直线 与 直线 关系（含初步判断）
  - 注意初步判断好多（给出多个 return 按需选择返回）：
    - 共线/平行/垂直 | 相交/不交 | 等
  - 直线 与 直线 交点
  - 直线 到 直线 距离
  - 直线 与 线段 相交 / 距离
- 直线 与 点 关系（含初步判断）
  - 注意初步判断好多（给出多个 return 按需选择返回）：
    - 左侧/右侧/内部 | 等
  - 点 在 直线 上 的 投影（垂足）
  - 直线 到 点 距离
- 线段 与 线段 关系（含初步判断）
  - 注意初步判断好多（给出多个 return 按需选择返回）：
    - 共线/平行/垂直 | 相交/不交 | 等
  - 线段 与 线段 交点（前置：直线 与 直线 交点）
  - 线段 到 线段 距离（前置：直线 到 直线 距离）
  - 线段间最近点对
- 线段 与 点 关系（含初步判断）
  - 注意初步判断好多（给出多个 return 按需选择返回）：
    - 左侧/右侧/左端点/右端点/内部线段/st负向/st正向 | 等
  - 点 在 线段所在直线 上 的 投影参数
  - 点 在线段 上 的 投影（截断垂足 / 最近点）
  - 线段 到 点 距离（前置：直线 到 点 距离）

===== 线段 创建方式

`Seg` 用起点 `s`、终点 `t` 和方向 `v=t-s` 保存有向几何对象。相同的数据可以按使用场景解释为：线段取参数 $0 lt.eq k lt.eq 1$，射线取 $k gt.eq 0$，直线不限制 $k$，其中点为 `s+k*v`。方向向量必须非零；线段本身允许退化为一个点。

====== 线段属性 与 创建

`st(s,t)` 用起点和终点创建；`sv(s,v)` 用起点和方向向量创建，内部终点设为 `s+v`。

#quote(block: true)[
#strong[输入];：起点 `s`、终点 `t`，或起点 `s`、非零方向 `v`。

#strong[输出];：保存 `s,t,v` 的 `Seg`。

#strong[范围];：$O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
struct Seg {
    Vec s, t, v;

    Seg() = default;

    static Seg st(Vec s, Vec t) {
        Seg Line;
        Line.s = s;
        Line.t = t;
        Line.v = t - s;
        return Line;
    }

    static Seg sv(Vec s, Vec v) {
        return st(s, s + v);
    }

    bool operator==(Seg B) const {
        return s == B.s && t == B.t; // 有向端点相同
    }
};

Seg AB = Seg::st(Vec(1, 2), Vec(4, 6));
Seg Ray = Seg::sv(Vec(1, 2), Vec(3, 4));
```

此处相等表示两个有向端点分别相同；若要判断无向线段相同，还需同时允许端点交换。直线与射线的参数范围由具体查询函数决定，不由 `Seg` 自动区分。

===== 直线 与 直线 关系（含初步判断）

对非零方向 `A.v`、`B.v`，叉积判断平行，点积判断垂直；平行时再用位移叉积判断是否共线。两条不平行直线恰有一个交点。

====== 直线 与 直线 初步判断

#quote(block: true)[
#strong[输入];：两条方向非零的直线 `A,B`。

#strong[输出];：平行、重合、垂直三个关系标记；重合直线也属于平行直线。

#strong[范围];：$O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
struct LineRelation {
    bool parallel;
    bool same;
    bool perpendicular;
};

LineRelation line_relation(Seg A, Seg B) {
    bool parallel = sign(A.v % B.v) == 0;
    bool same = parallel && sign(A.v % (B.s - A.s)) == 0;
    bool perpendicular = sign(dot(A.v, B.v)) == 0;
    return {parallel, same, perpendicular};
}
```

`parallel == false` 表示两直线相交；若需要多个初步判断，可分别读取标记后按题意提前返回。

====== 直线 与 直线 交点

两直线平行或重合时没有唯一交点，函数返回 `false`；否则把交点写入 `p`。

#quote(block: true)[
#strong[输入];：两条方向非零且不平行的直线。

#strong[输出];：有唯一交点返回 `true` 并写入 `p`，平行或重合返回 `false`。

#strong[范围];：$O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
bool line_intersection(Seg A, Seg B, Vec& p) {
    db det = A.v % B.v;
    if (sign(det) == 0) return false;
    p = A.s + A.v * ((B.v % (A.s - B.s)) / det);
    return true;
}
```

====== 直线 到 直线 距离

两条不平行直线相交，距离为 `0`；平行直线间的距离等于其中一条直线上任一点到另一条直线的距离。

#quote(block: true)[
#strong[输入];：两条方向非零的直线。

#strong[输出];：两直线的最短距离。

#strong[范围];：$O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
db dist_line_line(Seg A, Seg B) {
    if (sign(A.v % B.v) != 0) return 0;
    return fabsl((B.s - A.s) % A.v) / len(A.v);
}
```

====== 直线 与 线段 相交 / 距离

线段端点在直线两侧或其中一点在线上时，闭线段与直线相交。若不相交，最近点必在线段端点，因此距离是两个端点到直线距离的较小值。线段允许退化为点，直线方向必须非零。

#quote(block: true)[
#strong[输入];：方向非零的直线 `L` 和闭线段 `A`。

#strong[输出];：是否相交，以及直线到线段的最短距离。

#strong[范围];：每次查询 $O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
bool line_segment_intersect(Seg L, Seg A) {
    int side_s = sign(L.v % (A.s - L.s));
    int side_t = sign(L.v % (A.t - L.s));
    return side_s == 0 || side_t == 0 || side_s != side_t;
}

db dist_line_segment(Seg L, Seg A) {
    if (line_segment_intersect(L, A)) return 0;
    return min(dist_point_line(A.s, L), dist_point_line(A.t, L));
}
```

若只需要相交判断，直接调用 `line_segment_intersect`；若还需要最近点，在线段不相交时比较两个端点到直线的垂足即可。

===== 直线 与 点 关系（含初步判断）

有向直线 `L` 把平面分成左侧、线上、右侧。符号由 `L.v × (p-L.s)` 决定；更换直线方向会交换左右。

====== 直线 与 点 初步判断

#quote(block: true)[
#strong[输入];：方向非零的直线 `L` 和点 `p`。

#strong[输出];：`1` 左侧、`0` 在线上、`-1` 右侧。

#strong[范围];：$O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
int point_line_side(Vec p, Seg L) {
    return sign(L.v % (p - L.s));
}
```

====== 点 在 直线 上 的 投影（垂足）

垂足是 `p-L.s` 在方向向量 `L.v` 上的投影，再平移回直线上的点。

#quote(block: true)[
#strong[输入];：方向非零的直线 `L` 和点 `p`。

#strong[输出];：点 `p` 在直线 `L` 上的垂足。

#strong[范围];：$O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
Vec project_line(Vec p, Seg L) {
    return L.s + L.v * (dot(p - L.s, L.v) / len2(L.v));
}
```

====== 直线 到 点 距离

叉积绝对值是平行四边形面积，除以底边长度即得到点到直线的距离。

#quote(block: true)[
#strong[输入];：方向非零的直线 `L` 和点 `p`。

#strong[输出];：点 `p` 到直线 `L` 的距离。

#strong[范围];：$O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
db dist_point_line(Vec p, Seg L) {
    return fabsl(L.v % (p - L.s)) / len(L.v);
}
```

===== 线段 与 线段 关系（含初步判断）

闭线段相交包含端点接触和共线重叠。先看两线段所在直线是否平行、共线、垂直，再用方向叉积和端点在线段上的判断处理相交；零长度线段也可参与相交与距离计算。

====== 线段 与 线段 初步判断

#quote(block: true)[
#strong[输入];：两条线段 `A,B`。

#strong[输出];：共线、平行、垂直与是否相交的标记。

#strong[范围];：$O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
bool on_segment(Vec p, Seg L) {
    return sign(L.v % (p - L.s)) == 0 &&
           sign(dot(p - L.s, p - L.t)) <= 0;
}

bool segments_intersect(Seg A, Seg B) {
    int s1 = sign(A.v % (B.s - A.s));
    int s2 = sign(A.v % (B.t - A.s));
    int s3 = sign(B.v % (A.s - B.s));
    int s4 = sign(B.v % (A.t - B.s));

    if (s1 * s2 < 0 && s3 * s4 < 0) return true;
    return (s1 == 0 && on_segment(B.s, A)) ||
           (s2 == 0 && on_segment(B.t, A)) ||
           (s3 == 0 && on_segment(A.s, B)) ||
           (s4 == 0 && on_segment(A.t, B));
}

bool segments_parallel(Seg A, Seg B) {
    return sign(A.v % B.v) == 0;
}

bool segments_collinear(Seg A, Seg B) {
    return segments_parallel(A, B) && sign(A.v % (B.s - A.s)) == 0;
}

bool segments_perpendicular(Seg A, Seg B) {
    return sign(dot(A.v, B.v)) == 0;
}

bool segments_equal(Seg A, Seg B) {
    return (A.s == B.s && A.t == B.t) ||
           (A.s == B.t && A.t == B.s); // 无向线段相等
}
```

平行、垂直等方向关系要求两条线段长度非零；`on_segment` 和 `segments_intersect` 可以处理零长度线段。

====== 线段 与 线段 交点

不平行且相交时交点唯一。平行共线时，交集可能为空、一个点或一段线段；函数返回交集端点，因此返回 0、1 或 2 个点。

#quote(block: true)[
#strong[输入];：两条闭线段 `A,B`。

#strong[输出];：无交集返回空向量；单点接触返回一个点；共线重叠返回重叠部分的两个端点。

#strong[范围];：$O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
Vec line_intersection_point(Seg A, Seg B) {
    return A.s + A.v * ((B.v % (A.s - B.s)) / (A.v % B.v));
}

vector<Vec> segment_intersection(Seg A, Seg B) {
    if (!segments_intersect(A, B)) return {};

    if (sign(A.v % B.v) != 0)
        return {line_intersection_point(A, B)};

    vector<Vec> ans;
    for (Vec p : vector<Vec>{A.s, A.t, B.s, B.t}) {
        if (!on_segment(p, A) || !on_segment(p, B)) continue;
        bool repeated = false;
        for (Vec q : ans) if (p == q) repeated = true;
        if (!repeated) ans.push_back(p);
    }
    return ans;
}
```

====== 线段 到 线段 距离

若线段相交，距离为 `0`；否则最近点至少有一个是端点，因此取四个“端点到另一线段”的距离最小值。

#quote(block: true)[
#strong[输入];：两条闭线段 `A,B`，允许退化为点。

#strong[输出];：两线段间的最短距离。

#strong[范围];：$O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
db dist_to_seg(Vec p, Seg L); // 使用本节后面的点到线段距离模板

db dist_segment_segment(Seg A, Seg B) {
    if (segments_intersect(A, B)) return 0;
    return min({dist_to_seg(A.s, B), dist_to_seg(A.t, B),
                dist_to_seg(B.s, A), dist_to_seg(B.t, A)});
}
```

====== 线段间最近点对

若两线段相交，最近点对就是任意一个交点与自身；若不相交，至少一个最近点是某条线段的端点。因此分别把两条线段的端点投影到另一条线段，取距离最小的一对。

#quote(block: true)[
#strong[输入];：两条闭线段 `A,B`，允许退化为点。

#strong[输出];：两线段上的一对最近点及其距离；相交或重叠时返回同一个交点两次，距离为 `0`。

#strong[范围];：$O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
struct ClosestPair {
    Vec a, b;
    db distance;
};

Vec project_segment(Vec p, Seg L); // 使用本节后面的点到线段投影模板

ClosestPair segment_closest_points(Seg A, Seg B) {
    if (segments_intersect(A, B)) {
        vector<Vec> common = segment_intersection(A, B);
        return {common[0], common[0], 0};
    }

    ClosestPair Ans{A.s, project_segment(A.s, B), 0};
    Ans.distance = dist(Ans.a, Ans.b);

    auto relax = [&](Vec p, Vec q) {
        db distance = dist(p, q);
        if (distance < Ans.distance) Ans = {p, q, distance};
    };

    relax(A.t, project_segment(A.t, B));
    relax(project_segment(B.s, A), B.s);
    relax(project_segment(B.t, A), B.t);
    return Ans;
}
```

如果只需要距离，使用前面的 `dist_segment_segment`；需要最近点坐标时使用本函数。两者都允许零长度线段。

===== 线段 与 点 关系（含初步判断）

先用叉积判点在有向直线左侧、右侧或共线；共线时再用点积区分起点、终点、线段内部，以及从 `s` 指向 `t` 的反向延长线和正向延长线。

====== 线段 与 点 初步判断

#quote(block: true)[
#strong[输入];：点 `p` 和线段 `L`；允许 `L` 退化为点。

#strong[输出];：左侧、右侧、`s` 端点、`t` 端点、线段内部、`st` 负向延长线、`st` 正向延长线；退化线段外的点返回 `DegenerateOutside`。

#strong[范围];：$O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
enum class PointSegmentPos {
    Left, Right, Start, End, Inside, STNegative, STPositive, DegenerateOutside
};

PointSegmentPos point_segment_position(Vec p, Seg L) {
    if (L.s == L.t)
        return p == L.s ? PointSegmentPos::Start : PointSegmentPos::DegenerateOutside;

    int side = sign(L.v % (p - L.s));
    if (side > 0) return PointSegmentPos::Left;
    if (side < 0) return PointSegmentPos::Right;
    if (p == L.s) return PointSegmentPos::Start;
    if (p == L.t) return PointSegmentPos::End;
    if (sign(dot(p - L.s, L.v)) < 0) return PointSegmentPos::STNegative;
    if (sign(dot(p - L.t, L.v)) > 0) return PointSegmentPos::STPositive;
    return PointSegmentPos::Inside;
}
```

====== 点 在 线段所在直线 上 的 投影参数

沿线段方向的投影参数为 $k = \( \( p - s \) dot.op v \) \/ \| v \|^2$。`k<0` 在 `s` 端反向延长线上，`k>1` 在 `t` 端正向延长线上，$0 lt.eq k lt.eq 1$ 时垂足落在线段上。线段方向 `v` 必须非零。

#quote(block: true)[
#strong[输入];：点 `p` 和非退化线段 `L`。

#strong[输出];：点 `p` 在直线 `L.s + k*L.v` 上的投影参数 `k`。

#strong[范围];：$O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
db projection_parameter(Vec p, Seg L) {
    return dot(p - L.s, L.v) / len2(L.v);
}
```

====== 点 在线段 上 的 投影（截断垂足 / 最近点）

先求点到所在直线的垂足，再将投影参数限制到 $\[ 0 \, 1 \]$；垂足在线段外时，截断到最近端点。退化线段的最近点就是其唯一端点。

#quote(block: true)[
#strong[输入];：点 `p` 和线段 `L`；允许线段退化为点。

#strong[输出];：点到闭线段的最近点。

#strong[范围];：$O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
Vec project_segment(Vec p, Seg L) {
    if (L.s == L.t) return L.s;
    db k = dot(p - L.s, L.v) / len2(L.v);
    k = max((db)0, min((db)1, k));
    return L.s + L.v * k;
}
```

====== 线段 到 点 距离

点到线段的距离等于点到最近点的距离；平方距离版本可避免开方。

#quote(block: true)[
#strong[输入];：点 `p` 和线段 `L`；允许线段退化为点。

#strong[输出];：点到闭线段的最短距离。

#strong[范围];：$O \( 1 \)$ 时间、$O \( 1 \)$ 空间。
]

```cpp
db dist_to_seg(Vec p, Seg L) {
    Vec near = project_segment(p, L);
    return dist(p, near);
}
```

若只需要距离平方，将最后一行改为 `len2(p - near)`。点到直线的投影和距离使用前面的 `project_line`、`dist_point_line`；它们要求 `L.v` 非零。

