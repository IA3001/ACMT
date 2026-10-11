==== #text("计算几何-圆题")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/Notes/计算几何-圆题.md`]

- 最小覆盖圆
  - 退化情况
  - 真实赛题：#link("https://www.luogu.com.cn/problem/P3517")[POI 2011 WYK-Plot]
- 多圆 覆盖专题
  - 多圆 并集面积
  - 多圆 并集周长
  - 多圆 交集面积
  - 等半径 多圆 交集面积（凸包有序）
  - 多圆 交集周长
  - 圆盘覆盖至少 k 次的面积
  - 圆盘覆盖至少 k 次的周长
  - 圆盘最大覆盖点
- 圆盘集 最小覆盖圆
- 凸多边形 内最大圆
- 其它真实赛题
  - #link("https://codeforces.com/gym/103069/problem/J")[2020 ICPC Asia East Continent Final J. Circle]

===== 最小覆盖圆

给定平面点集，求包含所有点的最小闭圆盘。最优圆唯一，且最多由三个输入点确定：

- 一个边界点：所有点重合时，最优半径为 `0`。
- 两个边界点：这两点为直径端点，圆心是中点。
- 三个边界点：三点不共线，最优圆经过这三点。

随机增量算法先随机打乱点，再依次加入。新点在当前圆内就保持不变；新点落在圆外时，它必须成为新圆的边界点，再逐层加入此前违反当前圆的点，最多固定三个边界点重建圆。随机顺序下期望 $O \( n \)$，最坏 $O \( n^3 \)$。

实现沿用《计算几何-圆》中的 `minimum_enclosing_circle`。本节重点说明退化情形和如何把这份模板用于真实题目。

====== 退化情况

#figure(
  align(center)[#table(
    columns: (33.33%, 33.33%, 33.33%),
    align: (auto,auto,auto,),
    table.header([输入情况], [最小覆盖圆], [实现处理],),
    table.hline(),
    [空点集], [题目通常不定义], [本文模板返回半径 `0` 的占位圆；题目若不允许空集，应先检查输入],
    [一个点], [圆心为该点，半径 `0`], [初始化为零半径圆],
    [所有点重合], [同一个零半径圆], [点落在圆内，不触发扩张],
    [两个不同点], [以两点为直径的圆], [使用 `diameter_circle(a,b)`],
    [三个边界点共线], [取最远两点为直径的圆], [不调用三点外接圆，避免除以零],
    [三个边界点近共线], [外心可能很远，对浮点误差敏感], [由 ACMT `sign` 的精度决定是否进入共线分支；坐标尺度大或精度要求高时要调整判零策略],
    [新点恰在圆周上], [当前圆仍有效], [包含判断使用边界计入圆内],
  )]
  , kind: table
  )

三点不共线时才可调用 `Circle::abc(a,b,c)`。不能把“三点外接圆”当成任意三点的最小覆盖圆：若其中一点落在另外两点为直径的圆内，最小覆盖圆由那两点确定；随机增量的约束过程会自然保留这个两点边界情况。

====== 代码模板

下面代码与《计算几何-圆》的点集 MEC 模板一致，放在本文件即可直接用于后续题目。`sign`、`Vec`、`Circle`、`dist`、`len2`、`Circle::abc`、`Circle::Or` 使用 ACMT 中的定义。

#quote(block: true)[
#strong[输入];：点集 `p`，允许重复点；空集按半径 `0` 的退化圆处理。

#strong[输出];：包含所有点的最小圆。

#strong[复杂度];：期望 $O \( n \)$，最坏 $O \( n^3 \)$；除打乱数组外 $O \( 1 \)$ 空间。
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

判定点是否在圆内建议比较平方距离：

```cpp
bool disk_contains_point(Circle Cir, Vec p) {
    return sign(len2(p - Cir.o) - Cir.r * Cir.r) <= 0;
}
```

若题目只有整型坐标且坐标范围较大，外心计算和距离仍会进入浮点；不要因为输入是整数就把圆心、半径也存成整数。

===== 真实赛题：POI 2011 WYK-Plot

原题：#link("https://szkopul.edu.pl/problemset/problem/mzrTn1kzVBOAwVYn55LUeAai/site/?key=statement")[POI 2011 Plot 官方题面];（#link("https://www.luogu.com.cn/problem/P3517")[洛谷镜像];）。给定按输入顺序排列的 $n$ 个平面点，将序列切成至多 `m` 个连续非空段；每段用一个新点代替，最小化所有原点到对应新点的最大距离，并输出误差、段数和每段代表点。点不要求按坐标排序；题目范围为 $1 lt.eq m lt.eq n lt.eq 10^5$，坐标绝对值不超过 $10^6$。原始题面要求输出代表点的实数坐标（最多 15 位小数）；洛谷页面的“整数”描述与原题及样例不一致，应以原题面为准。

题目关键不是分别选择某个简单代表点，而是要为每一段选择使最大距离最小的点。对固定的一段，最佳代表点就是该段所有点的最小覆盖圆圆心，段的最小可能误差就是最小覆盖圆半径。因此，最小覆盖圆把“选代表点”转成了可计算的区间代价。

====== 固定误差的判定

二分答案 `R`，判断能否用不超过 `m` 段，使每段的最小覆盖圆半径都不超过 `R`。

从左向右贪心，每次取当前起点 `l` 能覆盖的最长连续段 `[l,r]`。这样得到的段数最少：若某个方案第一段比贪心段短，把它延长到贪心右端点只会让剩余后缀缩短，不会增加后续所需段数。

固定 `l` 后，随着 `r` 增大，区间最小覆盖圆半径不会减小，所以可行性单调。用倍增找到第一个可能不可行的右端点范围，再二分出最大可行 `r`。重复到覆盖全部点；段数不超过 `m` 即判定可行。最终用答案再贪心一次，输出每段最小覆盖圆的圆心。

```text
check(R):
    l = 1
    段数 = 0
    while l <= n:
        用倍增 + 二分找最大的 r，使 MEC(P[l..r]).r <= R
        l = r + 1
        段数 += 1
        if 段数 > m: return false
    return true
```

====== 参考实现

下面给出完整的解题骨架，复用上一节的 `minimum_enclosing_circle`。输入输出遵循原题：输出最大偏差、分段数及每段的代表点。对每个左端点，先倍增定位最远可行右端点的范围，再二分；区间 MEC 按需计算并缓存，避免每次 check 都从头重复计算相同区间。实际提交时应将 ACMT 几何基础模板与此代码合并，并按题目精度调 `EPS`。

