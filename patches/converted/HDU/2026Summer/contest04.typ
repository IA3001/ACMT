=== #text("2026“钉耙编程”中国大学生算法设计暑期联赛（04）")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/HDU/2026Summer/contest04.md`]

===== 1001 Signal 【Minmax 容斥 / 半平面交求凸包交 / "clip 动态维护凸包半平面交" / “继承性 dfs”】

====== Problem Description

A 国和 B 国正在交战，战场是平面内的一个凸多边形 $P$。A 国的通信系统由 $n$ 个频道组成。频道 $i$ 由平面内两个不同的点 $A_i \, B_i$ 确定，其单位面积使用费用为 $w_i$。

战场内一点 $p$ 能接收到频道 $i$ 的信号，当且仅当

$ accent(A_i B_i, ⃗) times accent(A_i p, ⃗) gt.eq 0 \, $

即 $p$ 位于有向直线 $A_i B_i$ 的左侧或直线上。

一次通信会恰好开启集合 $S$ 中的所有频道。对于每个位置 $p$，收集所有满足

$ i in S \, quad accent(A_i B_i, ⃗) times accent(A_i p, ⃗) gt.eq 0 $

的费用 $w_i$，并将它们从大到小排列。若其中至少有 $k$ 个数，则 $f_(S \, k) \( p \)$ 是第 $k$ 个数；否则定义 $f_(S \, k) \( p \) = 0$。相同费用的不同频道需要分别计数。

A 国领导人想知道这次通信在整个战场上的总费用，即

$ "Ans" \( S \, k \) = integral_(p in P) f_(S \, k) \( p \) thin upright(d) A . $

现在有 $q$ 次相互独立的询问。每次询问给出集合 $S$ 和整数 $k$，求出对应的 $"Ans" \( S \, k \)$。

====== Input

输入包含多组测试数据。第一行包含一个整数 $T$，表示测试数据组数。

对于每组测试数据：

第一行包含三个整数 $n \, m \, q$；

接下来 $m$ 行，第 $i$ 行包含两个整数 $x_i \, y_i$，表示凸多边形的第 $i$ 个顶点。顶点按照逆时针顺序给出；

接下来 $n$ 行，第 $i$ 行包含五个整数 $x_(i \, 1) \, y_(i \, 1) \, x_(i \, 2) \, y_(i \, 2) \, w_i$，表示 $A_i = \( x_(i \, 1) \, y_(i \, 1) \)$、$B_i = \( x_(i \, 2) \, y_(i \, 2) \)$ 以及频道 $i$ 的单位面积使用费用；

接下来 $q$ 行，每行包含两个整数 $s \, k$，表示一次询问。集合 $S$ 使用十进制整数 $s$ 编码：频道 $i$ 属于 $S$，当且仅当 $s$ 的第 $i - 1$ 个二进制位为 $1$。允许 $k > \| S \|$，此时答案为 $0$。

====== Output

对于每次询问，输出一行一个实数，表示对应通信的总费用。

设你的输出为 $x$，标准答案为 $y$。若 $\| x - y \| lt.eq 10^(- 5)$ 或 $frac(\| x - y \|, \| y \|) lt.eq 10^(- 5)$，则视为正确。

====== Sample Input

```txt
1
2 4 6
0 0
4 0
4 4
0 4
2 0 2 4 3
0 2 4 2 5
3 1
3 2
1 1
2 1
0 1
1 2
```

====== Sample Output

```txt
52.0000000000
12.0000000000
24.0000000000
40.0000000000
0.0000000000
0.0000000000
```

====== Hint

#strong[样例解释]

频道 $1$ 可以在 $x lt.eq 2$ 的位置使用，频道 $2$ 可以在 $y gt.eq 2$ 的位置使用，单位面积使用费用分别为 $3$ 和 $5$。

对于第一组询问，$s = 3$，两个频道均被开启，且 $k = 1$。正方形左上、左下、右上三个面积均为 $4$ 的区域所取最大费用依次为 $5 \, 3 \, 5$，所以答案为

$ 4 times 5 + 4 times 3 + 4 times 5 = 52 . $

第二组询问的 $k = 2$。只有左上区域能同时接收到两个频道，其中第二大费用为 $3$，因此答案为

$ 4 times 3 = 12 . $

#strong[数据范围]

- $1 lt.eq T lt.eq 5$；
- $1 lt.eq n lt.eq 18$；
- $3 lt.eq m lt.eq 30$；
- $1 lt.eq q lt.eq 2 times 10^5$；
- 所有测试数据的 $n$ 之和不超过 $36$；
- 所有测试数据的 $q$ 之和不超过 $4 times 10^5$；
- 所有坐标均为整数，绝对值不超过 $10^3$；
- 对每个频道均有 $A_i eq.not B_i$；
- $1 lt.eq w_i lt.eq 10^6$；
- $0 lt.eq s < 2^n$，$1 lt.eq k lt.eq n$；
- $P$ 是严格凸多边形，顶点按照逆时针顺序给出。

