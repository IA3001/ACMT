#import "../lib.typ": *

= 动态规划

== 动态规划理论

+ *最优子结构*  
+ *无后效性*  
+ *子问题重叠* 

== 记忆化搜索

#note[见【剪枝优化】]

== 背包DP

=== 01背包

```cpp
const int N,M;
int dp[M],cost[N],val[N];
int n,m;
/* 01背包 P1048 */
void solve(){
  memset(dp,0xc0,sizeof(int)*(m+1));
  dp[0]=0;
  for(int i=1;i<=n;i++)
    for(int j=m;j>=w[i];j--)
      dp[j]=max(dp[j],dp[j-cost[i]]+val[i]);
}
```

=== 完全背包

+ *改成：*
    1. `01背包`：滚动第二维改正序
    2. `多重背包`：二进制分解

=== 多重背包

#note[更优解法见【单调队列优化DP】]

```cpp
const int N;
int n,m;
struct Item{int val,cost,c;}tmp[N],item[N*(1+__lg(N))];
/* 多重背包 P1776 */
void solve(){
    // 二进制分解
    for(int i=1;i<=n;i++){
        auto [val,cost,c]=tmp[i];
        for(int j=0;j<30;j++)if(c>=(1<<j)){
            item[++cnt]={val<<j,cost<<j,1};
            c-=(1<<j);
        }
        if(c)item[++cnt]={val*c,cost*c,1};
    }
    // 01背包
}
```

=== 混合背包

```cpp
// 伪代码
/* 混合(前三种)背包 共用一个dp 依据不同的物品 */
for(各种物品){
    if(属于01背包)
        01背包代码()
    else if(属于完全背包)
        完全背包代码()
    else if(属于多重背包)
        多重背包代码()
}
```

=== 二维费用背包

#note[`经验`：递推时只要有一个是倒序的就是滚动]

```cpp
/* 二维费用背包 P1507 */
const int N=55,W1=405,W2=405;
struct Item{int val,cost1,cost2;}item[N];
int dp[N][M];
void solve(){
    memset(dp,0xc0,sizeof(dp));
    dp[0][0]=0;
    for(int i=1;i<=n;i++)
        for(int j=m1;j>=item[i].cost1;j--)
            for(int k=m2;k>=item[i].cost2;k--)
                dp[j][k]=max(dp[j][k],dp[j-item[i].cost1][k-item[i].cost2]+item[i].val);
}
```

=== 分组背包

```cpp
// 伪代码
/* 分组背包 P1757 */
for(正序枚举组数(可滚动))
  for(逆序枚举容量)
    for(正序枚举物品)
      // 更新
```

=== 有依赖的背包

#note[求"前缀和"就是 *分组背包*]

=== 泛化物品的背包

#note[这种背包，没有固定的费用和价值，它的价值是随着分配给它的费用而定。在背包容量为 $V$ 的背包问题中，当分配给它的费用为 $v_i$ 时，能得到的价值就是 $h(v_i)$。这时，将固定的价值换成函数的引用即可。]

=== 杂项

#note[背包问题变种]

- *输出方案*  
	+ 用 `use[i][j]` 表示第i件物品在空间为 `j` 的时候是否选择该物品，从最优解倒推即可

- *求方案数*  
	+ *最大价值* 变成了 *方案数量*  
  + 转移方式 由 `max()` 变为 `+=`  
  + 空重量初始化为 `1` ：`dp[0]=1`

- *求最优方案总数*  
	+ 在求完 `dp[i][j] `后来一个辅助函数 `g[i][j] `表示相对应的方案数  
  + 可以滚动一维：`dp[0]=0;g[0]=1; ` 	
	+ 根据 `dp` 基于 `j` 的转移进行 `g` 基于 `j` 的转移即可

- *求背包的第k优解*  
  + 与*k短路*不同  
	+ 这里只需暴力多开一维 `k` 即可
	+ 对于原先的 *k* 优方案 *k* 次选与不选(双指针)(注意无效数据) 
  ```cpp
memset(dp, 0, sizeof(dp));
int i, j, p, x, y, z;
scanf("%d%d%d", &n, &m, &K);
for (i = 0; i < n; i++) scanf("%d", &w[i]);
for (i = 0; i < n; i++) scanf("%d", &c[i]);
for (i = 0; i < n; i++) {
for (j = m; j >= c[i]; j--) {
  for (p = 1; p <= K; p++) {
    a[p] = dp[j - c[i]][p] + w[i];
    b[p] = dp[j][p];
  }
  a[p] = b[p] = -1;
  x = y = z = 1;
  while (z <= K && (a[x] != -1 || b[y] != -1)) {
    if (a[x] > b[y])
      dp[j][z] = a[x++];
    else
      dp[j][z] = b[y++];
    if (dp[j][z] != dp[j][z - 1]) z++;
  }
}
}
printf("%d\n", dp[m][K]);
  ```

== 区间DP

```cpp
// 伪代码
// 往往二倍开环
int n,dp[N][N];
void interval_dp(){
    for(int i=1;i<=n;i++)dp[i][i]=...;// 初始化 len=1
    for(int len=2;len<=n;len++){// 枚举长度 len>=2
        for(int i=;i+len-1<=n;i++){// 枚举起始位置 i
            int j=i+len-1;// 终止位置 j
            // dp[i][j]=
        }
    }
}
```

== DAG上DP

#note[感觉就是 *有穷* 的 *记忆化搜索* ]

== 树形DP

=== 树上背包

==== 重量为 `1`  

#note[`常见的困扰`：dp 用的是*前缀最优解* 还是*单点最优解*，*单点最优解*好理解  ]

+ 法1 `dfs` $O(n^2)$（差）  
+ 法2 `nfd` $O(n m)$    

```cpp
/* 树上背包(类型1: 物品重量为1)  */
const int N,M;

// 法1 dfs
vector<int> e[N];
int val[N],sz[N];
int dp[N][M];// 表示以 i 为根的子树选择 j 个的最大价值
int n,m;// m为背包限制
void dfs(int u,int f){
    sz[u]=1;// sz 初始化
    dp[u][0]=0;
    dp[u][1]=val[u];// 因为重量为1更新可以
    for(auto v:e[u])if(v!=f){
        dfs(v,u);
        /* 错误示范(被修改的i+j由于正序遍历被使用) */
        // for(int i=1;i<=sz[u];i++){
        /* 正确顺序(i+j被更新后由于>=i而i倒序不会被使用) */
        // 合并时i必须从1开始
        for(int i=min(m,sz[u]);i>0;i--)// 更新u, u为主, 但是不能作为0参与合并
            for(int j=min(m-i,sz[v]);j>=0;j--)// v尽全力可以0, 提前预算 m 防止超限
                dp[u][i+j]=max(dp[u][i+j],dp[u][i]+dp[v][j]);
        // 更新树
        sz[u]+=sz[v];
        // 复杂度n^2 由lca匹配(记着吧)可知
  }
}

// 法2 dfn序 注意是 后dfn序 
int rnk[N];
int nfdcnt;
void dfs2(int u,int f){
  sz[u]=1;
  for(auto v:e[u])if(v!=f){
      dfs2(v,u);
      sz[u]+=sz[v];
  }
  rnk[++nfdcnt]=u;
}
void cal(){
  // 只接受正好用完的w
  dp[0][0]=0;
  for(int nfd=1;nfd<=nfdcnt;nfd++){
      int i=rnk[nfd];
      dp[nfd][0]=0;
      for(int j=min(m,nfd);j>0;j--){// 限制个数在m和nfd以内
          // 要么 选i接着考虑儿子, 要么不选i跳过它 
          dp[nfd][j]=max(dp[nfd-1][j-1]+val[i],dp[nfd-sz[i]][j]);
      }
  }
}

void solve(){
  memset(dp,0xc0,sizeof dp);
  // 法1 dfs 实测更快一点 
  // dfs(0,-1);
  // cout<<dp[0][m]<<'\n';
  // 法2 dfn
  dfs2(0,-1);
  cal();
  cout<<dp[dfncnt][m]<<'\n';
}
```

==== 重量为 `w`

#note[类型1的 一般化  ]

+ 法1 `dfs` $O(n m)$（好）  
+ 法2 `nfd` $O(n m)$  