```cpp
// 未对拍，谨慎使用
const db EPS = 1e-9;
int n, m;
vector<Vec> P;
mt19937 rng(chrono::steady_clock::now().time_since_epoch().count());
map<pair<int, int>, Circle> mec_cache;
vector<pair<int, int>> part;

Circle get_mec(int l, int r) { // 0-based 闭区间
    auto key = make_pair(l, r);
    auto it = mec_cache.find(key);
    if (it != mec_cache.end()) return it->second;
    vector<Vec> p(P.begin() + l, P.begin() + r + 1);
    return mec_cache[key] = minimum_enclosing_circle(p, rng);
}

bool check(db R, bool save) {
    mec_cache.clear();
    vector<pair<int, int>> now;
    int l = 0;
    while (l < n) {
        int good = l, step = 1;
        while (l + step - 1 < n &&
               get_mec(l, l + step - 1).r <= R + EPS) {
            good = l + step - 1;
            step <<= 1;
        }
        int low = good + 1, high = min(n - 1, l + step - 1);
        while (low <= high) {
            int mid = (low + high) >> 1;
            if (get_mec(l, mid).r <= R + EPS)
                good = mid, low = mid + 1;
            else
                high = mid - 1;
        }
        now.push_back({l, good});
        if ((int)now.size() > m) return false;
        l = good + 1;
    }
    if (save) part = move(now);
    return true;
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    cin >> n >> m;
    P.resize(n);
    for (Vec& p : P) cin >> p.x >> p.y;

    db low = 0, high = minimum_enclosing_circle(P, rng).r;
    for (int it = 0; it < 55; it++) {
        db mid = (low + high) / 2;
        if (check(mid, false)) high = mid;
        else low = mid;
    }
    check(high + EPS, true);
    cout << fixed << setprecision(15) << high << '\n';
    cout << part.size() << '\n';
    for (auto [l, r] : part) {
        Circle Cir = get_mec(l, r);
        cout << Cir.o.x << ' ' << Cir.o.y << '\n';
    }
}
```

#quote(block: true)[
复杂度：一个固定误差的 `check` 中，每个分段进行 $O \( log s \)$ 次区间 MEC 查询，$s$ 为该段长度；这些查询的 MEC 计算与复制点集合计期望 $O \( s log s \)$，对所有分段求和为 $O \( n log n \)$。区间缓存的查询次数总和为 $O \( n \)$，`std::map` 操作另需 $O \( n log n \)$；每轮缓存空间为 $O \( n \)$。外层做 $B$ 轮误差二分，总复杂度期望 $O \( B n log n \)$，本代码固定 $B = 55$。若要降低常数，可改用带自定义哈希的 `unordered_map`；缓存只在单次 `check` 内有效。
]

区间 `[l,r]` 的 MEC 用随机增量法计算。倍增先限制每个起点的搜索范围，再二分最大可行右端点；不能对每个起点都从 `l+1` 逐个扩展到 `n`，否则会重复扫描大量区间。固定二分轮数时，整体期望复杂度为 $O \( n log n \)$，主要因子来自每轮的区间 MEC 查询及有序缓存操作。上述结论是期望复杂度，不是最坏情况保证。

这题说明最小覆盖圆不仅用于“直接求一个点集的圆”，也可作为连续区间的代价函数，嵌入二分答案、贪心分段与构造输出中。实际实现还需按题目精度选取 `sign` 阈值，并确保最后输出的代表点对该段所有点满足题目误差限制。

===== 多圆 覆盖专题

本节讨论输入多个闭圆盘时的覆盖深度。覆盖深度是一个点被多少个圆盘包含。前面《计算几何-圆》中的并集面积对应“至少覆盖一次”；下面两题分别推广到覆盖次数和最优覆盖点。

====== 多圆 并集面积

多圆并集面积按每个圆的#strong[未被覆盖圆弧];累加。对圆 `i`，每个其它圆会在它的圆周上覆盖一个角度区间；把所有区间裁剪到 `[0,2π]`、排序合并，剩下的角度区间就是并集外边界。每段圆弧用 Green 公式计算有向面积贡献。先处理整圆被包含、重合和无交的情况，避免 `d=0` 时除零。

#quote(block: true)[
#strong[输入];：所有半径为正的圆；允许相离、相切、包含及重合。

#strong[输出];：这些闭圆盘并集的面积。

#strong[范围];：$O \( n^2 log n \)$ 时间、$O \( n \)$ 临时空间。
]

```cpp
db area_circle_union(const vector<Circle>& Cir) {
    const db PI = acos((db)-1), TAU = 2 * PI;
    db area = 0;
    int n = Cir.size();

    for (int i = 0; i < n; i++) {
        Circle A = Cir[i];
        vector<pair<db, db>> covered;
        bool full = false;

        for (int j = 0; j < n; j++) {
            if (i == j) continue;
            Circle B = Cir[j];
            db d = dist(A.o, B.o);

            if (sign(d) == 0 && sign(A.r - B.r) == 0) {
                if (j < i) full = true;
                if (full) break;
                continue;
            }

            // B 包含 A：A 的整条圆周都在并集内部。
            if (sign(B.r - d - A.r) >= 0) {
                full = true;
                break;
            }
            if (sign(d + B.r - A.r) <= 0 ||
                sign(d - A.r - B.r) >= 0) continue;

            db phi = atan2(B.o.y - A.o.y, B.o.x - A.o.x);
            db cs = (d * d + A.r * A.r - B.r * B.r) / (2 * d * A.r);
            cs = max((db)-1, min((db)1, cs));
            db alpha = acos(cs);
            db left = phi - alpha, right = phi + alpha;

            while (left < 0) left += TAU, right += TAU;
            while (left >= TAU) left -= TAU, right -= TAU;
            if (right <= TAU) covered.push_back({left, right});
            else {
                covered.push_back({left, TAU});
                covered.push_back({0, right - TAU});
            }
        }
        if (full) continue;

        sort(covered.begin(), covered.end());
        vector<pair<db, db>> merged;
        for (auto [l, r] : covered) {
            if (merged.empty() || sign(l - merged.back().second) > 0)
                merged.push_back({l, r});
            else
                merged.back().second = max(merged.back().second, r);
        }

        auto add_arc = [&](db l, db r) {
            if (sign(r - l) <= 0) return;
            Vec x(A.o.x + A.r * cos(l), A.o.y + A.r * sin(l));
            Vec y(A.o.x + A.r * cos(r), A.o.y + A.r * sin(r));
            area += (A.r * A.r * (r - l) + (A.o % (y - x))) / 2;
        };

        db at = 0;
        for (auto [l, r] : merged) {
            add_arc(at, l);
            at = max(at, r);
        }
        add_arc(at, TAU);
    }
    return max((db)0, area);
}
```

每个圆单独按逆时针方向累计未覆盖弧。若若干圆完全重合，只保留输入顺序最靠前的一个，其余跳过；否则相同的两个圆会互相判为覆盖，导致都不计入。若题目问某点被覆盖几次，直接统计点到各圆心距离即可，不能使用并集面积算法。

====== 多圆 并集周长

并集周长同样只统计每个圆上没有被其它圆盘覆盖的圆弧。覆盖角区间的求法与上面的并集面积相同；区别是每段未覆盖圆弧只贡献 `r * 圆心角`，无需做面积积分。完全包含和重合圆必须先处理，否则会出现除以零或重复计数。

#quote(block: true)[
#strong[输入];：所有半径为正的圆；允许相离、相切、包含及重合。

#strong[输出];：这些闭圆盘并集边界的总长度。

#strong[范围];：$O \( n^2 log n \)$ 时间、$O \( n \)$ 临时空间。
]

