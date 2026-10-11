==== #text("计算几何-凸包")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/Notes/计算几何-凸包.md`]

- 凸包 的 创建（含规范化）
- 凸包 的 面积与周长
- 凸包直径与宽度（旋转卡壳）
- 凸包 与 凸包 关系（含初步判断）
  - 凸包 与 凸包 距离
  - 凸包 与 凸包 交点
  - 凸包 与 凸包 区域交集（静态半平面交）
- 凸包 与 直线 关系（含初步判断）
  - 凸包 与 直线 距离
  - 凸包 与 直线 交点
  - 凸包 被 直线 裁剪（保留左侧）
- 凸包 与 线段 关系（含初步判断）
  - 凸包 与 线段 距离
  - 凸包 与 线段 交点
- 凸包 与 点 关系（含初步判断）
  - 凸包 与 点 距离（外）
  - 凸包 与 点 距离（内）

===== 凸包 的 创建（含规范化）

将任意平面点集转成不重复存储首尾点的凸包，返回顺序为逆时针。重复点会先删除；若所有点共线，结果只保留线段的两个端点。

#quote(block: true)[
#strong[输入];：任意点集 `points`，允许空集、重复点、单点和共线点集。

#strong[输出];：逆时针凸包 `hull`；空集返回空向量，单点返回一个点，共线点集返回两个端点。

#strong[范围];：$O \( n log n \)$ 时间、$O \( n \)$ 额外空间。排序按坐标精确比较，叉积转向判断沿用 ACMT 的 `sign`。
]

```cpp
vector<Vec> convex_hull_clean(vector<Vec> points) {
    sort(points.begin(), points.end(), [](Vec a, Vec b) {
        if (a.x != b.x) return a.x < b.x;
        return a.y < b.y;
    });
    points.erase(unique(points.begin(), points.end(), [](Vec a, Vec b) {
        return a.x == b.x && a.y == b.y;
    }), points.end());

    int n = points.size();
    if (n <= 2) return points;

    vector<Vec> hull(2 * n);
    int k = 0;
    for (Vec p : points) {
        while (k > 1 && sign((hull[k - 1] - hull[k - 2]) %
                             (p - hull[k - 1])) <= 0) --k;
        hull[k++] = p;
    }
    int lower = k;
    for (int i = n - 2; i >= 0; --i) {
        Vec p = points[i];
        while (k > lower && sign((hull[k - 1] - hull[k - 2]) %
                                 (p - hull[k - 1])) <= 0) --k;
        hull[k++] = p;
    }
    hull.resize(k - 1); // 不重复存储首尾点
    return hull;
}
```

后面的凸包距离、相交函数都只接收这里得到的凸包或等价的、已按要求排序的凸包；不会在函数内部替原始点集建凸包。

===== 凸包 的 面积与周长

凸包顶点按逆时针排列时，面积用鞋带公式，周长累加相邻顶点距离。顶点不重复存储首尾点；空集和单点面积、周长均为 `0`，线段的周长按闭合退化多边形定义为线段长度的两倍。

#quote(block: true)[
#strong[输入];：已按逆时针排列、不重复存储首尾点的凸包；允许空集、点和线段。

#strong[输出];：凸包面积与闭合周长。

#strong[范围];：每项 $O \( n \)$ 时间、$O \( 1 \)$ 额外空间。
]

```cpp
db convex_area(const vector<Vec>& hull) {
    db area2 = 0;
    for (int i = 0; i < (int)hull.size(); i++)
        area2 += hull[i] % hull[(i + 1) % hull.size()];
    return abs(area2) / 2;
}

db convex_perimeter(const vector<Vec>& hull) {
    int n = hull.size();
    if (n <= 1) return 0;
    if (n == 2) return 2 * dist(hull[0], hull[1]);
    db perimeter = 0;
    for (int i = 0; i < n; i++)
        perimeter += dist(hull[i], hull[(i + 1) % n]);
    return perimeter;
}
```

===== 凸包直径与宽度（旋转卡壳）

凸包直径是凸包内最远两点距离。对固定边 `hull[i] -> hull[i+1]`，离该边最远的顶点称为对踵点；凸包边按环序转动时，对踵点也沿凸包单调前进，因此两个指针各走一圈即可求直径。

凸包宽度是两条平行支撑线之间的最小距离。固定一条边时，宽度等于最大点到该边的距离；枚举所有边并同步维护对踵点即可在线性时间求最小值。

#quote(block: true)[
#strong[输入];：逆时针严格凸包，不重复存储首尾点；允许空集、点和线段。

#strong[输出];：直径的两个端点下标、直径长度，以及最小宽度。

#strong[范围];：$O \( n \)$ 时间、$O \( 1 \)$ 额外空间。
]

