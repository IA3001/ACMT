=== #text("Codeforces Round 2204")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/CF/2204.md`]

===== E Sum of Digits (and Again)

====== Problem Description

定义 $S \( x \)$ 表示 $x$ 的递归数位求和字符串，例如 $S \( 75 \) = 75123$。

给定一个乱序的字符串 $s$，请重排它，使其成为某个 $S \( x \)$。

数据范围：$1 lt.eq \| s \| lt.eq 10^5$

====== Solution

#strong[质变分治]

- 考虑到 `1e5` 级别的数字开始，形成的 $S \( x \)$ 用不了几位
- 所以可以得出：那么长的一个字符串一定是由最左侧的非常大的数字加上一个 `1e6` 级别的 $S \( x \)$ 组成的
- 因此可以枚举 `1e6` 级别的 $x$，而作为第一个数字，仅关心其各个数位之和，而不关心其排列顺序，故倒序输出即可
- 特别注意：
  - $\| s \| = 1$ 的特判
  - 枚举一定要从 $1$ 开始

====== Code

```cpp
for (auto c:s)cnt[c - '0']++, sum += c - '0';
for (int i = 1; i < N; i++) { // !!! 一定要从 1 开始因为有 10
    bool ok = true;
    int cost = 0;
    for (int j = 0; j <= 9; j++) {
        ok &= cnt[j] >= need[i][j];
        cost += need[i][j] * j;
    }
    if (ok && sum - cost == i) {
        for (int j = 9; j >= 0; j--) {
            cnt[j] -= need[i][j]; // !!! 扣掉
            while (cnt[j]--) ans += '0' + j;
        }
        ans += S(i);
        cout << ans << "\n";
        return;
    }
}
```

===== F Sum of Fractions

====== Problem Description

给定一个数组，均为 $1 \/ a_i$ 形式。

有 $m$ 个询问，求所有子数组中每个子数组进行 $k_i$ 次提升操作（选择一个元素，分母 `--` 或分子 `++`）后它们所有元素的和。

====== Solution

#strong[单调栈、笛卡尔树、双指针、排序]

- 观察可以得出：所有子数组中必然可以只选择一个数进行不断操作
  - 因此可以总结出一个公式（后来发现这个真得用公式描述，因为我发现增量法会出现 180 度大转弯）
  - 设 $f \( a \, k \)$ 表示对 $1 \/ a$ 进行 $k$ 次操作后新增的收益：

$ f \( a \, k \) = cases(delim: "{", frac(1 + k, a) - 1 / a & k < a - 1, (k - \( a - 1 \) + 1) - 1 / a & k gt.eq a - 1) $

- 根据单调栈计算出每一种元素作为”最值”的次数，然后将 $a$ 排序
- 根据 $k$ 二分出来一个界限，预处理前缀、后缀的信息即可 $O \( 1 \)$ 查询

$ upright("ans") & = sum frac(i \( n + 1 - i \), a_i) + sum_(a_i > k + 1) upright("cnt")_i times k / a_i + sum_(a_i lt.eq k + 1) upright("cnt")_i times (k - a_i + 2 - 1 / a_i)\
 & = sum frac(i \( n + 1 - i \), a_i) + k (sum_(a_i > k + 1) upright("cnt")_i / a_i + sum_(a_i lt.eq k + 1) upright("cnt")_i) - sum_(a_i lt.eq k + 1) upright("cnt")_i times (a_i + 1 / a_i - 2) $

#strong[踩坑]

- #strong[WA];：我竟然把单调栈求得的范围判定条件写反了！！！
  - 记住：#strong[单调栈求管辖范围];，边界必然是那些#strong[比自己更优的位置]
  - 往往使用#strong[一半取等] #strong[一半不取];的方式划分同值范围
- #strong[IDEA];：`lower_bound` 和 `upper_bound` 自定义比较器的顺序不一样！（想想底层实现）

```cpp
// 因为 key >= k 所以 key < k
lower_bound(begin, end, k, [&](auto key, auto k){
  return key < k; 
});
// 因为 key > k 所以 k < key
uppeer_bound(begin, end, k, [&](auto k, auto key){
  return k < key; 
})
```