```cpp
db perimeter_circle_union(const vector<Circle>& Cir) {
    const db PI = acos((db)-1), TAU = 2 * PI;
    db perimeter = 0;
    int n = Cir.size();

    for (int i = 0; i < n; i++) {
        Circle A = Cir[i];
        vector<pair<db, db>> covered;
        bool full = false;

        for (int j = 0; j < n; j++) {
            if (i == j) continue;
            Circle B = Cir[j];
            db d = dist(A.o, B.o);

            if (sign(d) == 0 && sign(A.r - B.r) == 0) {
                if (j < i) full = true;
                if (full) break;
                continue;
            }
            if (sign(B.r - d - A.r) >= 0) {
                full = true;
                break;
            }
            if (sign(d + B.r - A.r) <= 0 ||
                sign(d - A.r - B.r) >= 0) continue;

            db phi = atan2(B.o.y - A.o.y, B.o.x - A.o.x);
            db cs = (d * d + A.r * A.r - B.r * B.r) / (2 * d * A.r);
            cs = max((db)-1, min((db)1, cs));
            db alpha = acos(cs);
            db left = phi - alpha, right = phi + alpha;
            while (left < 0) left += TAU, right += TAU;
            while (left >= TAU) left -= TAU, right -= TAU;
            if (right <= TAU) covered.push_back({left, right});
            else {
                covered.push_back({left, TAU});
                covered.push_back({0, right - TAU});
            }
        }
        if (full) continue;

        sort(covered.begin(), covered.end());
        vector<pair<db, db>> merged;
        for (auto [l, r] : covered) {
            if (merged.empty() || sign(l - merged.back().second) > 0)
                merged.push_back({l, r});
            else
                merged.back().second = max(merged.back().second, r);
        }

        db uncovered_angle = 0, at = 0;
        for (auto [l, r] : merged) {
            uncovered_angle += max((db)0, l - at);
            at = max(at, r);
        }
        uncovered_angle += max((db)0, TAU - at);
        perimeter += A.r * uncovered_angle;
    }
    return perimeter;
}
```

====== 多圆 交集面积

给定 `n` 个闭圆盘，求它们公共部分的面积。交集仍是凸集，边界由输入圆的圆弧组成。对圆 `A`，只累计同时落在所有其它圆盘内的圆周弧；每段弧按 Green 公式累加。与并集相反，并集保留“未被覆盖”的弧，交集保留“被所有约束圆覆盖”的弧。

先删除重复圆和冗余圆：若圆盘 `A` 完全包含圆盘 `B`，求交时 `A` 这个较大的约束可以删除；重复圆只留一个。若任意两圆外离或外切，公共面积为 `0`。对剩下的每一对相交且互不包含的圆，在 `A` 的圆周上，`B` 覆盖一段连续圆弧；其补弧是被 `B` 排除的部分。将所有排除弧拆到 `[0,2π]` 后排序合并，取并集的补集，即为 `A` 上满足所有其它圆约束的弧段。

一段圆弧 `theta0 -> theta1` 的有向面积贡献为

$ frac(r^2 \( theta_1 - theta_0 \) + o times \( q_1 - q_0 \), 2) \, $

其中 `o` 是圆心，`q0,q1` 是弧端点的全局坐标。所有保留弧段贡献之和即交集面积；公共部分可能退化为点或线段，此时面积为 `0`。

#quote(block: true)[
#strong[输入];：`n>=1` 个半径非负的圆盘；允许相离、相切、包含及重合。

#strong[输出];：所有闭圆盘的公共面积。

#strong[范围];：$O \( n^2 log n \)$ 时间、$O \( n \)$ 临时空间。
]

```cpp
db area_circle_intersection_all(vector<Circle> Cir) {
    const db PI = acos((db)-1), TAU = 2 * PI;
    vector<Circle> use;

    // 重复圆只保留一个约束。
    for (Circle A : Cir) {
        bool same = false;
        for (Circle B : use)
            if (sign(dist(A.o, B.o)) == 0 && sign(A.r - B.r) == 0) {
                same = true;
                break;
            }
        if (!same) use.push_back(A);
    }

    int n = use.size();
    if (n == 0) return 0; // 空输入按题目约定返回 0
    for (Circle A : use)
        if (sign(A.r) <= 0) return 0;

    // 大圆盘若包含另一个圆盘，其约束冗余。
    vector<Circle> keep;
    for (int i = 0; i < n; i++) {
        bool redundant = false;
        for (int j = 0; j < n; j++) {
            if (i == j) continue;
            db d = dist(use[i].o, use[j].o);
            if (sign(d + use[j].r - use[i].r) <= 0) {
                redundant = true;
                break;
            }
        }
        if (!redundant) keep.push_back(use[i]);
    }
    use.swap(keep);
    n = use.size();
    if (n == 1) return PI * use[0].r * use[0].r;

    // 外离或外切时交集面积为 0。
    for (int i = 0; i < n; i++)
        for (int j = i + 1; j < n; j++)
            if (sign(dist(use[i].o, use[j].o) - use[i].r - use[j].r) >= 0)
                return 0;

    db area = 0;
    for (int i = 0; i < n; i++) {
        Circle A = use[i];
        vector<pair<db, db>> excluded;

        for (int j = 0; j < n; j++) {
            if (i == j) continue;
            Circle B = use[j];
            db d = dist(A.o, B.o);

            // B 包含 A：A 的整条圆周均满足此约束。
            if (sign(d + A.r - B.r) <= 0) continue;

            // A 包含 B：A 圆周除可能的切点外都不在 B 内。
            if (sign(d + B.r - A.r) <= 0) {
                excluded = {{0, TAU}};
                break;
            }

            db phi = atan2(B.o.y - A.o.y, B.o.x - A.o.x);
            db cs = (d * d + A.r * A.r - B.r * B.r) / (2 * d * A.r);
            cs = max((db)-1, min((db)1, cs));
            db alpha = acos(cs);

            // A 圆周落在 B 外部的补弧，是本约束排除的角区间。
            db left = phi + alpha;
            db span = TAU - 2 * alpha;
            while (left < 0) left += TAU;
            while (left >= TAU) left -= TAU;
            db right = left + span;
            if (right <= TAU) excluded.push_back({left, right});
            else {
                excluded.push_back({left, TAU});
                excluded.push_back({0, right - TAU});
            }
        }

        sort(excluded.begin(), excluded.end());
        vector<pair<db, db>> merged;
        for (auto [l, r] : excluded) {
            if (merged.empty() || sign(l - merged.back().second) > 0)
                merged.push_back({l, r});
            else
                merged.back().second = max(merged.back().second, r);
        }

        auto add_arc = [&](db l, db r) {
            if (sign(r - l) <= 0) return;
            Vec q0(A.o.x + A.r * cos(l), A.o.y + A.r * sin(l));
            Vec q1(A.o.x + A.r * cos(r), A.o.y + A.r * sin(r));
            area += (A.r * A.r * (r - l) + (A.o % (q1 - q0))) / 2;
        };

        db at = 0;
        for (auto [l, r] : merged) {
            add_arc(at, l);
            at = max(at, r);
        }
        add_arc(at, TAU);
    }
    return max((db)0, area);
}
```

此实现按正面积输入编写；半径为 `0` 的圆盘面积恒为 `0`，因此直接返回 `0`。当所有输入圆互相包含时，冗余约束删除后只剩最小圆盘。近切、近重合时的分支由 ACMT `sign` 判定，精度阈值应结合坐标和半径范围设置。

====== 等半径 多圆 交集面积（凸包有序）