```cpp
struct ConvexDiameter {
    int i, j;
    db dist2;
};

ConvexDiameter convex_diameter(const vector<Vec>& hull) {
    int n = hull.size();
    if (n == 0) return {-1, -1, 0};
    if (n == 1) return {0, 0, 0};
    if (n == 2) return {0, 1, len2(hull[1] - hull[0])};

    ConvexDiameter Ans{0, 1, len2(hull[1] - hull[0])};
    auto relax = [&](int i, int j) {
        db d2 = len2(hull[i] - hull[j]);
        if (d2 > Ans.dist2) Ans = {i, j, d2};
    };

    int j = 1;
    for (int i = 0; i < n; i++) {
        int ni = (i + 1) % n;
        Vec edge = hull[ni] - hull[i];
        auto height = [&](int k) {
            return abs(edge % (hull[k] - hull[i]));
        };
        while (sign(height((j + 1) % n) - height(j % n)) > 0) ++j;
        relax(i, j % n);
        relax(ni, j % n);
        if (sign(height((j + 1) % n) - height(j % n)) == 0) {
            relax(i, (j + 1) % n);
            relax(ni, (j + 1) % n);
        }
    }
    return Ans;
}

db convex_width(const vector<Vec>& hull) {
    int n = hull.size();
    if (n <= 2) return 0;
    db width = numeric_limits<db>::infinity();
    int j = 1;
    for (int i = 0; i < n; i++) {
        int ni = (i + 1) % n;
        Vec edge = hull[ni] - hull[i];
        auto height = [&](int k) {
            return abs(edge % (hull[k] - hull[i]));
        };
        while (sign(height((j + 1) % n) - height(j % n)) > 0) ++j;
        width = min(width, height(j % n) / len(edge));
    }
    return width;
}
```

叉积并列时两侧顶点都可能构成直径端点，所以 `convex_diameter` 会同时检查 `j` 和 `j+1`。代码返回平方直径，调用处需要实际长度时再开方：`sqrt(convex_diameter(hull).dist2)`。宽度对点、线段退化凸包按 `0` 返回。

===== 凸包 与 凸包 关系（含初步判断）

====== 凸包 与 凸包 初步判断（相交）

给定两个凸包，判断它们是否有公共点；边界接触也算相交。凸包允许退化为点或线段。退化时分别用点定位、点在线段上和线段相交处理；两个二维凸包则构造差集 $K = A - B = A + \( - B \)$，判断原点是否在 $K$ 内或边界上。

#quote(block: true)[
#strong[输入];：两个已去重的凸包 `A`、`B`，按逆时针排列且不重复存储首尾点；允许点和线段。

#strong[输出];：相交或接触返回 `true`，否则返回 `false`。

#strong[范围];：$O \( n + m \)$ 时间、$O \( n + m \)$ 额外空间；不在函数内把任意点集转成凸包，也不枚举所有边对。
]

```cpp
bool on_segment(Vec a, Vec b, Vec p) {
    return sign((b - a) % (p - a)) == 0 &&
           sign(dot(p - a, p - b)) <= 0;
}

bool segments_intersect(Vec a, Vec b, Vec c, Vec d) {
    int s1 = sign((b - a) % (c - a));
    int s2 = sign((b - a) % (d - a));
    int s3 = sign((d - c) % (a - c));
    int s4 = sign((d - c) % (b - c));
    if (s1 * s2 < 0 && s3 * s4 < 0) return true;
    return (s1 == 0 && on_segment(a, b, c)) ||
           (s2 == 0 && on_segment(a, b, d)) ||
           (s3 == 0 && on_segment(c, d, a)) ||
           (s4 == 0 && on_segment(c, d, b));
}

int lowest_vertex(const vector<Vec>& p) {
    int k = 0;
    for (int i = 1; i < (int)p.size(); ++i)
        if (p[i].y < p[k].y || (p[i].y == p[k].y && p[i].x < p[k].x)) k = i;
    return k;
}

int angle_half(Vec v) {
    return (v.y > 0 || (v.y == 0 && v.x >= 0)) ? 0 : 1;
}

bool angle_less(Vec a, Vec b) {
    if (angle_half(a) != angle_half(b)) return angle_half(a) < angle_half(b);
    return sign(a % b) > 0;
}

bool same_direction(Vec a, Vec b) {
    return sign(a % b) == 0 && sign(dot(a, b)) > 0;
}

vector<Vec> minkowski_convex(vector<Vec> a, vector<Vec> b) {
    rotate(a.begin(), a.begin() + lowest_vertex(a), a.end());
    rotate(b.begin(), b.begin() + lowest_vertex(b), b.end());
    int n = a.size(), m = b.size(), i = 0, j = 0;
    Vec current = a[0] + b[0];
    vector<Vec> sum{current};

    while (i < n || j < m) {
        Vec edge;
        Vec ea = a[(i + 1) % n] - a[i % n];
        Vec eb = b[(j + 1) % m] - b[j % m];
        if (i == n) edge = eb, ++j;
        else if (j == m) edge = ea, ++i;
        else if (same_direction(ea, eb)) edge = ea + eb, ++i, ++j;
        else if (angle_less(ea, eb)) edge = ea, ++i;
        else edge = eb, ++j;
        current = current + edge;
        sum.push_back(current);
    }
    sum.pop_back(); // 删除累计回到起点的末尾点
    return sum;
}

bool convex_intersects_hull(const vector<Vec>& A, const vector<Vec>& B) {
    int n = A.size(), m = B.size();
    if (n == 0 || m == 0) return false;

    auto same_point = [](Vec a, Vec b) {
        return sign((a - b).x) == 0 && sign((a - b).y) == 0;
    };
    if (n == 1 && m == 1) return same_point(A[0], B[0]);
    if (n == 1 && m == 2) return on_segment(B[0], B[1], A[0]);
    if (n == 2 && m == 1) return on_segment(A[0], A[1], B[0]);
    if (n == 1) return point_in_convex(B, A[0]) >= 0;
    if (m == 1) return point_in_convex(A, B[0]) >= 0;
    if (n == 2 && m == 2) return segments_intersect(A[0], A[1], B[0], B[1]);

    auto segment_polygon = [&](Vec a, Vec b, const vector<Vec>& poly) {
        if (point_in_convex(poly, a) >= 0 || point_in_convex(poly, b) >= 0) return true;
        for (int i = 0; i < (int)poly.size(); ++i)
            if (segments_intersect(a, b, poly[i], poly[(i + 1) % poly.size()])) return true;
        return false;
    };
    if (n == 2) return segment_polygon(A[0], A[1], B);
    if (m == 2) return segment_polygon(B[0], B[1], A);

    vector<Vec> negB = B;
    for (Vec& p : negB) p = p * -1;
    vector<Vec> K = minkowski_convex(A, negB);
    return point_in_convex(K, Vec(0, 0)) >= 0;
}
```

