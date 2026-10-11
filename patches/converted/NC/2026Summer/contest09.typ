=== #text("2026牛客暑期多校训练营09")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/NC/2026Summer/contest09.md`]

===== F Light the Lamp【unordered\_map 预留问题 / map 动态开辟特性 / 手写 mask\_hash + 模拟 / 栈上操作】

====== Problem Description

在一个 $n$ 行 $n$ 列的网格图上，每个格子中都有一盏灯。第 $0$ 秒时，每一行、每一列都恰好有一盏灯亮着。

更具体地说，第 $i$ 行第 $p_i$ 列的灯是亮着的，其中 $p$ 是一个长度为 $n$ 的排列。

之后时间按整秒变化。对于每盏尚未亮起的灯，如果在第 $t - 1$ 秒时，与它有公共边的相邻格子中至少有两盏灯已经亮着，那么这盏灯会在第 $t$ 秒亮起。已经亮起的灯不会熄灭。

你需要判断是否所有灯最终都会亮起；如果所有灯最终都会亮起，则你还需要求出所有灯都亮起的最早时刻。

====== Input

第一行包含一个整数 $n$ ($2 lt.eq n lt.eq 5 dot.op 10^5$)。

第二行包含 $n$ 个两两不同的整数 $p_1 \, p_2 \, dots.h \, p_n$ ($1 lt.eq p_i lt.eq n$)，表示初始时第 $i$ 行第 $p_i$ 列的灯亮着。

====== Output

如果存在至少一盏灯永远不会亮起，输出 $- 1$。

否则输出一个整数，表示所有灯都亮起的最早时刻。

====== Sample Input

```txt
4
1 2 3 4
```

====== Sample Output

```txt
3
```

====== Hint

在样例 1 中，初始亮灯位于主对角线上。每一秒会向两侧扩展一格，最远的两个角落会在第 3 秒亮起。

====== Solution

#strong[题目没什么好说的，主要是被 unordered\_map 卡常了！！！！！！！！！！！]

- `unordered_map` #strong[全是缺点]
  - 默认哈希 -\> 被针对 $O \( n \)$ 对策：
    - 重载哈希（But 只支持 #strong[取模哈希];）
  - 动态扩容重哈希 -\> 被卡常 $\( > 2 倍 ， 感 觉 是 2 . .4 \)$ 对策：
    + `reserve(n * 4)`
    + `max_load_factor(0.5 ~ 0.6)`
- `map` #strong[特点]
  - 动态开点 #strong[劣势];：
    - 复杂度天生带 log
    - 套 `vector<>` 需要谨慎，常数大
  - 动态开点 #strong[优势];：
    - 相比 `unordered_map` 不需要扩容
    - 随机数据下，key 用 `long long` 时，`5e5` 数据量 `map` 比 `unordered_map` 快 $1$ 倍？？？
  - 最大的优势是 #strong[有序]
- 手写 `HashTable` #strong[全是优点]
  - 可以写 `mask_hash` 比 `mod_hash` 快（干掉 `unordered_map`）
  - 链式前向星静态空间，比几乎不能 `reserve` 的 `cc_hash_table` 好 （干掉 `cc_hash_table`）
  - 桶空间可以针对 key 值域特调（鞭尸 `cc_hash_table`）
  - 自定义哈希方便快速 （鞭尸 `cc_hash_table`）
  - 注意：
    - `mask_hash` 的自定义哈希务必做好 `mix` 保证分组均匀

#quote(block: true)[
附： HashTable
]

