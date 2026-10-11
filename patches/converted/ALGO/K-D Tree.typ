=== #text("K-D Tree K-D 树")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/ALGO/K-D Tree.md`]

==== 讲解

#box(image("../../assets/posts/ALGO/assets/K-D Tree/file-20260910234214539.png"))

==== KDT 可以解决的题目

- 不保证复杂度（非K维矩阵查询，只能是剪枝作用）
  - K 维空间值点查询
- 保证复杂度（标准K维矩阵查询）
  - K 维空间 RMQ

==== P1 静态 - 平面最近点对（剪枝）

- `LG_P1429`
  - n 个二维点，求最近点对距离
  - trick : 存 long long 距离平方，最后开根

==== P2 静态 - Kth 远查询（剪枝）

- `LG_P2094`
  - n 个点，m 次询问，询问到某个点 第 k （很小） 远的点
  - 做法：使用堆优化 kth
  - trick : 依然距离平方

==== P3 静态 - 二维半平面查询（剪枝）

- `LG_P4475`
  - n 个点， m 次询问，询问一个半平面中的权值和
  - 从未设想的道路，回头思考确实是用 K-D 树优化剪枝
  - 猜想：工程上最常用剪枝

==== P4 动态 - 二维矩形动态查询

- `LG_P4148`
  - n x n 的区域
  - op 1: x y 位置加上 A
  - op 2: 查询 x1 x2 y1 y2 区域和
- 一发过哦耶

==== P5 动态 - K 维矩形动态查询(模板型) + 区间加

- `LG_P14312`
  - k 维 m 次操作
  - 1 增加点
  - 2 区间加
  - 3 区间查询

==== P6 动态 - 二维动态哈夫曼距离查询（剪枝）

- `LG_P4169`
  - n 个初始点 m 次操作
  - 1 加点
  - 2 查询距离指定点的最近点距离

==== P7 动态 - 三维偏序（降一维）

- `LG_P3810`
  - 这段代码是 #strong[二维替罪羊 KD 树] 做动态矩形计数，用于三维偏序（洛谷 P3810）。复杂度：
    - #strong[排序];：$O \( n log n \)$
    - #strong[替罪羊 KD 树插入];：均摊 $O \( log n \)$ 每次，总 $O \( n log n \)$
    - #strong[二维矩形查询];：平衡 KD 树下每次最坏/平均 $O \( sqrt(n) \)$，共 $n$ 次，总 $O \( n sqrt(n) \)$
  - #strong[总时间复杂度];：$O \( n log n + n sqrt(n) \) = O \( n sqrt(n) \)$
  - #strong[空间复杂度];：$O \( n \)$

==== P8 动态 - 二维矩形 RMQ - 带删除

- `CF_44G`
  - n 个靶子，依次匹配 m 个子弹

==== P9 动态 - 三维 - 球壳查询（动态 EPS / 精度范围查询）

#quote(block: true)[
卡精度弘文了 最终发现是动态精度 震惊瘫坐
]

- `LG_11716`
  - n 个点 m 次操作
  - 1 插入 x y z 点
- 要注意！ K=3！
  - 所以 `L[0] = {inf, inf, inf}` 三个 分量！！还有 `R[0]`
- 真！卡常！
  - 优化0
    - 起初我还发现了，首次 build 建树的 牢 Trick ！！！
    - 虽然没什么用
  - 优化1
    - 到什么地方，用什么精度，不要总是用一种，
    - 比如二分的时候手动 `1e-9`
  - 优化2
    - 动态 EPS / 精度范围查询
    - 见 code 的注释
  - 精度是个谜
    - 精度高了 tle
    - 低了 神秘 tle 其实是本质 RE （评测机骗人）

==== P10 动态 - 四维偏序 DP（KD 树拿捏掉 2 维）

- `LG_P3769`
  - 求 n 个四元组，由 `<=` 组成的四维偏序的最长链
  - 我回顾了一下 cdq 分治，发现确实是先按照一维排序，然后在一维的基础上再次排序
    - 确实啊
    - 所以就是 先按照 a 排序，然后按照 `{b, i}` 排序
    - 这样的单次查询居然是 $O \( sqrt(n) \)$
    - 但是插入依然是 $O \( n log^2 n \)$ 但是不带根号是好的
  - 注意复杂度关键：
    - 必须带上 `i` 否则的话，就会挤占到同一个树上，导致查询多乘以一个 $log n$ 的复杂度

==== P11 动态 - 在线二维区间第 k 大

#quote(block: true)[
传统的线段树值域二分 + K-D 树上个数查询
]

- `LG_P4848`
  - 给定 n x n 的网格， q 条操作，#strong[强制在线]
  - 1 值 v 加入 (x, y) 位置
  - 2 查询 x1 y1 x2 y2 区间内 第 k 大值，不存在打印 orz\~

==== P12 静态 - 二维 K-D 树优化”建图”

#quote(block: true)[
隐式建图，跑 Dijkstra 在线 update 带剪枝 太牛逼了 不仅 省空间 还 可以剪枝时间，因为 `dist[i] <= dis` 可以直接 return
]

- `LG_P5471`
  - n x n 的矩形区域
  - n 个点 m 条 单点 - 二维区间 边
  - 求 1 到其它点的最短距离
- Trick：
  - 在线激活区间隐式边

==== Codes

===== P1 静态 - L - R

```cpp
#include<bits/stdc++.h>
using namespace std;
using ll = long long;
const ll INF = 1ll << 60;

// 比较推荐替罪羊树实现动态 KDT 因为支持的操作多

// 先搞 静态 KDT

ll ans;

namespace KDT {
    const int N = 2e6 + 5;
    const int K = 2;
    
    // 节点
    int root;
    int lc[N], rc[N];
    
    // 属性
    array<ll,K> p[N], L[N], R[N];
    int arr[N];

    void up(int i) {
        L[i] = R[i] = p[i];
        for (int d = 0; d < K; d++) {
            if (lc[i]) {
                L[i][d] = min(L[i][d], L[lc[i]][d]);
                R[i][d] = max(R[i][d], R[lc[i]][d]);
            }
            if (rc[i]) {
                L[i][d] = min(L[i][d], L[rc[i]][d]);
                R[i][d] = max(R[i][d], R[rc[i]][d]);
            }
        }
    }
    
    int build(int l,int r, int d) {
        if (l > r) return 0;
        int mid = (l + r) / 2;
        nth_element(arr+l,arr+mid,arr+r+1,[&](int a,int b) {
            return p[a][d] < p[b][d];
        });
        int i = arr[mid];
        d = (d + 1) % K;
        lc[i] = build(l,mid-1,d);
        rc[i] = build(mid+1,r,d);
        up(i);
        return i;
    }
    
    // 业务相关
    ll dist(int i,int j) {
        ll res = 0;
        // 【坑点啊！】 没开 long long 爆 int 了
        for (int d = 0; d < K; d++) res += (p[i][d] - p[j][d]) * (p[i][d] - p[j][d]);
        return res;
    }

    // 相当于左右方向剪枝
    ll guess(int i,int j) {
        if (!i) return INF;
        ll res = 0;
        for (int d = 0; d < K; d++) {
            ll v = p[j][d] < L[i][d] ? L[i][d] - p[j][d] : p[j][d] > R[i][d] ? p[j][d] - R[i][d] : 0;
            res += v * v;
        }
        return res;
    }

    void query(int i,int j) {
        if (!i) return;
        if (i != j) {
            ans = min(ans, dist(i, j));
        }
        ll gl = guess(lc[i], j);
        ll gr = guess(rc[i], j);
        if (gl < gr) {
            if (gl < ans) query(lc[i], j);
            if (gr < ans) query(rc[i], j);
        } else {
            if (gr < ans) query(rc[i], j);
            if (gl < ans) query(lc[i], j);
        }
    }
}

struct LG_P1429 {
    inline static const int N = 2e5 + 5;
    int n;
    LG_P1429() {
        cin >> n;
        for (int i = 1; i <= n; i++) {
            cin >> KDT::p[i][0] >> KDT::p[i][1];
            KDT::arr[i] = i;
        }
        KDT::root = KDT::build(1, n, 0);
        ans = INF;
        for (int i = 1; i <= n; i++) {
            KDT::query(KDT::root, i);
        }
        cout << fixed << setprecision(4) << sqrt(ans) << "\n";
    }
};

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    new LG_P1429();
}
```

===== P2 静态 - L - R

