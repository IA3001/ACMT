
#import "../lib.typ": *

= 杂项

== 离散化

```cpp
const int N=2e5+5;
int x[N],cntX,X[N];

void prepare(){
    // 预处理 O(nlog n)
    memcpy(X,x,sizeof(x[0])*(n+1));
    sort(X+1,x+1+n);
    cntX=unique(X+1,X+1+n)-X-1;

    // 法2预处理 O(n)
    for(int i=1;i<=cntX;i++)Xrnk[X[i]]=i;
}

// 法1 O(log n)
int Xrnk(int v){return lower_bound(X+1,X+1+cntX,v)-X;}
// int rnk = Xrnk(X[i])

// 法2 O(1)
unordered_map<int,int> Xrnk;
// int rnk = Xrnk[X[i]]W
```

== 双指针技巧

#note[
  *核心思想：*
  利用问题的 *单调性*，通过两个指针的移动，将 $O(n^2)$ 的嵌套循环优化为 $O(n)$ 的线性扫描。
  *分类：*
  + *对撞指针*：方向相反，从两头向中间（如：二分查找、反转）。
  + *快慢指针*：方向相同，维护区间信息（如：滑动窗口、链表判环）。
  + *归并指针*：处理两个序列（如：归并排序、子序列匹配）。
]

=== 类型一：对撞指针 (Opposite Direction)

*适用场景*：
通常用于 *有序数组* 或 *字符串* 问题。
+ 查找两个数满足特定关系（和/差/积）。
+ 盛最多水的容器（面积问题）。
+ 回文串判断。

*通用模板*：
+ 初始化 $L = 0, R = n - 1$。
+ 循环条件 $L < R$：
  - 若 $"val"(L, R) == "target"$：找到答案 / 记录。
  - 若 $"val"(L, R) < "target"$：需要更大的值，因为数组有序，$L$ 必须右移 ($L++$)。
  - 若 $"val"(L, R) > "target"$：需要更小的值，因为数组有序，$R$ 必须左移 ($R--$)。

*经典例题：三数之和 (3Sum)*
+ *思路*：先排序。
+ 枚举第一个数 $i$。
+ 在区间 $[i+1, n-1]$ 使用对撞指针寻找 $L, R$ 使得 $"nums"[i] + "nums"[L] + "nums"[R] == 0$。
+ *注意*：需要处理重复元素跳过的情况。

=== 类型二：快慢指针 / 滑动窗口 (Same Direction)

这是双指针中最灵活、考法最多的一类。通常指针 $R$ 为主指针（探索），$L$ 为副指针（收缩）。

*适用场景*：
+ 寻找满足条件的 *最长/最短* 连续子数组。
+ 统计满足条件的连续子数组 *个数*。
+ 链表问题（判环、找中点）。

*通用模板 (求最长/最短)*：
1. 初始化 $L = 0, R = 0$。
2. *进窗口*：循环增大 $R$，将 $A[R]$ 加入窗口，更新状态（如 sum, count）。
3. *出窗口*：当状态 *打破限制*（求最长时）或 *满足条件*（求最短时）：
   - 循环增大 $L$，将 $A[L]$ 移出窗口，恢复状态。
   - 在此过程中更新最终答案。

*经典模型*：
+ *最小覆盖子串*：
  $R$ 向右扩直到包含所有字符 $->$ $L$ 向右缩直到不能再缩 $->$ 更新 minLen $->$ 重复。
+ *无重复字符的最长子串*：
  $R$ 向右遇到重复字符 $x$ $->$ $L$ 向右缩直到跳过上一个 $x$。
+ *长度为 k 的子数组的最大平均值*：
  固定窗口大小，$R$ 进一个，$L$ 出一个。

=== 类型三：归并指针 (Merging)

*适用场景*：
+ 合并两个有序数组（归并排序核心）。
+ 判断 $A$ 是否为 $B$ 的子序列。
+ 求两个有序数组的中位数。

*逻辑*：
设立指针 $i, j$ 分别指向两个数组。
比较 $A[i]$ 和 $B[j]$ 的大小，决定移动哪一个。

*经典例题：判断子序列*
判断 $s$ 是否为 $t$ 的子序列。
+ $i$ 指向 $s$, $j$ 指向 $t$。
+ 若 $s[i] == t[j]$，匹配成功，$i++, j++$。
+ 否则只移动 $j$（尝试 $t$ 的下一位）。
+ 结束时若 $i == s."length"()$，则为真。

=== 进阶：Floyd 判圈算法 (链表/隐式图)

*问题*：给定一个链表（或数组模拟的跳转关系），判断是否有环，并求环的入口。

*算法逻辑*：
1. *判环*：
   - 设 $"fast"$ 指针一次走 2 步，$"slow"$ 指针一次走 1 步。
   - 若无环，$"fast"$ 会走到 null。
   - 若有环，$"fast"$ 和 $"slow"$ 必然在环内相遇。
2. *找入口*：
   - 相遇后，将其中一个指针移回起点，另一个保持在相遇点。
   - 两个指针每次都走 1 步。
   - 再次相遇的点即为环的入口。

#note[
  *复杂度分析：*
  双指针算法通常将嵌套循环的 $O(n^2)$ 降低为 $O(n)$。
  虽然代码里可能有两层循环（比如滑动窗口的 `while(R) { while(L) ... }`），但每个元素最多被访问两次（进窗口一次，出窗口一次），所以总复杂度是线性的。
]
== 离线算法

=== 根号分治

#note[ 
    按照一个界限 x
    + `<x` 用一种方法
    + `>x` 用另一种方法
]

