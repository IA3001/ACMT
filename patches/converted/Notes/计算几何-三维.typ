==== #text("计算几何-三维")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/Notes/计算几何-三维.md`]

- 空间向量 与 点
  - 空间向量 创建
  - 空间向量 运算
  - 空间向量 共线 与 共面
  - 空间向量 投影
- 空间直线 与 平面
  - 空间直线 创建
  - 平面 创建
  - 直线 与 直线 关系
  - 直线 与 平面 关系
  - 平面 与 平面 关系
- 空间线段
  - 线段 创建
  - 线段 与 线段 相交
  - 线段 与 平面 相交
- 空间距离
  - 点 到 直线 距离
  - 点 到 平面 距离
  - 异面直线 距离
  - 线段 到 线段 距离
- 三角形 与 四面体
  - 空间三角形 面积
  - 四面体 体积
  - 三角形 与 四面体 重心
  - 点 在 四面体 内
- 球
  - 球 创建
  - 点 与 球 关系
  - 三维最小球覆盖
  - 球面 切平面 与 切点
  - 球外点 引出的切平面
  - 球 与 直线 关系
  - 球 与 线段 相交
  - 球 与 平面 关系
  - 球 与 球 关系
  - 球面 交圆 与 切点
  - 两球 公切平面
- 空间圆 与 圆片
  - 空间圆 创建
  - 点 与 空间圆 关系
  - 直线 与 空间圆 相交
  - 直线 与 空间圆片 相交
  - 线段 与 空间圆 相交
  - 线段 与 空间圆片 相交
  - 平面 与 空间圆 相交
  - 平面 与 空间圆片 相交

===== 空间向量 与 点

三维点和向量统一用 `Vec3` 表示。点表示位置，向量表示位移。点积记为 `dot`，叉积记为 `cross`；向量长度平方为 `norm2`。

所有向量除法、单位化、直线方向和平面法向量都要求相关向量非零。浮点几何统一通过 `sign` 判断正负；若题目坐标和运算可以用整数精确表示，优先用足够宽的整数类型计算行列式，避免浮点误差。

====== 空间向量 创建

```cpp
using db = long double;
const db eps = 1e-12L;

int sign(db x) {
    if (x > eps) return 1;
    if (x < -eps) return -1;
    return 0;
}

struct Vec3 {
    db x = 0, y = 0, z = 0;

    Vec3() = default;
    Vec3(db x, db y, db z) : x(x), y(y), z(z) {}

    Vec3 operator+(Vec3 b) const { return Vec3(x + b.x, y + b.y, z + b.z); }
    Vec3 operator-(Vec3 b) const { return Vec3(x - b.x, y - b.y, z - b.z); }
    Vec3 operator*(db k) const { return Vec3(x * k, y * k, z * k); }
    Vec3 operator/(db k) const { return Vec3(x / k, y / k, z / k); }

    bool operator==(Vec3 b) const {
        return sign(x - b.x) == 0 && sign(y - b.y) == 0 && sign(z - b.z) == 0;
    }
};

db dot(Vec3 a, Vec3 b) { return a.x * b.x + a.y * b.y + a.z * b.z; }

Vec3 cross(Vec3 a, Vec3 b) {
    return Vec3(a.y * b.z - a.z * b.y,
                a.z * b.x - a.x * b.z,
                a.x * b.y - a.y * b.x);
}

db norm2(Vec3 a) { return dot(a, a); }
db len(Vec3 a) { return sqrtl(norm2(a)); }

bool unit(Vec3 a, Vec3& result) {
    db d = len(a);
    if (sign(d) == 0) return false;
    result = a / d;
    return true;
}
```

`unit` 对零向量返回 `false`，不会把零向量当成某个方向。容器按 ACMT 习惯用大写首字母，例如 `vector<Vec3> P`；单个 `Vec3` 变量使用小写。

====== 空间向量 运算

点积用于夹角、垂直判断和投影；叉积模长是平行四边形面积，方向垂直于两向量所在平面。

$ a dot.op b = \| a \| \| b \| cos theta \, #h(2em) \| a times b \| = \| a \| \| b \| sin theta . $

三个向量的混合积是有向平行六面体体积：

$ \[ a \, b \, c \] = a dot.op \( b times c \) . $

```cpp
db parallelogram_area(Vec3 a, Vec3 b) {
    return len(cross(a, b));
}

db triangle_area(Vec3 a, Vec3 b, Vec3 c) {
    return len(cross(b - a, c - a)) / 2;
}

db scalar_triple(Vec3 a, Vec3 b, Vec3 c) {
    return dot(a, cross(b, c));
}
```

三角形面积函数输入三个点；叉积函数参数是两条向量。混合积为零表示三向量张成的平行六面体体积为零。

====== 空间向量 共线 与 共面

两向量平行当且仅当叉积为零。三点共线等价于由它们构成的两个方向向量平行。四点共面等价于对应三个方向向量的混合积为零。

```cpp
bool parallel(Vec3 a, Vec3 b) {
    return sign(len(cross(a, b))) == 0;
}

bool collinear(Vec3 a, Vec3 b, Vec3 c) {
    return parallel(b - a, c - a);
}

bool coplanar(Vec3 a, Vec3 b, Vec3 c, Vec3 d) {
    return sign(scalar_triple(b - a, c - a, d - a)) == 0;
}
```

零向量也会被 `parallel` 判为平行；题目若要求方向有效，先检查方向向量非零。近退化输入受 `eps` 影响；大整数坐标可以用整数混合积判断。

====== 空间向量 投影

向量 `a` 在非零向量 `v` 上的投影为 $v \( a dot.op v \) \/ \| v \|^2$。点 `q` 到经过 `p`、方向为 `v` 的直线的垂足，是 `q-p` 在 `v` 上的投影再加回 `p`。

```cpp
Vec3 project_vector(Vec3 a, Vec3 v) {
    return v * (dot(a, v) / norm2(v));
}

Vec3 project_point_line(Vec3 q, Vec3 p, Vec3 v) {
    return p + project_vector(q - p, v);
}
```

