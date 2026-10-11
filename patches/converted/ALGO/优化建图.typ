=== #text("优化建图")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/ALGO/优化建图.md`]

==== P1 模板1（线段树优化）

- `CF786B`
  - n 个点 q 次加边后 求 s 单源最短路

==== P2 模板2（线段树优化）

- `LG_P6348`
  - n 个点 m 次 r2r 加边后 求 p 单元最短路(边权1)

==== P3 沙漠 （线段树优化 + 拓扑序 DP）

- `LG_P3588`
  - 给定一个长度为 $n$ 的正整数序列 $a$，每个数都在 $1$ 到 $10^9$ 范围内，告诉你其中 $s$ 个数，并给出 $m$ 条信息，每条信息包含三个数 $l \, r \, k$ 以及接下来 $k$ 个正整数，表示 $a_l \, a_(l + 1) \, dots.h \, a_(r - 1) \, a_r$ 里这 $k$ 个数中的任意一个都比任意一个剩下的 $r - l + 1 - k$ 个数大（严格大于，即没有等号）。
  - 若无解，则输出 `NIE`。否则第一行输出 `TAK`，第二行输出 $n$ 个正整数，依次输出序列 $a$ 中每个数。

==== P4 Beautiful Tree （树剖优化 - 本质线段树优化）

- `CF_1904F`
  - 给定一棵树
  - 有若干限制 t a b c 表示 a b 路径上的 c 是最大/最小值
  - 求可行解
  - $O \( log^2 n \)$

==== P5 Beautiful Tree （倍增优化）

- 同上
  - $O \( log n \)$
  - 但是空间 $O \( n log n \)$

==== P6 划分可重集 （树状数组优化）

- `LG_P7477`
  - 其实掺杂了 2-SAT
  - PS: 这一题的实现，结合了 SAT 和 BitG
  - 如何设计 init / clear / reset 简直了！

==== P7 划分可重集 （主席树优化）

- 同上
  - 练习主席树
  - 基于 BitG 魔改得到 PSegG

==== P8 划分可重集 （CDQ优化 含前缀优化）

- 同上
  - 练习CDQ分治
  - 一次过
  - 离线就是好！

==== Codes

===== P1 - P4（线段树优化）