```cpp
/* 树上背包(类型2：物品重量为cost 类型1的一般化) */

const int N=105,M=105;
int n,m;
vector<int> e[N];
int cost[N],val[N];
int dp[N][M];
int path[N];

// 法1 dfs
void dfs1(int u,int f){
  path[u]=path[f]+cost[u];
  for(auto v:e[u])if(v!=f){
      // 在计算儿子之前先初始化 
      // 注意这里是全局代价 即考虑的祖先的选择代价的 j 
      for(int j=path[u]+cost[v];j<=m;j++){
          dp[v][j]=dp[u][j-cost[v]]+val[v];
      }
      dfs1(v,u);
      // 儿子计算之后合并到父亲
      // 合并 儿子选或不选 
      for(int j=path[u]+cost[v];j<=m;j++){
          dp[u][j]=max(dp[u][j],dp[v][j]);
      }
  }
}

// 法2 nfd 很简单 这就是 
int sz[N];
int id[N];
int nfdcnt;
void dfs2(int u,int f){
  sz[u]=1;
  for(auto v:e[u]){
      if(v==f)continue;
      dfs2(v,u);
      sz[u]+=sz[v];
  }
  id[++nfdcnt]=u;
}

void cal(){
  // 这里dp定义就和前者不一样了 没有对祖先的考虑
  for(int nfd=1;nfd<=nfdcnt;nfd++){
      int i=id[nfd];
      // 不够选择自己
      for(int j=cost[i]-1;j>=0;j--)
          dp[nfd][j]=dp[nfd-sz[i]][j];
      // 考虑选择自己
      for(int j=cost[i];j<=m;j++)
          dp[nfd][j]=max(dp[nfd-1][j-cost[i]]+v[i],dp[nfd-sz[i]][j]);
  }
}

void solve(){
  // 输入
  cin>>n>>m;   
  for(int p,i=1;i<=n;i++){
      cin>>cost[i]>>val[i]>>p;
      if(p==-1)p=0;
      e[p].push_back(i);
  }
  // 初始化dp
  memset(dp,0xc0,sizeof dp);
  dp[0][0]=0;
  // 法1 dfs
  // dfs1(0,0);
  // cout<<*max_element(dp[0],dp[0]+m+1)<<'\n';
  // 法2 nfd 
  dfs2(0,0);
  cal();
  cout<<*max_element(dp[n],dp[n]+m+1)<<'\n';   
}
```

=== 换根DP

```cpp
/* P3478 最大深度和点*/
using LL = long long;
const int N=1e6+5;
LL n,dp[N],sz[N];// 注意 N^2
vector<int> e[N];
void dfs1(int u,int f){// 钦定根为1 求sz 得到 dp[1]
	dp[u]=0;sz[u]=1;
    for(auto v:e[u]){
        if(v==f)continue;
        dfs1(v,u);
        dp[u]+=dp[v]+sz[v];
        sz[u]+=sz[v];
    }
}
void dfs2(int u,int f){// 根从 u 迁移到 v 计算 dp[v] 以形成递归
    for(auto v:e[u]){
    	if(v==f)continue;
        dp[v]=dp[u]+(n-sz[v])-sz[v];
        dfs2(v,u);
	}
}
void solve(){dfs1(1,0);dfs2(1,0);}
```

== 状压DP

#note[*从1到0*:枚举子状态异或1  \
*从0到1*:枚举可加状态或1]

```cpp
/* P1896 k国王问题 */
const int N=10,K=82;
int n,k,mask;
LL dp[N][1<<N][K];
void solve(){
    // 输入
    cin>>n>>k;
	mask=(1<<n)-1;
    // 初始case 0层 0状态 0放置
    dp[0][0][0]=1;
    // 枚举层
    for(int i=1;i<=n;i++){
        // 枚举每层状态
        for(int s=0;s<=mask;s++){
            // 本层冲突
            if((s&(s<<1))||(s&(s>>1)))continue;
            int S=((s|(s<<1)|(s>>1))&mask)^mask;
            int pc=__builtin_popcount(s);
            // 枚举上一层状态
            for(int j=pc;j<=k;j++){
                for(int t=S;t>=0;t=(t-1)&S){
                	dp[i][s][j]+=dp[i-1][t][j-pc];
                	if(t==0)break;
                }
            }
        }
    }
    LL ans=0;
    for(int s=0;s<=mask;s++){
        ans+=dp[n][s][k];
    }
    cout<<ans<<'\n';
}
```

== 数位DP

```cpp
/* P2602 数码计数(统计[a,b]范围内的各个数码出现的次数) */
LL pow10[20],a,b,num,digit,ans[10],dp[20];
void init(){pow10[0]=1;for(int i=1;i<18;i++)pow10[i]=pow10[i-1]*10;}
int get(LL n,int p){
    return (n/pow10[p])%10;
}
// 注意：单依赖的 !fix 或 !fre 略。记忆化
LL f(int i,bool fix,bool fre){
    if(i==-1)return 0;
    if(fix&&fre&&~dp[i])return dp[i];
    LL res=0;
    int st=1-fix;
    int ed=fre?9:get(num,i);
    if(!fix)res+=f(i-1,false,fre|ed);// 继续不选 
    for(int d=st;d<=ed;d++)
        res+=
        (d==digit)*
        (fre|(d<ed)?pow10[i]:(num%pow10[i]+1LL))+f(i-1,true,fre|(d<ed));// 选
    if(fix&&fre)dp[i]=res;
    return res;
}
void solve(){
    init();
    cin>>a>>b;
    num=b;
    for(digit=0;digit<=9;digit++){
        memset(dp,-1,sizeof dp);
        ans[digit]+=f(13,0,0);
    }
    num=a-1;
    for(digit=0;digit<=9;digit++){
        memset(dp,-1,sizeof dp);
        ans[digit]-=f(13,0,0);
    }
    for(int i=0;i<=9;i++)cout<<ans[i]<<' ';
}
```

== 插头DP

=== 轮廓线DP

#note[题目大意：多米诺骨牌问题]

+ 思想：用轮廓线状态表示前缀信息
+ 对于所有的轮廓线问题，就算轮廓线出现了非法状态，它最终也算不到答案去所以不用担心

```cpp
#include <bits/stdc++.h>
using namespace std;
constexpr int N = 11;
long long f[2][1 << N], *f0, *f1;
int n, m;

int main() {
  while (cin >> n >> m && n) {
    f0 = f[0];
    f1 = f[1];
    fill(f1, f1 + (1 << m), 0);
    f1[0] = 1;
    for (int i = 0; i < n; ++i) {
      for (int j = 0; j < m; ++j) {
        swap(f0, f1);
        fill(f1, f1 + (1 << m), 0);
#define u f0[s]
        for (int s = 0; s < 1 << m; ++s)
          if (u) {
            if (j != m - 1 && (!(s >> j & 3))) f1[s ^ 1 << j + 1] += u;  // 横放
            f1[s ^ 1 << j] += u;  // 竖放或不放
          }
      }
    }
    cout << f1[0] << endl;
  }
}
```

=== 路径模型

==== 多条回路

#note[题目大意：求用若干条回路覆盖 $N times M$ 棋盘的方案数，有些位置有障碍。]

+ 严格来说，多条回路问题并*不属于*插头 DP，因为我们只需要和上面的骨牌覆盖问题一样，记录插头是否存在，然后成对的合并和生成插头就可以了。

+ *Thinking*
    + 这和轮廓线很像，因为我们无需关心前面的插头是否形成了回路，因为没有限制只能有一条回路
    + 还有一点就是 roll 操作为什么要 roll? 
    + Wiki里说了， 因为最右边的左插头是无关信息，且下一行的 左插头状态一定是 0 所以左移改变状态 读取的状态不会读到非法信息 （？？？关于非法信息的处理我们之后再聊）

```cpp
#include <iostream>
using namespace std;
constexpr int N = 11;
long long f[2][1 << (N + 1)], *f0, *f1;
int n, m;

int main() {
  int T;
  cin >> T;
  for (int Case = 1; Case <= T; ++Case) {
    cin >> n >> m;
    f0 = f[0];
    f1 = f[1];
    fill(f1, f1 + (1 << (m + 1)), 0);
    f1[0] = 1;  // 初始化
    for (int i = 0; i < n; ++i) {
      for (int j = 0; j < m; ++j) {
        bool bad;
        cin >> bad;
        bad ^= 1;
        swap(f0, f1);
        fill(f1, f1 + (1 << (m + 1)), 0);
        for (int s = 0; s < 1 << (m + 1); ++s)  // 具体的dp转移，上面都是初始化
          if (f0[s]) {
            bool lt = s >> j & 1, up = s >> (j + 1) & 1;
            if (bad) {
              if (!lt && !up) f1[s] += f0[s];
            } else {
              f1[s ^ 3 << j] += f0[s];
              if (lt != up) f1[s] += f0[s];
            }
          }
      }
      swap(f0, f1);
      fill(f1, f1 + (1 << (m + 1)), 0);
      for (int s = 0; s < 1 << m; ++s) f1[s << 1] = f0[s];
    }
    cout << "Case " << Case << ": There are " << f1[0]
         << " ways to eat the trees.\n";
  }
}
```

==== 一条回路

#note[题目大意：求用一条回路覆盖 $N times M$ 棋盘的方案数。]

- 在上面的状态表示中我们每合并一组连通的插头，就会生成一条独立的回路，因而在本题中，我们还需要区分插头之间的连通性（出现了！）。这需要我们对状态进行额外的编码。

- *Thinking*
    - 这里和一般的轮廓线不一样了，因为我们要求只允许有一条回路，我们最后收尾闭合的时候只允许之前是不存在闭合回路的，
    - 要如何区分是否存在闭合回路呢？
    - 关键是在转移的时候始终避免闭合回路的产生
    - 由于闭合回路必然是随右下角的确立而确定的
    - 所以我们不能只记录插头的存在，还要记录插头的连通关系，才能区分避免回路提前产生！

- 使用的特性：
    - 闭合回路的括号匹配性