#note(title:"题目1")[
    + `A x y` 求 $sum_(i equiv y mod x) a_i$
    + `C x y` 修改 $a[x]=y$ 
    - *典型的step操作*
]

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=15e4+5;
const int sN=4e2+5;
int n,x,y,q,sn;char op;
int a[N];
LL sum[sN][sN];
void solve(){
    cin>>n>>q;
    sn=sqrt(n);
    for(int i=1;i<=n;i++){
        cin>>a[i];
        for(int j=1;j<sn;j++)sum[j][i%j]+=a[i];
    }
    while(q--){
        cin>>op>>x>>y;
        if(op=='A'){
            if(x<sn){
                cout<<sum[x][y]<<"\n";
            }else {
                LL res=0;
                for(int i=y;i<=n;i+=x)res+=a[i];
                cout<<res<<"\n";
            }
        }else{
            y-=a[x];
            a[x]+=y;
            for(int j=1;j<sn;j++)sum[j][x%j]+=y;
        }
    }
}
int main(){
    solve();
}
```

#note(title:"题目2 CF1039D")[
    + 求一棵树剖分为 `>=k, k=1,2,3,..,n` 大小的子图的最大数量 
    - *单调划分数* 
    - *$sqrt(n)$个定义域 + $sqrt(n)$个值域*
    - $O(n)$ 树形DP 卡常怎么办? 改成dfn序!!!
]

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=1e6+5;
int n,sn,ans[N];
vector<int> e[N];
int f[N],mx1[N],mx2[N];
int dfncnt,p[N],rnk[N];
void dfs0(int u,int fa){
    rnk[++dfncnt]=u;
    p[u]=fa;
    for(auto v:e[u])if(v!=fa)dfs0(v,u);
}
int calc(int k){
    fill(f,f+n+1,0);
    fill(mx1,mx1+n+1,0);
    fill(mx2,mx2+n+1,0);
    for(int i=dfncnt;i>=1;i--){
        int u=rnk[i],fa=p[u];
        if(mx1[u]+mx2[u]+1>=k)f[u]++;
        else {
            if(mx2[fa]<mx1[u]+1)mx2[fa]=mx1[u]+1;
            if(mx1[fa]<mx2[fa])swap(mx1[fa],mx2[fa]);
        }
        f[fa]+=f[u];
    }
    return f[1];
}
// int dfs(int u,int fa,int k){
//     int res=0,mx1=0,mx2=0;
//     for(auto v:e[u])if(v!=fa){
//         res+=dfs(v,u,k);
//         if(mx2<mx[v])mx2=mx[v];
//         if(mx1<mx2)swap(mx1,mx2);
//     }
//     if(mx1+mx2+1>=k)res++,mx[u]=0;
//     else mx[u]=mx1+1;
//     return res;
// }
void solve(){
    cin>>n;sn=sqrt(n);
    for(int u,v,i=1;i<n;i++){
        cin>>u>>v;
        e[u].push_back(v);
        e[v].push_back(u);
    }
    dfs0(1,0);
    for(int i=1;i<=sn;i++)
        ans[i]=calc(i);
    for(int i=sn+1;i<=n;i++){
        ans[i]=calc(i);
        int l=i,r=n,m,ed=i;
        while(l<=r){
            m=(l+r)/2;
            int res=calc(m);
            if(res==ans[i])ed=m,l=m+1;
            else r=m-1;
        }
        fill(ans+i+1,ans+ed+1,ans[i]);
        i=ed;
    }
    for(int i=1;i<=n;i++)cout<<ans[i]<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

=== CDQ分治

#note[
    原理就是归并分治 ?! 虽 !?

    *复杂度*
    - 如果合并过程 $O(n)$ 那么 $O(n log n)$ 前提需要 手搓归并排序
    - 如果合并过程 $O(n log n)$ 那么 $O(n log^2 n)$ 不必手搓 归并了 

    *过程*
    - 差不多能处理 *三维* 
    - 优先排序操作时间? 然后归并排序索引? 用树状数组/线段树维护指标3?
    - 和那个 *整体二分* 一样! 无论是 初始化数据,还是查询 最终都可以转化为基于 op 的操作 (我愿称之为 *查询节点化* ?)
        - 对操作序列进行 分治即可 
]

#note(title:"题目1 略 三维偏序 ")[
    + 三维数据 `<a,b,c>` 求每个数据的对应的 `<<=a,<=b,<=c>` 的个数
    - 阴险: 需要特别处理 `a=a,b=b,c=c`
    - 模板做法:
        - 先整体按 a 排序, 开始递归分治
        - 底层递归分治结束前 先将本层元素按照 b 排序
        - 合并时 右指针遍历 b, 左指针卡住 b, 维护左右两侧元素按照 b 的启用范围
        - 使用 树状数组 对于每一个右侧查询(即每一个数据) 查询 <=c 的数量
]

#note(title:"题目2 动态逆序对 P3157")[
    + 给定一个 `n` 排列 `n` 次操作每次删除一个位置的数 打印每次操作之前逆序对数量
    - 计算每次被删除的元素贡献的当前逆序对数量 *原来是全局总贡献啊!!!*
    - 模板做法(*初始化-修改-查询 节点(带时间)*)
        - *离线* 查询机制
            - `1 id p x` 在 p 位置加入值 x, 将全局逆序对贡献算到 `ans[id]` (带 `id` 说明是查询操作)!!!
            - `2 id p x` 在 p 位置删除值 x, 将全局逆序对贡献算到 `ans[id]` (带 `id` 说明是查询操作)
        - 对所有以上查询按照 *时间(第一维)* 排序 开始分治
        - 归并后 按照 *值/位置(第二维)* 排序
        - 使用双指针(左右两次) 借助 *树状数组* 查询 *位置/值(第三维)* 个数
]

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=1e5+5;
struct BIT{
    int n;
    vector<int> tr;
    void init(int n){
        this->n=n+1;
        tr.assign(n+2,0);
    }
    void add(int i,int v){for(i++;i<=n;i+=i&-i)tr[i]+=v;}
    int query(int i){int res=0;for(i++;i;i-=i&-i)res+=tr[i];return res;}
    void erase(int i){for(i++;i<=n;i+=i&-i)tr[i]=0;}// 简单的清除
}T;
int p[N];
int n,m;
// 这里不必要记录时间了,因为第一维就是时间,天然排序了
// 注意只有两种操作 op=1 or op=-1 只有两种id 0 和非0 0相当于总贡献 非0相当于删除者的贡献
struct Query{
    int id,op,x,v;// op+=1 对应的操作 对全局逆序对的贡献 算到 ans[id] 里去!!!
}q[N*2];
int cntq;
int64_t ans[N*2];// 开 i64 !!!
void merge(int l,int mid,int r){
    // 现在 [l,mid] [mid+1,r] 两段已经按照 v 排好序
    // 因为要保证时间顺序 所以需要 枚举右v 1. 查找左>v中记录<x数量 2.查找左<v中记录>x数量 
    // 显然按照的是 v 排序 p2 跟着 p1 保持 p2的v<=p1的v 向树状数组中插入 x, 
    // 比右边大 在前面
    for(int R=r,L=mid;R>=mid+1;R--){
        while(L>=l&&q[L].v>q[R].v){
            T.add(q[L].x,q[L].op);
            L--;
        }
        ans[q[R].id]+=T.query(q[R].x-1)*q[R].op;
    }
    // 清空!!!
    for(int i=l;i<=mid;i++)T.erase(q[i].x);
    // 比右边小 在后面
    for(int R=mid+1,L=l;R<=r;R++){// [???] 你怎么写成的 L=1 ???
        while(L<=mid&&q[L].v<q[R].v){
            T.add(q[L].x,q[L].op);
            L++;
        }
        ans[q[R].id]+=(T.query(n)-T.query(q[R].x))*q[R].op;
    }
    // 清空!!!
    for(int i=l;i<=mid;i++)T.erase(q[i].x);
    // merge 后才总体sort
    sort(q+l,q+r+1,[](const Query& a,const Query& b){return a.v<b.v;});
}
void cdq(int l,int r){
    if(l==r)return;
    int mid=(l+r)/2;
    cdq(l,mid);
    cdq(mid+1,r);
    merge(l,mid,r);
}
void solve(){
    cin>>n>>m;
    T.init(n);
    for(int i=1,a;i<=n;i++)cin>>a,p[a]=i,q[++cntq]={0,1,i,a};
    for(int i=1,a;i<=m;i++){
        cin>>a;
        q[++cntq]={i,-1,p[a],a};
    }
    cdq(1,cntq);
    for(int i=1;i<=m;i++){
        ans[i]+=ans[i-1];
        cout<<ans[i-1]<<"\n";
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

#note(title:"题目3 略 二维矩阵求和(离散点) P3755")[
    + rt
    - 模板做法(*初始化-查询 节点(不带时间)*)
        - *离线* 查询机制
            - `1 x y v` `<x,y>` 坐标处有权值 `v`
            - `2 id x y sign` 加/减 所有 `<<=x,<=y>` 处的 `v` (带 `id` 说明是查询操作) (原本查询按照容斥拆成 $4$ 份)
        - 注意到合并复杂度为 $O(n)$ 所以考虑手搓归并
]

#note(title:"题目4 略")[
    + 上一题的 带修版本
    - 既然是 $O(n log n)$ 必然可以再玩一个 时间维度 
]

#note(title:"题目5 略")[
    + `1 x y` 有一个点 `<x,y>`
    + `2 x y` 查询 $min(|x-x_i|+|y-y_i|)$ 
    - 显然可以枚举所有加减情况 比如说 `x,y` 均作为最大值 只需求 `<<=x,<=y>` 中 `x+y` 最大值
    - 可以四次分治 也可以一次性考虑完
    - 用到的一个简单数据结构是 *树状数组* 维护前缀最大值(个人认为它的局限性只是不无法差分)
]

=== 整体二分

#note(title:"讲解")[
    *适用范围*
    + 可以*二分答案*
    + 离线处理(没说不能修改!!!!)
    
    *基本思想*
    + 让修改操作适配当前答案范围, 调整好数据状况
    + 多个问题*共享*这一轮的修改操作后的数据状况(时间复杂度本质)
    + 达标一部分进左组 不达标一部分进右组

    *具体操作(保留历史操作版本 pos分治中心的原理)*
    + `vl==vr` 结算答案
    + `vm=(vl+vr)/2` 执行 `[vl,vm]` 范围上的*相关操作*!
    + 遍历每个问题 满足, 进左组 
    + 不满足, 看当前局面能满足多少 计算上当前的贡献, 进右组 
    + *撤销* `[vl,vm]` 上的操作! (历史操作持久化 因此不一般不需要 `k-=tk`)
    + 递归左右组
    + PS: 递归函数相关的参数 除非明确全局, 千万不要轻易全局化 比如 cntl cntr !!!

    *时间复杂度*
    $O((n+q)log n log V)$
]

#note(title:"题目1")[
    + 离线查询 `[l,r]` 区间第 `k` 小
    - 正常情况下区间查询需要 *将数组初始化作为一种 add 操作混入其中* 
    - 此处代码使用 *分治中心* pos 优化 
]

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=2e5+5;

int n,m;
int a[N],A[N],cntA;
int getA(int v){return lower_bound(A+1,A+1+cntA,v)-A;}

// 简单的 "位值" 树状数组 [因为有 pos 优化, 不必要可以写 clear]
struct BIT{
    int n;
    vector<int> tr;
    void init(int n){
        // [!!!] n+1 与 n+2 !!!!!!
        this->n=n+1;// 一个是位移 一个是右开
        tr.assign(n+2,0);
    }
    void add(int i,int v){for(i++;i<=n;i+=i&-i)tr[i]+=v;}
    int query(int i){int res=0;for(i++;i;i-=i&-i)res+=tr[i];return res;}// Q !!!
}T;

// [操作] 定义
struct Query{
    int l,r,k;
}Q[N];// Q[i] 表示编号为 i 的询问 // 已经用q,ql,qr 了, 万年不变
int q[N],ql[N],qr[N];
// 维护分治中心 pos
int pos;// 右端点 为 n
// A 列表 <val,idx>
array<int,2> A_list[N];
// 答案
int ans[N];

// 当前答案范围来到 [vl..vr] 回答 q[jl..jr] "号"对应的询问 
void pbinary(int vl,int vr,int jl,int jr){
    if(jl>jr)return;
    if(vl==vr){
        for(int i=jl;i<=jr;i++)ans[q[i]]=vl;
        return;
    }
    int vm=(vl+vr)/2;
    // 维护分治中心
    while(pos+1<=n&&A_list[pos+1][0]<=vm)T.add(A_list[++pos][1],1);
    while(pos>=1&&A_list[pos][0]>vm)T.add(A_list[pos--][1],-1);
    int cntl=0,cntr=0;// [[[艹艹艹艹艹艹艹艹艹艹艹艹艹艹艹艹]]]
    for(int i=jl;i<=jr;i++){
        // 注意 不应修改询问信息
        // 注意 不应修改询问信息
        // 注意 不应修改询问信息
        auto [l,r,k]=Q[q[i]];// [!!!] 注意 这里一定 """不""" 要引用 k !!!!!!
        int tk=T.query(r)-T.query(l-1);
        // cout<<q[i]<<":"<<tk<<"\n";
        if(k<=tk)ql[++cntl]=q[i];
        else qr[++cntr]=q[i];
    }
    memcpy(q+jl,ql+1,sizeof(q[0])*cntl);
    memcpy(q+jl+cntl,qr+1,sizeof(q[0])*cntr);
    pbinary(vl,vm,jl,jl+cntl-1);
    pbinary(vm+1,vr,jl+cntl,jr);
}

void solve(){
    // 标准离散化
    cin>>n>>m;cntA=n;
    for(int i=1;i<=n;i++)cin>>a[i];
    memcpy(A,a,sizeof(a[0])*(n+1));
    sort(A+1,A+1+cntA);
    cntA = unique(A+1,A+1+cntA)-A-1;
    // 为了维护分治中心 pos 计算 _list 二元<值,索引>对
    for(int i=1;i<=n;i++)A_list[i]={getA(a[i]),i};
    sort(A_list+1,A_list+1+n);
    // 标准读入询问
    for(int i=1;i<=m;i++){
        auto&[l,r,k]=Q[i];
        cin>>l>>r>>k;
    }
    // 初始化 n 个位置
    T.init(n);
    // 可能的优化: 只使用查询编号
    iota(q,q+1+m,0);
    pos=0;
    pbinary(1,cntA,1,m);
    for(int i=1;i<=m;i++)cout<<A[ans[i]]<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();    
}
```

#note(title:"题目2 略")[
    + 上一题加 带修 
    - *只需要加一个修改类型的查询op即可*
    - *遍历操作时动态修改权值树状数组*
    - *分组依据为修改后值*
]

#note(title:"题目3 略")[
    + 离线查询 `[l,r]` 区间 `x` 的前驱(第 $"rank"(x)-1$小)
    - 套了一个 *CDQ分治* 求rank
]

#note(title:"题目4 略")[
    + 给定一个序列，每次操作可以把某个数 +1 或 -1。要求把序列变成非降数列。
    - 妙!!! 不知道怎么想的 但是反着想确实有这个必要性
    - 整体二分中间的索引边界值 `vm` 看看 `vm` 位于哪里代价(分别到`vm`和`vm+1`)更小
    - 用这个索引边界值将数组索引二分
]

#note(title:"题目5 略 P1527")[
    + 二维矩阵查询第 `k` 小
    - 妙!!! 
    - 看似繁琐的二维区间 其实确实可以 *二分答案*
    - 这样就不像线段树那样烦
]

#note(title:"题目6 略 P3250")[
    + `0 x y v` `x` 到 `y` 的每个节点集合加个 `v`
    + `1 t` 撤回时间为 `t` 的操作 `0`
    + `2 x` 查询与 `x` 无关的操作 `0` 中最大的 `v` 或者 `-1`
    - *二分答案* 神了
    - 把直接求解 转化为间接判断: 直接判断指定的 `v` 是否有过操作覆盖
    - *头一次知道* 树上快速路径点权+v 可以使用 *dfn序 + 树状数组* 
    - *因为路径差分的求和结果是子树和!!!!*
    - PS:不要盲目, 要变通, 不要以为处理的操作只能是 `[lv,mv]` 只要是一半,可以撤回就行
]

#note(title:"题目7 略 P3242")[
    + 若干个 A 路径 B 路径, A 路径有权值 求每一个 B 路径中完全包含的A路径的第 `k` 小权值
    - 难点其实是 *路径包含的判定* 及其 *快速求解*
    - *路径包含判定*: 对于每一个 a 路径, 显然可选的 b 路径的两个端点可以用 root, lca, x, y, x/y方向上lca的儿子 的 *dfn序* 区间拼凑而成
    - 根据 *乘法原理* 可以想出来 可以由一个由 b 的两个端点的 *dfn序* 组成的 *二维矩形区间+1* 表示贡献 
    - 想要查询某个 b 包含 a 的个数(二分答案) 可以 *单点查询* 
    - 为了压缩空间 可以适用 *扫描线* 一个矩形拆成两个操作 区间+1,区间-1 单点查询同样也是一个操作 
    - 按照将所有操作按照 *第一维* 排序, 用*树状数组*维护 *第二维* 
]

#note(title:"题目8 略 CF603E")[
    + 询问前 `i=1,2,3...m` 条边集构成的图 是否存在每个点都是 *奇度* 的子图 如果有 求子图的最小的边权最大值
    - 是的, 这是 *全奇度节点子图存在性* 的结论
        - *全奇度节点子图存在 <=> 所有的连通分量的大小都是偶数 <=> 不存在奇数大小连通分量*
        - *可能的构造方式:* 
            - 每个连通子图任意一点 BFS(建立树结构)
            - 从下网上递推 如果儿子数量是偶数 则与父亲连边, 否则不与父亲连边
    - 我会时空穿越, 我从 *分块* 章节知道, 这里一定重点讲解 *可撤销并查集* 的使用 因为边是有顺序加的 
    - 但是应该怎么控制边的加入?
        - 首先 最大值 一定来自 边权 可以使用 *边号* 代表 *边权*
        - 容易知道 来到一个 calc 节点 一定要伴随着 `<jl` 且 `<vl` 的边已经全部加入到队列中了
        - 但这还不够 因为此处需要进一步根据 `vm` 二分, 需要继续加入 `<jl` 且 `[vl,vm]` 的所有边
        - 显然我们不能为了前提, 乖乖暴力遍历 `<jl` 的所有边 否则就是 $O(n^2log n)$ 了
            - 注意到这里是 *双维度*, 我们可以换个维度枚举 `[vl,vm]` 的所有边, 这样均摊总和就是 $O(n log n)$!!!
            - 怎么实现? 拷贝一份边集 按照 `v` 排序 !!!
        - 特别注意, 接下来的两侧递归 严格保证递归前提: "`<jl` 且 `<vl` 的边已经全部加入到队列中了" 
            - 所以要使用 *撤销操作* !!!
]

