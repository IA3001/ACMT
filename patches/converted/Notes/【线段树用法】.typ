==== #text("【线段树用法】")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/Notes/【线段树用法】.md`]

===== 线段树-用法

====== 一、 基础架构

- #strong[静态堆式];：数组大小 4n，`p*2` 与 `p*2+1` 访问子节点。适用于数据量已知。
- #strong[动态开点];：不预建全树，用到才开。空间 $O \( k log V \)$，用于值域极大或稀疏场景（如 $\[ 1 \, 10^9 \]$）。
- #strong[zkw 线段树];：一种自底向上的非递归线段树写法；能维护哪些信息取决于节点合并方式和查询实现，不限于可差分信息。

====== 二、 按维护信息分类

- #strong[可差分信息];：区间和、区间异或和。可用树状数组替代。
- #strong[不可差分信息];：区间最大/最小值、区间 GCD。
- #strong[复合信息];：如最大子段和，节点需维护 `sum`、`max_prefix`、`max_suffix`、`max_subarray`。
- #strong[势能信息];：区间取模、区间开方等操作可在特定值域下用最大值剪枝。常见前提是维护非负整数：对 `x %= mod`，节点最大值 `< mod` 时整段不变；对 `x = floor(sqrt(x))`，节点最大值 `<= 1` 时整段不变。非负前提和整数语义不可省略；复杂度还要按势能变化证明，不能只凭剪枝存在就断言总复杂度。

====== 三、 按维护操作分类（Lazy Tag 体系）

- #strong[区间加/乘/赋值];：把一段懒标记统一表示为仿射变换 $x mapsto a x + b$；赋值 $v$ 对应 $\( a \, b \) = \( 0 \, v \)$。若当前已有标记 $\( a \, b \)$，随后又施加 $\( c \, d \)$，合成后是 $\( c a \, c b + d \)$。下传时按标记实际发生顺序组合；若分别存赋值、乘法、加法，先应用赋值，再乘法，最后加法。
- #strong[区间翻转];：普通固定下标线段树不能仅靠 `rev` 懒标记实现任意区间翻转，因为翻转会改变元素所在位置。若要支持翻转，通常用隐式平衡树（如 FHQ Treap）并交换左右子树；固定区间结构可维护正反信息回答回文等查询，但那本身不等于支持翻转修改。
- #strong[区间取 min / max（Segment Tree Beats）];：以区间取 `chmin` 为例，维护最大值 `mx`、严格次大值 `se`、最大值个数 `cnt` 和区间和；当 `se < x < mx` 时可整段更新。`chmax` 对称维护最小值信息。复杂度依赖支持的操作及对应势能分析，不能仅凭这组节点信息就统一写成 $O \( n log n \)$。
- #strong[区间历史最值];：若操作涉及区间加、乘或赋值，要同时描述当前值变换和历史最大/最小值如何变化；通常需要为懒标记额外维护历史贡献，不能只记录一个“历史最大增量”。
- #strong[标记永久化];：更新时不下传标记，查询时把祖先标记对答案的影响一并计算。适用于能正确合成并传递标记贡献的设计；可持久化线段树等场景可采用，但不能不加修改地套用普通懒标记代码。

====== 四、 按区间处理分类

- #strong[区间合并];：查询返回结构体，将多个子区间答案合并（如最大子段和）。
- #strong[线段树上二分];：在前缀和单调（例如数组元素非负）且节点维护区间和时，可用 $O \( log n \)$ 找最小的前缀和 $gt.eq k$ 的位置。从根节点判断左子树是否已达到 $k$，否则扣除左子树和后进入右子树；若前缀和不单调，这种判定不成立。
- #strong[坐标离散化];：坐标范围大但有效点少时，先离散化再建树。

====== 五、 进阶结构与变体

- #strong[可持久化线段树（主席树）];：每次修改新建 $O \( log n \)$ 节点，保留历史版本。求区间第 $k$ 小，用两棵线段树相减。
- #strong[线段树合并];：通常指破坏式合并两棵稀疏线段树；复杂度要按节点创建数和实际访问数分析，不能一概写成 $O \( n log n \)$。常用于树上子树值域统计等场景；它与 DSU on Tree 思路不同，不能笼统视为替代关系。
- #strong[线段树分裂];：在按值域建的动态线段树中，可按子树计数把一棵树拆成前 $k$ 小与其余部分，递归深度为 $O \( log V \)$；前提是节点维护了可用于定位的计数等信息。
- #strong[李超线段树];：维护二维平面线段/直线，支持插入与查询最值。用于斜率优化 DP。
- #strong[树套树];：线段树套线段树/平衡树，解决高维问题。
- #strong[线段树优化建图];：节点代表区间，单点连区间、区间连单点用虚拟节点，边数降为 $O \( n log n \)$。
- #strong[扫描线];：矩形面积并可按 $x$ 排序，并在线段树中维护 $y$ 轴覆盖长度；周长并还需维护覆盖段数及边界变化，不能只靠覆盖长度。
- #strong[动态 DP（DDP）];：将树上 DP 转成可合并的转移矩阵等信息，并用树链剖分和线段树维护；要处理好矩阵乘法顺序及轻重儿子贡献，具体形式依赖 DP 转移。
- #strong[全局平衡二叉树];：一种维护树上路径信息的平衡划分方法，可用于动态树上 DP，将部分树链剖分方案的操作复杂度优化到 $O \( log n \)$；实现和常数较复杂，是否优于树链剖分取决于问题与实现。

