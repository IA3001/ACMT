=== #text("V-DCC 点双连通分量")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/ALGO/V-DCC.md`]

==== P1 求割点（普通圆方树）

- `LG_P3388`
  - \/\/ 模板题
  - \/\/ 输出割点个数 + 从小到大输出割点

==== P2 点双缩点计数题（普通圆方树）

- `LG_P3225`
  - 矿场搭建
  - 和出题人博弈：选定几个点，使得无论任何点被删掉
  - 总有剩余联通区被感染

==== P3 简单路径查询（普通圆方树 + 树剖 + 差分）

- `LG_P5058`
  - 查询 a b 之间的最小编号割点(q=1)

==== Codes

```cpp
#include<bits/stdc++.h>
using namespace std;

// 【坑点】 template<int N, int M> 面向对象 看似完美
// 实则 非静态对象 n 等变量 直接未初始化
namespace DCC {
    const int N = 2e6 + 5;
    const int M = 2e6 + 5;

    int n;
    
    struct Edge {
        int to, nxt;
        int w;
    }e[M*2]; // 2*M
    int hd[N], cntE;
    int cntn;
    // 并非辅助： 直接用 这个邻接表存储 点双缩点 更简洁
    // 注意 开二倍空间
    vector<int> E[N*2];

    int dfn[N], low[N], dfncnt;
    int stk[N], tp;

    void init(int nn) {
        fill(hd,hd+1+n,0);
        
        fill(dfn,dfn+1+n,0);
        
        for (int i = 1; i <= cntn; i++) E[i].clear();

        cntn = n = nn;
        cntE = 1;
        dfncnt = tp = 0;
    }

    void add_edge(int u,int v, int w=0) {
        e[++cntE] = {v, hd[u], w};
        hd[u] = cntE;
    }

    void tarjan(int u) {
        low[u] = dfn[u] = ++dfncnt;
        stk[++tp] = u;
        for (int i = hd[u]; i; i=e[i].nxt) {
            int v = e[i].to;
            if (!dfn[v]) {
                tarjan(v);
                low[u] = min(low[u], low[v]);
                if (low[v] >= dfn[u]) {
                    ++cntn;
                    E[cntn].push_back(u);
                    E[u].push_back(cntn);
                    int pop;
                    do {
                        pop = stk[tp--];
                        E[cntn].push_back(pop);
                        E[pop].push_back(cntn);
                    } while(pop != v);
                }
            } else {
                low[u] = min(low[u], dfn[v]);
            }
        }
    }

    void build() {
        for (int i = 1; i <= n; i++) {
            if (!dfn[i]) {
                if (!hd[i]) {
                    ++cntn;
                    // 孤立节点，必须特判
                    E[cntn].push_back(i);
                    E[i].push_back(cntn);
                } else {
                    tarjan(i);
                }
            }
        }
    }
};

struct LG_P3388 {
    // 模板题
    // 输出割点个数 + 从小到大输出割点
    // N 2e4 M 1e5
    inline static const int N = 2e4 + 5, M = 1e5 + 5;
    int n, m;
    LG_P3388() {
        cin >> n >> m;
        DCC::init(n);
        for (int i = 1; i <= m; i++) {
            int u, v;
            cin >> u >> v;
            DCC::add_edge(u, v);
            DCC::add_edge(v, u);
        }
        DCC::build();
        int cnt = 0;
        for (int i = 1; i <= n; i++) {
            cnt += (DCC::E[i].size() > 1);
        }
        cout << cnt << "\n";
        for (int i = 1; i <= n; i++) {
            if (DCC::E[i].size() > 1) {
                cout << i << " ";
            }
        }
        cout << "\n";
    }
};

struct LG_P3225 {
    // 矿场搭建
    // 和出题人博弈：选定几个点，使得无论任何点被删掉
    // 总有剩余联通区被感染
    inline static const int N = 1e3 + 5, M = 1e3 + 5;
    int n, m, t;
    LG_P3225() {
        t = 0;
        while(cin >> m && m) solve();
    }
    void solve() {
        n = 0;
        map<int,int> mp;
        vector<array<int,2>> edge;
        for (int i = 1; i <= m;i++) {
            int u, v;
            cin >> u >> v;
            if (!mp.count(u)) mp[u] = ++n;
            if (!mp.count(v)) mp[v] = ++n;
            edge.push_back({mp[u], mp[v]});
        }
        DCC::init(n);
        for(auto [u, v]: edge) {
            DCC::add_edge(u, v);
            DCC::add_edge(v, u);
        }
        DCC::build();
        int cnt = 0;
        vector<int> deg(DCC::cntn + 1);
        for (int  i = 1; i <= n; i++) {
            if (DCC::E[i].size() > 1) {
                for (auto j: DCC::E[i]) {
                    deg[j]++;
                }
            }
        }
        uint64_t ans = 1;
        if (DCC::cntn == n + 1) {
            // 【坑点】哎我操 单点的时候 cnt=2 
            cout << "Case " << ++t << ": " << 2 << " " << n * (n - 1) / 2 << "\n";
            return;
        }
        for (int i = n + 1; i <= DCC::cntn; i++) {
            if (deg[i] == 1) {
                cnt++;
                ans *= DCC::E[i].size() - 1;
            }
        }
        cout << "Case " << ++t << ": " << cnt << " " << ans << "\n";
    }
};

struct LG_P5058 {
    // 查询 a b 之间的最小编号割点(q=1)
    // N 2e5 M 5e5
    inline static const int N = 2e5 + 5;
    int n;
    // 【坑点】 128MB 卡我的空间 复杂度 O(nlog^2n)
    // int son[N], sz[N], dfn[N], top[N], fa[N], dep[N], dfncnt;
    // int rnk[N];
    // int f[N*4];
    // void up(int i) {
    //     f[i] = min(f[i*2], f[i*2+1]);
    // }
    // void build(int i,int l,int r) {
    //     if(l==r) {
    //         f[i] = rnk[l] <= n ? rnk[l] : 2e9;
    //     } else {
    //         int mid = (l + r) / 2;
    //         build(i*2,l,mid);
    //         build(i*2+1,mid+1,r);
    //         up(i);
    //     }
    // }
    // int query(int i,int l,int r,int jl,int jr) {
    //     if(jl<=l&&r<=jr) {
    //         return f[i];
    //     } else {
    //         int res = 2e9;
    //         int mid = (l + r) / 2;
    //         if (jl <= mid) res = query(i*2,l,mid,jl,jr);
    //         if (jr > mid) res = min(res, query(i*2+1,mid+1,r,jl,jr));
    //         return res;
    //     }
    // }
    // void dfs1(int u, int f) {
    //     sz[u] = 1;
    //     fa[u] = f;
    //     // 【坑点！】 这玩意没写！
    //     dep[u] = dep[f] + 1;
    //     // 【坑点？】
    //     son[u] = 0;
    //     for (auto v: DCC::E[u]) if (v != f) {
    //         dfs1(v, u);
    //         sz[u] += sz[v];
    //         if (sz[v] > sz[son[u]]) son[u] = v;
    //     }
    // }
    // void dfs2(int u,int tp) {
    //     rnk[dfn[u] = ++dfncnt] = u;
    //     top[u] = tp;
    //     if (son[u]) dfs2(son[u], tp);
    //     for (auto v: DCC::E[u]) if (v!=fa[u] && v!=son[u]) dfs2(v, v);
    // }
    // int query_lca(int x,int y) {
    //     while(top[x] != top[y]) {
    //         if (dep[top[x]] < dep[top[y]]) swap(x, y);
    //         x=fa[top[x]];
    //     }
    //     return dfn[x] < dfn[y] ? x : y;
    // }
    // int query_path(int x, int y) {
    //     int ans = 2e9;
    //     while(top[x] != top[y]) {
    //         if (dep[top[x]] < dep[top[y]]) swap(x, y);
    //         ans = min(ans, query(1,1,dfncnt,dfn[top[x]], dfn[x]));
    //         x=fa[top[x]];
    //     }
    //     if(dep[x] < dep[y]) swap(x, y);
    //     ans = min(ans, query(1,1,dfncnt,dfn[y], dfn[x]));
    //     return ans;
    // }
    // int jump_to(int x,int d) {
    //     while(dep[top[x]] > d) {
    //         x = fa[top[x]];
    //     }
    //     return rnk[dfn[x] - (dep[x] - d)];
    // }
    // 【坑点】 双倍的点数！ 
    int fa[N*2];
    void dfs0(int u, int f) {
        fa[u] = f;
        for (auto v: DCC::E[u]) if (v!=f) dfs0(v, u);
    }
    LG_P5058() {
        cin >> n;
        DCC::init(n);
        int u, v;
        while (cin >> u >> v && (u || v)) {
            DCC::add_edge(u, v);
            DCC::add_edge(v, u);
        } 
        DCC::build();

        // dfs1(1,0);
        // dfncnt = 0;
        // dfs2(1,1);
        // build(1,1,dfncnt);
        int res = 2e9;
        int a, b, c, A, B;
        cin >> a >> b;
        A = a, B = b;
        vector<bool> vis(DCC::cntn + 1);
        dfs0(1, 0);
        while(A) vis[A] = true, A = fa[A];
        while(1) {
            if (vis[B]) {
                c = B;
                break;
            }
            B = fa[B];
        }
        int cur = a;
        while(1) {
            if (cur != a && cur != b && cur <= n) res = min(res, cur);
            if (cur == c) break;
            cur = fa[cur];
        }
        cur = b;
        while(1) {
            if (cur != a && cur != b && cur <= n) res = min(res, cur);
            if (cur == c) break;
            cur = fa[cur];
        }
        // int c = query_lca(a, b);
        // if (a == b) res = -1;
        // else if (c == a) {
        //     res = query_path(fa[b], jump_to(b, dep[c]+1));
        // } else if(c == b) {
        //     res = query_path(fa[a], jump_to(a, dep[c]+1));
        // } else {
        //     res = query_path(fa[a], fa[b]);
        // }
        if (res == 2e9) cout << "No solution\n";
        else cout << res << "\n";
    }
};

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    // new LG_P3388();
    // new LG_P3225();
    new LG_P5058();
}
```