为了尽可能避免浮点数误差，数据还满足以下性质：将凸多边形的边界直线和所有半平面边界直线放在一起考虑，

- 任意两条边界直线要么平行，要么夹角正弦的绝对值至少为 $10^(- 3)$；
- 平行的两条边界直线不会重合；
- 任意两条不平行边界直线的交点，到其他任意边界直线的距离至少为 $10^(- 4)$。

====== Solution

- 看本质
  - 面积是直观的
  - 本质在于怎么求 k-max
- 快速求面积：
  - 显然预处理各种半平面交
- 快速求k-max
  - 使用 min-max 容斥 $ upright("kmax")_k \( S \) = sum_(T subset.eq S med \| T \| gt.eq k) \( - 1 \)^(\| T \| - k) binom(\| T \| - 1, k - 1) min_(v in T) v $
- 推导答案公式

$ upright("ans") \( S \, k \) = integral_(p in P) $

====== Solution

- 折腾这么久，似乎重点已经不是 min-max 容斥了，而是 #strong[凸包 + 半平面交] 到底用哪个算法
  + 传统的单调栈维护半平面交：凸包的边必须转化为半平面，难以动态加入新的半平面
  + clip 凸包半平面交切割算法：凸包仍然用 `Vec` 顶点存储，可以方便动态添加半平面交限制，便于此题中的 #strong[dfs 继承]
- 当然还有一点，就是半平面交算法的鲁棒性
  - 可以理解板子
  - 但是，对于特殊情况的处理，无法保证不存在未知问题
- 【坑点】最后讲一下优化步骤
  - 首先，输入都是整数输入不要用 `double` 避免 TLE
  - 先排序还是后排序的问题
    - 先全局排序，之后取得的子集天然有序
    - 但是后排序，虽然可以快速收集，但是不保证有序，必须有内嵌 log 复杂度排序
  - 计算条件继承性问题
    - 此题尤为明显，利用计算结果的继承性，可以加速结果的递推 避免 TLE
    - dfs 继承性
  - `uniq()` 去重问题
    - 不知道为什么要去重
    - 此题问题不大
    - 记着吧
- 【回顾知识点】
  - 二维计算集合精度工具
    - `const db eps = 1e-9`
    - `int sign(db x) {}`
  - 二维计算几何结构体
    - `Vec` 点/向量
      - `db x, y, arg`
      - 重载：加法`+`，减法`-`，内积`*`，外积`%`，数乘`*`
      - 重载：打印（建议写成 `(x, y)`）
    - `Seg` 线段
      - `Vec s, t, v;`
      - `db arg`
      - 重载：打印（建议写成 `[s -> t]` ）
  - 二维计算几何，经典问题
    - `inter(Seg A, Seg B)`
    - `right(Seg A, Vec b)`
  - 半平面交传统算法
    - 前置 `cmp(Seg A, Seg B)`
    - `vector<Vec> half(vector<Seg> ss)`
  - 半平面交 clip 算法
    - `vector<Vec> clip(vector<Vec>& poly, Seg s)`
  - 计算多边形的面积
    - `db getS(vector<Vec>& poly)`

====== Code