```cpp
// 经验： 桶大小 (1 << 20) 最佳
template<typename Key, typename Value, int MAXN = (1<<21), int BUCKET = (1<<20) >
struct StaticHashTable {
    static_assert((BUCKET & (BUCKET - 1)) == 0, "BUCKET must be a power of 2!");

    int head[BUCKET];
    Key keys[MAXN];
    Value vals[MAXN];
    int nxt[MAXN];
    int tot;
    int mask;

    StaticHashTable() {
        memset(head, -1, sizeof(head));
        tot = 0;
        mask = BUCKET - 1;
    }

    Value* end() {
        return nullptr;
    }
    
    // [env]
    // BUCKET = 1<<20 牛客 OJ
    static uint64_t mix(uint64_t x) {
        // test: 直接映射
        // 346ms, 365ms, 503ms, 324ms, 324ms, 316ms
        // return x;

        // test: 简单一次乘法
        // 440ms, 594ms, 449ms, 395ms, 379ms, 379ms, 370ms
        x ^= x >> 23;
        x *= 0x2127599bf4325c37ULL;   // 这是乘法，但若你连这个都不想有，看下方替代
        x ^= x >> 47;
        return x;

        // test: splitMix 
        // 428ms, 383ms, 389ms, 551ms, 397ms, 417ms, 464ms
        // x += 0x9e3779b97f4a7c15ULL;
        // x = (x ^ (x >> 30)) * 0xbf58476d1ce4e5b9ULL;
        // x = (x ^ (x >> 27)) * 0x94d049bb133111ebULL;
        // return x ^ (x >> 31);

        // test: 随机数 + 多次移位
        // 456ms, 496ms, 462ms, 431ms, 405ms, 415ms, 428ms
        // static const uint64_t FIXED_RANDOM = chrono::steady_clock::now().time_since_epoch().count();
        // x += FIXED_RANDOM;
        // x ^= x >> 33;
        // x ^= x << 13;
        // x ^= x >> 7;
        // x ^= x << 17;
        // x ^= x >> 25;
        // return x;
    }

    int hash(const Key& k) const {
        return int(mix(k) & mask);
    }

    Value& operator[](const Key& k) {
        int h = hash(k);
        for (int i = head[h]; i != -1; i = nxt[i]) {
            if (keys[i] == k) return vals[i];
        }
        keys[tot] = k;
        vals[tot] = Value();
        nxt[tot] = head[h];
        head[h] = tot;
        return vals[tot++];
    }

    // 返回指针，不存在返回 nullptr
    Value* find(const Key& k) {
        int h = hash(k);
        for (int i = head[h]; i != -1; i = nxt[i]) {
            if (keys[i] == k) return &vals[i];
        }
        return nullptr;
    }

    // const 版本
    const Value* find(const Key& k) const {
        int h = hash(k);
        for (int i = head[h]; i != -1; i = nxt[i]) {
            if (keys[i] == k) return &vals[i];
        }
        return nullptr;
    }
};
```

====== Code

#quote(block: true)[
Version1 map：无脑
]