#note(title:"题目9(bushi) 略 CF1100F")[
    + `arr[l..r]` 范围内最大异或和(典) 虽然整体二分(不满足单调性)(但是代码结构推荐整体二分, 因为节省bitset存储空间)
    - 妙!!! 类似 *分治* 但是 *只分不治*
    - 解法: 
        - 类似线段树 建立节点 每一个节点暴力设置 `mid->l, mid->r` 的线性基缀和
        - 找到第一个同时满足 `l<=mv<=r` 的节点 显然目标线性基 为 `merge(base[l],base[r])`
]

=== 莫队算法

==== 普通莫队

#note(title:"模板 P3709")[
    + `l r` 查询区间 词频最大值
]

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=2e5+5;
int n,m,len;
struct Query{
    int id,l,r;
    bool operator<(const Query& o)const {
        // 正宗的块间排序
        // [唐唐唐] 你为什么在这里写 < 
        if((l-1)/len+1!=(o.l-1)/len+1)return l<o.l;
        // 正宗的块内奇升偶降排序
        return (((l-1)/len+1)&1)?r<o.r:r>o.r;
    }
}q[N];
int a[N];// 原数组
int cnt[N];// v 的词频
int cntcnt[N];// 词频为 f 的个数
int ans[N];// 查询 [l,r] 区间 最大词频
int cur_ans;// 当前 [l,r] 区间 最大词频
// v 的词频+1
void add(int v){
    cntcnt[cnt[v]]--;
    cntcnt[++cnt[v]]++;
    if(cnt[v]>cur_ans)cur_ans++;// assert
}
// v 的词频-1
void del(int v){
    cntcnt[cnt[v]]--;
    cntcnt[--cnt[v]]++;
    if(!cntcnt[cur_ans])cur_ans--;// assert
}
int A[N],cntA;
int getA(int v){return lower_bound(A+1,A+1+cntA,v)-A;}
void solve(){
    cin>>n>>m;
    len=ceil(sqrt(n));

    for(int i=1;i<=n;i++)cin>>a[i],A[++cntA]=a[i];
    sort(A+1,A+1+cntA);
    cntA=unique(A+1,A+1+cntA)-A-1;
    for(int i=1;i<=n;i++)a[i]=getA(a[i]);
    
    for(int i=1;i<=m;i++)
        cin>>q[i].l>>q[i].r,q[i].id=i;
    sort(q+1,q+1+m);

    cntcnt[0]=0;
    for(int i=1,l=1,r=0;i<=m;i++){
        auto[id,L,R]=q[i];
        while(L<l)add(a[--l]);
        while(r<R)add(a[++r]);
        while(l<L)del(a[l++]);
        while(R<r)del(a[r--]);
        ans[id]=cur_ans;
    }
    for(int i=1;i<=m;i++)cout<<-ans[i]<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

==== 带修莫队

#note(title:"复杂度分析")[
    - 排序方式 
        + l 所在块升序 
        + r 所在块升序 (注意这一维不再有序)
        + t 升序
    设 数组长度 $n$ 块长 $x$ 查询个数 $m$ 修改个数 $t$ 
    + 块内复杂度: $O(m x + (n/x)^2 t)$ (总 lr 变动 + $(n/x)^2$趟修改)
    + 块间复杂度: $O((n/x)^2 n)$ ($(n/x)^2$ 个组间的切换) (Wiki 不计, 但是模板题不计的话按这个就 TLE 了, 原因可能是块算小了)
    - 我自认为疑似: $x=((2 n^2 (n+t))/m)^(1/3)$
    - $m=t=n$ 时: $x=(4n^2)^(1/3)$ (哪来的4??? 但是模板题确实比不加4更快)
    - 最终复杂度约为: $O(n^(5/3))$
    + 求导=0 得到 $x=$
]

#note(title:"模板 P1903")[
    + `1 l r` 查询区间 元素种类数
    + `2 p v` 单点修改元素值
]

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=14e4+5,NUM=1e6+5;
int n,_,m,t,len;
struct Modify{
    int p,v;
}modify[N];
struct Query{
    int id,L,R,T;
    bool operator<(const Query& o)const {
        if((L-1)/len+1!=(o.L-1)/len+1)return L<o.L;
        if((R-1)/len+1!=(o.R-1)/len+1)return R<o.R;
        return T<o.T;
    }
}q[N];
int a[N];
int cnt[NUM];
int cur_type;
int ans[N];
void add(int v){if(++cnt[v]==1)cur_type++;}
void del(int v){if(--cnt[v]==0)cur_type--;}
void change(int L,int R,int i){
    auto& [p,v]=modify[i];
    if(L<=p&&p<=R)del(a[p]),add(v);
    swap(a[p],v);
}
void solve(){
    cin>>n>>_;
    for(int i=1;i<=n;i++)cin>>a[i];
    for(int i=1;i<=_;i++){
        char op;cin>>op;
        if(op=='Q'){
            auto& [id,L,R,T]=q[++m];
            id=m;T=t;
            cin>>L>>R;
        }else {
            auto& [p,v]=modify[++t];
            cin>>p>>v;
        }
    }
    // assert(m) // 必须有输出呗
    // len=ceil(pow(n,2.0/3));// 6.35s
    // len=ceil(pow(4.0*n*n,1.0/3));// 4.84s [嘿嘿] 我就说嘛!!!
    len=max(1,(int)pow(2.0*n*n*(n+t)/max(1,m),1.0/3));// 4.34s [嘿嘿] 我就说嘛!!!
    sort(q+1,q+1+m);
    int l=1,r=0,t=0;
    for(int i=1;i<=m;i++){
        auto[id,L,R,T]=q[i];
        while(L<l)add(a[--l]);
        while(r<R)add(a[++r]);
        while(l<L)del(a[l++]);
        while(R<r)del(a[r--]);
        while(t<T)change(L,R,++t);
        while(T<t)change(L,R,t--);
        ans[id]=cur_type;
    }
    for(int i=1;i<=m;i++)cout<<ans[i]<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

==== 回滚莫队

===== 只增回滚莫队

#note[
    前提
    + 只有当 `add` 操作时 方便更新答案

    过程
    + 排序
        + `L块号` 升序
        + `R` 升序
    + 遍历每一个块(`len=ceil(sqrt(n))`)
        + 首先清空莫队信息 
            - `ed=min(n,i*len), l=ed+1, r=ed`
            - `fill, memset`
        + `R<=ed` 调用 `force`
        + `R>ed` 
            - 右扩(当前未左扩) `add_r / add` (`while(r<R)`)
            - 缓存 仅右扩答案 `tmp_ans` 
            - 左扩 `add_l / add` (`while(L<l)`)
            - 得到答案 `ans[id]=cur_ans`
            - 回滚 ans `cur_ans=tmp_ans`
            - 回滚 l `del_l / del` (`while(l<ed+1)`) (此处仅用于撤回由 `add_l / add` 造成的间接答案信息)
    - PS: 易错点: `q[qi]` 不是 `q[i]` !!!
]

#note(title:"模板")[
    + `l r` 查询 `[l,r]` 范围内相同数字的最远距离
]

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=2e5+5;
int n,m,len;
int a[N],A[N],cntA;
int getA(int v){return lower_bound(A+1,A+1+cntA,v)-A;}
struct Query{
    int id,L,R;
    bool operator<(const Query& o)const {
        // 第一关键字: L 块号
        if((L-1)/len+1!=(o.L-1)/len+1)return L<o.L;
        // 第二关键字: R (特别注意)
        return R<o.R;
    }
}q[N];
int f_fst[N];// 暴力专用
int force(int L,int R){
    int res=0;
    for(int i=L;i<=R;i++){
        if(!f_fst[a[i]])f_fst[a[i]]=i;
        else res=max(res,i-f_fst[a[i]]);
    }
    // 清空
    for(int i=L;i<=R;i++)
        f_fst[a[i]]=0;
    return res;
}
int lst[N];// 数字 i 最右侧的位置
int fst[N];// 数字 i 最左侧的位置 
int cur_ans;// 当前答案
int ans[N];
void add_l(int i){
    // cout<<"add_l:"<<i<<" "<<a[i]<<"\n";
    // 左侧 i 处进队 需要查询 lst 
    /*
    注意 fst 不需要更新 因为 fst 是用于 add_r 求答案的 
    但是 只增回滚莫队 总是先 add_r 再 add_l 之后 del_l
    所以 add_r 所遭遇的信息 总是之前的 add_r 计算出的, 与 add_l 无关 
    */
   int v=a[i];
   // 1. lst=0
   if(!lst[v])lst[v]=i;
   // 2. lst!=0
   else cur_ans=max(cur_ans,lst[v]-i);
}
void add_r(int i){
    // cout<<"add_r:"<<i<<" "<<a[i]<<"\n";
    int v=a[i];
    if(!fst[v])fst[v]=i;
    lst[v]=i;// 永远直接赋值
    cur_ans=max(cur_ans,i-fst[v]);// [艹] 原来是 i v 混了!!!!
}
// del_l 的主要功能是 用于撤回 自己由于 add_l 修改的间接答案信息 
// 需要传一个小小的 ed
void del_l(int ed,int i){
    // cout<<"del_l:"<<i<<" "<<a[i]<<"\n";
    int v=a[i];
    if(lst[v]<ed)lst[v]=0;
}
// 只增回滚莫队 del_r 是不存在的
// void del_r(int i){}

void solve(){
    cin>>n;
    len=ceil(sqrt(n));
    for(int i=1;i<=n;i++)cin>>a[i],A[++cntA]=a[i];
    sort(A+1,A+1+cntA);
    cntA=unique(A+1,A+1+cntA)-A-1;
    for(int i=1;i<=n;i++)a[i]=getA(a[i]);
    // for(int i=1;i<=n;i++){
    //     cout<<a[i]<<", ";
    // }cout<<"\n";
    cin>>m;
    for(int i=1;i<=m;i++){
        auto& [id,L,R]=q[i];
        cin>>L>>R;id=i;
    }
    sort(q+1,q+1+m);
    int qi=1,bn=(n+len-1)/len;
    for(int i=1;i<=bn;i++){
        int ed=min(n,i*len);
        // 注意这里 l,r归位 一切记录清零
        // 相当于 初始化多次 普通莫队
        int l=ed+1,r=ed;
        fill(fst,fst+1+cntA,0);
        fill(lst,lst+1+cntA,0);
        cur_ans=0;
        for(;qi<=m&&q[qi].L<=ed;qi++){
            auto[id,L,R]=q[qi];
            // cout<<"id "<<id<<" L "<<L<<" R "<<R<<"\n";
            if(R<=ed){
                // cout<<"force!\n";
                ans[id]=force(L,R);
            }else {
                // 此处 还未左扩 先右扩
                while(r<R)add_r(++r);
                int tmp_ans=cur_ans;// 存储此时的仅右扩答案
                while(L<l)add_l(--l);
                ans[id]=cur_ans;
                // cout<<"ans="<<cur_ans<<"\n";
                cur_ans=tmp_ans;// 回档
                while(l<ed+1)del_l(ed,l++);// 只增的回滚莫队 不会在 del 中更新 ans
            }
        }
    }
    for(int i=1;i<=m;i++)cout<<ans[i]<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

===== 只删回滚莫队

#note[
    前提
    + 计算出 `[1,n]` 答案后 通过 `del` 方便得到答案 

    过程
    + 排序
        + `L块号` 升序
        + `R` 降序!!!
    + *初始化计算答案* 
        - `l=1, r=n`
        - `cur_ans`
    + 遍历每一个块(`len=ceil(sqrt(n))`)
        + 首先*更新*莫队信息 
            - `st=(i-1)*len+1, ed=min(n,i*len)` (`ed` 还是需要的)
            - 左缩 `del_l / del` (`while(l<st)`) (不再 `fill, memset`)
            - 缓存 `tmp_job=cur_ans`
        + 继续遍历每个 `R` (无需考虑 `force`)
            - 右缩(当前未左缩) `del_r / del` (`while(R<r)`)
            - 缓存 仅右缩答案 `tmp_ans=cur_ans`
            - 左缩 `del_l / del` (`while(l<L)`)
            - 得到答案 `ans[id]=cur_ans`
            - 回滚 ans `cur_ans=tmp_ans`
            - 回滚 l `add_l / add` (`while(st<l)`)
        + 额外的回滚
            - `add_r / add` (`while(r<n)`)
            - `cur_ans=tmp_job`
    - PS: 易错点: `q[qi]` 不是 `q[i]` !!!
]