```cpp
#include<bits/stdc++.h>
using namespace std;
using ll = long long;
const ll INF = 1ll << 60;

const int N = 1e5 + 5;
const int K = 2;

int n, m, k;

struct Node {
    ll dist;
    int u;
    bool operator<(const Node o) const {
        return dist != o.dist ? dist > o.dist : u < o.u;
    }
};

priority_queue<Node> Q;

// 业务
void add(Node o) {
    Q.push(o);
    while(Q.size() > k) Q.pop();
}

namespace KDT {
    array<ll,K> p[N], L[N], R[N];

    int root;
    int lc[N], rc[N];
    int arr[N];

    void up(int i) {
        L[i] = R[i] = p[i];
        for (int d = 0; d < K; d++) {
            if (lc[i]) {
                L[i][d] = min(L[i][d], L[lc[i]][d]);
                R[i][d] = max(R[i][d], R[lc[i]][d]);
            }
            if (rc[i]) {
                L[i][d] = min(L[i][d], L[rc[i]][d]);
                R[i][d] = max(R[i][d], R[rc[i]][d]);
            }
        }
    }

    int build(int l,int r,int d) {
        if (l > r) return 0;
        int mid = (l + r) / 2;
        nth_element(arr+l,arr+mid,arr+r+1,[&](int a,int b) {
            return p[a][d] < p[b][d];
        });
        int i = arr[mid];
        d = (d + 1) % K;
        lc[i] = build(l,mid-1,d);
        rc[i] = build(mid+1,r,d);
        up(i);
        return i;
    }

    // 这是真实的点
    ll dist(array<ll,K> a,array<ll,K> b) {
        ll res = 0;
        for (int d = 0; d < K; d++) {
            ll v = a[d] - b[d];
            res += v * v;
        }
        return res;
    }

    // 【注意这是放缩】 均取最优
    ll guess(int i, array<ll,K> no) {
        if (!i) return -INF; // 负数啊
        ll res = 0;
        for (int d = 0; d < K; d++) {
            ll v = max(abs(no[d]-L[i][d]), abs(no[d]-R[i][d]));
            res += v * v;
        }
        return res;
    }

    void query(int i,array<ll,K> no) {
        if (!i) return;
        add({dist(p[i],no), i});
        // 【有点危险】
        ll gl = guess(lc[i], no);
        ll gr = guess(rc[i], no);
        if (gl > gr) {
            // 这也 太 tm 危险了 所以 是 骗分技巧哦
            if (Q.size() < k || gl >= Q.top().dist) query(lc[i], no);
            if (Q.size() < k || gr >= Q.top().dist) query(rc[i], no);
        } else {
            if (Q.size() < k || gr >= Q.top().dist) query(rc[i], no);
            if (Q.size() < k || gl >= Q.top().dist) query(lc[i], no);
        }
    }
}

struct LG_P2094 {
    LG_P2094() {
        cin >> n;
        for (int i = 1; i <= n; i++) {
            cin >> KDT::p[i][0] >> KDT::p[i][1];
            KDT::arr[i] = i;
        }
        KDT::root = KDT::build(1, n, 0);
        cin >> m;
        while (m--) {
            while(Q.size()) Q.pop();
            array<ll,K> no;
            cin >> no[0] >> no[1] >> k;
            KDT::query(KDT::root, no);
            cout << Q.top().u << "\n";
        }
    }
};

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    new LG_P2094();
}
```

===== P3 静态 - L - R - sum - val

```cpp
#include<bits/stdc++.h>
using namespace std;
using ll = long long;

const int N = 5e4 + 5;
const int K = 2;

int n,m;
ll a,b,c;

namespace KDT {
    array<ll,K> p[N], L[N], R[N];
    ll sum[N], val[N];

    int root;
    int lc[N], rc[N];
    int arr[N];

    void up(int i) {
        L[i] = R[i] = p[i];
        for (int d = 0; d < K; d++) {
            if (lc[i]) {
                L[i][d] = min(L[i][d], L[lc[i]][d]);
                R[i][d] = max(R[i][d], R[lc[i]][d]);
            }
            if (rc[i]) {
                L[i][d] = min(L[i][d], L[rc[i]][d]);
                R[i][d] = max(R[i][d], R[rc[i]][d]);
            }
        }
        sum[i] = sum[lc[i]] + sum[rc[i]] + val[i];
    }

    int build(int l,int r,int d) {
        if(l > r) return 0;
        int mid = (l + r) / 2;
        nth_element(arr+l,arr+mid,arr+r+1,[&](int a,int b) {
            return p[a][d] < p[b][d];
        });
        int i = arr[mid];
        d = (d + 1) % K;
        lc[i] = build(l,mid-1,d);
        rc[i] = build(mid+1,r,d);
        up(i);
        return i;
    }

    // 直接剪枝
    ll query(int i) {
        if (!i) return 0;
        ll x1 = L[i][0] * a, x2 = R[i][0] * a;
        ll y1 = L[i][1] * b, y2 = R[i][1] * b;
        if (x1 < x2) swap(x1, x2);
        if (y1 < y2) swap(y1, y2);
        if (x1 + y1 < c) return sum[i];
        if (x2 + y2 >= c) return 0;
        ll res = (p[i][0] * a + p[i][1] * b < c ? val[i] : 0);
        res += query(lc[i]);
        res += query(rc[i]);
        return res;
    }
}

struct LG_P4475 {
    LG_P4475() {
        cin >> n >> m;
        for (int i = 1; i <= n; i++) {
            cin >> KDT::p[i][0] >> KDT::p[i][1] >> KDT::val[i];
            KDT::arr[i] = i;
        }
        KDT::root = KDT::build(1, n, 0);
        while (m--) {
            cin >> a >> b >> c;
            cout << KDT::query(KDT::root) << "\n";
        }
    }
};

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    new LG_P4475();
}
```

===== P4 动态 - L - R - sum - val - sz

```cpp
#include<bits/stdc++.h>
using namespace std;

const int N = 2e5 + 5;
const int K = 2;
const double alpha = 0.7;

namespace KDT {

    // 全局查询属性 (废弃，太丑了)
    // array<int,K> a, b;
    
    // 节点基本属性
    int tot;
    int root;
    int lc[N], rc[N];
    
    // 节点附加属性（KDT)
    array<int,K> p[N], L[N], R[N];
    
    // 节点附加属性 （业务）
    int sum[N], val[N], sz[N];

    // 替罪羊树专用
    int* tp, tpd;
    int buf[N], idx;

    // 基础信息维护
    void up(int i) {
        L[i] = R[i] = p[i];
        for (int d = 0; d < K; d++) {
            if (lc[i]) {
                L[i][d] = min(L[i][d], L[lc[i]][d]);
                R[i][d] = max(R[i][d], R[lc[i]][d]);
            }
            if (rc[i]) {
                L[i][d] = min(L[i][d], L[rc[i]][d]);
                R[i][d] = max(R[i][d], R[rc[i]][d]);
            }
        }
        sum[i] = sum[lc[i]] + sum[rc[i]] + val[i];
        sz[i] = sz[lc[i]] + sz[rc[i]] + 1;
    }

    // 替罪羊节点（动态）
    int new_node(array<int,K> no, int v) {
        ++tot;
        lc[tot] = rc[tot] = 0;
        sz[tot] = 1; // !!!
        L[tot] = R[tot] = p[tot] = no;
        sum[tot] = val[tot] = v;
        return tot;
    }

    // 替罪羊判断
    bool balance(int x) {
        return max(sz[lc[x]], sz[rc[x]]) < sz[x] * alpha;
    }

    // 替罪羊收集
    void collect(int u) {
        if(!u) return;
        buf[++idx] = u;
        collect(lc[u]);
        collect(rc[u]);
    }

    // 替罪羊重建
    int rebuild(int l,int r,int d) {
        if (l > r) return 0;
        int mid = (l + r) / 2;
        nth_element(buf+l,buf+mid,buf+r+1, [&](int a,int b) {
            return p[a][d] < p[b][d];
        });
        int i = buf[mid];
        d = (d + 1) % K;
        lc[i] = rebuild(l,mid-1,d);
        rc[i] = rebuild(mid+1,r,d);
        up(i);
        return i;
    }
    
    // 内部插入
    void _insert(int& i,int d, array<int,K> no, int v) {
        if (!i) {
            i = new_node(no, v);
            return;
        }
        if (no[d] < p[i][d]) {
            _insert(lc[i], (d+1)%K, no, v);
        } else {
            _insert(rc[i], (d+1)%K, no, v);
        }
        up(i);
        if (!balance(i)) {
            tp = &i;
            tpd = d;
        }
    }
    
    // 外部插入
    void insert(array<int,K> no, int v) {
        _insert(root, 0, no, v);
        if (tp) {
            idx = 0;
            collect(*tp);
            *tp = rebuild(1, idx, tpd);            
            tp = NULL;
        }
    }

    // 内部查询
    int _query(int i,int d, array<int,K> jL, array<int,K> jR) {
        if (!i) return 0;
        // jlx <= lx && rx <= jrx
        if (jL[0] <= L[i][0] && jL[1] <= L[i][1] && R[i][0] <= jR[0] && R[i][1] <= jR[1]) {
            return sum[i];
        }
        // jlx > rx || jrx < lx .... emm
        if (jL[0] > R[i][0] || jL[1] > R[i][1] || jR[0] < L[i][0] || jR[1] < L[i][1]) {
            return 0;
        }
        // jlx <= px && px <= jrx
        int res = 0;
        if (jL[0] <= p[i][0] && jL[1] <= p[i][1] && p[i][0] <= jR[0] && p[i][1] <= jR[1]) {
            res += val[i];
        }
        d = (d + 1) % K;
        res += _query(lc[i],d, jL, jR);
        res += _query(rc[i],d, jL, jR);
        return res;
    }

    // 外部查询
    int query(array<int,K> jL, array<int,K> jR) {
        return _query(root, 0, jL, jR);
    }
}

struct LG_P4148 {
    LG_P4148() {
        int lst = 0;
        int n, op, x, y, x1, y1, x2, y2, A;
        cin >> n;
        while(cin >> op && op != 3) {
            if (op == 1) {
                cin >> x >> y >> A;
                x ^= lst, y ^=lst, A ^= lst;
                KDT::insert({x, y}, A);
            } else {
                cin >> x1 >> y1 >> x2 >> y2;
                x1 ^= lst, y1 ^= lst, x2 ^=lst, y2 ^= lst;
                cout << (lst = KDT::query({x1, y1}, {x2, y2})) << "\n";
            }
        }
    }
};

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    new LG_P4148();
}
```

