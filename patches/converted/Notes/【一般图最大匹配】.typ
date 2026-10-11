==== #text("【一般图最大匹配】")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/Notes/【一般图最大匹配】.md`]

===== 一般图最大匹配（带花树 / Blossom Algorithm）

====== 1. 核心概念

- #strong[区别];：二分图可以用匈牙利/Dinic，一般图因为存在奇环（花），无法直接分层，必须缩环。
- #strong[核心思想];：BFS 寻找增广路，遇到奇环时，用并查集将环上所有点缩成一个外点，继续寻找增广路。
- #strong[复杂度];：$O \( n^3 \)$。适用 $n lt.eq 500$。

====== 2. 关键变量与含义

- `match[x]`：x 的匹配点。
- `pre[x]`：BFS 树上的前驱节点（增广路指向）。
- `fa[x]`：并查集数组，用于缩花。
- `vis[x]`：0=未访问，1=外点（偶数层），2=内点（奇数层）。
- `tag[x]`：LCA 求公共祖先时的时间戳。

====== 3. 核心流程

+ 枚举每个未匹配点 s 作为 BFS 起点。
+ 若遇到未匹配点 v：沿 `pre` 数组回溯，翻转匹配。
+ 若遇到外点 v（奇环）：求出 u, v 的 LCA，执行 `blossom` 缩花（并查集合并，环上内点变外点入队）。

====== 4. 代码模板（封装版）

```cpp
#include <bits/stdc++.h>
using namespace std;

struct Blossom {
    int n, timer;
    vector<vector<int>> g;
    vector<int> match, pre, fa, vis, tag, q;
    int head, tail;

    void init(int n) {
        this->n = n;
        g.assign(n + 1, {});
        match.assign(n + 1, 0);
        pre.assign(n + 1, 0);
        fa.resize(n + 1);
        vis.assign(n + 1, 0);
        tag.assign(n + 1, 0);
        q.resize(n + 1);
        timer = 0;
        head = 1, tail = 0;
    }

    void add_edge(int u, int v) {
        g[u].push_back(v);
        g[v].push_back(u);
    }

    int lca(int u, int v) {
        timer++;
        while (true) {
            if (u) {
                if (tag[u] == timer) return u;
                tag[u] = timer;
                u = fa[pre[match[u]]];
            }
            swap(u, v);
        }
    }

    void blossom(int u, int v, int x) {
        while (fa[u] != x) {
            pre[u] = v;
            v = match[u];
            if (vis[v] == 2) {
                vis[v] = 1;
                q[++tail] = v;
            }
            fa[u] = fa[v] = x;
            u = pre[v];
        }
    }

    int bfs(int s) {
        for (int i = 1; i <= n; i++) {
            fa[i] = i;
            vis[i] = pre[i] = 0;
        }
        head = 1, tail = 0;
        q[++tail] = s;
        vis[s] = 1;

        while (head <= tail) {
            int u = q[head++];
            for (int v : g[u]) {
                if (fa[u] == fa[v] || match[u] == v) continue;
                if (vis[v] == 0) {
                    pre[v] = u;
                    if (!match[v]) {
                        int cur = v;
                        while (cur) {
                            int nxt = match[pre[cur]];
                            match[cur] = pre[cur];
                            match[pre[cur]] = cur;
                            cur = nxt;
                        }
                        return 1;
                    }
                    vis[v] = 2;
                    vis[match[v]] = 1;
                    q[++tail] = match[v];
                } else if (vis[v] == 1) {
                    int x = lca(u, v);
                    blossom(u, v, x);
                    blossom(v, u, x);
                }
            }
        }
        return 0;
    }

    int max_matching() {
        int res = 0;
        for (int i = 1; i <= n; i++) {
            if (!match[i]) res += bfs(i);
        }
        return res;
    }

    int get_match(int u) {
        return match[u];
    }
};

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    cin >> n >> m;

    Blossom b;
    b.init(n);

    for (int i = 0, u, v; i < m; i++) {
        cin >> u >> v;
        b.add_edge(u, v);
    }

    cout << b.max_matching() << "\n";
    for (int i = 1; i <= n; i++) {
        cout << b.get_match(i) << " \n"[i == n];
    }
}
```

====== 5. 经典例题

- #link("https://uoj.ac/problem/79")[UOJ \#79 一般图最大匹配];：$n lt.eq 500$，求一般图最大匹配并输出匹配方案，与本模板的复杂度范围相符。
- 洛谷 P6113 的完整数据允许 $n lt.eq 1000$，超出本节模板标注的 $n lt.eq 500$ 范围；不作为这份 $O \( n^3 \)$ 模板的直接验证题。