```cpp
#include<bits/stdc++.h>
using namespace std;
using ll = long long;
const ll INF = 2e18;

namespace SegG {
    const int N = 4e5 + 5;
    const int NN = N * (__lg(N)+2) + 100;
    
    int n, tot;
    
    int lc[NN], rc[NN];
    int In, Out;

    vector<pair<int,int>> e[NN];

    void add_edge(int u,int v,int w) {
        e[u].push_back({v, w});
    }

    int build_in(int l,int r);
    int build_out(int l,int r);

    // 为了方便 把 init 放在最后吧？
    // 不行， 还是手动吧
    // 不行 还是放前面吧
    void init(int nn) {
        fill(lc,lc+nn,0);
        fill(rc,rc+nn,0);
        for (int i = 1; i <= nn; i++) e[i].clear();

        n = tot = nn;

        In = build_in(1, n);
        Out = build_out(1, n);
    }

    int build_in(int l,int r) {
        int rt;
        if (l == r) {
            rt = l;
        } else {
            rt = ++tot;
            // cout << "in" << tot << ":" << l << " " << r << "\n";
            int mid = (l + r) / 2;
            lc[rt] = build_in(l, mid);
            rc[rt] = build_in(mid+1, r);
            add_edge(rt, lc[rt], 0);
            add_edge(rt, rc[rt], 0);
        }
        return rt;
    }
    
    int build_out(int l,int r) {
        int rt;
        if (l == r) {
            rt = l;
        } else {
            rt = ++tot;
            // cout << "out" << tot << ":" << l << " " << r << "\n";
            int mid = (l + r) / 2;
            lc[rt] = build_out(l, mid);
            rc[rt] = build_out(mid+1, r);
            add_edge(lc[rt], rt, 0);
            add_edge(rc[rt], rt, 0);
        }
        return rt;
    }

    void x_to_range(int i,int l,int r,int jl,int jr,int x,int w) {
        if(jl<=l&&r<=jr) {
            add_edge(x, i, w);
        } else {
            int mid = (l + r) / 2;
            if (jl <= mid) x_to_range(lc[i], l, mid, jl,jr,x,w);
            if (jr > mid) x_to_range(rc[i],mid+1,r,jl,jr,x,w);
        }
    }
    void range_to_x(int i,int l,int r,int jl,int jr,int x,int w) {
        if(jl<=l&&r<=jr) {
            add_edge(i, x, w);
        } else {
            int mid = (l + r) / 2;
            if (jl <= mid) range_to_x(lc[i], l, mid, jl,jr,x,w);
            if (jr > mid) range_to_x(rc[i],mid+1,r,jl,jr,x,w);
        }
    }
    void x_to_r(int x,int l,int r,int w) {
        if (l > r) return;
        x_to_range(In,1,n,l,r,x,w);
    }
    // 更直观！
    void r_to_x(int l,int r,int x,int w) {
        if (l > r) return;
        range_to_x(Out,1,n,l,r,x,w);
    }
    void r_to_r(int l1,int r1,int l2,int r2,int w) {
        int x = ++tot, y = ++tot;
        r_to_x(l1,r1,x,0);
        add_edge(x, y, w);
        x_to_r(y,l2,r2,0);
    }
}

struct CF_786B {
    // 模板题
    // n 个点 q 次加边后 求 s 单源最短路
    // N 1e5 Q 1e5 
    int n, q, s;
    CF_786B() {
        cin >> n >> q >> s;
        SegG::init(n);
        while (q--) {
            int op, u, v, w, l , r;
            cin >> op;
            if (op == 1) {
                cin >> u >> v >> w;
                SegG::add_edge(u, v, w);
            } else if (op == 2) {
                cin >> u >> l >> r >> w;
                SegG::x_to_r(u, l, r, w);
            } else {
                cin >> u >> l >> r >> w;
                SegG::r_to_x(l, r, u, w);
            }
        }
        vector<ll> dist(SegG::tot+1, INF);
        vector<bool> vis(SegG::tot+1);
        priority_queue<pair<ll,int>> Q;
        Q.push({-0, s});
        dist[s] = 0;
        while (Q.size()) {
            int u = Q.top().second; Q.pop();
            if (vis[u]) continue;
            vis[u] = true;
            for (auto [v, w]: SegG::e[u]) {
                if (dist[v] > dist[u] + w) {
                    dist[v] = dist[u] + w;
                    Q.push({-dist[v], v});
                }
            }
        }
        for(int i = 1; i <= n; i++) {
            if (dist[i] == INF) dist[i] = -1;
            cout << dist[i] << " ";
        }cout << "\n";
    }
};

struct LG_P6348 {
    // 模板题 
    // n 个点 m 次 r2r 加边后 求 p 单元最短路(边权1)
    // N 5e5 M 1e5
    int n, m, p;
    LG_P6348() {
        cin >> n >> m >> p;
        SegG::init(n);
        while(m--) {
            int l1, r1, l2, r2;
            cin >> l1 >> r1 >> l2 >> r2;
            SegG::r_to_r(l1, r1, l2, r2, 1);
            SegG::r_to_r(l2, r2, l1, r1, 1);
        }
        deque<int> Q;
        vector<int> dist(SegG::tot+1, 1e9);
        vector<bool> vis(SegG::tot+1);
        Q.push_back(p);
        dist[p] = 0;
        while (Q.size()) {
            int u = Q.front(); Q.pop_front();
            if (vis[u]) continue;
            vis[u] = true;
            for (auto [v, w]: SegG::e[u]) {
                if (dist[v] > dist[u] + w) {
                    dist[v] = dist[u] + w;
                    if (w) Q.push_back(v);
                    else Q.push_front(v);
                }
            }
        }
        for (int i = 1; i <= n; i++) cout << dist[i] << "\n";
    }
};

struct LG_P3588 {
    // 数字大小约束 构造
    // 注意 mle 有点极限
    inline static const int N = 1e5 + 5, M = 2e5 + 5, K = 3e5 + 5, V = 1e9;
    int n, s, m;
    int mn[N * 20], val[N * 20];
    LG_P3588() {
        bool ok = true;
        cin >> n >> s >> m;
        for (int i = 1; i <= s; i++) {
            int p, d;
            cin >> p >> d;
            val[p] = d;
        }
        SegG::init(n);
        for (int i = 1; i <= m; i++) {
            int l, r, k;
            cin >> l >> r >> k;
            vector<int> p(k+2);
            p[0] = l-1;
            for(int i = 1; i <= k;i++) {
                cin >> p[i];
            }
            p[k+1] = r+1;
            int maxv = ++SegG::tot;
            for (int i = 0; i<=k;i++) {
                int l = p[i]+1, r = p[i+1]-1;
                if (l <= r) {
                    SegG::r_to_x(l, r, maxv, 0);
                }
            }
            for(int i = 1; i <= k; i++) {
                SegG::add_edge(maxv, p[i], 1);
            }
        }
        int tot = SegG::tot;
        vector<int> deg(tot + 1);
        for (int u = 1; u <= tot; u++) {
            for (auto [v, w]: SegG::e[u]) {
                deg[v]++;
            }
        }
        int cnt = 0;
        queue<int> Q;
        for (int i = 1; i <= tot; i++) {
            if (!deg[i]) {
                mn[i] = 1;
                Q.push(i);
            }
        }
        while(Q.size()) {
            int u = Q.front(); Q.pop();
            cnt++;
            if (val[u]) {
                ok &= val[u] >= mn[u];
                mn[u] = val[u];
            } else {
                val[u] = mn[u];
            }
            ok &= val[u] <= V;
            for (auto [v, w]: SegG::e[u]) {
                mn[v] = max(mn[v], mn[u] + w);
                if (!--deg[v]) {
                    Q.push(v);
                }
            }
        }
        ok &= cnt == tot;
        if (!ok) {
            cout << "NIE\n";
        } else {
            cout << "TAK\n";
            for (int i = 1; i <= n; i++) {
                cout << val[i] << " ";
            }cout << "\n";
        }
        fill(val, val + 1 + tot, 0);
        fill(mn, mn + 1 + tot, 0);
    }
};

struct CF_1904F {
    inline static const int N = 2e5 + 5, M = 2e5 + 5;
    int n, m, u, v, t, a, b, c;
    int dfn[N], dfncnt, son[N], dep[N], top[N], fa[N], sz[N];
    int rnk[N];
    vector<int> e[N];
    void dfs(int u,int f) {
        sz[u] = 1;
        fa[u] = f;
        dep[u] = dep[f] + 1;
        son[u] = 0;
        for (auto v: e[u]) if(v!=f){
            dfs(v, u);
            sz[u] += sz[v];
            if (sz[v] > sz[son[u]]) son[u] = v;
        }
    }
    void dfs2(int u,int tp) {
        rnk[dfn[u] = ++dfncnt] = u;
        top[u] = tp;
        if (son[u]) dfs2(son[u], tp);
        for (auto v:e[u]) if (v!=fa[u] && v!=son[u]) dfs2(v, v);
    }
    // 【坑点 / 爽点】 
    // 没想到树剖 可以直接批量处理路径
    // 之前一直以为要先求得 lca 才可以
    // 直接就可以维护了， 爽！！！
    void operation(int op,int x,int y,int z) {
        while(top[x] != top[y]) {
            if (dep[top[x]] < dep[top[y]]) swap(x, y);
            if (dfn[z] < dfn[top[x]] || dfn[z] > dfn[x]) {
                if (op == 1) SegG::x_to_r(dfn[z], dfn[top[x]], dfn[x], 1);
                else SegG::r_to_x(dfn[top[x]], dfn[x], dfn[z], 1);
            } else {
                if (op == 1) {
                    SegG::x_to_r(dfn[z], dfn[top[x]], dfn[z]-1, 1);
                    SegG::x_to_r(dfn[z], dfn[z]+1, dfn[x], 1);
                } else {
                    SegG::r_to_x(dfn[top[x]], dfn[z]-1, dfn[z], 1);
                    SegG::r_to_x(dfn[z]+1, dfn[x], dfn[z], 1);
                }
            }
            x = fa[top[x]];
        }
        if (dep[x] < dep[y]) swap(x, y);
        if (dfn[z] < dfn[y] || dfn[z] > dfn[x]) {
            if (op == 1) SegG::x_to_r(dfn[z], dfn[y], dfn[x], 1);
            else SegG::r_to_x(dfn[y], dfn[x], dfn[z], 1);
        } else {
            if (op == 1) {
                SegG::x_to_r(dfn[z], dfn[y], dfn[z]-1, 1);
                SegG::x_to_r(dfn[z], dfn[z]+1, dfn[x], 1);
            } else {
                SegG::r_to_x(dfn[y], dfn[z]-1, dfn[z], 1);
                SegG::r_to_x(dfn[z]+1, dfn[x], dfn[z], 1);
            }
        }
    }
    CF_1904F() {
        dfncnt = 0;
        fill(dfn,dfn+1+n,0);
        for (int i = 1; i <= n; i++) e[i].clear();
        cin >> n >> m;
        SegG::init(n);
        for (int i = 1; i < n; i++) {
            cin >> u >> v;
            e[u].push_back(v);
            e[v].push_back(u);
        }
        dfs(1, 0);
        dfs2(1, 1);
        for (int i = 1; i <= m; i++) {
            cin >> t >> a >> b >> c;
            operation(t, a, b, c);
        }
        int tot = SegG::tot;
        vector<int> deg(tot + 1), val(n + 1);
        for (int u = 1; u <= tot; u++) {
            for (auto [v, w]: SegG::e[u]) {
                deg[v]++;
            }
        }
        queue<int> Q;
        for (int i = 1; i <= tot; i++) {
            if (!deg[i]) Q.push(i); 
        }
        bool ok = true;
        int cnt = 0, num = 0;
        while (Q.size()) {
            int u = Q.front(); Q.pop();
            cnt++;
            if (u <= n) val[rnk[u]] = ++num;
            for (auto [v, w]: SegG::e[u]) {
                if (!--deg[v]) Q.push(v);
            }
        }
        ok &= cnt == tot;
        if (!ok) cout << -1 << "\n";
        else {
            for (int i = 1; i <= n; i++) cout << val[i] << " "; cout << "\n";
        }
    }
};

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    // new CF_786B();
    // new LG_P6348();
    // new LG_P3588();
    new CF_1904F();
}
```

