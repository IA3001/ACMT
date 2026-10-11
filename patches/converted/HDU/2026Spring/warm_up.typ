=== #text("2026“钉耙编程”中国大学生算法设计春季联赛（热身）")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/HDU/2026Spring/warm_up.md`]

===== 1001 最大的公约数

====== Problem Description

给定一个正整数 $n$，找到两个正整数 $a$ 和 $b$，满足：

- $a + b = n$
- $a > b$
- 使得 $gcd \( a \, b \)$ 的值最大

输出这个最大的 $gcd \( a \, b \)$。

====== Solution

#strong[GCD]

gcd 性质：$gcd \( a \, b \) = gcd \( a \, n - a \) = gcd \( a \, n \)$

注意特判：$a eq.not b$

===== 1002 雪蜜冰城柠檬茶的神秘成分魔法

====== Problem Description

#strong[柠檬茶配方];中有一个整数数列，支持以下三种操作：

- 操作 1 $x$ $y$：将数列中所有等于 $x$ 的元素替换为 $y$。
- 操作 2 $x$：在数列末尾添加一个 $x$。
- 操作 3 $x$：删除数列中所有等于 $x$ 的元素。

多组数据，数据范围： $1 lt.eq t lt.eq 10$，$1 lt.eq n lt.eq 2 times 10^5$，$1 lt.eq m lt.eq 10^5$，$1 lt.eq a_i lt.eq 10^7$，$1 lt.eq x \, y lt.eq 10^7$

====== Solution

#strong[启发式合并（$O \( n log n \)$）]

亮点：使用 `stk[]` 按需存储，灵活清空数据

```cpp
if(op==1){
    cin>>x>>y;
    if(pos[x].size()>pos[y].size())swap(pos[x],pos[y]);
    for(auto v:pos[x])pos[y].push_back(v);
    pos[x].clear();
    stk[++tp]=y;
}else if(op==2){
    cin>>x;
    pos[x].push_back(++tot);
    stk[++tp]=x;
}else {
    cin>>x;
    pos[x].clear();
}
```

#strong[另解（正解）：正难则反（$O \( n \)$）]

想一想：一个元素它最终的值取决于什么？

- 一旦一个元素被添加，它最终的值等于后续操作的映射值
- 考虑多次映射 $x arrow.r y arrow.r z$，这是满足传递性的

所以倒序处理元素：

- 初始化 `f[x]=x`（`f[x]` 是直接映射，不压缩）；最后添加的元素一定是未被重定向的
- 1 x y：`f[x]=f[y]`，在这之前裸的 $x$ 值都变为裸的 $y$ 之后的直接映射
- 2 x：如果 `if(f[x]) ans.push_back(f[x])`，查询裸的 $x$ 最终值
- 3 x：`f[x]=0`，之前的裸的 $x$ 值不再需要
- 倒序输出 `ans`

===== 1004 小z的开箱

====== Problem Description

在一条环形路上有 #strong[n] 颗幸运宝石，第 #strong[i] 颗的幸运值为 $a_i$。初始幸运值为 $0$ 的宝石，小 z 可以任意选择起点和方向（顺时针或逆时针）前行，不可回头，直到回到起点。沿途他可以选择吸收或不吸收每颗宝石，每吸收一颗，手中宝石的幸运值变为：当前幸运值与吸收宝石幸运值之和，再取不超过该和的最大质数；若该和小于 $2$（即不存在质数），则变为 $0$。求最后能得到的最大幸运值。

- 输入包含 #strong[T] 组测试，$1 lt.eq T lt.eq 10$。
- 每组第一行 #strong[n];，$1 lt.eq n lt.eq 10^5$。
- 第二行 #strong[n] 个整数 $a_i$，$1 lt.eq a_i lt.eq 10$。

====== Solution

#strong[值转移]

注意到 $a$ 的范围很小，打表很容易得出答案的值域不大，可进行#strong[值域加速跳转];。

===== 1005 时空碎片收集者

====== Problem Description

在一条从 $1$ 到 $n$ 的路径上有 $n$ 个节点，第 $i$ 个节点有基础碎片 $a_i$。收集者从节点 $1$ 进入，走到大于 $n$ 的节点即离开。他需要在每个节点选择以下三种操作之一：

- #strong[直接收集];：获得 $a_i$ 碎片，然后进入节点 $i + 1$。
- #strong[时空回溯];：获得 $2 a_i$ 碎片，但会使接下来 $k$ 个节点（$i + 1$ 到 $i + k$）的碎片变为原来的一半（向下取整），且这些节点不能再使用时空回溯（回溯效果不可叠加）。然后进入节点 $i + 1$。
- #strong[时空跳跃];：获得从节点 $i$ 到 $i + m$ 的所有碎片（即 $a_i + a_(i + 1) + dots.h + a_(i + m)$），然后进入节点 $i + m + 1$。跳跃获得的碎片始终取原始值，不受回溯影响。

