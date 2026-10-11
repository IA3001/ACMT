=== #text("SCC 强连通分量")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/ALGO/SCC.md`]

==== P1 模板题：打印强连通分量 （缩点）

- `LG_U224391`
  - 模板题

==== P2 性质：出度/入度 加边 （缩点 + 拓扑）

- `LG_P22812`
  - DAG 出度 / 入度 结论

==== P3 拓展：弱连通图判定 （缩点 + 拓扑）

- `LG_P10944`
  - 弱连通图判定

==== P4 其它：缩点 DAG 之后结合数学 （缩点 + 拓扑 + 数学）

- `LG_P4819`
  - 最优排查方式

==== Codes

```cpp
#include<bits/stdc++.h>
using namespace std;

namespace SCC {
    const int N = 2e6 + 5;
    const int M = 2e6 + 5;
    int n;
    
    struct Edge{
        int to, nxt;
    }e[N];
    int hd1[N], hd2[N], cntE;

    int dfn[N], low[N], dfncnt;
    int stk[N], tp;
    int scc[N], sc, sz[N];
    // 扩展  DAG 拓扑排序
    int in[N], out[N];
    
    void init(int nn) {
        fill(hd1,hd1+1+n,0);
        fill(hd2,hd2+1+n,0);
        fill(dfn,dfn+1+n, 0);
        // 没有 ins 那么 scc 一定要清空 
        fill(scc,scc+1+n,0);
        fill(sz,sz+1+n,0);
        // 扩展
        fill(in,in+1+n,0);
        fill(out,out+1+n,0);

        n = nn;
        cntE = 1;
        dfncnt = sc = tp = 0;
    }

    void add_edge(int* hd,int u,int v) {
        e[++cntE] = {v,hd[u]};
        hd[u] = cntE;
    }

    void tarjan(int u) {
        low[u] = dfn[u] = ++dfncnt; stk[++tp] = u;
        for(int i = hd1[u];i;i=e[i].nxt) {
            int v = e[i].to;
            if (!dfn[v]) {
                // cout << u << "->" << v << "\n";
                tarjan(v);
                low[u] = min(low[u], low[v]);
            } else if(!scc[v]) { 
                // 【坑点】这里是 !scc[v] 等价于 ins[v], 不是 dfn[v] 的比较!
                // cout << u << "<-" << v << "\n";
                low[u] = min(low[u], dfn[v]);
            }
        }
        if (low[u] == dfn[u]) {
            ++sc;
            int pop;
            do{
                pop = stk[tp--];
                scc[pop] = sc;
                sz[sc]++;
            }while(pop!=u);
        }
    }

    void work() {
        for (int u = 1; u <= n;u++) {
            if(!dfn[u]) tarjan(u);
        }
    }
    
    void build() {
        for (int u = 1; u <= n;u ++) {
            int x = scc[u];
            for(int i = hd1[u];i;i=e[i].nxt) {
                int v = e[i].to;
                int y = scc[v];
                if (x != y) {
                    add_edge(hd2, x, y);
                    out[x]++;
                    in[y]++;
                }
            }
        }
        // 之后可以进行：
        // 外部搓一个队列，然后拓扑排序
    }

    // 去重版
    void build2() {
        set<uint64_t> S;
        for (int u = 1; u <= n;u ++) {
            int x = scc[u];
            for (int i = hd1[u];i;i=e[i].nxt) {
                int v = e[i].to;
                int y = scc[v];
                if (x != y) {
                    // 不兑！两个 scc 之间的方向一定是同样的
                    uint64_t p = (uint64_t(x) << 32) | y;
                    if (!S.count(p)){
                        add_edge(hd2, x, y);
                        out[x]++;
                        in[y]++;
                        S.insert(p);
                    }
                }
            }
        }
    }
};

struct LG_U224391 {
    // 模板题 
    // 打印 scc 个数及其内部点
    // N 5e4 M 1e5 
    int n, m;
    LG_U224391() {
        cin >> n >> m;
        SCC::init(n);
        for (int i = 1; i <= m;i ++) {
            int u, v;
            cin >> u >> v;
            SCC::add_edge(SCC::hd1, u, v);
        }
        SCC::work();
        int group = SCC::sc;
        cout << group << "\n";
        vector<vector<int>> ans(group+1); 
        for (int i = 1; i <= n;i ++) {
            ans[SCC::scc[i]].push_back(i);
        }
        for(int i = 1; i <= group;i++) {
            cout << ans[i].size() << " ";
            for(auto v:ans[i]) cout << v << " ";
            cout << "\n";
        }
    }
};

struct LG_P2812 {
    // DAG 出度 / 入度 结论
    // N 1e4 M 5e4
    int n;
    LG_P2812() {
        cin >> n;
        SCC::init(n);
        for (int i = 1; i <= n;i++) {
            int j;
            while(cin>>j&&j) {
                SCC::add_edge(SCC::hd1, i, j);
            }
        }
        SCC::work();
        SCC::build();
        int L = 0, R = 0;
        for (int i = 1; i <= SCC::sc;i ++) {
            L += !SCC::in[i];
            R += !SCC::out[i];
        }
        // 【坑点】 特判只有一个 scc 不需要加边
        if (SCC::sc == 1) {
            cout << 1 << "\n";
            cout << 0 << "\n";
        } else {
            cout << L << "\n";
            cout << max(L, R) << "\n";
        }
    }
};

struct LG_P10944 {
    // 弱连通图判定
    // u v 之间至少有一条路
    // N 1e3 M 6e3
    int n, m;
    LG_P10944() {
        int T = 1;
        cin >> T;
        while (T--) {  
            cin >> n >> m;
            SCC::init(n);
            for (int i = 1; i <= m;i++) {
                int u, v;
                cin >> u >> v;
                SCC::add_edge(SCC::hd1, u, v);
            }
            SCC::work();
            SCC::build();
            queue<int> Q;
            bool ok = true;
            for(int i = 1; i <= SCC::sc; i++) {
                if (!SCC::in[i]) Q.push(i);
            }
            while(Q.size()) {
                ok &= Q.size() == 1;
                int u = Q.front(); Q.pop();
                for(int i = SCC::hd2[u];i;i=SCC::e[i].nxt) {
                    int v = SCC::e[i].to;
                    if(!--SCC::in[v]) Q.push(v);
                }
            }
            if (ok) cout << "Yes\n";
            else cout << "No\n";
        }
    }
};

struct LG_P4819 {
    // 杀人游戏
    // 最优排查方式 
    // 总概率公式 + 省一次
    // 【注意】 需要 scc 间边去重 (build2)
    // N 1e5 M 3e5
    int n, m;
    LG_P4819() {
        cin >> n >> m;
        SCC::init(n);
        for (int i = 1; i<= m;i++) {
            int u, v;
            cin >> u >> v;
            SCC::add_edge(SCC::hd1, u, v);
        }
        SCC::work();
        SCC::build2();
        auto isolate = [&](int u) {
            if(SCC::sz[u] > 1 || SCC::in[u]) return false;
            for(int i = SCC::hd2[u]; i; i=SCC::e[i].nxt) {
                int v = SCC::e[i].to;
                if (SCC::in[v] == 1) return false;
            }
            return true;
        };
        int tot = 0;
        bool ok = false;
        for (int i = 1; i <= SCC::sc; i++) {
            ok |= isolate(i);
            tot += !SCC::in[i];
        }
        tot -= ok;
        // 【坑点】 保留 6 位小数，必须写成这样 setprecision(6)
        cout << fixed << setprecision(6);
        cout << double(n - tot) / n << "\n";
    }
};

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    // new LG_U224391();
    // new LG_P2812();
    // new LG_P10944();
    new LG_P4819();
}
```