二维分支用 Minkowski 差处理；点和线段退化在进入该分支前处理。函数只接受已建好的凸包。

====== 凸包 与 凸包 距离

两凸包距离是其中任意两点距离的最小值。若二者相交或接触，距离为 `0`。两个二维凸包可构造差集 $K = A - B = A + \( - B \)$：若原点在 $K$ 内或边界上，距离为 `0`；否则答案是原点到 $K$ 边界的最短距离。点和线段退化分别走点段、段段或段多边形分支。

#quote(block: true)[
#strong[输入];：两个已建好的凸包 `A`、`B`，按逆时针排列且不重复存储首尾点；允许点和线段。

#strong[输出];：两凸包之间的最短距离；相交或接触时为 `0`。空凸包返回正无穷。

#strong[范围];：二维凸包为 $O \( n + m \)$；含点/线段退化的分支也为 $O \( n + m \)$。额外空间 $O \( n + m \)$，不枚举两多边形的所有边对。
]

以下距离函数复用上一节的 `segments_intersect`、`minkowski_convex` 和 `on_segment`；所有输入均为凸包，不在函数内预处理任意点集。

```cpp
db dist2_point_segment(Vec p, Vec a, Vec b) {
    Vec v = b - a;
    db vv = dot(v, v);
    if (a.x == b.x && a.y == b.y) return dot(p - a, p - a);
    db t = max((db)0, min((db)1, dot(p - a, v) / vv));
    Vec near = a + v * t;
    return dot(p - near, p - near);
}

db dist2_segment_segment(Vec a, Vec b, Vec c, Vec d) {
    if (segments_intersect(a, b, c, d)) return 0;
    return min({dist2_point_segment(a, c, d), dist2_point_segment(b, c, d),
                dist2_point_segment(c, a, b), dist2_point_segment(d, a, b)});
}

db dist2_point_polygon(Vec p, const vector<Vec>& poly) {
    if (point_in_convex(poly, p) >= 0) return 0;
    db ans = numeric_limits<db>::infinity();
    for (int i = 0; i < (int)poly.size(); ++i)
        ans = min(ans, dist2_point_segment(p, poly[i], poly[(i + 1) % poly.size()]));
    return ans;
}

db dist2_segment_polygon(Vec a, Vec b, const vector<Vec>& poly) {
    if (point_in_convex(poly, a) >= 0 || point_in_convex(poly, b) >= 0) return 0;
    db ans = numeric_limits<db>::infinity();
    for (int i = 0; i < (int)poly.size(); ++i) {
        Vec c = poly[i], d = poly[(i + 1) % poly.size()];
        if (segments_intersect(a, b, c, d)) return 0;
        ans = min(ans, dist2_segment_segment(a, b, c, d));
    }
    return ans;
}

db convex_distance(const vector<Vec>& A, const vector<Vec>& B) {
    int n = A.size(), m = B.size();
    if (n == 0 || m == 0) return numeric_limits<db>::infinity();
    if (n == 1 && m == 1) return dist(A[0], B[0]);
    if (n == 1 && m == 2) return sqrt(dist2_point_segment(A[0], B[0], B[1]));
    if (n == 2 && m == 1) return sqrt(dist2_point_segment(B[0], A[0], A[1]));
    if (n == 2 && m == 2) return sqrt(dist2_segment_segment(A[0], A[1], B[0], B[1]));
    if (n == 1) return sqrt(dist2_point_polygon(A[0], B));
    if (m == 1) return sqrt(dist2_point_polygon(B[0], A));
    if (n == 2) return sqrt(dist2_segment_polygon(A[0], A[1], B));
    if (m == 2) return sqrt(dist2_segment_polygon(B[0], B[1], A));

    vector<Vec> negB = B;
    for (Vec& p : negB) p = p * -1;
    vector<Vec> K = minkowski_convex(A, negB);
    if (point_in_convex(K, Vec(0, 0)) >= 0) return 0;

    db ans = numeric_limits<db>::infinity();
    for (int i = 0; i < (int)K.size(); ++i)
        ans = min(ans, dist2_point_segment(Vec(0, 0), K[i], K[(i + 1) % K.size()]));
    return sqrt(ans);
}
```

先显式建包，再分别调用两个接口：

