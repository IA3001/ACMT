#import "../lib.typ":*

= 搜索

== DFS

#note[在 DFS 中 `vis[u]=true` 和 `stk.push(u)` 必然绑定。]

```cpp
// 判断访问: vis[] 达到时立即更新
vector<int> e[N];
bool vis[N];
void dfs(int u){
  vis[u]=true;
  for(int v:e[u])if(!vis[v])dfs(v);
}
```

== BFS

- 在 01-BFS 中 `vis[u]=true` 和 `Q.push(u)` 是绑定的（Dijk 是个杂种）

- 特别的
    1. 堆优化dijkstra、 spfa 的 `inq[u]=true` 取代了 `vis` 的此作用
    2. 普通 dijkstra 的`vis[u]=true` 和 `PQ.pop()` 绑定

```cpp
// 判断访问: vis[] 入队时立即更新(注意初始化vis[s])
vector<int> e[N];
bool vis[N];
int dist[N];
void bfs(int s){
    queue<int> Q;
    vis[s]=true,Q.push(s);
    for(int d=0;Q.size();d++){
        for(int t=Q.size();t--;){
            int u=Q.front();Q.pop();
            dist[u]=d;
            for(int v:e[u])if(!vis[v])vis[v]=true,Q.push(v);
        }
        d++;
	}
}
```

== 双向搜索

- 可能的复杂度
  - 双向同时搜索：$O(2a^(n/2))$ （可能）
  - Meet in the middle（折半搜索）：约等于 $O((n+2)2^(n/2-1))$（类似折半背包，需要二分）

```cpp
// 伪代码
// 1.双向同时搜索
vector<int> e[N];  // 邻接表，存储图的边。
bool vis[N][2];    // 访问标记数组：
bool extend(queue<int>& Q,int o){
    int u=Q.front();Q.pop();// 取出队首节点 u。
    for(int v:e[u])if(!vis[v][o]){// 遍历节点 u 的所有邻居 v。
        vis[v][o]=true;// 标记 v 为已访问。
        Q.push(v);// 将 v 入队。
        if(vis[v][o^1])return true;// v 已被另一个方向的 BFS 访问过，找到交集，返回 true。
    }
    return false;
}
void bBFS(int s, int t) {
    queue<int> Qs, Qt;  // Qs 用于从起点 s 出发的 BFS，Qt 用于从终点 t 出发的 BFS。
    Qs.push(s); Qt.push(t);         // 将起点 s 和终点 t 分别加入对应的队列。
    vis[s][0] = vis[t][1] = true;  // 标记起点 s 和终点 t 已被访问。
    bool ok = (s == t);             // 如果起点和终点相同，则直接标记为找到路径。
    while (!ok && !Qs.empty() && !Qt.empty()) {
        if (Qs.size() > Qt.size())  // 如果从起点出发的队列更大，则扩展从终点出发的 BFS。
            ok |= extend(Qt, 1);    // 扩展 Qt，并检查是否找到交集。
        else ok |= extend(Qs, 0);   // 否则扩展从起点出发的 BFS。
    }
}
// 2.折半搜索
vector<pair<int,int>> left,right;
void dfs(vector<pair<int,int>>& arr,int l,int r,int cur_c=0,int cur_v=0){
    if(l==r){
        // 结束 
        arr.push_back({c,v});
    }else {
        // 递归
        dfs(arr,l+1,r,cur_c+c[l],cur_v+v[l]);
        dfs(arr,l+1,r,cur_c,cur_v);
    }
}
void solve(){
    dfs(left,0,mid);
    dfs(right,mid+1,n-1);
    sort(...);
    // 前缀 + 二分 
}
```

== 启发式搜索

#note[搜索加入了 *估价函数* `h` 进行临时导航。]

