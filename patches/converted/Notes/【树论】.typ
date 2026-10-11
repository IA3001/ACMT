==== #text("【树论】")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/Notes/【树论】.md`]

#quote(block: true)[
念经磨耳朵
]

===== 树论-结论

====== 重心

- 定义
  - 删去该点后最大连通块大小最小。最大子树大小 $lt.eq n / 2$；
- 性质：距离和最小点（可谓 #strong[树上中位数];）
  - 所有点到重心距离和最小；
- 性质：合并性
  - 两树合并重心在连接两树 #strong[重心的路径] 上。
- 求法
  - 见 #strong[点分治] 代码 写烂了

======= 补充

- 带权重心
  - 每个点有非负权值 $w_i$，求 $sum w_i dot.op d i s t \( u \, i \)$ 最小的点。
  - 权值非负时，带权重心满足：删去该点后，每个连通块的点权和都不超过总点权的一半；可通过子树权和定位。


====== 直径

- 性质：必有一个最远点（引申为 #strong[最小可达半径];）
  - 在非负边权树中，从任意点出发的一个最远点可以作为某条直径的端点。
- 性质：合并性
  - 两棵树合并，新直径端点必在原来两棵树直径的 4 个端点中产生。
- 求法
  - 非负权树：两次 DFS/BFS。
  - 带负权边：两次 DFS 不适用。令每个儿子方向的贡献为 `arm = w(u,v) + max(0, down[v])`，`down[u] = max(0, 所有 arm)`；用最大的一条 arm 和两条 arm 之和更新答案。若路径必须含边，答案初始化为 $- oo$，单点树需单独约定。


====== 中心

- 定义：（引申为 #strong[直径的中点];）
  - 到其他点最大距离最小的点。
  - 以下直径与中心结论默认树边权非负；负权边下距离不再是通常的度量，不能直接套用。
  - 一定在直径上。
- 性质：（神鬼二相性）
  - 无权树中，直径边数为偶数时中心是一个顶点；为奇数时中心为中间边的两个端点。
  - 带权树的中心是直径路径的中点；若中点落在边上，顶点中心取到该中点距离最小的顶点。
- 求法
  - 求出直径路径，取中点。（需要 check）
  - 树形 DP 求出每个点的最远距离 `max(dp[u][0], up[u])`，取最小值。


====== LCA

======= 两点 LCA 求法

- 纯 ST 表倍增 （人上人）
  - $O \( n log n \)$ 预处理
  - $O \( log n \)$ 查询
  - 优点
    - 可以维护动态加叶
- DFS序 / 欧拉序 + ST 表 （夯爆了）
  - $O \( n log n \)$ 预处理
  - $O \( 1 \)$ 查询
  - 缺点
    - 不能动态加叶
- Tarjan 离线 （NPC）
  - $O \( n + q \)$ 离线
  - 缺点
    - 并查集实现，仅限离线且查询已知的情况。
- 树链剖分 （夯爆了）
  - $O \( n \)$ 预处理
  - $O \( log n \)$ 查询
  - 优点
    - 常数极小，常与树剖的其他操作一并使用。
- LCT （人上人）
  - $O \( log n \)$ 查询
  - 优点
    - 可以指定 任意点 为 根
  - 缺点
    - 常数较大

======= 多点 LCA 求法

- 内容
  - $l c a \( v_1 \, dots.h \, v_k \) = l c a \( v_(m i n \_ d f n) \, v_(m a x \_ d f n) \)$。
  - 其实这个结论显然可以通过 Euler 序 / dfs 序 求 lca 推出
- 点集到 LCA 的距离和 （废话）
  - $sum_(i = 1)^k d i s t \( v_i \, l c a \) = sum d e p t h \[ v_i \] - k dot.op d e p t h \[ l c a \]$。
- 应用于 虚树
  - 利用多点 LCA 性质，关键点按 `tin` 排序后，相邻两点求 LCA 加入集合，即可在 $O \( k log k \)$ 内建成虚树。
- PS：
  - 服了，2026 东北四省赛 F 就是这个结论
  - 所以，初始化 $O \( n \)$ 建立平衡树，牛逼！！！


====== DFS 序