当所有圆半径相同，且圆心是#strong[严格凸多边形的顶点，按逆时针顺序给出];时，可以利用边界圆弧与圆心顺序一致这一性质，用栈维护最终交集边界上的圆。加入新圆时，只检查栈顶圆在前后两个圆约束下是否还保留正长度边界弧；没有边界弧且三圆交集仍有正面积时，栈顶圆的约束冗余，可以弹出。收尾时再检查首尾相邻圆。每个圆最多入栈、出栈一次。

三圆是否仍有正面积交集，用这三个圆心的最小覆盖圆半径判断：小于公共半径才有正面积；大于时交集为空；相等时交集至多为点，面积为 `0`。最小覆盖圆由三点确定，可以在 $O \( 1 \)$ 时间分类计算。

#quote(block: true)[
#strong[输入];：至少一个圆，半径均为 `r>0`；圆心按逆时针顺序构成严格凸多边形。`n=1`、`n=2` 分别按单圆和双圆处理。

#strong[输出];：所有圆盘的交集面积。

#strong[复杂度];：$O \( n \)$ 时间、$O \( n \)$ 空间。此线性结论依赖“等半径 + 圆心严格凸且有序”，不能用于一般多圆输入。
]

```cpp
Vec equal_circle_intersection_left(Vec a, Vec b, db r) {
    Vec v = b - a;
    db d = sqrt(dot(v, v));
    db h = sqrt(max((db)0, r * r - d * d / 4));
    Vec mid = (a + b) * 0.5;
    return mid + Vec(-v.y, v.x) * (h / d);
}

db equal_circle_pair_intersection_area(Vec a, Vec b, db r) {
    db d = dist(a, b);
    if (sign(d - 2 * r) >= 0) return 0;
    if (sign(d) == 0) return acos((db)-1) * r * r;
    db alpha = acos(max((db)-1, min((db)1, d / (2 * r))));
    return 2 * r * r * alpha - d * sqrt(max((db)0, r * r - d * d / 4));
}

db three_point_mec_radius(Vec a, Vec b, Vec c) {
    db ab = dist(a, b), bc = dist(b, c), ca = dist(c, a);
    db area2 = abs((b - a) % (c - a));
    if (sign(area2) == 0) return max({ab, bc, ca}) / 2;
    if (sign(dot(b - a, c - a)) <= 0 ||
        sign(dot(a - b, c - b)) <= 0 ||
        sign(dot(a - c, b - c)) <= 0)
        return max({ab, bc, ca}) / 2;
    return ab * bc * ca / (2 * area2);
}

bool three_equal_disks_have_area(Vec a, Vec b, Vec c, db r) {
    return sign(three_point_mec_radius(a, b, c) - r) < 0;
}

bool equal_circle_arc_is_positive(Vec prev, Vec now, Vec next, db r) {
    Vec a = prev - now, b = next - now;
    db alpha = acos(max((db)-1, min((db)1, dist(prev, now) / (2 * r))));
    db beta = acos(max((db)-1, min((db)1, dist(now, next) / (2 * r))));
    db inside = atan2(abs(a % b), dot(a, b));
    return sign(alpha + beta - inside) > 0;
}

db area_equal_circle_intersection_convex(const vector<Vec>& P, db r) {
    const db PI = acos((db)-1), TAU = 2 * PI;
    int n = P.size();
    if (n == 0 || sign(r) <= 0) return 0;
    if (n == 1) return PI * r * r;
    if (n == 2) return equal_circle_pair_intersection_area(P[0], P[1], r);

    deque<Vec> st;
    for (Vec p : P) {
        while (st.size() >= 2) {
            Vec a = st[st.size() - 2], b = st.back();
            if (!three_equal_disks_have_area(a, b, p, r)) return 0;
            if (equal_circle_arc_is_positive(a, b, p, r)) break;
            st.pop_back();
        }
        if (!st.empty() && sign(dist(st.back(), p) - 2 * r) >= 0) return 0;
        st.push_back(p);
    }

    // 检查从末尾绕回开头时仍然有效的圆弧；每次删除都只会删除一个圆。
    bool changed = true;
    while (changed && st.size() >= 3) {
        changed = false;
        Vec a = st[st.size() - 2], b = st.back(), c = st.front();
        if (!three_equal_disks_have_area(a, b, c, r)) return 0;
        if (!equal_circle_arc_is_positive(a, b, c, r)) {
            st.pop_back();
            changed = true;
            continue;
        }
        a = st.back(), b = st.front(), c = st[1];
        if (!three_equal_disks_have_area(a, b, c, r)) return 0;
        if (!equal_circle_arc_is_positive(a, b, c, r)) {
            st.pop_front();
            changed = true;
        }
    }

    if (st.size() == 1) return PI * r * r;
    if (st.size() == 2)
        return equal_circle_pair_intersection_area(st[0], st[1], r);
    db area = 0;
    int m = st.size();
    for (int i = 0; i < m; i++) {
        Vec prev = st[(i + m - 1) % m];
        Vec now = st[i];
        Vec next = st[(i + 1) % m];
        Vec q0 = equal_circle_intersection_left(prev, now, r);
        Vec q1 = equal_circle_intersection_left(now, next, r);
        Vec u = q0 - now, v = q1 - now;
        db angle = atan2(u % v, dot(u, v));
        if (angle < 0) angle += TAU;
        area += (r * r * angle + (now % (q1 - q0))) / 2;
    }
    return max((db)0, area);
}
```

上面的函数只负责#strong[固定半径下的交集面积];，可以替换真实赛题中的通用 `area_circle_intersection_all` 调用。若冗余约束删除后只剩两个有效圆盘，交集是透镜，需单独用双圆交集面积公式计算；一个有效圆盘时返回整圆面积。赛题半径由外层二分，因此总复杂度是每次判定 $O \( n \)$ 乘以二分轮数。不要将它当作任意半径圆、任意圆心顺序的通用多圆交集模板。

====== 多圆 交集周长

多圆交集周长与交集面积使用相同的边界筛选：对每个圆，只保留落在所有其它圆盘内的圆弧。区别是每段保留弧只贡献 `r * 圆心角`。圆盘交集是凸集，因此边界弧不会形成多个需要分类的连通分量；重复圆与冗余的大圆盘仍要先删除，外离或外切时交集退化，按周长 `0` 返回。

#quote(block: true)[
#strong[输入];：`n>=1` 个闭圆盘，半径非负；允许重合、相离、相切及包含。

#strong[输出];：公共部分边界的周长；空面积退化情形按 `0` 处理。

#strong[复杂度];：$O \( n^2 log n \)$ 时间、$O \( n \)$ 临时空间。
]

