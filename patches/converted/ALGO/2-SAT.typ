=== #text("2-SAT")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/ALGO/2-SAT.md`]

==== P1 模板题

- `LG_P4782`

==== P2 最多选一个：前缀优化建图

- `LG_P6378`

==== P3 数学互质：前缀优化建图

- `AT_abc210_f`

==== Codes

```cpp
#include<bits/stdc++.h>
using namespace std;

namespace SAT {
    // 【坑点】
    // N 一定要开二倍啊啊啊啊啊啊
    // M 也是！ 因为有正反孪生约束
    const int N = (2e6 + 5) * 2, M = (4e6 + 5) * 2;
    
    int n;

    struct Edge {
        int to, nxt;
    }e[M];
    int hd[N], cntE;
    int dfn[N], dfncnt, low[N], stk[N], tp;
    int scc[N], sc;

    // 【感悟！】
    // 我现在才发现，其实
    // 除非 BIT DSU（不太符合） 之类的东西
    // 不要用 init 而是用 clear 命名 这样便于动态扩展
    void clear() {
        fill(hd,hd+1+n,0);
        fill(dfn,dfn+1+n,0);
        fill(scc,scc+1+n,0);
        n = 0;
        cntE = 1;
        dfncnt = sc = tp = 0;
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
            do {
                pop = stk[tp--];
                scc[pop] = sc;
            } while(pop != u);
        }
    }

    void build(int nn) {
        n = nn;
        for(int i = 1; i <= n; i++) {
            if (!dfn[i]) tarjan(i);
        }
    }
}

struct LG_P4782 {
    // 模板题 
    // i==a or j==b
    inline static const int N = 1e6 + 5, M = 1e6 + 5;
    int n, m;
    int other(int x) {
        return x <= n ? x + n : x - n;
    }
    LG_P4782() {
        // 【坑点】 chovy!!! 节点数量是二倍包括正反！！！
        SAT::clear();
        bool ok = true;
        cin >> n >> m;
        while (m--) {
            int i, a, j , b;
            cin >> i >> a >> j >> b;
            int I = i + (a==0?n:0), J = j + (b==0?n:0);
            SAT::add_edge(other(I), J);
            SAT::add_edge(other(J), I);
        }
        SAT::build(n*2);
        for (int i = 1; i <= n; i++) ok &= SAT::scc[i] != SAT::scc[i+n];
        if (!ok) cout << "IMPOSSIBLE\n";
        else  {
            cout << "POSSIBLE\n";
            for (int i = 1; i <= n;i++) {
                cout << (SAT::scc[i] < SAT::scc[i+n]) << " ";
            }cout << "\n";
        }
    }
};

struct CF_1697 {
    // 太难了 现在 CF 太卡了 鸽了
};

struct LG_P6378 {
    // 结合前缀优化建图
    // 题意 k 个阵营的点，每一个阵营选一个
    // m 个边至少有一端被选中
    // 其实如果有阵营 全不选 的方案一定可以再选一个
    // 注意开
    // 点个数: 基础 2*N + 2 * N
    // 边个数: 基础 2*M + 6 * N 
    inline static const int N = 1e6 + 5, M = 1e6 + 5;
    int n, m, k;
    int tot;
    int other(int x) {
        return x <= n ? x + n : x - n;
    }
    LG_P6378() {
        SAT::clear();
        bool ok = true;
        cin >> n >> m >> k;
        tot = n * 2;
        for (int i = 1; i <= m; i++) {
            int u, v;
            cin >> u >> v;
            SAT::add_edge(other(u), v);
            SAT::add_edge(other(v), u);
        }
        for (int i = 1; i <= k; i++) {
            int w; cin >> w;
            vector<int> a(w), pre_not_in(w), suf_not_in(w);
            for(auto& v:a) cin >> v;
            pre_not_in[0] = other(a[0]);
            for(int i = 1; i < w;i++) {
                pre_not_in[i] = ++tot;
                SAT::add_edge(tot, pre_not_in[i-1]);
                SAT::add_edge(tot, other(a[i]));    
                // 选这个不选前面的
                SAT::add_edge(a[i], pre_not_in[i-1]);    
            }
            suf_not_in[w-1] = other(a[w-1]);
            for(int i = w-2;i>=0;i--) {
                suf_not_in[i] = ++tot;
                SAT::add_edge(tot, suf_not_in[i+1]);    
                SAT::add_edge(tot, other(a[i]));    
                // 选这个不选后面的
                SAT::add_edge(a[i], suf_not_in[i+1]);    
            }
        }
        SAT::build(tot);
        for(int i = 1; i <= n; i++) ok &= SAT::scc[i] != SAT::scc[i+n];
        if (!ok) cout << "NIE\n";
        else cout << "TAK\n";
    }
};

struct AT_abc210_f {
    // 选数字 二选一 不能互质
    inline static const int N = 3e4 + 5, V = 2e6 + 5;
    
    int factor[V], primes[V], cntP;

    void init() {
        for (int i = 2; i < V; i++) {
            if (!factor[i]) {
                primes[++cntP] = factor[i] = i;
            }
            for (int j = 1; j <= cntP; j++) {
                int p = primes[j], pi = p*i;
                if (pi >= V) break;
                factor[pi] = p;
                if(i % p == 0) break;
            }
        }
    }

    int n, tot;
    vector<int> buf[V];
    void solve() {
        SAT::clear();
        bool ok = true;
        cin >> n;
        auto other = [&](int x) {return x <= n ? x + n : x - n;};
        auto collect = [&](int a, int i) {
            while(a > 1) {
                int p = factor[a];
                buf[p].push_back(i);
                while(a%p==0) a/=p;
            }
        };
        for (int i = 1; i <= n; i++) {
            int a, b;
            cin >> a >> b;
            collect(a, i);
            collect(b, i+n);
        }
        tot = n * 2;
        auto set_pre = [&](vector<int>& a) {
            int n = a.size();
            if (n == 0) return;
            int pre_not = other(a[0]);
            // 【超威】 作秀用 lambda ，直接没有注意到 0-base 越界了
            for(int i = 1; i < n;i++) {
                SAT::add_edge(a[i], pre_not);
                ++tot;
                SAT::add_edge(tot, pre_not);
                SAT::add_edge(tot, other(a[i]));
                pre_not = tot;
            }
        };
        for(int i = 1; i < V; i++) {
            set_pre(buf[i]);
            reverse(buf[i].begin(), buf[i].end());
            set_pre(buf[i]);
        }
        SAT::build(tot);
        for(int i = 1; i <= n; i++) ok &= SAT::scc[i] != SAT::scc[i+n];
        cout << (ok ? "Yes" : "No") << "\n";
    }

    AT_abc210_f() {
        init();
        solve();
    }
};

int main() {
    // ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    // new LG_P4782();
    // new LG_P6378();
    new AT_abc210_f();
}
```