- #strong[定义];：节点第一次被访问的时间戳 $t i n \[ u \]$。
- #strong[子树区间];：子树在 DFS 序中对应连续区间 $\[ t i n \[ u \] \, t o u t \[ u \] \]$。
- #strong[大小关系];：$t i n \[ u \] + s z \[ u \] - 1 = t o u t \[ u \]$。
- #strong[祖先判定];：$u$ 是 $v$ 的祖先 $arrow.l.r.double t i n \[ u \] lt.eq t i n \[ v \] lt.eq t o u t \[ u \]$。
- #strong[LCA 性质];：$u$ 和 $v$ 的 LCA 是它们的公共祖先中#strong[深度最小的顶点];。
- #strong[应用];：
  - 不管上还是下，只要是 子树 / 链 就可以 树剖 + 线段树
    - （上 -\> 下）子树修改/查询：转化为区间操作（配合线段树/树状数组）。
    - （下 -\> 上）单点修改/查询（树上差分）：路径修改转化为单点修改，按 $t i n$ 逆序累加。
  - 虚树构建
    - 关键点按 $t i n$ 排序，单调栈维护右链。


====== Euler 序 / 括号序

- 定义
  - 进入节点和回溯节点均记录一次，序列长度为 $2 n - 1$。
- LCA 性质
  - $u$ 和 $v$ 的 LCA 是 Euler 序中 $u$ 和 $v$ 第一次出现位置之间深度最小的节点。
- 括号序性质 （废话）
  - 若在进入时标记 $+ 1$，回溯时标记 $- 1$，则前缀和为深度。
- 应用 （）
  - $O \( 1 \)$ LCA。
  - 树上莫队：
    - 将树上路径查询转化为序列区间查询
    - （注意特判 LCA 是否包含在内！！！）


====== Prufer 序列与 Cayley 公式

- Cayley 公式
  - $n$ 个节点的完全图生成树数量为 $n^(n - 2)$。
- Prufer 序列
  - 树与长度为 $n - 2$ 的序列双射。
- Prufer 性质
  - 节点 $i$ 出现次数等于 $d e g \( i \) - 1$。
- #strong[度限制] 生成树计数 （没见过唉）
  - $n gt.eq 2$ 且给定 $d_i gt.eq 1$、$sum_i d_i = 2 n - 2$ 时，方案数为 $frac(\( n - 2 \) !, product_(i = 1)^n \( d_i - 1 \) !)$；若条件不满足，方案数为 0。


====== 虚树 (Virtual Tree)

- 做法
  - 按 DFS 序排序，相邻点求 LCA 加入集合，单调栈维护右链连边。
  - 复杂度 $O \( k log k \)$。
- 性质
  - 关键点集大小为 $k$ 时，虚树总点数不超过 $2 k$。


====== 换根 DP

- 先以任意点为根，计算每个子树大小 `sz[u]`，并求根节点答案 `sum[root]`（到所有点的距离和）。

- 对父子边 $\( u \, v \)$，有 `sum[v] = sum[u] + n - 2 * sz[v]`；若边权为 $w$，则加项改为 $w \( n - 2 s z \[ v \] \)$。

- ===== 该式来自：跨过边 $\( u \, v \)$ 后，`sz[v]` 个点距离减少 $w$，其余点距离增加 $w$。
  <该式来自跨过边-uv-后szv-个点距离减少-w其余点距离增加-w>

====== 基环树

- 定义
  - $n$ 点 $n$ 条边的连通图。
- 套路
  - 拓扑排序 或 Tarjan 找环。
  - 断环成树
  - 对环上每个点的子树跑树形 DP
  - 最后在环上做环形 DP（或单调队列优化）。


====== 树上启发式合并 (DSU on Tree)

- 套路 （原来我真的不会啊）
  - #strong[前提];：一个节点作为轻儿子被遍历的次数 = 它向上跳轻边的次数。
  - #strong[然后呢？] 因为每次跳轻边，子树大小至少减半（重儿子是最大的儿子）。
  - #strong[结论];：任意节点最多被遍历 $O \( log n \)$ 次。所有节点加起来，总复杂度 $O \( n log n \)$。
  - #strong[所以];：我们才敢“暴力”把轻儿子子树合并到重儿子上，因为总共暴力遍历的次数只有 $O \( n log n \)$。