```cpp
db perimeter_circle_intersection_all(vector<Circle> Cir) {
    const db PI = acos((db)-1), TAU = 2 * PI;
    vector<Circle> use;

    // 重复圆周只留一个约束。
    for (Circle A : Cir) {
        bool same = false;
        for (Circle B : use)
            if (sign(dist(A.o, B.o)) == 0 && sign(A.r - B.r) == 0) {
                same = true;
                break;
            }
        if (!same) use.push_back(A);
    }
    int n = use.size();
    if (n == 0) return 0;
    for (Circle A : use)
        if (sign(A.r) <= 0) return 0;

    // 包含其它圆盘的大圆约束冗余，只保留较小圆盘对应的边界。
    vector<Circle> keep;
    for (int i = 0; i < n; i++) {
        bool redundant = false;
        for (int j = 0; j < n; j++) {
            if (i == j) continue;
            db d = dist(use[i].o, use[j].o);
            if (sign(d + use[j].r - use[i].r) <= 0) {
                redundant = true;
                break;
            }
        }
        if (!redundant) keep.push_back(use[i]);
    }
    use.swap(keep);
    n = use.size();
    if (n == 1) return 2 * PI * use[0].r;

    for (int i = 0; i < n; i++)
        for (int j = i + 1; j < n; j++)
            if (sign(dist(use[i].o, use[j].o) - use[i].r - use[j].r) >= 0)
                return 0;

    db perimeter = 0;
    for (int i = 0; i < n; i++) {
        Circle A = use[i];
        vector<pair<db, db>> excluded;

        for (int j = 0; j < n; j++) {
            if (i == j) continue;
            Circle B = use[j];
            db d = dist(A.o, B.o);

            // B 包含 A，A 的整周都满足此约束。
            if (sign(d + A.r - B.r) <= 0) continue;
            // A 包含 B，A 周界除切点外均被排除。
            if (sign(d + B.r - A.r) <= 0) {
                excluded = {{0, TAU}};
                break;
            }

            db phi = atan2(B.o.y - A.o.y, B.o.x - A.o.x);
            db cs = (d * d + A.r * A.r - B.r * B.r) / (2 * d * A.r);
            cs = max((db)-1, min((db)1, cs));
            db alpha = acos(cs);
            db left = phi + alpha;
            db span = TAU - 2 * alpha;
            while (left < 0) left += TAU;
            while (left >= TAU) left -= TAU;
            db right = left + span;
            if (right <= TAU) excluded.push_back({left, right});
            else {
                excluded.push_back({left, TAU});
                excluded.push_back({0, right - TAU});
            }
        }

        sort(excluded.begin(), excluded.end());
        vector<pair<db, db>> merged;
        for (auto [l, r] : excluded) {
            if (merged.empty() || sign(l - merged.back().second) > 0)
                merged.push_back({l, r});
            else
                merged.back().second = max(merged.back().second, r);
        }

        db uncovered_angle = 0, at = 0;
        for (auto [l, r] : merged) {
            uncovered_angle += max((db)0, l - at);
            at = max(at, r);
        }
        uncovered_angle += max((db)0, TAU - at);
        perimeter += A.r * uncovered_angle;
    }
    return perimeter;
}
```

====== 圆盘覆盖至少 k 次的面积

给定 `n` 个圆盘和正整数 `k`，求被至少 `k` 个圆盘覆盖的区域面积。`k=1` 就是圆盘并集面积；`k>n` 时答案为 `0`。

对每个#strong[不同的圆周];按与其它圆的交点切成弧段。每个开弧段中，被其它圆覆盖的数量固定。设该圆周对应的重数为 `w`，弧段外侧的覆盖数为 `d`；跨过这组重合圆周后，内侧覆盖数变为 `d+w`。当且仅当 `d < k <= d+w` 时，这段圆弧是“覆盖至少 `k` 次”区域的边界：沿圆周逆时针累加它的有向面积贡献。没有重合圆时 `w=1`，条件就化为恰好 `k-1` 个其它圆覆盖该弧段。单段贡献为

$ frac(r_i^2 \( theta_1 - theta_0 \) + o_i times \( q_1 - q_0 \), 2) \, $

其中 `o_i` 是圆心，`q_0,q_1` 是弧段端点的全局坐标。对每个圆收集所有覆盖角区间并排序扫描，就能得到每段的覆盖层数；总面积是所有符合条件的有向贡献之和。

#strong[复杂度];：直接对每个圆与其它圆求覆盖角区间并排序，时间 $O \( n^2 log n \)$，额外空间 $O \( n \)$。实现时要保留重合圆的覆盖权重：相同圆周的几何弧只处理一次，但其圆盘计数必须按重数累加。相切产生的零长度区间不能错误改变开弧段的覆盖层数；所有圆心重合、半径相同的情况应先按同圆分组处理。

```cpp
struct CircleSweepEvent {
    db angle;
    int delta;
};

db area_circle_cover_at_least_k(vector<Circle> Cir, int k) {
    const db PI = acos((db)-1), TAU = 2 * PI;
    vector<Circle> circle;
    vector<int> weight;

    for (Circle A : Cir) {
        int i = 0;
        for (; i < (int)circle.size(); i++)
            if (sign(dist(A.o, circle[i].o)) == 0 &&
                sign(A.r - circle[i].r) == 0) break;
        if (i == (int)circle.size()) circle.push_back(A), weight.push_back(1);
        else weight[i]++;
    }
    int n = circle.size();
    int total = 0;
    for (int w : weight) total += w;
    if (k <= 0) return 0; // 本函数约定 k>=1；至少 0 次覆盖的区域无界
    if (k > total) return 0;

    db area = 0;
    for (int i = 0; i < n; i++) {
        Circle A = circle[i];
        // 点圆没有圆周弧，对面积边界没有贡献。
        if (sign(A.r) <= 0) continue;
        int own = weight[i], base = 0;
        vector<CircleSweepEvent> event;

        for (int j = 0; j < n; j++) {
            if (i == j) continue;
            Circle B = circle[j];
            db d = dist(A.o, B.o);

            if (sign(d + A.r - B.r) <= 0) {
                base += weight[j];
                continue;
            }
            if (sign(d + B.r - A.r) <= 0 ||
                sign(d - A.r - B.r) >= 0) continue;

            db phi = atan2(B.o.y - A.o.y, B.o.x - A.o.x);
            db cs = (d * d + A.r * A.r - B.r * B.r) / (2 * d * A.r);
            cs = max((db)-1, min((db)1, cs));
            db alpha = acos(cs);
            db l = phi - alpha, r = phi + alpha;
            while (l < 0) l += TAU, r += TAU;
            while (l >= TAU) l -= TAU, r -= TAU;
            if (r <= TAU) event.push_back({l, weight[j]}), event.push_back({r, -weight[j]});
            else {
                event.push_back({l, weight[j]}), event.push_back({TAU, -weight[j]});
                event.push_back({0, weight[j]}), event.push_back({r - TAU, -weight[j]});
            }
        }

        sort(event.begin(), event.end(), [](auto a, auto b) {
            return a.angle < b.angle;
        });
        // 按事件间的开区间扫描；相切点是零测集，不影响面积。
        int active = base, at = 0;
        while (at < (int)event.size() && sign(event[at].angle) == 0)
            active += event[at++].delta;
        db left = 0;
        while (at < (int)event.size()) {
            db right = event[at].angle;
            if (active < k && active + own >= k) {
                Vec q0(A.o.x + A.r * cos(left), A.o.y + A.r * sin(left));
                Vec q1(A.o.x + A.r * cos(right), A.o.y + A.r * sin(right));
                area += (A.r * A.r * (right - left) + (A.o % (q1 - q0))) / 2;
            }
            while (at < (int)event.size() &&
                   sign(event[at].angle - right) == 0)
                active += event[at++].delta;
            left = right;
        }
        if (active < k && active + own >= k) {
            Vec q0(A.o.x + A.r * cos(left), A.o.y + A.r * sin(left));
            Vec q1(A.o.x + A.r * cos(TAU), A.o.y + A.r * sin(TAU));
            area += (A.r * A.r * (TAU - left) + (A.o % (q1 - q0))) / 2;
        }
    }
    return max((db)0, area);
}
```