===== G Grid Path

====== Problem Description

$n$ 行 $m$ 列的网格，初始在 $\( 1 \, 1 \)$ 位置，可以向左、右、下移动，问合法的路径覆盖区域（不区分经过的顺序）有多少种，结果对 $upright("mod")$ 取模。

数据范围：$1 lt.eq n lt.eq 10^8$，$1 lt.eq m lt.eq 150$，$2 lt.eq upright("mod") lt.eq 10^9$

====== Solution

#strong[计数 DP、层级 DP、矩阵加速、容斥]

显然可以一行一行地进行 DP：

- 注意到同一行内的移动范围必然是连续的一块
- 行间的转移必然是有重叠的列才可以转移
- 转移的时候可以容斥，但是没想到竟然是取反

设：

- $upright("dp") \[ i \] \[ l \] \[ r \]$ 表示第 $i$ 层活动区间在 $\[ l . . r \]$ 的方案数
- $S \[ i \]$ 表示第 $i$ 层方案总数
- 引入辅助变量：$C \[ i \] \[ x \] = sum_(l lt.eq x) upright("dp") \[ i \] \[ l \] \[ x \]$，$D \[ i \] \[ x \] = sum_(r gt.eq x) upright("dp") \[ i \] \[ x \] \[ r \]$

则：

- $upright("dp") \[ i + 1 \] \[ l \] \[ r \] = S \[ i \] - sum_(x < l) C \[ i \] \[ x \] - sum_(x > r) D \[ i \] \[ x \]$
- 推导 $C$：

$ C \[ i + 1 \] \[ x \] & = sum_(l lt.eq x) upright("dp") \[ i + 1 \] \[ l \] \[ x \]\
 & = sum_(l lt.eq x) (S \[ i \] - sum_(y < l) C \[ i \] \[ y \] - sum_(y > x) D \[ i \] \[ y \])\
 & = x S \[ i \] - sum_(y < x) \( x - y \) C \[ i \] \[ y \] - x sum_(y > x) D \[ i \] \[ y \] $

- 推导 $D$：

$ D \[ i + 1 \] \[ x \] & = sum_(r gt.eq x) upright("dp") \[ i + 1 \] \[ x \] \[ r \]\
 & = sum_(r gt.eq x) (S \[ i \] - sum_(y < x) C \[ i \] \[ y \] - sum_(y > r) D \[ i \] \[ y \])\
 & = \( m + 1 - x \) S \[ i \] - \( m + 1 - x \) sum_(y < x) C \[ i \] \[ y \] - sum_(y > x) \( y - x \) D \[ i \] \[ y \] $

- 推导 $S$：

$ S \[ i + 1 \] & = frac(sum_(x = 1)^m (C \[ i + 1 \] \[ x \] + D \[ i + 1 \] \[ x \]), 2)\
 & = frac(sum_(x = 1)^m (\( m + 1 \) S \[ i \] - sum_(y < x) \( m + 1 - y \) C \[ i \] \[ y \] - sum_(y > x) y D \[ i \] \[ y \]), 2)\
 & = frac(m \( m + 1 \), 2) S \[ i \] - 1 / 2 sum_(x = 1)^m \( m - x \) \( m + 1 - x \) C \[ i \] \[ x \] - 1 / 2 sum_(x = 1)^m x \( x - 1 \) D \[ i \] \[ x \] $

- 到这里我发现，求单个的 $upright("dp") \[ i \] \[ l \] \[ r \]$ 还有什么意义呢？题目不是让求的是 $sum_(i = 1)^n S \[ i \]$ 吗？
- 所以这里根据对称性引入 $F \[ i \] \[ x \] = C \[ i \] \[ x \] + D \[ i \] \[ m + 1 - x \]$（WA：这里想当然转化的时候没有注意到 $x$ 出现在多个位置，写反了）
- 于是：

$ S \[ i + 1 \] & = frac(m \( m + 1 \), 2) S \[ i \] - 1 / 2 sum_(x = 1)^m \( m - x \) \( m + 1 - x \) F \[ i \] \[ x \] $