- 通法
  - 剖分 #strong[重儿子]
  - 递归 #strong[轻儿子] 计算答案 并 #strong[清除影响]
  - 递归 #strong[重儿子] 计算答案 并 #strong[保留影响]
  - 暴力合并 #strong[轻儿子子树] 至 #strong[重儿子]
- 看了这个说法，我怎么突然觉得：
  - 树上启发式，是 #strong[另一种形式的莫队] 啊
  - 你看嘛
    - 都是借助已有的计算基础，
    - 借助求解顺序的先后，
    - 回答下一个询问
  - 和 树上莫队 对比
    - 两者都利用遍历顺序复用已有状态，但维护对象和复杂度依赖具体题目，不能用这句类比推出复杂度。

#quote(block: true)[
居然，在算法竞赛圈，有一句著名的暴论：“莫队就是序列上的树上启发式，树上启发式就是树上的莫队。”
]

- 例题

  ```cpp
  // 未对拍，谨慎使用
  // 全局变量：cnt[x] 维护颜色 x 的出现次数，ans[u] 记录子树 u 的答案
  int cnt[N], ans[N], max_cnt;

  // 把 u 的子树全加进去 / 全删掉
  void add_subtree(int u, int fa, int val) {
      cnt[color[u]] += val;
      if (val == 1 && cnt[color[u]] > max_cnt) max_cnt = cnt[color[u]]; // 更新答案
      for (int v : g[u]) if (v != fa) add_subtree(v, u, val);
  }

  void dfs(int u, int fa, bool keep) {
      // 1. 递归轻儿子，清除影响
      for (int v : g[u]) 
          if (v != fa && v != son[u]) dfs(v, u, 0);

      // 2. 递归重儿子，保留影响
      if (son[u]) dfs(son[u], u, 1);

      // 3. 暴力合并轻儿子到重儿子
      for (int v : g[u]) 
          if (v != fa && v != son[u]) add_subtree(v, u, 1);

      // 把当前节点 u 自己加进去
      cnt[color[u]]++;
      if (cnt[color[u]] > max_cnt) max_cnt = cnt[color[u]];

      ans[u] = max_cnt; // 记录当前节点答案

      // 4. 如果是轻儿子，清除整棵子树的影响
      if (!keep) {
          add_subtree(u, fa, -1);
          max_cnt = 0; // 答案也要重置（具体看题目要求）
      }
  }
  ```


#quote(block: true)[
20261009 新增一批
]

====== 长链剖分（优化以深度为下标的 DP）

- 定义

  - 剖分时选择#strong[子树高度最大];的儿子作为重儿子（而不是子树大小最大的重儿子）。

- 性质

  - 任意节点向上跳轻边的次数为 $O \( sqrt(n) \)$，但#strong[总长链长度为 $O \( n \)$];。每条长链互不相交。

- 用法

  - 优化形如 `dp[u][dep]`（以深度为下标）的树形 DP。
  - 每条长链分配一段连续缓冲区；同一条链上的节点用不同偏移共享数组，$O \( 1 \)$ 继承重儿子的 DP。
  - 合并轻儿子时暴力合并。每条长链恰好作为一个轻儿子链被合并一次，扫描长度总和为 $O \( n \)$。

- 复杂度

  - 时间 $O \( n \)$，适用于每次轻链合并可按长链长度线性完成的深度 DP。
  - 空间 $O \( n \)$；每条长链只分配一段数组，所有长链长度之和为 $n$。

- #strong[与 DSU on Tree 对比];：

  - DSU 优化#strong[子树信息];（只关心子树整体，不关心深度）。
  - 长链剖分优化#strong[深度信息];（必须同时关心子树和深度下标）。