===== P5（倍增优化）

- 倍增优化

```cpp
#include<bits/stdc++.h>
#define endl '\n'
using namespace std;
using ll = long long;
const ll INF = 2e18;

namespace StG {
    const int N = 2e5 + 5;
    const int NN = N * 18 + 5;

    struct Edge {
        int to, nxt;
    }edge[NN*2 + NN*2 + NN]; // 两个树结构 + 2logN * N 个新的边
    // 【chovy】神秘加 2N 大小就过了
    int hd[N + NN*2], cntE;
    
    int n, tot, P;
    vector<int> e[N];
    // vector<int> E[NN*2];
    int fa[N][__lg(N)+1], stin[N][__lg(N)+1], stout[N][__lg(N)+1];
    int dep[N];

    void init(int nn) {
        for (int i = 1; i <= n; i++) e[i].clear();
        
        fill(hd, hd + 1 + tot, 0);
        // for (int i = 1; i <= tot; i++) E[i].clear();
        
        tot = n = nn;
        P = __lg(n);

        cntE = 1;
    }

    void connect(int u,int v) {
        e[u].push_back(v);
        e[v].push_back(u);
    }

    void add_edge(int u,int v) {
        // E[u].push_back(v);
        edge[++cntE] = {v, hd[u]};
        hd[u] = cntE;
    }

    void dfs(int u,int f) {
        dep[u] = dep[f] + 1; 
        fa[u][0] = f;
        stin[u][0] = stout[u][0] = u;
        for (int p = 1; p <= P; p++) {
            int ed = fa[u][p-1];
            // 【坑点】 忘了这个填写倍增了
            fa[u][p] = fa[ed][p-1];
            stin[u][p] = ++tot;
            add_edge(tot, stin[u][p-1]);
            add_edge(tot, stin[ed][p-1]);
            stout[u][p] = ++tot;
            add_edge(stout[u][p-1], tot);
            add_edge(stout[ed][p-1], tot);
        }
        for (auto v: e[u]) if (v!=f) {
            dfs(v, u);
        }
    }

    void build() {
        dfs(1, 1);
    }

    int jump(int x,int d) {
        for(int p = 0;d;d>>=1,p++) if(d&1) x = fa[x][p];
        return x;
    }

    int lca(int x,int y) {
        if (dep[x] < dep[y]) swap(x, y);
        x = jump(x, dep[x]-dep[y]);
        if (x == y) {
            return x;
        }
        for(int p = P;p>=0;p--) if (fa[x][p]!=fa[y][p]) x=fa[x][p],y=fa[y][p];
        return fa[x][0];
    }


    // 已知 x y 不同 求 x y 路径上距离 y 最近的 
    int nearst(int x,int y) {
        int z = lca(x, y);
        // 要么 y 是顶部
        if (z == y) return jump(x, dep[x] - dep[y] - 1);
        // 要么 y 不是顶部 
        return fa[y][0];
    }
    void xud_in(int x,int u,int d,int w) {
        if(d<=0) return;
        for(int p=0;d;d>>=1,p++) if(d&1) {
            add_edge(x, stin[u][p]);
            u = fa[u][p];
        }
    }
    void xud_out(int x,int u,int d,int w) {
        if(d<=0) return;
        for(int p=0;d;d>>=1,p++) if(d&1) {
            add_edge(stout[u][p], x);
            u = fa[u][p];
        }
    }
    void path_in(int v, int x,int y,int w) {
        int z = lca(x, y);
        xud_in(v, x, dep[x]-dep[z]+1, w);
        // 【坑点】 你复制给我复制好的啊 y 改一下
        xud_in(v, y, dep[y]-dep[z], w);
    }
    void path_out(int v,int x,int y,int w) {
        int z = lca(x, y);
        xud_out(v, x, dep[x]-dep[z]+1, w);
        // 【坑点】 你复制给我复制好的啊 y 改一下
        xud_out(v, y, dep[y]-dep[z], w);
    }
}

struct CF_1904F_2 {
    inline static const int N = 2e5 + 5, M = 2e5 + 5;
    int n, m, u, v, t, a, b, c;
    CF_1904F_2() {
        cin >> n >> m;
        StG::init(n);
        for (int i = 1; i < n; i++) {
            cin >> u >> v;
            StG::connect(u, v);
        }
        // 建立 st 表
        StG::build();
        for (int i = 1; i <= m; i++) {
            cin >> t >> a >> b >> c;
            if (t == 1) {
                if (a != c) {
                    StG::path_in(c, a, StG::nearst(a, c), 1);
                } 
                if (b != c) {
                    StG::path_in(c, b, StG::nearst(b, c), 1);
                }
            } else {
                if (a != c) {
                    StG::path_out(c, a, StG::nearst(a, c), 1);
                } 
                if (b != c) {
                    StG::path_out(c, b, StG::nearst(b, c), 1);
                }
            }
        }
        int tot = StG::tot;
        vector<int> deg(tot + 1), val(n + 1);
        for (int u = 1; u <= tot; u++) {
            for (int i = StG::hd[u];i;i=StG::edge[i].nxt) deg[StG::edge[i].to]++;
        }
        int cnt = 0, num = 0;
        queue<int> Q;
        for (int i = 1; i <= tot; i++) if (!deg[i]) {
            Q.push(i);
        }
        while (Q.size()) {
            int u = Q.front(); Q.pop();
            cnt++;
            if (u <= n) val[u] = ++num;
            for (int i = StG::hd[u]; i; i = StG::edge[i].nxt) {
                if (!--deg[StG::edge[i].to]) Q.push(StG::edge[i].to);
            }
        }
        if (cnt != tot) cout << -1 << endl;
        else {
            for (int i = 1; i <= n; i++) cout << val[i] << " "; cout << endl;
        }
    }
};

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    new CF_1904F_2();
}
```