===== P5 动态 - L - R - sum - val - sz - Template

```cpp
#include<bits/stdc++.h>
using namespace std;
using ll = long long;

const int N = 2e5 + 5;
const double alpha = 0.7;

template<int K>
struct KDT {
    array<ll,K> p[N], L[N], R[N];
    
    // 树结构信息
    int tot;
    int root;
    int lc[N], rc[N];

    // 基础信息
    ll sum[N], val[N];
    // 懒信息
    ll tag[N];
    int sz[N];

    // 替罪羊信息
    int *tp, tpd;
    int buf[N], idx;

    // 替罪羊新节点
    int new_node(array<ll,K> no, ll v) {
        ++tot;
        L[tot] = R[tot] = p[tot] = no;
        lc[tot] = rc[tot] = 0;
        sum[tot] = val[tot] = v;
        tag[tot] = 0;
        sz[tot] = 1;
        return tot;
    }

    void up(int i) {
        L[i] = R[i] = p[i];
        for (int d = 0; d < K; d++) {
            if (lc[i]) {
                L[i][d] = min(L[i][d], L[lc[i]][d]);
                R[i][d] = max(R[i][d], R[lc[i]][d]);
            }
            if (rc[i]) {
                L[i][d] = min(L[i][d], L[rc[i]][d]);
                R[i][d] = max(R[i][d], R[rc[i]][d]);
            }
        }
        sum[i] = sum[lc[i]] + sum[rc[i]] + val[i];
        sz[i] = sz[lc[i]] + sz[rc[i]] + 1;
    }

    // 懒标记
    void lazy(int i,ll v) {
        if (i) {
            sum[i] += sz[i] * v;
            val[i] += v;
            tag[i] += v;
        }
    }

    // 懒下传
    void down(int i) {
        if (tag[i]) {
            lazy(lc[i], tag[i]);
            lazy(rc[i], tag[i]);
            tag[i] = 0;
        }
    }

    // 替罪羊判定
    bool balance(int i) {
        return max(sz[lc[i]], sz[rc[i]]) < sz[i] * alpha;
    }

    // 替罪羊加入
    void _insert(int& i,int d, array<ll,K> no, ll v) {
        if (!i) {
            i = new_node(no, v);
        } else {
            down(i);
            if (no[d] < p[i][d]) {
                _insert(lc[i],(d+1)%K,no,v);
            } else {
                _insert(rc[i],(d+1)%K,no,v);
            }
            up(i);
            if(!balance(i)) {
                tp = &i;
                tpd = d;
            }
        }
    }

    // 替罪羊 add
    void _add(int i,int d, array<ll,K> jL, array<ll,K> jR, ll v) {
        if (!i) return;
        bool contain = true;
        for (int d = 0; d < K; d++) {
            contain &= jL[d] <= L[i][d] && R[i][d] <= jR[d];
            if (jL[d] > R[i][d] || L[i][d] > jR[d]) return;
        }
        if (contain) lazy(i, v);
        else {
            down(i);
            // 【chovy!!!】 _add 的时候没有特判 i 点!!!!
            bool contain = true;
            for (int d = 0; d < K; d++) {
                contain &= jL[d] <= p[i][d] && p[i][d] <= jR[d];
            }
            if (contain) val[i] += v;
            d = (d + 1) % K;
            _add(lc[i], d, jL, jR, v);
            _add(rc[i], d, jL, jR, v);
            up(i);
        }
    }
    
    // 替罪羊 query 
    ll _query(int i,int d, array<ll,K> jL, array<ll,K> jR) {
        if (!i) return 0;
        bool contain = true;
        for (int d = 0; d < K; d++) {
            contain &= jL[d] <= L[i][d] && R[i][d] <= jR[d];
            if (jL[d] > R[i][d] || L[i][d] > jR[d]) return 0;
        }
        if (contain) {
            return sum[i];  
        }else {
            down(i);
            bool contain = true;
            for (int d = 0; d < K; d++) {
                contain &= jL[d] <= p[i][d] && p[i][d] <= jR[d];
            }
            ll res = contain ? val[i] : 0;
            d = (d + 1) % K;
            res += _query(lc[i], d, jL, jR);
            res += _query(rc[i], d, jL, jR);
            return res;
        }
    }

    // 替罪羊收集
    void collect(int i) {
        if (i) {
            buf[++idx] = i;
            down(i); // !!!!
            collect(lc[i]);
            collect(rc[i]);
        }
    }

    // 替罪羊重建
    int rebuild(int l,int r, int d) {
        if(l > r) return 0;
        int mid = (l + r) / 2;
        nth_element(buf+l,buf+mid,buf+r+1,[&](int a,int b) {
            return p[a][d] < p[b][d];
        });
        int i = buf[mid];
        d = (d + 1) % K;
        lc[i] = rebuild(l,mid-1,d);
        rc[i] = rebuild(mid+1,r,d);
        up(i);
        return i;
    }

    // 业务一连
    void insert(array<ll,K> no, ll v) {
        _insert(root, 0, no, v);
        if (tp) {
            idx = 0;
            collect(*tp);
            *tp = rebuild(1, idx, tpd);
            tp = NULL;
        }
    }

    // 业务双连
    void add(array<ll,K> jL, array<ll,K> jR, ll v) {
        _add(root, 0, jL, jR, v);
    }
    
    // 业务三连
    ll query(array<ll,K> jL, array<ll,K> jR) {
        return _query(root, 0, jL, jR);
    }
};

template<int K> 
struct LG_P14312 {
    KDT<K>* T;
    int m, op;
    array<ll,K> jL, jR, no;
    ll v, lst;
    LG_P14312() {
        T = new KDT<K>();
        lst = 0; // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 都 new 了还是随机数？
        cin >> m;
        while(m--) {
            cin >> op;
            if (op == 1) {
                for (int d = 0; d < K; d++) cin >> no[d], no[d] ^= lst;
                cin >> v; v ^= lst;
                T->insert(no, v);
            } else if(op == 2) {
                for (int d = 0; d < K; d++) cin >> jL[d], jL[d] ^= lst;
                for (int d = 0; d < K; d++) cin >> jR[d], jR[d] ^= lst;
                cin >> v; v ^= lst;
                T->add(jL, jR, v);
            } else {
                for (int d = 0; d < K; d++) cin >> jL[d], jL[d] ^= lst;
                for (int d = 0; d < K; d++) cin >> jR[d], jR[d] ^= lst;
                cout << (lst = T->query(jL, jR)) << "\n";
            }
        }
    }
};

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    int k;
    cin >> k;
    if (k == 2) new LG_P14312<2>();
    else new LG_P14312<3>();
}
```