```cpp
vector<Vec> hullA = convex_hull_clean(pointsA);
vector<Vec> hullB = convex_hull_clean(pointsB);
bool intersects = convex_intersects_hull(hullA, hullB);
db distance = convex_distance(hullA, hullB);
```

`convex_intersects_hull` 和 `convex_distance` 都只接收凸包；不会在内部判断输入是不是凸包，也不会替原始点集做预处理。

====== 凸包 与 凸包 交点

两个凸包的公共区域本身仍是凸集。用半平面交求出公共区域的顶点后，这些顶点就是交集多边形的顶点；其中落在对方边上的点是边界交点，落在一方内部的点则是被包含的原凸包顶点。

下面的接口返回公共区域的顶点，按逆时针排列且不重复首尾点。空向量表示没有正面积交集；仅点接触或边接触时也返回空向量，这类退化接触由前面的 `convex_intersects_hull` 判断。利用两个凸包的边方向已经按环序单调旋转，分别旋转到最小方向角后线性归并，不再通用排序，复杂度为 $O \( n + m \)$。

====== 凸包 与 凸包 区域交集（静态半平面交）

凸包 `A`、`B` 的交集等于二者所有边的内侧半平面之交。逆时针边 `p -> p+v` 的内部在左侧，因此直接把两凸包的边作为半平面输入双端队列半平面交。

#quote(block: true)[
#strong[输入];：两个逆时针、正面积凸包；不重复存储首尾点，且相邻边不共线。

#strong[输出];：正面积交集的逆时针顶点；无正面积交集返回空向量。

#strong[范围];：$O \( n + m \)$ 时间、$O \( n + m \)$ 空间。点/线段退化及仅边界接触请先用相交判定分支处理。
]

```cpp
struct HullHalfPlane {
    Vec p, v;
};

int hull_angle_half(Vec v) {
    return (v.y > 0 || (v.y == 0 && v.x >= 0)) ? 0 : 1;
}

bool hull_angle_less(Vec a, Vec b) {
    if (hull_angle_half(a) != hull_angle_half(b))
        return hull_angle_half(a) < hull_angle_half(b);
    return sign(a % b) > 0;
}

Vec hull_halfplane_cross(HullHalfPlane A, HullHalfPlane B) {
    return A.p + A.v * (((B.p - A.p) % B.v) / (A.v % B.v));
}

bool outside_hull_halfplane(HullHalfPlane L, Vec p) {
    return sign(L.v % (p - L.p)) < 0;
}

vector<Vec> hull_halfplane_intersection(vector<HullHalfPlane> halfplanes) {
    // 输入按方向角非降序排列。
    vector<HullHalfPlane> unique_lines;
    for (HullHalfPlane L : halfplanes) {
        if (!unique_lines.empty() &&
            sign(unique_lines.back().v % L.v) == 0 &&
            sign(dot(unique_lines.back().v, L.v)) > 0) {
            HullHalfPlane& last = unique_lines.back();
            if (sign(last.v % (L.p - last.p)) > 0) last = L;
        } else {
            unique_lines.push_back(L);
        }
    }

    deque<HullHalfPlane> active;
    for (HullHalfPlane L : unique_lines) {
        while (active.size() > 1 && outside_hull_halfplane(
                   L, hull_halfplane_cross(active[active.size() - 2], active.back())))
            active.pop_back();
        while (active.size() > 1 && outside_hull_halfplane(
                   L, hull_halfplane_cross(active[0], active[1])))
            active.pop_front();
        if (!active.empty() && sign(active.back().v % L.v) == 0) return {};
        active.push_back(L);
    }
    while (active.size() > 2 && outside_hull_halfplane(
               active.front(), hull_halfplane_cross(active[active.size() - 2], active.back())))
        active.pop_back();
    while (active.size() > 2 && outside_hull_halfplane(
               active.back(), hull_halfplane_cross(active[0], active[1])))
        active.pop_front();
    if (active.size() < 3) return {};

    vector<Vec> polygon;
    for (int i = 0; i < (int)active.size(); ++i)
        polygon.push_back(hull_halfplane_cross(active[i], active[(i + 1) % active.size()]));
    db area2 = 0;
    for (int i = 0; i < (int)polygon.size(); ++i)
        area2 += polygon[i] % polygon[(i + 1) % polygon.size()];
    if (sign(area2) <= 0) return {};
    return polygon;
}

vector<HullHalfPlane> sorted_hull_edges(const vector<Vec>& hull) {
    int n = hull.size();
    vector<HullHalfPlane> edges;
    for (int i = 0; i < n; ++i) {
        Vec p = hull[i], v = hull[(i + 1) % n] - p;
        edges.push_back({p, v});
    }
    int first = 0;
    for (int i = 1; i < n; ++i)
        if (hull_angle_less(edges[i].v, edges[first].v)) first = i;
    rotate(edges.begin(), edges.begin() + first, edges.end());
    return edges;
}

vector<Vec> convex_intersection(const vector<Vec>& A, const vector<Vec>& B) {
    vector<HullHalfPlane> edges_a = sorted_hull_edges(A);
    vector<HullHalfPlane> edges_b = sorted_hull_edges(B);
    vector<HullHalfPlane> halfplanes;
    halfplanes.reserve(edges_a.size() + edges_b.size());
    int i = 0, j = 0;
    while (i < (int)edges_a.size() || j < (int)edges_b.size()) {
        if (j == (int)edges_b.size() ||
            (i < (int)edges_a.size() && hull_angle_less(edges_a[i].v, edges_b[j].v)))
            halfplanes.push_back(edges_a[i++]);
        else
            halfplanes.push_back(edges_b[j++]);
    }
    return hull_halfplane_intersection(halfplanes);
}
```

