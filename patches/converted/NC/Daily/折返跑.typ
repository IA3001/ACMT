=== #text("折返跑")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/NC/Daily/折返跑.md`]

#quote(block: true)[
回忆了一把 #strong[组合数 求和公式]
]

====== Code

```cpp
#include <iostream>
using namespace std;
using ll = long long;

// cao 做完才发现 不就是 n-1 分成 m 份的方案数吗
// x1 + x2 + ... + x_m = n - 1
// C(n-1-1, m - 1)

// m-1 数字满足 xi >= 1 并且 sum xi <= n-2
// x1 + x2 + ... + x_{m-1} <= n - 2
// 也就是说 (m-1 ... n-2) 个小球分成 m - 1 个非空份
// 有多少种分法 

// 不要！隔板法
// F(a, b) = C(a-1, b-1)

// sum F(m-1 ... n-2, m-1)
// sum C(m-2 ... n-3, m-2)

// 下指标求和：
// sum C(0...i, j) = C(i+1, j+1)

// 故 ans = C(n-2,m-1) - C(m-2,m-1)

const ll mod = 1e9 + 7;
const int N = 1e6 + 5;

ll ksm(ll a, ll b) {
    ll res = 1;
    for (;b;b>>=1,a=a*a%mod) if (b & 1) res = res * a % mod;
    return res;
}

ll fac[N], invfac[N];

void init() {
    fac[0] = 1;
    for (int i = 1; i < N; i++) fac[i] = fac[i-1] * i % mod;
    invfac[N-1] = ksm(fac[N-1],mod-2);
    for (int i = N-1; i >= 1; i--) invfac[i-1] = invfac[i] * i % mod;
}

ll C(int i,int j) {
    if (j > i) return 0;
    return fac[i] * invfac[j] % mod * invfac[i-j] % mod;
}

int n, m;

void solve() {
    cin >> n >> m;
    cout << (C(n-2,m-1)-C(m-2,m-1)+mod) % mod << "\n";
}

int main() {
    init();
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    int T = 1;
    cin >> T;
    while (T--) solve();
}
```