`v` 必须非零。投影到线段时还要把参数限制在 $\[ 0 \, 1 \]$，不能直接使用直线投影。

===== 空间直线 与 平面

空间直线用“线上一点 + 非零方向向量”表示，平面用“平面上一点 + 非零法向量”表示。

```cpp
struct Line3 {
    Vec3 p, v; // x = p + t v, v != 0
};

struct Plane {
    Vec3 p, n; // n · (x - p) = 0, n != 0
};
```

平面也可写成 `n.x * x + n.y * y + n.z * z = d`，其中 `d = dot(n, p)`。点法式避免额外存储常数项，后面的代码统一使用点法式。

====== 空间直线 创建

由不同两点 `a,b` 确定的直线方向是 `b-a`。两点重合时无法确定唯一方向，创建失败。

```cpp
bool line_from_points(Vec3 a, Vec3 b, Line3& line) {
    Vec3 v = b - a;
    if (sign(norm2(v)) == 0) return false;
    line = {a, v};
    return true;
}
```

====== 平面 创建

由三点确定的平面要求三点不共线。两条不平行方向向量的叉积就是平面法向量。

```cpp
bool plane_from_points(Vec3 a, Vec3 b, Vec3 c, Plane& plane) {
    Vec3 n = cross(b - a, c - a);
    if (sign(norm2(n)) == 0) return false;
    plane = {a, n};
    return true;
}
```

法向量不需要单位化；距离和投影函数会除以法向量长度或长度平方。

====== 直线 与 直线 关系

两条空间直线可能相交、平行、重合或异面。先看方向叉积：若为零，再看位移是否与方向共线；若不为零，用混合积判断两线是否共面。非平行且共面时恰好相交。

```cpp
enum class LineRelation { Intersect, Parallel, Coincident, Skew };

LineRelation line_relation(Line3 a, Line3 b) {
    Vec3 direction_cross = cross(a.v, b.v);
    if (sign(norm2(direction_cross)) == 0) {
        return sign(len(cross(b.p - a.p, a.v))) == 0
            ? LineRelation::Coincident
            : LineRelation::Parallel;
    }
    return sign(dot(b.p - a.p, direction_cross)) == 0
        ? LineRelation::Intersect
        : LineRelation::Skew;
}

bool line_line_intersection(Line3 a, Line3 b, Vec3& point) {
    Vec3 normal = cross(a.v, b.v);
    db denominator = norm2(normal);
    if (sign(denominator) == 0) return false; // 平行或重合

    Vec3 delta = b.p - a.p;
    if (sign(dot(delta, normal)) != 0) return false; // 异面

    db t = dot(cross(delta, b.v), normal) / denominator;
    point = a.p + a.v * t;
    return true;
}
```

输入方向向量必须非零。交点函数只在唯一交点存在时返回 `true`；重合直线有无穷多个公共点，返回 `false`，需先用关系函数区分。

====== 直线 与 平面 关系

把直线 $x = p + t v$ 代入平面 $n dot.op \( x - p_0 \) = 0$：若 $n dot.op v eq.not 0$，有唯一交点；若点积为零，再检查直线上一点是否在平面上，以区分平行和直线在平面内。

```cpp
enum class LinePlaneRelation { Intersect, Parallel, Contained };

LinePlaneRelation line_plane_relation(Line3 line, Plane plane) {
    db denominator = dot(plane.n, line.v);
    if (sign(denominator) != 0) return LinePlaneRelation::Intersect;
    return sign(dot(plane.n, line.p - plane.p)) == 0
        ? LinePlaneRelation::Contained
        : LinePlaneRelation::Parallel;
}

bool line_plane_intersection(Line3 line, Plane plane, Vec3& point) {
    db denominator = dot(plane.n, line.v);
    if (sign(denominator) == 0) return false;
    db t = dot(plane.n, plane.p - line.p) / denominator;
    point = line.p + line.v * t;
    return true;
}
```

交点函数只处理唯一交点；平行且包含于平面的情况没有唯一交点，需用关系函数单独判断。

====== 平面 与 平面 关系

两个平面的法向量不平行时相交于一条直线；法向量平行时，再检查一个平面上的点是否在另一个平面上，以区分平行与重合。

```cpp
enum class PlaneRelation { Intersect, Parallel, Coincident };

PlaneRelation plane_relation(Plane a, Plane b) {
    if (sign(norm2(cross(a.n, b.n))) != 0) return PlaneRelation::Intersect;
    return sign(dot(a.n, b.p - a.p)) == 0
        ? PlaneRelation::Coincident
        : PlaneRelation::Parallel;
}

bool plane_plane_intersection(Plane a, Plane b, Line3& line) {
    Vec3 direction = cross(a.n, b.n);
    db denominator = norm2(direction);
    if (sign(denominator) == 0) return false; // 平行或重合

    db da = dot(a.n, a.p), dbb = dot(b.n, b.p);
    Vec3 point = (cross(b.n, direction) * da +
                  cross(direction, a.n) * dbb) / denominator;
    line = {point, direction};
    return true;
}
```

交线函数只在两平面相交于唯一一条直线时返回 `true`；平行或重合时返回 `false`，用关系函数区分。

===== 空间线段

====== 线段 创建

空间线段直接用两个端点表示。允许两个端点重合，此时线段退化为一个点。

```cpp
struct Segment3 {
    Vec3 a, b;
};
```

====== 线段 与 线段 相交

三维中两线段相交，必须共面。非平行时解两条支撑直线的参数，再检查参数是否都落在 $\[ 0 \, 1 \]$；平行时先判断共线，再求两个参数区间的重叠部分。返回结果分为不相交、一个交点、重叠线段三种。