===== P6 动态 - L - R - sz

```cpp
#include<bits/stdc++.h>
using namespace std;

const int N = 6e5 + 5;
const int K = 2;
const double alpha = 0.7;
const int inf = 1e9;

int n, m;
int ans;

int dist(array<int,K> a, array<int,K> b) {
    return abs(b[0] - a[0]) + abs(b[1] - a[1]);
}

int guess(array<int,K> no, array<int,K> jL, array<int,K> jR) {
    int dx = no[0] < jL[0] ? jL[0] - no[0] : no[0] > jR[0] ? no[0] - jR[0] : 0;
    int dy = no[1] < jL[1] ? jL[1] - no[1] : no[1] > jR[1] ? no[1] - jR[1] : 0;
    return dx + dy;
}

namespace KDT {
    array<int,K> p[N], L[N], R[N];

    int tot;
    int root;
    int lc[N], rc[N];
    
    int *tp, tpd;
    int buf[N], idx;

    int sz[N];

    int new_node(array<int,K> no) {
        int i = ++tot;
        L[i] = R[i] = p[i] = no;
        lc[i] = rc[i] = 0;
        sz[i] = 1;
        return i;
    }

    void up(int i) {
        L[i] = R[i] = p[i];
        for (int d = 0; d < K; d++) {
            if (lc[i]) {
                L[i][d] = min(L[i][d], L[lc[i]][d]);
                R[i][d] = max(R[i][d], R[lc[i]][d]);
            }
            if (rc[i]) {
                L[i][d] = min(L[i][d], L[rc[i]][d]);
                R[i][d] = max(R[i][d], R[rc[i]][d]);
            }
        }
        sz[i] = sz[lc[i]] + sz[rc[i]] + 1;
    }

    bool balance(int i) {
        return max(sz[lc[i]], sz[rc[i]]) < sz[i] * alpha;
    }

    void collect(int i) {
        if(i) {
            buf[++idx] = i;
            collect(lc[i]);
            collect(rc[i]);
        }
    }

    int rebuild(int l,int r,int d) {
        if (l > r) return 0;
        int mid = (l + r) / 2;
        nth_element(buf+l,buf+mid,buf+r+1,[&](int a,int b) {
            return p[a][d] < p[b][d];
        });
        int i = buf[mid];
        d = (d + 1) % K;
        lc[i] = rebuild(l,mid-1,d);
        rc[i] = rebuild(mid+1,r,d);
        up(i);
        return i;
    }

    void _insert(int& i,int d, array<int,K> no) {
        if (!i) {
            i = new_node(no);
        } else {
            if (no[d] < p[i][d]) {
                _insert(lc[i], (d+1)%K, no);
            } else {
                _insert(rc[i], (d+1)%K, no);
            }
            up(i);
            if (!balance(i)) {
                tp = &i;
                tpd = d;
            }
        }
    }

    void _query(int i,array<int,K> no) {
        if (!i) return;
        ans = min(ans, dist(p[i], no));
        int gl = guess(no, L[lc[i]], R[lc[i]]);
        int gr = guess(no, L[rc[i]], R[rc[i]]);
        if (gl < gr) {
            if (gl < ans) _query(lc[i], no);
            if (gr < ans) _query(rc[i], no);
        } else {
            if (gr < ans) _query(rc[i], no);
            if (gl < ans) _query(lc[i], no);
        }
    }

    void insert(array<int,K> no) {
        _insert(root, 0, no);
        if (tp) {
            idx = 0;
            collect(*tp);
            *tp = rebuild(1,idx,tpd);
            tp = NULL;
        }
    }

    int query(array<int,K> no) {
        ans = 1e9;
        _query(root, no);
        return ans;
    }
}

struct LG_P4169 {
    LG_P4169() {
        // guess 不得不特判
        KDT::L[0] = {inf, inf};
        KDT::R[0] = {-inf, -inf};
        cin >> n >> m;
        for (int i = 1; i <= n; i++) {
            int x, y;
            cin >> x >> y;
            KDT::buf[++KDT::idx] = KDT::new_node({x, y});
        }
        KDT::root = KDT::rebuild(1, KDT::idx, 0);
        while (m--) {
            int op, x, y;
            cin >> op >> x >> y;
            if (op == 1) {
                KDT::insert({x, y});
            } else {
                cout << KDT::query({x, y}) << "\n";
            }
        }
    }
};

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    new LG_P4169();
}
```

===== P7 动态 - 三维偏序（降一维）

```cpp
#include<bits/stdc++.h>
using namespace std;

const int N = 1e5 + 5;
const int K = 2;
const double alpha = 0.7;
const int inf = 1e9;

int n, k;
array<int,3> abc[N];
int cnt[N];

namespace KDT {
    // K-D 属性
    array<int,K> p[N], L[N], R[N];

    // 基础信息
    int tot;
    int root;
    int lc[N], rc[N];

    // 替罪羊信息
    int *tp, tpd;
    int buf[N], idx;

    // 替罪羊属性
    int sz[N];

    // 初始化
    void init() {
        L[0] = {inf, inf};
        R[0] = {-inf, -inf};
    }

    // 替罪羊新节点
    int new_node(array<int,K> no) {
        int i = ++tot;
        lc[i] = rc[i] = 0;
        L[i] = R[i] = p[i] = no;
        sz[i] = 1;
        return i;
    }

    // 整合
    void up(int i) {
        L[i] = R[i] = p[i];
        for (int d = 0; d < K; d++) {
            // 干脆这一次直接懒点 L = {inf,inf} R = {-inf,-inf};
            L[i][d] = min(L[i][d], L[lc[i]][d]);
            R[i][d] = max(R[i][d], R[lc[i]][d]);
            L[i][d] = min(L[i][d], L[rc[i]][d]);
            R[i][d] = max(R[i][d], R[rc[i]][d]);
        }
        sz[i] = sz[lc[i]] + sz[rc[i]] + 1;
    }

    // 替罪羊平衡
    bool balance(int i) {
        return max(sz[lc[i]], sz[rc[i]]) < sz[i] * alpha;
    }

    // 替罪羊收集
    void collect(int i) {
        if (i) {
            buf[++idx] = i;
            collect(lc[i]);
            collect(rc[i]);
        }
    }

    // 替罪羊重建
    int rebuild(int l,int r, int d) {
        if (l > r) return 0;
        int mid = (l + r) / 2;
        nth_element(buf+l,buf+mid,buf+r+1,[&](int a,int b) {
            return p[a][d] < p[b][d];
        });
        int i = buf[mid];
        d = (d + 1) % K;
        lc[i] = rebuild(l,mid-1,d);
        rc[i] = rebuild(mid+1,r,d);
        up(i);
        return i;
    }

    // 内插入
    void _insert(int& i,int d,array<int,K> no) {
        if (!i) {
            i = new_node(no);
        } else {
            if (no[d] < p[i][d]) {
                _insert(lc[i],(d+1)%K,no);
            } else {
                _insert(rc[i],(d+1)%K,no);
            }
            up(i);
            if(!balance(i)) {
                tp = &i;
                tpd = d;
            }
        }
    }

    // 内查询 注意到 查询是不需要维护 d 的
    int _query(int i,array<int,K> jL, array<int,K> jR) {
        if (!i) return 0;
        bool contain = true;
        for (int d = 0; d < K; d++) {
            contain &= jL[d] <= L[i][d] && R[i][d] <= jR[d];
            // 【chovy!!!】 光想着 contain 了 忘了 out 了
            if (jL[d] > R[i][d] || L[i][d] > jR[d]) return 0;
        }
        if (contain) return sz[i];
        else {
            int res = 0;
            bool contain = true;
            for (int d = 0; d < K; d++) {
                contain &= jL[d] <= p[i][d] && p[i][d] <= jR[d];
            }
            res += contain;
            res += _query(lc[i],jL,jR);
            res += _query(rc[i],jL,jR);
            return res;
        }
    }

    // 业务插入
    void insert(array<int,K> no) {
        _insert(root, 0, no);
        if (tp) {
            idx=0;
            collect(*tp);
            *tp = rebuild(1,idx,tpd);
            tp = 0;
        }
    }

    // 业务查询
    int query(array<int,K> jL, array<int,K> jR) {
        return _query(root,jL,jR);
    }
}

struct LG_P3810 {
    LG_P3810() {
        KDT::init();
        cin >> n >> k;
        for (int i = 1; i <= n; i++) {
            auto& [a,b,c] = abc[i];
            cin >> a >> b >> c;
        }
        sort(abc+1,abc+1+n);
        for (int i = 1; i <= n; i++) {
            int j = i;
            while(j + 1 <= n && abc[j+1][0] == abc[i][0]) j++;
            for (int k = i; k <= j; k++)
                KDT::insert({abc[k][1], abc[k][2]});
            for (int k = i; k <= j; k++) 
                cnt[KDT::query({0,0},{abc[k][1], abc[k][2]}) - 1]++;
            i = j;
        }
        for (int i = 0; i < n; i++) cout << cnt[i] << "\n";
    }
};

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    new LG_P3810();
}
```