====== 六、 线段树分治

- #strong[适用场景];：操作只在某段时间内有效（如动态图连通性、带删除的背包）。
- #strong[核心思想];：以时间轴建立线段树，将操作映射到时间区间上。DFS遍历这棵树，进入节点时应用操作，离开节点时撤销操作（需要支持撤销的数据结构，如可撤销并查集）。
- #strong[具体步骤];：
  + 将操作的时间区间 $\[ l \, r \]$ 打上懒标记，添加到时间线段树中。
  + 从根节点开始 DFS，每到一个节点，应用该节点的所有操作。
  + 到达叶子节点时，统计当前时间点的答案。
  + 回溯时，撤销当前节点的所有操作（需要可撤销数据结构支持）。
- #strong[复杂度];：若有 $m$ 个操作区间、时间轴长度为 $T$，分解后有 $O \( m log T \)$ 次应用；总时间为这些应用及撤销的代价之和，再加叶子查询代价。使用按大小合并且不路径压缩的可撤销并查集时，单次查找最坏 $O \( log n \)$，故总复杂度通常为 $O \( m log T log n + T \)$（若只在部分时刻查询，以实际查询数计）。
- #strong[配套数据结构];：可撤销并查集（按秩合并，不能路径压缩）。

====== 七、 其他高级技巧

====== 猫树（Cat Tree）

猫树是静态区间查询结构，适用于区间信息能按顺序合并、但不支持修改的场景。它在每个完全二叉树节点预处理左半区间的后缀信息、右半区间的前缀信息。查询区间端点的叶子节点 LCA 即为它们首次分居左右子树的节点，答案由两侧预处理信息合并得到。

- 预处理：$O \( N log N \)$。
- 查询：$O \( 1 \)$。
- 空间：$O \( N log N \)$。
- 这里 $N$ 是不小于元素个数 $n$ 的最小 2 的幂。补齐到 $N$ 的叶子必须填入合并运算的单位元。
- 信息合并必须满足结合律，并保留左右顺序；例如最大子段和、区间 GCD、区间最大值。

下面模板按 1-indexed 输入，要求 $1 lt.eq n lt.eq 10^5$。空节点用 `len == 0` 表示，避免用可能与真实数据冲突的数值哨兵。

```cpp
#include <bits/stdc++.h>
using namespace std;

struct Node {
    long long sum = 0;
    long long mx = 0;
    long long lmx = 0;
    long long rmx = 0;
    int len = 0;

    Node() = default;
    explicit Node(long long x) : sum(x), mx(x), lmx(x), rmx(x), len(1) {}
};

Node mergeNode(const Node& a, const Node& b) {
    if (!a.len) return b;
    if (!b.len) return a;
    Node c;
    c.len = a.len + b.len;
    c.sum = a.sum + b.sum;
    c.lmx = max(a.lmx, a.sum + b.lmx);
    c.rmx = max(b.rmx, b.sum + a.rmx);
    c.mx = max({a.mx, b.mx, a.rmx + b.lmx});
    return c;
}

int n, N, logN;
vector<long long> a;
vector<vector<Node>> f;

Node valueAt(int i) {
    return i <= n ? Node(a[i]) : Node();
}

void build(int l, int r, int dep) {
    if (l == r) {
        f[dep][l] = valueAt(l);
        return;
    }
    int mid = (l + r) >> 1;
    f[dep][mid] = valueAt(mid);
    for (int i = mid - 1; i >= l; --i)
        f[dep][i] = mergeNode(valueAt(i), f[dep][i + 1]);
    f[dep][mid + 1] = valueAt(mid + 1);
    for (int i = mid + 2; i <= r; ++i)
        f[dep][i] = mergeNode(f[dep][i - 1], valueAt(i));
    build(l, mid, dep + 1);
    build(mid + 1, r, dep + 1);
}

Node query(int l, int r) {
    if (l == r) return Node(a[l]);
    int x = l + N - 1;
    int y = r + N - 1;
    int highest = 31 - __builtin_clz(static_cast<unsigned>(x ^ y));
    int dep = logN - highest - 1;
    return mergeNode(f[dep][l], f[dep][r]);
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    int q;
    cin >> n >> q;
    a.assign(n + 1, 0);
    for (int i = 1; i <= n; ++i) cin >> a[i];

    N = 1;
    while (N < n) N <<= 1;
    logN = __builtin_ctz(static_cast<unsigned>(N));
    f.assign(logN + 1, vector<Node>(N + 1));
    a.resize(N + 1, 0);
    build(1, N, 0);

    while (q--) {
        int l, r;
        cin >> l >> r;
        cout << query(l, r).mx << '\n';
    }
}
```

`query(l, r)` 的区间必须满足 $1 lt.eq l lt.eq r lt.eq n$。端点叶子编号为 $x = l + N - 1$、$y = r + N - 1$。若 `highest` 是 `x ^ y` 的最高置位下标，则它们 LCA 的深度为 `logN - highest - 1`；不能把 `highest` 本身当作深度。单点区间单独返回，避免对 `x ^ y == 0` 调用 `__builtin_clz`。

====== 线段树套平衡树/树状数组

解决带修改的区间第 $k$ 小问题。

====== 区间最值操作与历史最值结合 WTF

Segment Tree Beats 的终极形态，极其复杂。