```cpp
#include <bits/stdc++.h>
using namespace std;
constexpr int M = 10;
constexpr int offset = 3, mask = (1 << offset) - 1;
int n, m;
long long ans, d;
constexpr int MaxSZ = 16796, Prime = 9973;

struct hashTable {
  int head[Prime], next[MaxSZ], sz;
  int state[MaxSZ];
  long long key[MaxSZ];

  void clear() {
    sz = 0;
    memset(head, -1, sizeof(head));
  }

  void push(int s) {
    int x = s % Prime;
    for (int i = head[x]; ~i; i = next[i]) {
      if (state[i] == s) {
        key[i] += d;
        return;
      }
    }
    state[sz] = s, key[sz] = d;
    next[sz] = head[x];
    head[x] = sz++;
  }

  void roll() {
    for (int i = 0; i < sz; i++) state[i] <<= offset;
  }
} H[2], *H0, *H1;

int b[M + 1], bb[M + 1];

int encode() {
  int s = 0;
  memset(bb, -1, sizeof(bb));
  int bn = 1;
  bb[0] = 0;
  for (int i = m; i >= 0; --i) {
    if (!~bb[b[i]]) bb[b[i]] = bn++;
    s <<= offset;
    s |= bb[b[i]];
  }
  return s;
}

void decode(int s) {
  for (int i = 0; i < m + 1; i++) {
    b[i] = s & mask;
    s >>= offset;
  }
}

void push(int j, int dn, int rt) {
  b[j] = dn;
  b[j + 1] = rt;
  H1->push(encode());
}

int main() {
  cin >> n >> m;
  if (m > n) swap(n, m);
  H0 = H, H1 = H + 1;
  H1->clear();
  d = 1;
  H1->push(0);
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < m; j++) {
      swap(H0, H1);
      H1->clear();
      for (int ii = 0; ii < (H0->sz); ii++) {
        decode(H0->state[ii]);
        d = H0->key[ii];
        int lt = b[j], up = b[j + 1];
        bool dn = i != n - 1, rt = j != m - 1;
        if (lt && up) {
          if (lt == up) {
            if (i == n - 1 && j == m - 1) {
              push(j, 0, 0);
            }
          } else {
            for (int i = 0; i < m + 1; i++)
              if (b[i] == lt) b[i] = up;
            push(j, 0, 0);
          }
        } else if (lt || up) {
          int t = lt | up;
          if (dn) {
            push(j, t, 0);
          }
          if (rt) {
            push(j, 0, t);
          }
        } else {
          if (dn && rt) {
            push(j, m, m);
          }
        }
      }
    }
    H1->roll();
  }
  assert(H1->sz <= 1);
  cout << (H1->sz == 1 ? H1->key[0] : 0) << endl;
}
```

==== 一条路径

#note[题目大意：一个 $N M$ 的方阵（$N,M<= 8$），每个格点有一个权值，求一段路径，最大化路径覆盖的格点的权值和。]

- 本题是标准的一条路径问题，在一条路径问题中，编码的状态中还会存在不能配对的独立插头。需要在状态转移函数中，额外讨论独立插头的生成、合并与消失的情况。独立插头的生成和消失对应着路径的一端，因而这类事件不会发生超过两次（一次生成一次消失，或者两次生成一次合并），否则最终结果一定会出现多个连通块。

- 我们需要在状态中额外记录这类事件发生的总次数，可以将这个信息编码进状态里（注意，类似这样的额外信息在调整轮廓线的时候，略。跟着滚动），当然也可以在 hashTable 数组的外面加维。下面的范例程序中我们选择后者。

- *Thinking*
  - 难点：状态对应的权值是什么？
  - 是当前格子所连接的插头连通分量的和！
  - 难点：为什么要有 $c_0 c_1 c_2$ 分层？
  - 因为存在独立的插头，独立的插头可以选择截断
  - 分三层是为了适应 
  - 截断一次 -> 独立插头集
  - 截断两次 -> 独立插头合并集!
  - 分层，崩溃了，不会了!

```cpp
#include <bits/stdc++.h>
using namespace std;

template <class T>
bool checkMax(T &a, const T b) {
  return a < b ? a = b, true : false;
}

constexpr int N = 8, M = 8;
constexpr int offset = 3, mask = (1 << offset) - 1;
int A[N + 1][M + 1];
int n, m;
int ans, d;
constexpr int MaxSZ = 16796, Prime = 9973;

struct hashTable {
  int head[Prime], next[MaxSZ], sz;
  int state[MaxSZ];
  int key[MaxSZ];

  void clear() {
    sz = 0;
    memset(head, -1, sizeof(head));
  }

  void push(int s) {
    int x = s % Prime;
    for (int i = head[x]; ~i; i = next[i]) {
      if (state[i] == s) {
        checkMax(key[i], d);
        return;
      }
    }
    state[sz] = s, key[sz] = d;
    next[sz] = head[x];
    head[x] = sz++;
  }

  void roll() {
    for (int i = 0; i < sz; i++) state[i] <<= offset;
  }
} H[2][3], *H0, *H1;

int b[M + 1], bb[M + 1];

int encode() {
  int s = 0;
  memset(bb, -1, sizeof(bb));
  int bn = 1;
  bb[0] = 0;
  for (int i = m; i >= 0; --i) {
    if (!~bb[b[i]]) bb[b[i]] = bn++;
    s <<= offset;
    s |= bb[b[i]];
  }
  return s;
}

void decode(int s) {
  for (int i = 0; i < m + 1; i++) {
    b[i] = s & mask;
    s >>= offset;
  }
}

void push(int c, int j, int dn, int rt) {
  b[j] = dn;
  b[j + 1] = rt;
  H1[c].push(encode());
}

void init() {
  cin >> n >> m;
  H0 = H[0], H1 = H[1];
  for (int c = 0; c < 3; c++) H1[c].clear();
  d = 0;
  H1[0].push(0);
  memset(A, 0, sizeof(A));
  for (int i = 0; i < n; i++)
    for (int j = 0; j < m; j++) cin >> A[i][j];
}

void solve() {
  ans = 0;
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < m; j++) {
      checkMax(ans, A[i][j]);  // 需要单独处理一个格子的情况
      if (!A[i][j]) continue;  // 如果有障碍，则跳过，注意这时状态数组略。滚动
      swap(H0, H1);
      for (int c = 0; c < 3; c++)
        H1[c].clear();  // c 表示生成和消失事件发生的总次数，最多不超过 2 次
      for (int c = 0; c < 3; c++)
        for (int ii = 0; ii < H0[c].sz; ii++) {
          decode(H0[c].state[ii]);
          d = H0[c].key[ii] + A[i][j];
          int lt = b[j], up = b[j + 1];
          bool dn = A[i + 1][j], rt = A[i][j + 1];
          if (lt && up) {
            if (lt == up) {  // 在一条路径问题中，我们不能合并相同的插头。
              // Cannot deploy here...
            } else {  // 有可能参与合并的两者中有独立插头，但是也可以用同样的代码片段处理
              for (int i = 0; i < m + 1; i++)
                if (b[i] == lt) b[i] = up;
              push(c, j, 0, 0);
            }
          } else if (lt || up) {
            int t = lt | up;
            if (dn) {
              push(c, j, t, 0);
            }
            if (rt) {
              push(c, j, 0, t);
            }
            // 一个插头消失的情况，如果是独立插头则意味着消失，如果是成对出现的插头则相当于生成了一个独立插头，
            // 无论哪一类事件都需要将 c + 1。
            if (c < 2) {
              push(c + 1, j, 0, 0);
            }
          } else {
            d -= A[i][j];
            H1[c].push(H0[c].state[ii]);
            d += A[i][j];  // 跳过插头生成，本题中不要求全部覆盖
            if (dn && rt) {  // 生成一对插头
              push(c, j, m, m);
            }
            if (c < 2) {  // 生成一个独立插头
              if (dn) {
                push(c + 1, j, m, 0);
              }
              if (rt) {
                push(c + 1, j, 0, m);
              }
            }
          }
        }
    }
    for (int c = 0; c < 3; c++) H1[c].roll();  // 一行结束，调整轮廓线
  }
  for (int ii = 0; ii < H1[2].sz; ii++) checkMax(ans, H1[2].key[ii]);
  cout << ans << endl;
}

int main() {
  int T;
  cin >> T;
  while (T--) {
    init();
    solve();
  }
}
```

=== 染色模型

#note[略（略指的是我不想学）]

=== 图论模型

#note[略]

== 计数DP

#note[从 `1` 开始计数的DP   ]

+ 常用转移方法： *等价计数法* 

