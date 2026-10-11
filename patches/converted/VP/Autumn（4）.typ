=== #text("VP：Autumn（4）国庆3")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/VP/Autumn（4）.md`]

===== A. Bridge

- 给定 n 个列 m+1 个行
- q 次操作
  - 1 在第 a,b a+1,b 之间建立双向传送门
  - 2 询问从 a 1 开始，向下走，最终达到的列号

====== Code

```cpp
#include<bits/stdc++.h>
using namespace std;
using ll = long long;

const int N = 1e5 + 5;

int n, m, q;
int tim;

array<int,3> op[N];

struct SegT {
    map<int,int> mp[N*4], pos[N*4];
    void initk(int i,int k) {
        if (!pos[i][k]) {
            pos[i][k] = mp[i][k] = k;
        }
    }
    void initp(int i,int p) {
        if (!mp[i][p]) {
            pos[i][p] = mp[i][p] = p;
        }
    }
    void work(int i,int k1,int k2) {
        if (i) {
            initk(i,k1);
            initk(i,k2);
            int p1 = pos[i][k1], p2 = pos[i][k2];
            swap(pos[i][k1], pos[i][k2]);
            swap(mp[i][p1],mp[i][p2]);
            if (i == 1) return;

            if (i & 1) {
                //
                // p1 -> k1 -> k2
                // p2 -> k2 -> k1
                int f = i / 2;
                int j = f * 2;
                initk(j,p1);
                initk(j,p2);
                int q1 = pos[j][p1], q2 = pos[j][p2];
                initp(f,q1);
                initp(f,q2);
                int kk1 = mp[f][q1], kk2 = mp[f][q2];
                work(f, kk1,kk2);
            } else {
                int f = i / 2;
                initp(f,p1);
                initp(f,p2);
                int kk1 = mp[f][p1], kk2 = mp[f][p2];
                work(f, kk1,kk2);
            }
        }
    }
    void Sw(int i,int l,int r,int p,int k1,int k2) {
        if (l == r) {
            work(i,k1,k2);
        } else {
            int mid = (l + r) / 2;
            if (p <= mid) {
                Sw(i*2,l,mid,p,k1,k2);
            } else {
                Sw(i*2+1,mid+1,r,p,k1,k2);
            }
        }
    }
}T;

void solve() {
    cin >> n >> m >> q;
    for (int i = 1; i <= q; i++) {
        auto& [a, b, c] = op[i];
        cin >> a;
        if (a == 1) {
            // b b + 1
            // dep = c
            cin >> b >> c;
            T.Sw(1,1,m,c,b,b+1);
        } else {
            cin >> b;
            T.initp(1,b);
            int p = T.mp[1][b];
            cout << p << "\n";
        }
    }
}

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    int T = 1;
    // cin >> T;
    while (T--) solve();
}
```

===== B. 二维网格塞数字

- 给定 n x m 网格，有空地，有障碍
- 给定 c d
- 定义用 1 - k 的数字填网格，保证每一行每一列不存在重复数字
- 求最小可能的 $c times k + d times upright("cnt")_0$

====== Code

```cpp
#include<bits/stdc++.h>
using namespace std;
using ll = long long;

const int inf = 1e9;

namespace ISAP {
    const int N = (255+255+2), M = (255*255+255+255)*2;
    struct Edge {
        int to, nxt, w;
    }e[M];
    int hd[N], cur[N], cntE;

    void add_edge(int u,int v,int w) {
        e[++cntE] = {v, hd[u], w};
        hd[u] = cntE;
        e[++cntE] = {u, hd[v], 0};
        hd[v] = cntE;
    }

    int n, s, t;
    int d[N];
    // maybe
    int gap[N*2]; 

    void init(int nn) {
        fill(hd,hd+1+n,0);
        n = nn;
        cntE = 1;
    }
    
    void bfs() {
        fill(d,d+1+n,inf);
        // maybe
        fill(gap,gap+1+n+5,0);
        queue<int> Q;
        gap[d[t] = 0]++;
        Q.push(t);
        while (Q.size()) {
            int u = Q.front(); Q.pop();
            for (int i = hd[u]; i; i = e[i].nxt) {
                int v = e[i].to, w = e[i].w;
                if (!w && d[v] > d[u] + 1) {
                    gap[d[v] = d[u] + 1]++;
                    Q.push(v);
                } 
            }
        }
    }

    int dfs(int u = s,int sum = inf) {
        // maybe 差点忘了
        if (u == t) {
            return sum;
        }
        int tk, res = 0;
        for (int& i = cur[u]; i; i = e[i].nxt) {
            int v = e[i].to, w = e[i].w;
            if (d[u] - 1 == d[v] && w) {
                tk = dfs(v, min(sum, w));
                e[i].w -= tk;
                e[i^1].w += tk;
                sum -= tk;
                res += tk;
                if (!sum) return res;
            }
        }
        // maybe 说明有剩余 需要提高势能倒流
        // maybe 某一层没了，必然导致断流
        if(!--gap[d[u]]) d[s] = n + 1;
        // maybe 高势能层计数增加
        gap[++d[u]]++;
        return res;
    }

    int cal(int ss, int tt) {
        s = ss, t = tt;
        int res = 0;
        bfs();
        while (d[s] <= n) {
            memcpy(cur,hd,sizeof(hd[0])*(n+1));
            res += dfs();
        }
        return res;
    }

    void reset() {
        for (int i = 2; i <= cntE; i+=2) {
            e[i].w += e[i^1].w;
            e[i^1].w = 0;
        }
    }
}

const int N = 255;

ll ans;
int n, m, c, d;
char mat[N][N];

void solve() {
    cin >> n >> m >> c >> d;
    
    // [1, n] 是行 [n+1,n+m] 是列
    int tot = n + m;
    int S = ++tot, T = ++tot;
    ISAP::init(tot);
    
    int z = 0;
    for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= m; j++) {
            cin >> mat[i][j];
            if (mat[i][j] == '.') {
                z++;
                ISAP::add_edge(i,n+j,1);
            }
        }
    }

    int L = ISAP::cntE;
    for (int i = 1; i <= n; i++) ISAP::add_edge(S, i, 0);
    for (int i = 1; i <= m; i++) ISAP::add_edge(n+i, T, 0);
    int R = ISAP::cntE;
    
    ans = (ll) d * z;
    for (int k = 1; k <= max(n, m); k++) {
        for (int i = L+1; i <= R; i+=2) ISAP::e[i].w++;
        int flow = ISAP::cal(S, T);
        ans = min(ans, (ll) c * k + (ll) d * (z - flow));
        ISAP::reset();
    }
    cout << ans << "\n";
}

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    solve();
}
```