===== P8 动态 - 二维矩形 RMQ - 带删除 - L - R - cnt - has - mn

```cpp
#include<bits/stdc++.h>
using namespace std;

const int N = 1e5 + 5;
const int K = 2;
const double alpha = 0.7;
const int inf = 1e9;

int n, m;
array<int,6> zxxyyi[N];
array<int,2> xy[N];
int ans[N];

namespace KDT {
    int ans;
    array<int,K> p[N], L[N], R[N];

    int tot;
    int root;
    int lc[N], rc[N];

    int *tp, tpd;
    int buf[N], idx;

    int sz[N], cnt[N], mx[N], mn[N];
    bool has[N];

    // !!!
    void init() {
        mx[0] = -inf;
        mn[0] = inf;
        L[0] = {inf, inf};
        R[0] = {-inf, -inf};
    }

    int new_node(array<int,K> no) {
        int i = ++tot;
        has[i] = true;
        sz[i] = cnt[i] = 1;
        mx[i] = mn[i] = i;
        lc[i] = rc[i] = 0;
        L[i] = R[i] = p[i] = no;
        return i;
    }

    void up(int i) {
        mx[i] = has[i] ? i : -inf;
        mn[i] = has[i] ? i : inf;
        L[i] = has[i] ? p[i] : array{inf,inf};
        R[i] = has[i] ? p[i] : array{-inf,-inf};
        for (int d = 0; d < K; d++) {
            L[i][d] = min(L[i][d], L[lc[i]][d]);
            L[i][d] = min(L[i][d], L[rc[i]][d]);
            R[i][d] = max(R[i][d], R[lc[i]][d]);
            R[i][d] = max(R[i][d], R[rc[i]][d]);
        }
        sz[i] = sz[lc[i]] + sz[rc[i]] + 1;
        cnt[i] = cnt[lc[i]] + cnt[rc[i]] + has[i];
        mx[i] = max(mx[i], mx[lc[i]]);
        mx[i] = max(mx[i], mx[rc[i]]);
        mn[i] = min(mn[i], mn[lc[i]]);
        mn[i] = min(mn[i], mn[rc[i]]);
    }

    bool balance(int i) {
        return max(cnt[lc[i]], cnt[rc[i]]) < cnt[i] * alpha;
    }

    void collect(int i) {
        if (i && cnt[i]) {
            if(has[i]) buf[++idx] = i;
            collect(lc[i]);
            collect(rc[i]);
        }
    }

    int rebuild(int l,int r,int d) {
        if (l > r) return 0;
        int mid = (l + r) / 2;
        // 【chovy!!!】 注意这里的 (a, b) 对
        nth_element(buf+l,buf+mid,buf+r+1,[&](int a,int b) {
            return p[a][d] ^ p[b][d] ? p[a][d] < p[b][d] : a < b;
        });
        int i = buf[mid];
        d = (d + 1) % K;
        lc[i] = rebuild(l,mid-1,d);
        rc[i] = rebuild(mid+1,r,d);
        up(i);
        return i;
    }

    // 试验版：即将插入的节点是 j 已经提前 new_node 
    void _insert(int& i,int d, int j) {
        if (!i) i = j;
        else {
            // 【chovy!!!】 别判断反了 判断的对是 (j, i) !!!!
            if (p[i][d] ^ p[j][d] ? p[j][d] < p[i][d] : j < i) {
                _insert(lc[i], (d+1)%K, j);
            } else {
                _insert(rc[i], (d+1)%K, j);
            }
            up(i);
            if (!balance(i)) {
                tp = &i;
                tpd = d;
            }
        }
    }

    // 直接 cv 的 _insert
    void _erase(int& i,int d,int j) {
        assert(i);
        if (i == j) {
            has[i] = false;
            up(i);
        } else {
            // 【chovy!!!】 别判断反了 判断的对是 (j, i) !!!!
            if (p[i][d] ^ p[j][d] ? p[j][d] < p[i][d] : j < i) {
                _erase(lc[i], (d+1)%K, j);
            } else {
                _erase(rc[i], (d+1)%K, j);
            }
            up(i);
        }
        if (!balance(i)) {
            tp = &i;
            tpd = d;
        }
    }

    void _query(int i,array<int,K> jL, array<int,K> jR) {
        // cout << "qeury:" << jL[0] << " " << jL[1] << " " << jR[0] << " " << jR[1] << "\n";
        // cout << "cur:" << i << " mn :" << mn[i] << "\n";
        if (!i) return;
        bool contain = true;
        for (int d = 0; d < K; d++) {
            contain &= jL[d] <= L[i][d] && R[i][d] <= jR[d];
            if (jL[d] > R[i][d] || L[i][d] > jR[d]) return;
        }
        if (contain) {
            ans = min(ans, mn[i]);
            return;
        } else {
            // 【chovy!!!】 需要存在才可以判断该点
            if (has[i]) {
                bool contain = true;
                // 【chovy】 又忘了该点
                for (int d = 0; d < K; d++) {
                    contain &= jL[d] <= p[i][d] && p[i][d] <= jR[d];
                }
                if (contain) ans = min(ans, i);
            }
            int gl = mn[lc[i]];
            int gr = mn[rc[i]];
            if (gl < gr) {
                if (gl < ans) _query(lc[i], jL, jR);
                if (gr < ans) _query(rc[i], jL, jR);
            } else {
                if (gr < ans) _query(rc[i], jL, jR);
                if (gl < ans) _query(lc[i], jL, jR);
            }
        }
    }

    int insert(array<int,K> no) {
        int j = new_node(no);
        _insert(root,0,j);
        if (tp) {
            idx=0;
            collect(*tp);
            *tp = rebuild(1,idx,tpd);
            tp = 0;
        }
        // 其实这个编号这一题没什么用 
        return j; // 哎我操 把新建的编号返回， 就像 Trie 树一样
    }
    
    void erase(int j) {
        _erase(root,0,j);
        if (tp) {
            idx=0;
            collect(*tp);
            *tp = rebuild(1,idx,tpd);
            tp = 0;
        }
    }

    int query(array<int,K> jL, array<int,K> jR) {
        ans = inf;
        _query(root, jL, jR);
        return ans;
    }
}

struct CF_44G {
    CF_44G() {
        KDT::init();
        cin >> n;
        for (int i = 1; i <= n; i++) {
            auto& [z,x1,x2,y1,y2,id] = zxxyyi[i];
            cin >> x1 >> x2 >> y1 >> y2 >> z;
            id = i;
        }
        cin >> m;
        for (int i = 1; i <= m; i++) {
            auto& [x,y] = xy[i];
            cin >> x >> y;
            KDT::insert({x, y});
        }
        sort(zxxyyi+1,zxxyyi+1+n);
        for (int i = 1; i <= n; i++) {
            auto [z,x1,x2,y1,y2,id] = zxxyyi[i];
            int hit = KDT::query({x1,y1},{x2,y2});
            if (hit != inf) {
                KDT::erase(hit);
                ans[hit] = id;
            }
        }
        for (int i = 1; i <= m; i++) cout << ans[i] << "\n";
    }
};

int main() {
    ios::sync_with_stdio(0);
    new CF_44G();
}
```

===== P9 动态 - K=3 - 浮点 - L - R - cnt - has

