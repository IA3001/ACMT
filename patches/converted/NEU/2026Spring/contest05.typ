=== #text("NEU 2026Spring（5）   # TODO: 占位，待补官方场次名")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/NEU/2026Spring/contest05.md`]

===== L 尖尖的排列计数

====== Problem Description

等价转化：求长度为 $n$（奇数）的 1-base 排列 $1 . . n$ 的方案数量，满足：

- 偶数位置上的数字均大于相邻两侧的数字
- 偶数位置上的数字#strong[整体上];是先增后降的

====== Solution

#strong[笛卡尔树分析、数堆计数公式、计数、相对等价计数思想]

- 一棵确定的包含 $n$ 个节点的树结构 $T$，将其填入 $1 . . n$ 的数字并满足最大堆性质的合法方案数为：

$ frac(n !, product_(v in T) upright("size")_v) $

- 可以用归纳法证明
- 这个题就是把排列数组的#strong[大小关系];信息，转化为一个#strong[笛卡尔树模型];，它们之间有一一对应的关系
  - 枚举最大值在哪里，然后这个笛卡尔树结构就确定了，基米说这里的笛卡尔树的叶子必然是奇数索引
  - 确实啊，你模拟一下笛卡尔树的建造过程，确实是这样的形状
  - 对于每一个偶数索引都开始计数（怀念的#strong[多重组合数啊];），加起来就可以了

#strong[踩坑]

- #strong[UNK];：题目都没读全就开算了，以为是卷积，写了 DIF DIT 好久，绝望了，实则呢还有其他约束
- #strong[IDEA];：发现新的树上计数公式了，好耶！
  - #strong[最大堆、笛卡尔树、树的拓扑序];，本质上#strong[完全是同一个数学问题在不同场景下的”换皮”];：
    - #strong[最大/小堆标号];：父节点必须大于（或小于）子节点。
    - #strong[树的拓扑序];：要求父节点必须排在子节点前面（这就等价于给树填入 $1 tilde.op n$ 的标号，且父节点的值小于子节点的值，也就是最小堆）。
    - #strong[笛卡尔树（Cartesian Tree）计数];：给定一棵笛卡尔树形态，求原数组有多少种排列。由于笛卡尔树的形态固定了中序遍历，原排列的数字只需要满足”父节点大于子节点”的最大堆性质即可。因此它完全等价于堆标号问题。
  - 这三者在底层是#strong[绝对同构];的，所以公式完全一模一样，推导过程也被称为 #strong[Knuth's formula for topological sorting of trees];。
- #strong[WA];：出生啊，这个公式里的 $v$ 注意#strong[包含树头];啊，必须要除以一个 $n$ 啊

====== Code

```cpp
const int N = 1e5 + 5;
const int mod = 1e9 + 7;
int fac2[N];
int invfac2[N];
void init() {
    fac2[0] = fac2[1] = 1;
    for (int i = 2; i < N; i++) fac2[i] = 1LL * fac2[i - 2] * i % mod;
    invfac2[N-1] = ksm(fac2[N-1], mod - 2);
    invfac2[N-2] = ksm(fac2[N-2], mod - 2);
    for (int i = N-1; i >= 2; i--) invfac2[i - 2] = 1LL * invfac2[i] * i % mod;
}
void solve() {
    int n, ans = 0;
    cin >> n;
    for (int i = 2; i <= n; i += 2) {
        int L = i - 1, R = n - i;
        ans = (ans + 1LL  * invfac2[L] * invfac2[R] % mod) % mod;
    }
    ans = 1LL * ans * fac2[n] % mod * fac2[n - 1] % mod;
    ans = 1LL * ans * ksm(n, mod - 2) % mod;
    if (n == 1) ans = 1;
    cout << ans << "\n";
}
```

