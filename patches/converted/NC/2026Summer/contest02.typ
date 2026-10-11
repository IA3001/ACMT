=== #text("2026牛客暑期多校训练营02")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/NC/2026Summer/contest02.md`]

===== C 比赛：连胜记录【分讨】（TODO）

====== Problem Description

小羊正在观看一场特殊的羽毛球比赛，Alice 和 Bob 正在进行对决。若将两位选手的得分记为 $x$ 和 $y$，当以下两个条件同时满足时，比赛结束：

- $max \( x \, y \) gt.eq k$，其中 $k$ 为给定参数。
- $\| x - y \| gt.eq 2$。

但不幸的是，小羊睡着了。过了相当长一段时间后，他醒来，发现比分已经大幅改变。在他睡着之前，Alice 和 Bob 的比分分别为 $x_1 \, y_1$，而当他醒来时，比分变为 $x_2 \, y_2$。在小羊睡眠期间，Alice 最长连胜长度的最小值和最大值分别是多少？

连胜是指一名选手连续赢得若干分的情况，连胜的长度为该期间赢得的分数数量。

====== Input

每个测试包含多组测试用例。第一行包含测试用例数 $T$（$1 lt.eq T lt.eq 10^4$）。接下来是每组测试用例的描述。

每组测试用例仅一行，包含五个整数 $k \, x_1 \, y_1 \, x_2 \, y_2$（$1 lt.eq k lt.eq 10^9$，$1 lt.eq x_1 < x_2 lt.eq 10^9$，$1 lt.eq y_1 lt.eq y_2 lt.eq 10^9$）------比赛参数以及小羊睡前和醒来后 Alice 和 Bob 的比分。

保证 $max \( x_1 \, y_1 \) < k$ 或 $\| x_1 - y_1 \| lt.eq 1$ 成立，且 $max \( x_2 \, y_2 \) lt.eq k$ 或 $\| x_2 - y_2 \| lt.eq 2$ 成立。即，当小羊睡着时比赛尚未结束，但当他醒来时比赛可能已经结束。

====== Output

对于每组测试用例，输出两个整数，分别表示 Alice 最长连胜长度的最小值和最大值。

====== Sample Input

```txt
4
21 1 1 10 5
21 19 20 22 21
21 16 19 21 19
21 9 12 22 20
```

====== Sample Output

```txt
2 9
2 2
5 5
2 13
```

====== Solution

#strong[超级分类讨论]

#strong[切入点：感觉是分讨的斩杀线]

====== Code

===== F 神奇的树【树形DP】

====== Problem Description

大小为 $n$ 的树是一个有 $n - 1$ 条双向边的连通图。带标签的树是指每个顶点和每条边都被赋予一个非负整数值的树。

顶点 $u$ 被赋予的值为 $a_u$，$u$ 与 $v$ 之间的边被赋予的值为 $w_(u \, v)$。若对于每对存在边的 $\( u \, v \)$，均满足

$ w_(u \, v) = \| a_u - a_v \| \, $

则称该带标签的树为神奇的树。

对于一棵树，其复杂度定义为所有顶点被赋予的值中最大值与最小值之差。

给定一棵以 $1$ 为根的带标签树，但各顶点的值缺失。对于从 $1$ 到 $n$ 的每个 $i$，若将顶点 $i$ 对应的子树的顶点赋值，使其成为一棵神奇的树，该子树的最小复杂度是多少？注意各子树的问题需独立求解。即某子树复杂度的最小化并不意味着其他子树的复杂度也一定达到最小。

顶点 $u$ 的子树包含且仅包含所有满足“从 $1$ 到 $v$ 的最短路径经过顶点 $u$”的顶点 $v$，并保留原树的连接关系。

====== Input

每个测试包含多组测试用例。第一行包含测试用例数 $T$（$1 lt.eq T lt.eq 10^4$）。接下来是每组测试用例的描述。

每组测试用例的第一行包含一个整数 $n$（$3 lt.eq n lt.eq 10^5$）------树的顶点数。

