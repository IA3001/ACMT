=== #text("Codeforces Round 1900")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/CF/1900.md`]

===== D 基于小值域的GCD对之和的快速维护

====== Problem Description

见 code

====== Solution

#strong[莫比乌斯反演、GCD、欧拉筛]

见 code

#strong[踩坑]

- #strong[UNK];、#strong[TLE]

====== Code

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N = 8e4 + 5;
const int V = 1e5 + 5;

int n;
int a[N];

int factor[V];
int primes[V], cntP;
int phi[V];
int cnt[V];
vector<int> ch[V];

void init() {
    phi[1] = 1;
    for (int i = 2; i < V; i++) {
        if (!factor[i]) {
            primes[++cntP] = factor[i] = i;
            phi[i] = i - 1;
        }
        for (int j = 1; j <= cntP; j++) {
            int p = primes[j];
            int v = p * i;
            if (v >= V) break;
            factor[v] = p;
            if (i % p) {
                // 啊啊啊 这里是第一次
                phi[v] = phi[i] * (p - 1);
            } else {
                phi[v] = phi[i] * p;
                break;
            }
        }
    }
    for (int i = 1; i < V; i++) {
        for (int j = i; j < V; j+= i) {
            ch[j].push_back(i);
        }
    }
}

void solve() {
    for (int i = 1; i < V; i++) cnt[i] = 0;
    cin >> n;
    LL ans = 0;
    LL sum = 0;
    for (int i = 1; i <= n; i++) {
        cin >> a[i];
    }
    sort(a + 1, a + 1 + n);
    for (int i = 1; i <= n; i++) {
        ans += sum;
        for (auto d: ch[a[i]]) {
            sum += (LL) phi[d] * cnt[d];
            cnt[d]++;
        }
    }
    cout << ans << "\n";
}

int main() {
    init();
    cin.tie(0)->sync_with_stdio(0);
    int T = 1;
    cin >> T;
    while (T--) solve();
}

/*
这个题是求 i < j < k  sum(gcd_of_min2(a[i], a[j], a[k])) 
显然是 枚举 最大值, 然后 它代表 的答案就是所有的 <= 它 的所有的两两 gcd 之和 
直接排序暴力计算 n^2 高达 4e9 (被 e4 骗了) 

还是得回归数学(莫比乌斯反演): n = sum_(d | n) phi(d)
所以: gcd(a[i], a[j]) = sum_(d | a[i] && d | a[j]) phi(d) 
枚举项为 d | x, 和 d | a[j] 注意到这个依赖关系与 phi(d) 的重复统计
转化为: = sum_(d | a[i]) phi(d) * cnt[d | a[j]] 
即 枚举 a[i] 的 O(sqrt(a[i])) 个因子 d 求 sum(phi(d) * cnt[d的倍数])

问题来了, 老了, 欧拉函数不会算了

欧拉函数的计算是什么来着 有一个公式 质因数分解的 
n * 每有一种 p 就 乘以 (p-1)/p 来着是吗
想想 如果一个数是质数 那么函数值为 p - 1, 
如果再乘以一个 p 就是 除了 p 2*p 3*p ... p*p 这 p 个数 其他的都可以 即 p^2 - p = p*(p - 1) 
如果再乘一个 就是 p^3 - p^3/p = p^3 - p^2 = p^2(p - 1) = p^3(1 - 1/p)
推导得到 phi(p^n) = p^n * (1 - 1/p) 
由于它是积性函数 所以 乘起来就是 phi(n) = n * (1 - 1/p_1) * (1 - 1/p_2) * ... * (1 - 1/p_k)
所以 它的计算方式显然是 它本身 转化一次所有的 出现过的 质数集合的 p -> p - 1
即 如果是第一个质数 就乘以 p - 1 否则就乘以 p!!!
欧拉筛怎么写来着???
要维护一个质数集合
遍历所有的质数 相乘产生新数
直到遇到它的最小质因子就结束 是吗
在遇到最小质因子之前，一定是互质的
所以 这个数的phi 和 这个质数的phi 的乘积 = 新数的 phi
难道第一个最小质因子也要计算? 好像有这个意思
第一个最小质因子 显然是 这个数的phi 直接乘以这个质数 = 新数的 phi
那么 w^5p^3q^2 这种的 phi 是如何求得的呢  
我想 显然 它是由 它的必然的前驱 w^4p^3q^2 乘以 w 得到的这样就追溯到
wp^3q^2 这个数必然是通过它的前驱 p^3q^2 乘以 w (它的phi为w-1) 得到的
p^3q^2 这个数 就不必我说了吧 
*/
```