- #link("https://codeforces.com/problemset/problem/1009/F")[CF1009F Dominant Indices];：求每个子树中节点数最多的深度，平局取最小深度。

  ```cpp
  // 未对拍，谨慎使用
  #include <bits/stdc++.h>
  using namespace std;

  const int N = 1e6 + 5;

  int n;
  vector<int> g[N];
  int parent[N], son[N], len[N], ans[N];
  int buf[N], *dp[N];
  int base[N], top[N], offset[N];

  int main() {
      ios::sync_with_stdio(false);
      cin.tie(nullptr);
      cin >> n;
      for (int i = 1, u, v; i < n; i++) {
          cin >> u >> v;
          g[u].push_back(v);
          g[v].push_back(u);
      }

      // 迭代遍历得到父节点和先序；反向处理计算长儿子与长链长度。
      vector<int> Order{1};
      Order.reserve(n);
      for (int i = 0; i < n; i++) {
          int u = Order[i];
          for (int v : g[u]) if (v != parent[u]) {
              parent[v] = u;
              Order.push_back(v);
          }
      }
      for (int i = n - 1; i >= 0; i--) {
          int u = Order[i];
          len[u] = 1;
          for (int v : g[u]) if (parent[v] == u) {
              if (len[v] + 1 > len[u]) {
                  len[u] = len[v] + 1;
                  son[u] = v;
              }
          }
      }

      // 每条长链分配 len[链顶] 个格子，链上节点按深度偏移共享。
      int used = 0;
      base[1] = used;
      used += len[1];
      top[1] = 1;
      for (int u : Order) {
          for (int v : g[u]) if (parent[v] == u) {
              if (v == son[u]) {
                  top[v] = top[u];
                  offset[v] = offset[u] + 1;
              } else {
                  top[v] = v;
                  offset[v] = 0;
                  base[v] = used;
                  used += len[v];
              }
          }
      }
      for (int u : Order) dp[u] = buf + base[top[u]] + offset[u];

      // 反向先序即子节点先处理；重儿子数组由指针偏移继承。
      for (int i = n - 1; i >= 0; i--) {
          int u = Order[i];
          ans[u] = son[u] ? ans[son[u]] + 1 : 0;
          dp[u][0] = 1;
          for (int v : g[u]) {
              if (parent[v] != u || v == son[u]) continue;
              for (int d = 1; d <= len[v]; d++) {
                  dp[u][d] += dp[v][d - 1];
                  if (dp[u][d] > dp[u][ans[u]] ||
                      (dp[u][d] == dp[u][ans[u]] && d < ans[u]))
                      ans[u] = d;
              }
          }
          if (dp[u][0] >= dp[u][ans[u]]) ans[u] = 0;
      }

      for (int i = 1; i <= n; i++) cout << ans[i] << "\n";
      return 0;
  }
  ```

- 还能 $O \( 1 \)$ 求 k 级祖先！

  - #strong[结论];：长链剖分可以在 $O \( n log n \)$ 预处理后，$O \( 1 \)$ 查询任意节点的 $k$ 级祖先。
  - #strong[做法];：
    + 对每个点预处理二进制祖先表，并用长链剖分建立向下、向上的链数组。
    + 查询时先按 $k$ 的最高位跳 $2^i$ 步，剩余步数小于 $2^i$；再利用长链数组直接补完。
  - #strong[复杂度];：预处理 $O \( n log n \)$，查询 $O \( 1 \)$。

  ```cpp
  #include <bits/stdc++.h>
  using namespace std;

  const int N = 5e5 + 5;
  const int LOG = 20;

  int n, q;
  vector<int> g[N];
  int dep[N], fa[N][LOG], son[N], len[N], top[N];
  vector<int> chain[N];    // 长链向下节点
  vector<int> up_chain[N]; // 长链向上节点

  void init() {
  // 迭代遍历，避免 n 较大时递归栈溢出；反向序计算最长儿子链。
  vector<int> order{1};
  order.reserve(n);
  dep[1] = 1;
  for (int i = 0; i < (int)order.size(); ++i) {
      int u = order[i];
      for (int v : g[u]) if (v != fa[u][0]) {
          fa[v][0] = u;
          dep[v] = dep[u] + 1;
          for (int j = 1; j < LOG; ++j)
              fa[v][j] = fa[fa[v][j - 1]][j - 1];
          order.push_back(v);
      }
  }
  for (int i = n - 1; i >= 0; --i) {
      int u = order[i];
      len[u] = 1;
      for (int v : g[u]) if (fa[v][0] == u && len[v] + 1 > len[u]) {
          len[u] = len[v] + 1;
          son[u] = v;
      }
  }

  // 按父先子的顺序分配长链，并建立链顶向上的数组。
  for (int u : order) {
      if (!top[u]) {
          top[u] = u;
          for (int cur = u; cur; cur = son[cur]) chain[u].push_back(cur);
          int x = fa[u][0];
          for (int i = 0; i < len[u]; ++i) {
              up_chain[u].push_back(x);
              if (x) x = fa[x][0];
          }
      }
      for (int v : g[u])
          if (fa[v][0] == u && v == son[u]) top[v] = top[u];
  }
  }

  int query(int u, int k) {
      if (k < 0 || k >= dep[u]) return 0;
      if (k == 0) return u;
      int i = __lg(k);             // k 的最高位
      u = fa[u][i];
      k -= (1 << i);
      int t = top[u];
      int d = dep[u] - dep[t];
      if (k <= d) {
          return chain[t][d - k];
      } else {
          return up_chain[t][k - d - 1];
      }
  }

  int main() {
      ios::sync_with_stdio(false);
      cin.tie(nullptr);
      cin >> n;
      for (int i = 1, u, v; i < n; i++) {
          cin >> u >> v;
          g[u].push_back(v);
          g[v].push_back(u);
      }
      init();
      cin >> q;
      while (q--) {
          int u, k;
          cin >> u >> k;
          cout << query(u, k) << "\n";
      }
      return 0;
  }
  ```


