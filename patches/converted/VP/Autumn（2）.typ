=== #text("VP：Autumn（2）国庆1")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/VP/Autumn（2）.md`]

===== F 看起来很经典的动态 max 覆盖 min RMQ

- 给定 n 个操作，可以离线
  - 1 在 l r 区间放置一个高度为 h 的矩形
  - 2 移除放置的第 i 个矩形
  - 3 查询 l r 区间覆盖的最低高度

====== Solution1【树套树】

- 此题的树套树做法，难点在于
  - 想出来 区间覆盖某一个数字，下方的信息依然可以通过 up 上传得到
  - 想出来 查询时，经过的区间，需要对该区间的全覆盖值取 max
- 因此
  - `void up(i)` 信息的维护
    - `mn[i] = max(tag[i], (sz[i] > 1 ? min(mn[i*2], mn[i*2+1]) : 0));`
  - `int query()` 的注意事项
    - `int res = tag[i];`
- 复杂度 $O \( n log^2 n \)$
- 发现：
  - #strong[树套树] 解法 的常数 #strong[大于] #strong[线段树分治]

====== Code1

```cpp
#include<bits/stdc++.h>
using namespace std;

const int N = 2e5 + 5;
// 离散化 注意到 N * 2 的边界值 再乘 2 为了补空
const int NN = N * 4;

int tmp[NN], cnt;
int X[NN], cntX;

int getX(int x) {
    return lower_bound(X+1,X+1+cntX, x) - X;
}

int n;

struct Op {
    char op;
    int v1, v2, v3;
}q[N];

// op_add[i] = {l, r, x}
int idx;
array<int,3> op_add[N];

struct PQ {
    priority_queue<int> add, del;
    // 属性： 大小
    int sz;
    int size() {return sz;}
    // 操作：查询（最大值）
    int top() {
        return add.top();    
    }
    // 操作：加入
    void push(int x) {
        sz++;
        add.push(x);
    }
    // 操作：删除
    void erase(int x) {
        assert(sz);
        sz--;
        del.push(x);
        while(del.size() && del.top() == add.top()) {
            del.pop();
            add.pop();
        }
    }
};

namespace SegT {
    
    PQ S[NN*4];
    // mn 表示各个 "子树" 中各个整段的最小 max (很妙的一点就是，tag 保证了父覆盖的前提)
    // tag 表示当前段整段覆盖的 max
    int mn[NN*4], tag[NN*4];
    // 标注大小
    int sz[NN*4];

    void up(int i) {
        // 因为叶子 需要更新 只能这么搞了
        mn[i] = max(tag[i], (sz[i] > 1 ? min(mn[i*2], mn[i*2+1]) : 0));
    }
    void build(int i,int l,int r) {
        S[i].push(0); // 保底
        tag[i] = 0;
        sz[i] = r - l + 1;
        if (l == r) {
            mn[i] = 0;
        } else {
            int mid = (l + r) / 2;
            build(i*2,l,mid);
            build(i*2+1,mid+1,r);
            up(i); // bushi
        }
    }
    // 在 [jl, jr] 范围内 均覆盖一层 x
    void insert(int i,int l,int r,int jl,int jr,int x) {
        if (jl <= l && r <= jr) {
            S[i].push(x);
            tag[i] = S[i].top();
            up(i); // !!!
        } else {
            int mid = (l + r) / 2;
            if (jl <= mid) insert(i*2,l,mid,jl,jr,x);
            if (jr > mid) insert(i*2+1,mid+1,r,jl,jr,x);
            up(i);
        }
    }
    void erase(int i,int l,int r,int jl,int jr,int x) {
        if (jl <= l && r <= jr) {
            S[i].erase(x);
            tag[i] = S[i].top();
            up(i); // !!!!!
        } else {
            int mid = (l + r) / 2;
            if (jl <= mid) erase(i*2,l,mid,jl,jr,x);
            if (jr > mid) erase(i*2+1,mid+1,r,jl,jr,x);
            up(i);
        }
    }
    // 查询最小值
    int query(int i,int l,int r,int jl,int jr) {
        if (l > r) return 2e9;
        // 【原来是查询处理错了】
        // 确实应该 chmax tag[i]
        if (jl <= l && r <= jr) {
            return max(tag[i], mn[i]);
        } else {
            int mid = (l + r) / 2;
            int res = 2e9;
            if (jl <= mid) res = query(i*2,l,mid,jl,jr);
            if (jr > mid) res = min(res, query(i*2+1,mid+1,r,jl,jr));
            return max(tag[i], res);
        }
    }
}

void solve() {
    cin >> n;
    for (int i = 1; i <= n; i++) {
        auto& [op, v1, v2, v3] = q[i];
        cin >> op;
        if (op == '+') {
            // l r h
            cin >> v1 >> v2 >> v3;
            v2--;
            X[++cntX] = v1;
            X[++cntX] = v2;
        } else if (op == '-') {
            // idx
            cin >> v1;
        } else {
            // l r
            cin >> v1 >> v2;
            v2--;
            X[++cntX] = v1;
            X[++cntX] = v2;
        }
    }

    // 带有插空的离散化(可以不必 unique)
    // 1. 排序
    sort(X+1,X+1+cntX);
    // 2. 先放一个
    tmp[1] = X[1];
    cnt = 1;
    // 3. 按照时机放置 2 1 0 个
    for (int i = 2; i <= cntX; i++) {
        if(tmp[cnt] < X[i] - 1) {
            tmp[++cnt] = X[i] - 1;
        }
        if(tmp[cnt] < X[i]) {
            tmp[++cnt] = X[i];
        }
    }
    // 4. 拷贝
    memcpy(X,tmp,sizeof(X[0])*(cnt+1));
    cntX = cnt;

    SegT::build(1,1,cntX);
    for (int i = 1; i <= n; i++) {
        auto [op, v1, v2, v3] = q[i];
        if (op == '+') {
            v1 = getX(v1);
            v2 = getX(v2);
            SegT::insert(1,1,cntX,v1,v2,v3);
            // cout << "cover:" << v1 << " " << v2 << " " << v3 << "\n";
            op_add[++idx] = {v1, v2, v3};
        } else if (op == '-') {
            auto [a1,a2,a3] = op_add[v1];
            // cout << "del:" << a1 << " " << a2 << " " << a3 << "\n";
            SegT::erase(1,1,cntX,a1,a2,a3);
        } else {
            v1 = getX(v1);
            v2 = getX(v2);
            // cout << "query:" << v1 << " " << v2 << "\n";
            cout << SegT::query(1,1,cntX,v1,v2) << "\n";
        }
    }
}

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    int T = 1;
    // cin >> T;
    while (T--) solve();
}


/*

// 居然是实数轴

1   2   3   4   5   6
|---|---|---|---|---|
*****   *****
     ^^^ ???
 1    2   3   4   5

这样标记 [l, r] -> [l, r-1] ok 

query [l, r] -> [l, r-1] ok 

*/
```

