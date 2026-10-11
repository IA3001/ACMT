=== #text("基环树")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/ALGO/基环树.md`]

#quote(block: true)[
注意到： 一个 n 个点 n 条非重边的图 = $sum 基 环 树$
]

==== P1 模板题

- `LG_P2607`
  - 给定一个 n 个点 n 条非重边的图 每一个点有点权 求最大独立集
  - 显然是若干个基环树组成的
  - 可以拆环，打家劫舍 

==== P2 基环树的绝对直径
- `LG_P1399`
  - 众所周知，边越删，直径越大
  - 注意到，基环树的直径是一条链，也是一个树链
  - 所以必然存在环上一条边，不在链上
  - 所以删掉这个边之后，对直径无影响，得到一个树，这个直径也是树的直径
  - 所以，基环树的直径，等价于删掉环上某一条边之后，能得到的最小的树的直径
  - 做法：$d i s t_i + p r e_i + d i s t_j - p r e_j$ 二倍开环 + 单调队列维护最短环路径范围内的 $max \( d i s t_j - p r e_j \)$
  - #strong[对吗？错！大错特错！]
  - 删掉一条边有多个影响的
- 如何推导出来，基环树 的 #strong[绝对直径] 等于 #strong[删掉环上某一条边之后];，#strong[剩余的树的直径的最小可能值]
  - 首先，绝对中心必然是某一简单路径的中点
  - 其次，绝对直径长度必然等于最短路树的直径
  - 然后，删掉基环树中的环上，且不在最短路树上的那条边，即可打通两者
- 所以，怎么求这个最小直径可能值
  - 1.首先，先解决不经过环的最长简单路径作为候选
  - 2.然后，枚举每一条环上的边删除，求出来所有删除可能情况下，的最小直径
  - 两者取最大值
- 显然，第 2 步难求
  - 删除边之后，就会产生一个断了环的循环链，
  - 求直径的话就不得不考虑：前面的哪个 j 和后面的哪个 i 是最匹配的，很难维护！
  - 为什么难维护？
    - 因为这个序列前面不断删除，后面不断增加，两头都在变
    - 导致不好维护
  - 有什么办法？
    - 钦定分界点！
  - 既然考虑到计算的是最大值，符合结合律
    - 如果断掉了 某个边 那么
    - 新的可能的匹配分为 3 种情况
    - 要么 前缀选一个 后缀选一个 匹配
    - 要么 前缀选 2 个
    - 要么 后缀选 2 个
    - 取 max
    - 显然就是答案
  - 复杂度 O(n)

#quote(block: true)[
我已瘫坐眩晕！！！
]

==== P3 基环树的大直径

- `LG_P4381`
  - 气笑了
  - 上一题写了半天假思路
  - 到这一题直接能用
  - #strong[不过] #strong[要重点区分] 基环树的 3 种直径
    - 绝对直径（上一题）
      - 跟直径八竿子打不着的关系
      - 有两种含义
        + 选定一个基环树内部点，可以在边上，使得内部点到最远的点的距离最短的半径的二倍
        + 删掉基环树的一条环上边，使得生成的树的直径最小，对应的直径
    - 最短路的小直径（这个在仙人掌专题有考）
    - 简单路的大直径（此题）

==== P4 动态基环树最短路

- `LG_P4949`
  - 树的亲戚：基环树，小改一下，或者用 trick 就可以搞出来
  - #strong[trcik];（未实现）：
    - 依然钦定环上的一条边 x，拆掉，变成树！！！
    - 分为过 x 与不过 x 的
      - 过 x ： 暴力分讨 x u v y / x v u y
      - 不过 x：直接树上最短路 用 树状数组维护
    - 二者取 min
  - #strong[hacked];：
    - 依然是 #strong[二元环处理] 的问题
    - 一定要注意标记边 而非标记两点啊
    - 除非这玩意绝对是一个树
  - #strong[新发现];：
    - 树状数组维护基环树的时候，必须开两个 dfn 啊！
      - 第一个是找环的
      - 第二个是从环根开始，dfn 编号的
    - 并且，树状数组可以批量维护多个树啊，就像维护森林一样啊
      - 必须注意，根节点也要差分！

==== Codes

