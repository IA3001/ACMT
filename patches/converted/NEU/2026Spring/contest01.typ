=== #text("NEU 2026Spring（1）")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/NEU/2026Spring/contest01.md`]

===== I 数字子数组排序和

====== Problem Description

求一个 `[1, 9]` 的字符串的所有子串排序后的数字之和。

数据范围：$1 lt.eq n lt.eq 5 times 10^5$

====== Solution

#strong[主动贡献法]

见 code

#strong[踩坑]

- #strong[UNK];：见 code

====== Code

```cpp
void solve() {
    string s;
    cin >> s;
    n = s.size();
    for (int i = 1; i <= n; i++) a[i] = s[i - 1] - '0';
    vector<int> le(11), low(11);
    int sum = 0, ans = 0;
    for (int i = 1; i <= n; i++) {
        int d = a[i];
        // 首先 <= d 的数字都乘以 10
        for (int j = 1; j <= d; j++) {
            sum = (sum - le[j] + mod) % mod;
            le[j] = (le[j] * 10LL) % mod;
            sum = (sum + le[j]) % mod;
        }
        // 自带的一个 d 也要加上 
        // 然后 加上为 d 准备的权值 + 1
        low[d] = (low[d] + 1) % mod;
        int delta = (LL) d * low[d] % mod;
        le[d] = (le[d] + delta) % mod;
        sum = (sum + delta) % mod;
        // 然后 为将来所有 < d 的元素 都乘以10加 10 
        for (int j = 1; j < d; j++) {
            low[j] = (low[j] * 10LL + 10) % mod;
        }
        for (int j = d + 1; j <= 9; j++) {
            low[j] = (low[j] + 1) % mod;
        }
        ans = (ans + sum) % mod;
    }
    cout << ans << "\n";
}
/*
这是一种主动维护前缀贡献的方式
类似插入排序
但是被新 item 可插入点 卡了好久
*/
```

===== M 从多个商店买货

====== Problem Description

见 code

====== Solution

#strong[根号分治、SOS DP];（DS 竟然说这不是 SOS DP）

见 code

#strong[踩坑]

- #strong[UNK];：竟然没有发现 250 开根号是 16 ?!!
- #strong[IDEA];：没事开开根！！！

====== Code

```cpp
const LL INF = 0x3f3f3f3f3f3f3f3f;
const int N = 16;
int r, c;
LL a[300][300];
LL d[300];
LL f[2][(1 << N) + 1][2];
LL mn[300];
void solve() {
    cin >> r >> c;
    for (int i = 0; i < r; i++) {
        for (int j = 0; j < c; j++) {
            cin >> a[i][j];
        }
    }
    for (int i = 0; i < c; i++) cin >> d[i];
    LL ans = INF;
    if (r <= 16) { // 商品数量有限
        memset(f, 0x3f, sizeof f); // 全部 INF
        f[0][0][0] = 0; // 基础情况 不买 不花钱
        // 【疑问】 这里的指针可以吗
        auto f0 = f[0], f1 = f[1]; // f0 -> f1
        for (int i = 0; i < c; i++) { // 枚举商家
            auto deli = d[i]; // 商家的运费
            for (int j = 0; j < r; j++) { // 枚举商品
                auto cost = a[j][i]; // 商品价格
                for (int s = 0; s < (1 << r); s++) { // 枚举目标商品状态
                    if (s >> j & 1) { // 目标商品是由于在这里购买而得到
                        f1[s][1] = min({ // 取 原始最小值, 第一次买, 第 n 次买 中的最小值 
                            f1[s][1], 
                            f0[s ^ (1 << j)][0] + cost + deli, 
                            f1[s ^ (1 << j)][1] + cost // 这里是 self DP 由于本 DP 数值仅由小到大递推 所以正确 
                        });
                    }
                }
            }
            // 要么不买用的是f0的0, 要么买用的是 f1的1 
            for (int s = 0; s < (1 << r); s++) {
                f1[s][0] = min(f0[s][0], f1[s][1]);
            }
            memset(f0, 0x3f, sizeof f[0]);
            swap(f0, f1);
        }
        ans = min(f0[(1 << r) - 1][0], f0[(1 << r) - 1][1]);
    } else {
        for (int s = 1; s < (1 << c); s++) {
            fill(mn, mn + r, INF);
            LL res = 0;
            for (int b = 0; b < c; b++) {
                if (s >> b & 1) {
                    res += d[b];
                    for (int i = 0; i < r; i++) {
                        mn[i] = min(mn[i], a[i][b]);
                    }
                }
            }
            for (int i = 0; i < r; i++) res += mn[i];
            ans = min(ans, res);
        }
    }
    cout << ans << "\n";
}
/*
有 r 个商品 c 个商店
第 i 个商品在第 j 个商店卖 a_(i,j) 
每一个商店有基础运费 d_j
问购买所有商品的最小代价
r * c <= 250
【没看出来】这个 250 不就是 16 的平方吗 根号分治啊

1. r <= 16 的时候 商品个数较少 
所以状压商品拥有集合 SOS dp 啊
为了解决同一个商家购买的运费问题，我们在一个商家处一次买够
那么 只需要枚举 c 个商家 每次更新 可能的购买集合? 
还是不行 状态转移得平方了 为了处理这个运费 尝试换一种方法 加一维 [2] 表示在当前商店买过或者没买过
那么只需要分别枚举要买的 r 个商品 针对 0 -> 1 1 -> 1 转移不久可以了
然后 上一步的各种买了和没买中的最小值 赋值到下一个商店的没买就可以了 

2. c <= 16 的时候 商家个数少
所以只需枚举最终包含的商家集合即可 取它们之中目标商品的最小值来买
这种情况不需要再设 dp 结构了
*/
```