调用 `convex_intersection(A, B)` 得到交集多边形；返回的每个顶点都属于交集边界。此模板处理正面积交集，不负责输出点接触或线段接触的退化结果。

===== 凸包 与 直线 关系（含初步判断）

对严格凸包，线性函数在顶点环序上只有一个极大点和一个极小点。下面的 `convex_support_vertex` 用二分找支撑顶点，后续直线查询复用它。

```cpp
template <class Direction>
int convex_extreme_vertex(const vector<Vec>& hull, Direction direction) {
    int n = hull.size(), left = 0;
    auto compare = [&](int i, int j) {
        return sign(direction(hull[j]) % (hull[j] - hull[i]));
    };
    auto is_extreme = [&](int i, int& side) {
        side = compare((i + 1) % n, i);
        return side >= 0 && compare(i, (i + n - 1) % n) < 0;
    };

    int left_side;
    int right = is_extreme(0, left_side) ? 1 : n;
    while (left + 1 < right) {
        int mid = (left + right) / 2, mid_side;
        if (is_extreme(mid, mid_side)) return mid;
        if (left_side != mid_side ? left_side < mid_side
                                  : left_side == compare(left, mid)) {
            right = mid;
        } else {
            left = mid;
            left_side = mid_side;
        }
    }
    return left;
}

int convex_support_vertex(const vector<Vec>& hull, Vec direction) {
    return convex_extreme_vertex(hull, [&](Vec) { return direction; });
}
```

====== 凸包 与 直线 距离

直线侧值是线性函数 `L.v % (p-L.s)`。分别二分最大值和最小值对应的支撑顶点：若两者异号或其中一个为 `0`，直线与凸包相交或相切；否则，离直线最近的支撑顶点给出最小距离。查询时间 $O \( log n \)$。

#quote(block: true)[
#strong[输入];：逆时针凸包 `hull` 和非零方向直线 `L`；允许空凸包、点和线段。

#strong[输出];：直线到凸包的最短距离；空凸包返回正无穷。

#strong[范围];：$O \( log n \)$ 时间、$O \( 1 \)$ 额外空间；要求严格凸包，点和线段退化单独处理。
]

```cpp
db dist_line_convex(const vector<Vec>& hull, Seg L) {
    if (hull.empty()) return numeric_limits<db>::infinity();
    if (hull.size() == 1)
        return abs(L.v % (hull[0] - L.s)) / len(L.v);
    if (hull.size() == 2) {
        db side_a = L.v % (hull[0] - L.s);
        db side_b = L.v % (hull[1] - L.s);
        if (sign(side_a) * sign(side_b) <= 0) return 0;
        return min(abs(side_a), abs(side_b)) / len(L.v);
    }
    int max_index = convex_support_vertex(hull, L.v);
    int min_index = convex_support_vertex(hull, L.v * -1);
    db max_side = L.v % (hull[max_index] - L.s);
    db min_side = L.v % (hull[min_index] - L.s);
    if (sign(min_side) <= 0 && sign(max_side) >= 0) return 0;
    return min(abs(min_side), abs(max_side)) / len(L.v);
}
```

====== 凸包 与 直线 交点

凸包是凸集，因此一条直线与其交集只能是空集、一个点或一段线段。对严格凸包，先二分线性侧值的最大点和最小点；它们把边界分成两条单调链，分别二分侧值从正到负的位置，得到至多两个交点。时间 $O \( log n \)$。

#quote(block: true)[
#strong[输入];：逆时针凸包 `hull` 和非零方向直线 `L`；允许空凸包、点和线段。

#strong[输出];：直线与凸包交集中的不同点，至多两个。

#strong[范围];：严格凸包为 $O \( log n \)$ 时间、$O \( 1 \)$ 额外空间；点和线段退化为 $O \( 1 \)$。
]