$ F \[ i + 1 \] \[ x \] & = C \[ i + 1 \] \[ x \] + D \[ i + 1 \] \[ m + 1 - x \]\
 & = 2 x S \[ i \] - sum_(y < x) \( x - y \) C \[ i \] \[ y \] - x sum_(y > x) D \[ i \] \[ y \] - x sum_(y < m + 1 - x) C \[ i \] \[ y \] - sum_(y > m + 1 - x) \( x + y - m - 1 \) D \[ i \] \[ y \]\
 & = 2 x S \[ i \] - sum_(y < x) \( x - y \) C \[ i \] \[ y \] - x sum_(y > x) D \[ i \] \[ y \] - x sum_(y > x) C \[ i \] \[ m + 1 - y \] - sum_(y < x) \( x - y \) D \[ i \] \[ m + 1 - y \]\
 & = 2 x S \[ i \] - sum_(y < x) \( x - y \) F \[ i \] \[ y \] - x sum_(y > x) F \[ i \] \[ m + 1 - y \] $

设状态向量定义为：

$ x_i = (S \[ i \] \, F \[ i \] \[ 1 \] \, F \[ i \] \[ 2 \] \, dots.h \, F \[ i \] \[ m \] \, sum_(j = 1)^(i - 1) S \[ i \])^T $

则左乘转移矩阵为：

$ T_(\( \( m + 2 \) times \( m + 2 \) \)) = mat(delim: "(", frac(m \( m + 1 \), 2), - frac(m \( m - 1 \), 2), - frac(\( m - 1 \) \( m - 2 \), 2), dots.h, - frac(1 \( 1 - 1 \), 2), 0; 1 times 2, dots.h, upright("随机应变"), dots.h, dots.h, 0; 2 times 2, dots.h, upright("随机应变"), dots.h, dots.h, 0; 3 times 2, dots.h, upright("随机应变"), dots.h, dots.h, 0; dots.h, dots.h, dots.h, dots.h, dots.h, 0; m times 2, dots.h, upright("随机应变"), dots.h, dots.h, 0; 1, 0, 0, 0, 0, 1) $

初始状态为：

$ x_1 = (m \, F \[ 1 \] \[ 1 \] \, F \[ 1 \] \[ 2 \] \, dots.h \, F \[ 1 \] \[ m - 1 \] \, F \[ 1 \] \[ m \] \, 0)^T $

终止状态为：

$ x_(n + 1) = (S \[ n + 1 \] \, F \[ n + 1 \] \[ 1 \] \, F \[ n + 1 \] \[ 2 \] \, dots.h \, F \[ n + 1 \] \[ m - 1 \] \, F \[ n + 1 \] \[ m \] \, sum_(i = 1)^n S \[ i \]) $

#strong[踩坑]

- #strong[IDEA];：关于 DP 推柿子的启发
  - 转移条件#strong[正难则反];，使用容斥
  - 有时候递推是有对称性的，比如一个前缀、一个后缀
  - 要正确使用换元的方法，不要漏换
  - 一开始推柿子的时候，#strong[不要直接朝];着答案去设状态，而是#strong[从答案的来源];进行#strong[分类讨论];（第 $i$ 层作为最后一层且处于 $\[ l . . r \]$ 区间），在求#strong[分量];的时候，#strong[自然];会意识到#strong[建立新的];方便用于#strong[答案求解];的新#strong[状态变量];（第 $i$ 层作为最后一层的方法总和 | $F \[ i \] \[ x \] = C \[ i \] \[ x \] + D \[ i \] \[ m + 1 - x \]$）
  - #strong[虽然];你可能#strong[不必推出所有];的#strong[细节变量];（$C \[ i \] \[ x \] \, D \[ i \] \[ x \]$ 等）
  - #strong[但是];必须推出#strong[方便求解答案];的#strong[主要变量];（$S \[ i \] \, F \[ i \] \[ x \] \, sum S$）！
- #strong[IDEA];：关于矩阵加速 DP 的启发
  - $x^T$ 被定义为#strong[状态向量];，存储所有所需要的状态，可以#strong[适当居中状态，两头（0, n+1）塞私货]
  - $T$ 被定义为#strong[转移矩阵];，定义了 $x$ 各个新的分量与旧的分量的一次函数关系