```cpp
bool point_on_segment3(Vec3 q, Vec3 a, Vec3 b) {
    Vec3 v = b - a;
    if (sign(norm2(v)) == 0) return q == a;
    return sign(len(cross(q - a, v))) == 0 &&
           sign(dot(q - a, q - b)) <= 0;
}

struct SegmentHit3 {
    int type = 0; // 0: 不相交，1: 一个点，2: 重叠线段
    Vec3 a, b;
};

SegmentHit3 segment_intersection3(Vec3 a, Vec3 b, Vec3 c, Vec3 d) {
    Vec3 u = b - a, v = d - c, w = c - a;
    db uu = norm2(u), vv = norm2(v);
    bool u_zero = sign(uu) == 0, v_zero = sign(vv) == 0;

    if (u_zero && v_zero)
        return a == c ? SegmentHit3{1, a, a} : SegmentHit3{};
    if (u_zero)
        return point_on_segment3(a, c, d) ? SegmentHit3{1, a, a} : SegmentHit3{};
    if (v_zero)
        return point_on_segment3(c, a, b) ? SegmentHit3{1, c, c} : SegmentHit3{};

    Vec3 normal = cross(u, v);
    db denominator = norm2(normal);
    if (sign(denominator) != 0) {
        if (sign(dot(w, normal)) != 0) return {};
        db uw = dot(u, w), vw = dot(v, w), uv = dot(u, v);
        db s = (vv * uw - uv * vw) / denominator;
        db t = (uv * uw - uu * vw) / denominator;
        if (sign(s) < 0 || sign(s - 1) > 0 ||
            sign(t) < 0 || sign(t - 1) > 0) return {};
        s = clamp(s, (db)0, (db)1);
        t = clamp(t, (db)0, (db)1);
        Vec3 p = a + u * s, q = c + v * t;
        return {1, (p + q) / 2, (p + q) / 2};
    }

    if (sign(len(cross(w, u))) != 0) return {};
    db tc = dot(c - a, u) / uu;
    db td = dot(d - a, u) / uu;
    db left = max((db)0, min(tc, td));
    db right = min((db)1, max(tc, td));
    if (sign(left - right) > 0) return {};

    Vec3 p = a + u * clamp(left, (db)0, (db)1);
    Vec3 q = a + u * clamp(right, (db)0, (db)1);
    if (p == q) return {1, p, p};
    return {2, p, q};
}
```

共线重叠时 `a,b` 是重叠部分的两个端点，端点顺序沿第一条线段方向。非平行时先检查混合积，异面线段直接返回不相交。单次判定 $O \( 1 \)$。

====== 线段 与 平面 相交

线段端点到平面的有向距离异号时，线段穿过平面；一个端点恰在平面上时，交集为该端点；两个端点都在平面上时，整条线段都在平面内。

```cpp
struct SegmentPlaneHit3 {
    int type = 0; // 0: 不相交，1: 一个交点，2: 整条线段在平面内
    Vec3 a, b;
};

SegmentPlaneHit3 segment_plane_intersection(Vec3 a, Vec3 b, Plane plane) {
    db da = dot(plane.n, a - plane.p);
    db dbb = dot(plane.n, b - plane.p);
    int sa = sign(da), sb = sign(dbb);

    if (sa == 0 && sb == 0) return {2, a, b};
    if (sa == 0) return {1, a, a};
    if (sb == 0) return {1, b, b};
    if (sa == sb) return {};

    db t = da / (da - dbb);
    Vec3 point = a + (b - a) * t;
    return {1, point, point};
}
```

返回交点或共面线段的两个端点。平面法向量必须非零；单次计算 $O \( 1 \)$。

===== 空间距离

距离都返回非负长度。若只比较大小，优先比较距离平方，避免不必要的开方。

====== 点 到 直线 距离

点到直线距离等于叉积平行四边形面积除以底边长度：

$ d \( q \, l \) = frac(\| \( q - p \) times v \|, \| v \|) . $

```cpp
db dist_point_line(Vec3 q, Line3 line) {
    return len(cross(q - line.p, line.v)) / len(line.v);
}
```

要求直线方向 `line.v` 非零。单次计算 $O \( 1 \)$。

====== 点 到 平面 距离

点到平面的距离是法向量方向上的投影长度：

$ d \( q \, Pi \) = frac(\| n dot.op \( q - p \) \|, \| n \|) . $

```cpp
db dist_point_plane(Vec3 q, Plane plane) {
    return fabsl(dot(plane.n, q - plane.p)) / len(plane.n);
}
```

要求平面法向量 `plane.n` 非零。单次计算 $O \( 1 \)$。

====== 异面直线 距离

两条不平行直线的公垂线方向为 $v_1 times v_2$，异面直线距离是两线上一点的位移在该方向上的投影长度。平行时退化为点到直线距离。

```cpp
db dist_line_line(Line3 a, Line3 b) {
    Vec3 normal = cross(a.v, b.v);
    if (sign(norm2(normal)) == 0)
        return dist_point_line(b.p, a);
    return fabsl(dot(b.p - a.p, normal)) / len(normal);
}
```

直线方向必须非零。相交或重合时返回 `0`；单次计算 $O \( 1 \)$。

====== 线段 到 线段 距离

三维线段不共面时也可能有正距离。最近点可能落在线段内部，也可能落在端点；下面实现返回两线段最近距离的平方，再提供开方版本。

```cpp
db dist2_segment_segment(Vec3 a, Vec3 b, Vec3 c, Vec3 d) {
    Vec3 u = b - a, v = d - c, w = a - c;
    db aa = dot(u, u), bb = dot(u, v), cc = dot(v, v);
    db dd = dot(u, w), ee = dot(v, w);
    db denominator = aa * cc - bb * bb;
    db s_num, s_den = denominator, t_num, t_den = denominator;

    if (sign(aa) == 0 && sign(cc) == 0) return norm2(a - c);
    if (sign(aa) == 0) {
        db t = clamp(ee / cc, (db)0, (db)1);
        return norm2(a - (c + v * t));
    }
    if (sign(cc) == 0) {
        db s = clamp(-dd / aa, (db)0, (db)1);
        return norm2((a + u * s) - c);
    }

    if (sign(denominator) == 0) {
        s_num = 0;
        s_den = 1;
        t_num = ee;
        t_den = cc;
    } else {
        s_num = bb * ee - cc * dd;
        t_num = aa * ee - bb * dd;
        if (s_num < 0) {
            s_num = 0;
            t_num = ee;
            t_den = cc;
        } else if (s_num > s_den) {
            s_num = s_den;
            t_num = ee + bb;
            t_den = cc;
        }
    }

    if (t_num < 0) {
        t_num = 0;
        if (-dd < 0) s_num = 0;
        else if (-dd > aa) s_num = s_den;
        else { s_num = -dd; s_den = aa; }
    } else if (t_num > t_den) {
        t_num = t_den;
        if (-dd + bb < 0) s_num = 0;
        else if (-dd + bb > aa) s_num = s_den;
        else { s_num = -dd + bb; s_den = aa; }
    }

    db s = sign(s_num) == 0 ? 0 : s_num / s_den;
    db t = sign(t_num) == 0 ? 0 : t_num / t_den;
    return norm2((a + u * s) - (c + v * t));
}

db dist_segment_segment(Vec3 a, Vec3 b, Vec3 c, Vec3 d) {
    return sqrtl(max((db)0, dist2_segment_segment(a, b, c, d)));
}
```