```cpp
#include<bits/stdc++.h>
using namespace std;
using db = double;
using ll = int;

const db eps = 1e-9;
const int N = 18, M = 31;

int C[N+1][N+1];

void init() {
    C[0][0]=1;
    for (int i = 1;i<=N;i++) {
        C[i][0] = 1;
        for(int j = 1;j<=i;j++) 
            C[i][j] = C[i-1][j] + C[i-1][j-1];
    }
}

int sign(db x) {
    if(x > eps) return 1;
    if(x < -eps) return -1;
    return 0;
}

struct Vec {
    db x, y;
    db arg;
    Vec(db x=0,db y=0):x(x),y(y),arg(atan2(y,x)){}
    bool operator<(const Vec& o) const {return arg < o.arg;}
    Vec operator-(Vec o) const {return Vec(x-o.x,y-o.y);}
    Vec operator+(Vec o) const {return Vec(x+o.x,y+o.y);}
    db operator*(Vec o) const {return x*o.x + y*o.y;}
    Vec operator*(db o) const {return Vec(x*o, y*o);}
    db operator%(Vec o) const {return x*o.y - y*o.x;}
    friend ostream& operator<<(ostream& os, Vec o) {
        return os << "(" << o.x << ", " << o.y << ")";
    }
};

struct Seg {
    Vec s, t, v;
    db arg;
    int id;
    Seg():id(-1){}
    Seg(Vec s, Vec t):s(s),t(t),v(t-s),id(-1){arg = atan2(v.y, v.x);}
    bool operator<(const Seg& o) const {return v < o.v;}
    friend ostream& operator<<(ostream& os, Seg o) {
        return os << "Seg[" << o.s << " -> " << o.t << "]";
    }
};

namespace TLE_ConventionalHalfPlane { // Failed 

    Vec inter(Seg A, Seg B) {
        // 求交点
        Vec u = A.s - B.s;
        return A.s + A.v * ((B.v%u)/(A.v%B.v));
    }
    bool right(Seg A, Vec b) {
        return sign(A.v%(b-A.s)) == -1;
    }
    bool cmp(Seg A, Seg B) {
        if(!sign(A.arg-B.arg))return right(A,B.s);
        else return sign(A.arg-B.arg) == -1;
    }
    
    Seg Q[1000005];
    vector<Seg> alls;

    db half(vector<Seg>& S) {
        // 给定若干半平面，求交集面积
        int sz = S.size();
        int l = 1, r = 0;
        for(int i = 0;i<sz;i++) {
            if(l<=r&&sign(S[i].arg-Q[r].arg) == 0) continue;
            while(l<r&&right(S[i],inter(Q[r],Q[r-1])))r--;
            while(l<r&&right(S[i],inter(Q[l],Q[l+1])))++l;
            Q[++r] = S[i];
        }
        while(l < r&&right(Q[l], inter(Q[r], Q[r-1]))) --r;
        if (r - l + 1 < 3) return 0;

        Q[r+1] = Q[l];
        db res = 0;
        Vec O = inter(Q[l], Q[l+1]);
        for(int i=l+2;i<=r;i++) {
            auto tmp1 = (inter(Q[i-1], Q[i])-O);
            auto tmp2 = (inter(Q[i], Q[i+1])-O);
            res += tmp1 % tmp2;
        }
        return res/2;
    }
}

namespace AC_ClipHalfPlane {
    // 小规模数据 + 继承性加持 复杂度神了
    void uniq(vector<Vec>& p) {
        vector<Vec> q;
        q.reserve(p.size());
        for (Vec x : p) {
            if (q.empty() || sign(x.x - q.back().x) || sign(x.y - q.back().y)) {
                q.push_back(x);
            }
        }
        // 去掉首尾重复
        if (q.size() > 1 && !sign(q.front().x - q.back().x) && !sign(q.front().y - q.back().y)) {
            q.pop_back();
        }
        p.swap(q);
    }
    // 【新】clip O(n) 半平面 切割 凸包 算法
    vector<Vec> clip(vector<Vec>& poly, Seg s) {
        vector<Vec> res;
        if(poly.empty()) return res;
        int n = poly.size();
        poly.push_back(poly[0]);
        for(int i=0;i<n;i++) {
            Vec a = poly[i], b = poly[i+1];
            db ta = s.v % (a - s.s);
            db tb = s.v % (b - s.s);
            bool ina = sign(ta)>=0;
            bool inb = sign(tb)>=0;
            if (ina) res.push_back(a);
            if (ina^inb) {
                db t = ta / (ta - tb);
                res.push_back(a + (b-a)*t);
            }
        }
        uniq(res); // 不用 Unique 也能过 ?!!!
        return res;
    }
    db getS(vector<Vec>& poly) {
        if(poly.empty()) return 0;
        db res = 0;
        int n = poly.size();
        for(int i=0;i<n;i++) {
            res += poly[i] % poly[(i+1)%n];
        }
        return res / 2;
    }
}

using namespace AC_ClipHalfPlane;

int n, m, q;

db S[(1<<N)+1];
db kmax[N+1][(1<<N)+1];
vector<Vec> points; // 凸包点集
vector<Seg> segments;
int w[N+1];

void dfs(int i,int s,vector<Vec> poly) {
    S[s] = getS(poly);
    for(int j = i;j<n;j++) {
        auto tmp = clip(poly, segments[j]);
        dfs(j+1,s|(1<<j),tmp);
    }
}

void solve() {
    // 1. 读取 m 个顶点 -> m 个封闭半平面
    // 2. 读取 n 个半平面
    // 3. 然后预处理 2^n 个半平面交
    //      每次都是有 m + i 个半平面 求解交面积
    // 4. 然后 用高位前缀和 min-max 容斥
    //      即，对于从 1 到 n 每一个 k 值，都算一下 系数*权值*面积 容斥
    cin >> n >> m >> q;

    fill(S,S+(1<<n), 0);
    for (int k = 1; k <= n;k++) 
        fill(kmax[k],kmax[k]+(1<<n),0); 
    
    // 1.
    points.clear();
    for(int i = 0 ; i < m;i++) {
        ll x, y;
        cin >> x >> y;
        points.push_back(Vec(x,y));
    }
    
    // alls.clear(); // But Still Failed
    // for (int i = 0 ; i < m;i++) 
    //     alls.push_back(Seg(points[i], points[(i+1)%m]));

    // 2.
    segments.clear();
    for(int i = 0 ; i < n;i++) {
        ll x1,y1,x2,y2;
        cin >> x1 >> y1 >> x2 >> y2 >> w[i];

        auto tmp = Seg(Vec(x1,y1), Vec(x2,y2));
        segments.push_back(tmp);

        // tmp.id = i; // But Still Failed
        // alls.push_back(tmp);
    }

    // sort(alls.begin(), alls.end(), cmp); // But Still Failed

    dfs(0,0,points);
    
    // 3. 
    // vector<Seg> tmp; // Failed
    for (int i = 1 ; i< (1<<n); i++) {
        vector<Vec> poly = points;
        
        // tmp.clear();

        int mn = 1e7;
        int sz = 0;
        
        // 【坑点 But Still Failed】 排序 + 按需加入 >> 按需加入 + 排序
        // 依然 TLE 因为根本上，传统半平面交在这里常数太大！！！
        // 并且没有继承性
        // 必须使用 Clip + 继承性
        // for(const auto& s:alls) {
        //     if(s.id==-1) {
        //         tmp.push_back(s);
        //     } else if(i >> s.id & 1) {
        //         sz++;
        //         tmp.push_back(s);
        //         mn = min(mn, w[s.id]);
        //     }
        // }
        
        for(int j = 0;j<n;j++) {
            if(i>>j&1) {
                sz++;
                mn = min(mn, w[j]);
                // 【坑点 But Still Failed】直接使用 clip凸包半平面裁剪 依然 TLE 
                // 必须充分利用继承性 使用 dfs 实现最简单
                // poly = clip(poly, segments[j]); 
                // if(poly.size() < 3) break;
            }
        }

        // db sum = half(tmp); // Failed 
        
        // 4.
        for (int k = 1; k <= n; k++) {
            kmax[k][i] = S[i] * mn * C[sz-1][k-1];
            if((sz-k)&1) kmax[k][i] = -kmax[k][i];
        }
    }

    // 4.
    for(int k = 1; k <= n; k++) 
        for (int i = 0; i < n; i++) 
            for (int s = 1 ; s < (1<<n); s++) 
                if(s>>i&1) 
                    kmax[k][s] += kmax[k][s^(1<<i)];
    while(q--) {
        int s, k;
        cin >> s >> k;
        cout << kmax[k][s] << "\n";
    }
}

int main() {
    init();
    cout << setprecision(16) << fixed;
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    int t = 1;
    cin >> t;
    while (t--) solve();
}
```