接下来 $n - 1$ 行，第 $i$ 行包含三个整数 $u_i$, $v_i$ 和 $w_(u_i \, v_i)$（$1 lt.eq u_i \, v_i lt.eq n$, $u_i eq.not v_i$, $0 lt.eq w_(u_i \, v_i) lt.eq 5000$）------树中第 $i$ 条边的两个端点及其被赋予的值。保证给定的边构成一棵树。

记 $W$ 为同一测试中所有测试用例的 $w_(u_i \, v_i)$ 最大值。保证 $n$ 的总和不超过

$ min (frac(3 times 10^7, max \( 1 \, W \)) \, med 10^5) . $

====== Output

对于每组测试用例，输出 $n$ 个整数，分别表示顶点 $1 \, 2 \, dots.h \, n$ 各自子树的最小复杂度。

====== Sample Input

```txt
3
3
1 2 1
2 3 1
4
1 2 2
2 3 1
3 4 2
5
1 2 4
1 3 1
2 4 2
2 5 1
```

====== Sample Output

```txt
1 1 0
3 2 2 0
4 2 0 0
```

====== Solution

#strong[对 定一限一 这种 dp 定义方式的重视]

#strong[这种定义的树形 DP 转移是 $O \( m \)$ 的]

#strong[父子之间取的 max 或者 min 的运算结合顺序要理清]

#strong[由于 父亲 在某一定条件下的答案，是基于所有 儿子 的答案的 RMQ]

#strong[不妨加一层 tmp 层，缓存 儿子 带给父亲的 最小 代价，这是因为上层具体一种状态，需要下层的充分布置（特别是转移条件有多种方式的时候）]

现在分析一下 该题 dp 转移的合理性

- 定义 `dp[u][i]` 表示 节点 `u` 允许下跌 `i` 大小的情况下，最小最大上升值
- 故分析从各种 `v -> u` 的转移方式
- 必然是 `u` 选定一个 `i` 让所有 `v` 布置好 #strong[自己的] 最优状态从而从各种最优状态中，选取最差（最大）的，从而在 `i` 的前提下，而容纳所有子树
  - 先说一下答案按布置方法
    - 每一个 `v` 都是为 `u` 根据 `i` 的值，提供此时可以提供的最优（最小）的答案
    - 且 每一个 `v` 在最终的答案中，只能选择一个状态
    - 故 `v` 其实是在自己的各种可能状态中，选择所有映射到对应的 `i` 的备选答案中，最优（最小）的那一个 min 即可
  - `-w` 的情况
    - 从下跌出发
    - 此时下跌至少为 `w` ，最大是 `W*2 - 1` ，故据此枚举 `i in [w, W*2 - 1)`
    - `v` 相对于 `u` 已经下跌了 `w` ，故将 `dp[v]` 的所有值，平移 `-w` 并且与 `0` 取 max，得到最大上升值
  - `+w` 的情况
    - 从上升出发
    - 此时，至少上升 `w`，最大是 `W*2 - 1`
    - 而对于下跌来说，由于有预先上升，故将 `dp[v]` 中的下跌变化值，均映射到 `-w` 并且与 `0` 取 max，故据此，依然通过枚举 `[0, W*2 - 1)` ，只不过前几和由于取 max 导致多对一的 min 竞争映射

====== Code