===== P6（树状数组优化）

```cpp
#include<bits/stdc++.h>
using namespace std;

namespace SAT {
    const int N = 5e6 + 5, M = 5e6 + 5;

    int n;
    
    struct Edge {
        int to, nxt;
    }e[M];
    int hd[M], cntE;
    
    // tarjan
    int dfn[M], low[M], stk[M], tp, dfncnt, scc[M], sc;
    
    void clear() {
        fill(hd,hd+1+n,0);
        fill(dfn,dfn+1+n,0);
        fill(scc,scc+1+n,0);

        n = 0;
        tp = dfncnt = sc = 0;
        cntE = 1;
    }

    void add_edge(int u,int v) {
        e[++cntE] = {v, hd[u]};
        hd[u] = cntE;
    }

    void tarjan(int u) {
        low[u] = dfn[u] = ++dfncnt; stk[++tp] = u;
        for (int i = hd[u]; i; i = e[i].nxt) {
            int v = e[i].to;
            if (!dfn[v]) {
                tarjan(v);
                low[u] = min(low[u], low[v]);
            } else if (!scc[v]) {
                low[u] = min(low[u], dfn[v]);
            }
        }
        if (low[u] == dfn[u]) {
            sc++;
            int pop;
            do pop=stk[tp--],scc[pop]=sc; while(pop != u);
        }
    }
    
    void build(int nn) {
        n = nn;
        for(int i = 1; i <= n; i++) if (!dfn[i]) tarjan(i);
    }
}

namespace BitG {
    const int N = 2e4 + 5, M = 5e6 + 5;
    // 一次操作空间复杂度是 logN 
    int n, tot;
    int tr_in[N], tr_out[N];
    // 注意，初始的时候，认为 占用的点权等于预留的节点编号量
    // 即：点权认为就是编号
    // 还要注意，认为 0 权值无用，所以不要特殊处理了

    void reset(int tt) {
        // 【不兑】 n 和 tot 不能相提并论
        // 我说 这个 tt 其实是已经被占用的编号，不要再占用了
        tot = tt;
    }

    void init(int nn) {
        fill(tr_in,tr_in+1+n,0);
        fill(tr_out,tr_out+1+n,0);
        n = nn;
    }

    // 【巨大坑点1】 这里 in out 的方向是怎么搞的？
    // 想了半天 终于明白了 
    // 之前是入点 那么必然新的入点要接上原来的入点区 + 现在的新的入点
    void add_in(int i,int x) {
        for(;i<=n;i+=i&-i) {
            ++tot;
            if (tr_in[i]) {
                // 有老版本 那么老版本向新版本连边 吗？
                // 是后来者可以享受历史版本！
                SAT::add_edge(tot, tr_in[i]);
            }
            // 变为最新版本
            tr_in[i] = tot;
            // 向最新版本倚靠
            SAT::add_edge(tot, x);
        }
    }
    // 【巨大坑点1】 这里 in out 的方向是怎么搞的？
    // 想了半天 终于明白了 
    // 之前是出点 那么必然新的出点要从 原来的出点来 + 现在的新的出点来
    void add_out(int i,int x) {
        for(;i<=n;i+=i&-i) {
            ++tot;
            if(tr_out[i]) {
                // 这里是 老版本指向新版本
                // 表示 底座永远是老的 永远享受新版本
                SAT::add_edge(tr_out[i], tot);
            }
            tr_out[i] = tot;
            SAT::add_edge(x, tot);
        }
    }
    // 【巨大坑点2】 这里 x2r r2x 竟然不需要 ++tot
    // 我想了想，确实，因为接入点完全没有变化，除非 add_in / add_out 
    // 从 x 向 [1, i] 权值的所有点连边
    void x_to_range(int i,int x) {
        for(;i;i-=i&-i) {
            if (!tr_in[i]) continue; // 没有目标 不搞
            SAT::add_edge(x, tr_in[i]);
        }
    }
    // 【巨大坑点2】 这里 x2r r2x 竟然不需要 ++tot
    // 我想了想，确实，因为接入点完全没有变化，除非 add_in / add_out 
    // [1, i] 向 x 连边
    void range_to_x(int i,int x) {
        for(;i;i-=i&-i) {
            if (!tr_out[i]) continue;
            SAT::add_edge(tr_out[i], x);
        }
    }
}

struct LG_P7477 {
    inline static const int N = 2e4 + 5, V = 1e9;
    int n, m, val[N];
    array<int,2> par[N], uv[N];
    bool check(int k) {
        SAT::clear();
        for (int i = 1; i <= m; i++) {
            auto [u, v] = uv[i];
            SAT::add_edge(u, v + n);
            SAT::add_edge(v, u + n);
            SAT::add_edge(u + n, v);
            SAT::add_edge(v + n, u);
        }
        BitG::reset(n * 2);
        // 设 1 为 选 a 0 为选 b
        // 那么 先看如果 p1 选了 1
        // 那么 p2 满足 v[p2] <= v[p1] - k 的所有 j <= i-1 的点都必然走向反面即 0
        // 所以要 
        // 1. 单 p1 1 -> 多 p2 0
        // 2. 多 p2 1 -> 单 p1 0
        // 所以需要维护
        // 1. 入树: 把反面节点 放到节点对应的位置
        // 2. 出树: 把正面节点 放到节点对应的位置
        // 先清空
        int p1 = 1, p2 = 1;
        BitG::init(n);
        while(p1 <= n) {
            // 先跑出来所有的候选
            while(p2 <= n && par[p2][0] <= par[p1][0] - k) {
                BitG::add_in(par[p2][1], par[p2][1] + n); // 反面节点
                BitG::add_out(par[p2][1], par[p2][1]); // 正面节点
                p2++;
            }
            // 然后专门找 j <= i - 1 的来搞
            BitG::x_to_range(par[p1][1]-1, par[p1][1]);
            BitG::range_to_x(par[p1][1]-1, par[p1][1] + n);
            p1++;
        } 
        // 梅开二度
        // 看如果 p1 选了 0 那么
        // 必须所有 v[p2] >= v[p1] + k 并且 j <= i - 1 的都要选 1
        // 1. 单 p1 0 -> 多 p2 1
        // 2. 多 p2 0 -> 单 p1 1
        // 1. 入树: 把正面节点 放在对应位置
        // 2. 出树: 把反面节点 放在对应位置
        // 【注意】 反着来卡
        p1 = p2 = n;
        BitG::init(n);
        while(p1 >= 1) {
            // 先跑出来所有的候选
            while(p2 >= 1 && par[p2][0] >= par[p1][0] + k) {
                BitG::add_in(par[p2][1], par[p2][1]); // !反面节点
                BitG::add_out(par[p2][1], par[p2][1] + n); // !正面节点
                p2--;
            }
            // 然后专门找 j <= i - 1 的来搞
            BitG::x_to_range(par[p1][1]-1, par[p1][1] + n); // !
            BitG::range_to_x(par[p1][1]-1, par[p1][1]); // !
            p1--;
        } 
        SAT::build(BitG::tot);
        for (int i = 1; i <= n; i++) if (SAT::scc[i] == SAT::scc[i+n]) return false;
        return true;
    }
    LG_P7477() {
        cin >> n >> m;
        for (int i = 1; i <= n; i++) cin >> val[i], par[i] = {val[i], i};
        for (int i = 1; i <= m; i++) cin >> uv[i][0] >> uv[i][1];
        sort(par+1,par+1+n);
        int l = 0, r = V, ans = -1;
        while(l <= r) {
            int mid = (l + r) / 2;
            if (check(mid)) {
                ans = mid;
                r = mid - 1;
            } else {
                l = mid + 1;
            }
        }
        cout << ans << "\n";
    }
};

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    new LG_P7477();
}
```