====== 圆盘覆盖至少 k 次的周长

与“至少 `k` 次的面积”使用同一套圆周分段和覆盖层数统计。对某个不同圆周的一段开弧，设圆周外侧已有 `d` 个圆盘覆盖、该圆周重数为 `w`；跨过边界后覆盖数变成 `d+w`。当且仅当 `d < k <= d+w` 时，这段弧是“至少覆盖 `k` 次”区域的边界，周长贡献为 `r * 圆心角`。相同圆周只处理一次，但必须按重数同时增加覆盖层数。

相切点只有零长度，不影响周长；同心不同半径、包含与相离情况分别由“整周计入覆盖数”或“没有覆盖区间”处理。`k` 必须为正数；若 `k` 大于圆盘总数，周长为 `0`。

#quote(block: true)[
#strong[输入];：圆盘集合 `Cir`，正整数 `k`；圆盘半径非负。

#strong[输出];：被至少 `k` 个圆盘覆盖区域的边界总长度。

#strong[复杂度];：$O \( n^2 log n \)$ 时间、$O \( n \)$ 临时空间。
]

```cpp
db perimeter_circle_cover_at_least_k(vector<Circle> Cir, int k) {
    const db PI = acos((db)-1), TAU = 2 * PI;
    vector<Circle> circle;
    vector<int> weight;

    // 重合圆盘计数累加，几何圆周只扫描一次。
    for (Circle A : Cir) {
        int i = 0;
        for (; i < (int)circle.size(); i++)
            if (sign(dist(A.o, circle[i].o)) == 0 &&
                sign(A.r - circle[i].r) == 0) break;
        if (i == (int)circle.size()) circle.push_back(A), weight.push_back(1);
        else weight[i]++;
    }
    int n = circle.size(), total = 0;
    for (int w : weight) total += w;
    if (k <= 0 || k > total) return 0;

    db perimeter = 0;
    for (int i = 0; i < n; i++) {
        Circle A = circle[i];
        if (sign(A.r) <= 0) continue;
        int own = weight[i], base = 0;
        vector<CircleSweepEvent> event;

        for (int j = 0; j < n; j++) {
            if (i == j) continue;
            Circle B = circle[j];
            db d = dist(A.o, B.o);

            // B 覆盖 A 的整个圆盘，整周外侧深度都增加其重数。
            if (sign(d + A.r - B.r) <= 0) {
                base += weight[j];
                continue;
            }
            // B 位于 A 内部或与 A 外离，A 圆周上没有正长度覆盖弧。
            if (sign(d + B.r - A.r) <= 0 ||
                sign(d - A.r - B.r) >= 0) continue;

            db phi = atan2(B.o.y - A.o.y, B.o.x - A.o.x);
            db cs = (d * d + A.r * A.r - B.r * B.r) / (2 * d * A.r);
            cs = max((db)-1, min((db)1, cs));
            db alpha = acos(cs);
            db l = phi - alpha, r = phi + alpha;
            while (l < 0) l += TAU, r += TAU;
            while (l >= TAU) l -= TAU, r -= TAU;

            if (r <= TAU) {
                event.push_back({l, weight[j]});
                event.push_back({r, -weight[j]});
            } else {
                event.push_back({l, weight[j]});
                event.push_back({TAU, -weight[j]});
                event.push_back({0, weight[j]});
                event.push_back({r - TAU, -weight[j]});
            }
        }

        sort(event.begin(), event.end(), [](auto a, auto b) {
            return a.angle < b.angle;
        });
        int active = base, at = 0;
        while (at < (int)event.size() && sign(event[at].angle) == 0)
            active += event[at++].delta;
        db left = 0;
        while (at < (int)event.size()) {
            db right = event[at].angle;
            if (active < k && active + own >= k)
                perimeter += A.r * (right - left);
            while (at < (int)event.size() &&
                   sign(event[at].angle - right) == 0)
                active += event[at++].delta;
            left = right;
        }
        if (active < k && active + own >= k)
            perimeter += A.r * (TAU - left);
    }
    return perimeter;
}
```

====== 圆盘 最大覆盖点

给定 `n` 个闭圆盘，求一个点，使其落在尽可能多的圆盘内，并返回最大覆盖数。若要输出具体点，也需保存达到最大值的候选位置。

取一个达到最大覆盖数的点，在包含它的圆盘交集中沿任意方向移动到该交集边界，覆盖数不会减少，因此至少有一个最优点落在某个输入圆周上。枚举每个圆周：求它与其它圆的交点，把每个其它圆在该圆周上覆盖的部分转换为角区间，按覆盖深度初始化并排序扫描事件，统计圆周各段的覆盖数。闭圆盘的切点也算覆盖，因此相同角度的区间起点先计入再统计，终点统计后再移除；零长度切触区间也要在该角度统计。若要输出坐标，记录达到最大值的事件角或相邻事件间的一个角，并在该圆周上还原点坐标。

#strong[复杂度];：枚举圆对并对每个圆排序角事件，时间 $O \( n^2 log n \)$，额外空间 $O \( n \)$。这不是把所有圆周交点逐一拿来对全部圆重算（那会达到 $O \( n^3 \)$）。同心圆、重合圆、内含圆和相切圆都要进入事件初始化或圆心候选检查，不能只处理一般的两交点情况。

#quote(block: true)[
#strong[输入];：半径非负的圆盘集合；允许重合、包含、相切。

#strong[输出];：覆盖数最大值及一个达到最大值的点。空集返回 `{0, (0,0)}`。

#strong[复杂度];：$O \( n^2 log n \)$ 时间、$O \( n \)$ 临时空间。依赖 ACMT 的 `Vec`、`Circle`、`dist`、`sign`。
]

