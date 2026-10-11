==== #text("计算几何-三维凸包")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/Notes/计算几何-三维凸包.md`]

- 三维凸包 创建
- 三维凸包 表面积与体积
- 点 与 三维凸包 关系
- 三维凸包 与 平面 相交

===== 三维凸包 创建

三维凸包的增量法维护当前凸包的三角面片。加入新点时，先找出从外侧可见的面；可见面的边界构成地平线，删除可见面后，将地平线上的每条边与新点连成新面。

模板会删除坐标完全相同的重复点，并区分点集的仿射维数：点集可退化为一个点、一条线段、一个平面凸包或真正的三维凸包。三维面片允许共面三角片；与新点共线的零面积三角片不会加入结果。代码使用 `<map>` 和 `<numeric>`。浮点计算使用本文统一的 `Vec3`、`dot`、`cross`、`sign`、`len`。

#quote(block: true)[
#strong[输入];：任意空间点集；点坐标可为浮点数。

#strong[输出];：`dimension=0/1/2/3` 分别表示点、线段、平面凸包、三维凸包；三维凸包返回外法向三角面片，低维凸包通过 `Boundary` 保存端点或边界环。

#strong[范围];：最坏 $O \( n^2 log n \)$ 时间、$O \( n \)$ 额外空间。每个新点扫描当前面片；地平线用 `map` 维护，每次插入或删除边为 $O \( log n \)$。
]