#note(title:"模板")[
    + `l r` 区间 `[l,r]` 求 `mex`
    - PS: 好像确实只增做不了 可能爆 `++cur_ans`
]

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=2e5+5;
int n,m,len;
int a[N];
struct Query{
    int id,L,R;
    bool operator<(const Query& o)const {
        if((L-1)/len+1!=(o.L-1)/len+1)return L<o.L;
        return R>o.R;
    }
}q[N];
int cur_ans,tmp_ans,tmp_job;
int cnt[N];
int ans[N];
void add(int v){
    ++cnt[v];
    // 不要改答案 虽然你可以计算 但是这里是只删!!!
    // while(cnt[cur_ans])cur_ans++; 
}
void del(int v){
    if(--cnt[v]==0&&v<cur_ans)cur_ans=v;
}
void solve(){
    cin>>n>>m;
    len=ceil(sqrt(n));
    for(int i=1;i<=n;i++)cin>>a[i],cnt[a[i]]++;
    for(int i=1;i<=m;i++){
        auto&[id,L,R]=q[i];
        cin>>L>>R;id=i;
    }
    sort(q+1,q+1+m);
    int qi=1,bn=(n+len-1)/len,l=1,r=n;
    /* 在调用之前请先计算出 [1,n] 的全局答案 */
    while(cnt[cur_ans])cur_ans++;
    for(int i=1;i<=bn;i++){
        int st=(i-1)*len+1,ed=min(n,i*len);// ed 还是需要的
        while(l<st)del(a[l++]);// 从 [st1,n] 删除一块 
        tmp_job=cur_ans;// 缓存 job [st2,n]
        for(;qi<=m&&q[qi].L<=ed;qi++){
            auto[id,L,R]=q[qi];// [艹] 注意这里 qi !!! 
            while(R<r)del(a[r--]);
            tmp_ans=cur_ans;
            while(l<L)del(a[l++]);
            ans[id]=cur_ans;
            cur_ans=tmp_ans;
            while(st<l)add(a[--l]);// 恢复 [l=st2]
        }
        while(r<n)add(a[++r]);// 恢复 [r=n]
        cur_ans=tmp_job;// 复原 [st2,n]
    }
    for(int i=1;i<=m;i++)cout<<ans[i]<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

==== 树上莫队

#note[
    括号序
    - 出现一次有效 两次无效

    前提
    + 树上的路劲信息 用 树链剖分+线段树 不方便维护
    
    顺序
    + 生成括号序 `seg[N*2]`
        - 任意节点都出现两次 `bl[N],br[N]`
    + 对于查询 `x y` (假设 `bl[x]<bl[y]`)
        + $x=="lca"$: `seg[bl[x]...br[y]]`
        + $x!="lca"$: `seg[br[x]...br[y]]` 
]

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=1e5+5;
int n,typ,_,m,t,len;
int val[N],wei[N],can[N];

// 建树 + 求解 lca
vector<int> e[N];
int dep[N];
int rmq[N][__lg(N)+2],P,dfn[N],dfncnt;
// 括号序!!!
int seg[N*2],cntS,bl[N],br[N];
int upper(int a,int b){return dep[a]<dep[b]?a:b;}
void dfs(int u,int fa){
    rmq[dfn[u]=++dfncnt][0]=fa;
    seg[bl[u]=++cntS]=u;
    dep[u]=dep[fa]+1;
    for(auto v:e[u])if(v!=fa)dfs(v,u);
    seg[br[u]=++cntS]=u;
}
void build(){
    P=__lg(n);
    for(int p=1;p<=P;p++){
        for(int i=1;i<=n;i++){
            int ed=min(n,i+(1<<(p-1)));
            rmq[i][p]=upper(rmq[i][p-1],rmq[ed][p-1]);    
        }
    }
}
int lca(int a,int b){
    int l=dfn[a],r=dfn[b];
    if(l>r)swap(l,r);// [艹] 你 swap(a,b) 干什么!!!
    if(l==r)return a;
    l++;// 注意 dfn 序的求 lca 从 l+1 !!!
    int p=__lg(r-l+1);
    return upper(rmq[l][p],rmq[r-(1<<p)+1][p]);
}

// 单点修改 can[p]
struct Modify{int u,c;}modify[N];
struct Query{
    int id,L,R,T,lca;// 注意这里还有 lca
    // 这里是带修莫队
    // 一般莫队按找奇偶写 
    bool operator<(const Query& o)const {
        if((L-1)/len+1!=(o.L-1)/len+1)return L<o.L;
        if((R-1)/len+1!=(o.R-1)/len+1)return R<o.R;
        return T<o.T;
    }
}q[N];

bool vis[N];
int cnt[N];
LL cur_ans;
LL ans[N];

// 原子操作: 增加一个 c 值
void add(int c){
    cur_ans+=(LL)val[c]*wei[++cnt[c]];
}
// 原子操作: 减少一个 c 值
void del(int c){
    cur_ans-=(LL)val[c]*wei[cnt[c]--];
}
// 改变节点 u 的有无
void toggle(int u){
    if(!vis[u])add(can[u]);
    else del(can[u]);
    vis[u]=!vis[u];
}
// 启用第 i 个修改
void change(int i){
    auto& [u,c]=modify[i];
    if(vis[u]){
        del(can[u]);
        add(c);
    }
    swap(can[u],c);
}

void solve(){
    cin>>n>>typ>>_;
    for(int i=1;i<=typ;i++)cin>>val[i];
    for(int i=1;i<=n;i++)cin>>wei[i];
    for(int i=1,u,v;i<n;i++){
        cin>>u>>v;
        e[u].push_back(v);
        e[v].push_back(u);
    }
    for(int i=1;i<=n;i++)cin>>can[i];
    dfs(1,0);
    build();
    for(int op,x,y,i=1;i<=_;i++){
        cin>>op>>x>>y;
        if(op==0)modify[++t]={x,y};
        else {
            ++m;
            if(bl[x]>br[y])swap(x,y);
            int z=lca(x,y);
            if(z==x)q[m]={m,bl[x],bl[y],t,0};// 无 lca
            else q[m]={m,br[x],bl[y],t,z};// 有 lca
        }
    }
    // 注意了 这里是按照 cntS 分块
    len=ceil(pow(2.0*cntS*cntS,1.0/3));
    sort(q+1,q+1+m);
    for(int i=1,l=1,r=0,t=0;i<=m;i++){
        auto[id,L,R,T,lca]=q[i];
        while(L<l)toggle(seg[--l]);
        while(r<R)toggle(seg[++r]);
        while(l<L)toggle(seg[l++]);
        while(R<r)toggle(seg[r--]);
        // 时间!!!
        while(t<T)change(++t);
        while(T<t)change(t--);
        if(lca)toggle(lca);// lca 处理
        ans[id]=cur_ans;
        if(lca)toggle(lca);// lca 撤销 
    }
    for(int i=1;i<=m;i++)cout<<ans[i]<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

==== 莫队二次离线

#note[
    前提
    - 直接算不好算 考虑增量(差分值)

    过程
    + 预设可差分信息(前后缀和), 答案的变化量 分解为两个部分
    + 执行普通莫队
        + 第一次离线, 得到变化量的第一部分 生成第二次离线的查询任务
        + 第二次离线, 得到变化量的第二部分, 答案求解完毕
    + 变化量的前缀和就是答案

    复杂度
    - 第二次离线枚举的总代价 = 普通莫队滑窗的总距离 = $O(n sqrt(n))$
]

#note(title:"题目1 第1种 详细 写法")[
    + 给定全局 `k`
        - `l r` 求 `[l,r]` 区间异或恰好有 `k` 个 `1` 的对 ($i<j$) 的数量 
    - 考虑计算增量
        - 右扩时: `[l,r] [r+1,R]` 
            - 差分一下得到 (`[r+1,R]` 逐一与*前缀*的匹配数的和(即*前缀*跑 `cnt[i]` 信息时顺带求得"区间和" `pre[i]`) - `[r+1,R]` 全部与 `[1,l-1]` 的匹配数的和(即二次离线处理*前缀* `[1,l-1]` 时计算)) (注意这里的右扩时取 `1` 啊!!!)
        - 右缩时: 交换 `r,R`, `op` 取 `1`  即可 (注意非二次离线信息取 `-=`)
        - 左扩时: `[L,l-1] [l,r]`
            - 差分一下得到 (`[L,l-1]` 逐一与*后缀*的匹配数的和(即*后缀*跑 `cnt[i]` 信息时顺带求得"区间和" `suf[i]`) - `[L,l-1]` 全部与 `[r+1,n]` 的匹配数的和(即二次离线处理*后缀* `[r+1,n]` 时计算))
        - 左缩时: 交换 `l,L`, `op` 取 `-1` 即可 (注意非二次离线信息取 `-=`)
]

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=1e5+5,V=(1<<14)+1;
int n,m,k,len;
int a[N];
struct Query{
    int id,L,R;
    bool operator<(const Query& o)const {
        if((L-1)/len+1!=(o.L-1)/len+1)return L<o.L;
        return ((L-1)/len+1)&1?R<o.R:R>o.R;
    }
}q[N];
struct Query2{
    int id,l,r,op;// 哦 这里不用写 x
};
vector<Query2> q2l[N],q2r[N];
vector<int> cand;

int cnt[V];
LL pre[N],suf[N];
LL ans[N];