```cpp
struct CircleCoverAnswer {
    int cnt;
    Vec p;
};

struct CoverEvent {
    db angle;
    int delta;
    int point; // 只在该角度成立的切触覆盖数
};

CircleCoverAnswer maximum_circle_cover_point(const vector<Circle>& Cir) {
    const db PI = acos((db)-1), TAU = 2 * PI;
    int n = Cir.size();
    CircleCoverAnswer Ans{0, Vec(0, 0)};
    auto update = [&](int cnt, Vec p) {
        if (cnt > Ans.cnt) Ans = {cnt, p};
    };

    // 圆心也作为候选，覆盖所有同心、零半径等退化情况。
    for (Circle A : Cir) {
        int cnt = 0;
        for (Circle B : Cir)
            if (sign(dist(A.o, B.o) - B.r) <= 0) cnt++;
        update(cnt, A.o);
    }

    for (int i = 0; i < n; i++) {
        Circle A = Cir[i];
        if (sign(A.r) <= 0) continue;
        int base = 1;
        vector<CoverEvent> event;
        for (int j = 0; j < n; j++) {
            if (i == j) continue;
            Circle B = Cir[j];
            db d = dist(A.o, B.o);
            if (sign(d) == 0) {
                if (sign(B.r - A.r) >= 0) base++;
                continue;
            }
            if (sign(d + A.r - B.r) <= 0) {
                base++;
                continue;
            }
            if (sign(d + B.r - A.r) < 0 || sign(d - A.r - B.r) > 0)
                continue;

            db phi = atan2(B.o.y - A.o.y, B.o.x - A.o.x);
            db cs = (d * d + A.r * A.r - B.r * B.r) / (2 * d * A.r);
            cs = max((db)-1, min((db)1, cs));
            db alpha = acos(cs);
            db l = phi - alpha, r = phi + alpha;
            while (l < 0) l += TAU, r += TAU;
            while (l >= TAU) l -= TAU, r -= TAU;

            // 相切只覆蓋單點；保留 point 欄位，閉圓盤邊界也計入。
            if (sign(r - l) == 0) {
                event.push_back({l, 0, 1});
            } else if (r <= TAU) {
                event.push_back({l, 1, 0});
                event.push_back({r, -1, 0});
            } else {
                event.push_back({l, 1, 0});
                event.push_back({TAU, -1, 0});
                event.push_back({0, 1, 0});
                event.push_back({r - TAU, -1, 0});
            }
        }

        sort(event.begin(), event.end(), [](CoverEvent a, CoverEvent b) {
            return a.angle < b.angle;
        });
        int active = base, at = 0;
        db left = 0;
        while (at < (int)event.size()) {
            db angle = event[at].angle;
            // active 是前一开区间的覆盖数；结束区间仍在端点覆盖，开始区间也已覆盖。
            int starts = 0, ends = 0, points = 0;
            while (at < (int)event.size() && sign(event[at].angle - angle) == 0) {
                if (event[at].delta > 0) starts += event[at].delta;
                else ends -= event[at].delta;
                points += event[at].point;
                at++;
            }
            int at_angle = active + starts + points;
            db mid = (left + angle) / 2;
            update(active, Vec(A.o.x + A.r * cos(mid), A.o.y + A.r * sin(mid)));
            update(at_angle, Vec(A.o.x + A.r * cos(angle), A.o.y + A.r * sin(angle)));
            active += starts - ends;
            left = angle;
        }
        if (sign(TAU - left) > 0) {
            db mid = (left + TAU) / 2;
            update(active, Vec(A.o.x + A.r * cos(mid), A.o.y + A.r * sin(mid)));
        }
    }
    return Ans;
}
```

===== 圆盘集 最小覆盖圆

输入从点集改为圆盘集：给定圆盘 `(o_i,r_i)`，求最小的圆盘包含它们。候选圆的圆心 `c` 必须满足半径至少为 `|c-o_i|+r_i`，所以目标等价于

$ min_c max_i \( \| c - o_i \| + r_i \) . $

`r_i=0` 时退化为点集最小覆盖圆。最优解仍由至多三个约束圆盘支撑，但重建边界解时不能直接套用“两个点作直径、三个点求外接圆”：两个支撑圆要求外切于覆盖圆，三个支撑圆要求求解外切于三个给定圆的 Apollonius 圆。若一个输入圆盘已经包含其它输入圆盘，它们可从约束中删除。

#strong[算法方向];：这是加权 1-center（additively weighted smallest enclosing circle），可用低维 LP-type 随机增量框架，前提是实现单圆、双圆、三圆支撑集的精确重建与退化处理。三圆外切可能没有实解、出现多解或退化为两圆支撑；浮点代码必须逐个验证候选圆确实包含支撑圆盘。不能把点集 MEC 代码里只改 `inside` 判断就当作完整解法。

#strong[复杂度];：支撑集求解正确且每次为常数时间时，固定维度随机增量可达期望 $O \( n \)$；最坏复杂度不保证线性。三圆 Apollonius 求解和退化覆盖较多，属于专题模板，不建议混进基础圆结构代码。

下面给出随机增量实现。三圆支撑候选由方程 $\| c - o_i \| = R - r_i$ 解出；同时枚举单圆、双圆支撑候选并检查是否覆盖三者，以处理包含、共线和无有效三圆外切解的退化情况。代码假定正半径或零半径圆盘，且 `sign` 的误差适配坐标尺度。

#quote(block: true)[
#strong[输入];：圆盘集合 `Disk`。

#strong[输出];：覆盖全部输入圆盘的最小圆盘。

#strong[复杂度];：期望 $O \( n \)$，最坏 $O \( n^3 \)$；每个三盘支撑问题为 $O \( 1 \)$。
]

```cpp
bool disk_contains_disk(Circle A, Circle B) {
    return sign(dist(A.o, B.o) + B.r - A.r) <= 0;
}

Circle enclose_two_disks(Circle A, Circle B) {
    db d = dist(A.o, B.o);
    if (disk_contains_disk(A, B)) return A;
    if (disk_contains_disk(B, A)) return B;
    db R = (d + A.r + B.r) / 2;
    Vec o = A.o + (B.o - A.o) * ((R - A.r) / d);
    return Circle::Or(o, R);
}

Circle enclose_three_disks(Circle A, Circle B, Circle C) {
    vector<Circle> D{A, B, C};
    Circle best = Circle::Or(Vec(0, 0), numeric_limits<db>::infinity());
    auto take = [&](Circle X) {
        if (!isfinite(X.r)) return;
        for (Circle Y : D)
            if (!disk_contains_disk(X, Y)) return;
        if (X.r < best.r) best = X;
    };
    for (Circle X : D) take(X);
    for (int i = 0; i < 3; i++)
        for (int j = i + 1; j < 3; j++)
            take(enclose_two_disks(D[i], D[j]));

    // 令覆盖圆圆心 c = u + vR，再代入 |c-o0| = R-r0。
    Vec o0 = A.o, e1 = B.o - o0, e2 = C.o - o0;
    db det = e1 % e2;
    if (sign(det) != 0) {
        db b10 = (dot(B.o, B.o) - dot(o0, o0) - B.r * B.r + A.r * A.r) / 2;
        db b20 = (dot(C.o, C.o) - dot(o0, o0) - C.r * C.r + A.r * A.r) / 2;
        db b11 = B.r - A.r, b21 = C.r - A.r;
        Vec u((b10 * e2.y - e1.y * b20) / det,
              (e1.x * b20 - b10 * e2.x) / det);
        Vec v((b11 * e2.y - e1.y * b21) / det,
              (e1.x * b21 - b11 * e2.x) / det);
        Vec w = u - o0;
        db qa = dot(v, v) - 1;
        db qb = 2 * dot(w, v) + 2 * A.r;
        db qc = dot(w, w) - A.r * A.r;
        if (sign(qa) == 0) {
            if (sign(qb) != 0) {
                db R = -qc / qb;
                if (sign(R - max({A.r, B.r, C.r})) >= 0)
                    take(Circle::Or(u + v * R, R));
            }
        } else {
            db delta = qb * qb - 4 * qa * qc;
            if (sign(delta) >= 0) {
                db root = sqrt(max((db)0, delta));
                for (db R : {(-qb - root) / (2 * qa), (-qb + root) / (2 * qa)})
                    if (sign(R - max({A.r, B.r, C.r})) >= 0)
                        take(Circle::Or(u + v * R, R));
            }
        }
    }
    return best;
}

Circle minimum_enclosing_disks(vector<Circle> Disk, mt19937& rng) {
    if (Disk.empty()) return Circle::Or(Vec(0, 0), 0);
    shuffle(Disk.begin(), Disk.end(), rng);
    Circle Ans = Disk[0];
    for (int i = 0; i < (int)Disk.size(); i++) {
        if (disk_contains_disk(Ans, Disk[i])) continue;
        Ans = Disk[i];
        for (int j = 0; j < i; j++) {
            if (disk_contains_disk(Ans, Disk[j])) continue;
            Ans = enclose_two_disks(Disk[i], Disk[j]);
            for (int k = 0; k < j; k++) {
                if (disk_contains_disk(Ans, Disk[k])) continue;
                Ans = enclose_three_disks(Disk[i], Disk[j], Disk[k]);
            }
        }
    }
    return Ans;
}
```