```cpp
struct Face3 {
    int a, b, c;
};

struct ConvexHull3 {
    int dimension = -1;
    vector<Vec3> P;
    vector<Face3> Faces;
    vector<int> Boundary;
    Vec3 normal;
};

bool convex_hull3(vector<Vec3> P, ConvexHull3& hull) {
    hull = ConvexHull3();
    sort(P.begin(), P.end(), [](Vec3 a, Vec3 b) {
        if (a.x != b.x) return a.x < b.x;
        if (a.y != b.y) return a.y < b.y;
        return a.z < b.z;
    });
    P.erase(unique(P.begin(), P.end(), [](Vec3 a, Vec3 b) {
        return a.x == b.x && a.y == b.y && a.z == b.z;
    }), P.end());

    int n = P.size();
    if (n == 0) return false;
    hull.P = P;
    hull.Faces.clear();
    hull.Boundary.clear();

    int a = 0, b = -1, c = -1, d = -1;
    db farthest2 = 0;
    for (int i = 1; i < n; ++i) {
        db distance2 = norm2(P[i] - P[a]);
        if (distance2 > farthest2) farthest2 = distance2, b = i;
    }
    if (b == -1 || sign(farthest2) == 0) {
        hull.dimension = 0;
        hull.Boundary = {0};
        return true;
    }

    db area2 = 0;
    for (int i = 0; i < n; ++i) {
        db value = norm2(cross(P[b] - P[a], P[i] - P[a]));
        if (value > area2) area2 = value, c = i;
    }
    if (c == -1 || sign(area2) == 0) {
        hull.dimension = 1;
        int other = b;
        farthest2 = 0;
        for (int i = 0; i < n; ++i) {
            db distance2 = norm2(P[i] - P[b]);
            if (distance2 > farthest2) farthest2 = distance2, other = i;
        }
        hull.Boundary = {b, other};
        return true;
    }

    Vec3 normal = cross(P[b] - P[a], P[c] - P[a]);
    Vec3 unit_normal;
    unit(normal, unit_normal);
    db volume6 = 0;
    for (int i = 0; i < n; ++i) {
        db value = fabsl(dot(normal, P[i] - P[a]));
        if (value > volume6) volume6 = value, d = i;
    }
    if (d == -1 || sign(volume6) == 0) {
        Vec3 base = fabsl(unit_normal.x) <= fabsl(unit_normal.y) &&
                    fabsl(unit_normal.x) <= fabsl(unit_normal.z)
            ? Vec3(1, 0, 0)
            : (fabsl(unit_normal.y) <= fabsl(unit_normal.z)
                ? Vec3(0, 1, 0) : Vec3(0, 0, 1));
        Vec3 e1;
        unit(cross(unit_normal, base), e1);
        Vec3 e2 = cross(unit_normal, e1);

        vector<int> Order(n);
        iota(Order.begin(), Order.end(), 0);
        sort(Order.begin(), Order.end(), [&](int i, int j) {
            db xi = dot(P[i] - P[a], e1), xj = dot(P[j] - P[a], e1);
            if (xi != xj) return xi < xj;
            return dot(P[i] - P[a], e2) < dot(P[j] - P[a], e2);
        });
        auto turn = [&](int i, int j, int k) {
            Vec3 u = P[j] - P[i], v = P[k] - P[i];
            db ux = dot(u, e1), uy = dot(u, e2);
            db vx = dot(v, e1), vy = dot(v, e2);
            return sign(ux * vy - uy * vx);
        };

        vector<int> Boundary;
        for (int id : Order) {
            while (Boundary.size() > 1 &&
                   turn(Boundary[Boundary.size() - 2], Boundary.back(), id) <= 0)
                Boundary.pop_back();
            Boundary.push_back(id);
        }
        int lower_size = Boundary.size();
        for (int i = n - 2; i >= 0; --i) {
            int id = Order[i];
            while ((int)Boundary.size() > lower_size &&
                   turn(Boundary[Boundary.size() - 2], Boundary.back(), id) <= 0)
                Boundary.pop_back();
            Boundary.push_back(id);
        }
        Boundary.pop_back();
        hull.dimension = 2;
        hull.normal = unit_normal;
        hull.Boundary = move(Boundary);
        return true;
    }

    Vec3 inside = (P[a] + P[b] + P[c] + P[d]) / 4;
    vector<Face3> Faces;
    auto add_face = [&](int u, int v, int w) {
        Vec3 face_normal = cross(P[v] - P[u], P[w] - P[u]);
        if (sign(norm2(face_normal)) == 0) return;
        if (sign(dot(face_normal, inside - P[u])) > 0)
            swap(v, w);
        Faces.push_back({u, v, w});
    };

    add_face(a, b, c);
    add_face(a, d, b);
    add_face(b, d, c);
    add_face(c, d, a);

    vector<bool> initial(n, false);
    initial[a] = initial[b] = initial[c] = initial[d] = true;
    hull.dimension = 3;
    for (int id = 0; id < n; ++id) {
        if (initial[id]) continue;

        vector<Face3> Next;
        map<pair<int, int>, int> Horizon;
        for (Face3 face : Faces) {
            Vec3 face_normal = cross(P[face.b] - P[face.a],
                                     P[face.c] - P[face.a]);
            if (sign(dot(face_normal, P[id] - P[face.a])) <= 0) {
                Next.push_back(face);
                continue;
            }

            pair<int, int> Edges[3] = {
                {face.a, face.b}, {face.b, face.c}, {face.c, face.a}
            };
            for (auto [u, v] : Edges) {
                auto it = Horizon.find({v, u});
                if (it != Horizon.end()) Horizon.erase(it);
                else Horizon[{u, v}] = 1;
            }
        }

        if (Next.size() == Faces.size()) continue; // 点在当前凸包内或边界上
        Faces.swap(Next);
        for (auto [edge, unused] : Horizon)
            add_face(edge.first, edge.second, id);
    }

    hull.P = move(P);
    hull.Faces = move(Faces);
    return true;
}
```

每次插入点时扫描当前面片，当前三维凸包的面数为 $O \( n \)$；每条可见面边还要通过 `map` 查找或维护地平线，因此最坏总时间为 $O \( n^2 log n \)$。`inside` 是初始四面体的重心，始终位于当前凸包内部，用它统一调整新面方向。共面区域保留为多个三角面片，不要求合并成一个多边形面；共线的新面会因面积为零而跳过。低维结果没有三角面，后续表面积和体积函数应只对 `dimension==3` 调用。

===== 三维凸包 表面积与体积

凸包表面积是所有三角面片面积之和。体积可把每个有向三角面与原点组成有向四面体，累加混合积后取绝对值。面片方向一致是体积公式成立的前提。

#quote(block: true)[
#strong[输入];：`convex_hull3` 成功构造的凸包。

#strong[输出];：表面积与体积。

#strong[范围];：$O \( f \)$ 时间、$O \( 1 \)$ 额外空间，$f$ 为三角面片数。
]