void solve(){
    cin>>n>>m>>k;
    cand.clear();
    for(int i=0;i<(1<<14);i++)
        if(__builtin_popcount(i)==k)cand.push_back(i);
    len=ceil(sqrt(n));
    for(int i=1;i<=n;i++)cin>>a[i];
    for(int i=1;i<=m;i++){
        auto&[id,L,R]=q[i];
        cin>>L>>R;id=i;
    }
    if(k>14){// 特判!!!
        while(m--)cout<<0<<"\n";
        return;
    }
    sort(q+1,q+1+m);
    // 清空
    fill(cnt,cnt+V,0);
    // 首先预处理 辅助信息 pre
    for(int i=1;i<=n;i++){
        pre[i]=pre[i-1]+cnt[a[i]];
        for(auto v:cand)cnt[a[i]^v]++;
    }
    fill(cnt,cnt+V,0);
    // 首先预处理 辅助信息 suf
    for(int i=n;i>=1;i--){
        suf[i]=suf[i+1]+cnt[a[i]];
        for(auto v:cand)cnt[a[i]^v]++;
    }
    // 首先 第一次莫队 走个形式
    for(int i=1,l=1,r=0;i<=m;i++){
        auto[id,L,R]=q[i];
        // [!!!] 事实上 先右扩右缩 然后左扩左缩 节省代码行数 r=R l=L
        if(r<R){// 右扩 [l,r] -> [r+1,R] ans+= pre[r+1,R] - 二次离线左
            q2l[l-1].push_back({id,r+1,R,-1});
            ans[id]+=pre[R]-pre[r];
        }
        if(R<r){// 右缩
            q2l[l-1].push_back({id,R+1,r,1});
            ans[id]-=pre[r]-pre[R];
        }
        r=R;
        if(L<l){// 左扩 [L,l-1] <- [l,r] ans+= suf[L,l-1] - 二次离线右
            q2r[r+1].push_back({id,L,l-1,-1}); 
            ans[id]+=suf[L]-suf[l];
        }
        if(l<L){// 左缩 [l,L-1] -> [L,r]
            q2r[r+1].push_back({id,l,L-1,1}); // 那么这里只需要 互换后 变为 -1
            // 那么现在这里其实连符号都不用变了 ? 不对 得变!!!!
            ans[id]-=suf[l]-suf[L];
        }
        l=L;
        // [艹] 忘了 !!! 不应该在这里一起赋值 l r 
    }
    // 第二次莫队 
    fill(cnt,cnt+V,0);
    // 先玩 q2l[0,n] 注意这里从 0 开始
    for(int i=0;i<=n;i++){
        if(i>=1)for(auto v:cand)cnt[v^a[i]]++;
        for(auto [id,L,R,op]:q2l[i]){
            // 乖乖站好
            for(int i=L;i<=R;i++)ans[id]+=op*cnt[a[i]];
        }
    }
    fill(cnt,cnt+V,0);
    // 再 q2r[n+1,1] 注意这里从 n+1 开始
    for(int i=n+1;i>=1;i--){
        if(i<=n)for(auto v:cand)cnt[v^a[i]]++;
        for(auto [id,L,R,op]:q2r[i]){
            // 乖乖站好
            for(int i=L;i<=R;i++)ans[id]+=op*cnt[a[i]];
        }
    }
    // 因为是离线啊 所以别忘了求一个前缀和 
    // [艹] 依赖关系不是 i-1 而是 q[i-1].id !!!
    for(int i=2;i<=m;i++)
        ans[q[i].id]+=ans[q[i-1].id];
    for(int i=1;i<=m;i++)
        cout<<ans[i]<<"\n";
}
int main(){
    // cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

#note(title:"题目2 第1种 详细 写法")[
    + `l r` 查询 `[l,r]` 区间内的 逆序对 个数 (注意:数字可重复)
    - !!! 我突然发现 这种 二次离线算法 不太需要考虑匹配的相对大小 只需要枚举 第二个数字的角色即可! 
    - 右扩时 `[l,r] -> [r+1,R]`
        - 新增逆序对个数 = (`[r+1,R]` 逐一 *前缀* *大于* 该值的数量(查询次数少$O(n)$, 使用树状数组动态计算, 使用 `pre[i]`) - `[r+1,R]` 小于 `[1,l-1]` 的数量和(查询次数多$O(n sqrt(n))$, 使用更高效的查询结构:*值域分块*))
    - 右缩时 交换 `r,R` + 变号
    - 左扩时 `[L,l-1] <- [l,r]`
        - 新增逆序对个数 = (`[L,l-1]` 逐一 *后缀* *小于* 该值的数量(查询次数少$O(n)$, 使用树状数组动态计算 使用 `suf[i]`) - `[L,l-1]` 小于 `[r+1,n]` 的数量和(查询次数多$O(n sqrt(n))$, 使用更高效的查询结构:*值域分块*))
    - 左缩时 交换 `l,L` + 变号
]

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=1e5+5,B=355;
int n,m,len;
int a[N],A[N],cntA;
int getA(int v){return lower_bound(A+1,A+1+cntA,v)-A;}

// 树状数组 
struct BIT{
    int n;
    vector<int> tr;
    void init(int n){
        this->n=n+1;
        tr.assign(n+2,0);
    }
    // 区间加 O(log n)
    void add(int i,int v){for(i++;i<=n;i+=i&-i)tr[i]+=v;}
    // 单点查 O(log n)
    int query(int i){int res=0;for(i++;i;i-=i&-i)res+=tr[i];return res;}
}Tree;
// 块状数组
struct BArray{
    int n,len,bn;
    int a[N],id[N];
    int st[B],ed[B],tag[N];
    void init(int n){
        len=ceil(sqrt(n));
        bn=(n+len-1)/len;
        for(int i=1;i<=bn;i++){
            st[i]=(i-1)*len+1;
            ed[i]=min(n,st[i]+len-1);
            fill(id+st[i],id+ed[i]+1,i);
        }
        // 清空数据!!!
        fill(a,a+n+1,0);
        fill(tag,tag+1+bn,0);
    }
    // 区间加 O(sqrt(n)) 
    void add(int l,int r,int v){
        if(l>r)return;// [!? 艹 ?!] 缺少处理? ??????
        int L=id[l],R=id[r];
        if(L==R){
            for(int i=l;i<=r;i++)a[i]+=v;
        }else {
            for(int i=l;i<=ed[L];i++)a[i]+=v;
            for(int i=st[R];i<=r;i++)a[i]+=v;
            for(int i=L+1;i<=R-1;i++)tag[i]+=v;
        }
    }
    // 单点查 O(1)
    int query(int i){return a[i]+tag[id[i]];}
}Arr;

struct Query{
    int id,L,R;
    bool operator<(const Query& o)const {
        if((L-1)/len+1!=(o.L-1)/len+1)return L<o.L;
        return ((L-1)/len+1)&1?R<o.R:R>o.R;
    }
}q[N];
struct Query2{int id,L,R,op;};
vector<Query2> q2l[N],q2r[N];

// 注意 pre
LL pre[N],suf[N];
LL ans[N];

void solve(){
    cin>>n>>m;
    len=ceil(sqrt(n));
    for(int i=1;i<=n;i++)cin>>a[i],A[++cntA]=a[i];
    sort(A+1,A+1+cntA);
    cntA=unique(A+1,A+1+cntA)-A-1;
    for(int i=1;i<=n;i++)a[i]=getA(a[i]);
    for(int i=1;i<=m;i++){
        auto&[id,L,R]=q[i];
        cin>>L>>R;id=i;
    }
    sort(q+1,q+1+m);
    // 预处理信息
    Tree.init(cntA);
    for(int i=1;i<=n;i++){
        pre[i]=pre[i-1]+Tree.query(cntA)-Tree.query(a[i]);
        Tree.add(a[i],1);
    }
    Tree.init(cntA);
    for(int i=n;i>=1;i--){
        suf[i]=suf[i+1]+Tree.query(a[i]-1);
        Tree.add(a[i],1);
    }
    for(int i=1,l=1,r=0;i<=m;i++){
        auto[id,L,R]=q[i];
        if(r<R){// 右扩 右边的连续增量 - 左边的定点查询
            ans[id]+=pre[R]-pre[r];
            q2l[l-1].push_back({id,r+1,R,-1});
        }
        if(R<r){// 右缩
            ans[id]-=pre[r]-pre[R];
            q2l[l-1].push_back({id,R+1,r,1});
        }
        r=R;
        if(L<l){// 左扩 左边的增量 - 右边的定点查询 
            ans[id]+=suf[L]-suf[l];
            q2r[r+1].push_back({id,L,l-1,-1});
        }
        if(l<L){// 左缩
            ans[id]-=suf[l]-suf[L];
            q2r[r+1].push_back({id,l,L-1,1});
        }
        l=L;
    }
    // 开始二次离线
    // 先处理左边的定点查询 查询的必然是 >x 的数量
    Arr.init(cntA);
    for(int i=0;i<=n;i++){
        if(i>=1)Arr.add(1,a[i]-1,1);// 受益者必然是 < a[i] 的
        for(auto[id,L,R,op]:q2l[i])
            for(int i=L;i<=R;i++)
                ans[id]+=op*Arr.query(a[i]);
    }
    // 然后处理右边的定点查询 查询的必然是 <x 的数量
    Arr.init(cntA);
    for(int i=n+1;i>=1;i--){
        if(i<=n)Arr.add(a[i]+1,cntA,1);// 收益者必然是 > a[i] 的
        for(auto[id,L,R,op]:q2r[i])
            for(int i=L;i<=R;i++)
                ans[id]+=op*Arr.query(a[i]);
    }
    for(int i=2;i<=m;i++)ans[q[i].id]+=ans[q[i-1].id];
    for(int i=1;i<=m;i++)cout<<ans[i]<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

#note(title:"题目3 第2种 紧凑 写法")[
    + `l r` 查询 `[l,r]` 区间内的 $sum_i a[i] times "rank"(a[i])$
    - 很显然增量法 很好想
    - 在 *第2种写法* 中, 我们有时会将不同含义的 同阶数据放在一起求 使用小小的容斥处理
    - 右扩时 `[l,r] -> [r+1,R]`
        - 新增值 = (`[r+1,R]` 逐一 *前缀* *大于*该值 的 和 + 该值 $times$ (*小于* 该值 的 数量 *+ 1*(这挺烦的??? 在这里加任意常数居然没有任何效果!!! 仍然需要补充:*我们发现 常系数需要在最终答案中补充 不要在递推过程中使用?!*) ) - `[r+1,R]` 关于 定点 `l-1` 的对应信息... )
    - 右删时 交换 `r,R` + 变号
    - *注意看!!!* 我们不想依赖 `suf` 了, 希望 使用容斥
    - *注意看!!!* 我们不想依赖 `suf` 了, 希望 使用容斥
    - *注意看!!!* 我们不想依赖 `suf` 了, 希望 使用容斥
    - 左扩时 `[L,l-1] <- [l,r]` 
        - *设* 
            - `f(i,j) : i 点对于后缀 j 的贡献`
            - `g(i,j) : i 点对于前缀 j 的贡献`
            - `self[i] : i 点对自己的贡献`
        - 原本我们在考虑左边的*一个*新点时 使用的是 
            - `f(i,i+1) - f(i,r+1)` $=>$ `(suf[L] - suf[l]) + query2r(r+1,L,l-1) `
        - 但是现在 使用容斥 其实它也等于 
            - `g(i,r) - g(i,i) = g(i,r) - g(i,i-1) - self[i]` $=>$ `query2l(r,L,l-1) - (pre[l-1]-pre[L-1] - self[L,l-1])`
        - 新增值 = (`[L,l-1]` 关于定点 `r` 的对应信息 - (`[L,l-1]` 逐一 *前缀* *大于* 该值 的 和 + 该值 $times$ (*小于* 该值 的数量 *+ 1*)) - `[L,l-1]` 逐一 对自身的贡献信息(*这里特别注意了!!!* 很多时候 贡献为空) )
    - 左删是 交换 `l,L` + 变号即可
]

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=5e5+5,B=740,V=1e5+1;
using LL = long long;
int n,m,len;
int a[N];

struct BIT{
    int n;
    vector<LL> tr;
    void init(int n){
        this->n=n+1;
        tr.assign(n+2,0);
    }
    void add(int i,LL v){for(i++;i<=n;i+=i&-i)tr[i]+=v;}
    LL query(int i){LL res=0;for(i++;i;i-=i&-i)res+=tr[i];return res;}
}Tcnt,Tsum;
struct BArray{
    int n,len,bn;
    LL a[N];
    int id[N];
    int st[B],ed[B];
    LL tag[B];
    void init(int n){
        this->n=n;
        len=ceil(sqrt(n));
        bn=(n+len-1)/len;
        for(int i=1;i<=bn;i++){
            st[i]=(i-1)*len+1;
            ed[i]=min(n,st[i]+len-1);
            fill(id+st[i],id+ed[i]+1,i);
        }
        fill(a,a+1+n,0);
        fill(tag,tag+1+bn,0);
    }
    void add(int l,int r,LL v){
        if(l>r)return;// 有阴影了 !!!
        int L=id[l],R=id[r];
        if(L==R){
            for(int i=l;i<=r;i++)a[i]+=v;
        }else {
            for(int i=l;i<=ed[L];i++)a[i]+=v;
            for(int i=st[R];i<=r;i++)a[i]+=v;
            for(int i=L+1;i<=R-1;i++)tag[i]+=v;
        }
    }
    LL query(int i){return a[i]+tag[id[i]];}
}Acnt,Asum;

