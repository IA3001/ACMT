=== #text("NEU 2026Spring（5.5）")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/NEU/2026Spring/contest05.5.md`]

===== I 校园跑

====== Problem Description

池子里有 $m$ 个数 $a \[ 1 . . m \]$，每一个数字有 $p \[ i \]$ 的概率抽到，最多可以重抽 $n$ 次，求最终能抽到的数字的最小值的期望。

数据范围：$1 lt.eq m lt.eq 2 times 10^5$，$1 lt.eq n lt.eq 10^9$

====== Solution

#strong[期望、DP、矩阵加速、eps]

见 code

#strong[踩坑]

- #strong[TLE];：还以为开到#strong[数值分析题目];写收敛来着
- #strong[UNK];：啊！
  - #strong[好久才注意到分段点的含义]
  - #strong[有限的分段点！]
  - #strong[O(1) 单调指针我给写成二分了！]
- #strong[TLE];：有时候 `double` #strong[TLE] 并#strong[不是];因为#strong[计算量大];，可能#strong[是] #strong[精度不够];，`eps` 都判定失败！！！所以开 `long double`！！！
- #strong[TLE];：#strong[eps！！！] 在处理浮点数算法（特别是计算几何、二分小数答案、期望 DP 矩阵乘法）时，#strong[为了防止计算机底层浮点误差把正确的逻辑判断给”拦截”掉，加上 `eps` 扩大一点点判定范围，是所有高分选手都会本能去写的”通常规律”。] 以后只要看到浮点数的 `>=` 或 `<=` 判定引发了离奇的超时或死循环，第一个要想到的就是加 `eps`！

====== Code

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
using DB = long double;
const DB eps = 1e-9;
const int N = 2e5 + 5;

int n, m;
struct Node{ int a,b; }no[N];
DB sp[N], spa[N];

struct Mat{
    DB a[2][2];
    Mat(){ memset(a,0,sizeof a);}
    Mat(DB a00 ,DB a01,DB a10,DB a11) {
        a[0][0] = a00;a[0][1] = a01;
        a[1][0] = a10;a[1][1] = a11;
    }
    Mat operator*(Mat o) const {
        return Mat(
            a[0][0] * o.a[0][0] + a[0][1] * o.a[1][0],
            a[0][0] * o.a[0][1] + a[0][1] * o.a[1][1],
            a[1][0] * o.a[0][0] + a[1][1] * o.a[1][0],
            a[1][0] * o.a[0][1] + a[1][1] * o.a[1][1]
        );
    }
}pmat[N][32];

void solve() {
    cin >> n >> m;
    for (int i = 1; i <= m;i++) cin >> no[i].a;
    LL S = 0;
    for (int i = 1; i <= m;i++) cin >> no[i].b, S += no[i].b;
    sort(no + 1, no + 1 + m, [](auto a, auto b){ return a.a < b.a; });
    for(int i = 1; i <= m; i++) {
        DB p = (DB) no[i].b / S;
        sp[i] = sp[i - 1] + p;
        spa[i] = spa[i - 1] + p * no[i].a;
    }
    for (int i = 1; i <= m; i++) {
        pmat[i][0] = Mat(1-sp[i], 0, spa[i], 1);
        for (int j = 1; j <= __lg(n); j++) pmat[i][j] = pmat[i][j-1] * pmat[i][j-1];
    }
    DB lst = spa[m];
    LL cur = 1;
    // 首先找到当前答案的 k 值是多少
    int k = m;
    while(k && no[k].a + eps > lst) k--; // 【eps】乐于助人 我不敢跳！
    while(cur < n && k) {
        // 然后 已经计算出 cur 现在进行扩展 
        for(int i = __lg(n); i >=0;i--) {
            if(cur + (1 << i) > n) continue;
            // 在 n 范围内倍增扩展 
            // 如果扩展后 仍然不违规 继续扩
            DB nxt = lst * pmat[k][i].a[0][0] + pmat[k][i].a[1][0];
            if(nxt + eps >= no[k].a ) { // 【eps】乐于助人 我不敢跳！
                lst = nxt;
                cur += 1 << i;
            }
        }
        // 现在走到的是 最后一个不违规的地方了 lst 正确!
        // g[cur] 此时是 >= a[k] 的 g[cur+1] < a[k]
        // 所以在计算 g[cur+2] 的时候需要注意使用新的 k
        if(cur < n && k) {
            // 如果扩展后 仍然不违规 继续扩
            DB nxt = lst * (1 - sp[k]) + spa[k];
            lst = nxt;
            cur++;
            while(k && no[k].a + eps > lst) k--; // 【eps】乐于助人 我不敢跳！
        }
    }
    cout << lst << "\n";
}

int main() {
    cout << setprecision(6) << fixed;
    cin.tie(0)->sync_with_stdio(0);
    int T = 1;
    cin >> T;
    while (T--) solve();
}

/*
设 E[i] 表示还有 i 次选择机会 期望的最短时间
则 E[0] = inf

E[i] = sum of a_i * p_i where a_i < E[i - 1] + (1 - sum of p_i where a_i <= E[i - 1]) * E[i - 1]
根据刷新次数越多 期望越小的基本原理
在这个问题中 E[i] 的大小会随着 i 的增加而不断递减 但是不会减少太多 顶多收敛于 a_i 的最小值

由于期望值会不断变小 所以当你拥有更多刷新次数后 你会更小概率的选择留下 (即小于期望的 a_i 数量会减少)
在 E[1] 的基础上 你最多可以拥有 n - 1 次刷新次数, 每一次刷新 你都希望把所有 < E[上一次] 的 a_i 保留下来, 
而剩余的情况依然 依赖于 E[上一次] 这是不断收敛的

【混蛋】 以上的推导 TLE 了 !

需要详细分析
设 f[i][j] 表示 还有 i 次选择机会 当前已经至少保证用时 <= a[j] 的最小用时期望
则 f[0][j] = a[j]
设 g[i] = sum_j f[i][j] * p[j]
则 f[i][j] = min(a[j], g[i-1])
则答案为 g[n] 
其中 g[i] = sum_j p[j] * min(a[j], g[i-1])
则 g[i] =sum_(j <= k) p[j] * a[j] + sum_(j > k) p[j] * g[i-1]
        = spa[k] + (1-sp[k]) * g[i - 1]
这意味着 g[i] 的求解 "形式" (而非答案值) 只依据 g[i-1] 在 a 数组中的排名
而这种依据(k 值) 必然是单调不增的(机会越多, 小值越少) 因此需要找到第一个 x 使得 g[x] < a[k]
这意味着 g[x] -> g[x + 1] 的过程中 g[x] 胜过了一些 a[j] 所以 k 需要减少一些
所以 k 值对应的合法求解区间为 [当前, x]
这就意味着 递推来到了一个存档点 x
对于 x + 1 的求解 需要新的 k 值先求出来
然后继续传递下去即可
注意这个矩阵 想象一下
[g[i-1], 1] * [1-sp[k] , 0]  = [g[i], 1]
              [spa[k]  , 1]
*/
```