```cpp
/* n 的无序划分 */
// 1 划定上限法 (基于最大数) 
const int N=2e4+5;
int f[N][N];// f[i][j] 表示 i 分为 每项不超过 j 的数字方法数
// f[i][0]=0; i>=1
// f[0][j]=1; j>=0
f[i][j] = f[i][j-1] // 表示 每项均不超过j-1的方法数   (上下级递推) (j>=1)
		+ f[i-j][j];//  有项达到了 j 表明 删去这一项 剩余的不超过j的方法数 (同级递推) (i>=j)
// 2 等效构造法 (基于元素个数)
// 得到 有若干元素 和为 n 的无序多重集 方法是:
// a.T中每个元素+1 b.T中加入1
// 可知每个 T 的构造顺序是唯一的(与答案的判定相同)
// 即可将 和为n的 T的个数 与答案绑定
// 分析对T的影响 
int g[N][N];// g[i][j] 表示 达到 和为 i 数量为 j 的方法数
// g[0][0] = 1;
g[i][j] = g[i-j][j] // j 个元素+1 (i>=j)
    	+ g[i-1][j-1]; // 增加一个 1 (i,j>=1)
// 3. 根号分治法 (基于1和2的调度)
// 因为 n = 值*个数
// 我们选择根号n为值与个数的分界点
// 对于某种划分 我们将其分为 1 值<=根号n 的部分 和 2 值>根号n 的部分
// 由于两种方法的特点
// 1 最大数<=根号n 复杂度为 n^(3/2)
// 2 元素个数<根号n 复杂度为 n^(3/2)
// 最后枚举n在1和2中的各种分配方法数 乘积 求和 即可
```

== 动态DP

#note[人话：带修改 dp]

```cpp
// P4719 【模板】动态DP
#include<bits/stdc++.h>
using namespace std;

const int N=1e5+5,D=2;
const int inf = 1e9;

/*

1. 线段树查询信息合并没有分类讨论，认为一定是两端
2. 没有认识到 g[u] 的定义含义 所以一直没搞懂 g[u] 的初始转化 为什么增量传递式修改
3. dfs 写多了 写 两个就够了
4. 一直没有弄清 G 矩阵和 f 其实是自然必然等价的 啊 G 包含了 f
5. 要强化 线段树懒处理 动态修改操作的特点， 所以有 lst nxt 的差分增量
6. 要强化 动态dp 初始值(矩阵) f 和路径参数矩阵 G 的认识 

*/

// 广义矩阵乘法 封装
struct Mat{
    int g[D][D];
    Mat(){
        for(int i=0;i<D;i++)
        for(int j=0;j<D;j++)
        g[i][j]=-inf;// 为什么 0 也可以 啊 
    }
    inline int* operator[](int i)const {
        return (int*)g[i];
    }
    Mat operator*(const Mat& B)const {
        Mat C;
        for(int i=0;i<D;i++){
            for(int j=0;j<D;j++){
                for(int k=0;k<D;k++){
                    C[j][k]=max(C[j][k],g[j][i]+B[i][k]);
                }
            }
        }
        return C;
    }
};

int n,m;
int a[N];
vector<int> e[N];
int dfn[N],dfncnt,son[N],sz[N],rnk[N],ed[N],top[N],fa[N];
Mat G[N];
int f[N][2];

struct SegmentTree{
    Mat f[N*4];
    void up(int i){
        f[i]=f[i*2]*f[i*2+1];
    }
    void build(int i,int l,int r){
        if(l==r){
            f[i]=G[rnk[l]];               
        }else {
            int mid=(l+r)/2;
            build(i*2,l,mid);
            build(i*2+1,mid+1,r);
            up(i);
        }
    }
    void Set(int i,int l,int r,int p,Mat v){
        if(l==r){
            f[i]=v;
        }else {
            int mid=(l+r)/2;
            if(p<=mid)Set(i*2,l,mid,p,v);
            else Set(i*2+1,mid+1,r,p,v);
            up(i);
        }
    }
    Mat Query(int i,int l,int r,int jl,int jr){
        if(jl<=l&&r<=jr){
            return f[i];
        }else {
            int mid=(l+r)/2;
            if(jl<=mid&&jr>mid){
                Mat L = Query(i*2,l,mid,jl,jr);
                Mat R = Query(i*2+1,mid+1,r,jl,jr);
                return L*R;
            }else if(jl<=mid){
                return Query(i*2,l,mid,jl,jr);
            }else {
                return Query(i*2+1,mid+1,r,jl,jr);
            }
        }
    }
}T;

void dfs1(int u){
    f[u][1]=a[u];
    sz[u]=1;
    for(auto v:e[u])if(v!=fa[u]){
        fa[v]=u;
        dfs1(v);
        sz[u]+=sz[v];
        if(sz[v]>sz[son[u]])son[u]=v;
        f[u][0]+=max(f[v][0],f[v][1]);
        f[u][1]+=f[v][0];
    }
    G[u][0][0]=G[u][0][1]=f[u][0]-max(f[son[u]][0],f[son[u]][1]);
    G[u][1][0]=f[u][1]-f[son[u]][0];
    G[u][1][1]=-inf;
}

void dfs2(int u,int tp){
    dfn[u]=++dfncnt;
    rnk[dfncnt]=u;
    top[u]=tp;
    ed[u]=u;
    if(son[u])dfs2(son[u],tp),ed[u]=ed[son[u]];
    for(auto v:e[u])if(v!=fa[u]&&v!=son[u])dfs2(v,v);
}

void Modify(int x,int y){
    G[x][1][0]+=y-a[x];
    a[x]=y;
    while(x){
        Mat lst = T.Query(1,1,n,dfn[top[x]],dfn[ed[top[x]]]);
        T.Set(1,1,n,dfn[x],G[x]);
        Mat nxt = T.Query(1,1,n,dfn[top[x]],dfn[ed[top[x]]]);
        x=fa[top[x]];
        G[x][0][0] = G[x][0][1] += max(nxt[0][0],nxt[1][0]) - max(lst[0][0],lst[1][0]);
        G[x][1][0] += nxt[0][0] - lst[0][0];
    }

}

void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>a[i];
    for(int u,v,i=2;i<=n;i++){
        cin>>u>>v;
        e[u].push_back(v);
        e[v].push_back(u);
    }
    dfs1(1);
    dfs2(1,1);
    T.build(1,1,n);
    for(int x,y,i=1;i<=m;i++){
        cin>>x>>y;
        Modify(x,y);
        Mat res = T.Query(1,1,n,dfn[1],dfn[ed[1]]);
        cout<<max(res[0][0],res[1][0])<<'\n';    
    }
    
}

int main(){
    solve();
}
```

== 概率DP

=== DP求概率

```cpp
/* CF148D */ 
// 顺序求解 无效状态概率为0
#include <bits/stdc++.h>
using namespace std;

using ll = long long;
int w, b;
double dp[1010][1010];

int main() {
  cin.tie(nullptr)->sync_with_stdio(false);
  cin >> w >> b;
  memset(dp, 0, sizeof(dp));
  for (int i = 1; i <= w; i++) dp[i][0] = 1;  // 初始化
  for (int i = 1; i <= b; i++) dp[0][i] = 0;
  for (int i = 1; i <= w; i++) {
    for (int j = 1; j <= b; j++) {  // 以下为题面概率转移
      dp[i][j] += (double)i / (i + j);
      if (j >= 3) {
        dp[i][j] += (double)j / (i + j) * (j - 1) / (i + j - 1) * (j - 2) / (i + j - 2) * dp[i][j - 3];
      }
      if (i >= 1 && j >= 2) {
        dp[i][j] += (double)j / (i + j) * (j - 1) / (i + j - 1) * i / (i + j - 2) * dp[i - 1][j - 2];
      }
    }
  }
  cout << fixed << setprecision(9) << dp[w][b] << '\n';
  return 0;
}
```

=== DP求期望

```cpp
/* POJ2096 */
// 思路同概率：
// 通常是博弈 (根据博弈特点求两者期望关系)
// 初始化结局状态的概率
// 根据状态递推概率
#include <bits/stdc++.h>
using namespace std;
int n, s;
double dp[1010][1010];

int main() {
  cin.tie(nullptr)->sync_with_stdio(false);
  cin >> n >> s;
  dp[n][s] = 0;
  for (int i = n; i >= 0; i--) {
    for (int j = s; j >= 0; j--) {
      if (i == n && s == j) continue;
      dp[i][j] = (dp[i][j + 1] * i * (s - j) + dp[i + 1][j] * (n - i) * j + dp[i + 1][j + 1] * (n - i) * (s - j) + n * s) / (n * s - i * j);  // 概率转移
    }
  }
  cout << fixed << setprecision(4) << dp[0][0] << '\n';
  return 0;
}
```

=== 有后效性DP

#note[题目大意：给出一个 $n times m$ 的矩阵区域。一个机器人初始在第 x 行第 y 列，每一步机器人会等概率地选择停在原地、左移一步、右移一步、下移一步。如果机器人在边界则不会往区域外移动，问机器人到达最后一行的期望步数。]