```cpp
vector<Vec> line_convex_intersections(const vector<Vec>& hull, Seg L) {
    vector<Vec> points;
    auto push = [&](Vec p) {
        for (Vec q : points)
            if (sign((p - q).x) == 0 && sign((p - q).y) == 0) return;
        points.push_back(p);
    };
    int n = hull.size();
    if (n == 0) return points;
    if (n == 1) {
        if (sign(L.v % (hull[0] - L.s)) == 0) push(hull[0]);
        return points;
    }
    if (n == 2) {
        db side_a = L.v % (hull[0] - L.s);
        db side_b = L.v % (hull[1] - L.s);
        if (sign(side_a) == 0) push(hull[0]);
        if (sign(side_b) == 0) push(hull[1]);
        if (sign(side_a) * sign(side_b) < 0)
            push(hull[0] + (hull[1] - hull[0]) * (side_a / (side_a - side_b)));
        return points;
    }

    auto side = [&](int i) { return L.v % (hull[i] - L.s); };
    int max_index = convex_support_vertex(hull, L.v);
    int min_index = convex_support_vertex(hull, L.v * -1);
    if (sign(side(max_index)) < 0 || sign(side(min_index)) > 0) return points;

    auto add_chain = [&](int start, int finish, int step) {
        int count = step == 1 ? (finish - start + n) % n
                              : (start - finish + n) % n;
        auto index_at = [&](int offset) {
            return (start + step * offset + n * (offset + 1)) % n;
        };
        if (sign(side(start)) == 0) {
            push(hull[start]);
            if (count > 0 && sign(side(index_at(1))) == 0) push(hull[index_at(1)]);
            return;
        }
        int left = 0, right = count;
        while (right - left > 1) {
            int mid = (left + right) / 2;
            if (sign(side(index_at(mid))) <= 0) right = mid;
            else left = mid;
        }
        db side_left = side(index_at(left)), side_right = side(index_at(right));
        if (sign(side_right) == 0) {
            push(hull[index_at(right)]);
            if (right < count && sign(side(index_at(right + 1))) == 0)
                push(hull[index_at(right + 1)]);
        } else if (sign(side_left) * sign(side_right) < 0) {
            Vec a = hull[index_at(left)], b = hull[index_at(right)];
            push(a + (b - a) * (side_left / (side_left - side_right)));
        }
    };
    add_chain(max_index, min_index, 1);
    add_chain(max_index, min_index, -1);
    return points;
}
```

====== 凸包 被 直线 裁剪（保留左侧）

给定凸包和有向直线 `L`，保留直线左侧的闭半平面。这里“左侧”由方向决定：点 `p` 在左侧，当且仅当 `L.v % (p-L.s) >= 0`。反转直线方向，保留区域也随之反转。

沿凸包边界依次处理每条有向边 `a -> b`，分四种情况：

#figure(
  align(center)[#table(
    columns: 3,
    align: (auto,auto,auto,),
    table.header([`a`], [`b`], [输出],),
    table.hline(),
    [内], [内], [`b`],
    [内], [外], [边 `ab` 与裁剪直线的交点],
    [外], [内], [交点、`b`],
    [外], [外], [不输出],
  )]
  , kind: table
  )

按原凸包的环序输出，结果仍保持逆时针顺序。点和线段也可用同一套逐边处理：线段被裁成空集、一个点或一段线段时，结果对应返回空向量、一个顶点或两个端点。

这是#strong[单条直线裁剪];，时间为 $O \( n \)$。若有 $m$ 条约束依次裁剪，最坏复杂度为 $O \( n m \)$；需要大量半平面约束时应使用半平面交算法，不能把重复调用本函数称为 $O \( n + m \)$。

#quote(block: true)[
#strong[输入];：逆时针凸包 `hull`（不重复存储首尾点）和非零方向直线 `L`；保留 `L` 左侧及直线上的点。空凸包也允许。

#strong[输出];：裁剪后的凸包；允许输出空集、点或线段。

#strong[范围];：$O \( n \)$ 时间、$O \( n \)$ 额外空间。输入为点、线段时也按闭半平面逐边裁剪。
]

```cpp
vector<Vec> clip_convex_left(const vector<Vec>& hull, Seg L) {
    vector<Vec> result;
    int n = hull.size();
    if (n == 0) return result;

    auto side = [&](Vec p) {
        return L.v % (p - L.s);
    };
    auto same_point = [](Vec a, Vec b) {
        return sign((a - b).x) == 0 && sign((a - b).y) == 0;
    };
    auto push = [&](Vec p) {
        if (result.empty() || !same_point(result.back(), p))
            result.push_back(p);
    };

    for (int i = 0; i < n; ++i) {
        Vec a = hull[i], b = hull[(i + 1) % n];
        db side_a = side(a), side_b = side(b);
        bool inside_a = sign(side_a) >= 0;
        bool inside_b = sign(side_b) >= 0;

        if (inside_a && inside_b) {
            push(b);
        } else if (inside_a && !inside_b) {
            Vec cross_point = a + (b - a) * (side_a / (side_a - side_b));
            push(cross_point);
        } else if (!inside_a && inside_b) {
            Vec cross_point = a + (b - a) * (side_a / (side_a - side_b));
            push(cross_point);
            push(b);
        }
    }

    if (result.size() > 1 && same_point(result.front(), result.back()))
        result.pop_back();
    return result;
}
```

交点比例来自有向侧值沿边线性变化：边上点 `a+t(b-a)` 的侧值为 `side_a+t(side_b-side_a)`；令它等于 `0`，得到 `t=side_a/(side_a-side_b)`。代码只在一端内、一端外时计算交点，此时分母非零。

例如，正方形 `[(0,0),(2,0),(2,2),(0,2)]` 被 `Seg::st(Vec(0,1), Vec(1,1))` 裁剪后，保留上半部分，结果是 `[(0,1),(2,1),(2,2),(0,2)]`；把直线反向，结果就是下半部分。实际调用：

```cpp
vector<Vec> hull = {
    Vec(0, 0), Vec(2, 0), Vec(2, 2), Vec(0, 2)
};
Seg L = Seg::st(Vec(0, 1), Vec(1, 1));
vector<Vec> upper = clip_convex_left(hull, L);
```

若裁剪直线恰好经过凸包顶点，顶点可能由相邻两条边同时产生；代码会合并相邻重复点及首尾重复点。`Seg::v` 必须非零，否则直线没有定义，调用前应保证这一条件。

===== 凸包 与 线段 关系（含初步判断）