```cpp
#include<bits/stdc++.h>
#define endl "\n"
using namespace std;
using db = double;

const int N = 1e5 + 5;
const int K = 3;
const db alpha = 0.7;
const db inf = 1e100;
const db eps = 1e-8;

// 【真卡精度啊】 动态 eps 因为有 pow2 放缩
// 所以可以
// 1. EPS = 2 * x * eps
// 2. low, high = pow2(max(0.0, x-eps)), pow2(x+eps)
// 正解就是要考虑动态 EPS 
// 2. 最标准！！！！！！！！！！！！！！！！！！！！
// 这其实就是 微小的 区间查询 
// 使用的 K-DTree 剪枝了
// 似乎正解居然是数学题？？？ 怎么可能！？？！
db EPS;

int sign(db x) {
    if (x < -eps) return -1;
    if (x > eps) return 1;
    return 0;
}

int sign2(db x) {
    if (x < -EPS) return -1;
    if (x > EPS) return 1;
    return 0;
}

int cmp(db x, db y) {
    return sign(x - y);
}

int cmp2(db x, db y) {
    return sign2(x - y);
}

db dist2(array<db,K> a, array<db,K> b) {
    db res = 0;
    for (int d = 0; d < K; d++) {
        db v = a[d] - b[d];
        res += v * v;
    }
    return res;
}

db guess1(array<db,K> a, array<db,K> L, array<db,K> R) {
    db res = 0;
    for (int d = 0; d < K; d++) {
        db v = a[d] < L[d] ? L[d] - a[d] : a[d] > R[d] ? a[d] - R[d] : 0;
        res += v * v;
    }
    return res;
}

db guess2(array<db,K> a, array<db,K> L, array<db,K> R) {
    db res = 0;
    for (int d= 0; d < K; d++) {
        db v = max(abs(a[d]-L[d]), abs(a[d]-R[d]));
        res += v * v;
    }
    return res;
}

namespace KDT {
    db r2;
    int ans;
    array<db,K> no;

    array<db,K> p[N], L[N], R[N];
    
    int tot;
    int root;
    int lc[N], rc[N];

    int *tp, tpd;
    int buf[N], idx;

    // 替罪羊
    int cnt[N];
    bool has[N];
    // 业务标记
    int id[N];

    void init() {
        // 【chovy!!!】 K = 3 !!!!!!!!!!!!!!!!!!!!!!!!!!!
        L[0] = {inf, inf, inf}; //
        R[0] = {-inf, -inf, -inf};
    }

    // 因为坐标要复用？？？ 我，懒删除，如何复用？
    // 所以，重新建一个呗
    int new_node(array<db,K> no, int _id) {
        int i = ++tot;
        lc[i] = rc[i] = 0;
        has[i] = true;
        cnt[i] = 1;
        L[i] = R[i] = p[i] = no;
        id[i] = _id;
        return i;
    }

    void up(int i) {
        if (has[i]) {
            L[i] = R[i] = p[i];
        } else {
            L[i] = L[0]; 
            R[i] = R[0];
        }
        cnt[i] = cnt[lc[i]] + cnt[rc[i]] + has[i];
        for (int d = 0; d < K; d++) {
            L[i][d] = min(L[i][d], L[lc[i]][d]);
            L[i][d] = min(L[i][d], L[rc[i]][d]);
            R[i][d] = max(R[i][d], R[lc[i]][d]);
            R[i][d] = max(R[i][d], R[rc[i]][d]);
        }
    }

    bool balance(int i) {
        return max(cnt[lc[i]], cnt[rc[i]]) < cnt[i] * alpha;
    }

    void collect(int i) {
        if (i && cnt[i]) {
            if (has[i]) buf[++idx] = i;
            collect(lc[i]);
            collect(rc[i]);
        }
    }

    int rebuidb(int l,int r,int d) {
        if (l > r) return 0;
        int mid = (l + r) / 2;
        nth_element(buf+l,buf+mid,buf+r+1,[&](int a,int b) {
            int tmp = cmp(p[a][d], p[b][d]);
            return tmp ? tmp < 0 : a < b;
        });
        int i = buf[mid];
        d = (d == K - 1 ? 0 : d + 1);
        lc[i] = rebuidb(l,mid-1,d);
        rc[i] = rebuidb(mid+1,r,d);
        up(i);
        return i;
    }

    void _insert(int& i,int d,int j) {
        if (!i) {
            i = j;
        } else {
            int tmp = cmp(p[j][d], p[i][d]);
            if (tmp ? tmp < 0 : j < i) {
                _insert(lc[i], (d == K - 1 ? 0 : d + 1), j);
            } else {
                _insert(rc[i], (d == K - 1 ? 0 : d + 1), j);
            }
            up(i);
            if (!balance(i)) {
                tp = &i;
                tpd = d;
            }
        }
    }

    void _erase(int& i,int d,int j) {
        assert(i);
        if(i == j) {
            has[i] = false;
            up(i);
        } else {
            int tmp = cmp(p[j][d], p[i][d]);
            if (tmp ? tmp < 0 : j < i) {
                _erase(lc[i], (d == K - 1 ? 0 : d + 1), j);
            } else {
                _erase(rc[i], (d == K - 1 ? 0 : d + 1), j);
            }
            up(i);
            if (!balance(i)) {
                tp = &i;
                tpd = d;
            }
        }
    }

    void _query(int i,int d) {
        if (!i || ans) return;
        db g1 = guess1(no, L[i], R[i]);
        db g2 = guess2(no, L[i], R[i]);
        if (cmp2(g2,r2) == -1 || cmp2(r2,g1) == -1) return;
        if (has[i]) {
            if (cmp2(dist2(p[i], no), r2) == 0) {
                ans = id[i];
                return;
            }
        }
        if (ans) return;
        d = (d == K - 1) ? 0 : d + 1;
        _query(lc[i], d);
        _query(rc[i], d);
    }

    int insert(array<db,K> _no, int _id) {
        no = _no;
        int j = new_node(no, _id);
        _insert(root, 0, j);
        if (tp) {
            idx=0;
            collect(*tp);
            *tp = rebuidb(1,idx,tpd);
            tp = 0;
        }
        return j;
    }

    void erase(int j) {
        _erase(root, 0, j);
        if (tp) {
            idx=0;
            collect(*tp);
            *tp = rebuidb(1,idx,tpd);
            tp = 0;
        }
    }

    int query(array<db,K> _no, db r) {
        no = _no;
        ans = 0;
        r2 = r * r;
        EPS = max(eps, 2 * r * eps);
        _query(root, 0);
        return ans;
    }
}

int cur[N];

struct LG_P11716 {
    db a, b, lst;
    db f(db x) {
        return a * x - b * sin(x);
    }
    db decode(db x, db l, db r) {
        l = l * lst + 1, r = r * lst + 1;
        int t = 40;
        while(t-- && r - l > 1e-9) {
            db m = (l + r) / 2;
            if (f(m) < x) {
                l = m;
            } else {
                r = m;
            }
        } 
        return (l - 1) / lst;
    }
    int n, m;
    db x, y, z, r, fi;
    LG_P11716() {
        lst = 0.1;
        KDT::init();
        cin >> n >> m;
        cin >> a >> b;
        for (int i = 1; i <= n; i++) {
            cin >> x >> y >> z;
            cur[i] = KDT::buf[i] = KDT::new_node({x,y,z}, i);
        }
        KDT::root = KDT::rebuidb(1, n, 0);
        while(m--){
            int op, i;
            cin >> op;
            if (op == 0) {
                cin >> fi >> x >> y >> z;
                i = decode(fi, 1, n) + 0.5;
                x = decode(x, -100, 100);
                y = decode(y, -100, 100);
                z = decode(z, -100, 100);
                KDT::erase(cur[i]);
                cur[i] = KDT::insert({x,y,z}, i);
            } else {
                cin >> x >> y >> z >> r;
                x = decode(x, -100, 100);
                y = decode(y, -100, 100);
                z = decode(z, -100, 100);
                r = decode(r, 0, 400);
                int tmp = KDT::query({x,y,z}, r);
                lst = tmp;
                cout << tmp << "\n";
            }
        }
    }
};

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    new LG_P11716(); 
}
```

===== P10 动态 - L - R - sz - mx - val