求能收集到的最大碎片总数。

输入包含 $t$ 组数据，$1 lt.eq t lt.eq 10$。每组数据第一行三个整数 $n \, k \, m$，满足 $1 lt.eq n lt.eq 10^5$，$1 lt.eq k lt.eq 25$，$1 lt.eq m lt.eq 50$；第二行 $n$ 个整数 $a_1 \, a_2 \, dots.h \, a_n$，满足 $1 lt.eq a_i lt.eq 10^5$。所有组的 $n$ 之和不超过 $2 times 10^6$。

====== Solution

#strong[正推贡献DP]

显然又看到了小值域 $k \, m$ 可以 dp，本题巧妙地将区间范围影响转化为了 buff 剩余回合数量。

注意 dp 转移正难则反：要么使用#strong[逆推溯源法];，要么使用#strong[正推贡献法];（本题）。

====== Code

```cpp
// 注意适当扩充 n 范围方便求解
// f[i][j] 表示 来到 i 剩下的 j 个效果减半 累计的收益
for(int i=0;i<=n;i++){
    if(i+1<=n){
        f[i+1][0]=max(f[i+1][0],f[i][0]+a[i+1]);
        f[i+1][k]=max(f[i+1][k],f[i][0]+a[i+1]*2);
    }
    for(int j=1;j<=k;j++){
        if(i+1<=n)f[i+1][j-1]=max(f[i+1][j-1],f[i][j]+a[i+1]/2);
        if(i+m<=n)f[i+m][max(0,j-m)]=max(f[i+m][max(0,j-m)],f[i][j]+pre[i+m]-pre[i]);
    }
}
```

===== 1006 光辉岁月

====== Problem Description

水圣人活了 $n$ 年，每年有一个约定，用数组 $a_i$ 表示是否记得第 $i$ 年的约定（$0$ 表示不记得，$1$ 表示记得）。小 $w$ 施展 $q$ 次魔法，每次魔法使一段连续年份 $\[ l \, r \]$ 间的所有约定被想起（即永久变为记得）。

每次魔法后，小 $w$ 任意挑选一段年份 $\[ L \, R \]$（$1 lt.eq L lt.eq R lt.eq n$），记录这段区间内所有可以想起的约定的年份，得到 $t$ 个年份。如果 $t = 1$ 或存在 $k gt.eq 1$ 使得这些年份构成公差为 $k$ 的等差数列，那么这段岁月 $\[ L \, R \]$ 称为#strong[光辉岁月];。对于每次魔法，求所有光辉岁月中最大的 $t$。

数据范围：$T$ 组测试，$1 lt.eq T lt.eq 10^3$，每组 $n \, q$ 满足 $sum n lt.eq 2 times 10^5$，$sum q lt.eq 2 times 10^5$，数组元素为 $0$ 或 $1$，每次魔法的 $l \, r$ 满足 $1 lt.eq l lt.eq r lt.eq n$。

====== Solution

#strong[线段树区间信息合并]

注意到等差数列，因此想到维护最长连续序列。

亮点：

- 使用集合 `val` 缓存未出现的值
- 使用 `pre` 维护前驱，寻找后继

#strong[踩坑]

- #strong[UNK];、#strong[WA];：#strong[线段树区间信息合并];不熟练
  - 两处（`up` 和 `query`）都要#strong[写全信息];、#strong[写对合并 case]

====== Code

