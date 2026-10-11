=== #text("Tracker-区间增量与单点求值（SegmentTree / BIT）")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/NC/Daily/区间增量与单点求值.md`]

#quote(block: true)[
忘了 BIT 也能处理 区间增加+单点查询 了
]

```cpp
/*
代码里 切换一下注释就可以切换 SegmentTree / BIT
*/
#include <bits/stdc++.h>
using namespace std;
using LL = long long;

const int N = 5e5 + 5;

int n, q;
LL a[N];

namespace SegmentTree{
    LL sum[N*4], tadd[N*4];
    void up(int i) {
        sum[i] = sum[i*2] + sum[i*2+1];
    }
    void build(int i, int l,int r,LL* a) {
        tadd[i] = 0;
        if(l==r) {
            sum[i] = a[l];
        } else {
            int mid = (l + r) / 2;
            build(i*2, l,mid, a);
            build(i*2+1, mid+1,r, a);
            up(i);
        }
    }
    void lazy_add(int i,int n,LL v) {
        tadd[i] += v;
        sum[i] += v*n;
    }
    void down(int i, int ln, int rn) {
        if(tadd[i]) {
            lazy_add(i*2, ln, tadd[i]);
            lazy_add(i*2+1, rn, tadd[i]);
            tadd[i] = 0;
        }
    }
    void add(int i,int l,int r,int jl,int jr, LL v) {
        if(jl<=l&&r<=jr) {
            lazy_add(i,r-l+1,v);
        } else {
            int mid = (l + r) / 2;
            down(i, mid-l+1,r-mid);
            if (jl <= mid) add(i*2, l, mid, jl, jr, v);
            if (jr > mid) add(i*2 + 1, mid+1, r, jl, jr, v);
            up(i);
        }
    }
    LL query(int i,int l,int r,int jl,int jr) {
        if(jl<=l&&r<=jr) {
            return sum[i];
        } else {
            int mid = (l + r) / 2;
            down(i, mid-l+1,r-mid);
            LL res = 0;
            if(jl<=mid) res += query(i*2,l,mid,jl,jr);
            if(jr>mid) res += query(i*2+1,mid+1,r,jl,jr);
            return res;
        }
    }
}

namespace BIT{
    int n;
    LL tr[N];
    void add(int i,LL v) {
        for(i++;i<=n;i+=i&-i) tr[i] += v;
    }
    void range_add(int l,int r,LL v) {
        add(l, v);
        add(r+1, -v);
    }
    void build(int _n,LL * a) {
        n = _n + 2;
        fill(tr,tr+1+n,0);
        for (int i = 1; i <= _n;i++) {
            range_add(i,i,a[i]);
        }
    }
    LL query(int i) {
        LL res = 0;
        for(i++;i;i-=i&-i) res += tr[i];
        return res;
    }
}

void solve() {
    cin >> n >> q;

    for (int i = 1; i <= n;i ++) cin >> a[i];
    
    // SegmentTree::build(1,1,n,a);
    BIT::build(n, a);
    for (int i = 1; i <= q; i++) {
        int op, l, r, x;
        cin >> op;
        if (op == 1) {
            cin >> l >> r >> x;
            // SegmentTree::add(1,1,n,l,r,x);
            BIT::range_add(l,r,x);
        } else {
            cin >> x;
            // cout << SegmentTree::query(1,1,n,x,x) << "\n";
            cout << BIT::query(x) << "\n";
        }
    }
}

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    int T = 1;
    // cin >> T;
    while (T--) solve();
}
// 64 位输出请用 printf("%lld")
```

