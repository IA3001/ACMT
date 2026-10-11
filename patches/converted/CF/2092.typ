=== #text("Codeforces Round 2092")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/CF/2092.md`]

===== F Andryusha and CCB

====== Problem Description

给定一个长度为 $n$ 的 01 串 $s$，求 $s$ 的每一个前缀 $s \[ 1 dots.h i \]$ 可以划分为 $k$ 个颜色段数 $m$ 相同的子串的 $k$ 的数量。

数据范围：$1 lt.eq n lt.eq 10^6$

====== Solution

#strong[调和级数复杂度、增量递推、神秘结论]

- 首先需要一个神秘的结论：同一个 $\( k \, m \)$ 对应着一段连续区间
- 有一个数量关系：
  - 设总颜色段数为 $upright("sz")$，则
  - $k times m = upright("sz")$
  - 由于 $m$ 与单段长度有关
  - 所以可以先枚举 $m$，然后从小到大枚举 $k$，最多枚举 $O \( upright("sz") \/ m \)$ 次
  - 故总复杂度为 $n ln n$
- 特别注意：要特别计算 $m = 1$ 的答案，因为跑不动？

#strong[踩坑]

- #strong[WA];：压缩块（$s : 0001101 arrow.r t : 2211$）的时候 `if (!m || t[m] != s[i])` 大错特错！`s` 和 `t` 根本不是存的同一种字符