struct Query{
    int id,L,R;
    bool operator<(const Query& o)const {
        if((L-1)/len+1!=(o.L-1)/len+1)return L<o.L;
        return ((L-1)/len+1)&1?R<o.R:R>o.R;
    }
}q[N];
struct Query2{int id,L,R,op;};
vector<Query2> q2[N];
LL pre_a[N];
LL pre[N];
LL ans[N];
void solve(){
    cin>>n>>m;
    len=ceil(sqrt(n));
    for(int i=1;i<=n;i++)cin>>a[i],pre_a[i]=pre_a[i-1]+a[i];
    for(int i=1;i<=m;i++){
        auto&[id,L,R]=q[i];
        cin>>L>>R;id=i;
    }
    sort(q+1,q+1+m);
    // 预处理信息
    Tcnt.init(V);Tsum.init(V);
    for(int i=1;i<=n;i++){
        pre[i]=pre[i-1]+(Tsum.query(V)-Tsum.query(a[i]))+(Tcnt.query(a[i]-1)+0)*a[i];
        Tsum.add(a[i],a[i]);
        Tcnt.add(a[i],1);
    }
    // 开始莫队一次
    for(int i=1,l=1,r=0;i<=m;i++){
        auto[id,L,R]=q[i];
        if(r<R){// 右扩 
            ans[id]+=pre[R]-pre[r];
            q2[l-1].push_back({id,r+1,R,-1});
        }
        if(R<r){// 右缩
            ans[id]-=pre[r]-pre[R];
            q2[l-1].push_back({id,R+1,r,1});
        }
        r=R;// 勿忘!!!!
        if(L<l){// 左扩
            q2[r].push_back({id,L,l-1,1});
            ans[id]-=pre[l-1]-pre[L-1];
        }
        if(l<L){
            q2[r].push_back({id,l,L-1,-1});
            ans[id]+=pre[L-1]-pre[l-1];
        }
        l=L;// 勿忘!!!!
    }
    // 开始莫队二次
    Asum.init(V);Acnt.init(V);
    for(int i=0;i<=n;i++){
        if(i>=1){
            Asum.add(1,a[i]-1,a[i]);
            Acnt.add(a[i]+1,V,1);
        }
        for(auto [id,L,R,op]:q2[i])
            for(int i=L;i<=R;i++)
                ans[id]+=op*(Asum.query(a[i])+(Acnt.query(a[i])+0)*a[i]);
    }
    for(int i=2;i<=m;i++)ans[q[i].id]+=ans[q[i-1].id];

    /*
        [!!!] 夭寿了 计算式中的常系数 在做差分时 会被消掉 
        需要在最终的计算结果补上常系数
    */
    for(int i=1;i<=m;i++){
        auto[id,L,R]=q[i];
        ans[id]+=pre_a[R]-pre_a[L-1];
    }
    for(int i=1;i<=m;i++)cout<<ans[i]<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

#note(title:"题目4 第2中 紧凑 写法")[
    + `l r` 查询 `[l,r]` 区间内 互为倍数的二元组的个数 (`i`可以等于`j`)
    -  右扩时 `[l,r]` -> `[r+1,R]`
        - 新增二元组个数 
            - 加上(莫1 $O(m)$ 个查询 必须做到$O(sqrt(n))$修改 $O(sqrt(n))$查询) 
                - `[r+1,R]` 逐一 *前缀* 中 倍数(用根号级分解布置(修改$O(sqrt(n))$查询$O(1)$))+因子数(使用根号级分解枚举(修改$O(1)$查询$O(sqrt(n))$)) 
            - 减去(莫2 基础 $O(n)$ + $O(m)$ 个查询 移动 $O(n sqrt(n))$ 必须做到$O(sqrt(n))$修改 $O(1)$查询) 
                - `[r+1,R]` 关于 `[1,l-1]` 的倍数(根号级分解(修改$O(sqrt(n))$查询$O(1)$))+因子数(考虑*根号分治*:*大于根号*的暴力布置(修改$O(sqrt(n))$查询$O(1)$)) 命中和)
            - 减去(莫3 基础 $O(n)$ + $O(m)$ 个查询) 
                - (`[1,R]` - `[1,r]`) 关于 `[1,l-1]` 的因子数 (枚举 `v` 的时候需要计算 `[1,l-1]` 中 `v` 的个数, 在 `[1,R],[1,r]` 中计算 `v` 的倍数个数)
                - 这样确实可以: 预处理 $O(n sqrt(V))$ + 计算 $O((n+m)sqrt(V))$ 
                - (*根号分治*:枚举根号个因子预处理前缀 `v` 的倍数个数, 在计算每一处前缀 `x` 时批量计算区间 `[l,r]` 中 `v` 的倍数的个数 使用乘法原理组合即可)
    - 右缩时 交换 `r,R` 取负号即可
    - 左扩时 `[L,l-1] <- [l,r]`
        - 新增二元组个数
            - 加上(莫2) 
                - `[L,l-1]` 关于 `[1,r]` 的 倍数+因子数
            - 减去(莫3)
                - 略
            - 减去(莫1)
                - `[L,l-1]` 逐一 *前缀* 中 倍数+因子数
                - `[L,l-1]` 逐一 对自己(值拷贝)的贡献(倍数+因子数) $=>$ 长度的 `2` 倍 (*请注意* 此处对自己的贡献指的是对 *替身* 的贡献, 并不是严格的自己)
    - 左缩时 交换 `l,L` 取负号即可
    - *PS:* 这个 莫3 能不使用定点枚举就不要使用啊
        - 这样会多一个 $O(n)$ 常数级复杂度 (TLE了!!!) 而且 常数爆炸(因为内存访问慢)
        - 不如多存一个 `x`, 直接借用 全体请求(最好不要链式前向星, 因为内存不连续, 用一个全局拷贝 `vector` 吧) 来遍历补充, 仅 $O(m)$  
]