```cpp
// 伪代码
int ans;  // 全局变量，存储当前最优解。
void dfs(int u,int cur_ans){
  // Base Case
  if(u==ed)return ans=max(ans,cur_ans),void();
  // choice:one
  if(cur_ans+h1(u)>ans)dfs(nxt1,cur_ans+f1(u));
  // choice:others
  if(cur_ans+h2(u)>ans)dfs(nxt2,cur_ans+f2(u));
  // ...
}
void solve(){
    ans = worst;  // 初始化全局最优解为最差值。
    dfs(st, st_ans);  // 从起点 st 开始 DFS。
}
```

== A\*

#note[BFS 优先队列 *导航仪* 优化。]

```cpp
// 伪代码
struct Node {
    int u,f,g;  // 当前节点 // 估价函数值（f = g + h）// 从起点到当前节点的实际代价。
    bool operator<(const Node& o) const { return f > o.f; }  // 小顶堆优先队列。
};
priority_queue<Node> Q;  // 优先队列，按 f 值排序。
bool vis[N];             // 访问标记数组，用于记录节点是否已被访问。
int ans;                 // 全局变量，存储最终的最优解。
void aStar() {
    Q.push({st, st_ans + h(st), st_ans});  // 初始化优先队列，加入起点。
    while (Q.size()) {
        auto [u, f, g] = Q.top(); Q.pop();  // 取出 f 值最小的节点。
        if (vis[u]) continue;vis[u] = true; // 如果节点已访问过，跳过。// 标记节点为已访问。
        if (u == ed) return ans = g, void();  // 如果到达终点，更新答案并结束。
        int v = ...;  // 遍历当前节点 u 的邻居节点 v。
        if (!vis[v] && ...)  // 如果邻居节点未被访问且满足某些条件：
            Q.push({v, g + w(u, v) + h(v), g + w(u, v)});  // 加入优先队列。
    }
}
```

== 迭代加深搜索

#note[不如 IDA\*。]

== IDA\* 搜索

#note[适用于状态数极多的最短路问题，代替 BFS 进行 *预警机* 优化。]

```cpp
// 伪代码
/* P1763 迭代加深启发式 */
int dep;
bool IDAStar(int u,int d){
  	if(d+h(u)>dep||ok)return false;
    if(u==ed)return true;
   	for(auto v:e[u])if(IDAStar(v,d+1)) return true;
    return false;
}
void solve(){
  for(dep=2;dep<=30;dep++)
    if(IDAStar(st,1))return;
}
```

== 回溯法

- 比如图论中的 `lst[N]`   
- dfs方案中的压栈路径 `vector<int> path` （`bool vis[N]`）    
- 千万注意：不要随便 `return`， 记得先路径出栈

== Dancing Links (DLX)

#note[人话：跟拨码密码锁差不多的数据结构]

- DLX 递归及回溯的次数与矩阵中 `1` 的个数有关，与矩阵的 `r`, `c` 等参数无关。因此，它的时间复杂度是 指数级 的，理论复杂度大概在 $O(c^n)$ 左右，其中 `c` 为某个非常接近于 `1` 的常数，`n` 为矩阵中 `1` 的个数。

- 我们每拿到一个题，应该考虑行和列所表示的意义：
    + 行表示决策，因为每行对应着一个集合，也就对应着选/不选；
    + 列表示状态，因为第 `i` 列对应着某个条件 $P_i$。
    + 对于某一行而言，由于不同的列的值不尽相同，我们 由不同的状态，定义了一个决策。

