=== #text("2026牛客暑期多校训练营08")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/NC/2026Summer/contest08.md`]

===== F Tree Shifts Here【树的直径 / 换根 DP / 树上前缀和】（归档）

====== Problem Description

在月球上，篝将时间花在研究数之不尽的可能性上。她用一种极度压缩的语言解释自己的发现：寥寥数语就可能包含足以让普通人的大脑不堪重负的信息。

瑚太朗不愿认输，不断用自己的改写能力加速思考，以跟上她的讲解。这样的尝试已多次以惨痛结果告终，于是篝决定，在进一步告诉他任何事情之前，先测试他的反应速度。自然，简化自己的语言从不在她考虑的选项之中。

在这项挑战中，篝使用了一棵有 $n$ 个顶点的世界树，顶点编号从 $1$ 到 $n$。这棵树是无向且无权的。

每次询问由两个顶点 $u$ 和 $v$ 描述。篝会暂时删除从 $u$ 到 $v$ 的唯一简单路径上的每一条边。世界树随之变成一片由若干连通分量组成的森林。

一个连通分量的#strong[直径];是其中任意两个顶点间距离的最大值，距离以二者路径上的边数衡量。特别地，只含一个顶点的连通分量的直径为 $0$。

对于每次询问，瑚太朗必须求出所得所有连通分量的直径之和。

各次询问彼此#strong[独立];。每次询问结束后，所有被删除的边都会在下一次询问开始前恢复。如果 $u = v$，路径上不含任何边，因此世界树不会发生变化。

====== Input

每个测试的第一行包含两个整数 $n$ 和 $q$（$1 lt.eq n \, q lt.eq 2 dot.op 10^5$）。

接下来的 $n - 1$ 行描述 $n - 1$ 条边。第 $i$ 行包含两个整数 $a_i$ 和 $b_i$（$1 lt.eq a_i \, b_i lt.eq n$），表示顶点 $a_i$ 和 $b_i$ 之间的一条无向边。保证这些边构成一棵树。

接下来的 $q$ 行描述 $q$ 次询问。第 $i$ 行包含两个整数 $u_i$ 和 $v_i$（$1 lt.eq u_i \, v_i lt.eq n$）。

====== Output

对于每次询问，输出一个整数，表示删除对应边后所得所有连通分量的直径之和。

====== Sample Input

```txt
7 5
1 2
2 3
3 4
3 5
5 6
5 7
1 4
6 7
3 3
2 5
1 7
```

====== Sample Output

```txt
2
3
4
4
2
```

====== Solution

#quote(block: true)[
无
]

====== Code

