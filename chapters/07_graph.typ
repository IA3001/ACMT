
#import "../lib.typ": *

= 图论

== 图基础

#note[
    别急
]

== DFS (图论) 

- *栈实现*

```cpp
int sz;
array<int,3> ufe[N*M];
inline void push(int u,int f,int e){ufe[++sz]={u,f,e};}
inline array<int,3> pop(){return ufe[sz--];}
void dfs(int s){
    sz=0;
    push(s,0,-1);
    while(sz){
        auto [u,f,e]=pop();
        if(e==-1){
            e=hd[u];
            // 第一次访问... 初始化
        }else {
            e=edge[e].nxt;
            // 再次访问... 
        }
        if(e){
            int v=edge[e].to;
            push(u,f,e);
            if(v!=f)push(v,u,-1);
            // 遍历单个孩子... 传递信息
        }else {
            // 遍历结束... 收集信息
        }
    }
}
```

== BFS (图论) 

=== 队列实现 BFS

```cpp
queue<int> Q;
void bfs(int s){
    int d=0;
    Q.push(s);
    while(Q.size()){
        int t=Q.size();
        while(t--){
            // ...
        }
        d++;
    }
}
```

=== 双端队列 BFS (0-1BFS) 

```cpp
deque<int> dq;
void dbfs(int s){
    dq.push_back(s);
    while(dq.size()){
        int u=dq.front();dq.pop_front();
        for(auto v:e[u]){
            //...
            if(...)dq.push_front(v);// 0边权
            else dq.push_back(v);// 1边权
        }
    }
}
```

=== 优先队列 BFS

#note[事实上, 堆优化 Dijkstra 就是优先队列 BFS. ]

== 树上问题

=== 树基础

==== 树的定义

一个没有固定根结点的树称为 *无根树* (unrooted tree) . 无根树有几种等价的形式化定义：

- 有 $n$ 个节点, $n-1$ 条边的连通无向图
- 无向无环的连通图
- 任意两个结点之间有且仅有一条简单路径的无向图
- 任何边均为桥的连通图
- 没有圈, 且在任意不同两点间添加一条边之后所得图含唯一的一个圈的图

#note[在无根树的基础上, 指定一个结点称为 *根*, 则形成一棵 有根树 (rooted tree) . ]

==== 特殊的树

- *链 (chain/path graph) *：满足与任一结点相连的边不超过 2 条的树称为链. 
- *菊花/星星 (star) *：满足存在 $u$ 使得所有除 $u$ 以外结点均与 $u$ 相连的树称为菊花. 
- *有根二叉树 (rooted binary tree) *：每个结点最多只有两个儿子 (子结点) 的有根树称为二叉树. 常常对两个子结点的顺序加以区分, 分别称之为左子结点和右子结点. 大多数情况下, *二叉树* 一词均指有根二叉树. 
- *完整二叉树 (full/proper binary tree) *：每个结点的子结点数量均为 0 或者 2 的二叉树. 换言之, 每个结点或者是树叶, 或者左右子树均非空. 
- *完全二叉树 (complete binary tree) *：只有最下面两层结点的度数可以小于 2 , 且最下面一层的结点都集中在该层最左边的连续位置上. 
- *完美二叉树 (perfect binary tree) *：所有叶结点的深度均相同, 且所有非叶节点的子节点数量均为 2 的二叉树称为完美二叉树. 

==== 存储

- 只记录父结点
- 邻接表
- 左孩子右兄弟表示法

==== 树的遍历

===== 有根树

- 先序中序后序, 反推
- 树上 BFS (层序遍历) 
- 二叉树 

===== 无根树

- `dfs(u, f)`

=== 树的直径

==== 定义

树上任意两节点之间最长的简单路径即为树的「直径」. 

==== 性质

- 若树上所有边边权均为正, 则树的所有直径中点重合. 

==== 求法

===== 两次 DFS

#note[两次 DFS 的方法 *不适用* 于有 *负权边* 的树]

===== 树形 DP

```cpp
// 伪代码 
constexpr int N = 100000 + 10;
int n, d;
int dp[N];
vector<int> e[N];
void dfs(int u, int fa) {
  for (int v : e[u]) {
    if (v == fa) continue;
    dfs(v, u);
    d = max(d, dp[u] + dp[v] + 1);
    dp[u] = max(dp[u], dp[v] + 1);
  }
}
// dfs(1,0)
```

=== 树的中心

==== 定义

在树中, 如果节点 $x$ 作为根节点时, 从 $x$ 出发的最长链最短, 那么称 $x$ 为这棵树的中心. 

==== 性质

- 树的中心不一定唯一, 但最多有 2 个, 且这两个中心是相邻的. 
- 树的中心一定位于树的直径上. 
- 树上所有点到其最远点的路径一定交会于树的中心. 
- 当树的中心为根节点时, 其到达直径端点的两条链分别为最长链和次长链. 
- 当通过在两棵树间连一条边以合并为一棵树时, 连接两棵树的中心可以使新树的直径最小. 
- 树的中心到其他任意节点的距离不超过树直径的一半. 

==== 求法

- $O(n)$

```cpp
// 这份代码默认节点编号从 1 开始, 即 i ∈ [1,n], 使用vector存图
int d1[N], d2[N], up[N], x, y, mini = 1e9;  // d1,d2对应上文中的len1,len2
struct node {
  int to, val;  // to为边指向的节点, val为边权
};
vector<node> nbr[N];
void dfsd(int cur, int fa) {  // 求取len1和len2
  for (node nxtn : nbr[cur]) {
    int nxt = nxtn.to, w = nxtn.val;  // nxt为这条边通向的节点, val为边权
    if (nxt == fa) {
      continue;
    }
    dfsd(nxt, cur);
    if (d1[nxt] + w > d1[cur]) {  // 可以更新最长链
      d2[cur] = d1[cur];
      d1[cur] = d1[nxt] + w;
    } else if (d1[nxt] + w > d2[cur]) {  // 不能更新最长链, 但可更新次长链
      d2[cur] = d1[nxt] + w;
    }
  }
}
void dfsu(int cur, int fa) {
  for (node nxtn : nbr[cur]) {
    int nxt = nxtn.to, w = nxtn.val;
    if (nxt == fa) {
      continue;
    }
    up[nxt] = up[cur] + w;
    if (d1[nxt] + w != d1[cur]) {  // 如果自己子树里的最长链不在nxt子树里
      up[nxt] = max(up[nxt], d1[cur] + w);
    } else {  // 自己子树里的最长链在nxt子树里, 只能使用次长链
      up[nxt] = max(up[nxt], d2[cur] + w);
    }
    dfsu(nxt, cur);
  }
}
void GetTreeCenter() {  // 统计树的中心, 记为x和y (若存在) 
  dfsd(1, 0);
  dfsu(1, 0);
  for (int i = 1; i <= n; i++) {
    if (max(d1[i], up[i]) < mini) {  // 找到了当前max(len1[x],up[x])最小点
      mini = max(d1[i], up[i]);
      x = i;
      y = 0;
    } else if (max(d1[i], up[i]) == mini) {  // 另一个中心
      y = i;
    }
  }
}
```

=== 树的重心

==== 定义

如果在树 $T$ 中删去某个结点 $v$ 后, 得到的图 $T without {v}$ 中每个连通分量的大小均不超过原树结点数的一半, 就称这个结点 $v$ 为整棵树的 *重心* (centroid) . 删去某一结点后得到的最大连通分量的大小也称为该结点的 *重量* (weight) . 利用这一概念, 重心的定义可以叙述为重量不超过树结点数的一半的结点. 

#note[注意到, 得到的这些连通分量同样是无根树. 通过删去树的重心, 一棵树将变为若干棵至多原树一半大小的树. 重心的这一特性使得在树上应用分治思想解决问题成为可能. 这就是 [点分治], 也称为树的重心分解. ]

==== 性质

===== 无根树

1. 在树中删去结点 $v$ 后, 得到的图 $T without {v}$ 中每个连通分量的大小均不超过原树结点数的一半. 
2. 在所有删去某个结点后得到的最大连通分量大小中, 删去结点 $v$ 时所得到的值最小. 
3. 树中所有结点到某个结点的距离和中, 到结点 $v$ 的距离和最小. 

===== 有根树

1. 当树以结点 $v$ 为根时, 任一真子树的大小均不超过原树结点数的一半. 
2. 在所有以某个结点为根时的最大真子树大小中, 以结点 $v$ 为根时所得到的值最小. 
3. 在所有以某个结点为根时所有结点的深度和中, 以结点 $v$ 为根时深度和最小. 

===== 其他

1. 树的重心如果不唯一, 则恰有两个. 这两个重心相邻. 而且, 删去它们的连边后, 树将变为两个大小相同的连通分量. 
2. 在一棵树上添加或删除一个叶子, 那么它的重心最多只移动一条边的距离. 
3. 把两棵树通过一条边相连得到一棵新的树, 那么新树的重心在连接原来两棵树的重心的路径上. 
4. 一棵有根树的重心一定在根结点所在的重链上. 一棵树的重心一定是该树根结点重子结点对应子树的重心的祖先. 

==== 求法

===== DFS 统计子树大小

```cpp
const int MAXN = 50005;
int n;
// 这份代码默认节点编号从 1 开始, 即 i ∈ [1,n]
int siz[MAXN],  // 这个节点的「大小」 (所有子树上节点数 + 该节点) 
    weight[MAXN];  // 这个节点的「重量」, 即所有子树「大小」的最大值
vector<int> centroids;  // 用于记录树的重心 (存的是节点编号) 
vector<int> g[MAXN];
void dfs(int cur, int fa) {  // cur 表示当前节点 (current)
  siz[cur] = 1;
  weight[cur] = 0;
  for (int v : g[cur]) {
    if (v != fa) {  // v 表示这条有向边所通向的节点
      dfs(v, cur);
      siz[cur] += siz[v];
      weight[cur] = max(weight[cur], siz[v]);
    }
  }
  weight[cur] = max(weight[cur], n - siz[cur]);
  if (weight[cur] <= n / 2) {  // 依照树的重心的定义统计
    centroids.push_back(cur);
  }
}
void get_centroids() { dfs(1, 0); }
```

===== 换根 DP 统计深度和

#note[利用重心的性质]

=== 最近公共祖先 (LCA) 

==== 定义

两个节点的最近公共祖先, 就是这两个点的公共祖先里面, 离根最远的那个. 

==== 性质

- 如果 $u$ 是 $v$ 的祖先, 那么 $"LCA"(u, v) = u$. 
- 前序遍历中, $u$ 在 $v$ 的左边, 那么 $"LCA"(u, v)$ 一定在 $u$ 和 $v$ 之间. 
- 两点集并的最近公共祖先为两点集分别的最近公共祖先的最近公共祖先, 即
  $ "LCA"(S_1 union S_2) = "LCA"("LCA"(S_1), "LCA"(S_2)) $
- 两点的最近公共祖先必定处在树上两点间的最短路上；
- $"dis"(u, v) = "dep"[u] + "dep"[v] - 2 times "dep"["LCA"(u, v)]$. 
  可先求出 LCA, 再结合性质 3 求解树上两点间距离. 

==== 求法

===== 倍增

```cpp
// dfs:初始化st表
void dfs(int u){
    for(int i=1;i<=__lg(N);i++)
        st[u][i]=st[st[u][i-1]][i-1];
    for(auto v:e[u]){
        if(!dep[v]){
            st[v][0]=u;
            dep[v]=dep[u]+1;
            dfs(v);
        }
    }
}
int lca(int a,int b){
    if(dep[a]<dep[b])swap(a,b);
    for(int i=__lg(N);i>=0;i--)// 注意 dep[] 大小关系
        if(dep[st[a][i]]>=dep[b])a=st[a][i];
    if(a==b)return a;
    for(int i=__lg(N);i>=0;i--)
        if(st[a][i]!=st[b][i])a=st[a][i],b=st[b][i];
    return st[a][0];
}
```

===== Tarjan

#note[略]

===== 欧拉序 / dfn序 RMQ

#note[
    预处理 $O(n log n)$ 查询 $O(1)$ !!!    
]

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=5e5+5;
int n,m,s;
vector<int>e[N];
namespace Euler{
    int first[N];
    int euler[N*2],eulercnt;
    int dep[N],rmq[N*2][__lg(N*2)+2],P;
    // C return 没写 
    int upper(int a,int b){return dep[a]<dep[b]?a:b;}
    void dfs(int u,int fa){
        euler[++eulercnt]=u;
        rmq[eulercnt][0]=u;
        first[u]=eulercnt;
        dep[u]=dep[fa]+1;
        for(auto v:e[u])if(v!=fa){
            dfs(v,u);
            euler[++eulercnt]=u;
            rmq[eulercnt][0]=u;
        }
    }
    void build(){
        P=__lg(eulercnt);// !!!
        for(int p=1;p<=P;p++){
            for(int i=1;i<=eulercnt;i++){
                int ed=min(eulercnt,i+(1<<(p-1)));
                rmq[i][p]=upper(rmq[i][p-1],rmq[ed][p-1]);
            }
        }
    }
    int lca(int a,int b){
        int l=first[a],r=first[b];
        if(l>r)swap(l,r);
        int p=__lg(r-l+1);
        return upper(rmq[l][p],rmq[r-(1<<p)+1][p]);
    }
}
// 我寻思着 ST 表不也是 O(n log n) 预处理的吗 完爆 ST 表啊
namespace DFN{
    int dfn[N],dfncnt;
    int dep[N],rmq[N][__lg(N)+2],P;
    int upper(int a,int b){return dep[a]<dep[b]?a:b;}// 记住了 return
    void dfs(int u,int fa){
        dfn[u]=++dfncnt;
        dep[u]=dep[fa]+1;
        rmq[dfncnt][0]=fa;// 和 Euler 序不同的地方
        for(auto v:e[u])if(v!=fa)dfs(v,u);
    }
    void build(){
        P=__lg(dfncnt);
        for(int p=1;p<=P;p++){
            for(int i=1;i<=dfncnt;i++){
                int ed=min(dfncnt,i+(1<<(p-1)));
                rmq[i][p]=upper(rmq[i][p-1],rmq[ed][p-1]);
            }
        }
    }
    int lca(int a,int b){
        if(a==b)return a;// 和 Euler 序不同的地方
        int l=dfn[a],r=dfn[b];
        if(l>r)swap(l,r);
        l++;// 和 Euler 序不同的地方
        int p=__lg(r-l+1);
        return upper(rmq[l][p],rmq[r-(1<<p)+1][p]);
    }
}
void solve(){
    cin>>n>>m>>s;
    for(int u,v,i=1;i<n;i++){
        cin>>u>>v;
        e[u].push_back(v);
        e[v].push_back(u);
    }
    // Euler::dfs(s,0);
    // Euler::build();
    DFN::dfs(s,0);
    DFN::build();
    while(m--){
        int a,b;
        cin>>a>>b;
        // cout<<Euler::lca(a,b)<<"\n";
        cout<<DFN::lca(a,b)<<"\n";
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

===== 树链剖分

```cpp
int lca(int u, int v) {
  while (top[u] != top[v]) {
    if (dep[top[u]] > dep[top[v]])u = fa[top[u]];
    else v = fa[top[v]];
  }
  return dep[u] > dep[v] ? v : u;
}
```

===== Link Cut Tree

#note[
    TO DO !! 具体的还得见 LCT 
]

=== 树链剖分

*树链剖分* (树剖/链剖) 有多种形式, 如 *重链剖分*, *长链剖分* 和用于 Link/cut Tree 的剖分 (有时被称作「实链剖分」) . 大多数情况下 (没有特别说明时), 「树链剖分」都指「重链剖分」. 

==== 重链剖分

```cpp
int siz[MAXN], top[MAXN], son[MAXN], dep[MAXN], fa[MAXN], dfn[MAXN], rnk[MAXN],cnt;
void dfs1(int u, int f) {
  fa[u] = f, dep[u] = dep[f] + 1, siz[u] = 1;
  for (auto v : G[u]) {
    if (v == f) continue;
    dfs1(v, u);
    siz[u] += siz[v];
    if (siz[v] > siz[son[u]]) son[u] = v;
  }
}
void dfs2(int u, int ftop) {
  top[u] = ftop, dfn[u] = ++idx, rnk[idx] = u;
  if (son[u]) dfs2(son[u], ftop);
  for (auto v : G[u])
    if (v != son[u] && v != fa[u]) dfs2(v, v);
}
```

==== 长链剖分

#note[
    适用于 压缩与*高度相关*问题的 dp

    常用 *启发式*
]

```cpp
// CF1009F
#include<bits/stdc++.h>
using namespace std;
const int N=1e6+5;
vector<int> e[N];
int dep[N],h[N],fa[N],son[N],ans[N];
map<int,int> f[N];
void dfs1(int u){
    h[u]=1;
    for(auto v:e[u])if(v!=fa[u]){
        fa[v]=u;
        dep[v]=dep[u]+1;
        dfs1(v);
        h[u]=max(h[u],h[v]+1);
        if(h[son[u]]<h[v])son[u]=v;
    }
}
void dfs2(int u){
    if(son[u]){
        dfs2(son[u]);
        swap(f[u],f[son[u]]);
        ans[u]=ans[son[u]];
        f[u][dep[u]]++;
        if(f[u][dep[u]]>=f[u][ans[u]])ans[u]=dep[u];
        for(auto v:e[u])if(v!=son[u]&&v!=fa[u]){
            dfs2(v);
            for(auto [d,c]:f[v]){
                f[u][d]+=c;
                if(f[u][d]>f[u][ans[u]]||f[u][d]==f[u][ans[u]]&&d<ans[u])ans[u]=d;
            }
        }
    }else {
        f[u][dep[u]]=1;
        ans[u]=dep[u];
    }
}
void solve(){
    int n,u,v;cin>>n;
    for(int i=1;i<n;i++){
        cin>>u>>v;
        e[u].push_back(v);
        e[v].push_back(u);
    }
    dfs1(1);dfs2(1);
    for(int i=1;i<=n;i++)cout<<ans[i]-dep[i]<<"\n";
}
```
=== 树上启发式合并

$O(n log n)$

```cpp
/* 子树数颜色 */
#include <cstdio>
#include <vector>
using namespace std;
constexpr int N = 2e5 + 5;
int n, m;
// g[u]: 存储与 u 相邻的结点
vector<int> g[N];
// sz: 子树大小
// big: 重儿子
// col: 结点颜色
// L[u]: 结点 u 的 DFS 序
// R[u]: 结点 u 子树中结点的 DFS 序的最大值
// Node[i]: DFS 序为 i 的结点
// totdfn: 节点计数器, 也是当前遍历过节点的 DFS 序最大值
// ans: 存答案
// cnt[i]: 颜色为 i 的结点个数
// totColor: 目前出现过的颜色个数
int sz[N], big[N], col[N], L[N], R[N], Node[N], totdfn;
int ans[N], cnt[N], totColor;
void add(int u) {
  if (cnt[col[u]] == 0) ++totColor;
  cnt[col[u]]++;
}
void del(int u) {
  cnt[col[u]]--;
  if (cnt[col[u]] == 0) --totColor;
}
int getAns() { return totColor; }
void dfs0(int u, int p) {
  L[u] = ++totdfn;
  Node[totdfn] = u;
  sz[u] = 1;
  for (int v : g[u])
    if (v != p) {
      dfs0(v, u);
      sz[u] += sz[v];
      if (!big[u] || sz[big[u]] < sz[v]) big[u] = v;
    }
  R[u] = totdfn;
}
void dfs1(int u, int p, bool keep) {
  // 计算轻儿子的答案
  for (int v : g[u])
    if (v != p && v != big[u]) {
      dfs1(v, u, false);
    }
  // 计算重儿子答案并保留计算过程中的数据 (用于继承) 
  if (big[u]) {
    dfs1(big[u], u, true);
  }
  for (int v : g[u])
    if (v != p && v != big[u]) {
      // 子树结点的 DFS 序构成一段连续区间, 可以直接遍历
      for (int i = L[v]; i <= R[v]; i++) {
        add(Node[i]);
      }
    }
  add(u);
  ans[u] = getAns();
  if (!keep) {
    for (int i = L[u]; i <= R[u]; i++) {
      del(Node[i]);
    }
  }
}
int main() {
  scanf("%d", &n);
  for (int i = 1; i < n; i++) {
    int u, v;
    scanf("%d%d", &u, &v);
    g[u].push_back(v);
    g[v].push_back(u);
  }
  for (int i = 1; i <= n; i++) scanf("%d", &col[i]);
  dfs0(1, 0);
  dfs1(1, 0, false);
  scanf("%d", &m);
  for (int i = 1; i <= m; i++) {
    int q;
    scanf("%d", &q);
    printf("%d\n", ans[q]);
  }
  return 0;
}
```

=== 虚树

#note[
    二次排序 or 单调栈 
]