```cpp
/* Coding 体验最差的一集: 洛谷评测机 神人扰动 */
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=5e5+5,V=5e5+1;
int MX,sMX;// 变常量

int n,m,len;
int a[N];

vector<int> factors[V];
void calc(int i){
    // 随取随用 ??? why ???
    if(factors[i].empty()){
        int ed=sqrt(i);
        for(int j=1;j<=ed;j++){
            if(i%j==0){
                factors[i].push_back(j);
                if(j!=i/j)factors[i].push_back(i/j);
            }
        }
    }
}

struct Query{
    int id,L,R;
    bool operator<(const Query& o)const {
        if((L-1)/len+1!=(o.L-1)/len+1)return L<o.L;
        return ((L-1)/len+1)&1?R<o.R:R>o.R;
    }
}q[N];

// 链式前向星虽然 NB 但是 如果你这样同样可以 得到相近的 效率 
// emplace_back 不NB 事实上
struct Query23{
    int id,L,R,op,x;
    // Query23(int ii=0,int LL=0,int RR=0,int oo=0,int xx=0):id(ii),L(LL),R(RR),op(oo),x(xx){}
};
vector<Query23> q23[N],Q;// 虽然这里需要 二倍的空间

LL ans[N];
int cnt_ge[V];// v 命中的 倍数个数
int cntv[V];// 前缀词频统计 (枚举因子)
LL pre[N];// 前缀统计量

void solve(){
    cin>>n>>m;
    len=ceil(sqrt(n));
    for(int i=1;i<=n;i++)cin>>a[i];
    MX=*max_element(a+1,a+1+n);
    // sMX=ceil(sqrt(MX));// 不行啊
    sMX=100;// AC
    for(int i=1;i<=m;i++){
        auto&[id,L,R]=q[i];
        cin>>L>>R;id=i;
    }
    sort(q+1,q+1+m);
    // 预处理:
    for(int i=1;i<=n;i++){
        pre[i]=pre[i-1]+cnt_ge[a[i]];
        calc(a[i]);// !!!
        for(auto v:factors[a[i]]){
            pre[i]+=cntv[v];// 自己命中的前缀因子个数
            cnt_ge[v]++;// 为后续布置倍数统计
        }
        cntv[a[i]]++;// 为后续布置词频
    }
    for(int i=1,l=1,r=0;i<=m;i++){
        const auto& [id,L,R]=q[i];
        if(r<R){// 右扩
            ans[id]+=pre[R]-pre[r];
            q23[l-1].push_back({id,r+1,R,-1,l-1});
            Q.push_back({id,r+1,R,-1,l-1});
        }else if(R<r){// 右缩
            ans[id]-=pre[r]-pre[R];
            q23[l-1].push_back({id,R+1,r,1,l-1});
            Q.push_back({id,R+1,r,1,l-1});
        }
        r=R;
        if(L<l){// 左扩
            q23[r].push_back({id,L,l-1,1,r});
            Q.push_back({id,L,l-1,1,r});
            ans[id]-=pre[l-1]-pre[L-1]+2*(l-1-L+1);
        }else if(l<L){// 左缩
            q23[r].push_back({id,l,L-1,-1,r});
            Q.push_back({id,l,L-1,-1,r});
            ans[id]+=pre[L-1]-pre[l-1]+2*(L-1-l+1);
        }
        l=L;
    }
    // 开始二次离线
    // 重置
    fill(cntv,cntv+MX+1,0);
    for(int i=0;i<=n;i++){
        if(i>=1){
            // 为后续布置倍数
            calc(a[i]);// !!!
            for(const auto& v:factors[a[i]])cntv[v]++;
            // 为后续布置大因子 此处的 cntv[v] 表示 v 命中的因子个数
            if(a[i]>sMX)
                // [艹] 遮沙避风!!!!
                for(int j=a[i];j<=MX;j+=a[i])
                    cntv[j]++;
            }
            // [!!!] 啊啊啊
            for(const auto& [id,L,R,op,x]:q23[i]){
                for(int k=L;k<=R;k++)// [艹] 忘了写这个 for [L,R] 了 !!!
                    ans[id]+=op*cntv[a[k]];// 二合一 !!!
            }
    }
    // 开始三次离线
    // 枚举 v
    for(int v=1;v<=sMX;v++){
        int cnt=0;
        // 预处理 前缀 v 的倍数的个数
        for(int i=1;i<=n;i++){
            pre[i]=pre[i-1]+(a[i]%v==0);
            cntv[i]=cntv[i-1]+(a[i]==v);
        }
        // 开始滚动
        for(const auto& [id,L,R,op,x]:Q)
            ans[id]+=(LL)op*cntv[x]*(pre[R]-pre[L-1]);
    }
    for(int i=2;i<=m;i++)ans[q[i].id]+=ans[q[i-1].id];
    for(int i=1;i<=m;i++)ans[q[i].id]+=q[i].R-q[i].L+1;
    for(int i=1;i<=m;i++)cout<<ans[i]<<"\n";
}
int main(){
    // for(int i=1;i<V;i++)calc(i);// 服了 !!! 我全部预处理竟然 TLE ???
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

#note(title:"临时总结卡常笔记")[
    + *O2 优化能帮我做什么？*
        - 简单的函数内联（Inline）。
        - 把简单的循环展开（Unroll Loops）。
        - *尝试*把小的结构体拷贝优化掉（但在复杂循环里不一定成功）。
        - *尝试*把变量放进寄存器（Register），减少内存读写。
        - *O2 绝不会做*：
            + *改变数据结构布局*：它不能把链表变成数组，也不能把结构体数组（AoS）拆成多个数组（SoA）。
            + *预测你的算法逻辑*：它不知道 `cnt_ge` and `cntv` 可以合并，只有你能做。
            + *消除 Cache Miss*：如果你写的是跳跃访问 `a[b[c[i]]]`，O2 救不了你。

    + 连续 vs 离散（Cache Friendly）
    - *原则*：能用数组（`vector`）就别用链表。
    - *原因*：
            - *数组/Vector*：内存物理连续。CPU 读 `a[i]` 时，硬件预取器（Prefetcher）会自动把 `a[i+1], a[i+2]...` 拉进 L1 Cache。
            - *链式前向星/手写链表*：CPU 无法预测下一个位置，每次跳转都是一次 *Cache Miss*（CPU 停转等待）。

    + 数据结构布局：AoS vs SoA
        - *AoS (Array of Structures)*：`struct Node { int l, r, id; } q[N];`
        - *缺点*：如果你在一个循环里只访问 `l`，CPU 会被迫把不需要的 `r` 和 `id` 也加载进缓存，浪费了 2/3 的缓存行带宽。
        - *SoA (Structure of Arrays)*：`int q_l[N], q_r[N], q_id[N];`
        - *优点*：如果你只遍历 `l`，缓存里塞的全是 `l`，*缓存密度极高*。SIMD（向量化指令）也更容易优化这种结构。
        - *建议*：如果结构体很大且成员访问不绑定，拆成多个数组。

    + 内存带宽减半（Merge Access）
        - *原则*：*能读 1 个地址，绝不读 2 个。*
        - *解释*：在几十亿次的循环里，*Load（读取）指令*往往是流水线的瓶颈。合并数组直接让吞吐量翻倍。

    + 避免“随性”的内存分配（Allocation）
        - *原则*：避免在热路径（Hot Path）上申请内存。
        - *vector 的坑*：
            - `vector::push_back` 可能会触发扩容（malloc + memcpy + free），这是由于操作系统管理的，极慢。
        - *解决*：如果知道大概大小，提前 `v.reserve(size)`。
        - *全预处理 vs 懒加载*：
            - 一次性申请 500,000 个 `vector` 会导致内存碎片化，且挤占 Cache。
            - *懒加载（Lazy）*：用到时才申请，保证了数据在 Cache 中的“热度”。

    + *语法糖的真实开销*
        - *`const auto&`*：
            - *必用场景*：遍历 `vector<Struct>` 或 `vector<string>` 时。不加引用会发生拷贝（Copy），O2 也不一定能完全消除大对象的拷贝。
            - *无所谓场景*：遍历 `vector<int>`。`int` 的拷贝代价极低（一个寄存器指令），加不加引用区别不大。
    + *`emplace_back`*：
        - *作用*：在 vector 尾部*原地构造*对象，省去了一次 构造+拷贝/移动 的过程。
        - *建议*：养成习惯用 `emplace_back`，它在理论上永远不比 `push_back` 慢，且往往更快。

    + 那个极慢的取模（%）
        - *现象*：`x % y` 是 CPU 中最慢的基础指令之一（比加法慢 10-20 倍）。
        - *优化*：
            + *变常量*：`const int MOD = 1e9+7` 比 变量 `mod` 快（编译器会把除法优化为*乘法+移位*）。
            + *减少次数*：如你所做的 `sMX=100`，把 700 次取模压到 100 次，虽然增加了数组加法，但赚翻了。
            + *查表法*：如果模数固定且范围小，预处理 `is_multiple[x]` 数组（用空间换时间）。

    + 总结 Checklist（提交 TLE 前看一眼）
        1.  *最内层循环*里有没有多余的内存读取？能不能合并数组？
        2.  *最内层循环*里有没有 `%` 取模？能不能用加减法或查表代替？
        3.  *遍历*时，数据在内存里是连续的吗？（链表 -> 数组）
        4.  *结构体*是不是太大了？是不是每次只用其中一个字段？（结构体 -> 多数组）
        5.  *循环变量*是不是 `long long`？如果是数组下标，`int` 足够且更快（寄存器友好）。
        6.  *遍历大对象*时，加 `const auto&` 了吗？
]

==== 二维莫队

==== 莫队配合bitset

== 分数规划

#note[
    左神 我快忘了
]

分数规划用来求一个分式的极值。其形式化表述是，给出 $a_i$ 和 $b_i$，求一组 $w_i in {0,1}$，最小化或最大化

$ (sum_(i=1)^n a_i times w_i) / (sum_(i=1)^n b_i times w_i) $

通俗来讲，这类问题类似于：每种物品有两个权值 $a$ 和 $b$，选出若干个物品使得 $ (sum a) / (sum b) $ 最小或最大。

=== 二分法

分数规划问题的通用方法是二分答案法。假设当前二分到的答案为 "mid"，则一组满足条件的 ${w_i}$ 会让权值大于等于 "mid"。根据这一条件列不等式并变形

$ (sum a_i times w_i) / (sum b_i times w_i) >= "mid" \
arrow.r.double sum a_i times w_i - "mid" times sum b_i dot w_i >= 0 \
arrow.r.double sum w_i times (a_i - "mid" times b_i) >= 0 $

那么只要求出不等号左边的式子的最大值就行了。如果最大值比 0 要大，说明 "mid" 是可行的，否则不可行。分数规划的主要难点就在于如何求 $ sum w_i times (a_i - "mid" times b_i) $ 的最大值或最小值。

=== Dinkelbach 算法

#note[
    TO DO ! Dinkelbach 算法
]

Dinkelbach 算法 的大概思想是每次用上一轮的答案当做新的 $L$ 来输入，不断地迭代，直至答案收敛。

== 随机化

=== 关于随机函数的所有都在这里

==== <random> 库的内容

==== rand()

#note[
  弱 (同一秒的运行数据相同)
]

```cpp
srand(time(0));
rand();
```

==== mt19937 & shuffle

#note[
  !? 虽 ?!
]

```cpp
#include<bits/stdc++.h>
using namespace std;
mt19937_64 rng(chrono::steady_clock::now().time_since_epoch().count());
// mt19937_64 rng(time(0));// [禁] 同一秒 重复的数字 
int main(){
    int n=10;
    for(int i=0;i<n;i++){
        vector<int> a(10);
        iota(a.begin(),a.end(),0);
        shuffle(a.begin(),a.end(),rng);
        // random_shuffle(a.begin(),a.end());// [禁] 已经弃用了!!!
        for(auto i:a)cout<<i<<" ";
        cout<<"\n";
    }
}
```

==== 随机数分布

```cpp
#include <iostream>
#include <random>
int main() {
  std::random_device rd;   // 将用于为随机数引擎获得种子
  std::mt19937 gen(rd());  // 以播种标准 mersenne_twister_engine
  std::uniform_int_distribution<> dis(1, 6);
  for (int n = 0; n < 10; ++n)
    // 用 dis 变换 gen 所生成的随机 unsigned int 到 [1, 6] 中的 int
    std::cout << dis(gen) << ' ';
  std::cout << '\n';
}
```

=== 随机化技巧

#note[
  *核心思想：*
  利用概率将复杂的判定问题降维，或通过打乱数据特征规避最坏情况。
  + *Las Vegas 算法*：结果总是正确，时间期望复杂度优（如：Random Shuffle）。
  + *Monte Carlo 算法*：时间固定，结果有概率出错（如：Hash 判定、Miller-Rabin）。通过多次随机可将错误率降至 $1/2^k$。
]

==== 随机映射与多项式哈希 (Fingerprinting)

通过将复杂的集合或代数式映射为随机大整数，实现 $O(1)$ 判定。核心在于 *Schwartz-Zippel* 引理。

+ *多重集相等 (Multiset Equality)*：
  判断数组 $A$ 和 $B$ 包含的元素是否完全一致（无视顺序）。
  - 给每个数值 $v$ 分配一个随机 64 位整数 $"rnd"[v]$。
  - 检查 $sum "rnd"[A_i] == sum "rnd"[B_i] (mod P)$。
  - 进阶：判断子数组是否为 $1 dots "len"$ 的排列，只需预处理 $1 dots "len"$ 的随机权值和。

+ *Zobrist Hashing (异或哈希)*：
  用于集合操作。给每个元素分配随机权值，集合哈希为元素的异或和。
  - 特点：$O(1)$ 插入、删除（再异或一次即可还原）。
  - 应用：判定棋盘状态、路径点集相等。

+ *多项式恒等测试 (PIT)*：
  判断 $A(x) dot B(x) == C(x)$。
  - 随机选取 $r$，计算 $A(r) dot B(r) - C(r) (mod P)$。若结果为 0，则恒等。
  - 矩阵验证：判断 $A times B == C$。随机生成列向量 $vec(r)$，验证 $A times (B times vec(r)) == C times vec(r)$，复杂度从 $O(n^3)$ 降至 $O(n^2)$。

+ *几何填充验证*：
  判断若干小立方体是否刚好拼成一个完整的大立方体（无重叠且无空隙）。
  - 随机选取底数 $X, Y, Z$。
  - 每个格点 $(x, y, z)$ 的指纹为 $X^x Y^y Z^z$。
  - 长方体区域 $[x_1, x_2] times [y_1, y_2] times [z_1, z_2]$ 的总指纹通过等比数列求和公式计算：
    $ H = (sum_(i=x_1)^(x_2) X^i) dot (sum_(j=y_1)^(y_2) Y^j) dot (sum_(k=z_1)^(z_2) Z^k) (mod P) $
  - 若 $sum H_"small" == H_"large"$，则几乎确定是完美填充。

==== 随机染色简化模型 (Color Coding)

用于解决“状态空间太大，但目标集合很小”的问题。

+ *Color Coding (小 $k$ 路径)*：
  - *场景*：找长度为 $k$ ($k <= 7$) 的简单路径。
  - *解法*：将所有点随机染成 $1 dots k$ 种颜色。仅寻找“颜色互不相同”的路径。
  - *复杂度*：状压颜色掩码 $"mask"$，状态数从 $2^n$ 降至 $2^k$。
  - *成功率*：单次成功概率 $k! / k^k$。

+ *随机二分染色 (Random Bipartite)*：
  - *场景*：一般图上的环/路径问题，但原图非二分图，难以处理偶数环或特定依赖。
  - *解法*：随机将点染成黑/白两色，强制只走异色边。
  - *例题 (CF1314D)*：求 $k$ 步回路最小值。通过随机染色转化为二分图 DP，重复多次取最优解。

==== 3. 随机增量与性质赋予

+ *Random Shuffle (打乱顺序)*：
  - *规避构造*：防止被出题人针对特定顺序（如从小到大、链状图）卡掉复杂度。
  - *最小圆覆盖*：随机打乱点序后，期望复杂度为 $O(n)$。
  - *树结构平衡*：如 Treap 通过随机优先级保证平衡。

+ *用随机元素命中目标集合*：
  - *场景*：只要找到集合中满足条件的任意一个元素即可。
  - *技巧*：随机采样。如果目标元素占比 $p$，重复 $k$ 次不中的概率为 $(1-p)^k$。
  - *应用*：寻找最小圆边界上的点、随机化寻找线性基的基向量。

==== 随机化在算法中的其他应用

- 防止被造数据者用针对性数据卡掉。例如在搜索时随机打乱邻居的顺序。
- 保证算法过程中进行的「操作」具有（某种意义上的）均匀性。例如 *模拟退火* 算法。在这些场景下，随机化常常（但并不总是）与乱搞、骗分等做法挂钩。

==== 与随机性有关的证明技巧

===== 概率上界的分析

- 自然常数的使用：$(1 - 1/n)^n <= 1/e, forall n >= 1$

=== 爬山算法 & 模拟退火

#note[
    TO DO ! 爬山不如模拟退火 
]

- 模拟退火是一种随机化算法。当一个问题的方案数量极大（甚至是无穷的）而且不是一个单峰函数时，我们常使用模拟退火求解。
- 根据 *爬山算法* 的过程，我们发现：对于一个当前最优解附近的非最优解，爬山算法直接舍去了这个解。而很多情况下，我们需要去接受这个非最优解从而跳出这个局部最优解，即为模拟退火算法。

==== 如何退火（降温）

- 模拟退火时我们有三个参数：初始温度 $T_0$，降温系数 $d$，终止温度 $T_k$。其中 $T_0$ 是一个比较大的数，$d$ 是一个非常接近 1 但是小于 1 的数，$T_k$ 是一个接近 0 的正数。
- 首先让温度 $T=T_0$ ，然后按照上述步骤进行一次转移尝试，再让 $T=d dot T$。当 $T < T_k$ 时模拟退火过程结束，当前最优解即为最终的最优解。
- 注意为了使得解更为精确，我们通常不直接取当前解作为答案，而是在退火过程中维护遇到的所有解的最优值。

==== 实现

#note[
  *「BZOJ 3680」吊打 XXX* \
  （求 n 个点的带权类费马点）
]

```cpp
#include <bits/stdc++.h>
constexpr int N = 10005;
int n, x[N], y[N], w[N];
double ansx, ansy, dis;
double Rand() { return (double)rand() / RAND_MAX; }
double calc(double xx, double yy) {
  double res = 0;
  for (int i = 1; i <= n; ++i) {
    double dx = x[i] - xx, dy = y[i] - yy;
    res += sqrt(dx * dx + dy * dy) * w[i];
  }
  if (res < dis) dis = res, ansx = xx, ansy = yy;
  return res;
}
void simulateAnneal() {
  double t = 100000;
  double nowx = ansx, nowy = ansy;
  while (t > 0.001) {
    double nxtx = nowx + t * (Rand() * 2 - 1);
    double nxty = nowy + t * (Rand() * 2 - 1);
    double delta = calc(nxtx, nxty) - calc(nowx, nowy);
    if (exp(-delta / t) > Rand()) nowx = nxtx, nowy = nxty;
    t *= 0.97;
  }
  for (int i = 1; i <= 1000; ++i) {
    double nxtx = ansx + t * (Rand() * 2 - 1);
    double nxty = ansy + t * (Rand() * 2 - 1);
    calc(nxtx, nxty);
  }
}
int main() {
  std::cin.tie(nullptr)->sync_with_stdio(false);
  srand(0);  // 注意，在实际使用中，不应使用固定的随机种子。
  std::cin >> n;
  for (int i = 1; i <= n; ++i) {
    std::cin >> x[i] >> y[i] >> w[i];
    ansx += x[i], ansy += y[i];
  }
  ansx /= n, ansy /= n, dis = calc(ansx, ansy);
  simulateAnneal();
  std::cout << std::fixed << std::setprecision(3) << ansx << ' ' << ansy
            << '\n';
  return 0;
}
```

==== 一些技巧

1. 分块模拟退火
   - 有时函数的峰很多，模拟退火难以跑出最优解。此时可以把整个值域分成几段，每段跑一遍模拟退火，然后再取最优解。
2. 卡时
   - 有一个 `clock()` 函数，返回程序运行时间。可以把主程序中的 `simulateAnneal();` 换成 `while ((double)clock()/CLOCKS_PER_SEC < MAX_TIME) simulateAnneal();`。这样子就会一直跑模拟退火，直到用时即将超过时间限制。这里的 `MAX_TIME` 是一个自定义的略小于时限的数（单位：秒）。


== 悬线法

悬线法的适用范围是单调栈的子集。具体来说，悬线法可以应用于满足以下条件的题目：

- 需要在扫描序列时维护单调的信息；
- 可以使用单调栈解决；
- 略。在单调栈上二分。

悬线，就是一条竖线，这条竖线有初始位置和高度两个性质，可以在其上端点不超过当前位置的矩形高度的情况下左右移动。

对于一条悬线，我们在这条上端点不超过当前位置的矩形高度且不移出边界的前提下，将这条悬线左右移动，求出其最多能向左和向右扩展到何处，此时这条悬线扫过的面积就是包含这条悬线的尽可能大的矩形。容易发现，最大子矩形必定是包含一条初始位置为 $i$，高度为 $h_i$ 的悬线。枚举实现这个过程的时间复杂度为 $O(n^2)$，但是我们可以用悬线法将其优化到 $O(n)$。

== 有限状态自动机

#note[
    TO DO ? 有限状态自动机
]

== 计算理论基础

#note[
    TO DO ? 计算理论基础
]

== 字节顺序

#note[计组说是 略]

== 约瑟夫问题

#note[
    + $n$ 个人(0-base) 每 $k$ 个淘汰一个

    $O(k log n)$
]

```cpp
int J(int n,int k){
    if(n==1)return 0;
    if(k==1)return n-1;
    if(k>n)return (J(n-1,k)+k)%n;// 我先数 k 个人你告诉我 n-1个人每 k 淘汰1 第几个是活下来的 
    int res=J(n-n/k,k);// 一次性一循环 你告诉我 现在第几个人是活的
    res-=n%k;// 我数 n%k 个把剩下的都计算完
    if(res<0)res+=n;
    else res+=res/(k-1);// 每 k-1 个实则相隔 k 个 需要+1
    return res;
}
```

== 格雷码

=== 变换 possible

```cpp
int g(int n) { return n ^ (n >> 1); }
```

=== 逆变换 possible

```cpp
int rev_g(int g) {
  int n = 0;
  for (; g; g >>= 1) n ^= g;
  return n;
}
```

=== 应用

+ $k$ 位二进制格雷码 可以作为 $k$ 维空间的哈密尔顿回路
+ 格雷码被用于最小化数字模拟转换器（比如传感器）的信号传输中出现的错误，因为它每次只改变一个位．
+ 格雷码可以用来解决汉诺塔的问题．
+ 格雷码也在遗传算法理论中得到应用．

== 表达式求值

#note[
    TO DO ! 表达式 栈的使用
]

== 一台机器上规划任务

你有 $n$ 个任务，要求你找到一个代价最小的的顺序执行他们。第 $i$ 个任务花费的时间是 $t_i$，而第 $i$ 个任务等待 $t$ 的时间会花费 $f_i(t)$ 的代价。

- 形式化地说，给出 $n$ 个函数 $f_i$ 和 $n$ 个数 $t_i$，求一个排列 $p$，最小化
$ F(p) = sum_(i=1)^n f_(p_i)(sum_(j=1)^(i-1) t_(p_j)) $

=== 特殊的代价函数

==== 线性代价函数

- 首先我们考虑所有的函数是线性的函数，即 $f_i(x) = c_i x + d_i$，其中 $c_i$ 是非负整数。显然我们可以事先把常数项加起来，因此函数就转化为了 $f_i(x) = c_i x$ 的形式。

- 写成 $c_(p_i) / t_(p_i) > c_(p_(i+1)) / t_(p_(i+1))$ 的形式，就可以理解为将排列按 $c_i / t_i$ 升序排序。处理这个问题，我们的思路是考虑微扰后的变换情况，贪心地选取最优解。

==== 指数代价函数

- 考虑代价函数的形式为 $f_i(x) = c_i e^(a x)$，其中 $c_i >= 0, a > 0$。

- 我们沿用之前的思路，考虑将 $i$ 和 $i+1$ 的位置上的数交换引起的代价变化。最终得到的算法是将排列按照 $(1 - e^(a t_i)) / c_i$ 升序排序。

==== 相同的单增函数

- 我们考虑所有的 $f_i(x)$ 是同一个单增函数。那么显然我们将排列按照 $t_i$ 升序排序即可。

==== Livshits-Kladov 定理

#note[
    听说你想使用 邻项交换法 + 排序???

    当 代价函数是
    
    + 线性函数 $f_i(t)=c_i t + d_i, c_i>=0$
    + 指数函数 $f_i(t)=c_i e^(a t) + d_i, c_i,a>0$
    + 相同的单增函数 $f_i(t)=phi(t),phi(t)"是一个单增函数"$

    *“稳了！直接邻项交换推不等式，写 sort！”*

    当 你遇到的是

    + $t^2, t log t$??? 

    *“贪心已死！果断换思路，想 DP 或图论！”*
]

== 主元素问题

给一个有 $n$ 个元素的序列，保证有一个元素 $a$ 出现的次数 严格大于 $n/2$，求这个元素。

=== 离线算法

- 桶进行统计，空间效率并不优。显然，若序列存在主元素，那么在排序后，序列的第 $floor(n/2) + 1$ 个元素一定是主元素，利用 `nth_element` 就可以找到这个元素。这样我们就在不引入额外空间的情况下，以线性时间复杂度求得主元素了。

=== 在线算法

- 摩尔投票

#note[PS:如果变式为： 寻找 次数 > n/3 的 元素，则将多数投票算法的「抵消2个不同元素」变为「抵消3个两两不同的元素」 因为最多 候选2个]

- 随机选择算法

== GW算法

- Garsia–Wachs 算法（Garsia–Wachs Algorithm）是计算机用来在 *线性时间* 内构建 *最优二叉查找树* 和 *字母霍夫曼码* 的有效算法。

#note[略]

== 华容道

#note[
    启发式函数 `h(n)` 可以是

    + 放错的方块的数量．
    + 所有放错的方块到各自目标位置的欧几里得距离之和．
    + 所有放错的方块到各自目标位置的曼哈顿距离之和．
]

== kahan求和

#note[
  2026年还卡我精度吗?
]

== 珂朵莉树

#note[
    mutable 还有这种功能！

    它能过题的充要条件必须同时满足：

    + *有区间赋值（推平）操作:* 这是消耗势能，减少节点数的唯一途径。
    + *数据必须是随机生成的:* 保证推平操作的长度足够大，发生频率足够稳定。
]

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=2e5+5;
// AUV 这里的 ksm(a,b,mod) 的 a 必须保证 < mod 啊啊啊
LL ksm(LL a,LL b,LL mod){
    LL res=1;
    for(;b;b>>=1,a=a*a%mod)if(b&1)res=res*a%mod;
    return res;
}
namespace ODT{
    struct Node{
        int l,r;
        mutable LL v;
        Node(int ll,int rr=-1,LL vv=0):l(ll),r(rr),v(vv){}
        bool operator<(const Node& o)const {return l<o.l;}
    };
    set<Node> S;
    void init(int n,LL v){
        S.clear();
        S.insert(Node(1,n+1,v));
    }
    // [分裂]
    set<Node>::iterator split(int x){
        auto it=S.lower_bound(Node(x));
        if(it!=S.end()&&it->l==x)return it;
        it--;
        int l=it->l,r=it->r;
        LL v=it->v;
        S.erase(it);
        S.emplace(l,x-1,v);
        return S.emplace(x,r,v).first;
    }
    // [区间赋值]
    void assign(int l,int r,LL v){
        auto R=split(r+1),L=split(l);// 注意顺序 要不然 L 迭代器被删了
        S.erase(L,R);
        S.emplace(l,r,v);
    }
    // 示例
    // void perform(int l,int r){
    //     auto R=split(r+1),L=split(l);
    //     for(;L!=R;L++){
    //         // op
    //     }   
    // }
    void add(int l,int r,LL v){
        auto R=split(r+1),L=split(l);
        for(;L!=R;L++)L->v+=v;
    }
    LL kth(int l,int r,int k){
        auto R=split(r+1),L=split(l);
        vector<pair<LL,int>> tmp;
        for(;L!=R;L++)tmp.emplace_back(L->v,L->r-L->l+1);
        sort(tmp.begin(),tmp.end());
        for(auto [v,c]:tmp){
            if(k<=c)return v;
            k-=c;
        }
        assert(0);
        return -1;
    }
    LL pow_sum(int l,int r,LL x,LL y){
        auto R=split(r+1),L=split(l);
        LL res=0;
        // 先模 y !!!
        for(;L!=R;L++)res=(res+ksm(L->v%y,x,y)*(L->r-L->l+1))%y;
        return res;
    }
}
int n,m,seed,vmax,a[N];
int rnd(){
    int ret=seed;
    seed=((LL)seed*7+13)%1000000007;
    return ret;
}
void solve(){
    cin>>n>>m>>seed>>vmax;
    ODT::init(n,0);
    for(int i=1;i<=n;i++)a[i]=rnd()%vmax+1,ODT::assign(i,i,a[i]);
    for(int i=1;i<=m;i++){
        int op=rnd()%4+1,l=rnd()%n+1,r=rnd()%n+1,x,y;
        if(l>r)swap(l,r);
        if(op==3)x=rnd()%(r-l+1)+1;
        else x=rnd()%vmax+1;
        if(op==4)y=rnd()%vmax+1;
        if(op==1)ODT::add(l,r,x);
        else if(op==2)ODT::assign(l,r,x);
        else if(op==3)cout<<ODT::kth(l,r,x)<<"\n";
        else cout<<ODT::pow_sum(l,r,x,y)<<"\n";
    }
}
int main(){
    solve();
}
```

