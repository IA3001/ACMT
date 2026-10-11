=== #text("2026“钉耙编程”中国大学生算法设计春季联赛（5）")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/HDU/2026Spring/contest05.md`]

===== 1006 牧场

====== Problem Description

在 $1000 times 1000$ 的网格上，有 $n$ 个矩形，有 $q$ 次询问，每次查询禁用某 $k_i$ 个矩形后 $p_(i \, 1) dots.h p_(i \, k)$，剩下的矩形的覆盖面积。

数据范围：

- 多测 $T lt.eq 5$
- $1 lt.eq n \, q lt.eq 10^5$
- $1 lt.eq x_(i \, 1) \, x_(i \, 2) \, y_(i \, 1) \, y_(i \, 2) lt.eq 1000$
- $1 lt.eq k lt.eq 7$ #strong[（特别注意）]

====== Solution

#strong[随机化映射、01集合压缩映射]

- 唉！！！一样的杭电，一样的随机化哈希映射
- 由于每一次的查询的数量都很少，才 7 个，所以可以枚举最终会减少的空余块的类型是怎么叠加的，总共有 $2^7 - 1$ 种叠加方式哦
- 叠加方式，你想到了什么？哈希异或叠加状态啊！所以枚举所有的异或状态，把他们减去就是答案了！

#strong[踩坑]

- #strong[WA];：由于有差分，数组没开够，就差 1，落在边界上，直接 WA 了

====== Code

```cpp
// 附加一个自定义 ULLL 哈希的板子
struct ULLLhash {
    size_t operator()(ULLL x) const {
        // 将高64位和低64位混合
        ULLL low = (ULLL)x;
        ULLL high = (ULLL)(x >> 64);
        return low ^ (high << 1);
    }
};
unordered_map<ULLL,int,ULLLhash> cnt;

while(q--) {
    int k;
    cin >> k;
    vector<int> id(k);
    for(auto& v:id) cin >> v;
    int res = tot;
    for(int s = 1; s < (1<<k);s++) {
        ULLL msk = 0;
        for (int i = 0; i < k; i++) {
            if (s >> i & 1) msk ^= h[id[i]];
        }
        if(cnt.count(msk)) res -= cnt[msk];
    }
    cout << res << " ";
}cout << "\n";
```

===== 1009 走马观花

====== Problem Description

$n$ 个点 $m$ 条无向边，每个点有 $a_i$ 点权，每条边都有边权 $w_i$。求边权最小的简单路径（边相连，没有重复的点）且满足点权之和为 $k$ 的倍数，不存在输出 -1。

数据范围：

- 多测 $T lt.eq 10$
- $2 lt.eq n lt.eq 10^4$，$1 lt.eq m lt.eq 10^4$，$2 lt.eq k lt.eq 6$，$0 lt.eq a_i lt.eq k$，$1 lt.eq w_i lt.eq 10^9$
- 没有自环和重边

====== Solution

#strong[抽屉原理、爆搜（ex）]

由于#strong[抽屉原理];：前缀和模 $k$ 的结果（含 0）必然有两个是相同的，故区间和可以为 $k$ 的倍数。

#strong[踩坑]

- #strong[UNK];：恶心的神秘#strong[爆搜复杂度];，滚出 XCPC!

====== Code

```cpp
void dfs(int u) {
    if(W >= ans) return;
    if(S % k == 0) {
        ans = W;
        return;
    }
    vis[u] = true;
    if(D < k) {
        for (auto [v, w]: e[u]) if(!vis[v]){
            D++;S+=a[v];W+=w;
            dfs(v);
            W-=w;S-=a[v];D--;
        }
    }
    vis[u] = false;
}
ans = 1e10;
D = S = W = 0;
for (int i = 1; i <= n; i++) {
    S += a[i];
    dfs(i);
    S -= a[i];
}
```

===== 1010

====== Problem Description

求