```cpp
/* 高斯消元 层级dp */
const int N=1005;
const double eps=1e-9;
int n,m,x,y;
double dp[N][N];
vector<double> mat[N];
int sign(double x){
    if(x>eps)return 1;
    if(x<-eps)return -1;
    return 0;
}
void gauss_axis(){
    for(int i=1;i<=m-1;i++){
        double t=mat[i][i];
        if(!sign(t))continue;
       	mat[i][i]/=t;
        mat[i][i+1]/=t;
        mat[i][m+1]/=t;
        t=mat[i+1][i];
        if(!sign(t))continue;
        mat[i+1][i]-=t*mat[i][i];
        mat[i+1][i+1]-=t*mat[i][i+1];
        mat[i+1][m+1]-=t*mat[i][m+1];
    }
    for(int i=m;i>=2;i--){
        double t=mat[i][i];
        if(!sign(t))continue;
        t=mat[i-1][i];
        if(!sign(t))continue;
        mat[i-1][i]-=t*mat[i][i];
        mat[i-1][m+1]-=t*mat[i][m+1];
    }
}
void solve(){
    cin>>n>>m>>x>>y;
    cout<<fixed<<setprecision(5);
    if(m==1){
        cout<<2.0*(n-x)<<'\n';
        return;
    }
    for(int j=1;j<=m;j++)dp[n][j]=0;
	for(int i=n-1;i>=x;i--){
        for(int i=1;i<=m;i++)mat[i].assign(m+2,0);
        mat[1][1]=2,mat[1][2]=-1,mat[1][m+1]=3+dp[i+1][1];
        for(int j=2;j<=m-1;j++)mat[j][j-1]=-1,mat[j][j]=3,mat[j][j+1]=-1,mat[j][m+1]=4+dp[i+1][j];
        mat[m][m-1]=-1,mat[m][m]=2,mat[m][m+1]=3+dp[i+1][m];
    	gauss_axis();
        for(int j=1;j<=m;j++)dp[i][j]=mat[j][j];
    }
    cout<<dp[x][y]<<'\n';
}
```

== DP套DP

#note[
类似于 自动机上 DP 但又有些神秘压缩状态表示\
这种 题目一般求的是 一种用 状态机 不断输入 得到目标状态的方法数\
基础版 就是 自动机上 dp 定义一个 dp(i,S) 即可\
进阶版就是 需要考虑 状态的表示 \
比如 当 dp 是 二维的时候 它的转移 一般是 从上一行到下一行\
所以我们需要 以 一行作为状态 进行编码 （像轮廓线？）\
建立一个 输入上一行状态 和 得到下一行状态的 DFA (没错，就是直接转移一行)\
如果 要求 所有的 dp(n,m) == k 的方法数\
需要知道 这个状态的 答案是否 等于 k （注意到同一个状态的 dp 值一定相同）\
所以 我们在状态编码时 需要保证：\
通过 一行的状态 能够 求出该行 最后一格 (n,m) 处 的 dp 值\
据此，如果简单，可以直接按照历史 dp 值序列进行编码\
否则 可以使用 历史 dp 增量序列进行编码
]

#note[ACGT串计数 （就先浅学到这吧）]

```cpp
// 记得清空的重要性！
#include<bits/stdc++.h>
using namespace std;

const int N=1e3+1,D=4,M=15,mod=1e9+7;
int mp[128];

string S;
int n,m;
int ch[1<<M][D];
int pre[M],nxt[M];
int dp[2][1<<M];
int ans[M+1];

// 构建 DFA 关键是状态编码
void init(){
    // 记得清空！
    memset(ch,0,sizeof(ch));
    // 枚举"上一行"增量
    for(int s=0;s<1<<n;s++){
        // 增量->dp值
        for(int i=0;i<n;i++)pre[i]=(i?pre[i-1]:0)+(s>>i&1);
        // 枚举"某一维"的输入
        for(int c=0;c<D;c++){
            memset(nxt,0,sizeof nxt);
            // 求得"下一行"的dp值
            for(int i=0;i<n;i++){
                nxt[i]=i?max(pre[i],nxt[i-1]):pre[i];
                if(c==mp[S[i]])nxt[i]=max(nxt[i],(i?pre[i-1]:0)+1);
            }
            // dp值->增量
            for(int i=0;i<n;i++)ch[s][c]|=(nxt[i]-(i?nxt[i-1]:0))<<i;
        }
    }
}

void solve(){
    mp['A']=0;mp['C']=1;mp['G']=2;mp['T']=3;
    cin>>S>>m;
    n=S.size();
    init();
    int now=0;
    // 记得清空！
    memset(dp,0,sizeof dp);
    dp[now][0]=1;
    while(m--){
        // 输入 m 次
        memset(dp[now^1],0,sizeof dp[now^1]);
        for(int i=0;i<(1<<n);i++){
            for(int c=0;c<D;c++){
                dp[now^1][ch[i][c]]+=dp[now][i];
                dp[now^1][ch[i][c]]%=mod;
            }
        }
        now^=1;
    }
    // 记得清空！
    memset(ans,0,sizeof ans);
    for(int i=0;i<(1<<n);i++){
        int pc=__builtin_popcount(i);
        ans[pc]+=dp[now][i];
        ans[pc]%=mod;
    }
    for(int i=0;i<=n;i++)cout<<ans[i]<<"\n";
}

int main(){
    int T;
    cin>>T;
    while(T--)solve();
}
```

== DP优化

=== 常见优化

==== 滚动数组

#note[喂这是空间优化不是时间优化啊喂]

#note[滚动数组的核心：取余(对于 `%2` 可换成 `&1`)]

```cpp
// 1
int d[2][100];
for(int i = 0;i<100;i++){
    for(int j = 0;j<100;j++){
        // d[i%2][j] = d[(i-1)%2][j]+d[i%2][j-1];
        d[i&1][j] = d[i&1^1][j]+d[i&1^1][j-1];
}
}
// 2
int f[2][N];
for(int i=1;i<=n;i++){
    memcpy(f[i&1],f[i&1^1],sizeof f[0]);
    // 转移 f[i&1] <- f[i&1^1]    
}
// ans = f[n&1]
// 3
vector<int> f,tmp;
for(int i=1;i<=n;i++){
  swap(f,tmp);
  // f.fill(...);
  for(int j=1;j<=m;j++){
    // f[i]=...; 
  }
}
```

==== RQ优化

#note[见各种RQ方法：【前缀和】【线段树】【树状数组】【ST表】等]

==== 单调栈/单调队列优化

#note[适用单调栈/单调队列 辅助转移的最值选择 ]

===== 单调栈优化

+ *弹出非法栈顶*：通过比较当前元素与栈顶的大小，弹出不满足单调栈性质的栈顶。以单调递增的栈（即栈顶最大，维护最小值）为例，将所有大于等于当前元素的栈内元素全部弹出。
+ *加入当前元素*：将当前元素入栈即可。

===== 单调队列优化

+ *加入所需元素*：向单调队列重复加入元素直到当前元素达到所求区间的右边界，这样就能保证所需元素都在单调队列中。
+ *弹出越界队首*：单调队列本质上是维护的是所有已插入元素的最值，但我们想要的往往是一个区间最值。于是我们弹出在左边界外的元素，以保证单调队列中的元素都在所求区间中。
+ *获取最值*：直接取队首作为答案即可。

====== 多重背包优化

+ *优化前*(二进制分解)  
  + 时间 $O(n W log n)$  
  + 空间 $O(n log n+W)$  
+ *优化后*(单调队列)  
  + 时间 $O(n W)$  
  + 空间 $O(n+W)$  

```cpp
/* 单调队列优化的dp 典型:多重背包 */
// dp[i][j] = max(dp[i-1][j-k*w[i]] + k*v[i]) = 
// 压缩一维
// dp[r+j*w] = max(dp[r+(j-k)*w] + k*v) = max(dp[r+(j-k)*w] - (j-k)*v + j*v)
// dp[r+j*w] = max(dp[r+(j-k)*w] - (j-k)*v) + j*v 
// 以 j-k 为自变量 建立单调队列 由于 
// 视 j 为常数 
// 答案取决于 j-k 一个关于 k 的函数 结果为待转移的下标 j'
/* 多重背包代码 P1776*/
using LL = long long;
const int N=105,W=4e4+5;
struct Item{LL v,w,c;}item[N];
LL f[2][W],o,n,m,Q[W],h,t;
void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>item[i].v>>item[i].w>>item[i].c;
    // memset(f,0xc0,sizeof f);
    // f[o][0]=0;
    for(int i=1;i<=n;i++,o^=1){
        auto [v,w,c]=item[i];
        for(int r=0;r<w;r++){
        	h=t=0;
            for(int j=0;r+j*w<=m;j++){
                LL _=r+j*w;
                // f[o^1][_]=f[o][_];// 继承 无需
                while(Q[h]<j-c)h++;// 排除 
                // 注意: 单调队列中的候选元素严格来源于上一层o 不是本层o^1！
                while(h<t&&f[o][r+Q[t-1]*w]-Q[t-1]*v<f[o][r+j*w]-j*v)t--;// 比试
                Q[t++]=j;
                // 注意：取max用了20ms ??? 还是这样避免吧 
                f[o^1][_]=f[o][r+Q[h]*w]-Q[h]*v+j*v;// 上下层必定有
            }
        }
    }
    // 这是两种处理方式  
    // cout<<*max_element(f[o],f[o]+1+m)<<'\n';
    cout<<f[o][m]<<'\n';
}
```

==== CDQ 分治优化 DP

#note(title:"原理")[
    + *历史依赖性*: 只依赖之前的状态 `dp[j], j<i`
    + *偏序关系*: 转移对象之间存在可比较规则(目前已知可以维护 $3$ 维静态偏序的dp)
    + *可批量维护性*: 可以使用 数据结构 维护左边信息, 帮助更新右边的状态
]