端点重合、零长度线段和近似平行线段均有分支处理。单次计算 $O \( 1 \)$。浮点误差较大的题目应按坐标范围调整平行判定，不要把固定 `eps` 当作尺度无关的精确谓词。

===== 三角形 与 四面体

====== 空间三角形 面积

三角形面积是两条边叉积模长的一半，代码已在“空间向量 运算”中给出 `triangle_area`。三点共线时面积为 `0`。

====== 四面体 体积

四面体有向体积是三重积的六分之一；普通体积取绝对值。

$ V_(A B C D) = frac(\| \( B - A \) dot.op \( \( C - A \) times \( D - A \) \) \|, 6) . $

```cpp
db tetrahedron_volume6(Vec3 a, Vec3 b, Vec3 c, Vec3 d) {
    return dot(b - a, cross(c - a, d - a));
}

db tetrahedron_volume(Vec3 a, Vec3 b, Vec3 c, Vec3 d) {
    return fabsl(tetrahedron_volume6(a, b, c, d)) / 6;
}
```

`tetrahedron_volume6` 保留朝向符号；四点共面时返回 `0`。单次计算 $O \( 1 \)$。

====== 三角形 与 四面体 重心

均匀三角形薄片的重心是三个顶点的平均值；均匀四面体实体的重心是四个顶点的平均值。

```cpp
Vec3 triangle_centroid(Vec3 a, Vec3 b, Vec3 c) {
    return (a + b + c) / 3;
}

Vec3 tetrahedron_centroid(Vec3 a, Vec3 b, Vec3 c, Vec3 d) {
    return (a + b + c + d) / 4;
}
```

这两个公式只适用于均匀密度的三角形薄片和四面体实体；顶点质量、非均匀密度要按题意加权。

====== 点 在 四面体 内

把四面体按查询点拆成四个有向小四面体。非退化四面体内的点，其四个小体积与原体积同号或为零。

```cpp
bool point_in_tetrahedron(Vec3 q, Vec3 a, Vec3 b, Vec3 c, Vec3 d) {
    db whole = tetrahedron_volume6(a, b, c, d);
    int direction = sign(whole);
    if (direction == 0) return false;

    db Part[4] = {
        tetrahedron_volume6(q, b, c, d),
        tetrahedron_volume6(a, q, c, d),
        tetrahedron_volume6(a, b, q, d),
        tetrahedron_volume6(a, b, c, q)
    };
    for (db volume : Part)
        if (sign(volume) * direction < 0) return false;
    return true; // 内部或边界
}
```

退化四面体返回 `false`。该判定包含边界，单次计算 $O \( 1 \)$；接近共面时要关注浮点误差。

===== 球

三维球用球心和半径表示。这里处理的是#strong[球面];与点、直线、平面的关系；若题目说球体，“包含”通常还要把球面内部算入。

```cpp
struct Sphere {
    Vec3 o;
    db r;
};

Sphere make_sphere(Vec3 o, db r) {
    return {o, r};
}
```

半径要求非负。`Sphere` 中的 `o` 是 `Vec3` 变量，按命名约定使用小写。

====== 球 创建

四个不共面的点确定唯一外接球。令 $u = b - a \, v = c - a \, w = d - a$，设球心为 $a + x$，则

$ 2 u dot.op x = \| u \|^2 \, quad 2 v dot.op x = \| v \|^2 \, quad 2 w dot.op x = \| w \|^2 . $

用克拉默法则解三元方程；若四点共面则没有唯一外接球。

```cpp
bool sphere_through_four(Vec3 a, Vec3 b, Vec3 c, Vec3 d, Sphere& sphere) {
    Vec3 u = b - a, v = c - a, w = d - a;
    db denominator = dot(u, cross(v, w));
    if (sign(denominator) == 0) return false;

    Vec3 offset = (cross(v, w) * (norm2(u) / 2) +
                   cross(w, u) * (norm2(v) / 2) +
                   cross(u, v) * (norm2(w) / 2)) / denominator;
    sphere = {a + offset, len(offset)};
    return true;
}
```

一次计算 $O \( 1 \)$。四点接近共面时分母很小，外接球对误差敏感；题目若存在这种输入，应使用更高精度或精确判定退化。

====== 点 与 球 关系

比较点心距平方与半径平方，避免开方。返回 `-1` 表示球面内侧，`0` 表示球面上，`1` 表示球面外侧。

```cpp
int point_sphere_relation(Vec3 p, Sphere sphere) {
    return sign(norm2(p - sphere.o) - sphere.r * sphere.r);
}
```

若要判断点是否在#strong[球体内或球面上];，返回值小于等于 `0` 即可。单次计算 $O \( 1 \)$。

====== 三维最小球覆盖

随机打乱点的顺序后，用 Welzl 随机增量法维护当前最小球。递归处理中，若新点已在当前球内则无需改变；若在球外，就把它加入边界点集合重新求解。三维空间中，确定最小球最多需要 4 个边界点。

边界点集合最多 4 个，直接枚举由 1、2、3、4 个点确定的候选球，并检查它是否覆盖集合内所有点。这样也能处理共线、共面等退化的边界点组。

#quote(block: true)[
#strong[输入];：任意空间点集，允许重复点、共线点和共面点。

