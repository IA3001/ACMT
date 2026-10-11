=== #text("Codeforces Round 2209")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/CF/2209.md`]

===== D RGB三色限制序列构造

====== Problem Description

（赛时未做）给出 $R \, G \, B$ 三种字符的数量，构造尽可能长的序列满足：

- $S \[ i \] eq.not S \[ i - 1 \]$
- $S \[ i \] eq.not S \[ i - 3 \]$

====== Solution

#strong[构造、贪心]

#strong[贪心构造需要引理];：

- 构造串一定可以通过拼接若干个双字符对（RG、GB、RB 等）加上最多一个单字符
- 构造串翻转后仍然合法，因此可以先添加单个字符
- 间隔一格使用相同字符是可以利用的
- 根据鸽巢原理和进一步证明，发现如果每种字符的占比不超过 $ceil.l S \/ 2 ceil.r$，一定可以用完所有的字符（相当于配对充分，最多剩下单个字符）

#strong[贪心即是维持平衡];：

- 利用贪心策略（优先使用剩下的最多的）动态抹平各颜色的数量差，始终保持引理成立

====== Code

```cpp
// 1. 冷知识: bool 可以相加减 得到的类型是 int !!!
// 2. 非常棒的 method:
// 始终合并三个元素中较大的两个
// 等价于判定最小的那个是谁
while((r>0)+(g>0)+(b>0)>=2){
    if(r<=g&&r<=b)gb++,g--,b--;
    else if(g<=r&&g<=b)rb++,r--,b--;
    else rg++,r--,g--;
}
if(r){
    // 3. 以 R 开头为例 需要在 i-1 位置始终维持 R
    cout<<"R";
    while(rg--)cout<<"GR";
    bool ok=false;
    while(rb--)cout<<"BR",ok=true;
    // 现在 i-1 一定是 R 不会冲突 
    // i-3 位置取决于是否放置过 BR 
    while(gb--)cout<<(ok?"BG":"GB");
}else if(g)// code...
```

===== E 字符串最大前缀分解数

====== Problem Description

设 $f \( s \)$ 为字符串 $s$ 分解为若干个 $s$ 前缀的最大分解数。

给定 $s$，如何 $O \( n \)$ 求解 $sum_(i = 1)^n f \( s \[ 1 dots.h i \] \)$？

====== Solution

#strong[KMP + 最小 border]

记住这个结论：字符串的最大前缀分解数量，其方案为不断截取它尾部的最小 border 得到的分解。

====== Code

```cpp
vector<int> getNe(const string& s){
    int n=s.length();
    vector<int> ne(n);
    for(int i=1,j=0;i<n;i++){
        while(j&&s[i]!=s[j])j=ne[j-1];
        if(s[i]==s[j])j++;
        ne[i]=j;
    }
    // 最小 border 的求解: 不断跳的传递 
    for(int i=1;i<n;i++)
        // 要减个 1 啊！ 因为它是 0-base 的而 ne[i] 的含义是长度 所以要 -1
        if(ne[i]&&ne[ne[i]-1])ne[i]=ne[ne[i]-1];
    return ne;
}
// dp[i] 表示 f(s[0..i])
for(int i=0;i<r-l+1;i++){
    dp[i]=ne[i]?(dp[i-ne[i]]+1):1;
    res+=dp[i];
}
```

===== F Dynamic Values And Maximum Sum

====== Problem Description

给定一棵 $n$ 节点的树，点权为 $1 lt.eq a \[ i \] lt.eq 10^9$。

定义一次操作为：

- 选择一个点作为树的根
- 分数加等于它的点权，然后它的点权变为 $0$
- 这个有根树的所有非叶节点 $i$ 均将自己的权值加到自己的子树中第一关键字距离最大、第二关键字编号最小的那个节点 $d \[ i \]$，然后自己变为 $0$

最多进行 $k$ 次操作，求最终的分数最大值。

====== Solution

#strong[树形 DP、换根 DP、动态 k 大值数据结构]

显然，一旦进行一次操作，所有的点权都会集中到叶子上，以后不再迁移。

所以很自然就想到：

- 树形 DP + 换根 DP + 查询剩余树上前 $k - 1$ 大的和
  - 树形 DP 用于预处理 1 为根情况的答案以及初始的 $d \[ i \]$
  - 换根 DP 的内容（遍历相邻节点 $v$，从 $u$ 换到 $v$）
    - 原先 $u$ 从没有对叶子的贡献，变为有向”父子树”中的某个叶子的贡献
      - 如果 $d \[ u \]$ 与 $d \[ v \]$ 相同，说明 $u$ 来自 $v$，需要选取次大的 $d \[ u \]$
      - 如果没有次大的 $d \[ u \]$，说明 $u$ 之后会变成叶子（新的叶子出现了）
    - 原先 $v$ 从有对”子树”中的某个叶子的贡献，变为没有对叶子的贡献
      - 注意：$v$ 即将成为根，所以 $v$ 需要计算它为根的最大/次大 $d \[ v \]$
      - $u$ 是它的一个新的子树，自然 $v$ 需要按照预处理时的方式，用最大 $d \[ u \]$ 更新 $d \[ v \]$
      - 特别的，如果 $v$ 之前已经是叶子了，那么 $v$ 只会有最大 $d \[ v \]$（叶子消失了）
      - 现在 $v$ 为根所需要的信息都已经齐全，计算 $upright("ans") \[ v \]$ 并向下推 `dfs2(v,u)`
      - #strong[重置1];：回溯 $v$ 的贡献，恢复 $v$ 不为根时向”子树”中某个叶子的贡献
    - #strong[重置2];：回溯 $u$ 关于这个 $v$ 的贡献，撤回 $u$ 向”父子树”中的某个叶子的贡献

#strong[踩坑]

- #strong[WA];：根本没有详细读题（CF 英文题面），把”距离最远第一关键字”吃了
- #strong[UNK];：#strong[换根DP] #strong[没分析透彻] #strong[没有化简思路];，写的代码太 SHI 了
- #strong[UNK];：动态 $k$ 大值数据结构，我选的 #strong[FHQTreap];，但是没有弄清楚算法本质过程，#strong[默写不出来]
  - 大胆竟然使用 `int& i, int& l, int& r` 这种影响代码一致性的东西
  - 不知道 `merge` 它是基于 `split` #strong[左只有右，右只有左];的性质实现的
  - 忘记 `split` 和 `merge` 的时候 `up(i)` 和 `up(l) up(r)`
  - 错误的在 `erase` 的时候选错了根，删除的时候应该以 `int lm` 为根进行 `split`
  - 在#strong[平衡树上二分];的时候忘记判定 $> = <$ 的方式，甚至方向#strong[反了]