====== Solution2【线段树分治】

- 终于懂线段树分治了
  - #strong[线段树分治] 是经典的 #strong[离线] 技巧，适用于：
    - 操作为取 min / max 等 #strong[非可逆操作] 的 低代价 #strong[撤销] 操作
    - 时间复杂度比正常的 add / sub 等可逆操作多乘一个 $log Q$
    - 使用类似工程式的 `vector<Log> history` 日志备份便于撤销
  - #strong[线段树分治复杂度];：
    - $O \( 2 times Q log Q times 单 次 正 向 操 作 的 代 价 \)$
  - （此题的单次代价为 $log n$）
- 发现：
  - #strong[线段树分治] 解法 的常数 #strong[小于] #strong[树套树]

====== Code2

```cpp
#include<bits/stdc++.h>
using namespace std;

const int N = 2e5 + 5;
// 离散化 注意到 N * 2 的边界值 再乘 2 为了补空
const int NN = N * 4;

int tmp[NN], cnt;
int X[NN], cntX;

int getX(int x) {
    return lower_bound(X+1,X+1+cntX, x) - X;
}

int n;

// 读取+离散化
struct Op {
    char op;
    int v1, v2, v3;
}q[N];

// 修改
// op_add[i] = {l, r, x, tim_start, tim_end}
int idx; // 操作序号
// 第 i 个操作序号的 l r x [起始影响的查询, 结束影响的查询]
array<int,5> op_add[N]; // 注意 可能区间 l > r 请特判

// 查询
int tim; // 时间戳
// op_query[i] = {l, r, 对应时间戳的查询答案}
array<int,3> op_query[N]; 

namespace SegT {
    // 备份日志：
    struct Log {
        int* p;
        int v;
    };
    stack<Log> history;
    int mx[NN*4], mn[NN*4], tag[NN*4];

    // 核心回滚操作
    void roll_back(int ver) {
        while (history.size() > ver) {
            * history.top().p = history.top().v;
            history.pop();
        }
    }

    // 核心写操作：修改
    void modify(int* p, int v) {
        history.push({p, *p});
        *p = v;
    }

    // 上传
    void up(int i) {
        modify(&mx[i], max(mx[i*2], mx[i*2+1]));
        modify(&mn[i], min(mn[i*2], mn[i*2+1]));
        // cout << "up: " << i << " " << mx[i] << " " << mn[i] <<  "\n";
    }

    // 【仪式性的 build 一下】
    void build(int i,int l,int r) {
        tag[i] = -1;
        mx[i] = 0;
        mn[i] = 0;
        if (l == r) {

        } else {
            int mid = (l + r) / 2;
            build(i*2,l,mid);
            build(i*2+1,mid+1,r);
            // up(i); // ...
        }
    }

    // 懒
    void lazy(int i,int v) {
        if (mx[i] < v) {
            modify(&mx[i], v);
        }
        if (tag[i] < v) {
            modify(&tag[i], v);
        }
        if (mn[i] < v) {
            modify(&mn[i], v);
        }
    }

    // 下传
    void down(int i) {
        if (tag[i] != -1) {
            lazy(i*2,tag[i]);
            lazy(i*2+1,tag[i]);
            modify(&tag[i], -1);
        }
    }

    // 检查最大值
    void chmax(int i,int l,int r,int jl,int jr,int x) {
        if (l > r || mn[i] >= x) return;
        if (jl <= l && r <= jr) {
            lazy(i,x);
        } else {
            int mid = (l + r) / 2;
            down(i);
            // 【hev???】  jl <= l 和 jr > r 是 hev ???
            if (jl <= mid) chmax(i*2,l,mid,jl,jr,x);
            if (jr > mid) chmax(i*2+1,mid+1,r,jl,jr,x);
            up(i);
        }
    }

    // 查询最小值
    int query(int i,int l,int r,int jl,int jr) {
        if (l > r) return 2e9;
        if (jl <= l && r <= jr) {
            // cout << "hit :" << l << " " << r << "->" << mn[i] << "\n";
            return mn[i];   
        } else {
            int mid = (l + r) / 2;
            down(i);
            int res = 2e9;
            if (jl <= mid) res = query(i*2,l,mid,jl,jr);
            if (jr > mid) res = min(res, query(i*2+1,mid+1,r,jl,jr));
            return res;
        }
    }
}

namespace SegT2 {
    // 不可逆事件： chmax [l, r]
    struct Event {
        int l, r, x;
    };
    vector<Event> e[N*4]; // 时间戳 N*4 即可
    // 在 [l,r] 时间 覆盖 [kl, kr] 高度 x 
    void add(int i,int l,int r,int jl,int jr,int kl,int kr,int x) {
        if(l > r) return;
        if (jl <= l && r <= jr) {
            e[i].push_back({kl,kr,x});
        } else {
            int mid = (l + r) / 2;
            if (jl <= mid) add(i*2,l,mid,jl,jr,kl,kr,x);
            if (jr > mid) add(i*2+1,mid+1,r,jl,jr,kl,kr,x);
        }
    }
    // dfs
    void dfs(int i,int l,int r) {
        int ver = SegT::history.size();
        // 启用覆盖
        // cout << "enter: " << l << " " << r << "\n";
        for (auto [l, r, x]: e[i]) {
            // cout << "apply: " << l << " " << r << " " << x << "\n";
            SegT::chmax(1,1,cntX,l,r,x);
        }
        if (l == r) {
            // 查询 tim == l 的答案
            auto& [L, R, ans] = op_query[l];
            ans = SegT::query(1,1,cntX,L,R);
        } else {
            int mid = (l + r) / 2;
            dfs(i*2,l,mid);
            dfs(i*2+1,mid+1,r);
        }
        // 撤回覆盖
        // cout << "exit: " << l << " " << r << "\n";
        SegT::roll_back(ver);
    }
}

void solve() {
    cin >> n;

    // 【计数总时间戳】
    int total = 0;
    for (int i = 1; i <= n; i++) {
        auto& [op, v1, v2, v3] = q[i];
        cin >> op;
        if (op == '+') {
            // l r h
            cin >> v1 >> v2 >> v3;
            v2--;
            X[++cntX] = v1;
            X[++cntX] = v2;
        } else if (op == '-') {
            // idx
            cin >> v1;
        } else {
            total++;
            // l r
            cin >> v1 >> v2;
            v2--;
            X[++cntX] = v1;
            X[++cntX] = v2;
        }
    }

    // 带有插空的离散化(可以不必 unique)
    // 1. 排序
    sort(X+1,X+1+cntX);
    // 2. 先放一个
    tmp[1] = X[1];
    cnt = 1;
    // 3. 按照时机放置 2 1 0 个
    for (int i = 2; i <= cntX; i++) {
        if(tmp[cnt] < X[i] - 1) {
            tmp[++cnt] = X[i] - 1;
        }
        if(tmp[cnt] < X[i]) {
            tmp[++cnt] = X[i];
        }
    }
    // 4. 拷贝
    memcpy(X,tmp,sizeof(X[0])*(cnt+1));
    cntX = cnt;

    // 离散化之后重新读取一遍
    for (int i = 1; i <= n; i++) {
        auto [op, v1, v2, v3] = q[i];
        if (op == '+') {
            int l = getX(v1), r = getX(v2), h = v3;
            int id = ++idx;
            op_add[id] = {l, r, h, tim+1, total};
        } else if (op == '-') {
            int id = v1;
            op_add[id][4] = tim;
        } else {
            int l =getX(v1), r = getX(v2);
            op_query[++tim] = {l, r, 0};
        }
    }

    // 初始化战场
    SegT::build(1,1,cntX);
    // 初始化增量 Events
    for (int i = 1; i <= idx; i++) {
        auto [l, r, h, s, t] = op_add[i];
        if (s <= t) {
            // cout << "add: " << s << "->" << t << ": " << l << " " << r << " " << h << "\n";
            SegT2::add(1,1,tim,s,t,l,r,h);
        }
    }
    // 时间分治
    SegT2::dfs(1, 1, tim);
    
    for (int i = 1; i <= tim; i++) {
        cout << op_query[i][2] << "\n";
    }
}

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    int T = 1;
    // cin >> T;
    while (T--) solve();
}


/*

// 居然是实数轴

1   2   3   4   5   6
|---|---|---|---|---|
*****   *****
     ^^^ ???
 1    2   3   4   5

这样标记 [l, r] -> [l, r-1] ok 

query [l, r] -> [l, r-1] ok 

*/
```

===== I 无限字符串（TODO）

