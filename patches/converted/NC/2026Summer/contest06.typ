=== #text("2026牛客暑期多校训练营06")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/NC/2026Summer/contest06.md`]

===== J 加除【凸包 / 二分】（TODO）

====== Problem Description

给定两个长度为 $n$ 且由正整数组成的数组 $a$ 和 $b$。你需要回答 $q$ 个以下三种类型的询问：

- $1 med i med x$（$1 lt.eq i lt.eq n$，$1 lt.eq x lt.eq 10^9$）：赋值 $a_i arrow.l x$；
- $2 med i med x$（$1 lt.eq i lt.eq n$，$1 lt.eq x lt.eq 10^9$）：赋值 $b_i arrow.l x$；
- $3 med l med r$（$1 lt.eq l < r lt.eq n$）：计算：

$ max_(l lt.eq i < j lt.eq r) frac(a_i + a_j, b_i + b_j) $

所有的询问将按给出的顺序依次处理。每次赋值操作都会永久修改对应的数组元素，并影响所有后续的询问。

====== Input

每个测试点的第一行包含两个整数 $n$ 和 $q$（$2 lt.eq n lt.eq 10^5$，$1 lt.eq q lt.eq 10^5$），分别表示数组 $a$ 和 $b$ 的长度以及询问的数量。

第二行包含 $n$ 个整数 $a_1 \, a_2 \, dots.h \, a_n$（$1 lt.eq a_i lt.eq 10^9$），表示数组 $a$ 的元素。

第三行包含 $n$ 个整数 $b_1 \, b_2 \, dots.h \, b_n$（$1 lt.eq b_i lt.eq 10^9$），表示数组 $b$ 的元素。

接下来的 $q$ 行，每行包含一个询问。

====== Output

对于每个第三种类型的询问，可以证明其答案能被唯一表示为最简分数 $x / y$。你需要输出两个整数 $x$ 和 $y$。

====== Sample Input

```txt
6 7
10 20 30 100 1000000000 1000000000
1 5 2 10 1 1000000000
3 1 4
3 2 4
1 3 4
3 1 4
2 1 100
3 1 4
3 5 6
```

====== Sample Output

```txt
40 3
65 6
10 1
26 3
2000000000 1000000001
```