```cpp
// CF613D
#include<bits/stdc++.h>
using namespace std;
const int N=2e5+5;
int n,q,m;
vector<int> e[N],E[N];
int a[N],tmp[N],dfn[N],dfncnt,dep[N],st[N][__lg(N)+2],P;
void dfs1(int u){
    dep[u]=dep[st[u][0]]+1;
    dfn[u]=++dfncnt;
    for(int p=1;p<=P;p++)st[u][p]=st[st[u][p-1]][p-1];
    for(auto v:e[u])if(v!=st[u][0]){
        st[v][0]=u;
        // dep[v]=dep[u]+1;
        dfs1(v);
    }
}
int lca(int a,int b){
    if(dep[a]<dep[b])swap(a,b);
    for(int p=P;p>=0;p--)
        if(dep[st[a][p]]>=dep[b])
            a=st[a][p];
    if(a==b)return a;
    for(int p=P;p>=0;p--)
        if(st[a][p]!=st[b][p])
            a=st[a][p],b=st[b][p];
    return st[a][0];
}
// 什么鬼 二次排序还快 也许因为没有 root = 1
int build1(){
    // 1 二次排序
    sort(a+1,a+1+m,[](int a,int b){return dfn[a]<dfn[b];});
    int cn=0;
    for(int i=1;i<m;i++){
        tmp[++cn]=a[i];
        tmp[++cn]=lca(a[i],a[i+1]);
    }
    tmp[++cn]=a[m];
    // [!] ??? lca 的 dfn 序不是介于中间!!!! 而是 <=min(a,b)
    sort(tmp+1,tmp+1+cn,[](int a,int b){return dfn[a]<dfn[b];});
    cn = unique(tmp+1,tmp+1+cn)-tmp-1;
    // [!] ??? lca 的 dfn 序不是介于中间!!!! 而是 <=min(a,b)
    for(int i=1;i<=cn;i++)E[tmp[i]].clear();
    for(int i=1,lc,pre=0;i<cn;i++){
        lc=lca(tmp[i],tmp[i+1]);
        E[lc].push_back(tmp[i+1]);
    }
    return tmp[1];// 显然 dfn 最小者作为整棵子树的树头
}
int stk[N],tp;
int build2(){
    // 2 单调栈
    sort(a+1,a+1+m,[](int a,int b){return dfn[a]<dfn[b];});
    // stk[tp=1]=a[1];// 朴素方法/
    E[1].clear();
    stk[tp=1]=1;// 固定 1
    for(int i=1,lc;i<=m;i++){
        if(a[i]==1)continue;// 固定
        lc=lca(a[i],stk[tp]);
        if(lc!=stk[tp]){
            while(dfn[stk[tp-1]]>dfn[lc]){
                E[stk[tp-1]].push_back(stk[tp]);
                tp--;
            }
            if(dfn[stk[tp-1]]<dfn[lc]){
                E[lc].clear();
                E[lc].push_back(stk[tp]);
                stk[tp]=lc;
            }else E[lc].push_back(stk[tp--]);
        }
        E[a[i]].clear();
        stk[++tp]=a[i];// 入栈清空 
    }
    for(int i=1;i<tp;i++)
        E[stk[i]].push_back(stk[i+1]);
    return stk[1];
}
int ans[N],sz[N];
bool color[N];
void dfs2(int u){
    ans[u]=sz[u]=0;
    for(auto v:E[u]){
        dfs2(v);
        sz[u]+=sz[v];
        ans[u]+=ans[v];
    }
    if(color[u]){
        ans[u]+=sz[u];
        sz[u]=1;
    }else if(sz[u]>1){
        ans[u]++;
        sz[u]=0;
    }
}
void solve(){
    cin>>n;
    P=__lg(n);
    for(int i=1,u,v;i<n;i++){
        cin>>u>>v;
        e[u].push_back(v);
        e[v].push_back(u);
    }
    dfs1(1);
    cin>>q;
    bool ok;
    while(q--){
        ok=true;
        cin>>m;
        for(int i=1;i<=m;i++)cin>>a[i],color[a[i]]=true;
        for(int i=1;i<=m;i++)ok&=!color[st[a[i]][0]];
        if(!ok)cout<<"-1\n";
        else {
            int root=build1();
            // int root=build2();
            dfs2(root);
            cout<<ans[root]<<"\n";
        }
        for(int i=1;i<=m;i++)color[a[i]]=false;
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

=== 点分治

==== 静态点分治

#note[
    也叫重心分解

    使用前提:
    + 不同的点作为头不影响答案的求解
    + 答案来源有两种 跨过头 和 子树答案

    + 每次来到一颗子树, 为了找重心或者收集信息, 允许遍历当前子树有限次
        
    经典方法:
    + `get_centroid(int u,int fa)` 找到子树 $u$ 的重心
    + `dfs(int u,int fa,...)` 在子树 $u$ 上收集信息
    + `calc(int u,...)` 求解和重心 $u$ 有关的答案
    + `pdc(int u)` 对子树 $u$ 进行静态点分治 
]

#note(title:"模板题")[
    距离<= 边数<= 点对统计  
]

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=1e5+5;
namespace BIT{
    int tr[N];
    array<int,2> stk[N*2];
    int tp;
    void add(int i,int v){
        stk[++tp]={i,v};
        for(i++;i<N;i+=i&-i)tr[i]+=v;
    }
    int query(int i){
        int res=0;
        for(i++;i;i-=i&-i)res+=tr[i];
        return res;
    }
    void clear(){
        while(tp){
            auto [i,v]=stk[tp--];
            for(i++;i<N;i+=i&-i)tr[i]-=v;
        }
    }
}
int n,L,W;
vector<pair<int,int>> e[N];
bool vis[N];// 其一 vis pdc 
int sz[N];// 其二 sz pdc
void get_size(int u,int fa){
    // cout<<"get_size"<<u<<"\n";
    sz[u]=1;
    for(auto [v,_]:e[u])if(v!=fa&&!vis[v]){
        get_size(v,u);
        sz[u]+=sz[v];
    }
}
int get_centroid(int u,int fa){
    get_size(u,fa);
    int n=sz[u];
    bool f;
    do{
        f=false;
        for(auto [v,_]:e[u])if(v!=fa&&!vis[v]&&sz[v]>n/2){
            fa=u;u=v;f=true;
            break;
        }
    }while(f);
    return u;
}
struct Node{int d,e;}p[N];int cntP;
void dfs(int u,int fa,int dis,int edg){
    if(dis>W||edg>L)return;// 防止 long long
    p[++cntP]={dis,edg};
    for(auto [v,w]:e[u])if(v!=fa&&!vis[v])
        dfs(v,u,dis+w,edg+1);
}
LL calc(int u,int fa,int dis,int edg){
    // cout<<"calc"<<u<<"\n";
    dfs(u,fa,dis,edg);
    sort(p+1,p+1+cntP,[](const Node& a,const Node& b){return a.d<b.d;});
    for(int i=1;i<=cntP;i++)BIT::add(p[i].e,1);
    LL res=0;
    int l=1,r=cntP;
    while(l<r){
        if(p[l].d+p[r].d<=W&&L>=p[l].e){
            BIT::add(p[l].e,-1);
            res+=BIT::query(L-p[l].e);
            l++;
        }else {
            BIT::add(p[r].e,-1);
            r--;
        }
    }
    BIT::clear();
    cntP=0;
    return res;
}
LL pdc(int u){
    // cout<<"pdc"<<u<<"\n";
    vis[u]=true;
    LL res=calc(u,0,0,0);
    for(auto [v,w]:e[u])if(!vis[v]){
        res-=calc(v,u,w,1);// 容斥!!!
        res+=pdc(get_centroid(v,u));
    }
    return res;
}
void solve(){
    cin>>n>>L>>W;
    for(int i=2,f,w;i<=n;i++){
        cin>>f>>w;
        e[f].emplace_back(i,w);
        e[i].emplace_back(f,w);
    }
    cout<<pdc(get_centroid(1,0))<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

#note(title:"更多 静态点分治 code")[
    + 结合bfs(P7215):
        - 最小传递闭包的计算 同类,fa 进队列
    + 结合线段树(P3714):
        - 孩子按颜色排序 分批处理颜色段 最大权值线段树clear技巧
    + 结合二分答案(P4886):
        - 最小化 `d(a[i],c[i])+d(b[i],c[i])` 关于重心子树的答案判断 重心方向二分 
    + 结合多重背包(P6326 联通区内(c>=1)的多重背包):
    + 结合二分+单调队列(CF150E 最大中位数路径):
        -  *按秩(大小)排序处理* 二分中位数边界的+-1巧妙转化 
    + 结合单调栈(P9678 支配点对距离):
        - 预处理缩小备选答案范围 
    + 结合字符串哈希(P4075 模式字符串)
        - 字符串循环节延展至 n 前后缀哈希 串长同余分组
]

==== 动态点分治

#note[
    重心分解的重构树 性质:

    + 点分树上的每一个子树 一定是原树的一个连通块
    + 点分树上两点的 lca 一定在原树 两点的简单路径上(要不然谁来分割它们?)
    + 在*点分树*上, 两点 $x,y$ 的 lca 为 $c$ 则在原树上 `dist(x,y)=dist(x,c)+dist(c,y)` 
    + 这样就能处理 一个点 半径处理 的操作 (!? 强 ?!)
        - 讨论点 x 与其他点的某些答案是, 尤其是和距离有关的 某些答案时, 可以对其他点进行分类
        - 根据来自 x 点的哪个祖先重心, 其他点最多被分成 $O(log n)$ 类, 可能性的数量很少

    如何呢?
    + 点分树上, 点 x 的信息会被上方多个祖先重心统计, 作为每个祖先重心的子树信息
    + 一个点的信息, 会被多次统计 所以要容斥
    + *修改*时, 从 x 往上的链中, 每个上级重心*加入*了统计, 每个下级重心就*减少*统计
    + *查询*时, 从 x 往上的链中, 每*获得*上级重心的统计, 就*减少*下级重心的统计, 防止重复计算
]

#note(title:"模板题")[
    - 单点修改 半径求和
    - 注意需要 线段树需要动态开点
]

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=1e5+5;
// 题目数据
int n,q;
vector<int> e[N];
int w[N];
// 求解 dist
int dep[N],st[N][__lg(N)+2],P;
void dfs0(int u,int fa){
    dep[u]=dep[fa]+1;
    st[u][0]=fa;
    for(int p=1;p<=P;p++)st[u][p]=st[st[u][p-1]][p-1];
    for(auto v:e[u])if(v!=fa)dfs0(v,u);
}
int lca(int a,int b){
    if(dep[a]<dep[b])swap(a,b);
    for(int p=P;p>=0;p--)
    if(dep[st[a][p]]>=dep[b])a=st[a][p];
    if(a==b)return a;
    for(int p=P;p>=0;p--)
    if(st[a][p]!=st[b][p])a=st[a][p],b=st[b][p];
    return st[a][0];
}
int dist(int a,int b){return dep[a]+dep[b]-2*dep[lca(a,b)];}
// 动态开点线段树 单点增加 区间查询
namespace DSTree{
    struct DSTree{
        int lc,rc;
        int sum;    
    }tr[N*__lg(N)*__lg(N)*2];
    int tot;
    int new_node(){
        ++tot;
        memset(tr+tot,0,sizeof(tr[0]));
        return tot;
    }
    void add(int& i,int l,int r,int p,int v){
        if(!i)i=new_node();
        tr[i].sum+=v;
        if(l==r){
            // 既然单点更新 就不 up 了 
        }else {
            int mid=(l+r)/2;
            if(p<=mid)add(tr[i].lc,l,mid,p,v);
            else add(tr[i].rc,mid+1,r,p,v);
        }
    }
    int query(int i,int l,int r,int jl,int jr){
        if(l>r)return 0;// 
        if(!i)return 0;
        if(jl<=l&&r<=jr){
            return tr[i].sum;
        }else {
            int mid=(l+r)/2;
            int res=0;
            if(jl<=mid)res=query(tr[i].lc,l,mid,jl,jr);// 6
            if(jr>mid)res+=query(tr[i].rc,mid+1,r,jl,jr);
            return res;
        }
    }
}
// 点分治
namespace PDC{
    bool vis[N];
    int sz[N];
    // 点分树
    int p[N];
    // 线段树 一个加 一个减
    int rt[N],rt2[N];
    void get_size(int u,int fa){
        sz[u]=1;
        for(auto v:e[u])if(v!=fa&&!vis[v]){
            get_size(v,u);
            sz[u]+=sz[v];
        }
    }
    int get_centroid(int u,int fa){
        get_size(u,fa);
        int n=sz[u];
        bool f;
        do{
            f=false;
            for(auto v:e[u])if(v!=fa&&!vis[v]&&sz[v]>n/2){
                fa=u;u=v;f=true;break;
            }
        }while(f);
        return u;
    }
    void pdc(int u,int fa){
        vis[u]=true;
        p[u]=fa;
        for(auto v:e[u])if(!vis[v])
            pdc(get_centroid(v,u),u);
    }
    // u 节点增加 k
    // 我一直理解错了 原来不是孩子的直接影响
    // 而是容斥掉来自子树的影响啊啊啊 
    void add(int u,int k){
        int cur=u;
        // 自身要加
        DSTree::add(rt[u],0,n,0,k);
        while(p[cur]){// 如果有父亲
            int d=dist(u,p[cur]);
            DSTree::add(rt[p[cur]],0,n,d,k);
            DSTree::add(rt2[cur],0,n,d,k);// 容斥
            cur=p[cur];
        }
    }
    // 查询 距离 u 节点 d 距离的所有点权和 
    int query(int u,int d){
        if(d<0)return 0;
        int cur=u;
        // 自身
        int res=DSTree::query(rt[u],0,n,0,d);
        while(p[cur]){// 如果有父亲 且 够得到
            int dis=dist(u,p[cur]);
            if(d>=dis){// 不要以为点分树上的距离 ?!? 这里是 u !!! 
                res+=DSTree::query(rt[p[cur]],0,n,0,d-dis);// 这里要减 !!!!
                res-=DSTree::query(rt2[cur],0,n,0,d-dis);// 容斥 !!!
            }
            cur=p[cur];// 死循环!!!
        }
        return res;
    }
}
void solve(){
    cin>>n>>q;
    P=__lg(n)+1;
    for(int i=1;i<=n;i++)cin>>w[i];
    for(int u,v,i=1;i<n;i++){
        cin>>u>>v;
        e[u].push_back(v);
        e[v].push_back(u);
    }
    dfs0(1,0);// 准备 dist
    PDC::pdc(PDC::get_centroid(1,0),0);// 构建 点分树 
    for(int i=1;i<=n;i++)PDC::add(i,w[i]);// 初始化点权
    int op,x,k,y,lst=0;
    while(q--){
        cin>>op;
        if(op==0){
            cin>>x>>k;x^=lst;k^=lst;
            cout<<(lst=PDC::query(x,k))<<"\n";
        }else { 
            cin>>x>>y;x^=lst;y^=lst;
            PDC::add(x,y-w[x]);
            w[x]=y;
        }
    }
}
int main(){
    solve();
}
```

#note(title:"好题")[
    code 2 开关树上最远点对距离
    - 新数据结构: 延迟删除堆

    最优解: 线段树维护括号序 555!!!  
]

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=1e5+5,M=5e5+5;

int n,cnt,q;
vector<int> e[N];
bool black[N];

// dist 求解
int dep[N],st[N][__lg(N)+2],P;
void dfs0(int u,int fa){
    dep[u]=dep[fa]+1;
    st[u][0]=fa;
    for(int p=1;p<=P;p++)st[u][p]=st[st[u][p-1]][p-1];
    for(auto v:e[u])if(v!=fa)dfs0(v,u);
}
int lca(int a,int b){
    if(dep[a]<dep[b])swap(a,b);
    for(int p=P;p>=0;p--)
        if(dep[st[a][p]]>=dep[b])a=st[a][p];
    if(a==b)return a;
    for(int p=P;p>=0;p--)
        if(st[a][p]!=st[b][p])a=st[a][p],b=st[b][p];
    return st[a][0];
}
int dist(int a,int b){return dep[a]+dep[b]-dep[lca(a,b)]*2;}

// Trick: 延迟删除堆
struct Heap{
    priority_queue<int> Q,D;
    void clean(){while(D.size()&&Q.top()==D.top())Q.pop(),D.pop();}
    int size(){return Q.size()-D.size();}
    // WC 了!!! 没有返回值 直接本地 神秘 RE !!!
    void push(int x){Q.push(x);}// x 不是头必定不动 / x 是头必定不错 
    // int pop(){Q.pop();clean();}// 没有这东西 
    int top(){return Q.top();}
    int top2(){
        int tmp=Q.top();Q.pop();clean();
        int res=Q.top();Q.push(tmp);
        return res;
    }
    void del(int x){D.push(x);clean();}// 必须 clean
}S[N],cand[N],ans;

// 点分治
namespace PDC{
    bool vis[N];
    int sz[N];
    // 点分树
    int p[N];
    void get_size(int u,int fa){
        sz[u]=1;
        for(auto v:e[u])if(v!=fa&&!vis[v])
            get_size(v,u),sz[u]+=sz[v];
    }
    int get_centroid(int u,int fa){
        get_size(u,fa);
        int n=sz[u];
        bool f;
        do{
            f=false;
            for(auto v:e[u])if(v!=fa&&!vis[v]&&sz[v]>n/2){
                fa=u;u=v;f=true;break;
            }
        }while(f);
        return u;
    }
    void pdc(int u,int fa){
        vis[u]=true;
        p[u]=fa;
        for(auto v:e[u])if(!vis[v])pdc(get_centroid(v,u),u);
    }
    // 上传到全局答案
    void push_ans(int u){
        if(cand[u].size()>=2)ans.push(cand[u].top()+cand[u].top2());
    }
    // 删除全局答案
    void del_ans(int u){
        if(cand[u].size()>=2)ans.del(cand[u].top()+cand[u].top2());
    }
    // u 这个点可以作为一个地标
    void add(int u){
        // 上级 对全局答案 的贡献 可能要更新 先删除  
        del_ans(u);
        cand[u].push(0);// 显然可以是自己作为端点
        // 更新自己的贡献
        push_ans(u);// 更新完成
        // 现在更新 祖先的 cand
        for(int cur=u,fa=p[cur];fa;cur=fa,fa=p[cur]){
            del_ans(fa);
            // 首先 我的 S 更新了(插入一个元素) 所以要 撤回 S 在上级的贡献 (前提要有)
            if(S[cur].size())cand[fa].del(S[cur].top());
            // 然后 S 才能插入
            S[cur].push(dist(u,fa));
            // 重新贡献上级 
            cand[fa].push(S[cur].top());
            push_ans(fa);
        }
    }
    void del(int u){
        del_ans(u);
        cand[u].del(0);
        push_ans(u);
        for(int cur=u,fa=p[cur];fa;cur=fa,fa=p[cur]){
            del_ans(fa);
            assert(S[cur].size());// 必须
            // 依然撤回在上级的贡献 
            cand[fa].del(S[cur].top());
            // 然后 S 才能 删除
            S[cur].del(dist(u,fa));
            // 依然重新贡献上级 (前提还剩)
            if(S[cur].size())cand[fa].push(S[cur].top());
            push_ans(fa);
        }
    }
    int query(){assert(ans.size());return ans.top();}
}

void solve(){
    cin>>n;cnt=n;
    P=__lg(n);
    for(int u,v,i=1;i<n;i++){
        cin>>u>>v;
        e[u].push_back(v);
        e[v].push_back(u);
    }
    dfs0(1,0);// dist
    PDC::pdc(PDC::get_centroid(1,0),0);// 点分树 
    for(int i=1;i<=n;i++)PDC::add(i),black[i]=true;// 初始化都染成黑色
    char op;int x;cin>>q;
    while(q--){
        cin>>op;
        if(op=='C'){
            cin>>x;
            if(black[x])PDC::del(x),cnt--;
            else PDC::add(x),cnt++;
            black[x]^=1;
        }else {
            if(cnt<=1)cout<<cnt-1<<"\n";
            else cout<<PDC::query()<<"\n";
        }
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

#note(title:"更多 点分树 code")[
    + (P10603 半径增加 单点查询):
    + (P10604 第 k 小点对距离):
        - 使用二分答案 转化尾统计数量
    + (P3345 最佳指挥点花费)
        - 同样是 重心移动
    + (P3241 在线查询点权在 $[l,r]$ 内的所有点 到 $u$ 点的距离和)
        - 每个重心建立 u列表 fa列表 排序差分 得到答案
    + (P5311 至保留 编号 $[l,r]$ 内的点 求 $x$ 所在连通块的颜色数量)
        - Trick: 查询按 $r$ 排序逐个启用 
        - Trick: 只维护每种颜色 *最右出现位置* 实现防重
]

=== 边分治

==== 静态边分治

#note[
    + *重心边*: 划分两个连通区 最大值最小 / 最小值最大
    + 任意一点的度数 $<=3$  的情况下 (二叉树满足)
        + 重心边的 *其中一个端点*, 一定是树的*重心点*.
        + 如果重心点的 *最大子树* 有 *多个* 那么重心边就有 *多条*, 所有重心边一定 *相邻* 且 *共享重心点*.
        + 重心点通向 *最大子树* 的边就是重心边.
        + 重心边划分的 *较大的连通区* 的节点数是 $O(2/3 n)$ 规模.
        + 每次以重心边来分解当前连通区 *分治层数* 是 $O(log n)$.
    + 普通树可能分治层数较多 比如 *菊花图* 需要 *树的三度化重构*. 

    三度化注意
    + 补充的 *虚点* 和 *虚边* 权值要根据题目设置.
    + 重构的树, 边的序号从 `2` 开始使用 每一组正边和反边 连边顺序保证相邻.
    + 如果某条边的序号为 `e`, `e^1` 就是反向边.
    + 如果某条边的序号是 `e`, `e>>1` 是该边的组号.
    + 利用 `vis[边的组号]` 判断当前边, 是否是之前的重心边.

    寻找重心边的过程
    + 普通的树先完成*三度化重构*.
    + 遇到*之前的重心边*直接跳过.
    + 找到当前连通区的*重心点* `x`, 通向*最大子树*的边, 就是重心边.

    边分治的地位
    + 解决的类型和 *点分治* 相同, 都是 *路径/点对的统计* 类问题.
    + *点分治* 每次讨论 *跨越当前重心点* 的答案, *边分治* 每次讨论 *跨越当前重心边* 的答案.
    + 解决问题的类型相似, *边分治* 还要 *三度化重构*, 所以边分治是 *补充内容*.

    边分治的优势
    + *点分治* 需要处理 *多颗子树* 的信息.
    + *边分治* 只需要处理 *两个连通区* 的信息, 分治实现往往更容易.
    + *点分治* 有时候需要 *按秩处理*, *边分治* *不需要* 考虑这种处理顺序问题.
    + *边分治* 和 *边分树* 都是 *二叉结构* 带来的优势, 其实优势*极为强劲*!!!
]

#note(title:"模板题")[
    路径节点数 \* 路径点权最小值 的最大值
]

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=5e4+5;
int n;
int w[N*2];// WC 了 原来是 点权
LL ans;
struct Edge{
    int to,nxt;
    int c;// 虚边额外的信息 c 
}e[N*2+N*2*2];// 原树 和 重构树
int cntn;// 重构节点编号
int hd0[N],hd[N*2],cntE;// 原树 和 重构树
void init(){
    // 都初始化
    fill(hd0,hd0+1+n,0);
    fill(hd,hd+1+n*2,0);
    cntE=1;// 1
    cntn=n;// n
}
// 记住这里加的都是双边啊啊啊 !
void add_edge(int hd[],int u,int v,int c=1){
    e[++cntE]={v,hd[u],c};hd[u]=cntE;
    e[++cntE]={u,hd[v],c};hd[v]=cntE;
}
namespace EDC{
    bool vis[N*2+N];// [!!!] 这里的是边组 还要加上原树的边 !!!! 虽然树 是冗余的 
    int sz[N*2];// 经典大小
    // 重构
    void rebuild(int u,int fa){
        int lst=0;
        for(int i=hd0[u],v=e[i].to;i;i=e[i].nxt,v=e[i].to)
            if(v!=fa){
                if(!lst){// 第一次
                    // 连接 u -> v
                    add_edge(hd,u,v);
                    lst=u;
                }else {// 必须新建
                    ++cntn;
                    w[cntn]=w[u];// !!! 这回事忘了 
                    // 连接 lst -> cntn 0权
                    add_edge(hd,lst,cntn,0);
                    // 连接 cntn -> v
                    add_edge(hd,cntn,v);
                    lst=cntn;
                }
                rebuild(v,u);
            }
    }
    // 一样的 get_size 
    void get_size(int u,int fa){
        sz[u]=1;
        for(int i=hd[u],v=e[i].to;i;i=e[i].nxt,v=e[i].to)
            if(v!=fa&&!vis[i>>1])get_size(v,u),sz[u]+=sz[v];
    }
    // 这里不需要 fa 了, 好像本来就不需要 fa???
    int get_centroid(int u){
        get_size(u,0);// 好像 0 就可以 因为 分治点/边 会挡住 
        int n=sz[u],fa=0;// 定向重心 / 父子树会用到
        bool f;
        do{
            f=false;
            for(int i=hd[u],v=e[i].to;i;i=e[i].nxt,v=e[i].to)
                if(v!=fa&&!vis[i>>1]&&sz[v]>n/2){
                    fa=u;u=v;f=true;break;
                }
        }while(f);
        // 边分治 扩展代码
        int best=0,edg=0;
        for(int i=hd[u],v=e[i].to;i;i=e[i].nxt,v=e[i].to)
            if(!vis[i>>1]){
                int tmp=v==fa?n-sz[v]:sz[v];// 这里会用到 fa
                if(tmp>best){
                    best=tmp;
                    edg=i;
                }
            }
        return edg;
    }
    struct Node{
        int w,c;
        Node(int ww=0,int cc=0):w(ww),c(cc){}// 
        bool operator<(const Node& o){return w<o.w;}
    };
    void dfs(int u,int fa,int W,int C,vector<Node>& buf){
        buf.emplace_back(W,C);
        for(int i=hd[u],v=e[i].to;i;i=e[i].nxt,v=e[i].to)
            if(v!=fa&&!vis[i>>1])dfs(v,u,min(W,w[v]),C+e[i].c,buf);
    }
    void calc(int i){
        int v1=e[i].to;
        int v2=e[i^1].to;
        // 假设 以 v1 作为分段点
        vector<Node> L(1),R(1);// 可别 size_t 炸了
        dfs(v1,0,w[v1],0,L);
        dfs(v2,0,min(w[v1],w[v2]),e[i].c,R);
        sort(L.begin()+1,L.end());// +1
        sort(R.begin()+1,R.end());// +1
        int mx=-1e9;
        for(int l=L.size()-1,r=R.size()-1;l>=1;l--){
            while(r>=1&&R[r].w>=L[l].w){
                mx=max(mx,R[r].c);
                r--;
            }
            if(r<R.size()-1)ans=max(ans,(LL)L[l].w*(L[l].c+mx+1));
        }
        mx=-1e9;
        for(int l=L.size()-1,r=R.size()-1;r>=1;r--){
            while(l>=1&&L[l].w>=R[r].w){
                mx=max(mx,L[l].c);
                l--;
            }
            if(l<L.size()-1)ans=max(ans,(LL)R[r].w*(R[r].c+mx+1));
        }
    }
    void edc(int u){
        int edg=get_centroid(u);
        // 这里是强制二分递归的 不管两边是不是单点 "空边"
        if(!edg)return;// 必须特殊处理 单个点 找不到边 
        vis[edg>>1]=true;
        calc(edg);
        edc(e[edg].to);
        edc(e[edg^1].to);
    }
}
void print(int u,int fa,int* hd){
    cout<<fa<<" -> "<<u<<"\n";
    for(int i=hd[u],v=e[i].to;i;i=e[i].nxt,v=e[i].to){
        if(v!=fa){
            print(v,u,hd);
        }
    }
}
void solve(){
    cin>>n;
    init();// 先 init !!!
    for(int i=1;i<=n;i++)cin>>w[i];
    for(int u,v,i=1;i<n;i++){
        cin>>u>>v;
        add_edge(hd0,u,v);
    }
    // // 先重构
    EDC::rebuild(1,0);
    // // 再启动
    EDC::edc(1);
    // print(1,0,hd0);
    // print(1,0,hd);
    cout<<ans<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

==== 动态边分治

#note[
    边分树的原理
    + 边分树一般 *不需要显式* 的建立, 每条 *重心边* 的两侧信息, 由每个 *点集* 各自记录.
    + 初始时, 每个节点只记录 *和自己有关的重心边* 信息, 就是 *只有一条路径* 的信息树.
    + 每棵信息树的结构完全相同, 两颗信息树可以合并成一颗树, 代表合并后的 *点集* 拥有的 *重心边* 信息.
    + 信息树上的 *一个节点* 代表 *一条重心边*, 两侧信息的一个 *组合* 就是跨越重心边的一个 *点对/简单路径*.
    + 两颗信息树, 在 *同一个节点* , 可以枚举 *左右侧信息的组合*, 来枚举两个点集组合出的 *点对/简单路径*.
    + 重心边的信息不会保留所有可能性, 会有 *取舍策略*, 比如取最大、取最小、求和等等.
    + 这种信息树就是边分树, 因为时二叉结构树, 所以可以像线段树那样, 进行 *可持久化、合并* 操作.
    + 这种二叉结构带来的优势, 是点分树不具备的.
]

