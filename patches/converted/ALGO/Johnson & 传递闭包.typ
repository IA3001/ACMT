=== #text("Johnson 全源最短路 & 传递闭包")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/ALGO/Johnson & 传递闭包.md`]

==== 讲解：Johnson

#box(image("../../assets/posts/ALGO/assets/Johnson & 传递闭包/file-20261002210524054.png"))

==== P1 Johnson 模板题

- `LG_P5905`
  - 求 n 个点，m 个边可以带负权， 求全源最短路

==== 讲解：传递闭包

#quote(block: true)[
不用说，是位运算优化版的 Floyd $O \( n^3 / w \)$
]

- 话说，传递闭包不就是可达性矩阵吗

==== P2 - P3 传递闭包模板题

- `LG_B3611`
  - 给定 n 个点，和一个 n x n 邻接矩阵
  - 求 传递闭包 矩阵
- `LG_P4306`
  - 给定 n 个点，和一个 n x n 临界矩阵
  - 求 可达点对数量

==== P4 - P5 拓扑排序 不动点 / 确定性排名 & 拓展

- `LG_P2419`
  - 其实是给定一个 DAG 图，求固定拓扑排序不动点的数量
- 猜出来一个结论：
  - 这由于是一个 DAG 图，所以反图的传递闭包可以拓扑求
  - 确实是一种优化，这好像求了反图的闭包，因为是拓扑依赖关系

```cpp
// 如果一个点是关键点
// 那么 出队时的依赖集 严格等于出队时的历史
// 为什么需要传递闭包，因为计数必须去重
// 出队时的历史数量（好算） == 出队时的依赖集（需要去重，所以需要传递闭包）
```

- 卧槽，还有一个更妙的方法，根据定义啊！：
  - 一个排名确定，当且仅当 $比 他 大 的 + 比 它 小 的 = n - 1$
  - 正向传递闭包 + 反向传递闭包
  - 有关系，就可以比较大小！
  - 没有关系，就无法比较大小！！！！
- `LG_P2881`
  - 在原题的基础上，询问了至少需要几次询问，才可以保证所有排名都确定
  - 这个真就只能按照传递闭包来了
  - 我的理解
    - 既然至少的话，我觉得任意两点之间不确定的都要进行一次吧
    - 所以，碰到一个 i j / j i 对没有关系就 ++
  - 全对！

==== P6 传递闭包的 Floyd 属性：桥序

- `AT_abc287_h`
  - 给定 n 个点， m 个有向边！q 次询问
  - 询问 s -\> t 路径上最小最大编号
- TLE 之后才意识到
  - Floyd 居然有这样的性质
  - 题目也暗示了：
    - 有这种 max 可以分开两端和中间来求的！

==== P7 传递闭包 - 判断是否全序（臭暴力题目）

#quote(block: true)[
再次被 `new XXX()` 坑了 大坑特坑 再也不相信 new 出来的数据的安全性了
]

- `LG_P1347`
  - n \<= 26 个变量 m 个约束逐个给出

#quote(block: true)[
问了 AI 我最后好像被 windows 坑死了
]

```cpp
struct XXX {  
T f[N];  
T* g;  
XXX () {} // 空构造手动覆写 
};  
```

如果你像上面那样，覆写了 空构造方法， \
这样的结构体，你 new XXX(); 得到的对象在 windows 上，如果 N 很大（占用大），那么 f g 都清零，否则 f g 不清零， \
如果想在 windows 上跑通，就必须注释掉 空构造，或者手动设置初始化值 比如 T\* g = NULL;

我本地调试的时候，恰好最后一题是一个小数据量的题目， N 小， windows 不给我清零， debug 半天

如果这时候交上去，其实可以 AC， 因为 OJ 是 Linux。 \
我专门测试了 Linux ，发现无论是大空间还是小空间，无论是否覆写空构造， Linux 的 new XXX(); 的所有数据都是初始化为 0 的；

==== Codes

===== P1 Johnson 模板