$ S \( n \, m \) = sum_(i = 1)^m phi.alt \( n times i \) med mod med p $

其中：$1 lt.eq n \, m lt.eq 10^9$，$10^8 lt.eq p lt.eq 10^9 + 7$

====== Solution

#strong[杜教筛、莫反、欧拉函数]

可以用欧拉公式的结论：$phi.alt \( a b \) = frac(phi.alt \( a \) phi.alt \( b \) gcd \( a \, b \), phi.alt \( gcd \( a \, b \) \))$，但是我想直接推：

$ sum_(i = 1)^m phi.alt \( n times i \) & = sum_(i = 1)^m frac(phi.alt \( n \) phi.alt \( i \) gcd \( i \, n \), phi.alt \( gcd \( i \, n \) \))\
 & upright("简单移项")\
 & = phi.alt \( n \) sum_(i = 1)^m phi.alt \( i \) frac(d, phi.alt \( d \)) quad upright("其中 ") d = gcd \( i \, n \)\
 & upright("现在开始改变顺序，优先枚举 ") d\
 & upright("（化简的目标可能就是优先枚举因子）")\
 & = phi.alt \( n \) sum_(d divides n) frac(d, phi.alt \( d \)) sum_(i = 1)^m phi.alt \( i \) \[ gcd \( i \, n \) = d \]\
 & upright("把约束一般化")\
 & = phi.alt \( n \) sum_(d divides n) frac(d, phi.alt \( d \)) sum_(i = 1)^m phi.alt \( i \) \[ d divides i \] \[ gcd \( i \/ d \, n \/ d \) = 1 \]\
 & upright("单位函数莫反展开")\
 & = phi.alt \( n \) sum_(d divides n) frac(d, phi.alt \( d \)) sum_(i = 1)^m phi.alt \( i \) \[ d divides i \] sum_(k divides i \/ d \, med k divides n \/ d) mu \( k \)\
 & upright("此时换元 ") T = k d upright(" 并要求 ") d divides T\
 & upright("（记住：枚举二级因子 ") d \, k d upright(" 时，优先枚举中间因子 ") T upright("，不会遗漏）")\
 & = phi.alt \( n \) sum_(d divides n) frac(d, phi.alt \( d \)) sum_(i = 1)^m phi.alt \( i \) \[ d divides i \] sum_(T divides i \, med T divides n) mu \( T \/ d \)\
 & upright("由于 ") T divides i upright(" 所以反向枚举 ") i\
 & upright("（这就是为什么要优先枚举因子，因为这样就会出现一种等差数列前缀和）")\
 & = phi.alt \( n \) sum_(T divides n) sum_(d divides T) frac(d, phi.alt \( d \)) mu \( T \/ d \) sum_(i = 1)^(floor.l m \/ T floor.r) phi.alt \( i T \) $

看到积性函数 $h \( T \) = sum_(d divides T) frac(d, phi.alt \( d \)) mu \( T \/ d \)$，一定要算一下他的素数幂处的取值啊，就比如 $p^e$。

切入点在于 $mu \( p^2 \) = 0$，而只有 $mu \( 1 \) = 1 \, mu \( p \) = - 1$：

$ h \( p \) & = frac(p, phi.alt \( p \)) mu \( 1 \) + frac(1, phi.alt \( 1 \)) mu \( p \)\
 & = frac(p, p - 1) - 1\
 & = frac(1, p - 1)\
 & = frac(1, phi.alt \( p \)) $

$ h \( p^e \) & = frac(p^e, p^(e - 1) times \( p - 1 \)) mu \( 1 \) + frac(p^(e - 1), p^(e - 2) times \( p - 1 \)) mu \( p \)\
 & = frac(p^(e - 1), p^(e - 2) times \( p - 1 \)) - frac(p^(e - 1), p^(e - 2) times \( p - 1 \))\
 & = 0 quad upright("（当 ") e gt.eq 2 upright(" 时）") $