#note(title:"模板题 / 好题")[
    单点历史点集版本修改 区间版本差查询到某点距离和
]

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=2e5+5;
const int mod=1<<30;
int n,q,a[N],op,x,l,r;
LL lst;
struct Edge{
    int to,nxt;
    int w;
}e[N*2+N*2*2];
int hd0[N],hd[N*2],cntE;
int cntn;
void init(){
    fill(hd0,hd0+1+n,0);
    fill(hd,hd+1+n*2,0);
    cntE=1;
    cntn=n;
}
void add_edge(int hd[],int u,int v,int w){
    e[++cntE]={v,hd[u],w};hd[u]=cntE;
    e[++cntE]={u,hd[v],w};hd[v]=cntE;
}
namespace EDC{
    bool vis[N+N*2];
    int sz[N*2];
    void rebuild(int u,int fa){
        int lst=0;
        for(int i=hd0[u];i;i=e[i].nxt){
            int v=e[i].to;
            if(v!=fa){
                if(!lst){
                    add_edge(hd,u,v,e[i].w);
                    lst=u;
                }else {
                    ++cntn;
                    add_edge(hd,lst,cntn,0);
                    add_edge(hd,cntn,v,e[i].w);
                    lst=cntn;
                }
                rebuild(v,u);
            }
        }
    }
    void get_size(int u,int fa){
        sz[u]=1;
        for(int i=hd[u];i;i=e[i].nxt){
            int v=e[i].to;// 不花里胡哨的
            if(!vis[i>>1]&&v!=fa){
                get_size(v,u);
                sz[u]+=sz[v];
            }
        }
    }
    int get_centroid(int u){
        get_size(u,0);
        int n=sz[u],fa=0;
        bool f;
        do{
            f=false;
            for(int i=hd[u];i;i=e[i].nxt){
                int v=e[i].to;
                if(!vis[i>>1]&&v!=fa&&sz[v]>n/2){// [] > n/2 !!!
                    fa=u;u=v;f=true;break;
                }
            }
        }while(f);
        int best=0,edg=0;
        for(int i=hd[u];i;i=e[i].nxt){
            int v=e[i].to;
            if(!vis[i>>1]){
                int tmp=v==fa?n-sz[v]:sz[v];
                if(tmp>best){
                    best=tmp;
                    edg=i;
                }
            }
        }
        return edg;
    }
    struct EDCTree{
        int ch[2];
        int cnt;
        LL sum;
    }tr[N*(__lg(N)+1)*3];// 初始化 N log N + 合并 N log N + 询问 N log N
    #define ch(x,y) tr[x].ch[y]
    #define cnt(x) tr[x].cnt
    #define sum(x) tr[x].sum
    int rt[N],t[N],pre[N];// 实节点根 实节点尾 实版本
    int tot;// 节点计数器
    void dfs(int u,int fa,LL sum,int op){
        if(u<=n){
            if(!t[u])t[u]=rt[u]=++tot;// [hyw] 第一个点 要先有 !!!! 要不然第一个路径信息没了 
            ++tot;
            cnt(tot)=1;
            sum(tot)=sum;
            ch(t[u],op)=tot;
            t[u]=tot;
        }
        for(int i=hd[u];i;i=e[i].nxt){
            int v=e[i].to;
            if(!vis[i>>1]&&v!=fa)
                dfs(v,u,sum+e[i].w,op);
        }
    }
    void edc(int u){
        int edg=get_centroid(u);
        if(!edg)return;
        vis[edg>>1]=true;
        int v1=e[edg].to,v2=e[edg^1].to;
        dfs(v1,0,0,0);
        dfs(v2,0,e[edg].w,1);
        edc(v1);
        edc(v2);
    }
    // 当单个节点 y 合并到 x 上去 即插入 y 节点 返回新版本
    int add(int x,int y){
        if(!x||!y)return x|y;
        int i=++tot;
        tr[i]=tr[x];
        cnt(i)+=cnt(y);
        sum(i)+=sum(y);
        int d=ch(y,1)>0;// [] y !!!
        ch(i,d)=add(ch(x,d),ch(y,d));
        return i;
    }
    // 查询 (l,r] 范围节点 与单一 i 节点的跨越信息
    LL query(int l,int r,int i){
        if(!ch(i,0)&&!ch(i,1))return 0;
        int d=ch(i,1)>0;
        int L=ch(l,d^1),R=ch(r,d^1);
        LL res=(cnt(R)-cnt(L))*sum(ch(i,d))+(sum(R)-sum(L))*cnt(ch(i,d));
        return res+query(ch(l,d),ch(r,d),ch(i,d));
    }
}using EDC::pre,EDC::rt;
void solve(){
    cin>>n>>q;
    init();
    for(int i=1;i<=n;i++)cin>>a[i];
    for(int u,v,w,i=1;i<n;i++){
        cin>>u>>v>>w;
        add_edge(hd0,u,v,w);
    }
    EDC::rebuild(1,0);
    EDC::edc(1);
    for(int i=1;i<=n;i++)pre[i]=EDC::add(pre[i-1],rt[a[i]]);
    while(q--){
        cin>>op;
        if(op==1){
            cin>>l>>r>>x;l^=lst;r^=lst;x^=lst;
            cout<<(lst=EDC::query(pre[l-1],pre[r],rt[x]))<<"\n";
            lst%=mod;
        }else {
            cin>>x;x^=lst;
            swap(a[x],a[x+1]);
            pre[x]=EDC::add(pre[x-1],rt[a[x]]);
        }
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

#note(title:"更多 边分树 code")[
    + (CF833D 红黑边数量关系路径统计)
        - *正难则反(期望小小大大)* 方案全集 贡献计算法 分类讨论+对应信息收集
    + (P4565 双树 dist Trick)
        - T1 建立边分树 
        - `dis(x),dis(y)` 点权分配 
        - `dist(x,y)=path(x)+path(y)`
        - T2 枚举 lca 按编号合并 T1节点
    + (P2339 三树 dist Trick)
        - 点权边权化(中介虚点) + 转化为 直径求解(前提边权非负)
        - 直径结论 点集的直径端点合并 的 继承性 
            - 直径 (a,b) 与 (c,d)结合: 直径存在于 ${(x,y)|x!=y and x,y in {a,b,c,d}}$
]


=== AHU 算法

#note[
    灵活不如隔壁 树哈希 (因为这个 AHU 主要在于准确 用于研究)
]

#note[
    树同构 (AHU + 字符串Hash)
]

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=2e2+5;
const int mod=1e9+7;
const int base=233;
int pbase[N];
vector<int> e[N];
int n,h[N],sz[N],mx[N],ans;
map<int,int> rcd;
void init(){
    pbase[0]=1;
    for(int i=1;i<N;i++)// 初始化 base^i
        pbase[i]=1LL*pbase[i-1]*base%mod;
}
void dfs1(int u,int fa){// dfs 求重心
    sz[u]=1;mx[u]=0;// sz mx
    for(auto v:e[u])if(v!=fa){
        dfs1(v,u);
        sz[u]+=sz[v];// sz+=
        mx[u]=max(mx[u],sz[v]);// mx=max
    }
    mx[u]=max(mx[u],n-sz[u]);// mx=max
    ans=min(ans,mx[u]);// ans 
}
void dfs2(int u,int fa){// 求 hash
    h[u]=1;// 初始化 hash
    sz[u]=1;// 重心不一样 要重新计算
    for(auto v:e[u])if(v!=fa){
        dfs2(v,u);// 递归
        sz[u]+=sz[v];// 重心不一样 要重新计算
    }
    sort(e[u].begin(),e[u].end(),[&](const int& a,const int& b){
        return h[a]<h[b];
    });
    for(auto v:e[u])if(v!=fa)// 字符串 hash 
        h[u]=(1LL*h[u]*pbase[sz[v]]+h[v])%mod;
    h[u]=1LL*h[u]*base%mod;// ???
}
void solve(){
    int m;cin>>m;
    for(int i=1;i<=m;i++){
        cin>>n;
        // 清理树
        for(int i=1;i<=n;i++)e[i].clear();
        // 建树
        for(int i=1,fa;i<=n;i++){
            cin>>fa;if(!fa)continue;// C!
            e[fa].push_back(i);
            e[i].push_back(fa);
        }
        ans=n;// 初始化 ans
        dfs1(1,0);// 求解重心 
        int res=INT_MAX;
        for(int i=1;i<=n;i++)if(mx[i]==ans)
            dfs2(i,0),res=min(res,h[i]);// 取重心dfs
        if(!rcd.count(res))rcd[res]=i,cout<<i<<"\n";
        else cout<<rcd[res]<<"\n";// 已有
    }
}
int main(){
    init();// 初始化
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

=== 树哈希 (TreeHash)

#note[
    更高级 可以差分计算的 哈希 
]

#note[
    树同构 (TreeHash)
]

```cpp
#include<bits/stdc++.h>
using namespace std;
using ULL = unsigned long long;
const int N=2e2+5;
const ULL mod = 998244353;
const ULL mask = mt19937_64(time(0))();
vector<int>e[N];
int n;
int sz[N],mx[N],ans;
ULL h[N];
map<ULL,int> rcd;
ULL shift(ULL x){
    x^=mask;
    x^=x<<13;
    x^=x>>7;
    x^=x<<17;
    x^=mask;
    return x;
}
// 需要 n
void dfs1(int u,int fa){
    sz[u]=1;mx[u]=0;
    for(auto v:e[u])if(v!=fa){
        dfs1(v,u);
        sz[u]+=sz[v];
        mx[u]=max(mx[u],sz[v]);
    }
    mx[u]=max(mx[u],n-sz[u]);
    ans=min(ans,mx[u]);
}
void dfs2(int u,int fa){
    h[u]=1;
    for(auto v:e[u])if(v!=fa){
        dfs2(v,u);
        h[u]+=shift(h[v]);
    }
}
void solve(){
    int m;cin>>m;
    for(int i=1;i<=m;i++){
        cin>>n;
        for(int i=1;i<=n;i++)e[i].clear();
        for(int i=1,fa;i<=n;i++){
            cin>>fa;if(!fa)continue;
            e[i].push_back(fa);
            e[fa].push_back(i);
        }
        ans=n;
        dfs1(1,0);
        ULL res=-1;
        for(int i=1;i<=n;i++)if(ans==mx[i])
            dfs2(i,0),res=min(res,h[i]);
        if(!rcd.count(res))rcd[res]=i;
        cout<<rcd[res]<<"\n";
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

#note[
    (TreeHashPro)
    
    括号序列计数
]

```cpp
#include<bits/stdc++.h>
using namespace std;
using ULL = unsigned long long; // 使用无符号长整型自然溢出
const int N=1e5+5;
const int mod=998244353;
// 生成一个随机掩码，防止被针对性卡哈希
const ULL mask = mt19937_64(time(0))();
// 快速幂求逆元：ksm(a) 默认求 a 的 mod-2 次方，即 1/a (mod p)
ULL ksm(ULL a,ULL b=mod-2){
    ULL res=1;
    for(;b;b>>=1,a=a*a%mod)if(b&1)res=res*a%mod;
    return res;
}
// 哈希扰动函数：类似于 XorShift 随机数生成器
// 作用是将子树的哈希值打乱，防止 sum 哈希冲突（例如 1+3 和 2+2）
ULL shift(ULL x){
    x^=mask;
    x^=x<<13;
    x^=x>>7;
    x^=x<<17;
    x^=mask;
    return x;
}
struct Tree{
    ULL hash; // 子树的哈希值
    ULL deg;  // 当前节点的度数（子节点个数）
    ULL ans;  // 当前子树产生的本质不同括号序列方案数
    map<ULL,ULL> son; // 记录每种哈希值的子节点出现了多少次，用于处理多重集排列
    Tree(){clear();}
    // 初始化
    void clear(){
        hash=1; // 哈希初值设为 1
        deg=0;
        ans=1;  // 方案数初值设为 1（空树只有一种方案）
        son.clear();
    }
    // 【核心】加入一个子树 o 到当前节点
    void add(Tree& o){
        ULL tmp=shift(o.hash); // 获取子树扰动后的哈希值
        hash+=tmp;             // 累加哈希（Sum Hash）
        // 更新方案数：
        // 1. ans * ++deg: 原本是 deg!，现在变成 (deg+1)!，所以乘上 (deg+1)
        // 2. ksm(++son[tmp]): 处理同构子树。假设该哈希原有 c 个，现在 c+1 个。
        //    分母需要从 c! 变为 (c+1)!，所以需要除以 (c+1)，即乘上 inv(c+1)
        // 3. * o.ans: 乘上子树内部的方案数
        ans = ans * ++deg % mod * ksm(++son[tmp]) % mod * o.ans % mod;
    }
    // 【核心】从当前节点移除一个子树 o（用于换根和回溯）
    void remove(Tree& o){
        ULL tmp=shift(o.hash);
        hash-=tmp; // 减去哈希
        // 更新方案数（add 的逆运算）：
        // 1. ksm(deg--): 原本是 deg!，移除一个变成 (deg-1)!，所以除以 deg
        // 2. son[tmp]--: 该哈希子树数量从 c 变 c-1。
        //    分母从 c! 变为 (c-1)!，相当于分子乘了 c。注意这里 son[tmp]-- 返回的是减之前的值 c
        // 3. ksm(o.ans): 除以该子树内部的方案数
        ans = ans * ksm(deg--) % mod * son[tmp]-- % mod * ksm(o.ans) % mod;
    }
} sub[N], root[N]; // sub[i]存以1为根时的子树信息，root[i]存以i为根时的全树信息
vector<int> e[N];
map<ULL,ULL> trees; // 记录最终每种本质不同的树的方案数，key是树哈希，val是方案数
// 第一次 DFS：自底向上计算，默认 1 为根
void get_sub(int u,int fa){
    for(auto v:e[u]) if(v!=fa){
        get_sub(v,u);
        sub[u].add(sub[v]); // 将子节点 v 合并到 u
    }
}
// 第二次 DFS：自顶向下换根
// u 是当前的根（父节点），我们现在要处理 u 的子节点 v，尝试让 v 成为整棵树的根
void get_root(int u,int fa){
    for(auto v:e[u]) if(v!=fa){
        // --- 换根步骤 ---
        // 1. 从 u 中移除 v 的贡献
        // 此时 root[u] 变成了 "除去 v 子树之外，树的其他部分"
        root[u].remove(sub[v]);
        // 2. 初始化 root[v]
        // root[v] 目前只包含 v 的下层子树信息（和 sub[v] 一样）
        root[v] = sub[v];
        // 3. 将 u 合并到 v 上
        // 此时 u 已经变成了 v 的一个子节点（包含了树的上半部分）
        root[v].add(root[u]);
        // 4. 回溯恢复 u 的状态
        // 这一步非常重要！如果不恢复，u 的信息就丢失了，
        // 处理 u 的下一个兄弟节点时，需要用到完整的 u。
        // 注意：这里恢复 root[u] 是为了下一次循环或者回溯给 u 的父亲用，
        // 而不是给下面的 get_root(v, u) 用，因为递归下去用的是 root[v]。
        root[u].add(sub[v]);
        // 5. 递归处理 v
        get_root(v,u);
    }
    // 记录以 u 为根时的哈希值和方案数
    // map 会自动去重：如果两个根产生了相同的哈希（同构），只记录一次（或覆盖，值是一样的）
    trees[root[u].hash] = root[u].ans;
}
void solve(){
    int n; cin>>n;
    for(int i=1;i<=n;i++){
        e[i].clear();
        sub[i].clear();
        root[i].clear();
    }
    trees.clear();
    for(int u,v,i=1;i<n;i++){
        cin>>u>>v;
        e[u].push_back(v);
        e[v].push_back(u);
    }
    // 步骤 1: 以 1 为根计算所有子树信息
    get_sub(1,0);
    // 步骤 2: 准备换根，root[1] 初始状态就是 sub[1]
    root[1] = sub[1];
    // 步骤 3: 换根 DP 遍历所有节点作为根的情况
    get_root(1,0);
    // 步骤 4: 统计答案
    // 题目要求本质不同的树的方案数之和
    // trees map 中 key 是哈希值，value 是方案数。
    // 遍历 map 累加 value 即可。
    ULL ans=0;
    for(auto [k,v]:trees) ans=(ans+v)%mod;
    cout<<ans<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    int T; cin>>T;while(T--) solve();
}
```

=== 树上随机游走

#note[
    通法: 设 $u$ 点的答案为 $f_u$ 假设公式 $f_u = A_u f_("fa"_u) + B_u$ 

    推柿子
]

==== 一步期望距离

#note[
    + $f_u$ 代表向父节点移动的期望距离 
    + $g_u$ 代表父节点到该节点移动的期望距离
$
    f_u 
    & = (w(u,"fa"_u)+sum_("son"_u) (w(u,v)+f_v+f_u))/d_u\
    & = (w(u,"fa"_u)+sum_("son"_u) (w(u,v)+f_v) + (d_u-1)f_u)/d_u\
    & = sum_("adj"_u) w(u,v) +  sum_("son"_u) f_v\
    & = "u为根的子树的所有邻边" times 2 - w(u,"fa"_u)
$
$
    g_u 
    & = (w("fa"_u,u)+(w("fa"_("fa"_u),"fa"_u)+g_("fa"_u)+g_u)+sum_("son"_("fa"_u))(w(u,v)+f_v+g_u)-w("fa"_u,u)-f_u-g_u)/d_u\
    & = ((sum_("adj"_("fa"_u))w("fa"_u,t)+ sum_("son"_("fa"_u))f_v) + (d_("fa"_u)-1)g_u - f_u + g_("fa"_u))/d_("fa"_u)\
    & = (f_("fa"_u)+(d_("fa"_u)-1)g_u - f_u + g_("fa"_u))/(d_("fa"_u))\
    & = f_("fa"_u) - f_u + g_("fa"_u)
$
]

```cpp
vector<pair<int,int>> e[N];
void dfs1(int u,int fa){
    f[u]=0;
    for(auto [v,w]:e[u]){
        f[u]+=w;
        if(v==fa)continue;
        dfs1(v,u);
        f[u]+=f[v];
    }
}
void dfs2(int u,int fa){
    if(fa)g[u]=f[fa]-f[u]+g[fa];
    else g[u]=0;
    for(auto [v,w]:e[u])if(v!=fa)dfs2(v,u);
}
```

==== S -> T 期望经过次数

#note[
    我们以 $T$ 为根
    
    $f_u$ 代表 $u$ *经过*次数

    $f_u = A_u f_("fa"_u) + B_u$

$
  f_u 
  & = cases(
    1\,& u = T,
    [u=S] + ["fa"_u != T](f_("fa"_u))/(d_("fa"_u)) + sum_("son"_u) (f_v)/(d_v)\, & "otherwise"
  )
$
对于 otherwise
$
    f_u
    & = [u=S] + ["fa"_u != T]((f_("fa"_u))/(d_("fa"_u))) + sum_("son"_u) (A_v f_u + B_v)/(d_v)\
    & = (["fa"_u != T](1/(d_("fa"_u))))/(1 - sum_("son"_u) A_v/d_v) f_("fa"_u) + ([u=S] + sum_("son"_u) B_v/d_v)/(1 - sum_("son"_u) A_v/d_v) 
$
注意到
$
  A_u &= (["fa"_u != T](1/(d_("fa"_u))))/(1 - sum_("son"_u) A_v/d_v)\
  B_u &= ([u=S] + sum_ ("son"_u) B_v/d_v)/(1 - sum_("son"_u) A_v/d_v)
$
]

```cpp
// 404
#include<bits/stdc++.h>
using namespace std;
const int N=2e5+5;
const int mod=998244353;
int ksm(int a,int b=mod-2){
    int res=1;
    for(;b;b>>=1,a=1LL*a*a%mod)if(b&1)res=1LL*res*a%mod;
    return res;
}
vector<int> e[N];
int n,S,T;
int d[N],A[N],B[N],f[N];
void dfs1(int u,int fa){
    int tmp=0;
    if(fa)A[u]=(fa!=T)*ksm(d[fa]);
    else A[u]=0;
    B[u]=(u==S);
    for(auto v:e[u])if(v!=fa){
        dfs1(v,u);
        tmp=(tmp+1LL*A[v]*ksm(d[v])%mod)%mod;
        B[u]=(B[u]+1LL*B[v]*ksm(d[v]%mod))%mod;// 公式写错了
    }
    tmp=(1LL-tmp+mod)%mod;
    A[u]=1LL*A[u]*ksm(tmp)%mod;
    B[u]=1LL*B[u]*ksm(tmp)%mod;
}
void dfs2(int u,int fa){
    if(fa) f[u]=(1LL*A[u]*f[fa]+B[u])%mod;
    else f[u]=1;
    for(auto v:e[u])if(v!=fa)dfs2(v,u);
}
void solve(){
    cin>>n>>S>>T;   
    for(int u,v,i=1;i<n;i++){
        cin>>u>>v;
        e[u].push_back(v);d[u]++;
        e[v].push_back(u);d[v]++;
    }
    dfs1(T,0);
    dfs2(T,0);
    for(int i=1;i<=n;i++)cout<<f[i]<<" ";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

== 有向无环图 (DAG) 

=== 定义

#note[无]

=== 性质

- 能 *拓扑排序* 的图, 一定是有向无环图；
- 有向无环图, 一定能拓扑排序；

=== 判定

- 检验它是否可以进行 *拓扑排序* 即可. 
- 当然也有另外的方法, 可以对图进行一遍 DFS, 在得到的 DFS 树上看看有没有连向祖先的非树边 (返祖边) . 如果有的话, 那就有环了. 

=== 应用

- DP 求最长 (短) 路

== 拓扑排序

=== 定义

1. *关键路径：* AOE 网中从源点到汇点的最长路径的长度. 
2. *递推求最早 和 最迟发生时间：* 按拓扑顺序求, 最早发生时间从前往后递推, 最迟发生时间从后往前递推. 

=== Kahn 算法

#note[略]

=== 求字典序最大/最小的拓扑排序

#note[略]

== 最短路问题

=== 最短路

==== Floyd

- $O(n^3)$

```cpp
for(int k=1;k<=n;k++)
    for(int i=1;i<=n;i++)
        for(int j=1;j<=n;j++)
            dist[i][j]=min(dist[i][j],dist[i][k]+dist[k][j]);
```

==== Bellman-Ford & SPFA

- $O(m n)$

```cpp
queue<int> Q;
int dist[N];
bool inq[N];
int vis[N];// 外加可以判断负环
bool spfa(int s){
    memset(dist,0x3f,sizeof(dist[0])*(n+1));
    memset(inq,0,sizeof(inq[0])*(n+1));
    memset(vis,0,sizeof(vis[0])*(n+1));
    Q.push(s);
    dist[s]=0;
    while(Q.size()){
        int u=Q.front();Q.pop();
        inq[u]=false;
        for(auto [v,w]:e[u]){
            if(dist[v]>dist[u]+w){
                dist[v]=dist[u]+w;
                if(!inq[v])Q.push(v),inq[v]=true;
                if(++vis[v]==n){
                    while(Q.size())Q.pop();
                    return false;
                }
            }
        }
    }
    return true;
}
```

==== Dijkstra

- $O((n+m) log m)$

```cpp
struct Node{
    int u,d;
    bool operator<(const Node& o)const {return d>o.d;}
};
bool vis[N];
int dist[N];
void dijk(int s){
    memset(dist,0x3f,sizeof(dist[0])*(n+1));
    priority_queue<Node> Q;
    Q.push(s);
    dist[s]=0;
    while(Q.size()){
        auto [u,d] = Q.top();Q.pop();
        if(vis[u])continue;
        vis[u]=true;
        for(auto [v,w]:e[u]){
            if(dist[v]>dist[u]+w){
                dist[v]=dist[u]+w;
                Q.push({v,dist[v]});
            }
        }
    }
}
```

==== Johnson 全源最短路径算法

- $O(n m log m)$

```cpp
#include <bits/stdc++.h>
using namespace std;
const int MAXN = 1e5 + 5; // 最大节点数
const int INF = 1e9;      // 定义无穷大
struct Edge {int v, w;};// 边的终点和权值
vector<Edge> adj[MAXN]; // 邻接表存储图结构
long long h[MAXN];      // 势能数组 (用于重新标记边权) 
long long dist[MAXN];   // 单源最短路的距离数组
int n, m;               // 节点数和边数
// Bellman-Ford：求解从虚拟节点0到所有节点的最短路
bool bellman_ford() {
    fill(h, h + n + 1, 0); // 初始化势能数组为0
    for (int i = 1; i <= n; ++i) { // 迭代n次
        bool flag = false;
        for (int u = 1; u <= n; ++u) {
            for (auto &e : adj[u]) {
                int v = e.v, w = e.w;
                if (h[v] > h[u] + w) {
                    h[v] = h[u] + w;
                    flag = true;
                }
            }
        }
        if (!flag) break; // 如果没有更新, 提前结束
    }
    return true; // 存在负环时返回false
}
// Dijkstra算法：使用优先队列计算单源最短路
void dijkstra(int s, vector<long long> &dist) {
    fill(dist.begin(), dist.end(), INF);
    dist[s] = 0;
    priority_queue<pair<long long, int>, vector<pair<long long, int>>, greater<>> pq;
    pq.push({0, s});
    while (!pq.empty()) {
        auto [d, u] = pq.top(); pq.pop();
        if (d > dist[u]) continue;
        for (auto &e : adj[u]) {
            int v = e.v, w = e.w;
            if (dist[v] > dist[u] + w) {
                dist[v] = dist[u] + w;
                pq.push({dist[v], v});
            }
        }
    }
}
// Johnson算法主函数
void johnson() {
    // Step 1: 添加虚拟节点0, 并连接到所有节点, 边权为0
    for (int i = 1; i <= n; ++i) adj[0].push_back({i, 0});

    // Step 2: 使用Bellman-Ford计算势能数组h[]
    if (!bellman_ford()) {
        cout << "Negative cycle detected!\n";
        return;
    }

    // Step 3: 重新标记边权
    for (int u = 1; u <= n; ++u) {
        for (auto &e : adj[u]) {
            e.w += h[u] - h[e.v];
        }
    }

    // Step 4: 对每个节点运行Dijkstra算法
    for (int s = 1; s <= n; ++s) {
        vector<long long> dist(n + 1, INF);
        dijkstra(s, dist);

        // 输出从节点s到其他节点的最短路径
        cout << "Shortest paths from node " << s << ":\n";
        for (int t = 1; t <= n; ++t) {
            if (dist[t] == INF) {
                cout << "Node " << t << ": Unreachable\n";
            } else {
                cout << "Node " << t << ": " << dist[t] + h[t] - h[s] << "\n";
            }
        }
    }
}
int main() {
    cin >> n >> m;
    for (int i = 0; i < m; ++i) {
        int u, v, w;
        cin >> u >> v >> w;
        adj[u].push_back({v, w});
    }
    johnson();
    return 0;
}
```

==== 输出方案

- 开一个 `pre` 数组, 在更新距离的时候记录下来后面的点是如何转移过去的, 算法结束前再递归地输出路径即可. 
  - 比如 Floyd 就要记录 `pre[i][j] = k;`, Bellman-Ford 和 Dijkstra 一般记录 `pre[v] = u`. 

==== 一些特殊情形

- 边权只由 0 和 1 组成的图上最短路：[0-1 BFS]
- 允许至多 $k$ 次改变路径成本等操作的最短路问题：[分层图最短路]. 

#table(
  columns: (auto, auto, auto, auto, auto),
  inset: 5pt,
  align: horizon,
  [*最短路算法*], [*Floyd*], [*Bellman-Ford*], [*Dijkstra*], [*Johnson*],
  [最短路类型], [每对结点之间的最短路], [单源最短路], [单源最短路], [每对结点之间的最短路],
  [作用于], [任意图], [任意图], [非负权图], [任意图],
  [能否检测负环？], [能], [能], [不能], [能],
  [时间复杂度], [$O(N^3)$], [$O(N M)$], [$O(M log M)$], [$O(N M log M)$],
)