```cpp
#include<bits/stdc++.h>
using namespace std;
using ll = long long;

// #define cout xxxx

const int N = 5e5 + 5;

int n_;

int p[N];

map<ll,int> fa;

inline ll id(int i,int j) {
    return (ll)(i-1) * n_ + j;
}

int tot;
bool vis[N*3];
struct Node{
    int n;
    int x,y;
    ll t00,t01,t10,t11;
    int ID;
    // Node():n(n),x(x),y(y),t00(t00),t01(t01),t10(t10),t11(t11){}
}no[N*3];

// void print(Node a) {
//     cout << "n:" << a.n << "\n";
//     cout << "x,y:" << a.x << "," << a.y << "\n";
//     cout << "t:" << a.t00 << " " << a.t01 << "\n";
//     cout << "t:" << a.t10 << " " << a.t11 << "\n";
//     cout << "ID:" << a.ID << "\n";
//     cout << "\n";
// }

Node merge(Node a, Node b) {
    int ax = a.x, ay = a.y;
    int bx = b.x, by = b.y;
    Node c;
    auto& [n,x,y,t00,t01,t10,t11, _] = c;
    // cout << "a:\n";
    // print(a);
    // cout << "b:\n";
    // print(b);
    if(a.x < b.x && a.y < b.y) {
        // 右下
        ll mx = max(a.t11, b.t00);
        n = a.n + b.n;
        x = a.x;
        y = a.y;
        t00 = a.t00;
        t11 = b.t11;
        t01 = t10 = mx + a.n + b.n - 1;
        
        t01 = max({
            t01,
            a.t01 + b.n,
            b.t01 + a.n,
        });
        t10 = max({
            t10,
            a.t10+b.n,
            b.t10+a.n
        });

    } else if(a.x < b.x && a.y > b.y) {
        // 左下
        ll mx = max(a.t10, b.t01);
        n = a.n + b.n;
        x = a.x;
        y = b.y;
        t01 = a.t01;
        t10 = b.t10;
        t00 = t11 = mx + a.n + b.n - 1;


        t00 = max({
            t00,
            a.t00 + b.n,
            b.t00 + a.n
        });

        t11 = max({
            t11,
            a.t11 + b.n,
            b.t11 + a.n
        });

    } else if(a.x > b.x && a.y < b.y) {
        // 
        swap(a, b);
        // 左下
        ll mx = max(a.t10, b.t01);
        n = a.n + b.n;
        x = a.x;
        y = b.y;
        t01 = a.t01;
        t10 = b.t10;
        t00 = t11 = mx + a.n + b.n - 1;

        t00 = max({
            t00,
            a.t00 + b.n,
            b.t00 + a.n
        });

        t11 = max({
            t11,
            a.t11 + b.n,
            b.t11 + a.n
        });

    } else {
        swap(a, b);
        // 右下
        ll mx = max(a.t11, b.t00);
        n = a.n + b.n;
        x = a.x;
        y = a.y;
        t00 = a.t00;
        t11 = b.t11;
        t01 = t10 = mx + a.n + b.n - 1;

        t01 = max({
            t01,
            a.t01 + b.n,
            b.t01 + a.n,
        });
        t10 = max({
            t10,
            a.t10+b.n,
            b.t10+a.n
        });
    }
    // cout << "c:\n";
    // print(c);
    return c;
}

void solve() {
    cin >> n_;
    queue<int> Q;
    for(int i = 1; i <= n_; i++) {
        cin >> p[i];
        no[++tot] = {1, i, p[i], 0,0,0,0,0};
        no[tot].ID = tot;
        fa[id(i, p[i])] = tot;
        Q.push(tot);
    }
    ll res = -1;

    while(Q.size()) {
        auto i = Q.front(); Q.pop();
        Node& u = no[i];

        // cout << "cur:" << i << "\n";
        // print(u);

        if(vis[u.ID]) continue;

        int n = u.n;
        int x0 = u.x, y0 = u.y;

        // auto jt = fa.find(id(x0,y0));
        
        // if(jt->second != i) continue;
        // jt = fa.find(id(x0+n-1,y0));
        // if(jt->second != i) continue;
        // jt = fa.find(id(x0,y0+n-1));
        // if(jt->second != i) continue;
        // jt = fa.find(id(x0+n-1,y0+n-1));
        // if(jt->second != i) continue;
        
        if(n == n_) {
            res = max({
                u.t00,
                u.t01,
                u.t10,
                u.t11
            });
            break;
        }

        auto it = fa.find(id(x0-1,y0-1));
        if(it!=fa.end()) {
            // cout << "LU\n";
            // 左上
            vis[no[it->second].ID] = true;

            no[++tot] = merge(u, no[it->second]);
            auto& c = no[tot];
            c.ID = tot;
            
            fa[id(c.x, c.y)] = tot;
            fa[id(c.x+c.n-1, c.y)] = tot;
            fa[id(c.x, c.y+c.n-1)] = tot;
            fa[id(c.x+c.n-1, c.y+c.n-1)] = tot;
            Q.push(tot);
                        // cout << "to:" << tot << "\n";
            // print(c);
            continue;
        }
        it = fa.find(id(x0+n,y0-1));
        if(it!=fa.end()) {
            // cout << "LD\n";

            // 左下
            vis[no[it->second].ID] = true;

            no[++tot] = merge(u, no[it->second]);
            auto& c = no[tot];
            c.ID = tot;

            fa[id(c.x, c.y)] = tot;
            fa[id(c.x+c.n-1, c.y)] = tot;
            fa[id(c.x, c.y+c.n-1)] = tot;
            fa[id(c.x+c.n-1, c.y+c.n-1)] = tot;
            Q.push(tot);
            // cout << "to:" << tot << "\n";
            // print(c);
            continue;
        }
        it = fa.find(id(x0-1,y0+n));
        if(it!=fa.end()) {
            // cout << "RU\n";
            
            // 右上
            vis[no[it->second].ID] = true;

            no[++tot] = merge(u, no[it->second]);
            auto& c = no[tot];
            c.ID = tot;

            fa[id(c.x, c.y)] = tot;
            fa[id(c.x+c.n-1, c.y)] = tot;
            fa[id(c.x, c.y+c.n-1)] = tot;
            fa[id(c.x+c.n-1, c.y+c.n-1)] = tot;
            Q.push(tot);
                        // cout << "to:" << tot << "\n";
            // print(c);
            continue;

        }
        it = fa.find(id(x0+n,y0+n));
        if(it!=fa.end()) {
            // cout << "LD\n";

            // 右下
            vis[no[it->second].ID] = true;

            no[++tot] = merge(u, no[it->second]);
            auto& c = no[tot];
            c.ID = tot;

            fa[id(c.x, c.y)] = tot;
            fa[id(c.x+c.n-1, c.y)] = tot;
            fa[id(c.x, c.y+c.n-1)] = tot;
            fa[id(c.x+c.n-1, c.y+c.n-1)] = tot;
            Q.push(tot);
                        // cout << "to:" << tot << "\n";
            // print(c);
            continue;

        }
    }

    cout << res << "\n";
} 

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    int T = 1;
    // cin >> T;
    while (T--) solve();
}
```