#strong[输出];：包含全部点的最小球；空集返回 `false`。

#strong[范围];：随机打乱后期望 $O \( n \)$ 时间，递归栈 $O \( n \)$；极端排列下时间可能退化。需要 `<random>` 与 `<chrono>`。
]

```cpp
bool smallest_sphere_of_small_set(const vector<Vec3>& P, Sphere& best) {
    bool found = false;
    auto add_candidate = [&](Sphere candidate) {
        if (sign(candidate.r) < 0) return;
        for (Vec3 p : P)
            if (point_sphere_relation(p, candidate) > 0) return;
        if (!found || candidate.r < best.r) {
            best = candidate;
            found = true;
        }
    };

    int n = P.size();
    for (int i = 0; i < n; ++i)
        add_candidate({P[i], 0});

    for (int i = 0; i < n; ++i)
        for (int j = i + 1; j < n; ++j)
            add_candidate({(P[i] + P[j]) / 2, len(P[i] - P[j]) / 2});

    for (int i = 0; i < n; ++i)
        for (int j = i + 1; j < n; ++j)
            for (int k = j + 1; k < n; ++k) {
                Vec3 u = P[j] - P[i], v = P[k] - P[i];
                Vec3 normal = cross(u, v);
                db nn = norm2(normal);
                if (sign(nn) == 0) continue;
                Vec3 offset = (cross(v, normal) * norm2(u) +
                               cross(normal, u) * norm2(v)) / (2 * nn);
                add_candidate({P[i] + offset, len(offset)});
            }

    for (int i = 0; i < n; ++i)
        for (int j = i + 1; j < n; ++j)
            for (int k = j + 1; k < n; ++k)
                for (int l = k + 1; l < n; ++l) {
                    Sphere candidate;
                    if (sphere_through_four(P[i], P[j], P[k], P[l], candidate))
                        add_candidate(candidate);
                }
    return found;
}

bool welzl_sphere(vector<Vec3>& P, int n, vector<Vec3>& R, Sphere& sphere) {
    if (n == 0 || R.size() == 4)
        return smallest_sphere_of_small_set(R, sphere);

    Vec3 p = P[n - 1];
    if (welzl_sphere(P, n - 1, R, sphere) &&
        point_sphere_relation(p, sphere) <= 0) return true;

    R.push_back(p);
    bool found = welzl_sphere(P, n - 1, R, sphere);
    R.pop_back();
    return found;
}

bool minimum_enclosing_sphere3(vector<Vec3> P, Sphere& sphere) {
    if (P.empty()) return false;
    mt19937 rng(chrono::steady_clock::now().time_since_epoch().count());
    shuffle(P.begin(), P.end(), rng);
    vector<Vec3> R;
    return welzl_sphere(P, P.size(), R, sphere);
}
```

小集合候选球的枚举次数是常数。三点候选使用所在平面的外接圆；四点候选复用前面的 `sphere_through_four`。随机增量法的递归深度最多为点数，点数特别大时需留意进程栈限制；半径比较与包含判断沿用本文的 `sign` 精度。

====== 球面 切平面 与 切点

球面上点 `q` 处的切平面法向量就是半径方向 `q - o`。输入点必须在球面上，且球半径非零；否则切平面不唯一或不存在。

```cpp
bool sphere_tangent_plane_at(Sphere sphere, Vec3 q, Plane& tangent) {
    if (sign(sphere.r) == 0) return false;
    if (sign(norm2(q - sphere.o) - sphere.r * sphere.r) != 0) return false;
    tangent = {q, q - sphere.o};
    return true;
}
```

此处 `q` 同时就是切点；平面不要求单位法向量。单次构造 $O \( 1 \)$。

====== 球外点 引出的切平面

从球外一点看球，切平面不是有限条，而是一族绕球心连线旋转的平面；用角度 `angle` 指定其中一个。返回的 `touch` 是该平面的球面切点，线段 `q-touch` 也是球的切线。

```cpp
bool sphere_tangent_plane_from_point(Sphere sphere, Vec3 q, db angle,
                                     Plane& tangent, Vec3& touch) {
    if (sign(sphere.r) <= 0) return false;
    Vec3 direction = q - sphere.o;
    db distance = len(direction);
    if (sign(distance) == 0 || sign(distance - sphere.r) < 0) return false;

    Vec3 axis = direction / distance;
    if (sign(distance - sphere.r) == 0) {
        touch = q;
        tangent = {touch, axis};
        return true;
    }

    Vec3 base = fabsl(axis.x) <= fabsl(axis.y) && fabsl(axis.x) <= fabsl(axis.z)
        ? Vec3(1, 0, 0)
        : (fabsl(axis.y) <= fabsl(axis.z) ? Vec3(0, 1, 0) : Vec3(0, 0, 1));
    Vec3 e1 = cross(axis, base) / len(cross(axis, base));
    Vec3 e2 = cross(axis, e1);
    db cosine = sphere.r / distance;
    db sine = sqrtl(max((db)0, 1 - cosine * cosine));
    Vec3 normal = axis * cosine +
        (e1 * cosl(angle) + e2 * sinl(angle)) * sine;
    touch = sphere.o + normal * sphere.r;
    tangent = {touch, normal};
    return true;
}
```

若 `q` 在球内则无实切平面；若 `q` 在球面上只有该点处的一张切平面；若 `q` 在球外，角度参数连续变化会扫过全部切平面。单次构造 $O \( 1 \)$。

====== 球 与 直线 关系

把球心投影到直线，比较球心到直线的距离和半径。交点是最近点沿直线方向向两侧移动得到的点。

```cpp
int sphere_line_intersections(Sphere sphere, Line3 line,
                              array<Vec3, 2>& Points) {
    db vv = norm2(line.v);
    if (sign(vv) == 0) return 0;

    db t = dot(sphere.o - line.p, line.v) / vv;
    Vec3 closest = line.p + line.v * t;
    db height2 = sphere.r * sphere.r - norm2(closest - sphere.o);
    int relation = sign(height2);
    if (relation < 0) return 0;

    if (relation == 0) {
        Points[0] = closest;
        return 1;
    }
    Vec3 offset = line.v * sqrtl(height2 / vv);
    Points[0] = closest - offset;
    Points[1] = closest + offset;
    return 2;
}
```

