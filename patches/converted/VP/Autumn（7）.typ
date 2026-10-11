=== #text("VP：Autumn（7）国庆6")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/VP/Autumn（7）.md`]

===== F. 抽奖

- 给定 n 个奖金， 基础费用 c 惩罚费用 k
- 第 i 次抽奖费用 `c + k * i`
- 至少抽一次奖，并且只保留最后一次抽的奖
- 问最大收益期望

====== Solution

- #strong[一定要先写清楚递推式啊，数学公式一定要写清楚，摆明了！！！]
- #strong[然后，递归实现，永远比 主动 循环 来得简单！！！]
  - 而且，递归蕴含着要处理边界剪枝情况，引发你的思考！！！

====== Code

```cpp
#include<bits/stdc++.h>
using namespace std;
using ll = long long;
using db = double;

const int N = 4e5 + 5;

ll n, c, k;
ll a[N], suf[N];
ll mx;

// 当代价达到一定程度的时候，会走向固定值！！！
db f(int i) {
    ll ncost = c + k * (i + 1);
    if (ncost >= mx) {
        return suf[1] / db(n);
    } else {
        db nxt = f(i + 1) - ncost; // !!!
        // 有 cnt 个无法继续了, 
        auto cnt = lower_bound(a+1,a+1+n,nxt) - a - 1;
        // 因为对 nxt 与 a[j] 取 max
        return (nxt * cnt + suf[cnt+1]) / db(n);
    }
}

void solve() {
    cin >> n >> c >> k;
    for (int i = 1; i <= n; i++) cin >> a[i];
    sort(a+1,a+1+n);
    mx = *max_element(a+1,a+1+n);
    for (int i = n; i >= 1; i--) suf[i] = suf[i+1] + a[i];
    if (k == 0) {
        // 0 的时候，怎么做？
        // 这样的话，就无法收敛到固定值了怎么办？
        db ans = -2e18;
        for (int j = 1; j <= n; j++) {
            ans = max(ans, suf[n-j+1]/db(j) - c - c * (n - j) / db(j));
            // cout << j << ": " << ans << "\n";
        }
        cout << ans << "\n";
    } else {
        // 这个分隔抽奖 与 预扣款 太妙了
        cout << (f(0) - c) << "\n";
    }
}

int main() {
    cout << setprecision(9) << fixed;
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    solve();
}
```

===== K. 重复序列消除

- 给定长度为 n 的序列 s 和对应的权值 a
- 将 s, a 拷贝任意 m 份之后
- 你可以任意进行操作：
- 选择 `i < j && s[i] == s[j]`
  - 删除 `a[i+1...j], s[i+1...j]`
- 求得到的序列权值和 a 最小的权值 及其 m

====== Solution

- 这一个建图思维实在是妙
- 跟网络流建模一桌的
- 不过，好像官方题解说法太简单，
  - 还得是前缀优化建图 + 双关键字 Dijkstra

====== Code

```cpp
#include<bits/stdc++.h>
using namespace std;
using ll = long long;

const int N = 3e5 + 5;
const int V = 3e5;

int n;
int s[N];
ll a[N];
vector<int> pos[N];
int cntn;
vector<pair<int,ll>> e[N*3];

void solve() {
    cin >> n;

    // n + 1 !!!
    cntn = n + 1;

    for (int i = 1; i <= n; i++) {
        cin >> s[i];
        pos[s[i]].push_back(i);
    }

    for (int i = 1; i <= n; i++) {
        cin >> a[i];
        a[i] *= V;
    }

    for (int i = 1; i < N; i++) {
        if (pos[i].size()) {
            int pre = 0;
            for (auto p: pos[i]) {
                // 建立中介点
                int cur = ++cntn;
                if (pre) {
                    // 我支持去往前面，需要支付 (a[p] * V + 1) 费用
                    e[p].push_back({pre, a[p] + 1});
                    // cur 不仅支持去往前面
                    e[cur].push_back({pre, 0});
                }
                // 而且支持去往这里
                e[cur].push_back({p+1, 0});
                pre = cur;
            }
            pre = 0;
            for (auto p: ranges::reverse_view(pos[i])) {
                int cur = ++cntn;
                if (pre) {
                    // cur 不仅支持去往后面
                    e[cur].push_back({pre, 0});
                }
                // 而且支持去往这里
                e[cur].push_back({p+1, 0});
                pre = cur;
                // 【chovy】 pre 没连上
                // 我支持去往后面，需要支付 a[p] * V + 0 费用
                e[p].push_back({pre, a[p]});
            }
        }
    }
    // 关键字压缩在同一维： cost * V + step
    // 第一关键字：最短路
    // 第二关键字：最少跳转
    vector<ll> dist(cntn + 1, 2e18);
    vector<bool> vis(cntn + 1);
    priority_queue<pair<ll,int>> Q;
    dist[1] = 0;
    Q.push({-dist[1], 1});
    while (Q.size()) {
        auto [_, u] = Q.top(); Q.pop();
        if (vis[u]) continue;
        vis[u] = true;
        for (auto [v, w]: e[u]) {
            if (dist[v] > dist[u] + w) {
                dist[v] = dist[u] + w;
                Q.push({-dist[v], v});
            }
        }
    }
    ll cost = dist[n + 1] / V;
    ll step = dist[n + 1] % V + 1;
    cout << cost << " " << step << "\n";
}

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    int T = 1;
    // cin >> T;
    while (T--) solve();
}
```