```cpp
#include<bits/stdc++.h>
#include<bits/extc++.h>
using namespace std;
using ll = long long;

template<class T>
using PQ = __gnu_pbds::priority_queue<T>;

const int N = 3e3 + 5, M = 6e3 + 5;
const ll INF = 1e9;

int n, m;

vector<pair<int,int>> e[N];

// 最短路
ll h[N];
// spfa
bool inq[N];
// 判断负环
int vis[N];

bool spfa() {
    queue<int> Q;
    for (int i = 1; i <= n; i++) {
        h[i] = 0;
        vis[i] = 1;
        Q.push(i);
        inq[i] = true;
    }
    while (Q.size()) {
        auto u = Q.front(); Q.pop();
        inq[u] = false;
        for (auto [v, w]: e[u]) {
            if (h[v] > h[u] + w) {
                if (++vis[v] > n) {
                    return false; // 发现负环
                }
                h[v] = h[u] + w;
                if (!inq[v]) {
                    Q.push(v);
                    inq[v] = true;
                }
            }
        }
    }
    return true;
}

ll dist[N][N];
// 有了这玩意，就不需要 vis 了~~~
// 但是 好像又得需要 inq 了~~~~~~~~~~~~~
PQ<pair<ll,int>>::point_iterator pit[N];

void dijk(int s, ll* dist) {
    PQ<pair<ll,int>> Q;
    fill(dist,dist+1+n,INF);
    fill(inq,inq+1+n,false);
    dist[s] = 0;
    pit[s] = Q.push({-0, s});
    inq[s] = true;
    while (Q.size()) {
        auto [d, u] = Q.top(); Q.pop();
        // 这里就不需要 vis 了
        inq[u] = false;
        d = -d;
        for (auto [v, _w]: e[u]) {
            // 注意嗷！！！ 这里的 w 要改良！！！
            ll w = _w + h[u] - h[v];
            if (dist[v] > d + w) {
                dist[v] = d + w;
                if (!inq[v]) {
                    // 没有入队，正常来
                    pit[v] = Q.push({-dist[v], v});
                    inq[v] = true;
                } else {
                    // 入队了，使用强大的 modify
                    Q.modify(pit[v], {-dist[v], v});
                }
            }
        }
    }
}

// 【加一层接口是对的】
ll dis(int i,int j) {
    return dist[i][j] == INF ? INF : dist[i][j] - h[i] + h[j];
}

struct LG_P5905 {
    LG_P5905() {
        cin >> n >> m;
        for (int i = 1; i <= m; i++) {
            int u, v, w;
            cin >> u >> v >> w;
            e[u].push_back({v, w});
        }
        if (!spfa()) {
            cout << -1 << "\n";
            return;
        }
        for (int i = 1; i <= n; i++) {
            dijk(i, dist[i]);
        }
        for (int i = 1; i <= n; i++) {
            ll sum = 0;
            for (int j = 1; j <= n; j++) {
                sum += dis(i, j) * j;
            }
            cout << sum << "\n";
        }
    }
};

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    new LG_P5905();
}
```

===== P2-P3 传递闭包 模板

```cpp
#include<bits/stdc++.h>
using namespace std;

const int N = 100 + 5;

int n;
bitset<N> dp[N];

void floyd() {
    for (int j = 1; j <= n; j++) {
        for (int i = 1; i <= n; i++) {
            if (dp[i][j]) {
                dp[i] |= dp[j];
            }
        }
    }
}

struct LG_B3611 {
    LG_B3611() {
        cin >> n;
        for (int i = 1; i <= n; i++) {
            bool b;
            for (int j = 1; j <= n; j++) {
                cin >> b;
                dp[i].set(j, b);
            }
        }
        floyd();
        for (int i = 1; i <= n; i++) {
            for (int j = 1; j <= n; j++) {
                cout << dp[i][j] << " ";
            }cout << "\n";
        }
    }
};

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    new LG_B3611();
}
```

===== P4 - P5 拓扑排序 不动点 / 确定性排名 & 拓展

```cpp
#include<bits/stdc++.h>
using namespace std;

const int N = 101;
const int M = 5e3 + 5;


template<int N>
struct Closure {
    bitset<N> dp[N];
    void floyd(int n) {
        for (int j = 1; j <= n; j++) {
            for (int i = 1; i <= n; i++) {
                if (dp[i][j]) {
                    dp[i] |= dp[j];
                }
            }
        }
    }
};

// 我的猜想是 如果一个点是关键点 
// 那么 出队时的依赖集 严格等于出队时的历史
// 【还真是！！！】
// 我终于懂了
// 为什么需要传递闭包，因为计数必须去重
// 出队时的历史数量（好算） == 出队时的依赖集（需要去重，所以需要传递闭包）
struct LG_P2419 {
    inline static const int N = 101;
    Closure<N>* T;
    int n, m;
    LG_P2419() {
        T = new Closure<N>();
        cin >> n >> m;
        vector<vector<int>> e(n + 1);
        vector<int> in(n + 1);
        for (int i = 1; i <= m; i++) {
            int u, v;
            cin >> u >> v;
            e[u].push_back(v);
            in[v]++;
        }
        queue<int> Q;
        bitset<N> his;
        for (int i = 1; i <= n; i++) {
            if (!in[i]) {
                his.set(i);
                T->dp[i].set(i);
                Q.push(i);
            }
        }
        int ans = 0;
        while(Q.size()) {
            auto u = Q.front(); Q.pop();
            ans += his == T->dp[u];
            for (auto v: e[u]) {
                T->dp[v] |= T->dp[u];
                if (!--in[v]) {
                    his.set(v);
                    T->dp[v].set(v);
                    Q.push(v);
                }
            }
        }
        cout << ans << "\n";
    }
};

struct LG_P2419_2 {
    inline static const int N = 101;
    Closure<N>* T;
    int n, m;
    LG_P2419_2() {
        T = new Closure<N>();
        cin >> n >> m;
        for (int i = 1; i <= m; i++) {
            int u, v;
            cin >> u >> v;
            T->dp[u].set(v);
        }
        T->floyd(n);
        vector<int> cnt(n + 1);
        for (int i = 1; i <= n; i++) {
            for (int j = i + 1; j <= n; j++) {
                if (T->dp[i][j] || T->dp[j][i]) {
                    cnt[i]++;
                    cnt[j]++;
                }
            }
        }
        int ans = 0;
        for (int i = 1; i <= n; i++) ans += cnt[i] == n - 1;
        cout << ans << "\n";
    }
};

// 【1e9/64】 神力！
struct LG_P2881 {
    inline static const int N = 1001;
    Closure<N>* T;
    int n, m;
    LG_P2881() {
        T = new Closure<N>();
        cin >> n >> m;
        for (int i = 1; i <= m; i++) {
            int u, v;
            cin >> u >> v;
            T->dp[u].set(v);
        }
        T->floyd(n);
        int ans = 0;
        for (int i = 1; i <= n; i++) {
            for (int j = i+1; j <= n; j++) {
                ans += (!T->dp[i][j] && !T->dp[j][i]);
            }
        }
        cout << ans << "\n";
    }
};

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    // new LG_P2419();
    // new LG_P2419_2();
    new LG_P2881();
}
```