====== 树哈希（树同构判定）

- #strong[无根树哈希（AHU 算法）];：
  - 找出树的重心（最多两个）。
  - 只有一个重心时，以它为根递归编码；有两个重心时，先删去两重心之间的边，分别编码两侧，再将两个编码排序后作为整棵树的规范编码。
  - 每个点把孩子的规范编号排序，并把两棵树产生的编号序列放进同一张映射表映射为新编号；比较最终规范编号即可得到严格同构判定。
  - 该编号实现复杂度为 $O \( n log n \)$。若直接递归复制并拼接完整括号字符串，链形树可能产生 $O \( n^2 \)$ 的字符复制，不能沿用此复杂度。
- #strong[有根树哈希（括号序列法）];：
  - 每个节点 $h_u = upright("hash") \( upright("concat") \( upright("sort") \( h_(v_1) \, dots.h \, h_(v_k) \) \) \)$。
  - 配合 `std::mt19937_64` 或 `splitmix64` 防止被卡。
  - 复杂度 $O \( n log n \)$。
- #strong[树哈希（随机权值法）];：
  - $h_u = xor.big_(v in s o n \( u \)) upright("splitmix64") \( h_v \)$（不排序）。
  - 该方法只能判同构的#strong[必要条件];（易冲突），但极度好写。配合双哈希可防 Hack。


====== Kruskal 重构树（瓶颈边问题降维打击）

- #strong[最大瓶颈路];：求两点路径上最小边权的最大值。对原图建最大生成森林后，若两点连通，答案是它们在重构树上的 LCA 权值。

- #strong[最小瓶颈路];：求两点路径上最大边权的最小值。对原图建最小生成森林后，若两点连通，答案是它们在重构树上的 LCA 权值。

- #strong[多源最大瓶颈路];：若每个源点 $s$ 有初始容量 $c_s$，添加超级源点，并连边 $\( S \, s \, c_s \)$；再对扩展图建最大生成森林，用 LCA 查询超级源到目标点的瓶颈值。

- ===== 不连通时，两点间不存在路径，应按题目定义单独处理。
  <不连通时两点间不存在路径应按题目定义单独处理>

====== 支配集 / 点覆盖 / 独立集

- #strong[最小点覆盖];：管的是#strong[边];。每条边至少有一个端点被选。
- #strong[最小支配集];：管的是#strong[点];。每个点要么被选，要么邻居被选。
- #strong[最大独立集];：管的是#strong[点与点的关系];。选中的点两两不相邻。

