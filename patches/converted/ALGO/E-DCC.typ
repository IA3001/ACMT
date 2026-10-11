=== #text("E-DCC 边双连通分量")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/ALGO/E-DCC.md`]

==== P1 边简单路径/迹 查询（边双树 + 树剖）

- `LG_P7924`
  - 旅行家
  - q 次查询 x 到 y 所有简单路径覆盖的点权之和

==== P2 点集边双联通计数（边双树 + 有根据的计数DP）

- `LG_P8867`
  - 建造军营
  - \/\/ 双连通缩点 -\> 树
  - \/\/ -\> 树上任意点集联通方案计数
  - \/\/ N 5e5 M 1e6
  - \/\/ 终于看懂了, 是在限制:
  - \/\/ 唯一存在点集的边集连通块
  - \/\/ 的最高点在哪里
  - \/\/ 然后 然后枚举最高点并且与上层切割(注意特判树根)

==== Codes

===== P1 - P2

```cpp
#include<bits/stdc++.h>
using namespace std;
using ll = long long;

namespace DCC {
    const int N = 2e6 + 5;
    const int M = 2e6 + 5;
    
    int n;

    struct Edge {
        int to, nxt;
        int w;
    }e[M*2];
    int hd[N], cntE; // 111
    bool cut[M*2]; // 1
    // 新树
    vector<int> E[N];
    
    int dfn[N], low[N], dfncnt; // 101
    int stk[N], tp; // 01    
    // edcc 划分
    int dcc[N], dc; // 01
    vector<int> edcc[N];

    void init(int nn) {
        fill(hd,hd+1+n,0);
        fill(cut,cut+1+cntE,false);

        fill(dfn,dfn+1+n,0);
        
        for (int i = 1; i <= dc; i++) edcc[i].clear();
        for (int i = 1; i <= dc; i++) E[i].clear();
        
        n = nn;
        cntE = 1;
        dfncnt = dc = tp = 0;
    }

    void add_edge(int u,int v, int w = 0) {
        e[++cntE] = {v, hd[u], w};
        hd[u] = cntE;
    }

    void tarjan(int u, int fi) {
        low[u] = dfn[u] = ++dfncnt;
        stk[++tp] = u;
        for(int i = hd[u]; i;i=e[i].nxt) {
            if ((i^1) == fi) continue;
            int v = e[i].to;
            if(!dfn[v]) {
                tarjan(v, i);
                low[u] = min(low[u], low[v]);
                // 割边
                if (low[v] > dfn[u]) {
                    cut[i >> 1] = true;
                }
            } else {
                low[u] = min(low[u], dfn[v]);
            }
        }
        if (low[u] == dfn[u]) {
            dc++;
            int pop;
            do {
                pop = stk[tp--];
                dcc[pop] = dc;
                edcc[dc].push_back(pop);
            } while(pop != u);
        }
    }
    void work() {
        for(int i = 1; i <= n;i++) {
            if(!dfn[i]) tarjan(i, 0);
        }
    }
    void build() {
        // 建立不可反向边标记的无向图
        // 除非： add_edge 建立的是双向边
        for (int u = 1; u <= n;u++) {
            int x = dcc[u];
            for(int i = hd[u];i;i=e[i].nxt) {
                int v = e[i].to;
                int y = dcc[v];
                if (x != y) {
                    E[x].push_back(y);
                    // add_edge(hd2, x, y);
                } else {
                    // 无
                }
            }
        }
    }
}

struct LG_P7924 {
    // 旅行家
    // q 次查询 x 到 y 所有简单路径覆盖的点权之和 
    // N 5e5 M 2e6
    inline static const int N = 5e5 + 5;
    int n, m, q;
    int a[N];
    int tag[N];
    int dfn[N], dfncnt, dep[N];
    int rmq[N][__lg(N) + 2], P;
    int upper(int a,int b) {
        return dfn[a] < dfn[b] ? a : b;
    }
    int lca(int a,int b) {
        if(a == b) return a;
        int l = dfn[a], r = dfn[b];
        if (l > r) swap(l, r);
        l++;
        int p = __lg(r-l+1);
        return upper(rmq[l][p], rmq[r-(1<<p)+1][p]);
    }
    void dfs(int u,int f) {
        dep[u] = dep[f] + 1;
        dfn[u] = ++dfncnt;
        rmq[dfncnt][0] = f;
        for (auto v: DCC::E[u]){
            if (v == f) continue;
            dfs(v, u);
        }
    }
    void dfs2(int u,int f) {
        for(auto v: DCC::E[u]) {
            if (v == f) continue;
            dfs2(v, u);
            // 【坑】 被自己阴阳到了：递归顺序乱了 
            tag[u] += tag[v];
        }
    }
    LG_P7924() {
        dfncnt = 0;
        fill(tag,tag+1+n,0);
        cin >> n >> m;
        DCC::init(n);
        for (int i = 1; i <= n;i ++) cin >> a[i];
        for (int i = 1; i <= m; i++) {
            int u, v;
            cin >> u >> v;
            DCC::add_edge(u, v);
            DCC::add_edge(v, u);
        }
        DCC::work();
        DCC::build();
        dfs(1, 0);
        P = __lg(dfncnt);
        for (int p = 1; p <= P;p++) {
            for (int i = 1; i <= dfncnt;i++) {
                // 【坑点】狠！能用 dfncnt 就用 dfncnt 啊
                int ed = min(dfncnt, i + (1<<(p-1)));
                rmq[i][p] = upper(rmq[i][p-1], rmq[ed][p-1]);                
            }
        }
        cin >> q;
        while (q--) {
            int x, y;
            cin >> x >> y;
            x = DCC::dcc[x];
            y = DCC::dcc[y];
            int z = lca(x, y);
            int fz = rmq[dfn[z]][0];
            tag[x]++;
            tag[y]++;
            tag[z]--;
            tag[fz]--;
        }
        dfs2(1, 0);
        int ans = 0;
        for (int i = 1; i <= DCC::dc;i++) {
            if (tag[i] > 0) {
                for(auto v:DCC::edcc[i]) {
                    ans += a[v];
                }
            }
        }
        cout << ans << "\n";
    }
};

struct LG_P8867 {
    // 建造军营
    // 双连通缩点 -> 树
    // -> 树上任意点集联通方案计数
    // N 5e5 M 1e6
    // 终于看懂了, 是在限制: 
    // 唯一存在点集的边集连通块
    // 的最高点在哪里
    // 然后 然后枚举最高点并且与上层切割(注意特判树根)
    inline static const int mod = 1e9 + 7;
    inline static const int N = 5e5 + 5;
    inline static const int M = 1e6 + 5;
    int n, m;
    // dp[u] 表示必须以 u 作为最顶端边联通区的至少有一个军营的方案数
    // 初始的时候有: 至少选择一个军营 也就是 2^边双大小 - 1 
    int power2[M];
    int dp[N]; 
    int bridge[N];
    int ans;
    void dfs(int u,int f) {
        // cout << "dp[" << u << "]:" << "\n";
        bridge[u] = 0;
        dp[u] = power2[DCC::edcc[u].size()] - 1;
        for (auto v: DCC::E[u]) {
            if (v == f) continue;
            dfs(v, u);
            dp[u] = (
                // 10: dp[u] * 2^{bridge[v]+1}
                (ll) dp[u] * power2[bridge[v]+1] % mod+
                // 01: dp[v] * 2^{bridge[u]} // 特别注意： u 不要，但是 v 一定要连上 u!!!
                (ll) dp[v] * power2[bridge[u]] % mod+
                // 11: dp[u] * dp[v]
                (ll) dp[u] * dp[v] % mod
            )%mod;
            bridge[u] += bridge[v] + 1;
        }
        // 结算答案:
        // 以 u 作为含军营连通分量的最顶端 总边 - u 子树边 - (有父边)
        ans = (ans + (ll) dp[u] * power2[m - bridge[u] - (f>0)]) % mod;
    }

    void solve() {
        ans = 0;
        cin >> n >> m;
        DCC::init(n);
        for (int i = 1; i <= m; i++) {
            int u, v;
            cin >> u >> v;
            DCC::add_edge(u, v);
            DCC::add_edge(v, u);
        }
        DCC::work();
        DCC::build();
        dfs(1, 0);
        cout << ans << "\n";
    }

    LG_P8867() {
        // 【坑点】 这里上限是边的数量不是点！！！
        power2[0] = 1;
        for (int i = 1; i < M; i++) power2[i] = power2[i-1] * 2 % mod;
        solve();
    }
};

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    // 【巨大的坑点】 不可以直接 LG_P7924() 因为直接干爆栈了（对本地不友好）
    // new LG_P7924();
    // new LG_P8867();
}
```