```cpp
// 基环树 其实叫 pseudotree
#include<bits/stdc++.h>
using namespace std;
using ll = long long;


struct LG_P2607 {
    inline static const int N = 1e6 + 5;
    int n, val[N];
    ll dp[N][2];

    struct Edge {
        int to, nxt;
    }e[N*2];
    int hd[N], cntE;
    void init() {
        fill(hd,hd+1+n,0);
        cntE = 1;
    }
    void add_edge(int u,int v) {
        e[++cntE] = {v, hd[u]};
        hd[u] = cntE;
    }
    
    int dfn[N], dfncnt, v1, v2, skip;
    void dfs(int u) {
        dfn[u] = ++dfncnt;
        for (int i = hd[u]; i; i = e[i].nxt) {
            int v = e[i].to;
            if (!dfn[v]) {
                dfs(v);
            } else if (dfn[u] < dfn[v]) {
                // 发现弃边
                v1 = u, v2 = v;
                skip = i >> 1;
            }
        }
    }
    void cal(int u,int f) {
        dp[u][0] = 0, dp[u][1] = val[u];
        for (int i = hd[u]; i; i = e[i].nxt) {
            // 【进食后人！！！】
            // ban 边我用了 v1, v2 
            // 二元环我 tm 全 ban 了
            int v = e[i].to;
            if ((i >> 1) == skip || v == f) continue;
            cal(v, u);
            dp[u][0] += max(dp[v][0], dp[v][1]);
            dp[u][1] += dp[v][0];
        }
    }
    LG_P2607() {
        init();
        cin >> n;
        for (int i = 1; i <= n;i++) {
            int j;
            cin >> val[i] >> j;
            add_edge(i, j);
            add_edge(j, i);
        }
        ll ans = 0;
        for (int i = 1; i <= n; i++) {
            if (!dfn[i]) {
                dfs(i);
                cal(v1, 0);
                ll tmp = dp[v1][0];
                cal(v2, 0);
                tmp = max(tmp, dp[v2][0]);
                ans += tmp;
            }
        }
        cout << ans << "\n";
    }
};

struct LG_P1399 {
    inline static const int N = 1e5 + 5;
    int n;
    vector<pair<int,int>> e[N];
    int dfn[N], dfncnt, fromv[N], fromw[N];
    bool vis[N];
    ll ans, mx[N];
    int tmp[N];
    ll pre_max[N], suf_max[N], pre_d[N], suf_d[N];
    void get_dist(int u) {
        vis[u] = true;
        mx[u] = 0;
        for (auto [v, w]: e[u]) if (!vis[v]) {
            get_dist(v);
            ans = max(ans, mx[u] + mx[v] + w);
            mx[u] = max(mx[u], mx[v] + w);
        }
    }
    void dp(int siz, ll cycle_sum) {
        for(int i = 1; i <= siz; i++) {
            int u = tmp[i];
            get_dist(u);
        }
        // pre_max 表示 前缀 [1, i] 选一个最长的链
        // pre_d 表示前缀 [1, i] 里面选最多 2 个，最好的答案
        ll sum = 0, best = 0;
        for (int i = 1; i <= siz; i++) {
            pre_max[i] = max(pre_max[i-1], sum + mx[tmp[i]]);
            pre_d[i] = max(pre_d[i-1], mx[tmp[i]] + sum + best);
            best = max(best, mx[tmp[i]] - sum);
            sum += fromw[tmp[i]];
        }
        // suf_max 表示 后缀 [i, siz] 选一个最长的链 注意 链长
        // suf_d 表示 后缀 [i, siz] 选 最多 2 个，最好的答案
        sum = best = 0;
        suf_max[siz+1] = suf_d[siz+1] = 0;
        for (int i = siz; i >= 1; i--) {
            sum += fromw[tmp[i]];
            suf_max[i] = max(suf_max[i+1], sum + mx[tmp[i]]);
            suf_d[i] = max(suf_d[i+1], mx[tmp[i]] + sum + best);
            best = max(best, mx[tmp[i]] - sum);
        }
        // 断开的是 i 和 i+1 之间的边
        ll res = 2e18;
        for (int i = 1; i < siz; i++) {
            ll d = max({pre_max[i] + suf_max[i+1], pre_d[i], suf_d[i+1]});
            res = min(res, d);
        }
        // 断开的是 siz 和 1 之间的边
        res = min(res, pre_d[siz]);
        ans = max(ans, res);
    }
    void dfs(int u) {
        // 【我是傻逼】 dfn[u] = ++dfncnt 都不写
        dfn[u] = ++dfncnt;
        for(auto [v, w]: e[u]) {
            if (!dfn[v]) {
                fromv[v] = u;
                fromw[v] = w;
                dfs(v);
            } else if (dfn[u] < dfn[v]) {
                fromv[u] = v;
                fromw[u] = w;
                ll sum = 0;
                int idx = 0, cur = u;
                do {
                    tmp[++idx] = cur;
                    vis[cur] = true;
                    sum += fromw[cur];
                    cur = fromv[cur];
                } while(cur != u);
                dp(idx, sum);
            }
        }
    }
    LG_P1399() {
        cin >> n;
        for (int i = 1; i <= n; i++) {
            int u, v, w;
            cin >> u >> v >> w;
            e[u].push_back({v, w});
            e[v].push_back({u, w});
        }
        dfs(1);
        cout << fixed << setprecision(1) << double(ans) / 2 << "\n"; 
    }
};

struct LG_P4381 {
    inline static const int N = 1e6 + 5;
    int n;
    vector<pair<int,int>> e[N];
    int dfn[N], dfncnt, fromv[N], fromw[N];
    bool vis[N];
    ll ans, mx[N];
    // 队列属性
    int tmp[N], Q[N*2];
    ll pre[N*2], dist[N*2];
    void get_dist(int u) {
        vis[u] = true;
        mx[u] = 0;
        for (auto [v, w]: e[u]) if (!vis[v]) {
            get_dist(v);
            ans = max(ans, mx[u] + mx[v] + w);
            mx[u] = max(mx[u], mx[v] + w);
        }
    }
    void dp(int siz, ll cycle_sum) {
        ll sum = 0;
        for(int i = 1; i <= siz; i++) {
            int u = tmp[i];
            get_dist(u);
            dist[i] = dist[i+siz] = mx[u];
            pre[i] = sum;
            pre[i+siz] = sum + cycle_sum;
            sum += fromw[u];
        }
        int l = 1, r = 0;
        for(int i = 1; i <= siz * 2; i++) {
            while(l <= r && i - Q[l] >= siz) l++;
            if (l <= r) ans= max(ans, dist[i] + pre[i] + dist[Q[l]] - pre[Q[l]] );
            while(l <= r && (dist[i]-pre[i] >= dist[Q[r]] - pre[Q[r]])) r--;
            Q[++r] = i;
        }
    }
    void dfs(int u) {
        // 【我是傻逼】 dfn[u] = ++dfncnt 都不写
        dfn[u] = ++dfncnt;
        for(auto [v, w]: e[u]) {
            if (!dfn[v]) {
                fromv[v] = u;
                fromw[v] = w;
                dfs(v);
            } else if (dfn[u] < dfn[v]) {
                fromv[u] = v;
                fromw[u] = w;
                ll sum = 0;
                int idx = 0, cur = u;
                do {
                    tmp[++idx] = cur;
                    vis[cur] = true;
                    sum += fromw[cur];
                    cur = fromv[cur];
                } while(cur != u);
                dp(idx, sum);
            }
        }
    }
    LG_P4381() {
        cin >> n;
        for (int i = 1; i <= n; i++) {
            int u = i, v, w;
            cin >>  v >> w;
            e[u].push_back({v, w});
            e[v].push_back({u, w});
        }
        ll res = 0;
        for (int i = 1; i <= n; i++) {
            if (!dfn[i]) {
                ans = 0;
                dfs(i);
                res += ans;
            }
        }
        cout << res << "\n"; 
    }
};

struct LG_P4949 {
    inline static const int N = 1e6 + 5, M = 1e6 + 5;
    int n, m, uv[N][3];
    vector<pair<int,int>> e[N];
    int tr[N], tr2[N];
    void add(int* tr, int i,int v) {
        for(;i<=n+1;i+=i&-i) tr[i] += v;
    }
    int query(int* tr, int i) {
        int res = 0;
        for(;i;i-=i&-i) res += tr[i];
        return res;
    }
    int dfn[N], dfncnt, dfn2[N], dfncnt2, fromv[N], fromw[N], id[N], fa[N], sz[N], faw[N];
    int son[N], dep[N], top[N];
    int tmp[N], sum;
    void dfs(int u) {
        dfn[u] = ++dfncnt;
        for (auto [v, w]: e[u]) {
            if (!dfn[v]) {
                fromv[v] = u;
                fromw[v] = w;
                dfs(v);
            } else if(dfn[u] < dfn[v]){
                fromv[u] = v;
                fromw[u] = w;
                int cur = u, idx = 0;
                do {
                    tmp[++idx] = cur, id[cur] = idx, cur = fromv[cur]; 
                }while(cur != u);
                for (int i = 1; i <= idx; i++) {
                    setup(tmp[i], 0, i);
                    dfs2(tmp[i], tmp[i]);
                    sum += fromw[tmp[i]];
                    add(tr2, i+1, fromw[tmp[i]]);
                }
            }
        }
    }
    void setup(int u,int f, int i) {
        fa[u] = f;
        id[u] = i;
        sz[u] = 1;
        son[u] = 0;
        dep[u] = dep[f] + 1;
        for (auto [v, w] : e[u]) if (!id[v]) {
            faw[v] = w;
            setup(v,u,i);
            sz[u] += sz[v];
            if (sz[v] > sz[son[u]]) son[u] = v;
        }
    }
    void dfs2(int u,int tp) {
        dfn2[u] = ++dfncnt2;
        top[u] = tp;
        if(son[u]) dfs2(son[u],tp);
        for(auto [v,w]:e[u]) if(v!=fa[u] && id[v] == id[u] && v!=son[u]) {
            dfs2(v, v);
        }
        add(tr, dfn2[u], faw[u]);
        add(tr, dfn2[u]+sz[u], -faw[u]);
    }
    int lca(int a,int b) {
        while(top[a] != top[b]) {
            if(dep[top[a]] < dep[top[b]]) swap(a, b);
            a = fa[top[a]];
        }
        return dep[a] < dep[b] ? a : b;
    }
    LG_P4949() {
        cin >> n >> m;
        for (int i = 1; i <= n;i++) {
            int u, v, w;
            cin >> u >> v >> w;
            // 【逆天】 e[v].push_back({v, w});;
            e[u].push_back({v, w});
            e[v].push_back({u, w});
            uv[i][0] = u;
            uv[i][1] = v;
            uv[i][2] = w;
        }
        dfs(1);
        int op, x, y;
        for (int i = 1; i <= m; i++) {
            cin >> op >> x >> y;
            if (op == 1) {
                int u = uv[x][0], v = uv[x][1];
                if (fa[v] == u) swap(u, v);
                if (fa[u] == v) {
                    add(tr, dfn2[u], -faw[u]);
                    add(tr, dfn2[u]+sz[u], faw[u]);
                    faw[u] = y;
                    add(tr, dfn2[u], faw[u]);
                    add(tr, dfn2[u]+sz[u], -faw[u]);
                } else {
                    if (fromv[v] == u) swap(u, v);
                    // 【又被二元环坑了】tmd 二元环重边 不知道改哪一个
                    if (fromw[u] != uv[x][2]) swap(u, v);
                    sum -= fromw[u];
                    add(tr2,id[u]+1,-fromw[u]);
                    fromw[u] = uv[x][2] = y;
                    sum += fromw[u]; 
                    add(tr2,id[u]+1,fromw[u]);
                }
            } else {
                if (id[x] == id[y]) {
                    int z = lca(x, y);
                    int X = query(tr, dfn2[x]) - query(tr, dfn2[tmp[id[x]]]);
                    int Y = query(tr, dfn2[y]) - query(tr, dfn2[tmp[id[y]]]);
                    int Z = query(tr, dfn2[z]) - query(tr, dfn2[tmp[id[z]]]);
                    cout << (X + Y - Z * 2) << "\n";
                } else {
                    int X = query(tr, dfn2[x]) - query(tr, dfn2[tmp[id[x]]]);
                    int Y = query(tr, dfn2[y]) - query(tr, dfn2[tmp[id[y]]]);
                    int XY = abs(query(tr2, id[x]) - query(tr2, id[y]));
                    XY = min(XY, sum - XY);
                    cout << (X + Y + XY) << "\n";
                }
            }
        }
    }
};

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    // new LG_P2607();
    // new LG_P1399();
    // new LG_P4381();
    new LG_P4949();
}

```