#figure(
  align(center)[#table(
    columns: (33.33%, 33.33%, 33.33%),
    align: (left,left,left,),
    table.header([问题], [状态含义], [转移关键],),
    table.hline(),
    [#strong[最小点覆盖];], [`dp[u][0]`: u 不选；`dp[u][1]`: u 选], [u 不选 → 所有儿子必须选；u 选 → 儿子可选可不选],
    [#strong[最小支配集];], [`dp[u][0]`: u 被选；`dp[u][1]`: u 不选但被儿子支配；`dp[u][2]`: u 不选被父亲支配], [u 被选 → 儿子可任意状态；u 被儿子支配 → 至少一个儿子选；u 被父亲支配 → 儿子不能被父亲支配],
    [#strong[最大独立集];], [`dp[u][0]`: u 不选；`dp[u][1]`: u 选], [u 选 → 所有儿子不能选；u 不选 → 儿子可选可不选],
  )]
  , kind: table
  )

- 二分图
  - #strong[最小点覆盖 = 最大匹配];（Kőnig 定理）。
- 任意图
  - #strong[最大独立集 = 总点数 - 最小点覆盖];（互补关系）。
- 支配集没有这种简单的互补关系，通常单独用树形 DP 求。


====== 树上博弈（删边游戏 Green Hackenbush）

- （牛逼，这不是蓝桥杯吗）
- 规则
  - 每次删去一条边，不与根节点相连的部分被移除。
- SG 值
  - $S G \( u \) = xor.big_(v in s o n \( u \)) \( S G \( v \) + 1 \)$。


====== 树上最大匹配（贪心）

#quote(block: true)[
这个海星，给了个快速求解
]

- #strong[结论];：树上最大匹配可以用贪心 $O \( n \)$ 求解。

- #strong[做法];：DFS 后序遍历。若当前节点 $u$ 未匹配，且存在一个未匹配的儿子 $v$，则匹配 $\( u \, v \)$。

- #strong[本质];：叶子节点优先匹配，越晚匹配越亏。

- #strong[代码骨架];：

  ```cpp
  int match(int u, int fa) {
      int cnt = 0; // 已匹配的儿子数
      for (int v : g[u]) {
          if (v == fa) continue;
          if (match(v, u)) cnt++;
      }
      if (cnt > 0) return 0; // u 被匹配
      return 1;              // u 未匹配
  }
  ```


====== 树上最小路径覆盖（两种定义，别搞混！）

======= 定义一：用最少的点不相交路径覆盖所有顶点

- 路径可以是单点，任意两条路径不能共用顶点。
- 选择树边组成一个覆盖所有顶点的子图，并要求每个顶点度数不超过 2；由于原图是树，所选子图自然是若干条路径。
- 若最多能选出 $e$ 条这样的边，最少路径数为 $n - e$。这不是 $n -$最大匹配数；例如一条 $n$ 个点的链只需 1 条路径。
- 可用树形 DP 求最大度数不超过 2 的边子集：分别记录父边未选/已选时，当前点最多还能选 2/1 条儿子边。

======= 定义二：用最少的路径覆盖所有边，路径可以共用顶点

- 对含至少 2 个点的树，最少路径数为 $ceil.l L \/ 2 ceil.r$，其中 $L$ 是叶子数。
- 每条路径至多有两个叶子端点，故至少需要 $ceil.l L \/ 2 ceil.r$ 条；将叶子配对即可达到下界。

======= 一句话总结

- 覆盖顶点且路径互不相交：最大化度数不超过 2 的所选边数，再用 $n - e$。
- 覆盖边且路径可共用顶点：$ceil.l L \/ 2 ceil.r$。


====== 树的拓扑序计数

#quote(block: true)[
可以，本质堆计数
]

- #strong[结论];：有根树（父先于子）的拓扑序数量 = $frac(n !, product_(u = 1)^n s z \[ u \])$。
- #strong[直观理解];：$n$ 个节点的全排列有 $n !$ 种，但对每个节点 $u$，它的子树内部必须满足父先于子，子树内部的相对顺序固定了 $s z \[ u \]$ 种排列之一。
- #strong[应用];：树形结构的随机生成、排列计数。


====== 树上路径交 / 路径并

#quote(block: true)[
这个挺不错的 交 与 并
]