===== 1002 Binary Choice【欧拉回路 x 二分图】

====== Problem Description

本题开启 Special Judge。

给定 $n$ 个三元组：

$ ⟨ a_i \, b_i \, c_i ⟩ . $

其中 $a_i \, b_i$ 是第 $i$ 个位置的两个候选值，$c_i$ 是它的颜色。

你需要对每个位置 $i$：

- 从 $a_i \, b_i$ 中选择一个作为最终值 $x_i$；
- 将该位置放入第 $0$ 组或第 $1$ 组。

要求同时满足：

- 对于每种颜色，两组中这种颜色的数量相等；
- 对于每种值，两组中这个值的数量相等。

输入保证每种颜色出现偶数次。

#strong[样例解释]

第一组中最终选择的值依次为 $2 \, 2 \, 1 \, 1$。颜色 $10 \, 20$ 和最终值 $1 \, 2$ 都分别在两组中出现一次。

第二组中，值 $1$ 和值 $2$ 都只能被选择一次，不可能在两组中平分，因此无解。

====== Input

输入包含多组测试数据。第一行包含一个整数 $T$，表示测试数据组数。

对于每组测试数据：

- 第一行包含一个整数 $n$，表示三元组的数量；
- 接下来 $n$ 行，第 $i$ 行包含三个整数 $a_i \, b_i \, c_i$，分别表示第 $i$ 个位置的两个候选值和颜色。

====== Output

对于每组测试数据：

- 如果不存在合法方案，输出一行 `-1`；
- 否则输出两行长度均为 $n$ 的 01 字符串 $s \, t$。

其中：

- $s_i = 0$ 表示选择 $a_i$，$s_i = 1$ 表示选择 $b_i$；
- $t_i$ 表示位置 $i$ 被放入的组号。

如果存在多组合法方案，输出任意一组即可。

====== Sample Input

```txt
2
4
1 2 10
2 3 10
1 1 20
1 1 20
2
1 1 7
2 2 7
```

====== Sample Output

```txt
1000
0101
-1
```

====== Hint

数据范围：

$ 1 lt.eq T lt.eq 10 $

