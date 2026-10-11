=== #text("VP：Autumn（6）国庆5")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/VP/Autumn（6）.md`]

===== F. Top Cluster 【做法诈骗 - 树的直径合并 - 边分树（假）】

- n 个点 带边权的树
- 每一个点都有点权，点权唯一（突破口）
- 有 q 次询问
- 问距离 x 点不超过 k 的所有点权的 mex 是多少

====== Code1（MLE 做法：边分树）

```cpp
/*
 * 动态边分治探索笔记：树上距离球内的 mex
 *
 * 这份代码保留原始探索版本的算法与写法，评注用于解释结构之间的关系；
 * 它不是经过最终内存优化的 AC 版本。尤其是 SegT 节点池 no：每个点会在
 * 多层边分治中重复加入，每次加入还会沿值域线段树新建路径，峰值可能很大。
 * 保存代码时请把“结构探索成功”和“题目限制下通过”分开记录。
 *
 * 整体分层：
 * 1. 原树 hd0：输入的带权树。
 * 2. 三度化重构树 hd：把高点度数拆成若干零权辅助边，保留原树距离，
 *    让后续边分治更容易得到平衡切边。
 * 3. 边分信息树：每个节点对应一次被切开的边；左右子树对应切开后两侧
 *    继续递归得到的子问题。它是“切分事件”的树，不是原树顶点树。
 * 4. 边分链 ch/t/rt：记录原始点在相关分治边界上的左右决策路径，供查询
 *    把当前点定位到每层分治的哪一侧。
 * 5. rt2 与 no：每个切分节点两侧挂一棵按点权组织的动态线段树，保存
 *    到对应侧端点的距离信息，查询时和剩余距离限制配合统计 mex。
 *
 * 重要不变量：
 * - add_edge 每条无向边写两条有向邻接记录，编号从 2 开始；所以 i^1 是反向边，
 *   i>>1 是该无向边的访问标记编号。这里依赖 cntE 初始为 1。
 * - vis 标记的是已经从分治森林中删掉的边；子问题遍历时跳过 vis 边。
 * - 重构树新增边权为 0，因此原始点之间的距离不变；辅助点编号大于 n。
 * - 边分信息节点编号 i 与切边一一对应，最多约 n-1 个。
 * - 权值 mex 只需考虑 [0,n]；w[u]>=n 的点不影响 mex，但仍属于树和距离结构。
 */
#include<bits/stdc++.h>
using namespace std;
#define ll long long

const int N = 5e5 + 5;

int n, m, q;
int w[N]; // 开多大？ 只有 N

struct Edge {
    int to,nxt, w;
}e[N*6]; // 开多大？ 一个原始树，一个重构树！ N*2 + N*2*2 = N*6 

// 三度化重构树节点编号
int cntn;

// 原始树, 三度化重构树
// 开多大？ 原始 N 重构 N*2
int hd0[N], hd[N*2], cntE;

ll h[N*2];

int top[N*2], dfn[N*2], dfncnt, son[N*2], sz[N*2], fa[N*2], dep[N*2];

// 对三度化重构树做重链剖分预处理：h 是根距离，fa/dep/ top 支持 LCA。
// 注意后续 dist 的参数必须是重构树中的有效节点编号；原始点当然有效。
void dfs1(int u,int f) {
    sz[u] = 1;
    fa[u] = f;
    dep[u] = dep[f] + 1;
    son[u] = 0;
    for (int i = hd[u];i;i=e[i].nxt) {
        int v = e[i].to;
        if (v == f) continue;
        h[v] = h[u] + e[i].w;
        dfs1(v, u);
        sz[u] += sz[v];
        if (sz[v] > sz[son[u]]) {
            son[u] = v;
        }
    }
}

void dfs2(int u,int tp) {
    dfn[u] = ++dfncnt;
    top[u] = tp;
    if(son[u]) dfs2(son[u], tp);
    for (int i = hd[u];i;i=e[i].nxt) {
        int v = e[i].to;
        if (v!=son[u] && v!=fa[u]) dfs2(v, v);
    }
}

int lca(int a,int b) {
    while(top[a] != top[b]) {
        if (dep[top[a]] < dep[top[b]]) swap(a, b);
        a = fa[top[a]];
    }
    return dep[a] < dep[b] ? a : b;
}

ll dist(int a,int b) {
    int c = lca(a, b);
    return h[a] + h[b] - h[c] * 2;
}

// 【初始化】
// 单组数据初始化。先清空上一轮实际用过的邻接表范围，再重置边编号。
// fill(hd, ... cntn) 必须在 cntn 重置为 n 之前执行，否则旧辅助点邻接表残留。
void init() {
    dfncnt = 0;
    fill(hd0,hd0+1+n,0);
    // 【chovy!!!】 这里啊，太容易错了
    // 清空掉之前的 cntn 啊，要不然少 清理 WA 了
    fill(hd,hd+1+cntn,0);
    cntE = 1;
    cntn = n;
}

// 【无向边】
void add_edge(int hd[],int u,int v,int w) {
    e[++cntE] = {v, hd[u], w}; hd[u] = cntE;
    e[++cntE] = {u, hd[v], w}; hd[v] = cntE;
}

// 动态边分治
namespace EDC {
    // 边分治 边号 访问记录
    bool vis[N*3]; // 开多大 ？e 的一半 N*3
    // 求解重心
    int sz[N*2]; // 开多大 ？ 重构树大小 N*2
    
    // 【三度化重构】
    // 原树某点可能有很多孩子。第一个孩子直接连原点，之后每个孩子
    // 通过新建的辅助点串接；辅助边权为 0，原边权放在辅助点到孩子的边上。
    // 这样展开后节点度数有界，同时不改变任意两个原始点之间的距离。
    void rebuild(int u,int fa) {
        int lst = 0; // 上一个接入点
        for (int i = hd0[u]; i ; i = e[i].nxt) {
            int v = e[i].to;
            if (v!=fa) {
                if (!lst) {
                    // 没有接入点，说明 u 有两个接入点
                    add_edge(hd,u,v,e[i].w);
                    // 接入点变成 u
                    lst = u;
                } else {
                    // 新建接入点
                    ++cntn;
                    // 连接接入点
                    add_edge(hd,lst,cntn,0);
                    // 接入点连接 v
                    add_edge(hd,cntn,v,e[i].w);
                    // 上一个变成接入点
                    lst = cntn;
                }
                rebuild(v, u);
            }
        }
    }

    // 【获取子树大小】
    // 在当前尚未被 vis 删除的连通分量里，以 u 为根计算子树大小。
    // 这里的 fa 是 DFS 父亲，不是全局 fa[]。
    void get_size(int u,int fa) {
        // 1
        sz[u] = 1;
        for (int i = hd[u]; i; i = e[i].nxt) {
            int v = e[i].to;
            // 有效的的非反向边
            if (!vis[i>>1] && v != fa) {
                get_size(v, u);
                sz[u] += sz[v];
            }
        }
    }

    // 【获取重心边】
    // 先在当前连通分量中找顶点重心，再从重心 incident 的有效边里
    // 选出把分量切成两部分后最大一侧尽量小的边。返回的是有向邻接编号 edg。
    int get_cent(int u) {
        // 先获取大小
        get_size(u, 0);
        int n = sz[u], fa = 0;
        bool f ;
        do {
            f = false;
            // 寻找重心
            for (int i = hd[u];i;i=e[i].nxt) {
                int v = e[i].to;
                // 有效边 并且 非父亲 并且 更大
                if (!vis[i>>1] && v != fa && sz[v] > n / 2) {
                    fa = u; // 父亲 变成当前
                    u = v; // 当前 变成儿子
                    f = true; // 找到了
                    break;
                }
            }
        } while (f);
        int best = 0, edg = 0;
        for (int i = hd[u];i;i=e[i].nxt) {
            int v = e[i].to;
            // 有效边
            if (!vis[i >> 1]) {
                // 根据关系计算子树大小
                int tmp = v == fa ? n - sz[v] : sz[v];
                if (tmp > best) {
                    best = tmp;
                    edg = i;
                }
            }
        }
        return edg;
    }

    // 动态开点的值域线段树节点。
    // sum：该值域内插入的点数；mx：插入点对应距离的最大值。
    // 查询中通过 sum 检查值域是否齐全，通过 mx 检查对应点是否都在距离阈值内。
    struct SegT {
        int lc, rc;
        int sum;
        ll mx;
    }; // 开多大 ？ 双 log 吧, 因为 一个是 分治 log 一个是线段树 log

    vector<SegT> no;

    // lc rc sum mx
#define lc(x) no[x].lc
#define rc(x) no[x].rc
#define sum(x) no[x].sum
#define mx(x) no[x].mx

    // 线段树节点编号
    int tot;

    // 下标 0 作为空节点哨兵；vector 初始元素需为全零，便于空孩子访问。
    int new_node() {
        no.push_back(SegT());
        return ++tot;
    }

    // 从 i 点插入权值 val 大小 len 的点
    int insert(int i,int l,int r,int val,ll len) {
        if (!i) i = new_node(); // 空点新建

        // 加加
        sum(i)++;
        // 取最大值
        mx(i) = max(mx(i), len);

        // l == r 返回
        if (l == r) return i;

        // 递归下去
        int mid = (l + r) / 2;
        if (val <= mid) lc(i) = insert(lc(i), l,mid,val,len); // 左边
        else rc(i) = insert(rc(i), mid+1,r,val,len); // 右边

        // 返回节点
        return i;
    }

#undef lc(x)
#undef rc(x)
#undef sum(x)
#undef mx(x)

    // ===============================================

    // 每一个原始节点对应的 [边分链] 根 / 底。rt[u] 是链起点，t[u] 是目前追加到的末端。
    int rt[N], t[N]; // 开多大 ? 原始节点 那么 其实开 N 就可以
    int tot1; // 边分链 节点编号
    // [边分链] 信息
    array<int,2> ch[N*19]; // 左右 链孩子 // 开多大？ 链是 log 长度所以 20 够了
    
    // ===============================================

    // 每一个 [边分端点] 到对应 原始节点的真实距离
    // vector<pair<int,ll>> dis[N*2]; // 开多大 ? 边分端点 其实 就是 N*2 个
    
    // ===============================================

    // [边分信息树] 根：一次切边创建一个信息节点，左右递归结果挂在它下面。
    int root2;
    int tot2; // 边分信息树 节点编号
    // [边分信息树] 的信息
    // 开多大？ 一个节点就是代表一个边啊 所以 N*2 没毛病
    array<int,2> ch2[N*2]; // 左右 边分信息孩子 
    array<int,2> vh2[N*2]; // 这条边 的 左右 [边分端点]
    array<int,2> rt2[N*2]; // 这条边 的 左右 [线段树]

    // ===============================================

    // 收集 [边分端点] 到对应 原始节点 的 真实距离
    void dfs(int u,int fa,ll len, int op,int up,int id) {
        // 找到真实节点
        if (u <= n) {
            // cout << "dfs: " << u << " " << fa << ": " << up << "\n";
            
            // 标注距离
            // dis[up].push_back({u, len});

            if (w[u] < n)
                rt2[id][op] = insert(rt2[id][op], 0, n, w[u], len);
            
            // 拓展 [边分链] 底 
            if (!t[u]) t[u] = rt[u] = ++tot1; // 链根 单独存
            
            // 这是 新链底
            ++tot1;
            ch[t[u]][op] = tot1;
            t[u] = tot1;
        }

        // 递归收集信息
        for (int i = hd[u];i;i=e[i].nxt) {
            int v = e[i].to;
            // 【chovy!!!!】 我怎么少写了 >> 1 ???
            // 有效边并且 非父亲
            if (!vis[i >> 1] && v!=fa) {
                dfs(v, u, len+e[i].w, op, up, id);
            }
        }
    }

    // 边分治建树：切掉当前分量的一条平衡边，记录两侧端点，
    // 分别收集两侧信息，再递归建立左右子问题。
    int edc(int u) {
        // cout << "edc: " << u  << "\n";

        // 获取重心边
        int edg = get_cent(u);
        if (!edg) return 0;
        
        // 访问！
        vis[edg>>1] = true;

        int v1 = e[edg].to, v2 = e[edg^1].to;

        // 【chovy!!!】 看到这里 我突然发现我 想复杂了!!! 直接就可以收集信息了啊
        // 创建边分信息节点
        int i = ++tot2;
        vh2[i][0] = v1; // 左 边分端点
        vh2[i][1] = v2; // 右 边分端点

        dfs(v1,0,0,0,v1,i);
        dfs(v2,0,0,1,v2,i);

        // sort(dis[v1].begin(), dis[v1].end());
        // sort(dis[v2].begin(), dis[v2].end());
        
        ch2[i][0] =  edc(v1); // 左 边分信息
        ch2[i][1] =  edc(v2); // 右 边分信息
        
        return i;
    }

    // ==========================================
    // 
    // 我们现在来分析以下 [边分信息树] 与 [边分链] 的有效信息范围
    // [边分信息树]: 一个节点代表一条边 所以很好理解
    // [边分链]: 一个节点不代表什么, 真正有信息的, 只是 左/右 孩子的有无
    //          因此，最底层的节点不含有任何信息，只有所有的父节点才拥有信息 左/右
    // 
    // 当进行 add / collect 操作的时候
    // x(无要求) y(有孩子) 分别对应了 : 
    //  [分析的边] vs [对应点的决策方向]
    // [y 决策方向的 左/右] 对应了 [x 对应的方向信息]
    // 
    // ==========================================

    // [整体二分] [线段树] 节点 编号
    // {id, len}
    pair<int,ll> buf[100]; // 开多大 ？ 撑死 log 个
    int idx;

    // 对查询点在边分信息树上的路径逐层收集“对侧区域”的线段树根和剩余距离。
    // x 是当前边分信息节点，y 是查询点对应的边分链位置，no 是原始查询点。
    // 依然是 y 的一个决策方向 <-> x 的一个方向信息线段树
    void collect(int x,int y, int no,ll len) {
        if (!y || y == t[no]) return;
        int d = ch[y][1] > 0;
        
        // 话说 可以直接令 
        // if (y == t[no]) return; 不就完了？？ 
        // 卧槽！！！
        
        // 计算另一个方向 d^1 如果要到达 no 节点,
        // 支持的范围 l0
        // = 总长度 - 到 d 方向端点 的距离 - 跨过这条边所需要的代价 
        // ll tmp = len - (lower_bound(dis[vh2[x][d]].begin(), dis[vh2[x][d]].end(), pair{no,-1ll}))->second - w2[x];
        ll tmp = len - dist(vh2[x][d^1], no);
        
        // 必须要求 >= 0
        if (tmp >= 0) {
            // 添加 对侧方向的查询树根 {id, l}
            buf[++idx] = {rt2[x][d^1], tmp};
        }
        
        // 递归收集
        collect(ch2[x][d], ch[y][d], no, len);
    }

    // 在值域 [l,r] 上二分 mex。每轮检查左半值域是否完整，且相关区域内的
    // 权值点是否都满足距离限制；若左半完整且全部可达，mex 必在右半。
    // 二分定义: 
    // 已知 答案 一定在 [l, r] 范围内
    // 所以，你只需要确定 [l, mid] 是否存在答案！！！
    int cal(int nod, int l,int r) {
        // l == r 根本不需要再算了
        if (l == r) {
            return l;
        } else {
            // 二分答案
            int mid = (l + r) / 2;

            // 千万注意， 这里， 一定要加上 这一条
            // 因为在 [边分信息树] collect 的时候
            // 没有一次 是包含 nod 点本身的 当你查询到的 mid 包含 w[nod]
            // 的时候，一定要带上 
            // 而至于 l 的限制 天然为 true
            int S = (l <= w[nod] && w[nod] <= mid); // 验证 总和是否齐全
            
            bool ok = true; // 验证是否均在涉及范围内
            
            // 计算
            for (int i = 1; i <= idx; i++) {
                auto [root, len] = buf[i];
                // 【chovy!!!】 二分的指标是 左孩子！！！！
                if (root) {
                    S += no[no[root].lc].sum;
                    ok &= no[no[root].lc].mx <= len;
                }
            }
            
            // 【chovy!!!】 验证的答案是 mid - l + 1 !!!!!
            // 如果满足条件 那么答案可以更大 必然是 [mid + 1, r] 
            // 反之就是答案在 [l, mid] 范围内
            // cout << S << "! vs " << l << " " << mid << " " << ok << "\n";
            if (S == mid - l + 1 && ok) {
                // 【chovy!!!】 忘了更新 lc rc 了
                for (int i = 1; i <= idx; i++) {
                    if (buf[i].first) // 注意判断非 0 啊
                        buf[i].first = no[buf[i].first].rc;
                }
                return cal(nod, mid + 1, r);
            } else {
                // 【chovy!!!】 忘了更新 lc rc 了
                for (int i = 1; i <= idx; i++) {
                    if (buf[i].first) // 注意判断非 0 啊
                        buf[i].first = no[buf[i].first].lc;
                }
                return cal(nod, l, mid);
            }
        }
    }

    // 单次业务查询：先收集所有与 x 对应的对侧区域，再沿值域线段树二分 mex。
    // 查询距离 u 不超过 len 的所有节点的 mex
    int query(int u,ll len) {
        idx = 0;
        collect(root2, rt[u], u, len);
        return cal(u, 0, n);
    }
}

inline void solve() {

    // 【chovy!!!】 tot tot1 tot2 也要清空！
    EDC::no.resize(1);
    EDC::tot = EDC::tot1 = EDC::tot2 = 0;

    cin >> n >> q;

    // 【chovy!!!】 n == 1 的时候 根本没有边 只能特判了 !!!!
    if (n == 1) {
        cin >> w[1];
        int ans = w[1] == 0 ? 1 : 0;
        while(q--) {
            int x;
            ll k;
            cin >> x >> k;
            cout << ans << "\n";
        }
        return;
    }

    // 初始化 两个树
    init();

    // 输入1
    for (int i = 1; i <= n; i++) cin >> w[i];
    
    // 输入2
    for (int i = 1; i < n; i++) {
        int u, v, w;
        cin >> u >> v >> w;
        add_edge(hd0, u, v, w);
    }

    // 【重构树】
    EDC::rebuild(1, 0);

    // 在重构树上预处理 HLD/LCA 距离结构。零权辅助边保证原始树距离不变。
    dfs1(1, 0);
    dfs2(1, 1);
    
    // 【边分信息树】（空的骨架）
    EDC::root2 = EDC::edc(1);

    // 回答询问
    for (int i = 1; i <= q; i++) {
        int x;
        ll k;
        cin >> x >> k;
        cout << EDC::query(x, k) << "\n";
    }
}

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    int T=1;
    // cin>>T;
    while (T--) solve();
}
```