=== 差分约束

#note[
    TO DO !! 差分约束
]

==== 定义

- *差分约束系统* 是一种特殊的 $n$ 元一次不等式组, 包含 $n$ 个变量 $x_1, x_2, dots, x_n$ 和 $m$ 个约束条件. 
- 每个约束形如 $x_i - x_j <= c_k$, 其中 $c_k$ 是常数. 

==== 转化

- 约束形式包括：
  1. $x_i - x_j <= c_k$
  2. $x_i - x_j >= c_k$ (转化为 $x_j - x_i <= -c_k$) 
  3. $x_i = x_j$ (转化为 $x_i - x_j <= 0$ 且 $x_j - x_i <= 0$) 
- 构建图：每个变量 $x_i$ 对应一个节点, 每条约束对应一条有向边 $j arrow.r i$, 权重为 $c_k$. 

==== 求解

1. 添加超级源点 0, 并向所有节点连权重为 0 的边. 
2. 使用 Bellman-Ford 或 SPFA 算法求单源最短路. 
3. 若图中存在负环, 则无解；否则, 得到一组解. 

==== 性质

- 如果 ${a_1, a_2, dots, a_n}$ 是解, 则 ${a_1 + d, a_2 + d, dots, a_n + d}$ 也是解 ($d$ 为任意常数) . 

==== 复杂度

- 最坏时间复杂度为 $O(n m)$ (Bellman-Ford/SPFA) . 

```cpp
bool Bellman_Ford() {
  for (int i = 0; i < n; i++) {
    bool jud = false;
    for (int j = 1; j <= n; j++)
      for (int k = h[j]; ~k; k = nxt[k])
        if (dist[j] > dist[p[k]] + w[k])
          dist[j] = dist[p[k]] + w[k], jud = true;
    if (!jud) break;
  }
  for (int i = 1; i <= n; i++)
    for (int j = h[i]; ~j; j = nxt[j])
      if (dist[i] > dist[p[j]] + w[j]) return false;
  return true;
}
```

=== k 短路

#note[见【可持久化可并堆】]

=== 同余最短路

#note[类比 差分约束 方法, 利用同余构造的这些状态可以看作单源最短路中的点. 同余最短路的状态转移通常是这样的 $f(i + y) = f(i) + y$, 类似单源最短路中 $f(v) = f(u) + "edge"(u, v)$. ]

== 生成树问题

=== 最小生成树

==== Kruskal

- $O(m log m)$

#note[该算法的基本思想是从小到大加入边, 是个贪心算法. ]

==== Prim

#note[
    别说 有时候真的有用, 是一种思想 特别是 可以写无堆优化的
]

```cpp
// 使用二叉堆优化的 Prim 算法．
#include <bits/stdc++.h>
using namespace std;
constexpr int N = 5050, M = 2e5 + 10;
struct Edge {
  int to,nxt,w;
}e[M*2];
int n, m, hd[N], cntE;
void add_edge(int u, int v, int w) { 
  e[++cntE] = {to, hd[u], w};
  hd[u] = cntE; 
}
struct Node{
  int u, d;
  bool operator<(const S &o)const { return d > o.d; }
};
int dis[N];
bool vis[N];
int res = 0, cnt = 0;
void Prim() {
  priority_queue<Node> Q;
  memset(dis, 0x3f, sizeof(dis));
  dis[1] = 0;
  Q.push({1, 0});
  while (Q.size()) {
    if (cnt >= n) break;
    auto [u,d]= Q.top();Q.pop();
    if (vis[u]) continue;
    vis[u] = true;
    ++cnt;
    res += d;
    for (int i = hd[u]; i; i = e[i].nxt) {
      int v = e[i].v, w = e[i].w;
      if (w < dis[v]) {
        dis[v] = w;
        Q.push({v, w});
      }
    }
  }
}

int main() {
  cin >> n >> m;
  for (int i = 1, u, v, w; i <= m; ++i) {
    cin >> u >> v >> w;
    add_edge(u, v, w), add_edge(v, u, w);
  }
  Prim();
  if (cnt == n)
    cout << res;
  else
    cout << "No MST.";
  return 0;
}
```

==== Boruvka