#note(title:"过程")[
    + `cdq(l,mid)` 先计算出 `dp[l..mid]`
    + `merge(l,mid,r)` 使用 `dp[l..mid]` 构成的 *信息Node* 更新 `dp[mid+1...r]` *信息Node*
      - *注意* 先左递归 再`merge` 再右递归 (和正常的分治不一样)
      - *注意* `merge` 的时候 需要用到两侧 `sort` 不要在原查询序列更改, 请使用拷贝!!!
    + `cdq(mid+1,r)`
]

#note(title:"例题 寻找宝藏 P4849")[
    + 求 4维偏序 最大权值序列 及其方法数
    - *前缀最大值&计数 树状数组*
    - 注意 `cdq1(l,r)` 是 CDQ 分治 DP 的流程驱动, 遍历顺序是 左 merge 右
    - 但是 `cdq2(l,r)` 是 内部辅助计算 是真正的 CDQ分治 遍历顺序是 左右 merge
    - 最后一点 注意 多维偏序 `stable_sort` 以保证 
]

```cpp
/*
温馨提醒: 重排要保持稳定性 stable_sort
*/
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=8e4+5;
const LL INF=1e12;
const int mod=998244353;

// 带统计次数 的 前缀最大值 树状数组
struct BIT{
    int n;
    vector<pair<LL,int>> tr;
    void init(int n){
        this->n=n+1;
        tr=vector<pair<LL,int>>(n+2,{-INF,0});
    }
    void add(int i,LL v,int c){
        c%=mod;
        for(i++;i<=n;i+=i&-i)
            if(v>tr[i].first)tr[i]={v,c};
            else if(v==tr[i].first)(tr[i].second+=c)%=mod;// 注意取模
    }
    pair<LL,int> query(int i){
        pair<LL,int> res={-INF,0};
        for(i++;i;i-=i&-i)
            if(tr[i].first>res.first)res=tr[i];
            else if(tr[i].first==res.first)(res.second+=tr[i].second)%=mod;// 注意取模
        return res;
    }
    void erase(int i){// [突然发现] 这里必须单独设置一个 才行
        for(i++;i<=n;i+=i&-i)tr[i]={-INF,0};
    }
}T;

LL f[N];
int cnt[N];

struct Query{
    int id,a,b,c,d;
    LL v;
    bool left;
}q[N],q2[N];

// 注意!!! merge2 是基于 q2进行操作的!!!
// merge2 本质上是 "有 标签指导的 3维偏序"
// merge2 在贴有序标签(a)的前提下 已经有一个有序(b)分隔 重排序(c) 查询(d)范围内的 最大值 即可
void merge2(int l,int mid,int r){
    // cdq_dp merge 时, "先重排序"
    stable_sort(q2+l,q2+mid+1,[](const Query&a,const Query& b){return a.c<b.c;});
    stable_sort(q2+mid+1,q2+r+1,[](const Query&a,const Query& b){return a.c<b.c;});
    int L,R;
    for(L=l,R=mid+1;R<=r;R++){
        while(L<=mid&&q2[L].c<=q2[R].c){// 题目说的是 <=
            // 必须是左边 才能增加
            if(q2[L].left)T.add(q2[L].d,f[q2[L].id],cnt[q2[L].id]);// [!!!] 用 cnt 不是 1 !!!
            L++;
        }
        if(!q2[R].left){// 必须是右边 才能接收
            auto[v,c] = T.query(q2[R].d);// 题目说的是 <=
            if(v+q2[R].v>f[q2[R].id]){
                f[q2[R].id]=v+q2[R].v;// 注意 合并答案的时候 请选择自己
                cnt[q2[R].id]=c;// 自己这里显然 *1
            }else if(v+q2[R].v==f[q2[R].id])(cnt[q2[R].id]+=c)%=mod;// 注意取模
        }
    }
    // 清空!!! // 优化: [l,L)
    for(int i=l;i<L;i++)
        if(q2[i].left)T.erase(q2[i].d);
}
void cdq2(int l,int r){
    if(l==r)return;
    int mid=(l+r)/2;
    cdq2(l,mid);// 左递归
    cdq2(mid+1,r);// 右递归
    // [!!!!] 这里不是推 DP 啊啊啊 这是计算偏序对啊啊啊
    // [!!!!] 这里不是推 DP 啊啊啊 这是计算偏序对啊啊啊
    // [!!!!] 这里不是推 DP 啊啊啊 这是计算偏序对啊啊啊
    merge2(l,mid,r);// 中间 真·3.5维偏序
}
// merge1 是专门贴标签的 左/右 
void merge1(int l,int mid,int r){
    // // for(int i=l;i<=r;i++)q[i].left=i<=mid;// 标记左侧 一定要全部遍历 要不然有残留 
    memcpy(q2+l,q+l,sizeof(q[0])*(r-l+1));// 拷贝!!!
    // !!! 题目说的必然是 <= 要不然 这里怎么会随意设置 left(可能切割a相同的值)
    for(int i=l;i<=mid;i++)q2[i].left=true;// 标记左侧 但是这里是 q2 不必考虑残留
    // "第二维排序" 要满足a的前提稳定!!! 肯定是 <= 
    stable_sort(q2+l,q2+r+1,[](const Query& a,const Query& b){return a.b<b.b;});
    // 调用 cdq2 进行4维偏序转移计算答案
    cdq2(l,r);
}
// 入口
void cdq1(int l,int r){
    if(l==r)return;
    int mid=(l+r)/2;
    cdq1(l,mid);// 先解决左边
    // 这里才是 推 DP!!!
    // 这里才是 推 DP!!!
    // 这里才是 推 DP!!!
    merge1(l,mid,r);// 加个标签 启动4维!!!
    cdq1(mid+1,r);// 再解决右边
}
int n,m;
int D[N],cntD;
int getD(int v){return lower_bound(D+1,D+1+cntD,v)-D;}
void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++){
        auto&[id,a,b,c,d,v,_]=q[i];
        cin>>a>>b>>c>>d>>v;
        D[++cntD]=d;
    }
    // [啊啊啊 注意用到数据结构索引的那一维 离散化]
    // [啊啊啊 注意用到数据结构索引的那一维 离散化]
    // [啊啊啊 注意用到数据结构索引的那一维 离散化]
    sort(D+1,D+1+cntD);
    cntD=unique(D+1,D+1+cntD)-D-1;
    for(int i=1;i<=n;i++)q[i].d=getD(q[i].d);
    // 沟槽的 去重合并
    sort(q+1,q+1+n,[](const Query&a,const Query& b){return a.a!=b.a?a.a<b.a:a.b!=b.b?a.b<b.b:a.c!=b.c?a.c<b.c:a.d<b.d;});
    int tn=1;
    for(int i=2;i<=n;i++){
        if(q[i].a==q[tn].a&&q[i].b==q[tn].b&&q[i].c==q[tn].c&&q[i].d==q[tn].d)q[tn].v+=q[i].v;
        else q[++tn]=q[i];
    }
    n=tn;
    for(int i=1;i<=n;i++){
        q[i].id=i;
        f[i]=q[i].v;// [必须] 初始化 dp 值!!!
        cnt[i]=1;// [!!!] cnt 差点忘了!!!
    }
    // "第一维排序" 其实已经排过了 
    // sort(q+1,q+1+n,[](const Query&a,const Query& b){return a.a<b.a;});
    T.init(cntD);// 忘了 init 了 !!!!!! 这个 m 还真的有用!?!
    cdq1(1,n);
    int ans=0;
    LL mx=*max_element(f+1,f+1+n);
    for(int i=1;i<=n;i++)
        if(f[i]==mx)ans=(ans+cnt[i])%mod;
    cout<<mx<<"\n"<<ans<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

==== 倍增优化

#note[见【倍增】]

=== 问题结构优化

==== 斜率优化

#note[

$y_j = k_i x_j + b_i$

其中

$(x_j,y_j)$ 为转移起点 $j$ 关于 $j$ 的函数对\
$k_i,b_i$ 为关于 $i$ 的函数\
其中 $b_i$ 为所求 

若 $f_i = \min(b_i = y_j - k_i x_j)$  

由一次函数图像可知\
想要维护最小值 需要维护下凸包 反之维护上凸包
]

===== 二分 

```cpp
 /* P3195 玩具装箱(下凸壳模板) 普通斜率/二分斜率 */