$ 2 lt.eq n lt.eq 2 times 10^5 $

对于所有测试数据，$n$ 之和不超过 $4 times 10^5$。

$ 1 lt.eq a_i \, b_i \, c_i lt.eq 10^9 $

每种颜色的出现次数均为偶数。

====== Solution

#strong[欧拉回路 + 二分图染色 = 欧拉二分图]

DeepSeek：你刚才描述的现象，正是~#strong[“欧拉回路定理”（Eulerian Circuit Theorem）];~的直接推论。

#strong[定理原话];：

#quote(block: true)[
在一个连通图里，#strong[如果每个顶点的度数都是偶数];，那么这个图#strong[一定存在一条欧拉回路];（即一条不重复地经过每条边恰好一次，并回到起点的路径）。
]

#strong[你的话翻译成定理];：

#quote(block: true)[
你构造的那个二分图，左边点度数是偶数，右边点度数也是偶数，所以#strong[整个图所有点的度数都是偶数];。 \
因此，欧拉回路必然存在。 \
沿着这条回路“交替染色”，就必然让每个顶点周围的边被平分。
]

- 分析：
  - 首先，颜色一定已经是偶数了，所以不用管
  - 重点是，从 $a_i \, b_i$ 选一个，能否构造出，每种数字都是偶数个的方案
- 将这个数字选择翻译为图
  - 就是 $a_i \, b_i$ 两个值用边 $i$ 连接，选定一个方向，指向被选择的值
  - 则初步条件：
    - 所有节点的入度一定是偶数个
  - 进一步：
    - 所有连通图的边数一定是偶数个
    - 边数是偶数个？依稀记得左神讲过的结论
  - #strong[偶数边图结论];：
    - 偶数个边的图，一定存在合法方案：
    - 每一条边定向之后，所有入度都为 偶数
  - 偶数个数构造方式：
    - 跑一个 DFS 树
    - 对于非树边，可以默认指向 $u$ 自己
    - 对于树边，当遍历完成子节点 $v$ 之后，考虑
      - 若节点 $v$ 度数为奇数，则指向 $v$
      - 否则指向自己 $u$
- 至此，可以放心地跑 #strong[欧拉回路] x #strong[二分图染色] 了
  - 需要的图：
    - 左部点：所有被选择的值
    - 右部点：颜色序号
    - 边：被选择的值 -\> 所属编号 $i$ -\> $i$ 对应的颜色
  - 方案：
    - 欧拉回路访问顺序按照奇偶，对边的编号 $i$ 归类 0/1 组
- 实现是真的难！！！
  - 特意写了：
  - 【迭代 DFS】
  - 【Hierholzer 欧拉回路遍历算法】 ！！！
- 几个坑点：
  - 【坑点1：什么悬垂引用写穿！！！】
  - 【坑点2：init 要在 cntV cntC 之前初始化】
  - 【坑点3：为了维持对齐，必要时 ++cntE】
  - 【坑点4：dfn 序处在线理方式，自环 / 返祖边】 

====== Code

