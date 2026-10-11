=== #text("VP：Autumn（8）国庆7")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/VP/Autumn（8）.md`]

===== A. 华容道

- 给定 n x m 的网格
- 消除 L 需要先消除左侧的所有字符
  - R U D 以此类推
- 对于每一个网格，打印消除这个字符的最小代价
  - 不存在打印 -1

====== Code

```cpp
#include<bits/stdc++.h>
using namespace std;
#define ll long long

const int N = 5e4 + 5;

ll n,m;
string s[50010];

vector<vector<int>> id;
int cntn;

vector<int> e[N];

bitset<N> val[N];

bool vis[N];
bool dp[N];
bool ins[N];

void add_edge(int u,int v) {
    if (!u || !v) return;
    e[u].push_back(v);
}

int NM;

bool dfs(int u) {
    if (vis[u]) return dp[u];
    vis[u] = true;
    ins[u] = true;
    for (auto v : e[u]) {
        if (ins[v]) {
            dp[u] = false;
            ins[u] = false;
            return dp[u];
        }
        bool dpv = dfs(v);
        if (!dpv) {
            dp[u] = false;
            ins[u] = false;
            return dp[u];
        }
        val[u] |= val[v];
    }
    ins[u] = false;
    return dp[u];
}

inline void solve()
{
    cin>>n>>m;

    for (int i = 1; i <= n; i++) {
        cin >> s[i];
        s[i] = " " + s[i];
    }

    cntn = n * m;
    NM = n * m;

    for (int i = 1; i <= NM; i++) val[i].set(i);

    id = vector<vector<int>> (n+2,vector<int>(m+2));

    for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= m; j++) {
            id[i][j] = (i-1) * m + j;
        }
    }

    for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= m; j++) {
            char c = s[i][j];
            int u = id[i][j];
            int v;
            int x = i, y = j;
            if (c == 'L') {
                y--;
                while(y >= 1) {
                    add_edge(u, id[x][y]);
                    if (s[x][y] == 'L') break;
                    else y--;
                }
            } else if (c == 'U') {
                x--;
                while(x >= 1) {
                    add_edge(u, id[x][y]);
                    if (s[x][y] == 'U') break;
                    else x--;
                }
            } else if (c == 'R') {
                y++;
                while(y <= m) {
                    add_edge(u, id[x][y]);
                    if (s[x][y] == 'R') break;
                    else y++;
                }
            } else {
                x++;
                while(x <= n) {
                    add_edge(u, id[x][y]);
                    if (s[x][y] == 'D') break;
                    else x++;
                }
            }
        }
    }
    
    fill(vis,vis+1+cntn,false);
    fill(dp,dp+1+cntn,true);
    for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= m; j++) {
            bool f = dfs(id[i][j]);
            if (f) {
                cout << val[id[i][j]].count() << " ";
            } else cout << -1 << " ";
        }
        cout << "\n";
    }
    
    for (int i = 1; i <= cntn; i++) {
        val[i].reset();
        e[i].clear();
    }
}
int main()
{
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    int T=1;
    cin>>T;
    while (T--) solve();
}
```