using LL = long long;
const int N=5e4+5;
LL n,L,f[N],tp,s[N],c[N],p;
array<LL,2> Q[N];
LL cross(array<LL,2> a,array<LL,2> b,array<LL,2> c){
    return (b[0]-a[0])*(c[1]-a[1])-(b[1]-a[1])*(c[0]-a[0]);
}
void solve(){
    cin>>n>>L;
    L++;
    for(int i=1;i<=n;i++)cin>>c[i],s[i]=s[i-1]+c[i];
    for(int i=1;i<=n;i++)s[i]+=i;
    p=1;tp=0;
    Q[++tp]={0,0+0+2*0*L};
    for(int i=1;i<=n;i++){
        
        // 斜率单调时直接移动指针
        // while(p+1<=tp&&cross(Q[p],Q[p+1],{Q[p][0]+1,Q[p][1]+2*s[i]})>=0)p++; 

        // 斜率不单调时二分
        int l=1,r=tp-1;
        p=1;
        while(l<=r){
            int mid=(l+r)/2;
            if(cross(Q[mid],Q[mid+1],{Q[mid][0]+1,Q[mid][1]+2*s[i]})>0){
                p=mid+1;l=mid+1;
            }else r=mid-1;
        }
        
        f[i]=Q[p][1]-Q[p][0]*2*s[i]+(s[i]-L)*(s[i]-L);
        array<LL,2> ne = {s[i],f[i]+s[i]*s[i]+2*s[i]*L};
        while(tp>1&&cross(Q[tp-1],Q[tp],ne)<=0)tp--;// 维护凸包
        Q[++tp]=ne;
        // p=min(p,tp);// 注意：这里要规范 可能p偏大 
    }
    cout<<f[n]<<'\n';
}
```

===== CDQ

#note[见【CDQ分治】]

===== 平衡树

#note[见【平衡树】]

==== 四边形不等式优化

#note[四边形不等式优化 *抽象*  

$f(i) = \min(f(j) + w(j,i))$​  似乎是 正四边形不等式->min / 反四边形不等式->max  (决策单调性) 

$f(i,j) = min(f(i,k)+f(k+1,j)+w(i,j))$

如果转移代价$w(j,i)$ 满足四边形不等式 则有 决策单调性 可用优化 

]

#note[

*分治*  

可以使用分治优化的题目通常是那些“寻找最优决策点”的问题，且该决策点只与已知的、固定的输入数据有关，而不是与其他待求的 DP 状态有关。+ *可以用分治*：「POI2011」Lightning Conductor (如 OI-Wiki 所示)

*不可以用分治*

P3195 [HNOI2008] 玩具装箱 (因为它需要 `f[j]`，而 `f[j]` 正是我们要计算的目标，形成强依赖)  

*单调队列 + 二分*

]

#note[
  *PS:* xDyD 表示狀態數量複雜度是 $O(N ^ x)$，計算出一個狀態的複雜度是 $O(N ^ y)$
]

===== 分治（1D1D无依赖）

```cpp
/* 分治可用：无依赖 Lightning Conductor 210ms */
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=5e5+5;
int n,h[N];
double f[N];
// f[i] + h[i] >= h[j] + sqrt(abs(i-j))
// f[i] = max(h[j]+ceil(sqrt(abs(i-j)))) - h[i]
double val(int j,int i){
    return h[j]+sqrt(i-j)-h[i];
}
void DP(int l,int r,int kl,int kr){
   	int mid=(l+r)/2,k=kl;
    double cur=val(k,mid),tmp;
    for(int i=kl+1;i<=min(mid-1,kr);i++)
        if((tmp=val(i,mid))>cur)k=i,cur=tmp;// 注意：要保留double 因为这里比较更精细 速度
    f[mid]=max(f[mid],cur);
    if(l<mid)DP(l,mid-1,kl,k);
    if(r>mid)DP(mid+1,r,k,kr);
}
void solve(){
    cin>>n;
    for(int i=1;i<=n;cin>>h[i++]);
    DP(1,n,1,n);
    reverse(h+1,h+1+n);
    reverse(f+1,f+1+n);
    DP(1,n,1,n);
    for(int i=n;i>=1;cout<<(int)ceil(f[i--])<<'\n');// 注意：主要是double转型浪费时间
}
signed main(){solve();return 0;}
```

===== 二分队列（1D1D无/有依赖）

1. 无依赖

```cpp
/* 二分队列优化 无依赖 Lightning Conductor*/
#include<bits/stdc++.h>
using namespace std;
const int N=5e5+5;
double f[N];
int n,h,t,a[N];
struct CLR{int c,l,r;}Q[N];
double val(int j,int i){// j 转移到 i 的代价
    return a[j]+sqrt(i-j)-a[i];
}
void cal(){
    h=t=0;
    Q[0]={1,1,n};// 加入原点 注意:初始化不是{0,1,n} 因为认为1号为最优候选 而非不存在的 0！
    for(int i=1;i<=n;i++){
        if(h<=t&&Q[h].r<i)h++;// 最优解越界，弹出
        if(h<=t)Q[h].l=i;// 最优解左边界设置为i 合适的起始
        while(h<=t&&val(i,Q[t].l)>val(Q[t].c,Q[t].l))t--;// 把在l处不如的弹出
        if(h>t){// 队空了
            Q[++t]={i,i,n};// 直接加入当前最优解
        }else if(val(i,Q[t].r)<val(Q[t].c,Q[t].r)){// 如果在r处都不如尾
            if(Q[t].r<n)
                Q[++t]={i,Q[t].r+1,n};// 直接加入新的候选最优解(前提有空间r<n)
        }else {// 二分找
            int l=Q[t].l,r=Q[t].r,res=r;// 在l,r之间二分
            while(l<=r){
                int m=(l+r)/2;
                if(val(i,m)>val(Q[t].c,m)){// 二分的是转移的第一个优势终点m
                    res=m;
                    r=m-1;
                }else l=m+1;
            }
            Q[t].r=res-1;// 候选解的r规定
            Q[++t]={i,res,n};// 加入当前候选解
        }
        f[i]=max(f[i],val(Q[h].c,i));// 转移到 i 
    }
}
void solve(){
    cin>>n;
    for(int i=1;i<=n;cin>>a[i++]);
	cal();
    reverse(a+1,a+1+n);
    reverse(f+1,f+1+n);
    cal();
    for(int i=n;i>=1;cout<<(int)ceil(f[i--])<<'\n');
}
signed main(){solve();return 0;}
```

2. 有依赖

```cpp
/* 二分队列优化 单依赖 玩具装箱*/
#include<bits/stdc++.h>
using namespace std;
const int N= 5e4+5;
using LL = long long;
LL n,f[N],a[N],h,t,L;
struct CLR{int c,l,r;}Q[N];
LL val(int j,int i){// 这次会用到 f
   return f[j] + (a[i]-a[j]-L)*(a[i]-a[j]-L);
}
void insert(int x){
    int pos=n+1;// 边界点
    // 比头好
    while(h<=t&&val(x,Q[t].l)<=val(Q[t].c,Q[t].l))pos=Q[t--].l;// 继承边界 注意为l
    if(h<=t&&val(x,Q[t].r)<=val(Q[t].c,Q[t].r)){// 如果比尾好就二分
        int l=Q[t].l,r=Q[t].r;
        while(l<r){// r 当 res 不取等
            int m=(l+r)/2;
            if(val(x,m)<=val(Q[t].c,m))// 有优势
                r=m;// m为答案
            else l=m+1;// m不是答案 需要更大才有优势
        }
        Q[t].r=r-1;
        pos=r;
    }
    if(pos!=n+1)Q[++t]={x,pos,n};// 加入
}
void solve(){
    cin>>n>>L;L++;
    for(int i=1;i<=n;cin>>a[i],a[i]+=a[i-1],i++);// 注意：千万不要这样压行啊，喜提TLE
    for(int i=1;i<=n;a[i]+=i,i++);
    h=t=0;Q[0]={0,0,n};// 注意：这里要写{0,1,n}
	for(int i=1;i<=n;i++){
        // 求取答案
        f[i]=val(Q[h].c,i);// 注意：是 Q[h] 不是 Q[i]
        // 答案过期
        if(Q[h].r==i)h++;
        // 对齐下一个
        Q[h].l=i+1;// 注意：一定要对齐
        // 加入新答案
        insert(i);
    }
    cout<<f[n]<<'\n';
}
signed main(){solve();return 0;}
```

===== 2D1D专用优化

1. 专用优化

```cpp
/* Knuth优化 邮局(限制k个区间) */
// 成本函数如果能够递推 将会是证明四边形不等式的利器
// w[l][r] = w[l][r-1] + ... (P) (1)
// w[l][r+1] - w[l][r] = ... (T1) (2) 
// w[l+1][r+1] - w[l+1][r] = ... (T2) (3) 
// (2) - (3) 得到
// w[l][r+1] + w[l+1][r] - w[l+1][r+1] - w[l][r] >= 0 
// 则
// s[i-1][j] <= s[i][j] <= s[i][j+1]
// 故 任意的二阶差分递增
#include<bits/stdc++.h>
using namespace std;
const int N=3005,M=305;			
int n,m,x[N],f[N][M],w[N][N],s[N][M];
void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>x[i];
    sort(x+1,x+1+n);
    for(int i=1;i<=n;i++)
        for(int j=i+1;j<=n;j++)
            w[i][j]=w[i][j-1]+x[j]-x[(i+j)/2];
    // 注意：中间所求状态一定要初始化最差值 
    memset(f,0x3f,sizeof f);
    for(int j=0;j<=m;j++)f[0][j]=0;
    // 注意：只要依赖顺序维护好了，就没问题
    for(int i=1;i<=n;i++){
    	for(int j=m;j>=1;j--){
        	s[i][m+1]=n;
            for(int k=s[i-1][j];k<=s[i][j+1];k++){
                if(f[i][j]>f[k][j-1]+w[k+1][i]){
                  	f[i][j]=f[k][j-1]+w[k+1][i];
                    s[i][j]=k;
                }
            }
        }
    }
    cout<<f[n][m]<<'\n';
}
signed main(){solve();return 0;}
```

2. 另解

```cpp
/* 二分队列+WQS二分优化 邮局(限制k个区间)  */
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=5e5+5,M=5e5+5;
LL n,m,f[N],x[N],h,t,g[N],s[N];
// LL w[N][N]; // 注意：加强版 加强版 不可用
struct CLR{int c,l,r;}Q[N];
inline LL W(int l,int r){
    int m=(l+r)/2;
    return x[m]*(m-l)-(s[m-1]-s[l-1])+(s[r]-s[m])-x[m]*(r-m);
}
inline LL val(int j,int i,LL k){
    // return f[j]+w[j+1][i]+k;// 归约新问题
    return f[j]+W(j+1,i)+k;
}
void insert(int i,LL k){
    int p=0;
    // 注意：是先 l头 再 r尾 ！
	while(h<=t&&val(i,Q[t].l,k)<=val(Q[t].c,Q[t].l,k))p=Q[t--].l;// 注意：正向可等于！
    if(h<=t&&val(i,Q[t].r,k)<=val(Q[t].c,Q[t].r,k)){// 注意：这还是正向可等于！
        int l=Q[t].l,r=Q[t].r;
        while(l<r){
            int m=(l+r)/2;
            if(val(i,m,k)<=val(Q[t].c,m,k))r=m;// 注意：这里当然要等于
            else l=m+1;
        }
        Q[t].r=r-1;
        p=r;
    }
    if(p)Q[++t]={i,p,n};
}
int cal(LL k){
    memset(f,0x3f,sizeof f);
    memset(g,0,sizeof g);
    f[0]=0;
    h=t=0;Q[0]={0,1,n};
    for(int i=1;i<=n;i++){
        f[i]=val(Q[h].c,i,k);
        g[i]=g[Q[h].c]+1;
        if(Q[h].r==i)h++;
        Q[h].l=i+1;
       	insert(i,k);
    }
    return g[n];
}
void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>x[i];sort(x+1,x+1+n);
    for(int i=1;i<=n;i++)s[i]=s[i-1]+x[i];
    //for(int j=i+1;j<=n;j++)
    //    w[i][j]=w[i][j-1]+x[j]-x[(i+j)/2];
    int l=0,r=1e9;
    LL ans=0;
    while(l<=r){
        int mid=(l+r)/2;
        if(cal(mid)>=m){
            l=mid+1;// 注意：mid 和 m 要区分 
            ans=f[n]-mid*m;
        }else r=mid-1;
    }
    cout<<ans<<'\n';
}
signed main(){solve();return 0;}
```

==== Slope Trick 优化

#note[神奇函数表示方法：堆+特值]

===== 维护拐点

1. 其一

```cpp
/* Sequence P4331 最小递增序列&记录*/
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=1e6+5;
LL n,a[N],b[N];
void solve(){
    priority_queue<LL> Q;
    cin>>n;
    for(int i=1;i<=n;i++)cin>>a[i],a[i]-=i;
    // 找到一个非减 b[i] 使得 abs(a[i]-b[i]) 和最小
   	// f[i][j] = min(f[i-1][k<=j]) + abs(a[i]-j);
    LL ans=0;
    for(int i=1;i<=n;i++){
		Q.push(a[i]);Q.push(a[i]);// 加入现在的两个拐点
        ans+=Q.top()-a[i];// 这里永远调整 最小值 y_min
        Q.pop();// 弹出右侧正斜率拐点 
        b[i]=Q.top();// 这里永远是最小值所在拐点
    }
    for(int i=n-1;i>=1;i--)b[i]=min(b[i],b[i+1]);// 注意：666 还真是规约 
    cout<<ans<<'\n';
    for(int i=1;i<=n;i++)cout<<b[i]+i<<'\n';
}
signed main(){solve();return 0;}
```

2. 其二

```cpp
/* Safety P11598 */
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=2e5+5;
LL n,h,s[N],d;
void solve(){
    priority_queue<LL> L;
    priority_queue<LL,vector<LL>,greater<LL> > R;
    LL ans=0;d=0;
    cin>>n>>h;
    for(int i=1;i<=n;i++)cin>>s[i];
    // 注意：不是求之后的最小值，而是求当前的最小值？？
    // 但是当前的最小值，不就是之后的最小值吗 对！
    LL lt,rt;
    for(int i=1;i<=n;i++){
        lt=L.size()?L.top()-d:-1e18,rt=R.size()?R.top()+d:1e18;
        // 注意：求得最小值的增量 然后再插入 才符合常理 否则就不按公式走了
        if(s[i]<lt)// 注意：要平衡啊啊啊
            // 注意：看我的 最小值递推.png 即可了解为什么先 ans+=  
            ans+=lt-s[i],L.push(s[i]+d),L.push(s[i]+d),R.push(L.top()-d-d),L.pop();
        else if(s[i]>rt)
            ans+=s[i]-rt,R.push(s[i]-d),R.push(s[i]-d),L.push(R.top()+d+d),R.pop();
        else L.push(s[i]+d),R.push(s[i]-d);// 必然平衡
        d+=h;
    }
    cout<<ans<<'\n';
}
signed main(){solve();return 0;}
```

===== 维护斜率型

#note[本质是  \
单点依赖？ 非绝对值的依赖？凹函数依赖？取max不就是凸函数吗  \
贪心反悔。。。 但是对于斜率优化怎么形容呢？  \
哦哦哦 因为斜率最大处始终是左边对吗  \
现在我只能给出证明，而不能给出原理]

1. 其一

```cpp
/* 维护斜率??? 股票问题 CF865D */
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=3e5+5;
LL p[N],n,ans;
void solve(){
    cin>>n;for(int i=1;i<=n;i++)cin>>p[i];
    priority_queue<LL> Q;
    for(int i=1;i<=n;i++){
        Q.push(-p[i]);
        Q.push(-p[i]);
    	ans+=p[i]+Q.top();
    	Q.pop();
    }
    cout<<ans<<'\n';
}
signed main(){solve();return 0;}
```

2. 其二

```cpp
/* 维护斜率: 搬运土石问题 */
// f_i(x)  = minf_{i-1} + |y|*Z + max(X*((x-y) + (b_i - a_i)),-Y*((x-y) + (b_i - a_i)))
// 注：
// 1. min: 此题是维护凸函数
// 1.5 |y|*Z : 这是标准的叠加函数
// 2. max: 这里其实是一个|x - a_i| 类似物
// 3. max内部: 有一个 (x-y) 这是卷积下确界的标志性格式,有了它就可以看作卷积下确界？？？
// 4. max内部: 还有一个(b_i - a_i) 这是共有的对关于x的函数平移， 不要和左侧的 f_i(x) 混为一谈
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=1e5+5;
LL n,X,Y,Z,a,b;
void solve(){
    cin>>n>>X>>Y>>Z;
    stack<LL> neg,pos;// 左侧负斜率 和 右侧正斜率
    LL ans=0,d=0,l,r;// 答案 位移 左侧栈限制 右侧限制
    for(int i=1;i<=n;i++){
        cin>>a>>b;
        // 1.5 叠加
        d+=Z;
       	LL t=abs(a-b);
        // 注意:平移是一个一个移的
        // 4. 根据左移 b-a 说明原点右移 右栈左弹
        while(t--)
        if(b>a){
            // 3. 卷积下确界限定了斜率
            r = X;
            if(pos.size()){
                r = min(r,pos.top()+d);
                pos.pop();
            }
            // 4. 平移 左移时改变原点值
            ans+=r;
            // 4. 平移 加入左侧
            neg.push(r+d);
        }else {
            // 同理
            l = -Y;
            if(neg.size()){
                l = max(l,neg.top()-d);
                neg.pop();// 注意：这里别写对称式错误成为pos了
            }
            ans-=l;
            pos.push(l-d);
        }// while if
    }// for
    cout<<ans<<'\n';
}
signed main(){solve();return 0;}
```

==== WQS二分/凸优化

#note[代码见 上面2D1D专用优化的另解]

#note[常称作*带权二分*、*凸优化 DP*、*凸完全单调性 DP*、*Lagrange 乘子法*等，在国外也称作 *Aliens Trick*\
针对某种问题的优化  

要求：  \
类似于 想要优化二维的某个函数 f(i,j)的第二维：选择j个  \
前提是 f(i,j) 关于j是凸/凹的 确实不太直观  \
这就是 WQS 二分的基本想法。否则，可能不存在使得最优数量恰为 m 的附加惩罚 k。  \
但是看了图就明白了  

j是一个指标  \
在赋予某个惩罚k后最优解必然对应一个指标  \
而惩罚k看作是斜率，斜率单调，故j与k构成单调关系  \
我们可以认为，当二阶差分或导数非正或非负时就满足凸或凹  ]

=== 数学方法优化

+ 矩阵快速幂优化
    + 见【快速幂】

+ FFT优化
    + 见【FFT】

+ Lagrange 插值优化
    + 见【Lagrange插值】

=== 简化状态优化

==== DP套DP与DFA最小化

#note[见【DP套DP】【有限状态自动机】]

==== 状态设计优化

#note[1. 尝试*答案维与第1/2维互换*

2. 尽量使用*压缩*，如将 `bool f[i][64]` 转化为 `bitset<64>f[i]`]