```cpp
#include<bits/stdc++.h>
using namespace std;

const int N = 1e5 + 5;

int n, W;
vector<pair<int,int>> e[N];
// dp[i][x] 表示 最小值与 根 i 的距离不大于 x 的时候，最大值与 根 i 的距离的最小值 
vector<int> dp[N]; 
int tmp[10001];

void dfs(int u,int f) {
    dp[u].assign(W*2, 0);
    for (auto [v,w]: e[u]) if (v != f) {
        dfs(v, u);
        fill(tmp,tmp+W*2, 1e9);
        // 这么想： 
        // tmp 是 u 的儿子们根据 u 提供的一个指标
        // 由于 u 定了，所以 v 只有一个可选状态，所以可以反复重试取 min 
        // 为父亲 提供一个 最优解 
        for (int i = w; i < W * 2; i++) {
            // 当 -w
            tmp[i] = min(tmp[i], max(0, dp[v][i-w] - w));
        }
        for (int i = 0; i < W * 2; i++) {
            // 当 +w
            int tk = max(0, i - w);
            tmp[tk] = min(tmp[tk], w + dp[v][i]);
        }
        for (int i = 0; i < W * 2; i++) {
            dp[u][i] = max(dp[u][i], tmp[i]);
        }
    }
}

void solve() {
    cin >> n;
    W = 0;
    for (int i = 2; i <= n; i++) {
        int u, v, w;
        cin >> u >> v >> w;
        W = max(W, w);
        e[u].push_back({v, w});
        e[v].push_back({u, w});
    }
    dfs(1, 0);
    for (int i = 1; i <= n; i++) {
        int ans = 1e9;
        for (int j = 0; j < W*2; j++) {
            ans = min(ans, dp[i][j] + j);
        }
        cout << ans << " ";
    }cout << "\n";
    for (int i = 1; i <= n; i++) e[i].clear();
}

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    int T = 1;
    cin >> T;
    while (T--) solve();
}
```

===== K 幼儿园【关键点动态最短路】

====== Problem Description

- 输入模式：标准输入
- 输出模式：标准输出
- 时间限制：3 秒
- 空间限制：256 MB

牛客城的天气渐渐转好，牛客幼儿园的园长准备带小朋友们去主题公园玩。

主题公园有 $n$ 个游乐设施，有 $m$ 条游乐设施之间的无向的通道。第 $i$ 个设施被称为设施 $i$，而第 $i$ 条通道连结了设施 $u_i$ 和设施 $v_i$。你没办法不使用通道从一个设施到另一个设施，同时任意两个设施是相互可达的。

一般而言，每条通道需要 $T$ 单位的时间通过。但现在在一些通道上正在进行 $k$ 个活动，使得这条路的通行时间变得不一致。第 $i$ 个活动发生在第 $w_i$ 条通道上，而当小朋友到达公园时，需要 $c_i$ 单位的时间去通过这条通道。

在活动的进行过程中，通过通道的时间也可能发生改变。总共有 $q$ 次更新，第 $i$ 次中，第 $x_i$ 条通道的通行时间变为了 $y_i$。这里保证，$x_i$ 是曾经发生过活动的街道。

更新是累积且持久的，即前面更新所做的修改将在所有后续的更新和询问中持续生效。

在每次更新后，小朋友会提出 $L_i$ 个问题：从 $a$ 到 $b$ 需要多少时间呢？你能帮忙回答这些问题吗？

====== Input

测试样例由多行组成。

第一行包含三个整数 $n \, m \, T$（$3 lt.eq n lt.eq 2 times 10^3$，$n - 1 lt.eq m lt.eq 10^5$，$1 lt.eq T lt.eq 10^6$）------设施个数、通道个数以及一般而言通道需要的通行时间。

接下来 $m$ 行中的第 $i$ 行包含两个整数 $u_i \, v_i$（$1 lt.eq u_i \, v_i lt.eq n$，$u_i eq.not v_i$）------第 $i$ 条通道的两个端点。可能有重边。

接下来的一行包含一个整数 $k$（$1 lt.eq k lt.eq 50$）------在进行活动的通道数量。

接下来 $k$ 行中的第 $i$ 行包含两个整数 $w_i \, c_i$（$1 lt.eq w_i lt.eq m$，$1 lt.eq c_i lt.eq 10^9$）------有活动的通道的下标及其通行时间。保证 $forall 1 lt.eq i < j lt.eq k \, med w_i eq.not w_j$。

接下来的一行包含一个整数 $q$（$1 lt.eq q lt.eq 2 times 10^4$）------更新的次数。

每次更新由多行组成。以下是更新的格式。

第一行包含两个整数 $x_i \, y_i$（$x_i in { w_1 \, w_2 \, dots.h \, w_k }$，$1 lt.eq y_i lt.eq 10^9$）------更新的通道的下标及其新的通行时间。