```cpp
db convex_surface_area3(const ConvexHull3& hull) {
    db area = 0;
    for (Face3 face : hull.Faces) {
        Vec3 a = hull.P[face.a];
        Vec3 b = hull.P[face.b];
        Vec3 c = hull.P[face.c];
        area += len(cross(b - a, c - a)) / 2;
    }
    return area;
}

db convex_volume3(const ConvexHull3& hull) {
    db volume6 = 0;
    for (Face3 face : hull.Faces) {
        Vec3 a = hull.P[face.a];
        Vec3 b = hull.P[face.b];
        Vec3 c = hull.P[face.c];
        volume6 += dot(a, cross(b, c));
    }
    return fabsl(volume6) / 6;
}
```

封闭凸包的有向体积和与原点位置无关；返回的体积非负。若只需比较体积，可不除以 `6`。

===== 点 与 三维凸包 关系

三维凸包由外法向一致的面片围成。对每个面检查查询点是否落在其外侧：只要有一个面判为外侧，点就在凸包外。低维凸包则在自身所在直线或平面内判定相对内部与边界。

#quote(block: true)[
#strong[输入];：查询点与成功构造的三维凸包。

#strong[输出];：`-1` 表示凸包外，`0` 表示相对边界，`1` 表示相对内部；单点凸包上唯一的点返回 `0`。

#strong[范围];：$O \( f \)$ 时间、$O \( 1 \)$ 额外空间。
]

```cpp
int point_convex_hull3_relation(Vec3 q, const ConvexHull3& hull) {
    if (hull.dimension < 0) return -1;
    if (hull.dimension == 0)
        return q == hull.P[hull.Boundary[0]] ? 0 : -1;

    if (hull.dimension == 1) {
        Vec3 a = hull.P[hull.Boundary[0]];
        Vec3 b = hull.P[hull.Boundary[1]];
        Vec3 direction = b - a;
        if (sign(norm2(cross(q - a, direction))) != 0 ||
            sign(dot(q - a, q - b)) > 0) return -1;
        return q == a || q == b ? 0 : 1;
    }

    if (hull.dimension == 2) {
        Vec3 a = hull.P[hull.Boundary[0]];
        if (sign(dot(hull.normal, q - a)) != 0) return -1;
        bool boundary = false;
        int n = hull.Boundary.size();
        for (int i = 0; i < n; ++i) {
            Vec3 u = hull.P[hull.Boundary[i]];
            Vec3 v = hull.P[hull.Boundary[(i + 1) % n]];
            int side = sign(dot(cross(v - u, q - u), hull.normal));
            if (side < 0) return -1;
            if (side == 0) boundary = true;
        }
        return boundary ? 0 : 1;
    }

    bool boundary = false;
    for (Face3 face : hull.Faces) {
        Vec3 a = hull.P[face.a];
        Vec3 b = hull.P[face.b];
        Vec3 c = hull.P[face.c];
        Vec3 normal = cross(b - a, c - a);
        int side = sign(dot(normal, q - a));
        if (side > 0) return -1;
        if (side == 0) boundary = true;
    }
    return boundary ? 0 : 1;
}
```

三维凸包查询要求面片方向保持为外法向。低维凸包返回相对内部关系。若查询很多，可在确认题目规模后再考虑空间划分等加速结构；竞赛常见单次或少量查询直接扫描面片即可。

===== 三维凸包 与 平面 相交

平面与凸包的交集仍是凸集，可能为空、一个点、一条线段或一个凸多边形。遍历凸包三角面的边：端点在平面上的直接加入；两端在平面异侧时加入边与平面的交点。面片共享的网格边只处理一次，得到交点后再绕截面中心按极角排序。代码需要标准库头文件 `<set>`。

#quote(block: true)[
#strong[输入];：由 `convex_hull3` 构造的凸包与非零法向量平面；支持点、线段、平面凸包和三维凸包。

#strong[输出];：`type=0/1/2/3` 分别表示空集、点、线段、多边形；多边形顶点按平面法向量方向逆时针排列。

#strong[范围];：三维凸包求交 $O \( n + f log f \)$ 时间、$O \( n + f \)$ 额外空间，$n$ 为保存的输入点数、$f$ 为三角面片数；平面凸包求交为 $O \( n + k log k \)$，其中 $k$ 为截面顶点数。截面面积和周长各 $O \( k \)$。
]