返回交点个数 `0/1/2`。返回 `1` 时 `Points[0]` 就是切点；输入直线方向非零，单次计算 $O \( 1 \)$。

====== 球 与 线段 相交

直线与球的交点不一定落在线段上，因此直接解参数方程并保留 $t in \[ 0 \, 1 \]$ 的根。返回 `0/1/2` 个交点；切线段时只返回一个点。

```cpp
int sphere_segment_intersections(Sphere sphere, Vec3 a, Vec3 b,
                                array<Vec3, 2>& Points) {
    Vec3 v = b - a, w = a - sphere.o;
    db aa = norm2(v);
    if (sign(aa) == 0) {
        if (point_sphere_relation(a, sphere) != 0) return 0;
        Points[0] = a;
        return 1;
    }

    db bb = 2 * dot(w, v);
    db cc = norm2(w) - sphere.r * sphere.r;
    db discriminant = bb * bb - 4 * aa * cc;
    int relation = sign(discriminant);
    if (relation < 0) return 0;

    db root = sqrtl(max((db)0, discriminant));
    db t1 = (-bb - root) / (2 * aa);
    db t2 = (-bb + root) / (2 * aa);
    int count = 0;
    for (db t : {t1, t2}) {
        if (sign(t) < 0 || sign(t - 1) > 0) continue;
        Vec3 point = a + v * clamp(t, (db)0, (db)1);
        if (count == 0 || !(Points[count - 1] == point))
            Points[count++] = point;
    }
    return count;
}
```

退化线段作为一个点处理；二次方程的重根只返回一次。输入半径非负；单次计算 $O \( 1 \)$。

====== 球 与 平面 关系

球心到平面的距离大于半径时不相交；相切时交集退化为一点；相交时交集是圆。交圆圆心是球心在平面上的投影。

```cpp
int sphere_plane_section(Sphere sphere, Plane plane,
                         Vec3& center, db& radius) {
    db nn = norm2(plane.n);
    if (sign(nn) == 0) return 0;

    db signed_distance = dot(plane.n, sphere.o - plane.p);
    db height2 = sphere.r * sphere.r - signed_distance * signed_distance / nn;
    int relation = sign(height2);
    if (relation < 0) return 0;

    center = sphere.o - plane.n * (signed_distance / nn);
    radius = sqrtl(max((db)0, height2));
    return relation == 0 ? 1 : 2; // 相切点 / 交圆
}
```

返回 `0` 表示不相交，`1` 表示相切，`2` 表示交圆；相切时 `center` 就是切点且 `radius=0`。单次计算 $O \( 1 \)$。

====== 球 与 球 关系

两球球面的位置关系由球心距 $d$ 与 $r_1 + r_2$、$\| r_1 - r_2 \|$ 比较。若球心重合，需单独处理同心球面；球面可能相同，也可能不相交。

```cpp
enum class SphereRelation {
    Disjoint,
    ExternalTangent,
    IntersectCircle,
    InternalTangent,
    Contained,
    Coincident
};

SphereRelation sphere_relation(Sphere a, Sphere b) {
    db d = len(a.o - b.o);
    if (sign(d) == 0)
        return sign(a.r - b.r) == 0
            ? SphereRelation::Coincident
            : SphereRelation::Contained;

    db sum = a.r + b.r;
    db difference = fabsl(a.r - b.r);
    if (sign(d - sum) > 0) return SphereRelation::Disjoint;
    if (sign(d - sum) == 0) return SphereRelation::ExternalTangent;
    if (sign(d - difference) < 0) return SphereRelation::Contained;
    if (sign(d - difference) == 0) return SphereRelation::InternalTangent;
    return SphereRelation::IntersectCircle;
}
```

这里的 `Contained` 表示一个球面完全位于另一个球面的内侧且两球面不相交，不代表两个球面有公共点。

====== 球面 交圆 与 切点

两球面相交时，公共部分是一个圆。交圆圆心在两球心连线上，交圆所在平面的法向量沿球心连线。外切或内切时交圆退化为一个切点；两球面重合时公共部分是整个球面。

```cpp
int sphere_sphere_intersection(Sphere a, Sphere b,
                               Vec3& center, Vec3& normal, db& radius) {
    SphereRelation relation = sphere_relation(a, b);
    if (relation == SphereRelation::Disjoint ||
        relation == SphereRelation::Contained) return 0;
    if (relation == SphereRelation::Coincident) return -1;

    Vec3 direction = b.o - a.o;
    db distance = len(direction);
    normal = direction / distance;
    db x = (distance * distance + a.r * a.r - b.r * b.r) / (2 * distance);
    center = a.o + normal * x;
    radius = sqrtl(max((db)0, a.r * a.r - x * x));
    return (relation == SphereRelation::ExternalTangent ||
            relation == SphereRelation::InternalTangent) ? 1 : 2;
}
```

返回 `0` 表示不相交，`1` 表示相切，`2` 表示交圆，`-1` 表示两球面重合。相切时 `center` 就是切点且 `radius=0`；单次计算 $O \( 1 \)$。

====== 两球 公切平面

三维中两球的公切对象是平面；一般存在绕两球心连线的一族公切平面，不能只返回有限条切线。用角度 `angle` 指定其中一张，并同时返回两个切点。`internal=false` 表示两球切点位于球心连线的同侧；`internal=true` 表示异侧。若两球心距不足以形成对应类型的切平面，返回 `false`。