接下来的一行包含一个整数 $L_i$（$1 lt.eq L_i lt.eq 10^4$）------小朋友提出的问题的个数。

接下来 $L_i$ 行中的第 $j$ 行包含两个整数 $a_j \, b_j$（$1 lt.eq a_j \, b_j lt.eq n$）------小朋友提出的问题对应的两个端点。

保证 $L_i$ 的和不超过 $2 times 10^4$。

====== Output

对于每个小朋友提出的问题，输出一个正整数，表示从 $a_j$ 走到 $b_j$ 所需的最小时间。

====== Sample Input

```txt
4 4 1
1 2
2 3
1 3
1 4
3
1 1
2 2
3 100
3
2 5
1
3 4
3 1
1
3 4
1 5
1
3 4
```

====== Sample Output

```txt
7
2
2
```

====== Solution

- #strong[中介集群 思想]
  - #strong[需要建立一个新的图！]
  - #strong[动态维护他们之间的边权的时候，需要平衡树维护最小值！]
  - 就是说少量的 $k lt.eq 50$ 的 关键边/点，可以另外建立一个新的图加速转移
  - 使用朴素的 Dijkstra 即可
- #strong[图算法复建]
  - #strong[全源 01-BFS] 的复杂度是 $O \( n \( n + m \) \)$
    - 必须使用 邻接表，不可以用邻接矩阵，否则是 $O \( n^3 \)$
  - #strong[新：两张图，特殊点之间的正向/反向映射]
    - `mp[N]` `pm[K]`
  - #strong[新：重边动态选取最小边权的数据结构]
    - `multiset<LL> cand`

====== Code

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;

const int N = 2e3 + 5, M = 1e5 + 5, NN=2e2+5;
const LL inf = 1e15;

int n, m, T, k, q;

// 初始边集
// 【坑点1：这里的数组大小一定要开对啊！！！】，有多个 constant
array<int,3> uv[M];

// 图0 / 图1 边集
// 【坑点2：这里原图一定要开邻接表啊】
// 【全源BFS最短路 邻接表是O(n(n+m))，临界矩阵是 O(n^3)】
// LL g0[N][N];
vector<int> e0[N];
LL g1[NN][NN];

// 图0 <-> 图1 点映射
int mp[N], pm[NN], tot;

// 图0：不变最短路
LL dist[N][N];

// 辅助：图1 动态边权最小值候选
// 【坑点3】这里的边，最好开 LL 以防弄混
multiset<LL> cand[NN][NN];