===== P7 （主席树优化）

```cpp
#include<bits/stdc++.h>
using namespace std;

namespace SAT {
    const int N = 5e6 + 5, M = 5e6 + 5;

    int n;
    
    struct Edge {
        int to, nxt;
    }e[M];
    int hd[M], cntE;
    
    // tarjan
    int dfn[M], low[M], stk[M], tp, dfncnt, scc[M], sc;
    
    void clear() {
        fill(hd,hd+1+n,0);
        fill(dfn,dfn+1+n,0);
        fill(scc,scc+1+n,0);

        n = 0;
        tp = dfncnt = sc = 0;
        cntE = 1;
    }

    void add_edge(int u,int v) {
        e[++cntE] = {v, hd[u]};
        hd[u] = cntE;
    }

    void tarjan(int u) {
        low[u] = dfn[u] = ++dfncnt; stk[++tp] = u;
        for (int i = hd[u]; i; i = e[i].nxt) {
            int v = e[i].to;
            if (!dfn[v]) {
                tarjan(v);
                low[u] = min(low[u], low[v]);
            } else if (!scc[v]) {
                low[u] = min(low[u], dfn[v]);
            }
        }
        if (low[u] == dfn[u]) {
            sc++;
            int pop;
            do pop=stk[tp--],scc[pop]=sc; while(pop != u);
        }
    }
    
    void build(int nn) {
        n = nn;
        for(int i = 1; i <= n; i++) if (!dfn[i]) tarjan(i);
    }
}

namespace PSegG {
    const int N = 2e4 + 5, M = 5e6 + 5;
    // 一次操作空间复杂度是 logN 
    int n, tot;
    // 【坑点】 这玩意不是线性的 啊
    // 千万别写 N 啊
    int lc[M], rc[M];
    int In, Out;

    void reset(int tt) {
        tot = tt;
    }

    // 【感悟】 基本上就是在 
    // 遵循 原本 BitG 的 API 基础上
    // 修改了一些细节实现 
    int build_in(int l,int r) {
        int rt = ++tot;
        if (l < r) {
            int mid = (l + r) / 2;
            lc[rt] = build_in(l,mid);
            rc[rt] = build_in(mid+1,r);
            SAT::add_edge(rt, lc[rt]);
            SAT::add_edge(rt, rc[rt]);
        }
        return rt;
    }

    int build_out(int l,int r) {
        int rt = ++tot;
        if (l < r) {
            int mid = (l + r) / 2;
            lc[rt] = build_out(l,mid);
            rc[rt] = build_out(mid+1,r);
            SAT::add_edge(lc[rt], rt);
            SAT::add_edge(rc[rt], rt);
        }
        return rt;
    }

    void init(int nn) {
        fill(lc,lc+1+n,0);
        fill(rc,rc+1+n,0);
        n = nn;
        In = build_in(1, n);
        Out = build_out(1, n);
    }

    // 【感悟】原来一个是单点带修改 另一个是区间不修改
    // 有内味了
    int add_in(int i,int l,int r,int p,int x) {
        int rt = ++tot;
        lc[rt] = lc[i];
        rc[rt] = rc[i];
        // 新的入口点
        SAT::add_edge(rt, i);
        if (l == r) {
            SAT::add_edge(rt, x);
        } else {
            int mid = (l + r) / 2;
            if (p <= mid) {
                lc[rt] = add_in(lc[rt],l,mid,p,x);
                SAT::add_edge(rt, lc[rt]);
            } else {
                rc[rt] = add_in(rc[rt],mid+1,r,p,x);
                SAT::add_edge(rt, rc[rt]);
            }
        }
        return rt;
    }
    
    int add_out(int i,int l,int r,int p,int x) {
        int rt = ++tot;
        lc[rt]=lc[i];
        rc[rt]=rc[i];
        SAT::add_edge(i, rt);
        if (l == r) {
            SAT::add_edge(x, rt);
        } else {
            int mid = (l + r) / 2;
            if (p <= mid) {
                lc[rt] = add_out(lc[rt],l,mid,p,x);
                SAT::add_edge(lc[rt], rt);
            } else {
                rc[rt] = add_out(rc[rt],mid+1,r,p,x);
                SAT::add_edge(rc[rt], rt);
            } 
        }
        return rt;
    }

    // 【隐蔽的坑点】 jl > jr 直接退！！！
    void x_to_range(int i,int l,int r,int jl,int jr,int x) {
        if(jl>jr) return;
        if (jl <= l && r <= jr) {
            SAT::add_edge(x, i);
        } else {
            int mid = (l + r) / 2;
            if(jl<=mid) x_to_range(lc[i],l,mid,jl,jr,x);
            if(jr>mid) x_to_range(rc[i],mid+1,r,jl,jr,x);
        }
    }
    
    // 【隐蔽的坑点】 jl > jr 直接退！！！
    void range_to_x(int i,int l,int r,int jl,int jr,int x) {
        if(jl>jr) return;
        if(jl<=l&&r<=jr) {
            SAT::add_edge(i,x);
        } else {
            int mid = (l + r) / 2;
            if(jl<=mid) range_to_x(lc[i],l,mid,jl,jr,x);
            if(jr>mid) range_to_x(rc[i],mid+1,r,jl,jr,x);
        }
    }

    // 完好的 API
    void add_in(int i,int x) {
        In = add_in(In,1,n,i,x);
    }
    void add_out(int i,int x) {
        Out = add_out(Out,1,n,i,x);
    }
    void x_to_range(int i,int x) {
        x_to_range(In,1,n,1,i,x);
    }
    void range_to_x(int i,int x) {
        range_to_x(Out,1,n,1,i,x);
    }
}

struct LG_P7477 {
    inline static const int N = 2e4 + 5, V = 1e9;
    int n, m, val[N];
    array<int,2> par[N], uv[N];
    bool check(int k) {
        SAT::clear();
        for (int i = 1; i <= m; i++) {
            auto [u, v] = uv[i];
            SAT::add_edge(u, v + n);
            SAT::add_edge(v, u + n);
            SAT::add_edge(u + n, v);
            SAT::add_edge(v + n, u);
        }
        PSegG::reset(n * 2);
        // 设 1 为 选 a 0 为选 b
        // 那么 先看如果 p1 选了 1
        // 那么 p2 满足 v[p2] <= v[p1] - k 的所有 j <= i-1 的点都必然走向反面即 0
        // 所以要 
        // 1. 单 p1 1 -> 多 p2 0
        // 2. 多 p2 1 -> 单 p1 0
        // 所以需要维护
        // 1. 入树: 把反面节点 放到节点对应的位置
        // 2. 出树: 把正面节点 放到节点对应的位置
        // 先清空
        int p1 = 1, p2 = 1;
        PSegG::init(n);
        while(p1 <= n) {
            // 先跑出来所有的候选
            while(p2 <= n && par[p2][0] <= par[p1][0] - k) {
                PSegG::add_in(par[p2][1], par[p2][1] + n); // 反面节点
                PSegG::add_out(par[p2][1], par[p2][1]); // 正面节点
                p2++;
            }
            // 然后专门找 j <= i - 1 的来搞
            PSegG::x_to_range(par[p1][1]-1, par[p1][1]);
            PSegG::range_to_x(par[p1][1]-1, par[p1][1] + n);
            p1++;
        } 
        // 梅开二度
        // 看如果 p1 选了 0 那么
        // 必须所有 v[p2] >= v[p1] + k 并且 j <= i - 1 的都要选 1
        // 1. 单 p1 0 -> 多 p2 1
        // 2. 多 p2 0 -> 单 p1 1
        // 1. 入树: 把正面节点 放在对应位置
        // 2. 出树: 把反面节点 放在对应位置
        // 【注意】 反着来卡
        p1 = p2 = n;
        PSegG::init(n);
        while(p1 >= 1) {
            // 先跑出来所有的候选
            while(p2 >= 1 && par[p2][0] >= par[p1][0] + k) {
                PSegG::add_in(par[p2][1], par[p2][1]); // !反面节点
                PSegG::add_out(par[p2][1], par[p2][1] + n); // !正面节点
                p2--;
            }
            // 然后专门找 j <= i - 1 的来搞
            PSegG::x_to_range(par[p1][1]-1, par[p1][1] + n); // !
            PSegG::range_to_x(par[p1][1]-1, par[p1][1]); // !
            p1--;
        } 
        SAT::build(PSegG::tot);
        for (int i = 1; i <= n; i++) if (SAT::scc[i] == SAT::scc[i+n]) return false;
        return true;
    }
    LG_P7477() {
        cin >> n >> m;
        for (int i = 1; i <= n; i++) cin >> val[i], par[i] = {val[i], i};
        for (int i = 1; i <= m; i++) cin >> uv[i][0] >> uv[i][1];
        sort(par+1,par+1+n);
        int l = 0, r = V, ans = -1;
        while(l <= r) {
            int mid = (l + r) / 2;
            if (check(mid)) {
                ans = mid;
                r = mid - 1;
            } else {
                l = mid + 1;
            }
        }
        cout << ans << "\n";
    }
};

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    new LG_P7477();
}
```