====== 凸包 与 线段 距离

线段与凸包相交或端点位于凸包内时，距离为 `0`；否则，最近点必在凸包边界上。逐边计算线段到凸包边的距离并取最小值。该单次查询为 $O \( n \)$，复用前文 `segments_intersect`、`dist2_segment_segment` 和 `dist2_point_segment`，不会枚举线段与凸包边的所有配对。固定凸包上的大量线段查询需要额外预处理最近特征结构；本模板不含该预处理。

#quote(block: true)[
#strong[输入];：查询线段端点 `a,b` 和逆时针凸包 `hull`；允许空凸包、点和线段。

#strong[输出];：线段到凸包的最短距离；空凸包返回正无穷。

#strong[范围];：$O \( n \)$ 时间、$O \( 1 \)$ 额外空间。
]

```cpp
db dist_segment_convex(Vec a, Vec b, const vector<Vec>& hull) {
    int n = hull.size();
    if (n == 0) return numeric_limits<db>::infinity();
    if (point_in_convex(hull, a) >= 0 || point_in_convex(hull, b) >= 0) return 0;
    if (n == 1) return sqrt(dist2_point_segment(hull[0], a, b));

    db ans2 = numeric_limits<db>::infinity();
    for (int i = 0; i < n; ++i) {
        Vec c = hull[i], d = hull[(i + 1) % n];
        if (segments_intersect(a, b, c, d)) return 0;
        ans2 = min(ans2, dist2_segment_segment(a, b, c, d));
    }
    return sqrt(ans2);
}
```

====== 凸包 与 线段 交点

线段与凸包的公共部分是空集、点或线段。先用 $O \( log n \)$ 的点定位检查线段端点，再对线段所在直线调用前面的 $O \( log n \)$ 凸包交点查询，并过滤出落在线段上的点。共线重叠时，直线查询会返回凸包边界端点，过滤后得到重叠部分端点。

#quote(block: true)[
#strong[输入];：查询线段端点 `a,b` 和逆时针凸包 `hull`；允许空凸包、点和线段。

#strong[输出];：线段与凸包交集中的不同端点；返回空向量表示不相交。

#strong[范围];：严格凸包为 $O \( log n \)$ 时间、$O \( 1 \)$ 额外空间；点和线段退化为 $O \( 1 \)$。
]

```cpp
vector<Vec> segment_convex_intersections(Vec a, Vec b,
                                         const vector<Vec>& hull) {
    vector<Vec> points;
    auto push = [&](Vec p) {
        for (Vec q : points)
            if (sign((p - q).x) == 0 && sign((p - q).y) == 0) return;
        points.push_back(p);
    };
    int n = hull.size();
    if (n == 0) return points;
    if (sign((b - a).x) == 0 && sign((b - a).y) == 0) {
        if (point_in_convex(hull, a) >= 0) push(a);
        return points;
    }
    if (point_in_convex(hull, a) >= 0) push(a);
    if (point_in_convex(hull, b) >= 0) push(b);
    for (Vec p : line_convex_intersections(hull, Seg::st(a, b)))
        if (on_segment(a, b, p)) push(p);
    return points;
}
```

===== 凸包 与 点 关系（含初步判断）

====== 凸包 与 点 初步判断

======= 定义

输入为逆时针凸多边形 `p[0..n-1]`，不重复存储首尾点。以 `p[0]` 为扇形顶点，射线 `p[0] -> p[i]` 将多边形划分成三角形。对查询点 `q`：先用两条外侧边界判断是否落在扇形范围，再二分所在扇形，最后只检查一个三角形。因此每次查询 $O \( log n \)$。

约定返回 `-1` 表示外部、`0` 表示边界、`1` 表示内部。边界必须单独处理；若凸包保留了同方向的连续共线点，应先压缩中间点，避免二分方向重复。

#quote(block: true)[
#strong[输入];：逆时针凸多边形 `p`（允许点、线段退化）和查询点 `q`。

#strong[输出];：`-1` 外部、`0` 边界、`1` 内部。

#strong[范围];：$O \( log n \)$ 时间、$O \( 1 \)$ 额外空间；多边形顶点不重复存储首尾点。
]

======= Code

```cpp
int point_in_convex(const vector<Vec>& p, Vec q) {
    int n = p.size();
    if (n == 0) return -1;
    if (n == 1) return sign((q - p[0]).x) == 0 &&
                       sign((q - p[0]).y) == 0 ? 0 : -1;

    auto on_segment = [&](Vec a, Vec b) {
        return sign((b - a) % (q - a)) == 0 &&
               sign(dot(q - a, q - b)) <= 0;
    };
    if (n == 2) return on_segment(p[0], p[1]) ? 0 : -1;

    int first = sign((p[1] - p[0]) % (q - p[0]));
    int last  = sign((p[n - 1] - p[0]) % (q - p[0]));
    if (first < 0 || last > 0) return -1;
    if (first == 0) return on_segment(p[0], p[1]) ? 0 : -1;
    if (last == 0) return on_segment(p[0], p[n - 1]) ? 0 : -1;

    int l = 1, r = n - 1;
    while (r - l > 1) {
        int mid = (l + r) / 2;
        if (sign((p[mid] - p[0]) % (q - p[0])) >= 0) l = mid;
        else r = mid;
    }

    int side = sign((p[l + 1] - p[l]) % (q - p[l]));
    if (side < 0) return -1;
    if (side == 0) return 0;
    return 1;
}
```