```cpp
bool common_tangent_plane(Sphere a, Sphere b, bool internal, db angle,
                          Plane& tangent, Vec3& touch_a, Vec3& touch_b) {
    if (sign(a.r) <= 0 || sign(b.r) <= 0) return false;
    Vec3 delta = b.o - a.o;
    db distance = len(delta);
    if (sign(distance) == 0) return false;

    db cosine = (internal ? a.r + b.r : a.r - b.r) / distance;
    if (fabsl(cosine) > 1 + eps) return false;
    cosine = clamp(cosine, (db)-1, (db)1);

    Vec3 axis = delta / distance;
    Vec3 base = fabsl(axis.x) <= fabsl(axis.y) && fabsl(axis.x) <= fabsl(axis.z)
        ? Vec3(1, 0, 0)
        : (fabsl(axis.y) <= fabsl(axis.z) ? Vec3(0, 1, 0) : Vec3(0, 0, 1));
    Vec3 e1 = cross(axis, base) / len(cross(axis, base));
    Vec3 e2 = cross(axis, e1);
    db sine = sqrtl(max((db)0, 1 - cosine * cosine));
    Vec3 normal = axis * cosine +
        (e1 * cosl(angle) + e2 * sinl(angle)) * sine;

    touch_a = a.o + normal * a.r;
    touch_b = b.o + normal * (internal ? -b.r : b.r);
    tangent = {touch_a, normal};
    return true;
}
```

若 `|cosine|=1`，公切平面唯一；若小于 `1`，随 `angle` 形成一族。每次构造 $O \( 1 \)$。共心球不使用这段参数化代码，应先按球面是否重合单独处理。

===== 空间圆 与 圆片

空间圆不能只用圆心和半径表示，还需要所在平面。这里将圆定义为：满足 `dot(n, x - o) = 0` 且 `|x-o| = r` 的点集；圆片则把等式改为 `|x-o| <= r`。法向量 `n` 不必单位化，但必须非零。

```cpp
struct Circle3 {
    Vec3 o;
    db r;
    Vec3 n;
};

struct Disk3 {
    Vec3 o;
    db r;
    Vec3 n;
};
```

圆片边界就是对应的空间圆。半径要求非负；圆片的内部和边界都包含在内。

====== 空间圆 创建

由圆心、半径、法向量可直接创建。由三个不共线点创建时，先用叉积确定所在平面，再解圆心。代码沿用三角形面积的叉积结构，并对共线三点返回 `false`。

```cpp
bool circle3_from_three_points(Vec3 a, Vec3 b, Vec3 c, Circle3& circle) {
    Vec3 u = b - a, v = c - a;
    Vec3 n = cross(u, v);
    db nn = norm2(n);
    if (sign(nn) == 0) return false;

    Vec3 offset = (cross(v, n) * norm2(u) +
                   cross(n, u) * norm2(v)) / (2 * nn);
    Vec3 o = a + offset;
    circle = {o, len(offset), n};
    return true;
}
```

三点共线时不存在唯一圆；单次创建 $O \( 1 \)$。已知球与平面相交得到交圆时，也可直接令 `Circle3{o, r, plane.n}`。

====== 点 与 空间圆 关系

先判断点是否在圆所在平面，再比较到圆心的距离平方与半径平方。返回 `-1/0/1` 分别表示圆内侧（但不在圆上）、圆上、圆外侧；不在圆平面上的点返回 `2`。

```cpp
int point_circle3_relation(Vec3 q, Circle3 circle) {
    if (sign(dot(circle.n, q - circle.o)) != 0) return 2;
    return sign(norm2(q - circle.o) - circle.r * circle.r);
}

bool point_in_disk3(Vec3 q, Disk3 disk) {
    if (sign(dot(disk.n, q - disk.o)) != 0) return false;
    return sign(norm2(q - disk.o) - disk.r * disk.r) <= 0;
}
```

`point_circle3_relation == 0` 才表示点在圆周上；圆内侧的点不属于圆周，但属于对应圆片。单次判断 $O \( 1 \)$。

====== 直线 与 空间圆 相交

直线不平行圆平面时，先求直线与圆平面的唯一交点，再判断该点是否在圆周上。直线位于圆平面内时，求圆心到直线的垂足，并沿直线方向补出零个、一个或两个交点。

```cpp
int line_circle3_intersections(Line3 line, Circle3 circle,
                               array<Vec3, 2>& Points) {
    db denominator = dot(circle.n, line.v);
    if (sign(denominator) != 0) {
        db t = dot(circle.n, circle.o - line.p) / denominator;
        Vec3 point = line.p + line.v * t;
        if (sign(norm2(point - circle.o) - circle.r * circle.r) != 0) return 0;
        Points[0] = point;
        return 1;
    }

    if (sign(dot(circle.n, line.p - circle.o)) != 0) return 0;
    db vv = norm2(line.v);
    if (sign(vv) == 0) return 0;
    db t = dot(circle.o - line.p, line.v) / vv;
    Vec3 closest = line.p + line.v * t;
    db height2 = circle.r * circle.r - norm2(closest - circle.o);
    int relation = sign(height2);
    if (relation < 0) return 0;
    if (relation == 0) {
        Points[0] = closest;
        return 1;
    }
    Vec3 offset = line.v * sqrtl(height2 / vv);
    Points[0] = closest - offset;
    Points[1] = closest + offset;
    return 2;
}
```

返回 `0/1/2` 个交点。返回 `1` 且直线位于圆平面内时，直线与圆相切，`Points[0]` 是切点；直线方向必须非零。单次计算 $O \( 1 \)$。

====== 直线 与 空间圆片 相交

直线不平行圆片所在平面时，最多交于一点，且该点必须落在圆片内。直线位于圆片平面内时，交集为弦、切点或空集。

```cpp
struct DiskLineHit3 {
    int type = 0; // 0: 空，1: 一个点，2: 一条线段
    Vec3 a, b;
};

DiskLineHit3 line_disk3_intersection(Line3 line, Disk3 disk) {
    db denominator = dot(disk.n, line.v);
    if (sign(denominator) != 0) {
        db t = dot(disk.n, disk.o - line.p) / denominator;
        Vec3 point = line.p + line.v * t;
        if (!point_in_disk3(point, disk)) return {};
        return {1, point, point};
    }

    if (sign(dot(disk.n, line.p - disk.o)) != 0) return {};
    db vv = norm2(line.v);
    if (sign(vv) == 0) {
        if (!point_in_disk3(line.p, disk)) return {};
        return {1, line.p, line.p};
    }

    db t = dot(disk.o - line.p, line.v) / vv;
    Vec3 closest = line.p + line.v * t;
    db height2 = disk.r * disk.r - norm2(closest - disk.o);
    int relation = sign(height2);
    if (relation < 0) return {};
    if (relation == 0) return {1, closest, closest};
    Vec3 offset = line.v * sqrtl(height2 / vv);
    return {2, closest - offset, closest + offset};
}
```

