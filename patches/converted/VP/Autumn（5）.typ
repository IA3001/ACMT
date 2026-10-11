=== #text("VP：Autumn（5）国庆4")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/VP/Autumn（5）.md`]

===== C. Palindrome 【lcp 二分哈希法 - pam 求以 i 结尾的回文串】

- 给定长度为 n 的字符串，有 m 次询问
- 查询 串 `s[l...r]` 删除一个最小长度的连续字串 得到回文串
  - 求 最小长度
  - 求 方案数

#quote(block: true)[
这才意识到：

lcp 二分哈希求法的爽感

pam 确实可以求以 i 结尾的回文串
]

====== Code

```cpp
#include<bits/stdc++.h>
using namespace std;
// using ull = unsigned long long;
using ll = long long;

const ll m1 = 998244353, m2 = 1e9 + 9;
const ll base = 233;

const int N = 5e5 + 5;

struct PAM {
    int tot, lst, n, s[N], ch[N][26], fa[N], len[N];
    int st[N][21], id[N]; // 现用的
    void init() {
        memset(ch,0,sizeof(ch[0])*(tot+1));
        memset(fa,0,sizeof(fa[0])*(tot+1));
        memset(len,0,sizeof(len[0])*(tot+1));
        tot = 1; 
        lst = n = 0;
        fa[0] = 1; 
        len[1] = -1;
        s[0] = -1;
    }
    int getFail(int p) {
        for(;s[n-1-len[p]]!=s[n];p=fa[p]);
        return p;
    }
    void extend(int c) {
        s[++n] = c;
        int p = getFail(lst);
        if(!ch[p][c]) {
            len[++tot] = len[p] + 2;
            fa[tot] = ch[getFail(fa[p])][c];
            ch[p][c] = tot;
        }
        lst = ch[p][c];
        id[n] = lst; // 
    }
    // 现做的
    void build() {
        for (int i = 0; i <= tot; i++) st[i][0] = fa[i];
        for (int p = 1; p <= 20; p++) {
            for (int i = 0; i <= tot; i++) {
                st[i][p] = st[st[i][p-1]][p-1];
            }
        }
    }
}T,rT;

int n, m;
ll p1[N], p2[N];
array<ll,2> h[N], rh[N];
string s;

array<ll,2> getl(int l,int r) {
    auto [l1, l2] = h[l-1];
    auto [r1, r2] = h[r];
    r1 -= l1 * p1[r-l+1] % m1;
    r2 -= l2 * p2[r-l+1] % m2;
    if (r1 < 0) r1 += m1;
    if (r2 < 0) r2 += m2;
    return {r1, r2};
}

array<ll,2> getr(int l,int r) {
    auto [l1, l2] = rh[r+1];
    auto [r1, r2] = rh[l];
    r1 -= l1 * p1[r-l+1] % m1;
    r2 -= l2 * p2[r-l+1] % m2;
    if (r1 < 0) r1 += m1;
    if (r2 < 0) r2 += m2;
    return {r1, r2};
}

int lcpll(int i,int j) {
    int res = 0;
    int l = 1, r = min(n-i+1,n-j+1);
    while(l <= r) {
        int mid = (l + r) / 2;
        if (getl(i,i+mid-1) == getl(j,j+mid-1)) {
            res = mid;
            l = mid + 1;
        } else r = mid - 1;
    }
    return res;
}

int lcplr(int i,int j) {
    int res = 0;
    int l = 1, r = min(n-i+1,j);
    while(l <= r) {
        int mid = (l + r) / 2;
        if (getl(i,i+mid-1) == getr(j-mid+1,j)) {
            res = mid;
            l = mid + 1;
        } else r = mid - 1;
    }
    return res;
}

int lcprr(int i,int j) {
    int res = 0;
    int l = 1, r = min(i,j);
    while(l <= r) {
        int mid = (l + r ) / 2;
        if (getr(i-mid+1,i) == getr(j-mid+1,j)) {
            res = mid;
            l = mid + 1;
        } else r = mid - 1;
    }
    return res;
}

void solve() {

    cin >> n;
    cin >> s;
    
    s = " " + s;
    
    for (int i = 1; i <= n; i++) {
        h[i][0] = (h[i-1][0] * base + s[i]) % m1;
        h[i][1] = (h[i-1][1] * base + s[i]) % m2;
    }
    
    for (int i = n; i >= 1; i--) {
        rh[i][0] = (rh[i+1][0] * base + s[i]) % m1;
        rh[i][1] = (rh[i+1][1] * base + s[i]) % m2;
    }
    
    T.init();
    rT.init();
    for (int i = 1; i <= n; i++) T.extend(s[i] - 'a');
    for (int i = n; i >= 1; i--) rT.extend(s[i] - 'a');
    T.build();
    rT.build();
    
    cin >> m;
    for (int i = 1; i <= m; i++) {
        int l, r;
        cin >> l >> r;
        int lcp = lcplr(l, r);
        if (lcp >= r - l + 1) {
            cout << 0 << " " << 0 << "\n";
        } else {
            // l...L....R...r
            //      lim
            int L = l + lcp;
            int R = r - lcp;
            int lim = R - L + 1;
            int lid = rT.id[n-L+1], rid = T.id[R];
            if (rT.len[lid] > lim) {
                for (int p = 20; p >= 0; p--) {
                    if (rT.len[rT.st[lid][p]] > lim) {
                        lid = rT.st[lid][p];
                    }
                }
                lid = rT.st[lid][0];
            }
            if (T.len[rid] > lim) {
                for (int p = 20; p >= 0; p--) {
                    if (T.len[T.st[rid][p]] > lim) {
                        rid = T.st[rid][p];
                    }
                }
                rid = T.st[rid][0];
            }
            int pr = L + rT.len[lid], pl = R - T.len[rid]; 
            int len = 0, cnt = 0;
            if (rT.len[lid] == T.len[rid]) {
                // 相同 那么 删减的量就是
                len = lim - rT.len[lid];
                // 方法数是 如果 l 可以左移 
                cnt = 2 + min(lcp, lcprr(L-1,pl)) + min(lcp, lcpll(pr, R+1));
            } else if (rT.len[lid] > T.len[rid]) {
                // 左边多
                len = lim - rT.len[lid];
                // 删除右边 那么 右边计数
                cnt = 1 + min(lcp, lcpll(pr, R + 1));
            } else {
                // 右边多
                len = lim - T.len[rid];
                // 删除左边 那么 左边计数
                cnt = 1 + min(lcp, lcprr(L-1, pl));
            }
            cout << len << " " << cnt << "\n";
        }
    }
}

int main() {
    p1[0] = p2[0] = 1;
    for (int i = 1; i < N;i++) {
        p1[i] = p1[i-1] * base % m1;
        p2[i] = p2[i-1] * base % m2;
    }
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    int T = 1;
    while (T--) solve();
}
```