#note[
  $O(E log V)$ 

  + 需要并查集 
  + 每层遍历寻找连通块之外的最小代价边进行连接
]

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=2e5+5;
// WC 了 CF 的 unordered 卡的真早!!!
// #define set unordered_set
// #define map unordered_map
/*
    啊啊啊啊啊啊啊 没想到的优化:
    + 修改 Trie, 使其在叶子节点直接存储元素的下标. 
    + 直接遍历 1 到 n, 如果 D.f[i] == i, 则 i 是一个连通分量的根. 
*/
struct DSU{
    vector<int> f,sz;
    vector<vector<int>> S;
    void init(int n){
        f.resize(n);sz.assign(n,1);
        iota(f.begin(),f.end(),0);
        S=vector<vector<int>>(n);
        for(int i=0;i<n;i++)S[i].push_back(i);
    }
    int fd(int x){
        if(f[x]!=x)f[x]=fd(f[x]);
        return f[x];
    }
    bool same(int x,int y){
        return fd(x)==fd(y);
    }
    void merge(int x,int y){
        x=fd(x),y=fd(y);
        if(x==y)return;
        if(sz[x]<sz[y])swap(x,y);
        f[y]=x;
        sz[x]+=sz[y];
        for(auto v:S[y])S[x].push_back(v);
    }
}D;
struct Trie{
    int ch[N*40][2];
    int pass[N*40];
    int tot=0;
    void init(){
        memset(ch,0,sizeof(ch[0])*(tot+1));
        tot=0;
    }
    void insert(int x){
        int cur=0;
        for(int i=30;i>=0;i--){
            int to=x>>i&1;
            if(!ch[cur][to])ch[cur][to]=++tot;
            cur=ch[cur][to];
            pass[cur]++;
        }
    }
    void del(int x){
        int cur=0;
        for(int i=30;i>=0;i--){
            int to=x>>i&1;
            cur=ch[cur][to];
            pass[cur]--;
        }
    }
    int get(int x){
        int res=0;
        int cur=0;
        for(int i=30;i>=0;i--){
            int to=x>>i&1;
            if(!pass[ch[cur][to]])to=!to;
            cur=ch[cur][to];
            res|=to<<i;
        }
        return res;
    }
}T;
int n;
int a[N];
map<int,int> A;
LL ans;
void Boruvka(){
    T.init();
    for(int i=1;i<=n;i++)T.insert(a[i]);
    D.init(n+1);
    int cnt=0;
    ans=0;
    while(cnt<n-1){
        set<int> F;
        for(int i=1;i<=n;i++)F.insert(D.fd(i));
        map<int,pair<int,int>> E;
        for(auto f:F){
            auto& S = D.S[f];
            for(auto u:S)T.del(a[u]);
            int mnw = INT_MAX;
            int mnv = 0;
            for(auto u:S){
                int x = T.get(a[u]);
                int w = a[u]^x;
                int v = A[x];
                if(mnw>w){
                    mnw=w;
                    mnv=v;
                }
            }
            E[f]={mnv,mnw};
            for(auto u:S)T.insert(a[u]);
        }
        for(auto& [u,p]:E){
            auto [v,w] = p;
            if(!D.same(u,v)){
                D.merge(u,v);
                ans+=w;
                cnt++;
            }
        }
    }
}
void solve(){
    cin>>n;
    for(int i=1;i<=n;i++)cin>>a[i];
    sort(a+1,a+1+n);
    n=unique(a+1,a+1+n)-a-1;
    for(int i=1;i<=n;i++)A[a[i]]=i;
    Boruvka();
    cout<<ans<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```
==== 最小生成树的唯一性

如果图中所有边的权值都互不相同，那么最小生成树是唯一的。即使有相同权值的边，MST 也可能唯一。

#note[
  *判定 MST 是否唯一的方法：*
  在使用 Kruskal 算法求解时：
  + 将所有边按权值排序。
  + 对于权值相同的“一组”边，先计算其中有多少条边连接了当前 *尚未连通* 的两个连通块（记为 $"cnt"_"possible"$）。
  + 执行并查集操作，统计这一组边中实际上有多少条被 *加入* 了 MST（记为 $"cnt"_"real"$）。
  + 若 $"cnt"_"possible" > "cnt"_"real"$，说明存在未被选择但同样有效的边，故 MST 不唯一。
]

==== 非严格次小生成树

*定义*：在无向图中，边权和最小的满足边权和 $>=$ 最小生成树边权和的生成树。

*求解思路*：
+ 求出 MST $T$，其权值和为 $W$。
+ 遍历每一条 *非树边* $(u, v)$，设其权值为 $w$。
+ 在 MST 上找到 $u$ 到 $v$ 的路径，查询路径上权值 *最大* 的边 $"val"_"max"$。
+ 尝试用 $(u, v)$ 替换这条最大边，新生成树权值为 $W - "val"_"max" + w$。
+ 所有非树边计算出的结果中取最小值。

#note[
  *实现细节：*
  使用倍增法 (LCA) 维护树上路径最大值。
  预处理 $f[u][i]$ 表示 $u$ 向上跳 $2^i$ 步的节点；
  同时维护 $g[u][i]$ 表示对应路径上的最大边权。
  时间复杂度 $O(m log n)$。
]

==== 严格次小生成树

*定义*：在无向图中，边权和最小的满足边权和 $>$ 最小生成树边权和的生成树。

*求解思路*：
与非严格次小生成树类似，但必须保证替换后的权值严格增加。
对于非树边 $(u, v)$，权值为 $w$：
+ 找到 MST 上 $u, v$ 路径的最大边权 $"val"_"max"$ 和 *严格次大边权* $"val"_"second"$。
+ 若 $w > "val"_"max"$，则候选项为 $W - "val"_"max" + w$。
+ 若 $w = "val"_"max"$，此时替换最大边无法使总权值增加，必须替换路径上的 *严格次大边*，候选项为 $W - "val"_"second" + w$。

#note[
  *倍增维护两个值：*
  + $g[u][i]$ 记录最大值。
  + $h[u][i]$ 记录严格次大值。
  + 在倍增“向上跳”合并两条路径信息时，需要从“左段最大”、“左段次大”、“右段最大”、“右段次大”这四个值中选出总的最大和严格次大。
]

==== 瓶颈生成树

*定义*：无向图 $G$ 的所有生成树中，*最大边权最小* 的生成树。

*性质*：
- *最小生成树 (MST)* 一定是瓶颈生成树（充分不必要条件）。
- 瓶颈生成树不一定是 MST。

#note[
  *求解方法：*
  + *方法一*：直接跑 Kruskal 算法，MST 即为瓶颈生成树。
  + *方法二*：二分答案 $x$，只保留图中权值 $ <= x$ 的边，使用 BFS/DFS 或并查集判断图是否连通。复杂度 $O(m log W)$。
]

==== 最小瓶颈路

*定义*：$x$ 到 $y$ 的所有简单路径中，这条路径上的 *最大边权最小* 的路径。

*性质*：
最小生成树上 $x$ 到 $y$ 的路径就是 $x$ 到 $y$ 的最小瓶颈路。

#note[
  *查询方法：*
  + *MST + 倍增*：构建 MST，利用倍增数组查询 $x, y$ 路径上的最大边权。
  + *Kruskal 重构树*：
    - 在 Kruskal 过程中，每次合并两个连通块（根为 $u, v$）时，新建一个点 $p$（点权为当前边权）。
    - 将 $u, v$ 设为 $p$ 的左右儿子，将 $p$ 设为新根。
    - 最终构成一棵二叉树（叶子为原图节点，非叶子节点点权单调递增）。
    - 原图 $x, y$ 的最小瓶颈路最大边权 $=$ 重构树上 $"LCA"(x, y)$ 的点权。
]

==== Kruskal 重构树

- *定义*
  - 在跑 Kruskal 的过程中我们会从小到大加入若干条边. 现在我们仍然按照这个顺序. 
  - 首先新建 $n$ 个集合, 每个集合恰有一个节点, 点权为 0. 
  - 每一次加边会合并两个集合, 我们可以新建一个点, 点权为加入边的边权, 同时将两个集合的根节点分别设为新建点的左儿子和右儿子. 然后我们将两个集合和新建点合并成一个集合. 将新建点设为根. 
  - 不难发现, 在进行 $n-1$ 轮之后我们得到了一棵恰有 $n$ 个叶子的二叉树, 同时每个非叶子节点恰好有两个儿子. 这棵树就叫 Kruskal 重构树. 

- *性质*
  - 不难发现, 原图中两个点之间的所有简单路径上最大边权的最小值 = 最小生成树上两个点之间的简单路径上的最大值 = Kruskal 重构树上两点之间的 LCA 的权值. 
  - 也就是说, 到点 $x$ 的简单路径上最大边权的最小值 $<= "val"$ 的所有点 $y$ 均在 Kruskal 重构树上的某一棵子树内, 且恰好为该子树的所有叶子节点. 
  - 我们在 Kruskal 重构树上找到 $x$ 到根的路径上权值 $<= "val"$ 的最浅的节点. 显然这就是所有满足条件的节点所在的子树的根节点. 
  - 如果需要求原图中两个点之间的所有简单路径上最小边权的最大值, 则在跑 Kruskal 的过程中按边权大到小的顺序加边. 

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=2e5+5,M=4e5+5;
vector<pair<int,int>> e[N];
vector<int> E[N*2];
int n,n2;
array<int,4> uvla[M];
int dist[N*2],f[N*2],st[N*2][__lg(N*2)+2],P,w[N*2];
void init(){
    for(int i=1;i<=n;i++)e[i].clear();/// !!!
    for(int i=1;i<=n2;i++)E[i].clear();/// !!!
    iota(f,f+1+n,0);
    n2=n;
    P=__lg(n*2);// 
}
int fd(int x){
    return f[x]==x?x:(f[x]=fd(f[x]));
}
void dijk(){
    priority_queue<pair<int,int>> Q;
    vector<int> vis(n+1);
    fill(dist,dist+1+n,INT_MAX);
    Q.push({-0,1});dist[1]=0;
    while(Q.size()){
        int u=Q.top().second;// 
        Q.pop();
        if(vis[u])continue;
        vis[u]=true;
        for(auto [v,w]:e[u]){
            if(dist[v]>dist[u]+w){
                dist[v]=dist[u]+w;
                Q.push({-dist[v],v});
            }
        }
    }
}
void dfs(int u){
    if(u>n)dist[u]=INT_MAX;
    for(int p=1;p<=P;p++)
        st[u][p]=st[st[u][p-1]][p-1];
    for(auto v:E[u]){// 不必 v!=f
        st[v][0]=u;
        dfs(v);
        dist[u]=min(dist[u],dist[v]);
    }
}
int calc(int a,int lim){
    for(int p=P;p>=0;p--)
        if(st[a][p]&&w[st[a][p]]>lim)a=st[a][p];
    return dist[a];
}
void solve(){
    int m;cin>>n>>m;
    init();
    for(int i=1;i<=m;i++){
        auto& [u,v,l,a] = uvla[i];
        cin>>u>>v>>l>>a;
        e[u].push_back({v,l});
        e[v].push_back({u,l});
    }
    sort(uvla+1,uvla+1+m,[](const auto& a,const auto& b){return a[3]>b[3];});
    for(int i=1;i<=m;i++){
        auto [x,y,_,z] = uvla[i];
        x=fd(x);y=fd(y);
        if(x==y)continue;
        f[x]=f[y]=++n2;
        f[n2]=n2;// 
        w[n2]=z;
        E[n2].push_back(x);
        E[n2].push_back(y);
    }
    dijk();
    dfs(n2);
    int lst=0,Q,K,S,v,p;cin>>Q>>K>>S;
    while(Q--){
        cin>>v>>p;
        v=(v+K*lst-1)%n+1;
        p=(p+K*lst)%(S+1);
        cout<<(lst=calc(v,p))<<"\n";
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    int T=1;cin>>T;while(T--)solve();
}
```

=== 最小树形图

#note[
    有向图那种

    $O((n+m)log m)$ 优化朱刘
]

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=1e2+5,M=1e4+5;
const LL INF=1e9+7;
struct Edge{
    int from,to,nxt;
    LL w;
}e[M*2];
int n,m,root,n2;
int hd[N*2],cntE;
void add_edge(int u,int v,LL w){
    e[++cntE]={u,v,hd[u],w};hd[u]=cntE;
}
struct LeftistTree{
    int lc,rc,d;
    int id;LL w,tag;
    bool operator<(const LeftistTree&o)const{return w>o.w;}
}tr[N*2+M*2];
int tot,rt[N*2];
int new_node(int id,LL w){
    ++tot;
    tr[tot].lc=tr[tot].rc=0;
    tr[tot].d=0;
    tr[tot].id=id;
    tr[tot].w=w;
    tr[tot].tag=0;
    return tot;
}
void lazy(int i,LL t){
    if(!i)return;
    tr[i].w+=t;
    tr[i].tag+=t;
}
void down(int i){
    lazy(tr[i].lc,tr[i].tag);
    lazy(tr[i].rc,tr[i].tag);
    tr[i].tag=0;
}
int merge(int x,int y){
    if(!x||!y)return x|y;
    down(x),down(y);
    if(tr[x]<tr[y])swap(x,y);
    tr[x].rc=merge(tr[x].rc,y);
    if(tr[tr[x].lc].d<tr[tr[x].rc].d)swap(tr[x].lc,tr[x].rc);
    tr[x].d=tr[tr[x].rc].d+1;
    return x;
}
int pop(int i){
    down(i);
    return merge(tr[i].lc,tr[i].rc);
}
int f[N*2];
int fd(int x){return f[x]==x?x:f[x]=fd(f[x]);}
void init(){
    fill(hd,hd+1+n*2,0);
    iota(f,f+1+n*2,0);
    cntE=1;
}
int stk[N*2],tp;
bool ins[N*2];
void solve(){
    cin>>n>>m>>root;
    init();n2=n;
    LL w,ans=0;
    for(int u,v,i=1;i<=m;i++){
        cin>>u>>v>>w;
        add_edge(u,v,w);
        rt[v]=merge(rt[v],new_node(cntE,w));  
    }
    for(int u,v,i=1;i<=n;i++){
        u=i,v=i%n+1;
        add_edge(u,v,INF);
        rt[v]=merge(rt[v],new_node(cntE,INF));
    }
    // 我认为 栈中均为 团
    stk[++tp]=root;ins[root]=true;
    while(rt[stk[tp]]){
        int v=stk[tp];
        int u=fd(e[tr[rt[v]].id].from);
        if(u==v){
            rt[v]=pop(rt[v]);
        }else if(!ins[u]){
            stk[++tp]=u;
            ins[u]=true;
        }else {
            int p=++n2;
            while(ins[u]){
                v=stk[tp--];
                ins[v]=false;
                f[v]=p;
                LL t=tr[rt[v]].w;
                if(fd(root)!=fd(e[tr[rt[v]].id].to))ans+=t;
                rt[v]=pop(rt[v]);
                lazy(rt[v],-t);
                rt[p]=merge(rt[p],rt[v]);
            }
            stk[++tp]=p;
            ins[p]=true;
        }
    }
    cout<<(ans>=INF?-1:ans)<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```



=== 最小直径生成树

==== 绝对中心

#note[
    我觉得这么理解，既然中心点存在于边上，那么一定存在某一点 答案按被 u 主导的点，那么枚举 u 一侧的直径端点，其余的点，用来更新 v 侧的半径长度，既然 u 侧主导的半径已经确定，那么 v 侧的点必然要求到 u 的距离比选定的 u 端直径端点的距离远，否则就不满足 u 侧直径端点的前提，那么只需要在 j=i+1 到 n 中选择距离 v 最远的点即可，它们一定不会更新 u 端端点的答案。
]

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=2e2+5,M=N*N/2;
const int inf=1e9+7;
int n,m;
int g[N][N];
int val[N],rk[N][N];
array<int,3> edge[M];/// 
int MDST(){
    int ans=inf;
    // Floyd
    for(int c=1;c<=n;c++)
        for(int i=1;i<=n;i++)
            for(int j=1;j<=n;j++)
                g[i][j]=min(g[i][j],g[i][c]+g[c][j]);
    for(int i=1;i<=n;i++){
        for(int j=1;j<=n;j++){
            rk[i][j]=j;
            val[j]=g[i][j];
        }
        // 这就是谁的 val 小哪个编号就排前面
        sort(rk[i]+1,rk[i]+1+n,[&](int a,int b){return val[a]<val[b];});
    }
    for(int i=1;i<=n;i++)ans=min(ans,g[i][rk[i][n]]*2);
    for(int i=1;i<=m;i++){
        auto [u,v,w]=edge[i];
        // int mx=g[v][rk[u][n]];
        for(int p=n,j=n-1;j>=1;j--){
            // 建议只在 g[v][rk[u][j]] 增大时取 ans
            // ans=min(ans,g[u][rk[u][j]]+mx+w); // ??? 为什么这个错了??
            // mx=max(mx,g[v][rk[u][j]]);// ??? 为什么这个错了??
            // 否则答案过小???
            if(g[v][rk[u][j]]>g[v][rk[u][p]]){
                ans=min(ans,g[u][rk[u][j]]+g[v][rk[u][p]]+w);
                p=j;
            }
        }
    }
    return ans;
}
void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++){
        for(int j=1;j<=n;j++)
            g[i][j]=inf;
        g[i][i]=0;// n=1 
    }
    for(int u,v,w,i=1;i<=m;i++){
        cin>>u>>v>>w;
        edge[i]={u,v,w};
        g[u][v]=g[v][u]=w;
    }
    cout<<MDST()/2.0<<"\n";    
}   
int main(){
    cout<<setprecision(2)<<fixed;
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

==== 正文

#note[抄]

```cpp
#include <bits/stdc++.h>
using namespace std;
constexpr int MAXN = 502;
using ll = long long;
using pii = pair<int, int>;
ll d[MAXN][MAXN], dd[MAXN][MAXN], rk[MAXN][MAXN], val[MAXN];
constexpr ll INF = 1e17;
int n, m;
bool cmp(int a, int b) { return val[a] < val[b]; }
void floyd() {
  for (int k = 1; k <= n; k++)
    for (int i = 1; i <= n; i++)
      for (int j = 1; j <= n; j++) d[i][j] = min(d[i][j], d[i][k] + d[k][j]);
}
struct node {
  ll u, v, w;
} a[MAXN * (MAXN - 1) / 2];
void solve() {
  // 求图的绝对中心
  floyd();
  for (int i = 1; i <= n; i++) {
    for (int j = 1; j <= n; j++) {
      rk[i][j] = j;
      val[j] = d[i][j];
    }
    sort(rk[i] + 1, rk[i] + 1 + n, cmp);
  }
  ll P = 0, ansP = INF;
  // 在点上
  for (int i = 1; i <= n; i++) {
    if (d[i][rk[i][n]] * 2 < ansP) {
      ansP = d[i][rk[i][n]] * 2;
      P = i;
    }
  }
  // 在边上
  int f1 = 0, f2 = 0;
  ll disu = INT_MIN, disv = INT_MIN, ansL = INF;
  for (int i = 1; i <= m; i++) {
    ll u = a[i].u, v = a[i].v, w = a[i].w;
    for (int p = n, i = n - 1; i >= 1; i--) {
      if (d[v][rk[u][i]] > d[v][rk[u][p]]) {
        if (d[u][rk[u][i]] + d[v][rk[u][p]] + w < ansL) {
          ansL = d[u][rk[u][i]] + d[v][rk[u][p]] + w;
          f1 = u, f2 = v;
          disu = (d[u][rk[u][i]] + d[v][rk[u][p]] + w) / 2 - d[u][rk[u][i]];
          disv = w - disu;
        }
        p = i;
      }
    }
  }
  cout << min(ansP, ansL) / 2 << '\n';
  // 最小路径生成树
  vector<pii> pp;
  for (int i = 1; i <= 501; ++i)
    for (int j = 1; j <= 501; ++j) dd[i][j] = INF;
  for (int i = 1; i <= 501; ++i) dd[i][i] = 0;
  if (ansP <= ansL) {
    for (int j = 1; j <= n; j++) {
      for (int i = 1; i <= m; ++i) {
        ll u = a[i].u, v = a[i].v, w = a[i].w;
        if (dd[P][u] + w == d[P][v] && dd[P][u] + w < dd[P][v]) {
          dd[P][v] = dd[P][u] + w;
          pp.push_back({u, v});
        }
        u = a[i].v, v = a[i].u, w = a[i].w;
        if (dd[P][u] + w == d[P][v] && dd[P][u] + w < dd[P][v]) {
          dd[P][v] = dd[P][u] + w;
          pp.push_back({u, v});
        }
      }
    }
    for (auto [x, y] : pp) cout << x << ' ' << y << '\n';
  } else {
    d[n + 1][f1] = disu;
    d[f1][n + 1] = disu;
    d[n + 1][f2] = disv;
    d[f2][n + 1] = disv;
    a[m + 1].u = n + 1, a[m + 1].v = f1, a[m + 1].w = disu;
    a[m + 2].u = n + 1, a[m + 2].v = f2, a[m + 2].w = disv;
    n += 1;
    m += 2;
    floyd();
    P = n;
    for (int j = 1; j <= n; j++) {
      for (int i = 1; i <= m; ++i) {
        ll u = a[i].u, v = a[i].v, w = a[i].w;
        if (dd[P][u] + w == d[P][v] && dd[P][u] + w < dd[P][v]) {
          dd[P][v] = dd[P][u] + w;
          pp.push_back({u, v});
        }
        u = a[i].v, v = a[i].u, w = a[i].w;
        if (dd[P][u] + w == d[P][v] && dd[P][u] + w < dd[P][v]) {
          dd[P][v] = dd[P][u] + w;
          pp.push_back({u, v});
        }
      }
    }
    cout << f1 << ' ' << f2 << '\n';
    for (auto [x, y] : pp)
      if (x != n && y != n) cout << x << ' ' << y << '\n';
  }
}
void init() {
  for (int i = 1; i <= 501; ++i)
    for (int j = 1; j <= 501; ++j) d[i][j] = INF;
  for (int i = 1; i <= 501; ++i) d[i][i] = 0;
}
int main() {
  init();
  cin >> n >> m;
  for (int i = 1; i <= m; ++i) {
    ll u, v, w;
    cin >> u >> v >> w;
    w *= 2;
    d[u][v] = w, d[v][u] = w;
    a[i].u = u, a[i].v = v, a[i].w = w;
  }
  solve();
  return 0;
}
```

== 斯坦纳树

#note[
    无向图中 选择少量的 $k$ 个点使其连通的最小代价

    $O(n 3^k + m log m 2^k)$
]

```cpp
#include <bits/stdc++.h>
using namespace std;
const int N = 505;       // 最大节点数
const int INF = 1e9;     // 无穷大，不要设太大防止相加溢出
int n, m, k;
int p[15];               // 存储 k 个重点城市的编号
vector<pair<int, int>> g[N]; // 邻接表建图 {v, weight}
int dp[N][1 << 10];      // 核心DP数组：dp[点i][连通状态mask]
bool vis[N];             // Dijkstra 用的访问标记
priority_queue<pair<int, int>, vector<pair<int, int>>, greater<>> pq; // 小根堆
void steiner_tree() {
    // 1. 初始化 DP 数组为无穷大
    for (int i = 1; i <= n; i++) {
        for (int mask = 0; mask < (1 << k); mask++) {
            dp[i][mask] = INF;
        }
    }
    // 2. 初始化关键点（重点城市）
    // 自己连通自己，花费为 0。1<<i 表示第 i 个重点城市的独立状态。
    for (int i = 0; i < k; i++) {
        dp[p[i]][1 << i] = 0;
    }
    // 3. 按状态从小到大枚举（相当于先拼小积木，再拼大积木）
    for (int mask = 1; mask < (1 << k); mask++) {
        // 【操作一：合并 (Merge) - 原地拼接】
        for (int i = 1; i <= n; i++) {
            // 黑科技：枚举 mask 的所有二进制子集 (submask)
            // 比如 mask 是 101，submask 就会枚举 100 和 001
            for (int sub = (mask - 1) & mask; sub; sub = (sub - 1) & mask) {
                // 在点 i 把两个子集接在一起
                dp[i][mask] = min(dp[i][mask], dp[i][sub] + dp[i][mask ^ sub]);
            }
        }
        // 【操作二：延伸 (Extend) - 跑 Dijkstra 找最佳中转站】
        // 把当前状态 mask 下，所有已经算出来有效值的点塞入优先队列
        for (int i = 1; i <= n; i++) {
            if (dp[i][mask] != INF) {
                pq.push({dp[i][mask], i});
            }
            vis[i] = false; // 清空标记
        }
        // 标准的 Dijkstra 过程，拿着 mask 状态去跑全图
        while (!pq.empty()) {
            auto [dist, u] = pq.top();
            pq.pop();
            if (vis[u]) continue;
            vis[u] = true;
            // 尝试把点 u 的 mask 状态“拉线”到邻居 v
            for (auto& edge : g[u]) {
                int v = edge.first;
                int w = edge.second;
                if (dp[v][mask] > dp[u][mask] + w) {
                    dp[v][mask] = dp[u][mask] + w;
                    pq.push({dp[v][mask], v});
                }
            }
        }
    }
}
int main() {
    ios::sync_with_stdio(false); cin.tie(nullptr);
    // 读入点数、边数、重点城市数
    cin >> n >> m >> k;
    // 读入图
    for (int i = 1; i <= m; i++) {
        int u, v, w;
        cin >> u >> v >> w;
        g[u].push_back({v, w});
        g[v].push_back({u, w}); // 无向图
    }
    // 读入重点城市的编号 (0-indexed)
    for (int i = 0; i < k; i++) cin >> p[i];
    // 跑算法
    steiner_tree();
    // 答案是什么？
    // 答案是：在任意一个重点城市，连通了所有 k 个重点城市（状态为 (1<<k)-1 ）的最小花费。
    // 因为这棵树连通了所有重点城市，所以树上肯定包含 p[0]，我们直接查 p[0] 即可。
    cout << dp[p[0]][(1 << k) - 1] << "\n";
    return 0;
}
```

== 拆点

#note[
    TO DO !! 其实见过的很多

    + 虚点 
    + 分层图
    + 超级源点
]

== 连通性相关

=== 强连通分量 (Tarjan 算法)

#note[感觉到自己对于 环检测的 无力感]

- $O(n+m)$

```cpp
const int N=1e4+5;
vector<int> e[N];
int dfn[N],low[N],dfncnt,scc[N],sc,stk[N],tp,sz[N];
bool ins[N];
void tarjan(int u){
    low[u]=dfn[u]=++dfncnt;ins[stk[++tp]=u]=true;
    for(auto v:e[u]){
        if(!dfn[v]){
            tarjan(v);
            low[u]=min(low[u],low[v]);
        }else if(ins[v])
            low[u]=min(low[u],dfn[v]);
    }
    if(low[u]==dfn[u]){
        ++sc;
        do{
            scc[stk[tp]]=sc;
            ins[stk[tp]]=false;
            sz[sc]++;
        }while(stk[tp--]!=u);
    }
}
void solve(){
    int n,m,u,v;cin>>n>>m;
    for(int i=1;i<=m;i++){
        cin>>u>>v;
        e[u].push_back(v);
    }
    for(int i=1;i<=n;i++)if(!dfn[i])tarjan(i);
    int ans=0;
    for(int i=1;i<=sc;i++)ans+=sz[i]>1;
    cout<<ans<<"\n";
}
```


#note[Kosaraju 算法 / Garbow 算法 略]

=== 边双连通分量 (Tarjan1 算法)

```cpp
const int N = 5e3+5,M=1e4+5;
struct Edge{
    int to,nxt;
}e[M*2];
int hd[N],cntE;
void init(int n){
    fill(hd,hd+1+n,0);
    cntE=1;
}
void add_edge(int u,int v){
    e[++cntE]={v,hd[u]};hd[u]=cntE;// 最新研究表明
    e[++cntE]={u,hd[v]};hd[v]=cntE;// 加一条边至少两句代码
}
vector<int> E[N];
int dfn[N],low[N],dfncnt,stk[N],tp,dcc[N],dc,sz[N];
bool bri[M*2];
void tarjan(int u,int fi){
    low[u]=dfn[u]=++dfncnt;stk[++tp]=u;
    for(int i=hd[u],v;i;i=e[i].nxt){
        v=e[i].to;
        if(!dfn[v]){
            tarjan(v,i);
            low[u]=min(low[u],low[v]);
            if(low[v]>dfn[u])
                bri[i]=bri[i^1]=true;
        }else if(i!=(fi^1))
            low[u]=min(low[u],dfn[v]);
    }
    if(low[u]==dfn[u]){
        dc++;
        do{
            dcc[stk[tp]]=dc;
            sz[dc]++;
        }while(stk[tp--]!=u);
    }
}
void build(){
    for(int i=2;i<=cntE;i+=2){
        if(bri[i]){
            int u=dcc[e[i].to],v=dcc[e[i^1].to];
            E[u].push_back(v);
            E[v].push_back(u);
        }
    }
}
void solve(){
    int n,m,u,v;cin>>n>>m;
    init(n);
    for(int i=1;i<=m;i++){
        cin>>u>>v;
        add_edge(u,v);
    }
    tarjan(1,0);
    build();
    int cnt=0;
    for(int i=1;i<=dc;i++)cnt+=E[i].size()==1;
    cout<<(cnt+1)/2<<"\n";
}
```

#note[Tarjan2 / 差分算法 略]

=== 点双连通分量 (Tarjan 算法)

```cpp
const int N=(5e5+5);// 特别注意: 这里的 dcc 空间 必须开二倍 因为 id[i] 可能 达到 2n 级别 !!!!!!
vector<int> e[N],E[N];
vector<int> dcc[N];
int n;
int dfn[N],low[N],dfncnt,stk[N],tp,root,dc,id[N],num;
bool cut[N];
void tarjan(int u){
    low[u]=dfn[u]=++dfncnt;stk[++tp]=u;
    if(e[u].empty()){
        // 孤立点的的栈空间不会被访问
        dcc[++dc].push_back(u);
        return;
    }
    int child=0;
    for(int v:e[u]){
        if(!dfn[v]){
            tarjan(v);
            low[u]=min(low[u],low[v]);
            if(low[v]>=dfn[u]){
                child++;
                if(u!=root||child>1)
                    cut[u]=true;
                dc++;
                do{
                    dcc[dc].push_back(stk[tp]);
                }while(stk[tp--]!=v);
                dcc[dc].push_back(u);
            }
        }else low[u]=min(low[u],dfn[v]);// !!!
    }
}
void build(){// 听说这玩意叫圆方树
    num=dc;
    for(int i=1;i<=n;i++)
        if(cut[i])id[i]=++num;
    assert(num<N);// error 
    for(int i=1;i<=dc;i++){
        for(int u:dcc[i]){
            if(cut[u]){
                E[i].push_back(id[u]);
                E[id[u]].push_back(i);
            }
        }
    }
}
void solve(){
    int m,u,v;cin>>n>>m;
    for(int i=1;i<=m;i++){
        cin>>u>>v;if(u==v)continue;
        e[u].push_back(v);
        e[v].push_back(u);
    }
    for(int i=1;i<=n;i++)if(!dfn[i])tarjan(root=i);// root!!!
    cout<<dc<<"\n";
    build();
    for(int i=1;i<=dc;i++){
        if(dcc[i].size()){
            cout<<dcc[i].size()<<" ";
            for(int u:dcc[i])cout<<u<<" ";cout<<"\n";
        }
    }
}
```

#note[差分算法 略]

=== 割点 & 割边

==== 割点 / 割顶

#note[
    一个 *无向图*, 如果把一个点删除了, 连通块的个数增加, 这个点就是 *割点\/割顶*

    判定法则:
    + $x$ 不是根节点: 当搜索树上存在 $x$ 的一个子节点 $y$ `low[y]>=dfn[x]`
    + $x$ 是根节点: 当搜索树上存在至少两个子节点 满足上述条件
]

```cpp
const int N=2e4+5;
vector<int> e[N];
int dfn[N],low[N],dfncnt,root;
bool cut[N];
void tarjan(int u){
    low[u]=dfn[u]=++dfncnt;
    int child=0;
    for(int v:e[u]){
        if(!dfn[v]){
            tarjan(v);
            low[u]=min(low[u],low[v]);
            if(low[v]>=dfn[u]){
                child++;
                if(u!=root||child>1)
                    cut[u]=true;
            }
        }else low[u]=min(low[u],dfn[v]);// 无 ins
    }
}
void solve(){
    int n,m,u,v;cin>>n>>m;
    for(int i=1;i<=m;i++){
        cin>>u>>v;
        e[u].push_back(v);
        e[v].push_back(u);
    }
    // 666 多个 root
    for(int i=1;i<=n;i++)if(!dfn[i])tarjan(root=i);
    vector<int> ans;
    for(int i=1;i<=n;i++)if(cut[i])ans.push_back(i);
    cout<<ans.size()<<'\n';
    for(auto i:ans)cout<<i<<" ";
    cout<<"\n";
}
```

==== 割边 / 桥

#note[
    一个 *无向图*, 如果把一个边删除了, 连通块的个数增加, 这个点就是 *割边\/桥*

    判定法则:\
    搜索树上存在 $x$ 的一个子节点 $y$ `low[y]>dfn[x]`
]

```cpp
const int N=2e5+5,M=2e6+5;
struct Edge{
    int to,nxt;
}e[M*2];
int hd[N],cntE;
void init(int n){
    fill(hd,hd+1+n,0);
    cntE=1;
}
void add_edge(int u,int v){
    e[++cntE]={v,hd[u]};hd[u]=cntE;
    e[++cntE]={u,hd[v]};hd[v]=cntE;
}
int dfn[N],low[N],dfncnt;
vector<pair<int,int>> ans;
void tarjan(int u,int fi){
    low[u]=dfn[u]=++dfncnt;
    for(int i=hd[u],v;i;i=e[i].nxt){
        v=e[i].to;
        if(!dfn[v]){
            tarjan(v,i);
            low[u]=min(low[u],low[v]);
            if(low[v]>dfn[u]){
                if(u<v)ans.push_back({u,v});
                else ans.push_back({v,u});
            }
        }else if(i!=(fi^1))
            low[u]=min(low[u],dfn[v]);
    }
}
void solve(){
    int n,m,u,v;cin>>n>>m;
    init(n);
    for(int i=1;i<=m;i++){
        cin>>u>>v;
        add_edge(u,v);
    }
    for(int i=1;i<=n;i++)if(!dfn[i])tarjan(i);
    sort(ans.begin(),ans.end());
    for(auto [u,v]:ans)cout<<u<<" "<<v<<"\n";
}
```

=== 圆方树

#note[
    降维了 化图为树

    可以用于 *仙人掌图* 转化为树 求任意两点之间的最短路 
]


```cpp
// 确实啊 N2 是 1.5 倍的
// 有重边的情况下 虽然无意义 但是要开 2倍
const int N=1e4+5,N2=N*3/2,M=2e4+5;
struct Edge{
    int to,nxt;
    int w;
}e[M*2+N2];// 只需要 1 倍 N2 即可 
int n,n2;
int hd[N],hd2[N2],cntE;// kbky
void init(){
    fill(hd,hd+1+n,0);
    fill(hd2,hd2+1+n2,0);
    cntE=1;
}
void add_edge(int* hd,int u,int v,int w){
    e[++cntE]={v,hd[u],w};hd[u]=cntE;// 注意这里不是一键无向了 
}
int dfn[N],low[N],dfncnt,fe[N],sum[N],delta[N];
int st[N2][__lg(N2)+2],P,d[N2],dep[N2];
void build_tree(int u,int v,int w){
    // 手残 i 写成 v
    for(int i=v;i!=u;i=e[fe[i]^1].to){
        delta[i]=w;// 这里不取 min
        w+=e[fe[i]].w;
    }
    delta[u]=sum[u]=w;
    add_edge(hd2,u,++n2,0);
    for(int i=v;i!=u;i=e[fe[i]^1].to){
        sum[i]=w;
        // 这里取 min
        add_edge(hd2,n2,i,min(delta[i],w-delta[i]));
    }
}
void tarjan(int u){
    low[u]=dfn[u]=++dfncnt;
    for(int i=hd[u],v,w;i;i=e[i].nxt){
        v=e[i].to;w=e[i].w;
        if(!dfn[v]){
            fe[v]=i;
            tarjan(v);
            low[u]=min(low[u],low[v]);
            if(low[v]>dfn[u])
                add_edge(hd2,u,v,w);
        }else if(i!=(fe[u]^1))
            low[u]=min(low[u],dfn[v]);
    }
    for(int i=hd[u],v;i;i=e[i].nxt){
        v=e[i].to;
        if(dfn[v]>dfn[u]&&fe[v]!=i)
            build_tree(u,v,e[i].w);
    }
}
void dfs(int u){
    for(int p=1;p<=P;p++)
        st[u][p]=st[st[u][p-1]][p-1];
    for(int i=hd2[u],v;i;i=e[i].nxt){
        v=e[i].to;
        st[v][0]=u;// 这里不需要判 fa 因为是有向树
        dep[v]=dep[u]+1;// 注意 dep 与 d 的区别
        d[v]=d[u]+e[i].w;
        dfs(v);
    }
}
int A,B;
int lca(int a,int b){
    bool sw=false;
    if(dep[a]<dep[b])swap(a,b),sw=true;
    for(int p=P;p>=0;p--)
        if(dep[st[a][p]]>=dep[b])
            a=st[a][p];
    if(a==b)return a;// 这里返回的一定是 <=n 不需要计算 A B
    for(int p=P;p>=0;p--)
        if(st[a][p]!=st[b][p])
            a=st[a][p],b=st[b][p];
    A=a,B=b;
    if(sw)swap(A,B);// !!! 注意一致性 !!!
    return st[a][0];
}
int calc(int a,int b){
    int c=lca(a,b);
    if(c<=n){
        return d[a]+d[b]-2*d[c];
    }else {
        int len=abs(delta[A]-delta[B]);
        int AB=min(len,sum[A]-len);
        return AB+d[a]-d[A]+d[b]-d[B];
    }
}
void solve(){
    int m,u,v,w,q,a,b;cin>>n>>m>>q;
    init();
    for(int i=1;i<=m;i++){
        cin>>u>>v>>w;
        add_edge(hd,u,v,w);
        add_edge(hd,v,u,w);
    }
    n2=n;
    tarjan(1);// 建立新树
    P=__lg(n2)+1;dfs(1);// 预处理 lca
    while(q--)cin>>a>>b,cout<<calc(a,b)<<"\n";
}
```

=== 点/边连通度

==== Whitney 不等式

点连通度 $kappa$、边连通度 $lambda$ 和最小度 $delta$ 之间的关系：

$ 𝜅≤𝜆≤𝛿 $

#note[
    唯一用途：在构造题中。比如题目让你“构造一个图，使得它的最小度数是 $A$，但边连通度是 $B$。知道这个不等式能帮你判断无解的情况，或者提供构造思路（如文中所述的“两个团中间连几条边”）。

    这个不等式不能改进；换言之，对每个满足它的三元组，均可以找出满足这个三元组的图．

    把两个大小为 $delta + 1$ 的团用 $lambda$ 条边连起来，使两个团分别有 $lambda$ 和 $kappa$ 个不同的结点被连在这些边上．
]

==== Menger 定理

#note[
    由 最大流最小割定理（又名 Ford–Fulkerson 定理）可推出，两点间的不相交（指两两没有公共边）路径的最大数量等于割集的最小大小（这个推论又叫 Menger 定理——译者注）．
]

#note[以下图的边权均为 $1$]

==== 用最大流计算边连通度

枚举点对 $(s, t)$，以 $s$ 为源点，$t$ 为汇点跑边权为 $1$ 的最大流．

$O(|V|^2 |E| min(|V|^(2/3), |E|^(1/2)))$

==== 全局最小割

使用 Stoer–Wagner 算法 只需跑一次无源汇最小割即可

$O(|V||E| + |V|^2 log|V|) approx O(|V|^3)$

==== 点连通度

仍然枚举点对，这次把每个非源汇的点 $x$ 拆成两个点 $x_1$ 和 $x_2$，并连边 $(x_1, x_2)$．把原图中所有边 $(u, v)$ 换成两条边 $(u_2, v_1)$ 和 $(v_2, u_1)$．此时最大流等于 $s t$ 之间的最小点割集大小（又称局部点连通度）．复杂度与用最大流计算边连通度相同．

== 环计数问题

=== 普通环

#note[
    给定一个无向图, 求简单环的数目 $n<=19$

    状压DP
]

```cpp
// 502
#include<bits/stdc++.h>
using LL = long long;
using namespace std;
const int N=20;
int n,m;
vector<int> e[N];
LL f[N][1<<N],ans;// f[i][s] 表示来到 i 点且起点为s的最小编号点的路径方法数 
void solve(){
    cin>>n>>m;ans=0;
    for(int u,v,i=0;i<m;i++){
        cin>>u>>v;u--,v--;
        e[u].push_back(v);
        e[v].push_back(u);
    }
    for(int i=0;i<n;i++)f[i][1<<i]=1;// 起始点
    for(int s=1;s<(1<<n);s++){// 枚举状态
        for(int i=0;i<n;i++){// 枚举最低点
            if(!f[i][s])continue;// 非法状态
            for(auto j:e[i]){// 枚举下一个点 
                if((s&-s)>(1<<j))continue;// 起始点不能变 坏了规矩 
                if(s>>j&1){// 如果是回路
                    if((s&-s)==(1<<j))ans+=f[i][s];// 必须闭合成完整的环
                }else f[j][s|(1<<j)]+=f[i][s];// 否则依然是链
                // 注意到 转移的 s 递增
            }
        }
    }
    // 去掉二元环(这必然是是向的) 
    cout<<(ans-m)/2<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

=== 三元环

#note[
    无向图的变有向化 

    首先给所有边定向．我们规定从度数小的点指向度数大的点，度数相同就从编号小的点指向编号大的点．那么此时此图是一张有向无环图（DAG）．

    $O(m sqrt(m))$
]

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=1e5+5,M=2e5+5;
int n,m;
vector<int>e[N];
array<int,2> edge[M];
int deg[N];
bool vis[N];
void solve(){
    cin>>n>>m;
    for(int i=1;i<=m;i++){
        auto&[u,v]=edge[i];
        cin>>u>>v;
        deg[u]++;deg[v]++;
    }
    for(int i=1;i<=m;i++){
        auto&[u,v]=edge[i];
        if(deg[u]>deg[v]||deg[u]==deg[v]&&u>v)swap(u,v);
        e[u].push_back(v);
    }
    int ans=0;
    for(int u=1;u<=n;u++){
        for(auto w:e[u])vis[w]=true;
        for(auto v:e[u])
            for(auto w:e[v])
                ans+=vis[w];
        for(auto w:e[u])vis[w]=false;
    }
    cout<<ans<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

=== 四元环 ++

#note[
    我知道了 环编号后必定有一个只有入度的点 其他的边视为无向边

    容斥计算 即可 

    其实不仅仅是环的计数 其他的计数也要掌握 

    只需要枚举 环 \* 附加边(度数-x) 即可 
]

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=1e5+5,M=2e5+5;
int n,m;
vector<int> E[N],e[N];
array<int,2> edge[M];
int deg[N];
int cnt[N];
LL ans;
void solve(){
    cin>>n>>m;ans=0;
    for(int i=1;i<=m;i++){
        auto&[u,v]=edge[i];
        cin>>u>>v;
        E[u].push_back(v);
        E[v].push_back(u);
        deg[u]++,deg[v]++;
    }
    for(int i=1;i<=m;i++){
        auto&[u,v]=edge[i];
        if(deg[u]>deg[v]||deg[u]==deg[v]&&u>v)swap(u,v);
        e[u].push_back(v);
    }
    for(int u=1;u<=n;u++){
        for(auto v:E[u])
            for(auto w:e[v])// ??? <度,编号> 的二维偏序 666
                if(deg[u]<deg[w]||deg[u]==deg[w]&&u<w)
                    ans+=cnt[w]++;
        for(auto v:E[u])
            for(auto w:e[v])
                cnt[w]=0;
    }
    cout<<ans<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

== 最小环

#note[
    这个环是带权的
    
    + Dijkstra 删边法 $O(m (n+m) log n)$ 简单略
    + Floyd $O(n^3)$ 简单
    + SCFA $O(n (n+m) log n)$ ?
]

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=1e2+5;
const int inf=5e8;// 啊 爆了
int n,m;
int g[N][N],dis[N][N];
// 记录路径 专用
int pos[N][N],path[N],tp;
void get_path(int i,int j){
    if(!pos[i][j])return;
    int k=pos[i][j];
    get_path(i,k);
    path[++tp]=k;
    get_path(k,j);
}
int main(){
    cin>>n>>m;
    for(int i=1;i<=n;i++){
        // CAO! dis 和 g 不一样!!!
        for(int j=1;j<=n;j++)g[i][j]=dis[i][j]=inf;
        g[i][i]=0;
    }
    for(int u,v,w,i=1;i<=m;i++){
        cin>>u>>v>>w;
        dis[u][v]=dis[v][u]=g[u][v]=g[v][u]=min(g[u][v],w);// 
    }
    int ans=inf;
    for(int k=1;k<=n;k++){
        for(int i=1;i<k;i++)// [!] i,j < k 
            for(int j=1;j<k;j++){
                if(i!=j&&ans>g[i][k]+g[k][j]+dis[j][i]){
                    ans=g[i][k]+g[k][j]+dis[j][i];tp=0;
                    path[++tp]=i;
                    path[++tp]=k;
                    path[++tp]=j;
                    get_path(j,i);
                }
            }
        for(int i=1;i<=n;i++)
            for(int j=1;j<=n;j++)
                if(dis[i][j]>dis[i][k]+dis[k][j]){
                    dis[i][j]=dis[i][k]+dis[k][j];
                    pos[i][j]=k;
                }
    }
    if(ans==inf)cout<<"No solution.\n";
    else {
        // cout<<ans<<"\n";
        for(int i=1;i<=tp;i++)cout<<path[i]<<" ";cout<<"\n";
    }
}
```

== 2-SAT

#note[
    若干个二元布尔表达式 转化为 拆点 有向图
]

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=1e6+5;
int n,m;
vector<int> e[N*2];
int dfn[N*2],low[N*2],dfncnt;
int sc,scc[N*2],stk[N*2],tp;
bool ins[N*2];
void tarjan(int u){
    low[u]=dfn[u]=++dfncnt;stk[++tp]=u;ins[u]=true;
    for(auto v:e[u]){
        if(!dfn[v]){
            tarjan(v);
            low[u]=min(low[u],low[v]);
        }else if(ins[v]){
            low[u]=min(low[u],dfn[v]);
        }
    }
    if(low[u]==dfn[u]){
        sc++;
        do{
            scc[stk[tp]]=sc;
            ins[stk[tp]]=false;
        }while(stk[tp--]!=u);
    }
}
void solve(){
    cin>>n>>m;
    for(int i=1;i<=m;i++){
        int A,B;bool a,b;
        cin>>A>>a>>B>>b;
        // a or b <=> !a -> b and !b-> a
        // e[a?A+n:A].push_back(b?B:B+n);
        // e[b?B+n:B].push_back(a?A:A+n);
        // 使用 11 22 33 式
        e[2*A-!a].push_back(2*B-b);// 保证 1-2n 序号!!!
        e[2*B-!b].push_back(2*A-a);// 
    }
    for(int i=1;i<=n*2;i++)if(!dfn[i])tarjan(i);
    for(int i=1;i<=n*2;i+=2){
        if(scc[i]==scc[i+1]){
            cout<<"IMPOSSIBLE\n";
            return;
        }
    }
    cout<<"POSSIBLE\n";
    // 答案贪心？ 逆拓扑序优先标记为 1 
    // 因为 tarjan scc 本来就是逆拓扑序 所以编号小的就是 1
    for(int i=1;i<=n*2;i+=2)
        cout<<(scc[i]<scc[i+1])<<" ";
    cout<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

== 欧拉图

#note[
    欧拉图分为 $2 times 2$ 种

    + 欧拉图 / 半欧拉图
    + 无向图 / 有向图

    - 半欧拉图 只能起始/终止于 (无向:奇度/有向:+1-1度)
    - 有向图 不存在反向边 无需 ban 掉
]

```cpp
// 在 有向图/无向图 中 寻找字典序最小的欧拉路
#include<bits/stdc++.h>
#define DIRECTED
using namespace std;
const int N=1e5+5,M=2e5+5;
struct DSU{
    vector<int> f,sz;
    void init(int n){
        f.resize(n);
        iota(f.begin(),f.end(),0);
        sz.assign(n,1);
    }
    int fd(int x){
        if(f[x]!=x)f[x]=fd(f[x]);
        return f[x];
    }
    void merge(int x,int y){
        x=fd(x),y=fd(y);
        if(x==y)return;
        if(sz[x]<sz[y])swap(x,y);
        sz[x]+=sz[y];
        f[y]=x;
    }
}D;
struct Edge{
    int to,nxt,id;
}e[M*2];
bool vis[M*2];
int cntE,hd[N];
int n,m;
vector<pair<int,int>> tmp[N];
int in[N],out[N];
vector<int> path;
void init(){
    memset(hd,0,sizeof(hd[0])*(n+1));
    memset(in,0,sizeof(in[0])*(n+1));
    memset(out,0,sizeof(out[0])*(n+1));
    memset(vis,0,sizeof(vis[0])*(cntE+1));
    for(int i=1;i<=n;i++)tmp[i].clear();
    path.clear();
    cntE=0;
}
void add_edge(int u,int v,int id){
    e[++cntE]={v,hd[u],id};
    hd[u]=cntE;
    // cout<<"add "<<u<<"->"<<v<<" "<<id<<"\n";
}
void dfs(int u){
    // cout<<"vis:"<<u<<"\n";
    for(int& i=hd[u];i;i=e[i].nxt){
        if(vis[e[i].id])continue;
        vis[e[i].id]=true;
        dfs(e[i].to);
    }
    path.push_back(u);
}
int check_u(){
    int cn=0,first=0;
    D.init(n+1);
    for(int u=1;u<=n;u++){
        if(in[u]){
            // WC 忘了奇度了
            if(!first||in[first]%2==0&&in[u]&1)first=u;
            cn++;
            for(auto [v,id]:tmp[u])D.merge(u,v);
        }
    }
    if(D.sz[D.fd(first)]!=cn)return 0;
    if(!first)return -1;
    return first;// -1 表示全部都是点集
}
int check_d(){
    int cn=0,x=0,first=0;
    D.init(n+1);
    for(int u=1;u<=n;u++){
        if(in[u]||out[u]){
            if(!first)first=u;
            cn++;
            int d = in[u]-out[u];
            if(d==-1){
                if(x)return 0;
                x=u;
            }else if(d!=0&&d!=1)return 0;
            
            for(auto [v,id]:tmp[u])D.merge(u,v);
        }
    }
    if(!first)return -1;
    if(D.sz[D.fd(first)]!=cn)return 0;
    return x?x:first;// -1 表示全是点集
}
void solve(){
    init();
    n=500;
    cin>>m;
    // cin>>n>>m;
    int u,v;
    for(int i=1;i<=m;i++){
        cin>>u>>v;
        // case 1 无向图:
        tmp[u].push_back({v,i});
        tmp[v].push_back({u,i});
        out[u]++,in[v]++;
        out[v]++,in[u]++;
        // // case 2 有向图:
        // tmp[u].push_back({v,i});
        // out[u]++,in[v]++;
    }
    // 起点字典序最小处理
    // 【注意】使用前请保证该图为 连通欧拉图 + 孤立点集
    // case 1 无向图:
    int st = check_u();// AC
    // // case 2 有向图:
    // int st = check_d();// AC
    if(!st){cout<<"No\n";return;}
    // 字典序最小处理
    for(int u=1;u<=n;u++){
        // 【WC】 我 SB 了 【链式前向星】是 【头插】的
        sort(tmp[u].begin(),tmp[u].end(),greater<>());
        for(auto [v,id]:tmp[u])add_edge(u,v,id);
    }
    dfs(st);// AC AC 
    reverse(path.begin(),path.end());
    for(auto u:path)cout<<u<<"\n";
    // for(auto u:path)cout<<u<<" ";
    cout<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

== 哈密顿图

=== 定义

#note[
    + *哈密顿通路*: 通过图中所有顶点一次且仅一次的*通路*
    + *哈密顿回路*: 通过图中所有顶点一次且仅一次的*回路*
    + *哈密顿图*: 具有*哈密顿回路*的图
    + *半哈密顿图*: 具有*哈密顿通路*而不具有*哈密顿回路*的图
]

=== 性质 (必要条件)

#note[
    + 设 $G=⟨V,E⟩$ 是*哈密顿图*，则对于 $V$ 的任意非空真子集 $V_1$​，均有 $p(G-V_1)<=|V_1|$ (其中 p(x) 为 x 的连通分支数)
        - *通俗理解*: 你从*手环*上摘掉 $k$ 颗珠子（对应删掉$|V_1|=k$个顶点），剩下的珠子最多会被分成 $k$ 段断开的链子，绝对不可能分成比 $k$ 更多的段。
    + 设 $G=⟨V,E⟩$ 是*半哈密顿图*，则对于 $V$ 的任意非空真子集 $V_1$​，均有 $p(G-V_1)<=|V_1|+1$ (其中 p(x) 为 x 的连通分支数)
        - *通俗理解*: 你从*串*上摘掉 $k$ 颗珠子（对应删掉$|V_1|=k$个顶点），剩下的珠子最多会被分成 $k+1$ 段断开的链子，绝对不可能分成比 $k$ 更多的段。
    + 完全图 $K_(2k+1) ((2k(2k+1))/2 = k times (2k+1) "条边")$ 中包含 $k$ 条边不重的哈密顿回路 
    + 完全图 $K_(2k) ((2k(2k-1))/2 = k + (k-1) times 2k "条边")$ 中包含 $k-1$ 条边不重的哈密顿回路. 从 $K_(2k)$ 中删除这 $k-1$ 条边不重的哈密顿回路后所得图含 $k$ 条互不相邻的边。
]