```cpp
#include<bits/stdc++.h>
using namespace std;

const int N = 5e4 + 5;
const int K = 2;
const int inf = 1e9 + 1;
const double alpha = 0.7;

array<int,2> B[N];
int cntB;
int getB(array<int,2> x) {return lower_bound(B+1,B+1+cntB,x) - B;}

int n;
array<int,4> abcd[N];

// 这一次 不需要删除吧 
namespace KDT {
    // 【特别注意】 不要忘了乘以 log n 
    const int N = (5e4+5) * 20;
    int ans;

    array<int,K> p[N], L[N], R[N];

    int tot;
    int lc[N], rc[N];

    int *tp, tpd;
    int buf[N], idx;

    int sz[N];
    int mx[N], val[N];

    void init() {
        L[0] = {inf, inf};
        R[0] = {-inf, -inf};
        mx[0] = -inf;
    }

    int new_node(array<int,K> no, int v) {
        int i = ++tot;
        L[i] = R[i] = p[i] = no;
        mx[i] = val[i] = v;
        lc[i] = rc[i] = 0;
        sz[i] = 1;
        return i;
    }

    void up(int i) {
        L[i] = R[i] = p[i];
        for (int d = 0; d < K; d++) {
            L[i][d] = min(L[i][d], L[lc[i]][d]);
            R[i][d] = max(R[i][d], R[lc[i]][d]);
            L[i][d] = min(L[i][d], L[rc[i]][d]);
            R[i][d] = max(R[i][d], R[rc[i]][d]);
        }
        mx[i] = max(val[i], max(mx[lc[i]], mx[rc[i]]));
        sz[i] = sz[lc[i]] + sz[rc[i]] + 1;
    }

    bool balance(int i) {
        return max(sz[lc[i]], sz[rc[i]]) < sz[i] * alpha;
    }

    void collect(int i) {
        if (i) {
            buf[++idx] = i;
            collect(lc[i]);
            collect(rc[i]);
        }
    }

    int rebuild(int l,int r,int d) {
        if (l > r) return 0;
        int mid = (l + r) / 2;
        nth_element(buf+l,buf+mid,buf+r+1,[&](int a,int b) {
            return p[a][d] < p[b][d];
        });
        int i = buf[mid];
        d = (d == K - 1) ? 0 : d + 1;
        lc[i] = rebuild(l,mid-1,d);
        rc[i] = rebuild(mid+1,r,d);
        up(i);
        return i;
    }

    void _insert(int& i, int d,array<int,K> no,int v) {
        if (!i) {
            i = new_node(no, v);
        } else {
            if (no[d] < p[i][d]) {
                _insert(lc[i],(d+1)%K,no,v);
            } else {
                _insert(rc[i],(d+1)%K,no,v);
            }
            up(i);
            if (!balance(i)) {
                tp = &i;
                tpd = d;
            }
        }
    }

    // 依旧师承剪枝 在保证 \sqrt{n} 复杂度情况下剪枝
    void _query(int i,array<int,K> jL, array<int,K> jR) {
        if (!i || mx[i] <= ans) return;
        bool contain = true;
        for (int d = 0; d < K; d++) {
            contain &= jL[d] <= L[i][d] && R[i][d] <= jR[d];
            if (jL[d] > R[i][d] || L[i][d] > jR[d]) return;
        }
        if (contain) {
            ans = max(ans, mx[i]);
        } else {
            bool contain = true;
            for (int d = 0; d < K; d++) {
                contain &= jL[d] <= p[i][d] && p[i][d] <= jR[d];
            }
            if (contain) ans = max(ans, val[i]);
            if (mx[lc[i]] > mx[rc[i]]) {
                _query(lc[i],jL,jR);
                _query(rc[i],jL,jR);
            } else {
                _query(rc[i],jL,jR);
                _query(lc[i],jL,jR);
            }
        }
    }

    // 【注意 &i】
    void insert(int& i, array<int,K> no, int v) {
        _insert(i,0,no,v);
        if (tp) {
            idx = 0;
            collect(*tp);
            *tp = rebuild(1,idx,tpd);
            tp = 0;
        }
    }
    
    int query(int i, array<int,K> jL, array<int,K> jR) {
        ans = -inf;
        _query(i,jL, jR);
        return ans;
    }
}

namespace BIT {
    int n;
    int root[N];
    void init(int nn) {
        n = nn + 1;
    }
    void add(int i,array<int,K> cd,int v) {
        for(i++;i<=n;i+=i&-i) {
            KDT::insert(root[i], cd, v);
        }
    }
    int query(int i,array<int,K> cd) {
        int res = 0;
        for (i++;i;i-=i&-i) {
            res = max(res, KDT::query(root[i],{-inf,-inf}, cd));
        }
        return res;
    }
}

struct LG_P3769 {
    LG_P3769() {
        cin >> n;
        for (int i = 1; i <= n; i++) {
            auto&[a, b, c, d] = abcd[i];
            cin >> a >> b >> c >> d;    
        }

        sort(abcd+1,abcd+1+n);
        
        // 【我去这么神秘啊？？？】 
        // 这个偏序，哦，确实有点道理
        // 必须先按照 a 排完序再搞
        // 然后 b 自然就是按照 b 属性 外加 i 位置避免重复
        // 注意，是排序之后 按照 a 排序之后的 b 啊
        for (int i = 1; i <= n; i++) {
            B[++cntB] = {abcd[i][1], i};
        }
        sort(B+1,B+1+cntB);
        int ans = 0;
        
        KDT::init();
        BIT::init(n);
        for (int i = 1; i <= n; i++) {
            auto [a, b, c, d] = abcd[i];
            int _B = getB({b, i});
            int dpv = BIT::query(_B, {c, d});
            BIT::add(_B, {c, d}, dpv + 1);
            ans = max(ans, dpv + 1);
        }
        cout << ans << "\n";
    }
};

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    new LG_P3769();
}
```

===== P11 动态 - L - R - sz