即（$mu \( T \) eq.not 0$，不懂的自己去看质数次幂处的取值）：

$ S \( n \, m \) = sum_(T divides n \, med mu \( T \) eq.not 0) frac(phi.alt \( n \), phi.alt \( T \)) dot.op S (T \, floor.l m \/ T floor.r) $

边界条件：

$ S \( n \, 0 \) = 0 ， quad S \( 1 \, m \) = sum_(i = 1)^m phi.alt \( i \) $

#strong[踩坑]

- #strong[UNK];：这个改变#strong[求和顺序];真的是个谜！！！

====== Code

```cpp
const int N = 1e7 + 5;

int n, m, mod;
int S_phi[N], phi[N], mu[N];
map<int,int> S_phi2;
int primes[N], cntP;
int factor[N];

void init() {
    mu[1] = phi[1] = 1;
    for (int i = 2; i < N; i++) {
        if(!factor[i]) {
            primes[++cntP] = i;
            mu[i] = -1;
            phi[i] = i - 1;
        }
        for (int j = 1; j <= cntP; j++) {
            int p = primes[j];
            int ip = p * i;
            if(ip >= N) break;
            factor[ip] = p;
            if(i % p == 0) {
                mu[ip] = 0;
                phi[ip] = phi[i] * p; // 我 chovy ! 写反了
                break;
            } else {
                mu[ip] = -mu[i];
                phi[ip] = phi[i] * (p - 1);
            }
        }
    }
}

int cal_mu(int n) {
    if(n < N) return mu[n];
    int res = 1;
    for (int j = 1; j <= cntP; j++) {
        int p = primes[j];
        if(p * p > n) break;
        if(n % p == 0) {
            n /= p;
            if(n % p == 0) return 0;
            res = -res;
        }
    }
    if(n > 1) res = -res;
    return res;
}

int cal_phi(int n) {
    if(n < N) return phi[n];
    int res = n;
    for (int j = 1; j <= cntP;j++) {
        int p = primes[j];
        if(p * p > n) break;
        if(n % p == 0) {
            while(n % p == 0) n/=p; // 我 chovy
            res = res / p * (p - 1);
        }
    }
    if(n>1) res = res / n * (n - 1);
    return res;
}

// phi 的前缀和是怎么求的来着, phi * 1 (n) = id(n) 
// 1 * S(n) = n(n+1)/2 - sum_(i = 2)^(n) 1 * S(floor.l n/i floor.r) 
int cal_S_phi(int n) {
    if(n < N) return S_phi[n];
    if(S_phi2.count(n)) return S_phi2[n];
    int res = (LL) n * (n + 1) / 2 % mod;
    int j;
    for (int i = 2; i <= n; i = (j + 1)) {
        j = n / (n / i);
        res = (res - (LL) (j - i + 1) * cal_S_phi(n/i) % mod + mod) % mod;
    }
    return S_phi2[n] = res;
}

int cal_S(int n, int m) {
    if(m == 0) return 0;
    if(n == 1) return cal_S_phi(m);
    int phi_n = cal_phi(n);
    int res = 0;
    for (int T = 1; T * T <= n; T++) {
        if(n % T == 0) {
            if(cal_mu(T)) {
                int phi_T = cal_phi(T);
                int tmp = phi_n / phi_T;
                res = (res + (LL) tmp * cal_S(T, m / T) % mod) % mod; 
            }
            if(n/T != T && cal_mu(n / T)) {
                int phi_nT = cal_phi(n/T);
                int tmp = phi_n / phi_nT;
                res = (res + (LL) tmp * cal_S(n / T, m / (n / T)) % mod) % mod; 
            }
        }
    }
    return res;
}

void solve() {
    cin >> n >> m >> mod;
    S_phi2.clear();
    for (int i = 1; i < N; i++) {
        S_phi[i] = (S_phi[i-1] + phi[i]) % mod;
    }
    cout << cal_S(n, m) << "\n";
}
```