=== 充分条件

#note[
    - *哈密顿通路* 存在: $G$ 是 $n$ 的*无向简单图*, 对于 $G$ 中任意*不相邻*的顶点 $u, v$ 均有 $d(u)+d(v)>=n-1$ 则 $G$ 中存在哈密顿通路   
    - *哈密顿回路* 存在: $G$ 是 $n$ 的*无向简单图*, 对于 $G$ 中任意*不相邻*的顶点 $u, v$ 均有 $d(u)+d(v)>=n$ 则 $G$ 中存在哈密顿回路
    - *哈密顿回路* 存在: $G$ 是 $n$ 的*无向简单图*, 对于 $G$ 中任意顶点 $u$ 均有 $d(u)>=n/2$ 则 $G$ 中存在哈密顿回路

    - *竞赛图*: $n$ 个顶点的有向图，任意两个不同的顶点之间，有且只有一条有向边。

    + 设 $D$ 为 $n >= 2$ 阶*竞赛图*，则 $D$ 具有*哈密顿通路*。
    + 若 $D$ 含 $n >= 2$ 阶*竞赛图*作为子图，则 $D$ 具有*哈密顿通路*。
    + 强连通的竞赛图为哈密顿图．
    + 若 $D$ 含 $n >= 2$ 阶*强连通*的*竞赛图*作为子图，则 $D$ 具有*哈密顿回路*。
]

== 二分图

=== 定义

顶点集 $V$ 可以分为 两个互不相交的子集 $X, Y$ 使得每条边 $e$ 的两个端点都分别属于两者 就称图 $G$ 是一个二分图

=== 刻画

- 可 `2-着色` 的 就是说, 可以用至多两种颜色给图的所有顶点染色, 并且保证相邻顶点颜色不同. 
- 不存在奇数长度的环. 

=== 判定

- 要判定一个图是不是二分图, 只需要利用上述等价刻画, 尝试给二分图染色即可. 

```cpp
int n;
std::vector<std::vector<int>> gr;
std::vector<int> colors, vis;
// Depth-first search to color vertices.
bool dfs(int cr) {
  vis[cr] = true;
  for (int nt : gr[cr]) {
    if (vis[nt]) {
      if (colors[cr] == colors[nt]) return false;
    } else {
      colors[nt] = colors[cr] ^ 1;
      if (!dfs(nt)) return false;
    }
  }
  return true;
}
// Check whether the graph GR is bipartite.
// If so, the vector COLORS will store a feasible coloring.
bool check_bipartite() {
  for (int i = 1; i <= n; ++i) {
    // Check connected components one by one.
    if (!vis[i]) {
      colors[i] = 0;
      if (!dfs(i)) return false;
    }
  }
  return true;
}
```

=== 应用

由于结构简单, 很多图论优化问题都可以在二分图上高效解决. 详情参考相关主条目. 

#note[
  *极大团 (平凡) * & *最小点着色 (平凡) * & *最小边着色* \
  *最大匹配* & *最小边覆盖* & *最小点覆盖* \
  *最大独立集* & *最大权匹配* & *二分图博弈*
]

== 平面图

=== 性质

- *面*: 有且仅有一个 无界 (*无界面\/外部面*), 有界 (*有限面\/外部面*) 
- *边界*: 包围每个面的所有边组成的回路 (*边界*), 边界的长度 (*次数*)
- 平面图中所有 *面* 的 *次数* 之和等于边数的 $2$ 倍
- $1$ 次面: 自环
- $2$ 次面: 重边
- $3$ 次面: $|V|>=3$ 的简单连通平面图的每个面

==== 欧拉公式

对于连通的平面图 $G$ 有 

$ |V| - |E| + |F| = 2 $

#note(title:"推论")[
    对于有 $k$ 个连通分支的平面图 $G$ 
    $ |V| - |E| + |F| = k + 1 $
] 

平面图的边与顶点的数量关系

对于有 $k$ 个连通分支的平面图 $G$，如果图 $G$ 的每个面次数都至少为 $l >= 3$，那么有 

$ |E|<=l/(l-2)(|V|-k-1) $

设 $G$ 是简单可平面图，且 $|V| >= 3$，那么，有

$ |E|<=3|V|-6 $

==== 对偶图

#note[
    TO DO ? 对偶图
]

==== 更多结果

#note(title:"四色定理")[
    （没有自环的）平面图都是可 *4-着色的*
]

#note(title:"Fary定理")[
    简单可平面图总是存在一种平面嵌入，使得图的所有边都是直线段．
]

#note(title:"Wood定理")[
    可平面图至多只有 $8|V|-16$ 个极大团．
]

#note(title:"Tutte定理")[
    $4$-点连通 的可平面图都是哈密顿图．
]

=== 判定

#note[
    平面图最经典的刻画方式是利用 *禁用图* 给出的

    $K_5,K_(3,3)$ 不是可平面图, 事实上，它们就是使得一个图不可平面的最小结构．
]

- 若两个图 $G_1$ 与 $G_2$ 同构，或通过反复插入或消去 $2$ 度顶点后是同构的，则称二者是 *同胚的*
- 图 $G$ 是可平面图，当且仅当 $G$ 中没有可以收缩到 $K_5$ 或 $K_(3,3)$ 的子图．

==== 判定算法

#note[
    尽管看起来并不容易，平面性判定问题实际上有很多线性算法．但是，由于这些算法的实现通常都比较复杂，它们几乎从未出现在算法竞赛中．
]
=== 特殊的平面图

==== 极大平面图

极大可平面图 $G$ 必然连通．而且，当顶点数 $|V| >= 3$ 时，图 $G$ 没有割边．

对于顶点数 $|V| >= 3$ 的平面图 $G$，它是极大平面图当且仅当它是简单图，且它的每个面次数均为 $3$．

对于顶点数 $|V| >= 3$ 的图 $G$，总是有边数 $|E|=3|V|-6$ 且面数 $|F|=2|V|-4$．

由于极大平面图中，每个面都是由三条边围成，所以极大平面图也称为 *平面三角剖分*

==== 外平面图

就是说 所有的点 都可以在一个外边界上的平面图

同样有 *极大外平面图* 

#note(title:"定理")[
    - 对于 $|V|>=3$ 的极大外平面图, 所有的点都在外部面的边界上, 那么图 $G$ 恰有 $|V|-2$ 个内部面

    - 对于 $|V|>=3$ 的外平面图 $G$, 且所有顶点都在外部面的边界上, 那么图 $G$ 是极大外平面图, 当且仅当图 $G$ 的外部面是长为 $|V|$ 的环, 且所有内部面边界都是长为 $3$ 的环

    - 对于 $|V|>=3$ 的极大外平面图 $G$, 有:
        + $|E|=2|V|-3$
        + $G$ 中至少有 $3$ 个顶点度数 $<=3$, 且至少有 $2$ 个顶点度数为 2.
        + $G$ 的点连通度为 2.
]

== 弦图

#note[
    T DO ? 弦图
]

== 图的着色

#note[  
    TO DO ? 图的着色
]

== 网络流

=== 最大流

==== 最大流最小割定理

- 最大流等于最小割

==== Ford-Fulkerson 增广

#note[
  运用贪心的思想, 通过寻找增广路来更新并求解最大流
]

==== Edmonds-Karp 算法

#note[  
    $O(|V||E|^2)$ 

    Dinic 的初级版本 特点是增广是一次一次的 方案清晰???
]

==== Dinic 算法

#note[  
    $O(|V|^2|E|)$

    + BFS 分层图优化
    + 当前弧优化
    + 多路增广优化
]