```cpp
#include<bits/stdc++.h>
using namespace std;

const int N = 5e5 + 5;
const int K = 2;
const int inf = 1e9 + 1;
const double alpha = 0.7;

namespace KDT {
    const int N = (5e5+5) * 30 * 3;
    array<int,K> p[N], L[N], R[N];
    
    int tot;
    int lc[N], rc[N];
    
    int *tp, tpd;
    int buf[N], idx;

    int sz[N];

    void init() {
        for (int d = 0; d < K; d++) {
            L[0][d] = inf;
            R[0][d] = -inf;
        }
    }

    int new_node(array<int,K> no) {
        int i = ++tot;
        sz[i] = 1;
        L[i] = R[i] = p[i] = no;
        lc[i] = rc[i] = 0;
        return i;
    }

    void up(int i) {
        L[i] = R[i] = p[i];
        for (int d = 0; d < K; d++) {
            L[i][d] = min(L[i][d], L[lc[i]][d]);
            R[i][d] = max(R[i][d], R[lc[i]][d]);
            L[i][d] = min(L[i][d], L[rc[i]][d]);
            R[i][d] = max(R[i][d], R[rc[i]][d]);
        }
        sz[i] = sz[lc[i]] + sz[rc[i]] + 1;
    }

    void collect(int i) {
        if (i) {
            buf[++idx] = i;
            collect(lc[i]);
            collect(rc[i]);
        }
    }

    int rebuild(int l,int r,int d) {
        if (l > r) return 0;
        int mid = (l + r) / 2;
        nth_element(buf+l,buf+mid,buf+r+1,[&](int a,int b) {
            return p[a][d] < p[b][d];
        });
        int i = buf[mid];
        d = (d == K - 1 ? 0 : d + 1);
        lc[i] = rebuild(l,mid-1,d);
        rc[i] = rebuild(mid+1,r,d);
        up(i);
        return i;
    }

    bool balance(int i) {
        return max(sz[lc[i]], sz[rc[i]]) < sz[i] * alpha;
    }

    void _insert(int& i,int d, array<int,K> no) {
        if (!i) i = new_node(no);
        else {
            if (no[d] < p[i][d]) {
                _insert(lc[i],(d+1)%K,no);
            } else {
                _insert(rc[i],(d+1)%K,no);
            }
            up(i);
            if (!balance(i)) {
                tp = &i;
                tpd = d;
            }
        }
    }

    int _query(int i,int d, array<int,K> jL, array<int,K> jR) {
        if (!i) return 0;
        bool contain = true;
        for (int d = 0; d < K; d++) {
            contain &= jL[d] <= L[i][d] && R[i][d] <= jR[d];
            if (jL[d] > R[i][d] || L[i][d] > jR[d]) return 0;
        }
        if (contain) return sz[i];
        else {
            bool contain = true;
            for (int d = 0; d < K; d++) {
                contain &= jL[d] <= p[i][d] && p[i][d] <= jR[d];
            }
            int res = 0;
            if (contain) res = 1;
            d = (d == K - 1 ? 0 : d + 1);
            res += _query(lc[i],d,jL,jR);
            res += _query(rc[i],d,jL,jR);
            return res;
        }
    }

    void insert(int& i,array<int,K> no) {
        _insert(i,0,no);
        if (tp) {
            idx = 0;
            collect(*tp);
            *tp = rebuild(1,idx,tpd);
            tp = 0;
        }
    }

    int query(int i, array<int,K> jL,array<int,K> jR) {
        return _query(i,0,jL,jR);
    }
}

namespace SegT {
    const int N = (5e5+5) * 30;
    int tot;
    int rt;
    int lc[N], rc[N];
    int root[N];

    int new_node() {
        int i = ++tot;
        lc[i] = rc[i] = 0;
        root[i] = 0;
        return i;
    }

    // 强制在线的 所以 需要在 p 权值位置 添加一个点 no
    int add(int i,int l,int r,int p,array<int,K> no) {
        if (!i) i = new_node();
        KDT::insert(root[i], no);
        if (l == r) {
            return i;
        } else {
            int mid = (l + r) / 2;
            if (p <= mid) lc[i] = add(lc[i], l,mid,p,no);
            else rc[i] = add(rc[i], mid+1,r,p,no);
        }
        return i;
    }

    // 保证调用的时候 k >= 1 即必须要有答案
    int query_suf_k(int i,int l,int r,int k,array<int,K> jL, array<int,K> jR) {
        if (!i) return -1;
        if (l == r) {
            int tmp = KDT::query(root[i], jL, jR);
            return k <= tmp ? l : -1;
        } else {
            int mid = (l + r) / 2;
            int rsz = KDT::query(root[rc[i]], jL, jR);
            if (k <= rsz) {
                return query_suf_k(rc[i],mid+1,r,k,jL,jR);
            } else {
                return query_suf_k(lc[i],l,mid,k-rsz,jL,jR);
            }
        }
    }
}

struct LG_P4848 {
    int n, lst, q;
    LG_P4848() {
        KDT::init();
        lst = 0;
        cin >> n >> q;
        for (int i = 1; i <= q; i++) {
            int op;
            cin >> op;
            if (op == 1) {
                int a, b, v;
                cin >> a >> b >> v;
                a ^= lst; b ^= lst; v ^= lst;
                SegT::rt = SegT::add(SegT::rt,1,1e9,v,{a,b});
            } else {
                int a, b, c, d, k;
                cin >> a >> b >> c >> d >> k;
                a ^= lst; b ^= lst; c ^= lst; d ^= lst; k ^= lst;
                lst = SegT::query_suf_k(1,1,1e9,k,{a,b},{c,d});
                if (lst == -1) {
                    cout << "NAIVE!ORZzyz.\n";
                    lst = 0;
                } else {
                    cout << lst << "\n";
                }
            }
        }
    }
};

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    new LG_P4848();
}
```

===== P12 静态 - L - R

```cpp
#include<bits/stdc++.h>
using namespace std;
using ll = long long;

const int N = 7e4 + 5, M = 2e5 + 5;
const int K = 2;
const int inf = 1e9 + 1;
const ll INF = 2e18;

int W, H;
int n, m;

// 这个是图编号
int cntn;
// 每一个点都有一个虚点 所以开 2 倍
// e[i][j] = {l,r,d,u,w}
vector<array<int,5>> e[N];

priority_queue<pair<ll,int>> Q;
ll dist[N*2];
bool vis[N*2];

void update(int v, ll dis) {
    if (dist[v] > dis) {
        dist[v] = dis;
        Q.push({-dis, v});
    }
}

// 这样好哇！还能加一层门禁
// void add_edge(int u,int v, int w) {
//     if (u && v) {
//         // e[++cntE] = {v, hd[u], w};
//         // hd[u] = cntE;
//         e[u].push_back({v, w});
//     }
// }

// 终于用不上替罪羊了~~
namespace KDT {
    array<int,K> p[N], L[N], R[N];

    // 树根
    int root;
    int lc[N], rc[N];

    // 树节点 i 对应的图点
    int node[N];
    // 反过来！！！
    // 【啊啊啊啊啊】 开二倍啊啊
    int belong[N*2];
    
    int arr[N];

    void init() {
        L[0] = {inf, inf};
        R[0] = {-inf, -inf};
    }

    void up(int i) {
        L[i] = R[i] = p[i];
        for (int d = 0; d < K; d++) {
            L[i][d] = min(L[i][d], L[lc[i]][d]);
            R[i][d] = max(R[i][d], R[lc[i]][d]);
            L[i][d] = min(L[i][d], L[rc[i]][d]);
            R[i][d] = max(R[i][d], R[rc[i]][d]);
        }
    }

    int build(int l,int r,int d) {
        if (l > r) return 0;
        int mid = (l + r) / 2;
        nth_element(arr+l,arr+mid,arr+r+1,[&](int a,int b) {
            return p[a][d] < p[b][d];
        });
        int i = arr[mid];
        
        node[i] = ++cntn;
        belong[node[i]] = i; 
        // 连接自己
        // add_edge(node[i], i, 0);
        
        d = (d == K - 1 ? 0 : d + 1);
        lc[i] = build(l,mid-1,d);
        rc[i] = build(mid+1,r,d);
        
        // 连接孩子
        // add_edge(node[i], node[lc[i]], 0); 
        // add_edge(node[i], node[rc[i]], 0); 
        
        up(i);
        return i;
    }

    void x_to_range(int i,int d,array<int,K> jL, array<int,K> jR,ll dis) {
        // 【神之剪枝！！！】 到全集的距离足够小，就不需要继续了
        if (!i || dist[node[i]] <= dis) return;
        bool contain = true;
        for (int d = 0; d < K; d++) {
            contain &= jL[d] <= L[i][d] && R[i][d] <= jR[d];
            if (jL[d] > R[i][d] || L[i][d] > jR[d]) return;
        }
        if (contain) {
            // add_edge(x, node[i], w);
            update(node[i], dis);
        } else {
            bool contain = true;
            for (int d = 0; d < K; d++) {
                contain &= jL[d] <= p[i][d] && p[i][d] <= jR[d];
            }
            if (contain) {
                // add_edge(x, i, w);
                update(i,dis);
            }
            d = (d == K - 1 ? 0 : d + 1);
            x_to_range(lc[i],d,jL,jR,dis);
            x_to_range(rc[i],d,jL,jR,dis);
        }
    }
}

struct LG_P5471 {
    LG_P5471() {
        cin >> n >> m >> W >> H;
        cntn = n;
        KDT::init();
        for (int i = 1; i <= n; i++) {
            auto&[x,y] = KDT::p[i];
            cin >> x >> y;
            KDT::arr[i] = i;
        }
        KDT::root = KDT::build(1,n,0);
        for (int i = 1; i <= m; i++) {
            int p, t, L, R, D, U;
            cin >> p >> t >> L >> R >> D >> U;
            e[p].push_back({L,R,D,U,t});
            // KDT::x_to_range(KDT::root, 0, {L,D}, {R,U}, p, t);
        }
        fill(dist,dist+1+cntn,INF);
        fill(vis,vis+1+cntn,false);
        dist[1] = 0;
        Q.push({-0, 1});
        while (Q.size()) {
            auto [d, u] = Q.top(); Q.pop();
            if (vis[u]) continue;
            vis[u] = true;            
            d = -d;
            // 居然是现加，完全无边
            if (u <= n) {
                // 原生节点
                for (auto [L, R, D, U, w]: e[u]) {
                    KDT::x_to_range(KDT::root,0,{L,D},{R,U},d+w);
                }
                e[u].clear();
            } else {
                // node 节点 只干 3 件事
                int i = KDT::belong[u];
                update(i, d); // 自己的
                // 【存在】
                if (KDT::lc[i]) update(KDT::node[KDT::lc[i]], d); // 左 node
                if (KDT::rc[i]) update(KDT::node[KDT::rc[i]], d); // 右 node
            }
        }
        for (int i = 2; i <= n; i++) cout << dist[i] << "\n";
    }
};

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    new LG_P5471();
}
```