void solve() {

    cin >> n >> m >> T;
    
    // for (int i = 1; i < N; i++) 
    //     fill(g0[i], g0[i]+N, inf);
    for (int i = 1; i < NN;i++) 
        fill(g1[i], g1[i]+NN,inf);
    
    // 存储所有边
    for (int i = 1; i <= m; i++) {
        auto& [u, v, _] = uv[i];
        cin >> u >> v;
    }
    
    // 读取关键边
    cin >> k;
    for (int i = 1; i <= k; i++) {
        int id, cost;
        cin >> id >> cost;
        uv[id][2] = cost;
    }

    // 根据是否关键边，加入合适的图0/1
    for (int i = 1; i <= m; i++) {
        auto [u, v, w] = uv[i];
        if (!w) {
            // 非关键
            // g0[u][v] = g0[v][u] = min(g0[u][v], w);
            e0[u].push_back(v);
            e0[v].push_back(u);
        } else {
            // 关键，先映射端点
            if (!mp[u]) mp[u] = ++tot, pm[tot] = u;
            if (!mp[v]) mp[v] = ++tot, pm[tot] = v;
            u = mp[u], v = mp[v];
            if (u > v) swap(u, v);
            cand[u][v].insert(w);
            g1[u][v] = g1[v][u] = min(g1[u][v], (LL)w);
        }
    }

    // 图0 BFS 得到 dist[i][j]
    for (int s = 1; s <= n; s++) {
        fill(dist[s],dist[s]+1+n,inf);
        
        queue<int> Q;
        Q.push(s);
        
        vector<bool> vis(n+1);
        vis[s] = true;
        
        // 分层 BFS
        int d = 0;
        while(Q.size()) {
            int t = Q.size();
            while(t--) {
                int u = Q.front(); Q.pop();
                // 坑点 3
                dist[s][u] = (LL) d * T;
                for (auto v:e0[u]) {
                    if (!vis[v]) {
                        Q.push(v);
                        vis[v] = true;
                    }
                }
            }
            d++;
        }
    }

    // 【坑点3：没有写关键点之间的 dist 初始化啊啊啊】
    for (int i = 1; i <= tot;i++) {
        for (int j = i+1; j <=tot;j++) {
            int u = pm[i], v = pm[j];
            cand[i][j].insert(dist[u][v]);
            g1[i][j] = g1[j][i] = min(g1[i][j], dist[u][v]);
        }
    }
    
    // 计算函数 O(k^2) 朴素 dijkstra
    auto cal = [&](int s, int t)-> LL {
        // 先设置为不经过特殊边
        LL res = dist[s][t];
        
        // dijk 初始化
        vector<LL> d(tot + 1, inf);
        vector<bool> vis(tot + 1);
        
        // 初始化映射位置的 d (注意枚举小的！)
        for (int i = 1; i <= tot; i++) 
            d[i] = dist[s][pm[i]];
        
        // 每次寻找 d 最小的 !vis
        while(1) {
            int best = -1;
            LL mn = inf;
            for (int i = 1; i <= tot; i++) {
                if (!vis[i] && d[i] < mn) {
                    mn = d[i];
                    best = i;
                }
            }
            if (best == -1) break;
            vis[best] = true;
            // 松弛
            for (int i = 1; i <= tot; i++) 
                if (!vis[i])
                    d[i] = min(d[i], mn + g1[best][i]);
        }

        // 同样枚举小的，回溯 图0 上面的全源静态距离
        for (int i = 1; i <= tot; i++) 
            res = min(res, d[i] + dist[pm[i]][t]);
        
        return res;
    };

    // 回答询问
    cin >> q;
    for (int i = 1; i <= q; i++) {
        int x, y;
        cin >> x >> y;
        // cout << "x=" << x << "y=" << y << "\n";
        
        // 找到边
        auto [u, v, _] = uv[x];
        u = mp[u], v = mp[v];
        if (u > v) swap(u, v);
        
        // 更新图1 边权（注意需要动态维护集合最小值）
        cand[u][v].erase(cand[u][v].find(uv[x][2]));
        uv[x][2] = y;
        cand[u][v].insert(uv[x][2]);
        g1[u][v] = g1[v][u] = *cand[u][v].begin();
        
        int L;
        cin >> L;
        for (int i = 1; i <= L; i++) {
            int a, b;
            cin >> a >> b;
            cout << cal(a, b) << "\n";
        }
    }
}