```cpp
struct HullPlaneHit3 {
    int type = 0; // 0: 空，1: 点，2: 线段，3: 多边形
    vector<Vec3> P;
};

HullPlaneHit3 convex_hull3_plane_intersection(
    const ConvexHull3& hull, Plane plane) {
    int n = hull.P.size();
    vector<db> distance(n);
    vector<int> side(n);
    for (int i = 0; i < n; ++i) {
        distance[i] = dot(plane.n, hull.P[i] - plane.p);
        side[i] = sign(distance[i]);
    }

    HullPlaneHit3 hit;
    vector<bool> AddedVertex(n, false);
    set<pair<int, int>> Edges;
    auto add_vertex = [&](int id) {
        if (!AddedVertex[id]) {
            AddedVertex[id] = true;
            hit.P.push_back(hull.P[id]);
        }
    };
    auto process_edge = [&](int x, int y) {
        int u = min(x, y), v = max(x, y);
        if (!Edges.insert({u, v}).second) return;
        if (side[u] == 0) add_vertex(u);
        if (side[v] == 0) add_vertex(v);
        if (side[u] * side[v] < 0) {
            db t = distance[u] / (distance[u] - distance[v]);
            hit.P.push_back(hull.P[u] + (hull.P[v] - hull.P[u]) * t);
        }
    };

    if (hull.dimension == 0) {
        if (side[hull.Boundary[0]] == 0) add_vertex(hull.Boundary[0]);
    } else if (hull.dimension == 1 || hull.dimension == 2) {
        int k = hull.Boundary.size();
        int edge_count = hull.dimension == 1 ? 1 : k;
        for (int i = 0; i < edge_count; ++i)
            process_edge(hull.Boundary[i], hull.Boundary[(i + 1) % k]);
    } else {
        for (Face3 face : hull.Faces) {
            process_edge(face.a, face.b);
            process_edge(face.b, face.c);
            process_edge(face.c, face.a);
        }
    }

    int k = hit.P.size();
    if (k == 0) return hit;
    if (k == 1) {
        hit.type = 1;
        return hit;
    }
    if (k == 2) {
        hit.type = 2;
        return hit;
    }

    Vec3 center;
    for (Vec3 p : hit.P) center = center + p;
    center = center / k;

    Vec3 normal;
    unit(plane.n, normal);
    Vec3 base = fabsl(normal.x) <= fabsl(normal.y) &&
                 fabsl(normal.x) <= fabsl(normal.z)
        ? Vec3(1, 0, 0)
        : (fabsl(normal.y) <= fabsl(normal.z)
            ? Vec3(0, 1, 0) : Vec3(0, 0, 1));
    Vec3 e1;
    unit(cross(normal, base), e1);
    Vec3 e2 = cross(normal, e1);

    sort(hit.P.begin(), hit.P.end(), [&](Vec3 a, Vec3 b) {
        Vec3 delta_a = a - center, delta_b = b - center;
        db angle_a = atan2l(dot(delta_a, e2), dot(delta_a, e1));
        db angle_b = atan2l(dot(delta_b, e2), dot(delta_b, e1));
        if (angle_a != angle_b) return angle_a < angle_b;
        return norm2(delta_a) < norm2(delta_b);
    });
    hit.type = 3;
    return hit;
}

db hull_plane_section_area3(const HullPlaneHit3& hit, Plane plane) {
    if (hit.type != 3) return 0;
    Vec3 normal;
    unit(plane.n, normal);
    Vec3 center;
    for (Vec3 p : hit.P) center = center + p;
    center = center / hit.P.size();

    db area2 = 0;
    int n = hit.P.size();
    for (int i = 0; i < n; ++i) {
        Vec3 a = hit.P[i] - center;
        Vec3 b = hit.P[(i + 1) % n] - center;
        area2 += dot(cross(a, b), normal);
    }
    return fabsl(area2) / 2;
}

db hull_plane_section_perimeter3(const HullPlaneHit3& hit) {
    int n = hit.P.size();
    if (n <= 1) return 0;
    if (n == 2) return len(hit.P[0] - hit.P[1]);

    db perimeter = 0;
    for (int i = 0; i < n; ++i)
        perimeter += len(hit.P[i] - hit.P[(i + 1) % n]);
    return perimeter;
}
```

平面与凸包相切于顶点或棱时分别返回点或线段；与凸包某个三角面重合时返回该面的多边形。周长对线段返回其长度、对点返回 `0`；空集的面积与周长均为 `0`。平面法向量必须非零。