```cpp
#include<bits/stdc++.h>
using namespace std;
using ll = long long;

const int N = (2e5+5) * 2;

int V[N], cntV, C[N], cntC;

int n;
array<int,3> abc[N];
bool ok;

struct Edge{
    int to, nxt, id;
}e[N*8];
int cntE;
// a-b 图  左部取值 右部颜色 
int hd[N], hdV[N], hdC[N];

int dfn[N], dfncnt;
int visV[N], visE[N];

int deg[N];

int s[N], t[N];

void init() {
    cntE = 1;
    fill(hd,hd+1+cntV, 0);
    fill(hdV,hdV+1+cntV, 0);
    fill(hdC,hdC+1+cntC, 0);
}

void add_edge(int *hd, int u,int v, int id) {
    e[++cntE] = {v, hd[u], id};
    hd[u] = cntE;
    // e[++cntE] = {u, hd[v]};
    // hd[v] = cntE;
}

// 迭代 DFS
void dfs1() {
    // u fi i
    vector<array<int,3>> stk;
    for (int i = 1; i <= cntV; i++) {
        if (visV[i]) continue;
        stk.push_back({i, 0, -1});
        while(stk.size()) {
            auto& [u,fi,i] = stk.back();
            if(i == -1) {
                // st
                if(visV[u]) {
                    stk.pop_back();
                    continue;
                }
                visV[u] = true;
                dfn[u] = ++dfncnt;

                i = hd[u];
            } else if(i) {
                // 跳过父边
                if (i != (fi^1)) {
                    int v = e[i].to;
                    // 【坑点4：dfn 序在线处理方式，自环 / 返祖边】   
                    // dfn 序 
                    if (!visV[v]) {
                        // 【坑点1：什么悬垂引用写穿！！！】
                        int cur = i;
                        i = e[i].nxt;
                        // push_back 一旦扩容，引用就失效了！！！！
                        stk.push_back({v, cur, -1});
                        continue;
                    } else if(dfn[v] < dfn[u] || v == u){
                        deg[u]++;
                        int id = e[i].id;
                        add_edge(hdV, u, abc[id][2], id);
                        add_edge(hdC, abc[id][2], u, id);
                    }
                }
                i = e[i].nxt;
            } else {
                // ed
                if (fi) {
                    int f = e[fi^1].to;
                    int id = e[fi].id;
                    if (deg[u] & 1) {
                        deg[u]++;
                        add_edge(hdV, u, abc[id][2], id);
                        add_edge(hdC, abc[id][2], u, id);
                    } else {
                        deg[f]++;
                        add_edge(hdV, f, abc[id][2], id);
                        add_edge(hdC, abc[id][2], f, id);
                    }
                }
                stk.pop_back();
            }
        }
        ok &= deg[i] & 1 ^ 1;
    }
}

// 【Hierholzer】 欧拉回路遍历算法
// 本质上是 对称 + 当前弧 + 迭代 DFS
void dfs2() {
    // u, _
    vector<array<int,2>> stk;
    for (int i = 1; i <= cntV; i++) {
        stk.push_back({i, 0});
        while(stk.size()) {
            auto& [u, _] = stk.back();
            int& i = _ == 0 ? hdV[u] : hdC[u];
            if (i) {
                int v = e[i].to;
                int id = e[i].id;
                if (!visE[id]) {
                    visE[id] = true;
                    s[id] = (_ == 0 ? u:v ) == abc[id][1];
                    t[id] = _;
                    stk.push_back({v, _^1});
                }
                i = e[i].nxt;
            } else {
                stk.pop_back();
            }
        }
    }
}

void solve() {
    
    // 【坑点2：init 要在 cntV cntC 之前初始化】
    init();

    ok = true;    
    dfncnt = cntV = cntC = 0;

    cin >> n;
    for (int i = 1; i <= n; i++) {
        auto& [a, b, c] = abc[i];
        cin >> a >> b >> c;
        V[++cntV] = a;
        V[++cntV] = b;
        C[++cntC] = c;
    }
    sort(V+1,V+1+cntV);
    sort(C+1,C+1+cntC);
    cntV = unique(V+1,V+1+cntV) - V - 1;
    cntC = unique(C+1,C+1+cntC) - C - 1;
    for (int i = 1; i <= n; i++) {
        auto& [a,b,c] = abc[i];
        a = lower_bound(V + 1, V + 1 + cntV, a) - V;
        b = lower_bound(V + 1, V + 1 + cntV, b) - V;
        c = lower_bound(C + 1, C + 1 + cntC, c) - C;
        add_edge(hd, a, b, i);
        // 【坑点3：为了维持对齐，必要时 ++cntE】
        if (a != b) {
            add_edge(hd, b, a, i);
        } else cntE++;
    }
    
    dfs1();
    if(ok) dfs2();

    if(!ok) {
        cout << -1 << "\n";
    } else {
        for (int i = 1; i <= n; i++) cout << s[i];
        cout << "\n";
        for (int i = 1; i <= n; i++) cout << t[i];
        cout << "\n";

        array<ll,2> sum{0,0};
        for(int i = 1;i<=n;i++) {
            int v = abc[i][s[i]];
            sum[t[i]] += v;
            // if(i&1 && t[i] == t[i+1]) {
            //     assert(0);
            // }
        }
        
        if(sum[0]!=sum[1]) {
            assert(0);
        }
    }

    for (int i = max({cntV, cntC, n}); i; i--) {
        deg[i] = dfn[i] = s[i] = t[i] = 0;
        visV[i] = visE[i] = false;
    }
}   

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    int T = 1;
    cin >> T;
    while (T--) solve();
}
```

===== 1004 EERT 【树的直径 / 树上背包】（TODO）

====== Problem Description

给定一棵包含 $n$ 个原始结点的无根树。结点 $i$ 有一个整数权值 $a_i$。

你可以执行任意次以下两种操作：

+ 选择一个满足 $a_i > 1$ 的原始结点 $i$，支付 $x$ 的代价，新建 $a_i - 1$ 个权值为 $1$ 的结点，并将它们分别作为叶子连接到 $i$，随后令 $a_i = 1$；
+ 选择两个相邻的原始结点 $i \, j$，再选择一个满足 $1 lt.eq t lt.eq a_i - 1$ 的整数 $t$。支付 $y$ 的代价，并令 $ a_i arrow.l a_i - t \, quad a_j arrow.l a_j + t . $

新建的叶子不能参与第二种操作。

树的直径定义为树上两点之间路径所含边数的最大值。求使最终树的直径至少为 $k$ 所需的最小总代价。如果无法做到，输出 $- 1$。