#quote(block: true)[
Version2 unordered\_map + reserve / max\_load\_factor
]

```cpp
// 【改动1】将 map 改为 unordered_map
unordered_map<ll,int> fa;
void solve() {
    // 【改动2】预留空间 + 降低负载因子，彻底避免 rehash 卡顿
    fa.reserve(n_ * 4);
    fa.max_load_factor(0.7);
}
```

#quote(block: true)[
Version3 手写 HashTable
]

```cpp
template<typename Key, typename Value, int MAXN = (1<<21), int BUCKET = (1<<20) >
struct StaticHashTable {
    static_assert((BUCKET & (BUCKET - 1)) == 0, "BUCKET must be a power of 2!");

    int head[BUCKET];
    Key keys[MAXN];
    Value vals[MAXN];
    int nxt[MAXN];
    int tot;
    int mask;

    StaticHashTable() {
        memset(head, -1, sizeof(head));
        tot = 0;
        mask = BUCKET - 1;
    }

    Value* end() {
        return nullptr;
    }
    
    // [env]
    // BUCKET = 1<<20 牛客 OJ
    static uint64_t mix(uint64_t x) {
        // test: 直接映射
        // 346ms, 365ms, 503ms, 324ms, 324ms, 316ms
        // return x;

        // test: 简单一次乘法
        // 440ms, 594ms, 449ms, 395ms, 379ms, 379ms, 370ms
        x ^= x >> 23;
        x *= 0x2127599bf4325c37ULL;   // 这是乘法，但若你连这个都不想有，看下方替代
        x ^= x >> 47;
        return x;

        // test: splitMix 
        // 428ms, 383ms, 389ms, 551ms, 397ms, 417ms, 464ms
        // x += 0x9e3779b97f4a7c15ULL;
        // x = (x ^ (x >> 30)) * 0xbf58476d1ce4e5b9ULL;
        // x = (x ^ (x >> 27)) * 0x94d049bb133111ebULL;
        // return x ^ (x >> 31);

        // test: 随机数 + 多次移位
        // 456ms, 496ms, 462ms, 431ms, 405ms, 415ms, 428ms
        // static const uint64_t FIXED_RANDOM = chrono::steady_clock::now().time_since_epoch().count();
        // x += FIXED_RANDOM;
        // x ^= x >> 33;
        // x ^= x << 13;
        // x ^= x >> 7;
        // x ^= x << 17;
        // x ^= x >> 25;
        // return x;
    }

    int hash(const Key& k) const {
        return int(mix(k) & mask);
    }

    Value& operator[](const Key& k) {
        int h = hash(k);
        for (int i = head[h]; i != -1; i = nxt[i]) {
            if (keys[i] == k) return vals[i];
        }
        keys[tot] = k;
        vals[tot] = Value();
        nxt[tot] = head[h];
        head[h] = tot;
        return vals[tot++];
    }

    // 返回指针，不存在返回 nullptr
    Value* find(const Key& k) {
        int h = hash(k);
        for (int i = head[h]; i != -1; i = nxt[i]) {
            if (keys[i] == k) return &vals[i];
        }
        return nullptr;
    }

    // const 版本
    const Value* find(const Key& k) const {
        int h = hash(k);
        for (int i = head[h]; i != -1; i = nxt[i]) {
            if (keys[i] == k) return &vals[i];
        }
        return nullptr;
    }
};

StaticHashTable<ll,int> fa;

void solve() {
    auto it = fa.find(id(x0-1,y0-1));
    if (it != fa.end()) {   
        int j = *it;
    }
}
```