```cpp
struct SegmentTree{
    int f[N*4];
    int L[N*4],R[N*4];
    int lc[N*4],rc[N*4];
    int md[N*4],len[N*4];
    void up(int i){
        int l=i*2,r=i*2+1;
        len[i]=len[l]+len[r];
        L[i]=L[l]?L[l]:L[r];
        R[i]=R[r]?R[r]:R[l];
        lc[i]=lc[l]?lc[l]:lc[r];
        rc[i]=rc[r]?rc[r]:rc[l];
        md[i]=max({md[l],md[r],rc[l],lc[r]});
        if(R[l]&&L[r]&&R[l]==L[r]){
            md[i]=max(md[i],rc[l]+lc[r]);
            if(lc[l]==len[l])lc[i]=len[l]+lc[r];
            if(rc[r]==len[r])rc[i]=len[r]+rc[l];
        }
    }
    void build(int i,int l,int r){
        if(l==r){
            L[i]=R[i]=0;
            lc[i]=rc[i]=md[i]=0;
            len[i]=0;
        }else {
            int mid=(l+r)/2;
            build(i*2,l,mid);
            build(i*2+1,mid+1,r);
        }
    }
    void modify(int i,int l,int r,int p,int v){
        if(l==r){
            L[i]=R[i]=v;
            len[i]=md[i]=v>0;
            lc[i]=rc[i]=v>0;
        }else {
            int mid=(l+r)/2;
            if(p<=mid)modify(i*2,l,mid,p,v);
            else modify(i*2+1,mid+1,r,p,v);
            up(i);
        }
    }
    array<int,6> query(int i,int l,int r,int jl,int jr){
        if(jl<=l&&r<=jr){
            return {L[i],R[i],lc[i],rc[i],md[i],len[i]};
        }else {
            int mid=(l+r)/2;
            if(jl<=mid&&jr>=mid+1){
                auto [lL,lR,llc,lrc,lmd,llen] = query(i*2,l,mid,jl,jr);
                auto [rL,rR,rlc,rrc,rmd,rlen] = query(i*2+1,mid+1,r,jl,jr);
                int mL,mR,mlc,mrc,mmd,mlen;
                mlen=llen+rlen;
                mL=lL?lL:rL;
                mR=rR?rR:lR;
                mlc=llc?llc:rlc;
                mrc=rrc?rrc:lrc;
                mmd=max({lmd,rmd,lrc,rlc});
                if(lR&&rL&&lR==rL){
                    mmd=max(mmd,lrc+rlc);
                    if(llc==llen)mlc=llen+rlc;
                    if(rrc==rlen)mrc=rlen+lrc;
                }
                return {mL,mR,mlc,mrc,mmd,mlen};
            }else if(jl<=mid) return query(i*2,l,mid,jl,jr);
            else return query(i*2+1,mid+1,r,jl,jr);
        }
    }
}T;
```

===== 1008 单十一花钱计划

====== Problem Description

- 有 $T$ 天，每天有 $n$ 件衣服，第 $j$ 件衣服有两种价格 $a_j$ 和 $b_j$。
- 每天进行 $q$ 次购买，第 $i$ 次购买给定区间 $\[ l_i \, r_i \]$ 和两个整数 $X_i \, Y_i$。
- 对于区间内每件衣服 $j$，价格临时变为 $a_j + x_i$ 和 $b_j + y_i$，歪歪选择较低的价格支付，即实际支付 $min \( a_j + x_i \, b_j + y_i \)$。
- 她希望买到最贵的衣服，答案为区间内所有 $min \( a_j + x_i \, b_j + y_i \)$ 的最大值。
- 每次购买后价格恢复原状。
- 强制在线

数据范围：$T lt.eq 5 times 10^5$，$n \, q lt.eq 5 times 10^4$，$sum n_i lt.eq 5 times 10^5$，$sum q_i lt.eq 5 times 10^5$，$a_i \, b_i \, X_i \, Y_i lt.eq 10^9$，$1 lt.eq l lt.eq r lt.eq n$。

====== Solution

#strong[分块（$O \( n sqrt(n) log n \)$）]

注意到两种属性及其操作具有#strong[相对性];，到达一定的临界点才会转变，所以排序后在差值上面二分即可得到边界。

```cpp
struct BArray{
    int n,len,bn;
    // 排完序忘了拷贝了 
    array<LL,2> ab[N],tmp[N];
    LL c[N];
    LL pre_maxb[N],suf_maxa[N];
    int id[N];
    int st[B],ed[B];
    void build(){
        len=ceil(sqrt(n));
        bn=(n+len-1)/len;
        for(int i=1;i<=bn;i++){
            st[i]=(i-1)*len+1;
            ed[i]=min(n,st[i]+len-1);
            fill(id+st[i],id+ed[i]+1,i);
        }
        for(int I=1;I<=bn;I++){
            int l=st[I],r=ed[I];
            sort(ab+l,ab+r+1,[](auto a,auto b){
                return a[1]-a[0]<b[1]-b[0];
            });
            for(int i=l;i<=r;i++)c[i]=ab[i][1]-ab[i][0];
            pre_maxb[l]=ab[l][1];// 服了 这里 i 重定义 差点没看出来
            suf_maxa[r]=ab[r][0];// 服了 这里 i 重定义 差点没看出来 
            for(int i=l+1;i<=r;i++)pre_maxb[i]=max(pre_maxb[i-1],ab[i][1]);
            for(int i=r-1;i>=l;i--)suf_maxa[i]=max(suf_maxa[i+1],ab[i][0]);
        }
    }
    LL query(int l,int r,LL x,LL y){
        int L=id[l],R=id[r];
        LL res=0;
        if(L==R){
            for(int i=l;i<=r;i++)res=max(res,min(tmp[i][0]+x,tmp[i][1]+y));
        }else{
            for(int i=l;i<=ed[L];i++)res=max(res,min(tmp[i][0]+x,tmp[i][1]+y));
            for(int I=L+1;I<=R-1;I++){
                int ll=st[I],rr=ed[I];
                int pos=lower_bound(c+ll,c+rr+1,-(y-x))-c;
                if(pos<=rr)res=max(res,suf_maxa[pos]+x);
                if(pos>ll)res=max(res,pre_maxb[pos-1]+y);
            }
            for(int i=st[R];i<=r;i++)res=max(res,min(tmp[i][0]+x,tmp[i][1]+y));
        }
        return res;
    }

}A;
LL lst,q;
void solve(){
    cin>>A.n>>q;
    for(int i=1;i<=A.n;i++)cin>>A.ab[i][0]>>A.ab[i][1],A.tmp[i]=A.ab[i];
    A.build();
    lst=0;
    LL l,r,X,Y;
    while(q--){
        cin>>l>>r>>X>>Y;
        // 这么阴 ??? 异或 得到 2e9 级别???
        X^=lst;Y^=lst;
        cout<<(lst=A.query(l,r,X,Y))<<"\n";
    }
}
```