```cpp
using LL = long long;
const int N = 1205,M=2e5+5;// [SB] 二分图的 N 两倍在这里改 
const LL INF = 1e16;// 其实不必要一次性塞满 
namespace Dinic{
    struct Edge{
        int to,nxt;
        LL w;
    }e[M*2+N*2];
    int hd[N],cur[N],cntE;
    int n,s,t;
    int d[N];
    void init(int nn){
        n=nn;
        fill(hd,hd+1+n,0);
        cntE=1;
    }
    inline void add_edge(int u,int v,LL w){
        e[++cntE]={v,hd[u],w};hd[u]=cntE;
        e[++cntE]={u,hd[v],0};hd[v]=cntE;
    }
    inline bool bfs(){
        fill(d,d+1+n,-1);
        queue<int> Q;
        Q.push(s);d[s]=0;cur[s]=hd[s];// 素质三连
        while(Q.size()){
            int u=Q.front();Q.pop();
            if(u==t)return true;
            for(int i=hd[u],v;i;i=e[i].nxt){
                v=e[i].to;
                if(!e[i].w||~d[v])continue;// 跳过反向边
                Q.push(v);d[v]=d[u]+1;cur[v]=hd[v];// 素质三连
            }
        }
        return false;
    }
    LL dfs(int u=s,LL sum=INF){
        if(u==t)return sum;
        LL res=0,tk;
        for(int i=cur[u],v;i&&sum;i=e[i].nxt){// sum 剪枝
            cur[u]=i;// 当前弧优化
            v=e[i].to;
            if(d[v]!=d[u]+1||!e[i].w)continue;// 死路剪枝1
            tk=dfs(v,min(sum,e[i].w));
            if(tk){
                sum-=tk;
                res+=tk;
                e[i].w-=tk;
                e[i^1].w+=tk;
            }else d[v]=-1;// 死路剪枝2
        }
        return res;
    }
    LL calc(int ss,int tt){
        s=ss;t=tt;
        LL ans=0;
        while(bfs())ans+=dfs();
        return ans;
    }
}
```

==== MPM 算法

#note[  
    $O(|V|^3)$ 

    TO DO !! MPM
]

==== ISAP (基于 Dinic)

#note[  
    $O(|V|^2|E|)$

    + 反向 BFS 分层图优化
    + 当前弧优化
    + GAP 优化
    + DFS 的同时分层
]

```cpp
using LL = long long;
const int N=1205,M=2e5+5;// [SB] 二分图的 N 两倍在这里改 
const LL INF =1e16;
namespace ISAP{
    struct Edge{
        int to,nxt;
        LL w;
    }e[M*2+N*2];// 二分图最大匹配 + N*2
    int hd[N],cur[N],cntE;
    int n,s,t;
    int d[N],gap[N];// [新]gap
    void init(int nn){
        n=nn;
        fill(hd,hd+1+n,0);
        cntE=1;
    }
    inline void add_edge(int u,int v,LL w){
        e[++cntE]={v,hd[u],w};hd[u]=cntE;
        e[++cntE]={u,hd[v],0};hd[v]=cntE;
    }
    void bfs(){
        fill(d,d+1+n,-1);
        fill(gap,gap+1+n,0);// [新]
        queue<int> Q;
        Q.push(t);gap[d[t]=0]=1;// [!]t [+]gap [-]cur
        while(Q.size()){
            int u=Q.front();Q.pop();
            for(int i=hd[u],v;i;i=e[i].nxt){
                v=e[i].to;
                if(e[i].w||~d[v])continue;// [!]跳过正向边
                Q.push(v);gap[d[v]=d[u]+1]++;// [+]gap [-]cur
            }
        }
    }
    LL dfs(int u=s,LL sum=INF){
        if(u==t)return sum;
        LL res=0,tk;
        for(int i=cur[u],v;i;i=e[i].nxt){// [-]sum
            cur[u]=i;
            v=e[i].to;
            if(d[v]+1!=d[u]||!e[i].w)continue;// [!] v+1=u
            tk=dfs(v,min(sum,e[i].w));
            if(!tk)continue;// [+] continue [-] d[v]=-1
            e[i].w-=tk;
            e[i^1].w+=tk;
            sum-=tk;
            res+=tk;
            if(!sum)return res;// [+] return
        }
        if(!--gap[d[u]])d[s]=n;// [+] 断层 
        gap[++d[u]]++;// [+] 抬高
        return res;// [+] 
    }
    LL calc(int ss,int tt){
        s=ss;t=tt;
        LL ans=0;
        bfs();
        while(d[s]<n){// [!] d[s]<n
            memcpy(cur,hd,sizeof(hd[0])*(n+1));// [+] 当前弧
            ans+=dfs();
        }
        return ans;
    }
}
```

==== HLPP (最高标号预流推进)

#note[  
    $O(|V|^2 |E|^(1/2))$

    + 反向 BFS 分层图
    + GAP 优化
    + 堆 / 链栈 辅助
]

```cpp
using LL = long long;
// [TLE] 眼瞎sizeof(hd[0]*(n+1))
// 从此不再 memset(), fill() 启动 !!!!
const int N=1205,M=2e5+5;
const int inf = 0x3f3f3f3f;// 只需要索引级别的 inf !!!
const LL INF = 1e16;

// HLPP 天然不需要 LL 级别的 INF 
// 但是 依赖 inf 方便求 h 
namespace HLPP{
    struct Edge{
        int to,nxt;
        LL w;
    }e[M*2];
    int hd[N],cntE;
    int n,s,t;
    int h[N],gap[N];// gap[] 还是 1 倍
    LL flow[N];
    bool inq[N];
    priority_queue<pair<int,int>> Q;// 这个其实常数更小 !!!!
    void init(int nn){
        n=nn;
        fill(hd,hd+1+n,0);
        cntE=1;
    }
    inline void add_edge(int u,int v,LL w){
        e[++cntE]={v,hd[u],w};hd[u]=cntE;
        e[++cntE]={u,hd[v],0};hd[v]=cntE;
    }
    bool bfs(){
        fill(h,h+1+n,inf);
        queue<int> q;
        q.push(t);h[t]=0;// [RE] 不套娃了
        while(q.size()){
            int u=q.front();q.pop();
            for(int i=hd[u],v;i;i=e[i].nxt){
                v=e[i].to;
                if(e[i^1].w&&h[v]>h[u]+1)
                    q.push(v),h[v]=h[u]+1;// [RE] 不套娃了
            }
        }
        return h[s]!=inf;
    }
    bool push(int u){
        LL tk;
        for(int i=hd[u],v;i&&flow[u];i=e[i].nxt){
            v=e[i].to;
            if(h[v]!=h[u]-1||!e[i].w)continue;
            tk=min(flow[u],e[i].w);
            flow[u]-=tk;
            flow[v]+=tk;
            e[i].w-=tk;
            e[i^1].w+=tk;
            if(!inq[v]&&v!=s&&v!=t)
                Q.push({h[v],v}),inq[v]=1;
        }
        return flow[u];
    }
    void relabel(int u){
        h[u]=inf;// inf !!!! 
        for(int i=hd[u],v;i;i=e[i].nxt)
            if(e[i].w)
                h[u]=min(h[u],h[e[i].to]);
        if(++h[u]<n){
            gap[h[u]]++;
            Q.push({h[u],u});inq[u]=1;
        }
    }
    LL calc(int ss,int tt){
        s=ss;t=tt;
        if(!bfs())return 0;
        h[s]=n;
        // [RE] 不套娃了 老老实实 判断 inf 求 gap
        for(int i=1;i<=n;i++)if(h[i]!=inf)gap[h[i]]++;
        fill(flow,flow+1+n,0);
        for(int i=hd[s],v;i;i=e[i].nxt){
            v=e[i].to;
            flow[v]+=e[i].w;
            e[i^1].w=e[i].w;
            e[i].w=0;
            // [RE] 初始的堆 没写 h[v]!=inf 一出来就炸了!!!!!!
            if(!inq[v]&&v!=s&&v!=t&&h[v]!=inf)
                Q.push({h[v],v}),inq[v]=1;
        }
        while(Q.size()){
            int u=Q.top().second;Q.pop();inq[u]=0;
            if(push(u)){// 推送如果还有余量
                if(!--gap[h[u]])// 如果 gap 终结
                    for(int i=1;i<=n;i++)// 将 (h,n] 的直接终结
                        if(h[i]>h[u]&&h[i]<n+1&&i!=s&&i!=t)
                            gap[h[i]]--,h[i]=n+1;
                relabel(u);// 重新标号 
            }
        }
        return flow[t];
    }
}
int n,m,s,t,u,v,e,cnte,S,T;LL w,a,b,l[M*2],F[N];
void solve_demo(){
    cin>>n>>m>>s>>t;
    HLPP::init(n);
    while(m--)cin>>u>>v>>w,HLPP::add_edge(u,v,w);
    cout<<HLPP::calc(s,t)<<"\n";
}
void solve_pilot(){
    cin>>m>>n;S=n+1;T=n+2;
    HLPP::init(n+2);
    for(int i=1;i<=m;i++)HLPP::add_edge(n+1,i,1);
    for(int i=m+1;i<=n;i++)HLPP::add_edge(i,n+2,1);
    while(cin>>u>>v,(u!=-1&&v!=-1))HLPP::add_edge(u,v,1);
    cout<<HLPP::calc(S,T)<<"\n";
    for(int u=1;u<=m;u++)
        for(int i=HLPP::hd[u];i;i=HLPP::e[i].nxt)
            if(HLPP::e[i^1].w&&HLPP::e[i].to<=n)cout<<u<<" "<<HLPP::e[i].to<<"\n";
}
void solve_bigraph_match(){
    cin>>n>>m>>e;S=n+m+1;T=n+m+2;
    HLPP::init(n+m+2);
    for(int i=1;i<=n;i++)HLPP::add_edge(n+m+1,i,1);
    for(int i=1;i<=m;i++)HLPP::add_edge(i+n,n+m+2,1);
    while(e--)cin>>u>>v,HLPP::add_edge(u,v+n,1);
    cout<<HLPP::calc(S,T)<<"\n";
}
void solve_no_ST_any(){
    cin>>n>>m;
    S=n+1;T=n+2;HLPP::init(n+2);cnte=1;
    for(int i=1;i<=m;i++){
        cin>>u>>v>>a>>b;
        HLPP::add_edge(u,v,b-a);
        l[++cnte]=a,++cnte;
        F[u]-=a;F[v]+=a;
    }
    LL tot=0;
    for(int i=1;i<=n;i++)
        if(F[i]>0)HLPP::add_edge(S,i,F[i]),tot+=F[i];
        else if(F[i]<0)HLPP::add_edge(i,T,-F[i]);
    if(tot!=HLPP::calc(S,T)){
        cout<<"No\n";
    }else {
        cout<<"Yes\n";
        for(int i=2;i<=1+m*2;i+=2)
            cout<<(l[i]+HLPP::e[i^1].w)<<"\n";// [异或1] 才是使用量
    }
}
void solve_ST_m(bool is_max){
    cin>>n>>m>>s>>t;
    S=n+1;T=n+2;HLPP::init(n+2);cnte=1;
    for(int i=1;i<=m;i++){
        cin>>u>>v>>a>>b;
        HLPP::add_edge(u,v,b-a);
        l[++cnte]=a,++cnte;
        F[u]-=a;F[v]+=a;
    }
    HLPP::add_edge(t,s,INF);// [] 保持和 cnte 同频 
    LL tot=0;
    for(int i=1;i<=n;i++)
    if(F[i]>0)HLPP::add_edge(S,i,F[i]),tot+=F[i];
    else if(F[i]<0)HLPP::add_edge(i,T,-F[i]);
    if(tot!=HLPP::calc(S,T)){
        cout<<"N\n";
    }else {
        LL ans=HLPP::e[cnte+2].w;// 已经使用的流量
        HLPP::e[cnte+1].w=HLPP::e[cnte+2].w=0;// 断边
        if(is_max)ans+=HLPP::calc(s,t);// 我觉得残余 反悔边权 存在 计算的仍然是 s->t 最大增量 
        else ans-=HLPP::calc(t,s);// 显然 使用边权流守恒 可以证明 要不然这里怎么退流
        cout<<ans<<"\n";
    }
}
void solve_min_points_cover(){// 五字OJ 
    // HLPP 算法得到的残余网络 gap优化 缺少退流 不正确
}
```

=== 最小割

#note[  
    没有新算法, 最大流等于最小割
]

==== 定义

将图的点划分为两个集合 $S,T$ 其中源点和汇点 $s in S, t in T$\
求使得 $sum_(u in S, v in T, (u,v) in E) w(u,v)$ 最小的 $S,T$ 划分

==== 方案

#note[  
    我们可以通过从源点 $s$ 开始 `DFS`, 每次走残量大于 $0$ 的边, 找到所有 $S$ 点集内的点．
]

```cpp
void dfs(int u) {
  vis[u] = 1;
  for (int i = hd[u]; i; i = e[i].nxt) {
    int v = e[i].to;
    if (!vis[v] && e[i].w) dfs(v);
  }
}
```

==== 割边数量

#note[
    - 如果需要在*最小割*的前提下*最小化割边数量*, 那么先求出最小割, 把没有满流的边容量改成 $infinity$, 满流的边容量改成 $1$, 重新跑一遍最小割就可求出最小割边数量; 
    - 如果*没有*最小割的前提, 直接把所有边的容量设成 $1$, 求一遍最小割就好了.(人话: 割边集)
]

==== 问题模型

===== (1) $n$ 个物品二分关联代价

有 $n$ 个物品和两个集合 $A, B$, 如果一个物品没有放入 $A$ 集合会花费 $a_i$, 没有放入 $B$ 集合会花费 $b_i$；还有若干个形如 $u_i, v_i, w_i$ 限制条件, 表示如果 $u_i$ 和 $v_i$ 同时不在一个集合会花费 $w_i$. 每个物品必须且只能属于一个集合, 求最小的代价. 

这是一个经典的 *二者选其一* 的最小割题目. 我们对于每个集合设置源点 $s$ 和汇点 $t$, 第 $i$ 个点由 $s$ 连一条容量为 $a_i$ 的边、向 $t$ 连一条容量为 $b_i$ 的边. 对于限制条件 $u, v, w$, 我们在 $u, v$ 之间连容量为 $w$ 的双向边. 

注意到当源点和汇点不相连时, 代表这些点都选择了其中一个集合. 如果将连向 $s$ 或 $t$ 的边割开, 表示不放在 $A$ 或 $B$ 集合, 如果把物品之间的边割开, 表示这两个物品不放在同一个集合. 

最小割就是最小花费. 

===== (2) 最大权弱连通的有向子图

最大权值闭合图, 即给定一张有向图, 每个点都有一个权值 (可以为正或负或 0), 你需要选择一个权值和最大的子图, 使得子图中每个点的后继都在子图中.

做法：建立超级源点 $s$ 和超级汇点 $t$, 若节点 $u$ 权值为正, 则 $s$ 向 $u$ 连一条有向边, 边权即为该点点权；若节点 $u$ 权值为负, 则由 $u$ 向 $t$ 连一条有向边, 边权即为该点点权的相反数. 原图上所有边权改为 $infinity$. 跑网络最大流, 将所有正权值之和减去最大流, 即为答案. 

=== 费用流

==== SSP 算法

#note[
    $O(n m f) <= O(n^3 2^(n/2))$

    SSP (Successive Shortest Path) 算法是一个贪心的算法. 它的思路是每次寻找单位费用最小的增广路进行增广, 直到图上不存在增广路为止. 
]

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=5e3+5,M=5e4+5;
const LL INF = 1e10;// d 是 LL !!!