===== 凸多边形 内最大圆

给定逆时针、面积非零的凸多边形，求完全包含在多边形内的最大圆盘。最大圆心 `c` 到每条边界直线的有向距离都至少为半径 `R`。

把每条边的内部半平面向内平移 `R`，最大圆存在当且仅当这些偏移半平面的交非空。因此可以二分 `R`，每轮求一次半平面交；若使用适合凸多边形有序边的线性可行性检查，单轮 $O \( n \)$，共 `B` 轮为 $O \( B n \)$。也可以直接把 `x,y,R` 作为变量，将“到每条边的有向距离不小于 `R`”写成线性不等式，转成三变量线性规划。

退化多边形（点、线段）最大内切圆半径为 `0`，不进入通常的正面积多边形模板。输入需保证凸且顶点按逆时针顺序；凹多边形不能仅靠所有边的半平面交表示其内部。若要求的是最大内接圆心而不是半径，还需处理多个同半径最优解。

#quote(block: true)[
#strong[输入];：逆时针、正面积凸多边形 `P`。

#strong[输出];：最大内切圆 `Circle`。

#strong[复杂度];：每次半平面交 $O \( n log n \)$，二分 `B` 次为 $O \( B n log n \)$；额外空间 $O \( n \)$。
]

```cpp
struct HalfPlane {
    Vec p, v;
    db angle;
};

Vec line_intersection(HalfPlane A, HalfPlane B) {
    return A.p + A.v * (((B.p - A.p) % B.v) / (A.v % B.v));
}

bool outside_halfplane(HalfPlane L, Vec p) {
    return sign(L.v % (p - L.p)) < 0;
}

vector<Vec> halfplane_intersection(vector<HalfPlane> H) {
    sort(H.begin(), H.end(), [](HalfPlane A, HalfPlane B) {
        return A.angle < B.angle;
    });
    vector<HalfPlane> line;
    for (HalfPlane L : H) {
        if (!line.empty() && sign(L.v % line.back().v) == 0 &&
            sign(dot(L.v, line.back().v)) > 0) {
            if (sign(line.back().v % (L.p - line.back().p)) > 0)
                line.back() = L;
        } else {
            line.push_back(L);
        }
    }

    deque<HalfPlane> dq;
    for (HalfPlane L : line) {
        while (dq.size() > 1 && outside_halfplane(L,
               line_intersection(dq[dq.size() - 2], dq.back()))) dq.pop_back();
        while (dq.size() > 1 && outside_halfplane(L,
               line_intersection(dq[0], dq[1]))) dq.pop_front();
        if (!dq.empty() && sign(dq.back().v % L.v) == 0) return {};
        dq.push_back(L);
    }
    while (dq.size() > 2 && outside_halfplane(dq.front(),
           line_intersection(dq[dq.size() - 2], dq.back()))) dq.pop_back();
    while (dq.size() > 2 && outside_halfplane(dq.back(),
           line_intersection(dq[0], dq[1]))) dq.pop_front();
    if (dq.size() < 3) return {};

    vector<Vec> poly;
    for (int i = 0; i < (int)dq.size(); i++)
        poly.push_back(line_intersection(dq[i], dq[(i + 1) % dq.size()]));
    db area2 = 0;
    for (int i = 0; i < (int)poly.size(); i++)
        area2 += poly[i] % poly[(i + 1) % poly.size()];
    if (sign(area2) <= 0) return {};
    return poly;
}

vector<Vec> shifted_polygon_kernel(const vector<Vec>& P, db R) {
    vector<HalfPlane> H;
    for (int i = 0; i < (int)P.size(); i++) {
        Vec a = P[i], v = P[(i + 1) % P.size()] - a;
        db len = sqrt(dot(v, v));
        Vec p = a + Vec(-v.y, v.x) * (R / len);
        H.push_back({p, v, atan2(v.y, v.x)});
    }
    return halfplane_intersection(H);
}

Circle largest_circle_in_convex_polygon(const vector<Vec>& P) {
    db low = 0;
    db minx = P[0].x, maxx = P[0].x, miny = P[0].y, maxy = P[0].y;
    for (Vec p : P) {
        minx = min(minx, p.x), maxx = max(maxx, p.x);
        miny = min(miny, p.y), maxy = max(maxy, p.y);
    }
    db high = hypot(maxx - minx, maxy - miny);
    vector<Vec> poly = P;
    for (int it = 0; it < 60; it++) {
        db mid = (low + high) / 2;
        vector<Vec> now = shifted_polygon_kernel(P, mid);
        if (now.empty()) high = mid;
        else low = mid, poly = move(now);
    }
    Vec o(0, 0);
    for (Vec p : poly) o = o + p;
    o = o * (1.0 / poly.size());
    return Circle::Or(o, low);
}
```

半平面按方向角排序后做双端队列交集，避免逐边裁剪造成的 $O \( n^2 \)$。二分下界对应的交集取顶点平均值；凸集顶点的平均值仍在凸集内，故返回圆心满足半径 `low` 的所有边距约束。

===== 其它真实赛题

====== 2020 ICPC Asia East Continent Final J. Circle

#link("https://codeforces.com/gym/103069/problem/J")[原题：Codeforces Gym 103069J];。给定凸包 `C` 和半径 `r`，求所有能覆盖整个凸包的半径为 `r` 的圆心组成的区域 `S` 的面积。

圆心 `p` 可行，当且仅当 `C` 上每个点都在以 `p` 为圆心、`r` 为半径的圆盘内。由于 `C` 是凸包，只需检查凸包顶点；因此可行圆心区域可表示为所有顶点为圆心、半径为 `r` 的圆盘的交集。圆心按凸包逆时针给出且半径相同，可直接调用前面的线性交集函数。

这道题适合作为进阶综合题：主要难点是将最小覆盖圆的判定转化为等半径圆盘交集面积，并正确处理凸包只有一个点、两点线段、无可行圆心区域等情况。题目输入给出逆时针凸包，$n lt.eq 1000$，多组数据的顶点总数不超过 $2 times 10^5$；每次固定半径的面积判定可在线性时间完成。

====== 代码调用

将凸包顶点作为圆心，调用 `area_equal_circle_intersection_convex`。`n=1`、`n=2` 已在函数内特判。

```cpp
// 未对拍，谨慎使用
int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    int T;
    cin >> T;
    cout << fixed << setprecision(12);
    while (T--) {
        int n;
        db r;
        cin >> n >> r;
        vector<Vec> P(n);
        for (Vec& p : P) cin >> p.x >> p.y;
        cout << area_equal_circle_intersection_convex(P, r) << '\n';
    }
}
```