===== P6 传递闭包的 Floyd 性质

```cpp
#include<bits/stdc++.h>
using namespace std;

const int inf = 1e9;

int q;
array<int,3> query[100005];

template<int N>
struct Closure {
    bitset<N> dp[N];
    void floyd(int n) {
        for (int j = 1; j <= n; j++) {
            for (int i = 1; i <= n; i++) {
                if (dp[i][j]) {
                    dp[i] |= dp[j];
                }
            }
            // 在我使用 魔改 Floyd TLE 之前
            // 没想到，真的没想到
            // 关于 Floyd 的这个 桥 的连通顺序
            // 原来跟最小生成树差不多啊
            for (int i = 1; i <= q; i++) {
                auto& [s,t,_] = query[i];
                if (dp[s][t]) {
                    if (!_) _ = max(j, max(s,t));
                } 
            }
        }
    }
};

struct AT_abc287_h {
    inline static const int N = 2e3 + 1;
    Closure<N>* T;
    int n, m;
    AT_abc287_h() {
        T = new Closure<N>();
        cin >> n >> m;
        for (int i = 1; i <= m; i++) {
            int u, v;
            cin >> u >> v;
            T->dp[u].set(v);
        }
        cin >> q;
        for (int i = 1; i <= q; i++) {
            auto& [s,t,_] = query[i];
            cin >> s >> t;
        }
        T->floyd(n);
        for (int i = 1; i <= q; i++) {
            cout << (query[i][2] ? query[i][2] : -1) << "\n";
        }
    }
};

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    new AT_abc287_h();
}
```

===== P7 传递闭包 - 判断是否全序

```cpp
#include<bits/stdc++.h>
using namespace std;

template<int N>
struct Closure {
    bitset<N> dp[N];
    void floyd(int n) {
        for (int j = 1; j <= n; j++) {
            for (int i = 1; i <= n; i++) {
                if (dp[i][j]) dp[i] |= dp[j];
            }
        }
    }
};

struct LG_P1347 {
    inline static const int N = 27;
    // 【我 chovy】 new 出来的 T 是脏的！！！ 必须手动 = NULL 
    Closure<N>* T = NULL;
    int n, m;
    array<int,2> edge[601];
    string ans;
    LG_P1347() {
        // T = NULL;
        assert(T == NULL);
        cin >> n >> m;
        for (int I = 1; I <= m ;I++) {
            auto& [u, v] = edge[I];
            char A,_,C;
            cin >> A >> _ >> C;
            
            u  = A - 'A' + 1;
            v = C - 'A' + 1;

            if (T) delete T;
            T = new Closure<N>();
            
            for (int j = 1; j <= I; j++) {
                auto [u, v] = edge[j];
                T->dp[u].set(v);
            }
            T->floyd(n);

            int cnt = 0;
            vector<int> small(n + 1);
            for (int i = 1; i <= n; i++) {
                if (T->dp[i][i]) {
                    ans = "Inconsistency found after " + to_string(I) + " relations.";
                    cout << ans << "\n";
                    return;
                }
                for (int j = 1 ; j <= n; j++) {
                    cnt += T->dp[i][j];
                    small[j] += T->dp[i][j];
                }
            }

            // 等于组合数，必然是齐全的
            if (cnt == n * (n - 1) / 2) {
                ans = "Sorted sequence determined after " + to_string(I) + " relations: ";
                vector<int> ord(n);
                iota(ord.begin(),ord.end(),1);
                sort(ord.begin(),ord.end(),[&](int a,int b) {
                    return small[a] < small[b];
                });
                for(auto v: ord) ans += 'A' + v - 1;
                ans += ".";
                cout << ans << "\n";
                return;
            }
        }
        ans = "Sorted sequence cannot be determined.";
        cout << ans << "\n";
    }
};

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    new LG_P1347();
}
```