== 空间优化简介

=== 信息熵

信息熵描述了存储数据所占用的空间下限，若实际可用的空间低于这个下限则必然损失信息。

=== 常见技巧

- *避免存储不必要的数据*
  - 在 可持久化线段树 中，由于单次修改只会产生 $O(log n)$ 个新结点，所以我们略。把每个版本的线段树都完整地存储下来，只需要记录新结点即可。
  - 考虑 图的存储，对稀疏图来说，若使用邻接矩阵则会存储大量无用的 0，所以一般使用邻接表存稀疏图。
  - `bool` 数组的每个元素均会占用一个字节的空间，必要时可用每个元素只占用一位的 `std::vector<bool>` 或 `bitset` 代替。
  - 在 背包 DP 中，对 01 背包而言，每次计算 DP 值只会用到上一次计算时的数据，所以我们可以用滚动数组优化空间，只需要记录当前 DP 值即可。

- *利用数据特性*
  - 考虑支持路径压缩和启发式合并的 并查集，传统做法需要两个数组，分别记录父结点编号和子树大小。
  - 在应用了路径压缩后，对于并查集中的一棵树，我们只需要记录根结点对应的子树大小。
  - 根结点的父亲一定是自己。
  - 我们可以利用有符号整数的特性，用负数表示根结点，正数表示非根结点，所以我们只需一个数组即可实现支持路径压缩和启发式合并的并查集。