共面时 `type=2` 返回弦的两个端点；相切时 `type=1` 返回切点。输入直线方向可为零，零方向按单点处理。单次计算 $O \( 1 \)$。

====== 线段 与 空间圆 相交

先求线段与圆所在平面的交集。若线段只交于一个点，检查该点是否在圆周上；若整条线段共面，则求支撑直线与圆的交点，再只保留参数落在 $\[ 0 \, 1 \]$ 的点。退化线段按一个点处理。

```cpp
int segment_circle3_intersections(Segment3 segment, Circle3 circle,
                                  array<Vec3, 2>& Points) {
    SegmentPlaneHit3 hit = segment_plane_intersection(
        segment.a, segment.b, {circle.o, circle.n});
    if (hit.type == 0) return 0;
    if (hit.type == 1) {
        if (point_circle3_relation(hit.a, circle) != 0) return 0;
        Points[0] = hit.a;
        return 1;
    }

    Vec3 direction = segment.b - segment.a;
    db dd = norm2(direction);
    if (sign(dd) == 0) {
        if (point_circle3_relation(segment.a, circle) != 0) return 0;
        Points[0] = segment.a;
        return 1;
    }

    array<Vec3, 2> Candidates;
    int count = line_circle3_intersections(
        {segment.a, direction}, circle, Candidates);
    int result = 0;
    for (int i = 0; i < count; ++i) {
        db t = dot(Candidates[i] - segment.a, direction) / dd;
        if (sign(t) < 0 || sign(t - 1) > 0) continue;
        Vec3 point = segment.a + direction * clamp(t, (db)0, (db)1);
        if (result == 0 || !(Points[result - 1] == point))
            Points[result++] = point;
    }
    return result;
}
```

返回线段上的交点数 `0/1/2`；相切点和恰好落在线段端点上的交点都会保留。单次计算 $O \( 1 \)$。

====== 线段 与 空间圆片 相交

线段不在圆片平面内时，至多交于一个点，检查该点是否落在圆片内。线段共面时，圆片是凸集，交集仍为空、一个点或一条线段；沿线段参数求出圆内区间，再与 $\[ 0 \, 1 \]$ 相交即可。

```cpp
DiskLineHit3 segment_disk3_intersection(Segment3 segment, Disk3 disk) {
    SegmentPlaneHit3 hit = segment_plane_intersection(
        segment.a, segment.b, {disk.o, disk.n});
    if (hit.type == 0) return {};
    if (hit.type == 1) {
        if (!point_in_disk3(hit.a, disk)) return {};
        return {1, hit.a, hit.a};
    }

    Vec3 direction = segment.b - segment.a;
    db dd = norm2(direction);
    if (sign(dd) == 0) {
        if (!point_in_disk3(segment.a, disk)) return {};
        return {1, segment.a, segment.a};
    }

    db center_t = dot(disk.o - segment.a, direction) / dd;
    Vec3 closest = segment.a + direction * center_t;
    db height2 = disk.r * disk.r - norm2(closest - disk.o);
    if (sign(height2) < 0) return {};

    db delta_t = sqrtl(max((db)0, height2 / dd));
    db left = max((db)0, center_t - delta_t);
    db right = min((db)1, center_t + delta_t);
    if (sign(left - right) > 0) return {};

    Vec3 a = segment.a + direction * clamp(left, (db)0, (db)1);
    Vec3 b = segment.a + direction * clamp(right, (db)0, (db)1);
    if (a == b) return {1, a, a};
    return {2, a, b};
}
```

`type=0/1/2` 分别表示空集、一个交点、交线段；共面相切时返回 `type=1`。零长度线段按点处理。单次计算 $O \( 1 \)$。

====== 平面 与 空间圆 相交

空间圆与另一个平面的交集可能是空集、一个切点、两个点，或整个圆。两平面不平行时先求交线，再调用 `line_circle3_intersections`；两平面重合时整个圆都在交集中。

```cpp
int plane_circle3_intersections(Plane plane, Circle3 circle,
                                array<Vec3, 2>& Points) {
    Plane circle_plane{circle.o, circle.n};
    PlaneRelation relation = plane_relation(plane, circle_plane);
    if (relation == PlaneRelation::Coincident) return -1;
    if (relation == PlaneRelation::Parallel) return 0;

    Line3 line;
    plane_plane_intersection(plane, circle_plane, line);
    return line_circle3_intersections(line, circle, Points);
}
```

返回 `-1` 表示整圆重合，`0/1/2` 表示离散交点数。两平面相交时交线一定存在；单次计算 $O \( 1 \)$。

====== 平面 与 空间圆片 相交

两平面相交时，交集是一条直线；这条直线与圆片的交集是弦、切点或空集。平面重合时交集是整个圆片。

```cpp
struct DiskPlaneHit3 {
    int type = 0; // 0: 空，1: 一个点，2: 一条弦，3: 整个圆片
    Vec3 a, b;
};

DiskPlaneHit3 plane_disk3_intersection(Plane plane, Disk3 disk) {
    Plane disk_plane{disk.o, disk.n};
    PlaneRelation relation = plane_relation(plane, disk_plane);
    if (relation == PlaneRelation::Parallel) return {};
    if (relation == PlaneRelation::Coincident) return {3, disk.o, disk.o};

    Line3 line;
    plane_plane_intersection(plane, disk_plane, line);
    Circle3 boundary{disk.o, disk.r, disk.n};
    array<Vec3, 2> Points;
    int count = line_circle3_intersections(line, boundary, Points);
    if (count == 0) return {};
    if (count == 1) return {1, Points[0], Points[0]};
    return {2, Points[0], Points[1]};
}
```

`type=2` 返回圆片与平面的交弦；`type=1` 返回相切点；`type=3` 表示两平面重合，交集是整个圆片。单次计算 $O \( 1 \)$。

