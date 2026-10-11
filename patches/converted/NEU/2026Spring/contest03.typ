=== #text("NEU 2026Spring（3）   # TODO: 占位，待补官方场次名")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/NEU/2026Spring/contest03.md`]

===== G 我愿将扫描线称为一种数据结构

====== Problem Description

（2026 中山大学校赛 G）见 code

====== Solution

#strong[扫描线、树状数组、按位计算]

见 code

#strong[踩坑]

- #strong[TLE];：可持久化线段树常数太大了
- #strong[IDEA];：不妨使用#strong[扫描线] + #strong[树状数组];！神仙 CP

====== Code

```cpp
// 权值 异或 树状数组
struct BIT {
    int n;
    vector<int> tr;
    void init(int n) {
        this->n = n + 1;
        tr.assign(n + 2, 0);
    }
    void add(int i) {
        for(i++; i <= n; i += i & -i) tr[i] ^= 1;
    }
    int query(int i) {
        int res = 0;
        for(i++; i; i -= i & -i) res ^= tr[i];
        return res;
    }
}T;

int n, k;
int a[N];
int ans[N]; // 装答案

struct Query {
    int d, l, r, id;
}q[N]; // 查询

struct Event {
    int t, p;
    bool operator<(const Event& o) const {
        return t < o.t;
    }    
}e[N*10];
int cntE;

void solve() {
    cin >> n >> k;
    for (int i = 1; i <= n; i++) {
        cin >> a[i];
    }
    for (int i = 1; i <= k; i++) {
        auto& [d, l, r, id] = q[i];
        id = i;
        cin >> d >> l >> r;
    }
    // 按位计算 
    for(int bit = 0; bit < 17; bit++) {
        // 来到第 bit 位
        // 它们的 周期为 T = 2^(bit+1) 
        // 半周期为 t = 2^bit
        // 由于我们只看第 bit 位 所以大端就无视
        // 只看小端即 %T 之后还能存活的时间
        // 这里是快速模 T 的 MASK
        int MASK = (1 << (bit + 1)) - 1;
        sort(q + 1, q + 1 + k,[MASK](const Query& a,const Query& b){
            return (a.d & MASK) < (b.d & MASK);
        });
        // 这里是 t 的 mask
        int mask = (1 << bit) - 1;
        cntE = 0;
        for (int i = 1; i <= n; i++) {
            int b = a[i] >> bit & 1;
            int ttl = a[i] & mask;
            if (b) {
                // 当前是 1 那么从 [0, ttl] 和 [ttl + t + 1, T) 都是 1
                // 由于初始是 0 所以需要在 0, ttl + 1, ttl + t + 1 三个位置加事件
                e[++cntE] = {0, i};
                e[++cntE] = {ttl + 1, i};
                e[++cntE] = {ttl + (mask + 1) + 1, i};
            } else {
                // 当前是 0 那么从 [ttl + 1, ttl + 1 + t - 1] 都是 1
                // 那么需要在 ttl + 1, ttl + 1 + t - 1 + 1 这两个位置加事件
                e[++cntE] = {ttl + 1, i};
                e[++cntE] = {ttl + 1 + (mask + 1) - 1 + 1, i};
            }
        }
        sort(e+1,e+cntE+1);
        T.init(n); // n 个位置
        int t_q = 1, t_e = 1;
        for(int i = 0; i <= MASK; i++) {
            while(t_e <= cntE && e[t_e].t == i) {
                T.add(e[t_e].p); // 施加事件
                t_e++;
            }
            while(t_q <= k && (q[t_q].d & MASK) == i) {
                ans[q[t_q].id] |= (T.query(q[t_q].r) ^ T.query(q[t_q].l - 1)) << bit; // 施加询问
                t_q++;
            }
        }
    }
    for (int i = 1; i <= k; i++) {
        cout << ans[i] << "\n";
    }
}
/*
题目说 
有 n 个值域为 [0, 2^17) 的数字 a_i
有 k 个操作 
每个操作有三个参数 d 和 [l, r]
表示要查询 [l, r] 区间内 所有的数字全部减 d 之后的异或和
每次查询都是独立的 求每次查询的答案 (不强制在线)

所以这个题显然是按位计算的 
但是 "卡常" 
扫描线最 NB

对于每一位 我们要在 O(2^(bit+1)) 周期长度 "时间" 内计算出答案 
第 bit 位上 数值的视图变化
因为需要查询区间异或和 所以需要一个区间查询结构
显然使用树状数组 
由于每一个元素 a_i 的 "视图值" 在这段时间内的变化次数最多 3 次
所以 每一位的扫描 复杂度是 O(2^(bit+1) + 3 n log n + k log n)
总的复杂度大概是 
17 * (2^17 + 3 n log n + k log n)
*/
```