int main() {
    ios::sync_with_stdio(0);
    cin.tie(0); cout.tie(0);
    int T = 1;
    // cin >> T;
    while (T--) solve();
}
```

===== L 懒得打乱【逆序对 / 拓扑排序方案数】

====== Problem Description

小羊被分配了一个打乱长度为 $n$ 的排列的任务。一个排列就是一个长度为 $n$ 的包含 $1 \, 2 \, dots.h \, n$ 中的数各一次的序列。

小羊的领导会通过比较打乱前后数组的逆序对数量来评价小羊的工作。也就是说，我们定义一个排列 $A = \[ A_1 \, A_2 \, dots.h \, A_n \]$ 的逆序对数量为

$ f \( A \) = sum_(1 lt.eq i < j lt.eq n) upright(bold(1))_(A_i > A_j) \, $

而打乱前后的排列分别是 $A$ 和 $A'$。那么，小羊的领导会计算

$ g \( A \, A' \) = \| f \( A \) - f \( A' \) \| $

来检查小羊的工作。领导希望这个数值越大越好。

但小羊是个懒人。他不想真的好好打乱数组，所以他决定使用一个长度为 $n$ 的排列 $p = \[ p_1 \, p_2 \, dots.h \, p_n \]$，这样，当他工作中遇到一个排列 $A = \[ A_1 \, A_2 \, dots.h \, A_n \]$ 的时候，他就可以提交

$ f_p \( A \) = \[ A_(p_1) \, A_(p_2) \, dots.h \, A_(p_n) \] $

作为他的工作成果。可以证明 $f_p \( A \)$ 也是一个排列。

小羊认为一个排列是幸运的，当且仅当如果他使用上述的“打乱方法”的话，这个排列 $A$ 能最大化 $g \( A \, f_p \( A \) \)$。也就是说，对于任意一个长度为 $n$ 的排列 $A_0$，都有

$ g \( A \, f_p \( A \) \) gt.eq g \( A_0 \, f_p \( A_0 \) \) . $

那么有多少幸运的排列呢？鉴于答案可能很大，请将结果关于 $998244353$ 取模后输出。

注意，当 condition 成立时，$upright(bold(1))_(upright("condition"))$ 等于 $1$，否则等于 $0$。

====== Input

输入包含两行。

第一行包含一个整数 $n$ ($1 lt.eq n lt.eq 22$) --- 排列的长度。

第二行包含 $n$ 个整数 $p_1 \, p_2 \, dots.h \, p_n$ ($1 lt.eq p_i lt.eq n$) --- 小羊用于打乱 $A$ 的排列 $p$。保证 $forall 1 lt.eq i < j lt.eq n \, med p_i eq.not p_j$。

====== Output

输出一个整数，表示幸运的排列的数量关于 $998244353$ 取模的结果。

====== Sample Input

#strong[Sample 1]

```txt
3
3 1 2
```

#strong[Sample 2]

```txt
3
3 2 1
```

====== Sample Output

#strong[Sample 1]

```txt
4
```

#strong[Sample 2]

```txt
2
```

====== Solution

#strong[嗅到答案一定与逆序对有关！]

#strong[根据题目，找出来答案变化的原因，结合逆序对]

- 根据题目中，#strong[最] 值个数，发现
  - 分析 $p_i \, p_j$ 两个下标位置的置换，只有下标产生逆序对才有前后交换 $plus.minus 1$。
- 提出猜想
  - 所有满足同一类的逆序对，最值个数都相同
  - 所有的逆序对一定可以贡献同向
- 根据逆序对约束限制，可以构建出一个 DAG 图，这是一个关于大小偏序约束的图
  - 显然，DAG 图的解的数量等于其拓扑排序的方案数，因为可以一个个填
  - 同样根据 $n lt.eq 22$ 的数据量提示，发现只能使用 #strong[状压DP] 计算 每一个子集完成排序的方案数.

====== Code

```cpp
#include<bits/stdc++.h>
using namespace std;

const int N = 22;
const int mod = 998244353;

int n, p[N];

int f[(1<<N) + 1];
int pre[N];

void solve() {
    cin >> n;
    for (int i = 0 ; i < n; i++) {
        cin >> p[i];
        p[i]--;
    }
    bool flg = true;
    for (int i = 0 ; i < n; i++) {
        int mx = -1;
        for (int j = i+1;j  < n;j++) {
            if (p[i] > p[j] && p[j] > mx) {
                flg = false;
                pre[j] |= 1 << i;
                mx = p[j];
            }
        }
    }
    f[0] = 1;
    for (int s = 0; s < (1 << n); s++) {
        if (f[s])
        for (int j = 0; j < n; j++) {
            if (s >> j & 1^1) {
                if (pre[j] == (pre[j] & s)) {
                    (f[s | (1 << j)] += f[s]) %= mod;
                }
            }
        }
    }
    if (flg) {
        f[(1 << n) - 1] = (long long) f[(1 << n) - 1] * ((mod + 1) / 2) % mod;
    }
    cout << 2 * f[(1 << n) - 1] % mod << "\n";
}

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    int T = 1;
    // cin >> T;
    while (T--) solve();
}
```