namespace SSP{
    struct Edge{
        int to,nxt;
        LL w,c;// c 代价
    }e[M*2];
    int hd[N],cur[N],cntE;
    int n,s,t;
    bool inq[N];
    LL d[N];// [开LL] 边权不是 1 GAP 没了
    LL ans,cost;// 最大流 / 总费用
    void init(int nn){
        n=nn;
        fill(hd,hd+1+n,0);
        cntE=1;
    }
    inline void add_edge(int u,int v,LL w,LL c){
        e[++cntE]={v,hd[u],w,c};hd[u]=cntE;
        e[++cntE]={u,hd[v],0,-c};hd[v]=cntE;// 注意这里 -c
    }
    bool spfa(){// 可能负环 只能 spfa 除非 Js
        fill(d,d+1+n,INF);
        queue<int> q;
        q.push(s);d[s]=0;
        while(q.size()){
            int u=q.front();q.pop();inq[u]=0;
            for(int i=hd[u],v;i;i=e[i].nxt){
                v=e[i].to;
                if(e[i].w&&d[v]>d[u]+e[i].c){
                    d[v]=d[u]+e[i].c;
                    if(!inq[v])q.push(v),inq[v]=1;
                }
            }
        }
        return d[t]!=INF;
    }
    LL dfs(int u=s,LL sum=INF){
        if(u==t)return sum;
        inq[u]=1;
        LL res=0,tk;
        for(int& i=cur[u],v;i&&sum;i=e[i].nxt){
            v=e[i].to;// [SB写成nxt] 666 
            if(!inq[v]&&e[i].w&&d[v]==d[u]+e[i].c){
                tk=dfs(v,min(sum,e[i].w));
                if(tk){
                    e[i].w-=tk;
                    e[i^1].w+=tk;
                    res+=tk;
                    sum-=tk;
                    cost+=tk*e[i].c;// [注意!!!]
                }else d[v]=INF;
            }
        }
        inq[u]=0;
        return res;
    }
    pair<LL,LL> calc(int ss,int tt){// [确实]
        s=ss;t=tt;
        ans=cost=0;
        while(spfa()){
            memcpy(cur,hd,sizeof(hd[0])*(n+1));
            LL x=0;while(x=dfs())ans+=x;
        }
        return {ans,cost};
    }
}
int n,m,s,t,u,v;LL w,c;
void solve_CF(){
    cin>>n>>m>>s>>t;
    SSP::init(n);
    while(m--)cin>>u>>v>>w>>c,SSP::add_edge(u,v,w,c);
    auto [ans,cost] = SSP::calc(s,t);
    cout<<ans<<" "<<cost<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve_CF();
}
```

==== Primal-Dual 原始对偶算法

#note[
    $O(n m + f m log m )$

    思路与 Johnson 全源最短路径算法 类似, 通过为每个点设置一个势能, 将网络上所有边的费用 (下面简称为边权) 全部变为非负值, 从而可以应用 Dijkstra 算法找出网络上单位费用最小的增广路. 

    - 如果初始边权非负 可以不跑 `spfa` 复杂度 $O(f m log m)$ 
]


```cpp
#include<bits/stdc++.h>
using LL = long long;
using namespace std;
const int N=5e3+5,M=5e4+5;
const LL INF = 1e10;
namespace PD{
    struct Edge{
        int to,nxt;
        LL w,c;
    }e[M*2];
    int hd[N],cntE;
    int n,s,t;
    LL d[N],h[N];
    bool vis[N];
    int p[N];// 记录路径上的边
    LL ans,cost;
    void init(int nn){
        n=nn;
        fill(hd,hd+1+n,0);
        cntE=1;
    }
    inline void add_edge(int u,int v,LL w,LL c){
        e[++cntE]={v,hd[u],w,c};hd[u]=cntE;
        e[++cntE]={u,hd[v],0,-c};hd[v]=cntE;
    }
    void spfa(){
        queue<int> q;
        fill(h,h+1+n,INF);
        q.push(s);h[s]=0;
        while(q.size()){
            int u=q.front();q.pop();
            vis[u]=0;
            for(int i=hd[u],v;i;i=e[i].nxt){
                v=e[i].to;
                if(e[i].w&&h[v]>h[u]+e[i].c){
                    h[v]=h[u]+e[i].c;
                    if(!vis[v])q.push(v),vis[v]=1;
                }
            }
        }
    }
    bool dijk(){
        priority_queue<pair<LL,int>>Q;// first(dist) 取负 小根堆 
        fill(d,d+1+n,INF);
        fill(vis,vis+1+n,false);
        Q.push({-0,s});
        d[s]=0;
        while(Q.size()){
            int u=Q.top().second;Q.pop();
            if(vis[u])continue;
            vis[u]=1;
            LL nc;
            for(int i=hd[u],v;i;i=e[i].nxt){
                v=e[i].to;nc=e[i].c+h[u]-h[v];
                if(e[i].w&&d[v]>d[u]+nc){
                    d[v]=d[u]+nc;
                    p[v]=i;
                    if(!vis[v])Q.push({-d[v],v});
                }
            }
        }
        return d[t]!=INF;
    }
    pair<LL,LL> calc(int ss,int tt){
        s=ss;t=tt;
        ans=cost=0;
        spfa();
        while(dijk()){
            LL tk=INF;
            for(int i=1;i<=n;i++)h[i]+=d[i];
            for(int i=t;i!=s;i=e[p[i]^1].to)
                tk=min(tk,e[p[i]].w);
            for(int i=t;i!=s;i=e[p[i]^1].to)
                e[p[i]].w-=tk,e[p[i]^1].w+=tk;
            ans+=tk;
            cost+=tk*h[t];
        }
        return {ans,cost};
    }
}
int n,m,s,t,u,v;LL w,c;
void solve_CF(){
    cin>>n>>m>>s>>t;
    PD::init(n);
    while(m--)cin>>u>>v>>w>>c,PD::add_edge(u,v,w,c);
    auto [ans,cost] = PD::calc(s,t);
    cout<<ans<<" "<<cost<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve_CF();
}
```

=== 上下界网络流

==== 无源汇上下界 可行流

```cpp
int n,m,s,t,u,v,e,cnte,S,T;LL w,a,b;
void solve_no_ST_any(){
    cin>>n>>m;
    S=n+1;T=n+2;HLPP::init(n+2);cnte=1;
    for(int i=1;i<=m;i++){
        cin>>u>>v>>a>>b;
        HLPP::add_edge(u,v,b-a);
        l[++cnte]=a,++cnte;
        F[u]-=a;F[v]+=a;
    }
    LL tot=0;
    for(int i=1;i<=n;i++)
        if(F[i]>0)HLPP::add_edge(S,i,F[i]),tot+=F[i];
        else if(F[i]<0)HLPP::add_edge(i,T,-F[i]);
    if(tot!=HLPP::calc(S,T)){
        cout<<"No\n";
    }else {
        cout<<"Yes\n";
        for(int i=2;i<=1+m*2;i+=2)
            cout<<(l[i]+HLPP::e[i^1].w)<<"\n";// [异或1] 才是使用量
    }
}
```

==== 有源汇上下界 最大/小流

```cpp
int n,m,s,t,u,v,e,cnte,S,T;LL w,a,b,l[M*2],F[N];
void solve_ST_m(bool is_max){
    cin>>n>>m>>s>>t;
    S=n+1;T=n+2;HLPP::init(n+2);cnte=1;
    for(int i=1;i<=m;i++){
        cin>>u>>v>>a>>b;
        HLPP::add_edge(u,v,b-a);
        l[++cnte]=a,++cnte;
        F[u]-=a;F[v]+=a;
    }
    HLPP::add_edge(t,s,INF);// [] 保持和 cnte 同频 
    LL tot=0;
    for(int i=1;i<=n;i++)
    if(F[i]>0)HLPP::add_edge(S,i,F[i]),tot+=F[i];
    else if(F[i]<0)HLPP::add_edge(i,T,-F[i]);
    if(tot!=HLPP::calc(S,T)){
        cout<<"N\n";
    }else {
        LL ans=HLPP::e[cnte+2].w;// 已经使用的流量
        HLPP::e[cnte+1].w=HLPP::e[cnte+2].w=0;// 断边
        if(is_max)ans+=HLPP::calc(s,t);// 我觉得残余 反悔边权 存在 计算的仍然是 s->t 最大增量 
        else ans-=HLPP::calc(t,s);// 显然 使用边权流守恒 可以证明 要不然这里怎么退流
        cout<<ans<<"\n";
    }
}
```

=== Stoer-Wagner 算法

#note[  
    $O(|V|^3)$

    无向图 无源汇 最小割
]

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=605;
const LL INF=1e18;
int n,m,cnt;
LL g[N][N],d[N];
bool bin[N],vis[N];
LL SW(){
    LL ans=INF;
    for(int i=1;i<n;i++){
        int s=0,t=0;
        fill(vis,vis+1+n,false);
        fill(d,d+1+n,0);
        for(int j=1,now;j<=n-i+1;j++){
            now=0;
            for(int k=1;k<=n;k++)
                if(!bin[k]&&!vis[k]&&d[k]>=d[now])now=k;
            s=t;t=now;
            vis[now]=true;
            for(int k=1;k<=n;k++)d[k]+=g[k][now];
        }
        ans=min(ans,d[t]);
        bin[t]=true;
        for(int j=1;j<=n;j++)
            if(j!=s)g[s][j]=g[j][s]+=g[t][j];
    }
    return ans;
}
void solve(){
    cin>>n>>m;
    int u,v;LL w;
    for(int i=1;i<=m;i++){
        cin>>u>>v>>w;
        g[u][v]=g[v][u]+=w;
    }
    cout<<SW()<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

== 图的匹配

=== 图匹配

=== 二分图最大匹配

==== Kuhn 算法

#note[
    省流
]

==== Hopcroft-Karp 算法

#note[  
    省流
]

==== 归约为最大流问题

#note[
    YES
]

==== Dulmage-Mendelsohn 分解

#note[
    二分图 $G$ 的 任意最大匹配 $M => $ 可以得到 DM 分解(划分)

    $V = epsilon union O union u$  

    + $epsilon$: 从未匹配点走 *even* 长度交错路可以到达的点集
    + $O$: 从未匹配点走 *odd*  长度交错路可以到达的点集
    + $U$: 从未匹配点走交错路 *unreachable* 的点集
]

===== 性质

+ DM 分解唯一
+ 任意最大匹配都包含 
    - $U$ 内的 *完美匹配*
    - $O$ 内的每一个顶点 到 $epsilon$ 中的一个顶点
        - 即 $G$ 的最大匹配等于 $(|U|)/2+|O|$
    - $G$ 中 $epsilon$ 只存在与 $O$ 的连边

#note[
    求得最大匹配之后, 可以通过 BFS 在 $O(|V|+|E|)$ 的时间内求出 
]

```cpp
// WTF ??? 没有
```

===== 最大匹配关键点

#note(title:"定义")[
    一个顶点是关键点, 当且仅当在一个最大匹配中, 不存在从未匹配点出发到达该顶点的偶数长度的交错路．
]

#note(title:"定理")[
    二分图 $G$ 中 $v in V$ 是关键点 当且仅当 $v in O union U$
]

===== 最大匹配关键边

#note(title:"定义")[
    每一个最大匹配中都是匹配边, 那么它就称为最大匹配的关键边．
]

#note(title:"定理")[
    - 二分图的最大匹配是*唯一的*, 当且仅当它的一个最大匹配中, 所有匹配边都是关键边．

    边 $e in E$ 是关键边, 当且仅当 $e$ 的端点都在 $U$ 中, 边 $e$ 是 $M$ 中匹配边, 且相对于 $M$ 不存在一个包含边 $e$ 的交错环．
]

要求出最大匹配的关键边, 需要按照如下步骤进行：
+ 求出图 $G$ 的最大匹配 $M$;
+ 按照 $M$ 将图 $G$ 的边定向, 得到有向图 $G_M$;
+ 进行 `BFS` 求出 DM 分解中的集合 $U$, 即无法通过未匹配点沿着交错路到达的顶点集合;
+ 利用 `Tarjan` 算法 求出有向图 $G_M$ 的全部强连通分量;
+ 遍历匹配 $M$ 中的边, 如果它的端点都在 $U$ 中, 但是不在同一个强连通分量中, 它就是一条关键边．
得到最大匹配后, 后续步骤的时间复杂度为 $O(|V|+|E|)$.

```cpp
// WTF ??? 没有
```

==== 相关问题

===== 二分图最小点覆盖

#note[
    最小点覆盖问题是指, 在一张无向图中选择最少的顶点, 满足每条边至少有一个端点被选．
]

#note(title:"Kőnig 定理")[
    二分图中, 最小点覆盖中的顶点数量等于最大匹配中的边数量．

    从网络流的角度看, 最小点覆盖问题就是最小割问题：选择左部点, 相当于切割它与源点的连边；选择右部点, 相当于切割它与汇点的连边．从线性规划的角度看, 最小点覆盖问题就是最大匹配问题的对偶问题．因此, König 定理可以看作是 最大流最小割定理 的特殊情形, 或者更一般地, 线性规划的强对偶定理的特殊情形．
]

从每一个非匹配点出发, 沿着非匹配边正向进行遍历, 沿着匹配边反向进行遍历到的点进行标记. 选取左部点中没有被标记过的点, 右部点中被标记过的点, 则这些点可以形成该二分图的最小点覆盖. 

#note[
    *特别注意*: HLPP 算法得到的残余网络由于 GAP 优化没有退流 会错! 请使用 Dinic/ISAP
]

```cpp
void color(int u) {
	vis[u] = true;
    for(int i=hd[u],v;i;i=e[i].nxt){
        v=e[i].to;
        // 正向边的容量为0说明是匹配边, 
        // 反向边的容量为0说明是非匹配边
        if(vis[v]||!e[i].w)continue;
        color(v);
    }
}
```

```cpp
void solve_min_points_cover(){// UVA11419
    // 一个 enemy 就代表一个边 连接 row col
    // 只要我选择任意一个点 row/col 就可以覆盖这个边
    // 要消灭所有边 需要选用的最少 row/col 数量
    int n,m,k,r,c;
    while(cin>>n>>m>>k,n||m||k){
        int S=n+m+1,T=n+m+2;
        ISAP::init(n+m+2);
        vector<bool> use(n+m+3),vis(n+m+3);
        // 二分图 最小点覆盖/最大独立集 附加代码
        // 前提: use
        // 点覆盖: 左 !vis 右 vis 独立集相反
        function<void(int)> color;// [NB] c++11 就支持 function了
        color = [&](int u){
            vis[u]=true;
            for(int i=ISAP::hd[u],v;i;i=ISAP::e[i].nxt){
                v=ISAP::e[i].to;
                if(!vis[v]&&ISAP::e[i].w)color(v);
            }
        };
        for(int i=1;i<=k;i++){
            cin>>r>>c;
            ISAP::add_edge(r,n+c,1);
            use[r]=use[n+c]=true;
        }
        for(int i=1;i<=n;i++)if(use[i])ISAP::add_edge(S,i,1);
        for(int i=1;i<=m;i++)if(use[n+i])ISAP::add_edge(n+i,T,1);
        int cnt=ISAP::calc(S,T),cnt2=0;
        color(S);
        cout<<cnt<<" ";
        for(int i=1;i<=n;i++)if(use[i]&&!vis[i]){
            cnt2++;
            cout<<"r"<<i<<" ";
        }
        for(int i=1;i<=m;i++)if(use[n+i]&&vis[n+i]){
            cnt2++;
            cout<<"c"<<i<<" ";
        }
        assert(cnt==cnt2);
        cout<<"\n";
    }
}
```

===== 二分图最大独立集

#note[
最大独立集问题是指, 在一张无向图中选择最多的顶点, 满足两两之间互不相邻．
]

#note(title:"定理")[
    图 $G=(V,E)$ 中, 点集 $C subset.eq V$ 是点覆盖, 当且仅当它的补集 $V without C$ 是独立集．
]

#note(title:"推论")[
    图 $G=(V,E)$ 中, 最小点覆盖与最大独立集的大小之和等于顶点数目．
]

因此, 与最小点覆盖问题一样, 最大独立集问题对于一般图是 NP 困难的, 但是对于二分图它可以归约为最大匹配问题, 从而高效求解．

#note[
    最大独立集 = 最小点覆盖集合的补集 (没有找到题目)
]

===== 有向无环图最小路径覆盖

#note[
在一张有向图中, 选择最少数量的简单路径, 使得所有顶点都恰好出现在一条路径中．

一般的有向图上的最小路径覆盖问题是 NP 困难的, 但是对于有向无环图, 该问题可以归约为二分图最大匹配问题．对于有向无环图 $G=(V,E)$
]

可以二分图 $G' = (V^"in",V^"out",E')$ 如下

+ 为每个顶点 $v in V$, 分别建立一个入点 $v^"in"$ 和一个出点 $v^"out"$．设全体入点和出点的集合分别为 $V^"in"$ 和 $V^"out"$．它们分别成为新图的左部和右部．

+ 为每条有向边 $(u,v) in E$, 建立无向边 $(u^"out",v^"in")$．全体无向边的集合就是 $E'$

#note(title:"定理")[
    有向无环图 $G=(V,E)$ 的最小路径覆盖与相应的二分图 $G'=(V^"in",V^"out",E')$ 的最大匹配的大小之和等于顶点数量
]

#note(title:"???")[
    特别地, 对于集合 $X$ 和它上面的偏序关系 $P$, 可以建立有向无环图 $G=(X,P)$．此时, 根据 Dilworth 定理, 图 $G$ 的最小路径覆盖的大小, 就等于它的最长反链的长度, 也就是偏序集 $(X,P)$ 的宽度．因此, 本节实际上给出了任意偏序集的宽度的高效计算方法．
]

#note[
    异曲同工之妙!!! 

    最小路径覆盖 = 点数 - 最大有向边合并数(一个点最多有一个邻边)
]

```cpp
void solve_min_paths_cover(){// 模板题
    int n,m,S,T,u,v;
    cin>>n>>m;S=n*2+1;T=n*2+2;
    vector<int> pre(n+1),nxt(n+1);
    ISAP::init(n*2+2);
    for(int i=1;i<=n;i++)ISAP::add_edge(S,i,1),ISAP::add_edge(n+i,T,1);
    for(int i=1;i<=m;i++)
        cin>>u>>v,ISAP::add_edge(u,v+n,1);
    int cnt=ISAP::calc(S,T);
    for(int u=1;u<=n;u++)
        for(int i=ISAP::hd[u],v;i;i=ISAP::e[i].nxt){
            v=ISAP::e[i].to;
            if(!ISAP::e[i].w&&v<=n*2)pre[v-n]=u,nxt[u]=v-n;
        }
    for(int u=1;u<=n;u++){
        int x=u;
        if(!pre[x]){
            do cout<<x<<" ";while(x=nxt[x]);
            cout<<"\n";
        }
    }
    cout<<n-cnt<<"\n";
}
```

=== 二分图最大权匹配

==== KM 算法 (常用)

#note[  
    dfs $O(n^4)$ => bfs $O(n^3)$

    代码:最大完美匹配 + 最大匹配
]

```cpp
using LL = long long;
using namespace std;
const int N = 505;
const LL INF = 1e16;
namespace KM{
    int n;
    LL g[N][N],la[N],lb[N],d[N];
    int match[N],pre[N];
    bool vb[N];
    void bfs(int x){
        fill(vb,vb+1+n,false);
        fill(pre,pre+1+n,0);
        fill(d,d+1+n,INF);
        int y=0,yy=0;
        match[0]=x;
        do{
            LL k=INF;
            x=match[y];
            vb[y]=true;
            for(int i=1;i<=n;i++){
                if(vb[i])continue;
                if(d[i]>la[x]+lb[i]-g[x][i]){// la[x!!!] + lb[i] 
                    d[i]=la[x]+lb[i]-g[x][i];
                    pre[i]=y;
                }
                if(k>d[i])k=d[i],yy=i;
            }
            for(int i=0;i<=n;i++)// 从 0 开始
                if(vb[i])la[match[i]]-=k,lb[i]+=k;
                else d[i]-=k;
            y=yy;
        }while(match[y]);
        while(y){
            match[y]=match[pre[y]];
            y=pre[y];
        }
    }
    LL calc(int nn){
        n=nn;
        fill(la,la+1+n,false);
        fill(lb,lb+1+n,false);
        fill(match,match+1+n,0);
        for(int i=1;i<=n;i++)bfs(i);
        LL ans=0;
        for(int i=1;i<=n;i++)
            ans+=g[match[i]][i];
        return ans;
    }   
}using KM::g;
void solve_perfect_match(){// P6577
    int n,u,v,k;LL w;
    cin>>n>>k;
    for(int i=1;i<=n;i++)
        for(int j=1;j<=n;j++)
            g[i][j]=-INF;
    for(int i=1;i<=k;i++){
        cin>>u>>v>>w;
        g[u][v]=max(g[u][v],w);
    }
    cout<<KM::calc(n)<<"\n";
    for(int i=1;i<=n;i++)
        cout<<KM::match[i]<<" ";
    cout<<"\n";
}
void solve_normal_match(){// UOJ80
    int n,m,mx,u,v,k;LL w;
    cin>>n>>m>>k;swap(n,m);// [按需]女左 n 男右 m
    mx=max(n,m);// 扩展为最大值
    for(int i=1;i<=mx;i++)
        for(int j=1;j<=mx;j++)
            g[i][j]=0;// 初始化 0 !!!
    for(int i=1;i<=k;i++){
        cin>>u>>v>>w;swap(u,v);// [按需]女 u 男 v
        g[u][v]=max(g[u][v],w);
    }
    cout<<KM::calc(mx)<<"\n";
    for(int i=1;i<=m;i++)
        // 方案: 因为题目保证 w!=0 所以可以判断是否命中已有边
        cout<<(g[KM::match[i]][i]?KM::match[i]:0)<<" ";
        // 更稳健的写法：判断匹配到的点是否是真实点
        // 即编号 <= 真实的左部点数量 而不是判断边权
    cout<<"\n";
}
```

==== Dynamic Hungarian Algorithm

#note[
    略
]

==== 转化为费用流模型

#note[  
    
与 *二分图最大匹配* 类似, 二分图的最大权匹配也可以转化为网络流问题来求解．

+ 首先, 在图中新增一个源点和一个汇点．

+ 从源点向二分图的每个左部点连一条流量为 $1$, 费用为 $0$ 的边, 从二分图的每个右部点向汇点连一条流量为 $1$, 费用为 $0$ 的边．

+ 接下来对于二分图中每一条连接左部点 $u$ 和右部点 $v$, 边权为 $w$ 的边, 则连一条从 $u$ 到 $v$, 流量为 $1$, 费用为 $w$ 的边．

+ 另外, 考虑到最大权匹配下, 匹配边的数量不一定与最大匹配的匹配边数量相等, 因此对于每个左部点, 还需向汇点连一条流量为 $1$, 费用为 $0$ 的边．

+ 求这个网络的 最大费用最大流 即可得到答案．此时, 该网络的最大流量一定为左部点的数量, 而最大流量下的最大费用即对应一个最大权匹配方案．

代码略
]

=== 一般图最大匹配

#note[
    TO DO ? 一般图最大匹配
]

=== 一般图最大权匹配

#note[
    TO DO ? 一般图最大权匹配
]

=== 稳定匹配

#note[
    TO DO ! 稳定婚姻

    稳定匹配问题的模型中，每个个体对潜在的匹配对象具有偏好，而稳定匹配问题希望能在它们之间建立一种稳定的匹配关系．一个稳定的匹配中，不存在任何一组个体，会因为能得到更优的选择而合谋偏离当前的匹配结果．
]

==== 稳定婚姻 (延迟接受算法)

稳定婚姻问题是最早研究的稳定匹配问题．类似于二分图匹配，它可以描述为婚恋市场上的匹配问题：假设有男士和女士若干，每个人都对异性有一组偏好顺序，目标是找到一种匹配方式，使得没有一对男女更愿意抛弃各自的匹配对象而选择彼此．

```cpp
class Solution {
public:
    vector<vector<int>> stableMatching(vector<vector<int>> man_list, vector<vector<int>> woman_list) {
        int man_num = man_list.size();
        int woman_num = woman_list.size();
        // 男女数量不同，无法完美匹配
        if (man_num != woman_num) return {};
        int n = man_num;
        // 将女性喜好列表的索引和数据置反，方便处理
        vector<vector<int>> inverse_womanlist;
        for (int i = 0; i < n; ++i) {
            vector<int> prefer(n, -1);
            for (int j = 0; j < n; ++j) {
                prefer[woman_list[i][j]] = j;
            }
            inverse_womanlist.push_back(prefer);
        }
        // 记录最终的匹配结果
        vector<vector<int>> S = {};
        // 记录单身男性
        queue<int> free_man;
        for (int i = 0; i < n; ++i) {
            free_man.push(i);
        }
        // husband[w] = m：女性 w 的伴侣是 m
        vector<int> husband(n, -1);
        // 为每个男性维护一个指针（索引），记录喜爱列表中下一个求婚的女性索引
        vector<int> man_pointer(n, 0);
        // G-S算法主体
        while (!free_man.empty()) {
            int m = free_man.front();
            int w = man_list[m][man_pointer[m]];
            // 男方求婚指针向前
            man_pointer[m]++;
            // 女方无配偶
            if (husband[w] == -1) {
                S.push_back({m,w});
                free_man.pop();
                husband[w] = m;
            }
            // 男人m比当前配偶更有吸引力
            else if (inverse_womanlist[w][husband[w]] > inverse_womanlist[w][m]) {
                // 找到 S 中原来关于 w 的一对
                int index;
                for (index = 0; index < S.size(); index++) {
                    if (S[index][1] == w) break;
                }
                int old_m = S[index][0];

                // 从 S 中删除 m'-w
                S.erase(S.begin() + index);
                // 在 S 中添加 m -w
                S.push_back({m, w});
                free_man.pop();
                // w 原来的配偶变为单身汉
                free_man.push(old_m);
                husband[w] = m;
            }
            else {
                // w 拒绝 m
            }
        }
        return S;
    }
};
int main() {
    // 索引代表男性编号（0，1，2），数组代表喜好女性的列表
    vector<vector<int>> manlist = {{0,1,2},
                                   {1,0,2},
                                   {0,1,2}};
    // 索引代表女性编号（0，1，2），数组代表喜好男性的列表
    vector<vector<int>> womanlist = {{1,2,0},
                                     {0,1,2},
                                     {0,1,2}};
    Solution test;
    vector<vector<int>> result;
    result = test.stableMatching(manlist, womanlist);
    for (int i = 0; i < manlist.size(); ++i) {
        cout << result[i][0] << " - " << result[i][1] << endl;
    }
    return 0;
}
```

== Prüfer 序列

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=5e6+5;
int n,mode;
LL ans;
vector<int> e[N];
int deg[N],code[N],fa[N];
// 如果给的数据不是 n 为根的树 就用这个跑出来 fa[]
// 然后 deg[fa[i]]++,deg[i]++;
void dfs(int u=n){
    for(auto v:e[u])if(v!=fa[u]){
        fa[v]=u;
        dfs(v);
    }
}
void encode(){
    int cnt=0;
    for(int i=1;i<=n;i++){
        int j=i;
        while(j<=i&&deg[j]==1)
            deg[j=code[++cnt]=fa[j]]--;
    }
}
void decode(){
    for(int i=1;i<=n;i++)deg[i]=1;
    for(int i=1;i<=n-2;i++)deg[code[i]]++;
    code[n-1]=n;// 必须补充 
    // for(int i=1;i<=n;i++)cout<<i<<":"<<deg[i]<<"\n";
    int cnt=0;
    for(int i=1;i<=n;i++){
        // cout<<"i="<<i<<"\n";
        int j=i;
        while(j<=i&&deg[j]==1){
            // cout<<"fa["<<j<<"]="<<code[cnt+1]<<"\n";
            deg[j=fa[j]=code[++cnt]]--;
        }
    }   
}
void solve(){
    cin>>n>>mode;
    if(mode==1){
        for(int i=1;i<n;i++){
            cin>>fa[i];
            deg[fa[i]]++,deg[i]++;
        }
        encode();
        for(int i=1;i<=n-2;i++)ans^=1LL*i*code[i];
    }else {
        for(int i=1;i<=n-2;i++)cin>>code[i];
        decode();
        for(int i=1;i<n;i++)ans^=1LL*i*fa[i];
    }
    cout<<ans<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

=== Prufer 序列性质

+ 剩下的两个节点 其中一个一定是 $n$
+ 节点 $u$ 的度数 等于 `prufer` 序列中的出现次数($n$为根孩子个数) + 1

=== 凯莱公式

#note[
    - 完全图 $K_n$ 有 $n^(n-2)$ 个生成树 
    - $n$ 个节点的有标号无根树有 $n^(n-2)$ 个
]

=== 扩展:图连通方案数

#note[
    我觉得我的收获是 知道了 *多元二项式定理* 与 *可重集全排列* 的关系，以及 *prufer序列* 与 *度数* 与 *边* 的数学关系

    - $n$ 个 点 $m$ 条 边 $k$ 个 连通子图 的 有标号图 中 连接 $k-1$ 条边 使其连通的方案数 
]

设 $s_i$ 为第 $i$ 个连通子图的节点数 答案:

$
  n^(k-2) product_(i=1)^k s_i
$

== 矩阵树定理

#note[
    TO DO ? 图的生成树个数计数 矩阵树定理
]

== LGV定理

#note[
    TO DO ? 有向无环图上不相交路径计数 矩阵树定理
]

== 最大团搜索算法

#note[
    TO DO ? 最大团搜索算法
]

== 支配树

#note[
    给定起点 $S$ 的必然顺序记录树

    两个题目 
    + 板子
    + 单源最短路生成图(有向图) 的支配树 
]

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=2e5+5;
namespace DT{
    int n;
    vector<int> e[N],re[N],buf[N];
    int dfn[N],rnk[N],dfncnt,fa[N],mn[N],sdom[N],idom[N],f[N];
    int sz[N];
    void init(int nn){
        n=nn;
        dfncnt=0;
    }
    void dfs1(int u){
        rnk[dfn[u]=++dfncnt]=u;
        for(auto v:e[u])if(!dfn[v]){
            fa[v]=u;
            dfs1(v);
        }
    }
    int fd(int x){// 简单并查集 
        if(f[x]==x)return x;
        int fx=fd(f[x]);
        if(dfn[sdom[mn[f[x]]]]<dfn[sdom[mn[x]]])
        mn[x]=mn[f[x]];
        return f[x]=fx;
    }
    void LT(int S){
        dfs1(S);
        // 事后 clear 
        for(int i=1;i<=n;i++){
            f[i]=sdom[i]=mn[i]=i;
            e[i].clear();
        }
        for(int u,i=dfncnt;i>=2;i--){// dfncnt!!! !!! !!!
            u=rnk[i];
            for(auto v:re[u])if(dfn[v]){
                fd(v);
                if(dfn[sdom[mn[v]]]<dfn[sdom[u]])
                sdom[u]=sdom[mn[v]];
            }
            f[u]=fa[u];
            buf[sdom[u]].push_back(u);
            u=rnk[i-1];
            for(auto v:buf[u]){
                fd(v);
                if(sdom[mn[v]]==sdom[v])
                idom[v]=sdom[v];
                else idom[v]=mn[v];
            }
        }
        for(int u,i=2;i<=dfncnt;i++){// dfncnt!!! ??? !!!
            u=rnk[i];
            if(idom[u]!=sdom[u])
            idom[u]=idom[idom[u]];
            e[idom[u]].push_back(u);
        }
    }
    void dfs2(int u){
        sz[u]=1;
        for(auto v:e[u]){
            dfs2(v);
            sz[u]+=sz[v];
        }
    }
}using DT::e,DT::re;
void solve(){
    int n,m;cin>>n>>m;
    DT::init(n);
    for(int u,v,i=1;i<=m;i++){
        cin>>u>>v;
        e[u].push_back(v);
        re[v].push_back(u);
    }
    DT::LT(1);DT::dfs2(1);
    for(int i=1;i<=n;i++)cout<<DT::sz[i]<<" ";cout<<"\n";
}
void solve_CF757E(){
    int n,m,S;cin>>n>>m>>S;
    DT::init(n);
    vector<vector<pair<int,int>>> E(n+1);
    for(int u,v,w,i=1;i<=m;i++){
        cin>>u>>v>>w;
        E[u].push_back({v,w});
        E[v].push_back({u,w});
    }
    priority_queue<pair<long long,int>> Q;
    vector<long long> dis(n+1,1e18);
    dis[S]=0;
    Q.push({-0,S});
    while(Q.size()){
        int u=Q.top().second;Q.pop();
        for(auto [v,w]:E[u])
            if(dis[v]>dis[u]+w){
                dis[v]=dis[u]+w;
                Q.push({-dis[v],v});
            }
    }
    for(int u=1;u<=n;u++){
        for(auto [v,w]:E[u]){
            if(dis[v]==dis[u]+w){
                e[u].push_back(v);
                re[v].push_back(u);
            }
        }
    }
    DT::LT(S);DT::dfs2(S);
    int ans=0;
    for(auto v:e[S])ans=max(ans,DT::sz[v]);cout<<ans<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
    // solve_CF757E();
}
```

== 图上随机游走

#note[
    TO DO ? 图上随机游走
]