====== Input

输入包含多组测试数据。第一行包含一个整数 $T$，表示测试数据组数。

对于每组测试数据：

第一行包含四个整数 $n \, k \, x \, y$；

第二行包含 $n$ 个整数 $a_1 \, a_2 \, dots.h \, a_n$；

接下来 $n - 1$ 行，每行包含两个整数 $u \, v$，表示原树中的一条边。

====== Output

对于每组测试数据，输出一行一个整数，表示最小总代价；如果无解，输出 $- 1$。

====== Sample Input

```txt
5
4 3 10 2
1 1 1 1
1 2
2 3
3 4
5 3 7 3
2 1 1 1 1
1 2
1 3
1 4
1 5
5 6 5 2
1 1 3 1 1
1 2
2 3
3 4
4 5
3 4 5 7
1 2 1
1 2
2 3
1 2 11 100
3
```

====== Sample Output

```txt
0
10
18
-1
11
```

====== Hint

#strong[样例解释]

第一组数据中原树直径已经为 $3$，不需要执行操作。

第二组数据中，可以花费 $3$ 将结点 $1$ 的一个单位权值运输到任意叶子，再花费 $7$ 挂出新叶子，总代价为 $10$。

第三组数据中，将结点 $3$ 的两个单位分别运输到结点 $1 \, 5$，需要使用四条原树边。随后在两个端点各挂一次叶子，总代价为

$ 4 times 2 + 2 times 5 = 18 . $

第五组数据只有一个原始结点。一次操作可以同时挂出两个叶子，因此答案为 $11$。

#strong[数据范围]

- $1 lt.eq T lt.eq 5$；
- $1 lt.eq n lt.eq 2 times 10^5$；
- $1 lt.eq k lt.eq 10^9$；
- $1 lt.eq a_i lt.eq 10^9$；
- $0 lt.eq x \, y lt.eq 10^9$；
- 输入的边构成一棵树。
- 所有测试数据的 $n$ 之和不超过 $4 times 10^5$。

====== Solution

====== Code

===== 1005 TREE【笛卡尔树 / ST 表 / 矩阵乘法】

====== Problem Description

给定一个长度为 $n$ 的排列 $a_1 \, a_2 \, dots.h \, a_n$。

对于一个非空序列 $b_1 \, b_2 \, dots.h \, b_k$，它的小根笛卡尔树是一棵满足以下条件的二叉树：

- 结点为序列中的 $k$ 个位置；
- 中序遍历依次得到位置 $1 \, 2 \, dots.h \, k$；
- 每个结点对应的值都小于其儿子对应的值。

因为序列中的数互不相同，所以它的小根笛卡尔树唯一。

树根的深度定义为 $1$，其余结点的深度等于父亲深度加 $1$。树的高度是所有结点深度的最大值。

有 $q$ 次询问。每次给定一个区间 $\[ l \, r \]$，独立地取出序列

$ a_l \, a_(l + 1) \, dots.h \, a_r $

建立它的小根笛卡尔树，并求出这棵树的高度。

数据范围：

- $1 lt.eq T lt.eq 10$；
- $1 lt.eq n \, q lt.eq 2 times 10^5$；
- $a_1 \, a_2 \, dots.h \, a_n$ 是 $1 \, 2 \, dots.h \, n$ 的一个排列；
- $1 lt.eq l lt.eq r lt.eq n$；
- 所有测试数据的 $n$ 之和不超过 $4 times 10^5$；
- 所有测试数据的 $q$ 之和不超过 $4 times 10^5$。

====== Input

输入包含多组测试数据。第一行包含一个整数 $T$，表示测试数据组数。

对于每组测试数据：

- 第一行包含两个整数 $n \, q$；
- 第二行包含 $n$ 个整数 $a_1 \, a_2 \, dots.h \, a_n$；
- 接下来 $q$ 行，每行包含两个整数 $l \, r$，表示一次询问。

====== Output

对于每次询问，输出一行一个整数，表示对应区间的小根笛卡尔树高度。

====== Sample Input

```txt
3
1 2
1
1 1
1 1
5 6
3 1 5 2 4
1 5
1 3
3 5
2 4
3 3
4 5
7 6
3 2 4 1 6 5 7
1 7
1 3
5 7
2 6
3 5
4 4
```

====== Sample Output

```txt
1
1
3
2
2
3
1
2
3
2
2
3
2
1
```

====== Solution

#strong[像这种，笛卡尔树，非平衡的树，在上面做文章的话]

- 除了 #strong[启发式合并] 以外
- #strong[ST 表] 维护信息是一个不错的选择

#strong[本题着重考察了：中序遍历 与 跳父链 的关系，即]

- 左儿子跳父链时，其父亲的右儿子必然序号较大
- 右儿子跳父链是，其父亲的左儿子必然序号较小

