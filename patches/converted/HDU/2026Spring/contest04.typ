=== #text("2026“钉耙编程”中国大学生算法设计春季联赛（4）")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/HDU/2026Spring/contest04.md`]

===== 1003 通行证（Hard Version）

====== Problem Description

给定 $n times n$ 方阵 $a$，外围 $4 n + 4$ 个人构成 $\( n + 2 \) times \( n + 2 \)$ 的方阵 $b$。$a_(i \, j)$ 为 $a$ 中第 $i$ 行第 $j$ 列的识别码，$b$ 中其余人的识别码均为 $10^100$。

对于通行证 $upright("card")$，识别码 $x$ 满足 $\( x divides upright("card") \) eq.not upright("card")$ 的人为坏蛋。$a$ 中每个人从上下左右四个方向检查途径的人（含自身），该方向最近坏蛋与自身的距离为该方向安全感，四个方向的最小值即此人的安全感。求 $a$ 中所有人的安全感之和。

数据范围：$1 lt.eq T lt.eq 2$，$1 lt.eq n lt.eq 1500$，$1 lt.eq q lt.eq 5 times 10^4$，$0 lt.eq a_(i \, j) < 2^15$，$0 lt.eq upright("card") < 10^9$。

====== Solution

#strong[SOS 高维前缀和、答案差分化、short]

- 要看看对于某一个人来说，$upright("card")$ 在什么情况下才可以延伸 $0 \, 1 \, 2 \, 3 \, dots.h \, n$ 格
- 发现这种 $upright("card")$ 具有集合的运算包含性质，所以对于每一种四方向前缀#strong[或和];，在对应的 mask 状态 ++
- （Hard Version $O \( n^3 \)$ 有点大）发现对于一个前缀或和来说，最多变化 log 次，所以只需要记录一个地方上的上下左右的下一个第 $b$ 位的 $1$ 在哪一行/列

#strong[踩坑]

- #strong[TLE];：即使 Easy Version 如果直接暴力 #strong[TLE]
- #strong[WA];：debug 的时候改小了常量，直接 TM 找不到错误了，以为对了，其实错了，把我整懵了
- #strong[WA];：取多次 min 的时候 `mn = min({,,,})` 里面啥都写了，就是没写 mn
- #strong[MLE];：这个信息有点稍微大，不开 short 就 MLE 了！第一次见 short 优化 MLE！

====== Code

```cpp
for (int i = 1; i <= n; i++) {
    for (int j = 1; j <= n; j++) {
        int msk = a[i][j];
        int d = 0;
        while(d <= n) {
            if(i - d >= 1 && i + d <= n && j - d >= 1 && j + d <= n) {
                int mn = 1e9;
                for (int b = 0; b < M; b++) {
                    if (msk >> b & 1) continue;
                    mn = min({
                        mn, // !!!!
                        i - U[i-d][j][b],
                        D[i+d][j][b] - i,
                        j - L[i][j-d][b],
                        R[i][j+d][b] - j
                    });
                }
                int tmp;
                if(mn == 1e9) {
                    f[msk] += (tmp = min({
                        i - d, j - d,
                        n + 1 - i - d,
                        n + 1 - j - d  
                    }));
                } else {
                    f[msk] += (tmp = mn - d);
                    msk |= a[i-mn][j] | a[i+mn][j] | a[i][j-mn] | a[i][j+mn];
                }
                d = mn;
            } else break;
        }
    }
}
```

===== 1006 游戏

====== Problem Description

你有 $n$ 个变量属性 $a_i$，可以选或不选 $m$ 个武器，第 $i$ 个武器有属性 $g_(i \, j)$ 表示武器 $i$ 对 $j$ 属性的加成。你的每个属性都独立，造成的伤害与属性的取值有关，属性 $i$ 在取值为 $a_i$ 时的伤害为 $p_i$，其中

$ p_i = cases(delim: "{", 0 & a_i < l_i upright(" or ") a_i > r_i, f_(i \, a_i - l_i) & l_i lt.eq a_i lt.eq r_i) $

求你可以造成的最大伤害值 $sum_(i = 1)^n p_i$。

- 注（额外的限制）
  - $sum g_(i \, j) = k lt.eq 150$
  - $40 lt.eq l_i$ 且 $r_i lt.eq 150$
- 数据范围：
  - 多测 $t lt.eq 10$
  - $n lt.eq 6$；$m lt.eq 30$；$k lt.eq 150$；$40 lt.eq l_i lt.eq r_i lt.eq 150$；$1 lt.eq f_(i \, j) lt.eq 10000$；$0 lt.eq g_(i \, j) lt.eq k$

====== Solution

#strong[抽屉原理优化、可达性背包DP]

显然 $floor.l k \/ l_i floor.r lt.eq 3$，所以有效的属性最多有 3 个，状态数量不多，所以对 $m$ 个物品与三维属性使用#strong[可达性背包DP];，最后枚举答案即可。

#strong[踩坑]

- #strong[UNK];：理解错题目了，以为一个武器只能选择提升一个属性，调了好久

====== Code

```cpp
memset(dp, 0, sizeof dp);
dp[0][0][0] = true;
for (int i = 1; i <= m; i++) {
    int a0 = g[i][cand[1]];
    int b0 = g[i][cand[2]];
    int c0 = g[i][cand[3]];
    for (int a = K-1; a >= a0; a--) {
        for(int b = K-1; b >= b0; b--) {
            for (int c = K-1; c >= c0; c--) {
                dp[a][b][c] |= dp[a-a0][b-b0][c-c0]; // SB 了 以为是单加成 
            }
        }
    }
}
```