上面 `Vec` 的 `%` 是叉积，`dot` 是点积；`eps` 判零规则沿用 ACMT。输入必须是逆时针凸多边形。

======= 凸包切线

======== 类型

给定逆时针严格凸包和凸包外的点 $p$，求从 $p$ 引出的两条支撑线。切点是凸包在相应方向上的极点；顶点按环序排列时，可以在凸包上二分定位，单次查询为 $O \( log n \)$。

- #strong[切点是顶点];：直线 $P V$ 两侧的相邻凸包顶点落在同一侧。
- #strong[切线经过一条边];：该边两个端点都可作为切点；以下代码在严格凸包、无连续共线边的前提下返回一个切点下标。
- #strong[前置条件];：凸包逆时针、严格凸，且 $p$ 严格在凸包外。若输入保留连续共线点，先按 ACMT 凸包模板压掉中间共线点。

======== Code

复用前面的 `convex_extreme_vertex`，分别以 $p arrow.r V$ 和 $V arrow.r p$ 为方向二分极点，得到两侧切点。总复杂度 $O \( log n \)$，额外空间 $O \( 1 \)$。

#quote(block: true)[
#strong[输入];：逆时针严格凸包 `hull[0..n-1]`、外点 `p`，$n gt.eq 3$。

#strong[输出];：两条支撑线的切点下标。

#strong[范围];：单次 $O \( log n \)$；坐标和精度沿用 ACMT 的 `Vec`、`db`、`sign`。
]

```cpp
pair<int, int> tangent_vertex(const vector<Vec>& hull, Vec p) {
    int first = convex_extreme_vertex(hull, [&](Vec v) { return v - p; });
    int second = convex_extreme_vertex(hull, [&](Vec v) { return p - v; });
    return {first, second};
}
```

返回两个支撑切点的下标，顺序对应两次方向相反的极点查询。若切线沿一条边，想取出该边的两个端点时，再检查切点相邻顶点是否与 $p \, V$ 共线。

====== 凸包 与 点 距离（外）

给定凸包外的点 `p` 和凸包 `hull`，答案是 `p` 到凸包边界的最短距离。凸包只有一个点时退化为点距，只有两个点时退化为点到线段距离。若点在凸包内部或边界上，点到凸包#strong[区域];的距离为 `0`；这不是本节的查询范围。当前代码是单次 $O \( n \)$ 边界距离查询，不含固定凸包的多次查询预处理结构。

#quote(block: true)[
#strong[输入];：点 `p`；不重复存储首尾点的逆时针凸包 `hull`，允许空集、单点和线段。

#strong[输出];：`p` 到凸包的最短距离；空凸包返回正无穷。

#strong[范围];：输入已是凸包时为 $O \( n \)$ 时间、$O \( 1 \)$ 额外空间；从任意点集先调用 `convex_hull_clean` 再查询为 $O \( n log n \)$。若只需判点是否在凸包内，使用前面的 `point_in_convex`，复杂度为 $O \( log n \)$。
]

```cpp
db dist_outer_point_to_hull(Vec p, const vector<Vec>& hull) {
    int n = hull.size();
    if (n == 0) return numeric_limits<db>::infinity();
    if (n == 1) return dist(p, hull[0]);
    if (n == 2) return dist_to_seg(p, Seg::st(hull[0], hull[1]));
    db ans = numeric_limits<db>::infinity();
    for (int i = 0; i < n; ++i) {
        Seg Edge = Seg::st(hull[i], hull[(i + 1) % n]);
        ans = min(ans, dist_to_seg(p, Edge));
    }
    return ans;
}
```

若输入是原始点集，先调用 `convex_hull_clean(points)` 得到 `hull`，再调用 `dist_outer_point_to_hull(p, hull)`。函数要求 `p` 在凸包外或边界上；如果需要查询内部点到边界的距离，使用下一节函数。

====== 凸包 与 点 距离（内）

这里的“内”指内部点到凸包#strong[边界];的最短距离，不是到凸包区域的距离（后者恒为 `0`）。最近边界点必落在某条边上，逐边调用点到线段距离即可，单次查询时间 $O \( n \)$。输入点必须在凸包内部或边界上；固定凸包的多次最近边界查询需要额外预处理结构，本模板不含该预处理。

#quote(block: true)[
#strong[输入];：位于凸包内部或边界上的点 `p`，以及逆时针凸包 `hull`。

#strong[输出];：`p` 到凸包边界的最短距离；点不在凸包内时返回正无穷。

#strong[范围];：$O \( n \)$ 时间、$O \( 1 \)$ 额外空间。
]

```cpp
db dist_inner_point_to_hull_boundary(Vec p, const vector<Vec>& hull) {
    int n = hull.size();
    if (n == 0 || point_in_convex(hull, p) < 0)
        return numeric_limits<db>::infinity();
    if (n == 1) return dist(p, hull[0]);
    if (n == 2) return dist_to_seg(p, Seg::st(hull[0], hull[1]));

    db ans = numeric_limits<db>::infinity();
    for (int i = 0; i < n; ++i)
        ans = min(ans, dist_to_seg(p, Seg::st(hull[i], hull[(i + 1) % n])));
    return ans;
}
```