- #strong[两条路径 $\( a \, b \)$ 与 $\( c \, d \)$ 的交];：
  - 交为空 $arrow.l.r.double$ $l c a \( a \, b \)$ 不在路径 $\( c \, d \)$ 上 #strong[且] $l c a \( c \, d \)$ 不在路径 $\( a \, b \)$ 上。
  - 若相交，交点中深度最大的点为 $max_(x in { l c a \( a \, c \) \, l c a \( a \, d \) \, l c a \( b \, c \) \, l c a \( b \, d \) }) d e p \[ x \]$。
- #strong[多条路径的并];：
  - 用虚树解决。将路径端点加入关键点集，建虚树，在虚树上做标记和统计。


====== 树上背包的复杂度

#quote(block: true)[
这个挺神秘的
]

- #strong[结论];：朴素树上背包是 $O \( n^2 \)$，不是 $O \( n^3 \)$。
- #strong[证明];：合并两个子树时，代价为 $min \( s z \[ u \] \, K \) times min \( s z \[ v \] \, K \)$，总复杂度为 $O \( n K \)$。
- #strong[优化];：若容量上限 $K$ 很小，复杂度为 $O \( n K \)$。若 $K = n$，则为 $O \( n^2 \)$。


====== 树的完美匹配判定

- 对树做后序遍历：若节点 $u$ 尚未匹配，且有尚未匹配的儿子，就任选一个儿子与 $u$ 匹配。
- 这是树上最大匹配的贪心；全部处理后，只有所有顶点都已匹配时才存在完美匹配。
- 树若有完美匹配，则该匹配唯一；可由叶子反复匹配其唯一邻点来理解。


====== 树的连通块计数（DP）

#quote(block: true)[
背包方案数
]

- #strong[问题];：求树上大小为 $k$ 的连通块数量。
- #strong[DP];：`dp[u][j]` 表示以 $u$ 为根的子树中，包含 $u$ 且大小为 $j$ 的连通块数。
- #strong[转移];：合并儿子时，$d p \[ u \] \[ i + j \] + = d p \[ u \] \[ i \] times d p \[ v \] \[ j \]$。
- #strong[复杂度];：$O \( n^2 \)$。
- #strong[应用];：树形结构计数、随机生成。


====== 树的重心计数

- 重心最多两个；若有两个，它们相邻。
- 统计每个点删除后最大连通块大小是否不超过 $n \/ 2$，即可计数，复杂度 $O \( n \)$。


====== 树上的 LIS（最长递增子序列）

- #strong[问题];：对每个节点 $u$，求根到 $u$ 的点权序列的严格 LIS 长度。
- #strong[做法];：DFS 时用 `tails` 维护当前根路径的 LIS 状态；访问节点时用 `lower_bound` 替换对应位置，回溯时恢复被覆盖的值。
- 不能只比较 $a \[ u \]$ 与父节点的值；LIS 转移依赖整条路径的维护状态。

```cpp
// 可撤销版；进入前保证 tails[1..len] 是严格递增序列。
void dfs(int u, int fa) {
    int pos = lower_bound(tails + 1, tails + len + 1, a[u]) - tails;
    int old = tails[pos];
    int old_len = len;
    tails[pos] = a[u];
    if (pos > len) len = pos;
    ans[u] = len;
    for (int v : g[u]) if (v != fa) dfs(v, u);
    tails[pos] = old;
    len = old_len;
}
```


====== 树的带权最大匹配

- `dp0[u]`：$u$ 不与儿子匹配时，$u$ 子树内的最大匹配权值。
- `dp1[u]`：$u$ 必须与一个儿子匹配时，$u$ 子树内的最大匹配权值；没有儿子时为 $- oo$。
- 令 `base = Σ max(dp0[v], dp1[v])`。则 `dp0[u] = base`。
- 若 $u$ 与儿子 $v$ 匹配，候选值为 `base - max(dp0[v], dp1[v]) + dp0[v] + w(u,v)`；对所有儿子取最大值得到 `dp1[u]`。
- 根的答案为 `max(dp0[root], dp1[root])`，复杂度 $O \( n \)$。


====== 次小生成树

- LCT 啊
  - 枚举非树边加入形成环，删去环上最大边，取最小值。

