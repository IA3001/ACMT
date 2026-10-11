=== #text("Kevin的矩阵")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/NC/Daily/253625.md`]

====== Problem Description

给定一个长度为 $n$ 的数组，初始时排列在一个 $m$ 列的表格中，你可以 $+ + m$、$- - m$ 或者改变一个元素的值，问将某一列的元素全部变为 $k$ 的最小操作次数是多少。

数据范围：$1 lt.eq n lt.eq 2 times 10^5$

====== Solution

#strong[复杂度诈骗、暴力剪枝]

- 因为总个数有限，$upright("ans") = O \( Delta + upright("cnt") \) = O \( Delta + n \/ \( m plus.minus Delta \) \)$
- 因为移动 $O \( sqrt(n) \)$ 次列长度就必然收敛到 $O \( sqrt(n) \)$ 级别了