```cpp
#include<bits/stdc++.h>
using namespace std;
using ll = long long;

const int N = 1e6 + 5;

int n, q;
vector<int> e[N];

int st[N][__lg(N)+2];
int dep[N];
int P;

ll sum[N];

multiset<int> S[N], T[N];
int down[N], up[N];
int dv[N], uv[N];

void dfs(int u,int f) {
    st[u][0] = f;
    dep[u] = dep[f] + 1;
    for(int p = 1;p<=P;p++) {
        st[u][p] = st[st[u][p-1]][p-1];
    }
    for(auto v:e[u]) if(v!=f){
        dfs(v, u);
    }
}

int A, B;

int jump(int a,int d) {
    for(int p = P;p>=0;p--)
        if(dep[st[a][p]]>=d) a=st[a][p];
    return a;
}

int lca(int a,int b) {
    bool sw = 0;
    A = B = -1;
    if(dep[a]<dep[b]) swap(a, b), sw = true;

    for(int p = P;p>=0;p--)
        if(dep[st[a][p]]>=dep[b]) a=st[a][p];

    if(a == b) {
        return b;
    }

    for(int p = P;p>=0;p--)
        if(st[a][p]!=st[b][p]) a=st[a][p],b=st[b][p];
    A = a;
    B = b;
    if(sw) swap(A, B);
    return st[a][0];
}

int top(multiset<int>& S,int n) {
    auto it = S.rbegin();
    int res = 0;
    while(n--) {
        if(it==S.rend()) break;
        res += *it;
        it++;
    }
    return res;
}

void get_d(int u, int f) {
    dv[u] =  0;
    down[u] = 1;
    for(auto v:e[u]) if(v!=f) {
        get_d(v, u);
        down[u] = max(down[u], down[v] + 1);
        S[u].insert(down[v]);
        T[u].insert(dv[v]);

        dv[u] = max(dv[u], dv[v]);
        // dv2[u] = max(dv2[u], dv[v]);
        // if(dv[u] < dv2[u]) swap(dv[u], dv2[u]);
    }
    dv[u] = max(dv[u], top(S[u], 2));
}

void build2(int u,int f) {
    for(auto v:e[u]) if(v!=f){
        sum[v] = sum[u];
        int tmp = down[v], tmpv = dv[v];
        S[u].erase(S[u].find(tmp));
        T[u].erase(T[u].find(tmpv));
        sum[v] += max(top(S[u], 2), top(T[u], 1));
        build2(v, u);
        S[u].insert(tmp);
        T[u].insert(tmpv);
    }
}

void build(int u,int f,int dd, int vv) {
    S[u].insert(dd);
    T[u].insert(vv);
    for(auto v:e[u]) if(v!=f){
        int tmp = down[v], tmpv = dv[v];
        S[u].erase(S[u].find(tmp));
        T[u].erase(T[u].find(tmpv));
        int cur = top(S[u], 1) + 1, curv = max(top(S[u], 2), top(T[u], 1));
        
        up[v] = cur;
        uv[v] = curv;
        
        build(v, u, cur, curv);

        S[u].insert(tmp);
        T[u].insert(tmpv);
    }
    S[u].erase(S[u].find(dd));
    T[u].erase(T[u].find(vv));
}


ll single(int a) {
    return max(top(S[a], 2), top(T[a], 1)); 
}

ll get_sum(int d,int u) {
    if(dep[d] <= dep[u]) return 0;
    return sum[d] - sum[u];
}

ll fu(int a,int A) {

    S[a].erase(S[a].find(down[A]));
    T[a].erase(T[a].find(dv[A]));

    if(st[a][0]) {
        S[a].insert(up[a]);
        T[a].insert(uv[a]);
    }

    ll res = single(a);

    S[a].insert(down[A]);
    T[a].insert(dv[A]);
    
    if(st[a][0]) {
        S[a].erase(S[a].find(up[a]));
        T[a].erase(T[a].find(uv[a]));
    }

    return res;
}

ll fu2(int a,int  A, int B) {
    ll res = 0;
    
    S[a].erase(S[a].find(down[A]));
    S[a].erase(S[a].find(down[B]));
    T[a].erase(T[a].find(dv[A]));
    T[a].erase(T[a].find(dv[B]));

    if(st[a][0]) {
        S[a].insert(up[a]);
        T[a].insert(uv[a]);
    }

    res += single(a);

    S[a].insert(down[A]);
    S[a].insert(down[B]);
    T[a].insert(dv[A]);
    T[a].insert(dv[B]);

    if(st[a][0]) {
        S[a].erase(S[a].find(up[a]));
        T[a].erase(T[a].find(uv[a]));
    }

    return res;
}

ll calc(int a,int b) {
    if(a == b) return max(top(S[1],2), top(T[1], 1));
    ll res = 0;
    int c = lca(a, b);
    if (c == a || c == b) {
        if(dep[a] < dep[b]) swap(a, b), swap(A, B);
        A = jump(a, dep[b]+1);
        // a 下面 b 上面
        res += fu(b, A);
        res += get_sum(a, A);
        res += single(a);
    } else {
        // 2 个
        A = jump(a, dep[c]+1);
        B = jump(b, dep[c]+1);
        res += fu2(c,A,B);
        res += get_sum(a, A);
        res += get_sum(b, B);
        res += single(a);
        res += single(b);
    }
    return res;
}

void solve() {
    cin >> n >> q;
    P = __lg(n);
    for(int i = 1;i<n;i++) {
        int u, v;
        cin >> u >> v;
        e[u].push_back(v);
        e[v].push_back(u);
    }
    dfs(1, 0);
    get_d(1, 0);
    build2(1, 0);
    build(1, 0, 0, 0);
    while(q--) {
        int a, b;
        cin >> a >> b;
        cout << calc(a, b) << "\n";
    }
}

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    int T = 1;
    // cin >> T;
    while (T--) solve();
}
```