====== Code2 （正解： 树的直径合并 + 二分答案）

```cpp

#include<bits/stdc++.h>
using namespace std;
#define ll long long

const int N = 5e5 + 5;

int n, m, q;
int w[N];

struct Edge {
    int to,nxt, w;
}e[N*2]; 

int hd[N], cntE;

// 【无向边】
void add_edge(int u,int v,int w) {
    e[++cntE] = {v, hd[u], w}; hd[u] = cntE;
    e[++cntE] = {u, hd[v], w}; hd[v] = cntE;
}

ll h[N];

int top[N], dfn[N], dfncnt, son[N], sz[N], fa[N], dep[N];

void dfs1(int u,int f) {
    sz[u] = 1;
    fa[u] = f;
    dep[u] = dep[f] + 1;
    son[u] = 0;
    for (int i = hd[u];i;i=e[i].nxt) {
        int v = e[i].to;
        if (v == f) continue;
        h[v] = h[u] + e[i].w;
        dfs1(v, u);
        sz[u] += sz[v];
        if (sz[v] > sz[son[u]]) {
            son[u] = v;
        }
    }
}

void dfs2(int u,int tp) {
    dfn[u] = ++dfncnt;
    top[u] = tp;
    if(son[u]) dfs2(son[u], tp);
    for (int i = hd[u];i;i=e[i].nxt) {
        int v = e[i].to;
        if (v!=son[u] && v!=fa[u]) dfs2(v, v);
    }
}

int lca(int a,int b) {
    while(top[a] != top[b]) {
        if (dep[top[a]] < dep[top[b]]) swap(a, b);
        a = fa[top[a]];
    }
    return dep[a] < dep[b] ? a : b;
}

ll dist(int a,int b) {
    int c = lca(a, b);
    return h[a] + h[b] - h[c] * 2;
}

// 【初始化】
void init() {
    fill(hd,hd+1+n,0);
    dfncnt = 0;
    cntE = 1;
}

int pos[N];
array<int,2> D[N];

inline void solve() {

    init();
    fill(pos,pos+1+n,0);
    fill(D,D+1+n,array{0,0});

    cin >> n >> q;

    for (int i = 1; i <= n; i++) {
        cin >> w[i];
        if (w[i] <= n) {
            pos[w[i]] = i;
        }
    }

    for (int i = 1; i < n; i++) {
        int u, v, w;
        cin >> u >> v >> w;
        add_edge(u, v, w);
    }

    // !!!
    dfs1(1, 0);
    dfs2(1, 1);

    D[0] = {pos[0], pos[0]};
    for (int i = 1; i <= n; i++) {
        auto [a,b] = D[i-1];
        if (!a || !pos[i]) break;
        int c = pos[i];
        ll ac = dist(a,c);
        ll bc = dist(b,c);
        ll ab = dist(a,b);
        if (ac >= max(bc,ab)) {
            D[i] = {a, c};
        } else if (bc >= max(ac, ab)) {
            D[i] = {b, c};
        } else {
            D[i] = {a, b};
        }
    }

    // 回答询问
    for (int i = 1; i <= q; i++) {
        int x;
        ll k;
        cin >> x >> k;
        int res = -1;
        int l = 0, r = n;
        while (l <= r) {
            int mid = (l + r) / 2;
            auto [a, b] = D[mid];
            if (a && b && max(dist(x, a), dist(x, b)) <= k) {
                res = mid;
                l = mid + 1;
            } else {
                r = mid - 1;
            }
        }
        cout << res + 1 << "\n";
    }
}

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    int T=1;
    // cin>>T;
    while (T--) solve();
}
```

===== 