据此，借鉴 #strong[猫树] 的思想，将一次查询划分为：#strong[左子树的后缀+右子树的前缀]

- 通过限定中间，向两边延伸的方式，天然的卡住了区间

此外，借鉴 #strong[线段树维护区间矩阵乘法（结合律）] ， #strong[ST 表] 同样可以维护以一个点为起始点，压缩倍增式的结合律操作（但是静态的）

- 结合律需要自己根据当前题目特性，寻找结合律运算关系
- 并且，切记不要弄反运算结合顺序
- 要注意：op（Fn） 结构体到底存储在父亲还是儿子上面，何时停止结合，初始值是多少
- 在树上，尤其需要基础的 `st[N][__lg(N) + 1]` jump 表

====== Code

```cpp
#include<bits/stdc++.h>
using namespace std;

const int N = 2e5 + 5;

int n, q, a[N];

struct Cartesian{
    int n, *a, P;
    int stk[N], tp;
    int lc[N], rc[N];
    int pre[N][__lg(N) + 1][2], suf[N][__lg(N) + 1][2];
    int st[N][__lg(N) + 1], dep[N];
    int h[N];
    int root;
    int cur[2], tmp[2];

    void build(int n,int* a) {
        #define mst(arr) memset(arr, 0, (sizeof arr[0]) * (this->n + 1))
        mst(pre); mst(suf); mst(st); mst(dep); mst(h); mst(lc); mst(rc);
        this->n = n;
        P = __lg(n);
        for (int i = 1, tp = 0, tmp; i <= n; i++) {
            tmp = tp;
            while(tp && a[stk[tp]] > a[i]) tp--;
            if (tp) rc[stk[tp]] = i;
            if (tp != tmp) lc[i] = stk[tp + 1];
            stk[++tp] = i;
        }
        root = stk[1];
        dfs0(root, 0);
        dfs1(root);
    }
    // 特别注意啊，不要结合反了！
    void merge(int* a,int* b,int* c) {
        c[0] = max(b[0], a[0] + b[1]);
        c[1] = a[1] + b[1];
    }
    void dfs0(int u,int f) {
        if (!u) return;

        dep[u] = dep[f] + 1;
        st[u][0] = f;
        h[u] = 1;
        
        dfs0(lc[u], u);
        dfs0(rc[u], u);

        if(f) h[f] = max(h[f], h[u] + 1);
        
        suf[lc[u]][0][0] = h[rc[u]] + 1;
        suf[lc[u]][0][1] = 1;
        
        pre[rc[u]][0][0] = h[lc[u]] + 1;
        pre[rc[u]][0][1] = 1;
    }
    void dfs1(int u) {
        if (!u) return;
        for (int p = 1; p <= P; p++) {
            int f = st[u][p-1];
            st[u][p] = st[f][p-1];
            merge(suf[u][p-1], suf[f][p-1], suf[u][p]);
            merge(pre[u][p-1], pre[f][p-1], pre[u][p]);
        }
        dfs1(lc[u]);
        dfs1(rc[u]);
    }

    int lca(int a,int b) {
        if (dep[a] < dep[b]) swap(a, b);
        for(int p = P;p>=0;p--) if (dep[st[a][p]] >= dep[b]) a=st[a][p];
        if (a == b) return a;
        for (int p = P;p>=0;p--) if(st[a][p]!=st[b][p]) a=st[a][p],b=st[b][p];
        return st[a][0];
    }

    int query(int l,int r) {
        int mid = lca(l ,r);
        int pref = 0, suff = 0;
        if (l != mid) {
            int t = 1 + h[rc[l]];
            cur[0] = 0, cur[1] = 0;
            for(int p = P;p>=0;p--) if (dep[st[l][p]]>dep[mid]) {
                merge(cur, suf[l][p], tmp);
                memcpy(cur,tmp,sizeof cur);
                l = st[l][p];
            }
            suff = max(cur[0], t + cur[1]);
        }
        if (r != mid) {
            int t = 1 + h[lc[r]];
            cur[0] = 0, cur[1] = 0;
            for(int p = P;p>=0;p--) if (dep[st[r][p]]>dep[mid]) {
                merge(cur, pre[r][p], tmp);
                memcpy(cur,tmp,sizeof cur);
                r = st[r][p];
            }
            pref = max(cur[0], t + cur[1]);
        }
        return max(pref, suff) + 1;
    }
}T;

void solve() {
    cin >> n >> q;
    for (int i = 1; i <= n; i++) cin >> a[i];
    T.build(n, a);
    for (int i = 1; i <= q; i++) {
        int l ,r;
        cin >> l >> r;
        cout << T.query(l, r) << "\n";
    }
}

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    int T = 1;
    cin >> T;
    while (T--) solve();
}
```