#quote(block: true)[
Version4 根据题目特点优化计算：栈操作
]

```cpp
#include<bits/stdc++.h>
#include<ext/pb_ds/priority_queue.hpp>
using namespace std;
typedef long long ll;
typedef unsigned long long ull;
#define int ll
#define MP make_pair
#define pii pair<int,int>
const double PI=acos(-1.0);
template <class Miaowu>
inline void in(Miaowu &x){
    char c;x=0;bool f=0;
    for(c=getchar();c<'0'||c>'9';c=getchar())f|=c=='-';
    for(;c>='0'&&c<='9';c=getchar())x=(x<<1)+(x<<3)+(c^48);
    x=f?-x:x;
}
const int N=5e5+5;
int n,top;
struct Node{
    int l,r,t1,t2,t3,t4;
}a[N];
signed main(){
    in(n);
    for(int i=1,x;i<=n;i++){
        in(x);
        Node nw=Node{x,x,0,0,0,0};
        while(top&&(nw.r==a[top].l-1||nw.l==a[top].r+1)){
            if(nw.r==a[top].l-1){
                int t1=a[top].t1,t3=nw.t3;
                int t2=max(max(a[top].t3,nw.t1)+nw.r-nw.l+a[top].r-a[top].l,max(a[top].t2+nw.r-nw.l,nw.t2+a[top].r-a[top].l))+1;
                int t4=max(max(a[top].t3,nw.t1)+nw.r-nw.l+a[top].r-a[top].l,max(a[top].t4+nw.r-nw.l,nw.t4+a[top].r-a[top].l))+1;
                nw=Node{nw.l,a[top].r,t1,t2,t3,t4};
            }
            else{
                int t2=nw.t2,t4=a[top].t4;
                int t1=max(max(a[top].t2,nw.t4)+nw.r-nw.l+a[top].r-a[top].l,max(a[top].t1+nw.r-nw.l,nw.t1+a[top].r-a[top].l))+1;
                int t3=max(max(a[top].t2,nw.t4)+nw.r-nw.l+a[top].r-a[top].l,max(a[top].t3+nw.r-nw.l,nw.t3+a[top].r-a[top].l))+1;
                nw=Node{a[top].l,nw.r,t1,t2,t3,t4};
            }
            top--;
        }
        a[++top]=nw;
    }
    if(top>1)puts("-1");
    else cout<<max(max(a[1].t1,a[1].t2),max(a[1].t3,a[1].t4))<<endl;
    return 0;
}
```