#strong[踩坑]

- #strong[UNK];：因为#strong[没看数据范围];，所以想了半天线段树维护方式，但是一看数据范围 5e4，果断分块，#strong[印证了左神的那句话：实在难维护，先分块试试];（但是题解用的可持久化线段树？感觉复杂度也差不多吧）
- #strong[WA];：分块内部#strong[排序忘记备份]
- #strong[WA];：#strong[下标重定义];不容易分清
- #strong[WA];：#strong[数据范围被题目规则骗了];：`lst` 异或出来变成大数，计算爆 `int` !!!

#strong[另解（稍优）：归并树 MergeSortTree（$O \( n log^2 n \)$）]

- 未收录，本质上是带有区间数组大信息的线段树？
- 分的块数量是 $O \( log n \)$ 而非上述分块的 $O \( sqrt(n) \)$
- 突然感觉#strong[归并树];是更聪明的分块方式？？？

```cpp
// 1. 归并树 合并使用 c++ 自带的 std::merge()
void build(int p, int l, int r, const vector<Info> &arr) {
    if (l == r) {
        seg[p].assign(1, arr[l]);
        tree1[p].assign(1, arr[l].a);
        tree2[p].assign(1, arr[l].b);
        return;
    }
    int m = (l + r) >> 1;
    build(p << 1, l, m, arr);
    build(p << 1 | 1, m + 1, r, arr);

    int siz = seg[p << 1].size() + seg[p << 1 | 1].size();
    seg[p].resize(siz);
    merge(seg[p << 1].begin(), seg[p << 1].end(), seg[p << 1 | 1].begin(), seg[p << 1 | 1].end(), seg[p].begin());

    tree1[p].resize(siz);
    tree2[p].resize(siz);

    tree1[p][0] = seg[p][0].a;
    for (int i = 1; i < siz; ++i)
        tree1[p][i] = max(tree1[p][i - 1], seg[p][i].a);

    tree2[p][siz - 1] = seg[p][siz - 1].b;
    for (int i = siz - 2; i >= 0; --i)
        tree2[p][i] = max(tree2[p][i + 1], seg[p][i].b);
}
// 2. 学习借鉴: 不同类型之间的operator实现灵活二分 
auto it = upper_bound(seg[p].begin(), seg[p].end(), d, [](ll val, const Info &elem) {
    return val < elem.c;
});
// 3. 另外提醒 build(i,l,r) 
// 其中 [l,r] 可以是 [0,n-1] 
// 而为了方便 i 只能从 1 开始编号 !!! 
```

#strong[另解（最优）：可持久化线段树（$O \( n log n \)$）]

将衣服按 `a-b` 排序后，用两棵可持久化线段树分别按顺序存储每个版本下原数组位置的 `a` 最大值和 `b` 最大值，查询时根据 `y-x` 二分找到对应版本，分别查询区间 `[l,r]` 的 `max a` 和 `max b` 后取较大值即可。

===== 1010 收买时间

====== Problem Description

题目是二维网格，每一个格子有解锁时刻，格子上可能有#strong[单向];消耗 money 的传送门，给定初始 money、起点和终点，问什么时候最早到达终点。

====== Solution

#strong[二分答案、洪水填充、Dijkstra]

非常典型的二分答案（但是 WA 了两发！！！）

#strong[踩坑]

- #strong[WA];：题目给的是单向边，你非要#strong[自以为是];写成双向
- #strong[WA];：洪水填充这种#strong[建立新编号节点];的行为，在设计它的数据结构的时候，一定要计算好它的#strong[数据量是多大];，不要#strong[数组没开够];！！！
  - 所以当你 #strong[WA] 了，除了想想是不是没开 `LL` 爆 `int`，还要想想：
    - 是不是#strong[题目理解有误]
    - 是不是#strong[数组开小];了