===== P8 （CDQ优化 含前缀优化）

```cpp
#include<bits/stdc++.h>
using namespace std;

namespace SAT {
    const int N = 5e6 + 5, M = 5e6 + 5;

    int n;
    
    struct Edge {
        int to, nxt;
    }e[M];
    int hd[M], cntE;
    
    // tarjan
    int dfn[M], low[M], stk[M], tp, dfncnt, scc[M], sc;
    
    void clear() {
        fill(hd,hd+1+n,0);
        fill(dfn,dfn+1+n,0);
        fill(scc,scc+1+n,0);

        n = 0;
        tp = dfncnt = sc = 0;
        cntE = 1;
    }

    void add_edge(int u,int v) {
        e[++cntE] = {v, hd[u]};
        hd[u] = cntE;
    }

    void tarjan(int u) {
        low[u] = dfn[u] = ++dfncnt; stk[++tp] = u;
        for (int i = hd[u]; i; i = e[i].nxt) {
            int v = e[i].to;
            if (!dfn[v]) {
                tarjan(v);
                low[u] = min(low[u], low[v]);
            } else if (!scc[v]) {
                low[u] = min(low[u], dfn[v]);
            }
        }
        if (low[u] == dfn[u]) {
            sc++;
            int pop;
            do pop=stk[tp--],scc[pop]=sc; while(pop != u);
        }
    }
    
    void build(int nn) {
        n = nn;
        for(int i = 1; i <= n; i++) if (!dfn[i]) tarjan(i);
    }
}

struct LG_P7477 {
    inline static const int N = 2e4 + 5, V = 1e9;
    int K;
    int n, m, val[N];
    array<int,2> uv[N];

    // 建图
    int tot;

    void reset(int tt) {
        tot = tt;
    }
    
    // CDQ
    struct Node {
        int p, v;
    }no[N], tmp[N];

    void merge(int l,int mid,int r) {
        int L = l, R = mid+1;
        // 右边有 =v 1 那么左边就必须 <= v-k 0 
        // 左边有 <= v-k 1 那么右边必须 =v 0 
        // 维护左侧 pre_not_in pre_out
        int pre_not_in = 0, pre_out = 0;
        while(R <= r) {
            while(L <= mid && no[L].v <= no[R].v - K) {
                // pre_not_in
                ++tot;
                if (pre_not_in) SAT::add_edge(tot, pre_not_in);
                pre_not_in = tot;
                SAT::add_edge(tot, no[L].p + n);
                // pre_out
                ++tot;
                if (pre_out) SAT::add_edge(pre_out, tot);
                pre_out = tot;
                SAT::add_edge(no[L].p, tot);
                L++;
            }
            // 连边
            if(pre_not_in) SAT::add_edge(no[R].p, pre_not_in);
            if(pre_out) SAT::add_edge(pre_out, no[R].p + n);
            R++;
        }
        L = mid, R = r;
        // 右边有 =v 0 那么左边必须 >= v+k 1
        // 左边有 >= v+k 0 那么右边必须 =v 1
        // 维护左侧 suf_in suf_not_out
        int suf_in = 0, suf_not_out = 0;
        while (R >= mid+1) {
            while(L >= 1 && no[L].v >= no[R].v + K) {
                ++tot;
                if(suf_in) SAT::add_edge(tot, suf_in);
                suf_in = tot;
                SAT::add_edge(tot, no[L].p);
                ++tot;
                if(suf_not_out) SAT::add_edge(suf_not_out, tot);
                suf_not_out = tot;
                SAT::add_edge(no[L].p + n, tot);
                L--;    
            }
            if (suf_in) SAT::add_edge(no[R].p + n, suf_in);
            if (suf_not_out) SAT::add_edge(suf_not_out, no[R].p);
            R--;
        }

        // 归并排序 原来是按照 p 排序 现在按照 v
        int a = l, b = mid+1, i = 1;
        while(a <= mid && b <= r) tmp[i++] = no[a].v < no[b].v ? no[a++] : no[b++];
        while(a <= mid) tmp[i++] = no[a++];
        while(b <= r) tmp[i++] = no[b++];
        memcpy(no+l,tmp+1,sizeof(Node)*(r-l+1));
    }

    void cdq(int l,int r) {
        if(l==r)return;
        int mid = (l + r) / 2;
        cdq(l,mid);
        cdq(mid+1,r);
        merge(l,mid,r);
    }

    bool check(int k) {
        SAT::clear();
        reset(n * 2);
        for (int i = 1; i <= m; i++) {
            auto [u, v] = uv[i];
            SAT::add_edge(u, v + n);
            SAT::add_edge(v, u + n);
            SAT::add_edge(u + n, v);
            SAT::add_edge(v + n, u);
        }
        for(int i = 1; i <= n; i++) no[i] = {i, val[i]};
        K = k;
        cdq(1, n);
        SAT::build(tot);
        for (int i = 1; i <= n; i++) if (SAT::scc[i] == SAT::scc[i+n]) return false;
        return true;
    }
    LG_P7477() {
        cin >> n >> m;
        for (int i = 1; i <= n; i++) cin >> val[i];
        for (int i = 1; i <= m; i++) cin >> uv[i][0] >> uv[i][1];
        int l = 0, r = V, ans = -1;
        while(l <= r) {
            int mid = (l + r) / 2;
            if (check(mid)) {
                ans = mid;
                r = mid - 1;
            } else {
                l = mid + 1;
            }
        }
        cout << ans << "\n";
    }
};

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    new LG_P7477();
}
```

