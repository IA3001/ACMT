=== #text("2026“钉耙编程”中国大学生算法设计春季联赛（9）")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/HDU/2026Spring/contest09.md`]

===== 1003 玉米式概率

====== Problem Description

已知 $f \( x \) = upright("随机一个") \[ 1 \, 2 x \] upright("中的整数")$。

给定 $n$，已知初始 $x = 1$，求不断进行操作 $x arrow.l f \( x \)$ 直到 $x gt.eq n$，求期望操作次数。

数据范围：$1 lt.eq n lt.eq 10^6$

====== Solution

#strong[另类线性方程组解法、类树上随机游走、基准变量法]

- 设 $E \[ i \]$ 表示当前为 $i$ 时所需要进行的期望操作次数
- 则

$ E \[ k \] = cases(delim: "{", 1 + frac(1, 2 k) sum_(i = 1)^(2 k) E \[ i \] & k < n, 0 & k gt.eq n) $

- 你发现这显然是一个线性方程组，但是不对！数据量怎么 1e6？
- #strong[线性方程组];特别的性质：任意一个#strong[未知数];一定可以用其中的#strong[若干未知数];及其#strong[线性组合] + 常数表示
- 于是需要一个#strong[中介] $S$ 充当求解线性方程组的基底
- 观察方程组，发现大部分的地方 $E \[ 1 . . . n \]$ 重复出现，于是选取 $S = E \[ 1 . . . n \]$
- 过程：
  - 设 $E \[ k \] = a \[ k \] + b \[ k \] times S$
  - 因为递推式

$ E \[ k \] & = 1 + frac(1, 2 k) \( S - E \[ 2 k + 1 . . . n \] \)\
arrow.r.double E \[ k \] & = 1 + frac(1, 2 k) \( S - a \[ 2 k + 1 . . . n \] - b \[ 2 k + 1 . . . n \] times S \)\
arrow.r.double E \[ k \] & = (1 - frac(a \[ 2 k + 1 . . . n \], 2 k)) + frac(1 - b \[ 2 k + 1 . . . n \], 2 k) times S $

- 所以系数 $a \, b$：

$ cases(delim: "{", a \[ k \] = b \[ k \] = 0 & k gt.eq n, a \[ k \] = 1 - frac(a \[ 2 k + 1 . . . n \], 2 k) \, & b \[ k \] = frac(1 - b \[ 2 k + 1 . . . n \], 2 k)) $

- 而

$ S = sum_(i = 1)^n E \[ i \] = a \[ 1 . . . n \] + b \[ 1 . . . n \] times S arrow.r.double S = frac(a \[ 1 . . . n \], 1 - b \[ 1 . . . n \]) $

- 最终

$ E \[ 1 \] = a \[ 1 \] + b \[ 1 \] times S $

#strong[踩坑]

- #strong[UNK];：真的从来不知道原来高斯消元是这样换元、改变目标，从而化简的

====== Code

```cpp
fill(E,E+1+n,0);
fill(a,a+1+n,0);fill(b,b+1+n,0);
fill(sa,sa+1+n,0);fill(sb,sb+1+n,0);
for (int k = n-1;k >=1 ;k--) {
    a[k] = (1 - (2*k+1 <= n ? sa[2*k+1] : 0) * ksm(2*k) % mod + mod) % mod;
    b[k] = (1 - (2*k+1 <= n ? sb[2*k+1] : 0) + mod) * ksm(2*k) % mod;
    sa[k] = (sa[k+1] + a[k]) % mod;
    sb[k] = (sb[k+1] + b[k]) % mod;
}
S = sa[1] * ksm((1 - sb[1] + mod) % mod) % mod;
cout << (a[1] + b[1] * S % mod) % mod << "\n";
```

===== 1006 玉米式象棋

====== Problem Description

给定 $- 10^9 lt.eq u \, v lt.eq 10^9$，$0 lt.eq x \, y lt.eq 10^9$，设 $f \( x \, y \) = u x + v y$，你可以做任意次操作：

- $Delta = \( - 2 \, + 1 \)$
- $Delta = \( + 1 \, - 2 \)$

且始终要保证 $x \, y gt.eq 0$。

求可以得到的最小的 $f$ 值。

====== Solution

#strong[坐标系求直线极值、二维凸包极值关键点、不变量快速分析]

- 发现这个东西他的可达凸包轮廓是：
  - 要么不动
  - 要么一直往一个方向，遇到 1 可以微调
  - 要么尽量靠近 $\( 0 \, 0 \)$ 位置
- 可惜 $\( 0 \, 0 \)$ 位置附近会比较难，因为有 $x \, y gt.eq 0$ 的约束
- 但是！注意到 $Delta$ 变化的规律，它有#strong[不变量] $Delta x - Delta y equiv 0 med mod med 3$，所以通过这个可以快速缩小判定的 $\( 0 \, 0 \)$ 附近位置的范围，并且 `check` 方法是有效的，不受 $x \, y gt.eq 0$ 的约束！

#strong[踩坑]

- #strong[WA];：就是因为这个 $\( 0 \, 0 \)$ 附近的边界问题，我不知道怎么求解这个#strong[小小的偏移]
  - 使用随机扰动？多测炸了！
  - 使用手动偏移？没偏移对！

====== Code

```cpp
bool check(LL x, LL y) {
    // 假设 进行了 a次 -2 +1 b次 +1 -2 可以达到 -x, -y
    // 2a - b == x, 2b - a == y
    // 3a = 2x + y, 3b = x + 2y
    return (2*x + y) % 3 == 0 && (x + 2*y) % 3==0 && (2*x+y)>=0 && (x+2*y)>=0;
}
void cal(LL a, LL b) { ans = min(ans, a * u + b * v); }
void solve() {
    cin >> n >> k >> u >> v;
    LL x = k - 1, y = n - k;
    ans = 2e18;cal(x, y);
    int mode = ((x - y) % 3 + 3) % 3;
    if (mode == 0) {
        // 1 1 / 3 0 / 0 3
        if(check(x-1,y-1)) cal(1, 1);
        if(check(x-3,y)) cal(3, 0);
        if(check(x,y-3)) cal(0, 3);
    } else if(mode == 1) {
        // 1 0 / 0 2
        if(check(x-1,y)) cal(1, 0);
        if(check(x,y-2)) cal(0, 2);
    } else if(mode == 2) {
        // 2 0 / 0 1
        if(check(x-2,y)) cal(2, 0);
        if(check(x,y-1)) cal(0, 1);
    }
    LL tx = x, ty = y;
    LL tk = x/2;x-=tk*2;y+=tk;cal(x,y);
    if(x && y >=2) x--,y--;cal(x,y);
    x = tx, y = ty;tk = y/2;y-=tk*2;x+=tk;cal(x,y);
    if(y && x >=2) x--,y--;cal(x,y);
    cout << ans << "\n";
}
```

