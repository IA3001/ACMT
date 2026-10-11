=== #text("欧拉回路")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/ALGO/欧拉回路.md`]

==== P10950 太鼓达人

===== 题目描述

求字典序最小的，包含全体的 长度为 K 的 01 循环串最小循环节

===== Solution

- #strong[德布罗意序列]
- `namespace Euler`
  - Hierholzer 算法求欧拉路径
  - 有向图 / 无向图 欧拉 回路 / 路径 起点

==== P2731 USACO3.3 骑马修栅栏 Riding the Fences

===== 题目描述

给定有 $m$ 条无向边的连通图（顶点编号不连续），求字典序最小的欧拉路径

===== Solution

- #strong[无向图欧拉回路/路径] + #strong[最小字典序]

==== P7771 【模板】欧拉路径

===== 题目描述

求有向图字典序最小的欧拉路径。

==== Codes

```cpp
#include<bits/stdc++.h>
#define endl "\n"
using namespace std;

namespace Euler {
    const int N = 2e6 + 5;

    int n;

    struct Edge{
        int to, nxt, w, id;
    }e[N];

    int hd[N], cntE, cur[N];
    int in[N], out[N];
    int stk[N], tp;

    // 稳稳接住版
    bool vis[N];

    // 严格使用 1-base 
    void init(int nn) {
        n = nn;
        fill(hd,hd+1+n,0);
        fill(in,in+1+n,0);
        fill(out,out+1+n,0);

        fill(vis,vis+1+cntE, false);
        cntE = 1;
    }

    // 为什么要动态加入 id？
    // 因为往往需要字典序排序，容易乱
    void add_edge(int u, int v, int w, int id = 0) {
        e[++cntE] = {v, hd[u], w, id};
        hd[u] = cntE;
        out[u]++;
        in[v]++;
    }

    // 一般只做一次
    void reset() {
        memcpy(cur, hd, sizeof(hd[0])*(n+1));
    }

    // 有向图
    void hierholzer(int u, int fw) {
        for (int& i = cur[u]; i;) {
            int j = i;
            i = e[i].nxt;
            hierholzer(e[j].to, e[j].w);
        }
        stk[++tp] = fw;
    }

    // 无向图
    void hierholzer2(int u, int fw) {
        for (int& i = cur[u]; i;) {
            int j = i;
            i = e[i].nxt;

            if (vis[e[j].id]) continue;
            vis[e[j].id] = true;

            // cout << u << "->" << e[j].to << endl;
            
            hierholzer2(e[j].to, e[j].w);
        }
        stk[++tp] = fw;
    }

    pair<int,int> getST() {
        // 有向图 的 回路 / 路径(不适用于多连通分量) 起点
        // 1. in = out / abs(in - out) <= 1 
        // 2. any(min) / only
        int S = -1, T = -1, first = -1;
        for(int i = 1; i <= n;i++) {
            int diff = in[i] - out[i];
            if (diff < -1 || diff > 1 || (diff == -1 && S != -1) || (diff == 1 && T != -1)) return {-1, -1};
            if (diff == -1) S = i;
            else if (diff == 1) T = i;
            else if (first == -1) first = i;
        }
        if (S != -1 && T != -1) return {S, T};
        else if (S == -1 && T == -1) return {first, first};
        else return {-1, -1};
    }

    pair<int,int> getST2() {
        // 无向图 的 回路 / 路径(不适用于多连通分量) 起点
        // 1. deg = in 为偶数(因为双边) / 只有 2 个为 奇数
        // 2. any(min) / two(min)
        int S = -1, T = -1, first = -1;
        for(int i = 1; i <= n;i++) {
            // cout << i << ":" << in[i] << "\n";
            int deg = in[i];
            if (deg & 1) {
                if (S == -1) S = i;
                else if (T == -1) T = i;
                else return {-1, -1};
            } else if (first == -1) first = i;
        }
        // cout << S << " & " << T << "\n";
        if (S == -1 && T == -1) return {first, first};
        if (S > T) swap(S, T);
        if (S == -1) return {-1, -1};
        return {S, T};
    }
}

struct LG_P10950 {
    // 太鼓达人: 德布罗意序列 最小字典序
    const int K = 11;
    const int N = (1<<K) * 10;
    int k, mask;

    LG_P10950() {
        cin >> k;
        mask = (1 << (k-1)) - 1;
        Euler::init(1 << (k-1));
        for(int i = 0;i <= mask;i++) {
            int j0 = (i << 1) & mask;
            int j1 = (i << 1 | 1)& mask;
            // 倒序!
            // 【坑点？】神秘不去重
            Euler::add_edge(i+1, j1+1, 1);
            Euler::add_edge(i+1, j0+1, 0);
        }
        auto [S, T] = Euler::getST();
        if(S!=-1) {
            Euler::reset();
            Euler::tp = 0;
            Euler::hierholzer(S, -1);
            // 总延伸数量 + 基础数量 - 前后缀重复
            cout << (Euler::tp - 1 + (k - 1) - (k - 1)) << " ";
            // 初始 k-1 个 0
            for (int i = 1; i <= k - 1; i++) cout << 0;
            // 跳过开头 1 个 -1 结尾 k-1 个 0
            for (int i = Euler::tp - 1; i > k - 1; i--) cout << Euler::stk[i];
        }
        cout << endl;
    }
};

struct LG_P2731{
    // 无向图 最小字典序
    const int N = 505, M = 3005;
    int n, m;
    LG_P2731() {
        cin >> m;
        vector<int> X;
        vector<array<int,3>> edge;
        for (int i = 1; i <= m; i++) {
            int u, v;
            cin >> u >> v;
            X.push_back(u);
            X.push_back(v);
            edge.push_back({u, v, i});
            edge.push_back({v, u, i});
        }
        sort(edge.rbegin(), edge.rend());
        
        sort(X.begin(), X.end());
        X.erase(unique(X.begin(), X.end()), X.end());
        auto get = [&](int x) {return lower_bound(X.begin(), X.end(), x) - X.begin() + 1;};
        
        Euler::init(X.size());
        for(auto [u, v, i]: edge) Euler::add_edge(get(u), get(v), get(v), i);
        
        auto [S, T] = Euler::getST2();
        Euler::reset();
        Euler::tp = 0;
        Euler::hierholzer2(S, S);
        for(int i = Euler::tp; i >= 1; i--) cout << X[Euler::stk[i]-1] << endl;
    }
};

struct LG_P7771 {
    LG_P7771() {
        int n, m;
        cin >> n >> m;
        Euler::init(n);
        vector<array<int,2>> edge;
        for (int i = 1; i <= m; i++) {
            int u, v;
            cin >> u >> v;
            edge.push_back({u, v});
        }
        sort(edge.rbegin(), edge.rend());
        for (auto [u, v]: edge) Euler::add_edge(u, v, v);
        auto [S, T] = Euler::getST();
        if (S == -1) {
            cout << "No" << endl;
        } else {
            Euler::reset();
            Euler::tp = 0;
            Euler::hierholzer(S, S);
            for (int i = Euler::tp; i >= 1; i--) cout << Euler::stk[i] << " ";
            cout << endl;
        }
    }
};

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    // new LG_P10950();
    // new LG_P2731();
    new LG_P7771();
}
```