```cpp
#include <bits/stdc++.h>
constexpr int N = 500 + 10;
int n, m, ans;
int stk[N];

struct DLX {
  static constexpr int MAXSIZE = 1e5 + 10;
  int n, m, tot, first[MAXSIZE + 10], siz[MAXSIZE + 10];
  int L[MAXSIZE + 10], R[MAXSIZE + 10], U[MAXSIZE + 10], D[MAXSIZE + 10];
  int col[MAXSIZE + 10], row[MAXSIZE + 10];

  void build(const int &r, const int &c) {  // 进行build操作
    n = r, m = c;
    for (int i = 0; i <= c; ++i) {
      L[i] = i - 1, R[i] = i + 1;
      U[i] = D[i] = i;
    }
    L[0] = c, R[c] = 0, tot = c;
    memset(first, 0, sizeof(first));
    memset(siz, 0, sizeof(siz));
  }

  void insert(const int &r, const int &c) {  // 进行insert操作
    col[++tot] = c, row[tot] = r, ++siz[c];
    D[tot] = D[c], U[D[c]] = tot, U[tot] = c, D[c] = tot;
    if (!first[r])
      first[r] = L[tot] = R[tot] = tot;
    else {
      R[tot] = R[first[r]], L[R[first[r]]] = tot;
      L[tot] = first[r], R[first[r]] = tot;
    }
  }

  void remove(const int &c) {  // 进行remove操作
    int i, j;
    L[R[c]] = L[c], R[L[c]] = R[c];
    for (i = D[c]; i != c; i = D[i])
      for (j = R[i]; j != i; j = R[j])
        U[D[j]] = U[j], D[U[j]] = D[j], --siz[col[j]];
  }

  void recover(const int &c) {  // 进行recover操作
    int i, j;
    for (i = U[c]; i != c; i = U[i])
      for (j = L[i]; j != i; j = L[j]) U[D[j]] = D[U[j]] = j, ++siz[col[j]];
    L[R[c]] = R[L[c]] = c;
  }

  bool dance(int dep) {  // dance
    if (!R[0]) {
      ans = dep;
      return true;
    }
    int i, j, c = R[0];
    for (i = R[0]; i != 0; i = R[i])
      if (siz[i] < siz[c]) c = i;
    remove(c);
    for (i = D[c]; i != c; i = D[i]) {
      stk[dep] = row[i];
      for (j = R[i]; j != i; j = R[j]) remove(col[j]);
      if (dance(dep + 1)) return true;
      for (j = L[i]; j != i; j = L[j]) recover(col[j]);
    }
    recover(c);
    return false;
  }
} solver;

using std::cin;
using std::cout;

int main() {
  cin.tie(nullptr)->sync_with_stdio(false);
  cin >> n >> m;
  solver.build(n, m);
  for (int i = 1; i <= n; ++i)
    for (int j = 1; j <= m; ++j) {
      int x;
      cin >> x;
      if (x) solver.insert(i, j);
    }
  solver.dance(1);
  if (ans)
    for (int i = 1; i < ans; ++i) cout << stk[i] << ' ';
  else
    cout << "No Solution!\n";
  return 0;
}
```

== Alpha-Beta 剪枝

#note[`alpha` 要最大化答案，`beta` 要最小化答案  \
`alpha` 只能选择 最小值的最大值，`beta` 只能选择最大值的最小值。]

```cpp
int alpha_beta(int u, int alph, int beta, bool is_max) {
  if (!son_num[u]) return val[u];
  if (is_max) {
    for (int i = 0; i < son_num[u]; ++i) {
      int d = son[u][i];
      alph = max(alph, alpha_beta(d, alph, beta, !is_max));
      if (alph >= beta) break;
    }
    return alph;
  } else {
    for (int i = 0; i < son_num[u]; ++i) {
      int d = son[u][i];
      beta = min(beta, alpha_beta(d, alph, beta, !is_max));
      if (alph >= beta) break;
    }
    return beta;
  }
}
```


== 搜索优化

#note[剪枝]

```cpp
// 伪代码
// 1.记忆化搜索
int ans=INF;
int dfs(int u){
  if(vis[u])return dp[u];vis[u]=true;//记忆化
  if(u==t)return dp[u]=base_case;// base_case
  for(auto v:e[u])// ...递归
  return dp[u];
}
// 2.最优性剪枝 (当前解不比答案好 )？？？
// 3.可行性剪枝 (当前解不可用 )
```
