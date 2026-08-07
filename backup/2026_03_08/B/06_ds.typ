
#import "../lib.typ": *

= 数据结构

== 栈 (stack)

#note[简单]

== 队列 (queue)

#note[简单]

== 链表 (list)

```cpp
int main() {
    // 初始化
    std::list<int> myList = {10, 20, 30};
    // 插入
    myList.push_front(5);  // 插入到头部
    myList.push_back(40);  // 插入到尾部
    auto it = myList.begin();
    ++it;
    myList.insert(it, 15); // 在指定位置插入
    // 删除
    myList.remove(20);     // 删除值为 20 的元素
    myList.erase(it);      // 删除迭代器指向的元素
    // 排序与合并
    myList.sort();
    std::list<int> anotherList = {50, 60};
    myList.merge(anotherList);
    // 反转
    myList.reverse();
    // 遍历输出
    std::cout << "Final List: ";
    for (int x : myList) {
        std::cout << x << " ";
    }
    return 0;
}
```

== 哈希表 (unordered_map)

#note[手写哈希]

```cpp
struct HT {  // 哈希表模板
  struct data {
    long long u;
    int v, nex;
  };  // 前向星结构
  data e[SZ << 1];  // SZ 是 const int 表示大小
  int h[SZ], cnt;
  int hash(long long u) { return (u % SZ + SZ) % SZ; }
  // 这里使用 (u % SZ + SZ) % SZ 而非 u % SZ 的原因是
  // C++ 中的 % 运算无法将负数转为正数
  int& operator[](long long u) {
    int hu = hash(u);  // 获取头指针
    for (int i = h[hu]; i; i = e[i].nex)
      if (e[i].u == u) return e[i].v;
    return e[++cnt] = data{u, -1, h[hu]}, h[hu] = cnt, e[cnt].v;
  }
  HT() {
    cnt = 0;
    memset(h, 0, sizeof(h));
  }
};
```

== 并查集 

=== 优化

#note[路径压缩、启发式、按秩合并、虚点分离]

=== 并查集 (DSUPro)

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;

// 路径压缩-按秩合并(可惜有了虚点分离不能用了)+虚点分离(带删除/带移动)
struct DSUPro {
    vector<int> f,sz;
    vector<LL> sum;// sum 是一个集合的各种元素的指标
    int tot;
    // 初始化 大小为 n 的并查集 0-base 预定 m 次操作 
    // 因为 0-base 好操作 
    void init(int n,int m){
        f.resize(n*2+m);
        sz.resize(n*2+m);
        sum.resize(n*2+m);
        iota(f.begin(),f.begin()+n,n);
        iota(f.begin()+n,f.end(),n);
        fill(sz.begin(),sz.end(),1);
        tot=n*2;
        // 神秘 指标
        iota(sum.begin()+n,sum.begin()+n*2,0);
    }
    int fd(int x) { 
        if(f[x]!=x)f[x]=fd(f[x]);
        return f[x];   
    }
    void merge(int x,int y) {
        x=fd(x),y=fd(y);
        if(x==y)return;
        if(sz[x]<sz[y])swap(x,y);
        f[y]=x;
        sz[x]+=sz[y];
        sum[x]+=sum[y];
    }
    void erase(int x) {
        int fx=fd(x);
        f[x]=tot;
        --sz[fx];
        sum[fx]-=x,sum[tot]+=x;
        tot++;
    }
    void move(int x, int y) {
        int fx=fd(x),fy=fd(y);
        if(fx==fy)return;
        f[x]=fy;
        --sz[fx],++sz[fy];
        sum[fx]-=x,sum[fy]+=x;
    }
}D;

int main(){
    cin.tie(0)->sync_with_stdio(0);
    // // 1. 测试 erase
    int n, m, case_id = 0;
    while ((cin >> n >> m), n) {
        // nmbd 原来是 0-base!
        D.init(n, m);
        while(m--) {
            char ch;
            cin >> ch;
            if (ch == 'M') {
                int x, y;
                cin >> x >> y;
                D.merge(x, y);
            } else if (ch == 'S') {
                int x;
                cin >> x;
                D.erase(x);
            }
        }
        int res = 0;
        for (int i = n; i < D.tot; ++i) {
            if (D.sz[i] && i == D.fd(i)) {
                ++res;
            }
        }
        cout << "Case #" << (++case_id) << ": " << res << '\n';
    }
    // // 2. 测试 move
    // // 艹了 这也能有多测 
    // int n,op,p,q,m;
    // while(cin>>n>>m){
    //     D.init(n+1,m);
    //     while(m--){
    //         cin>>op;
    //         if(op==1){
    //             cin>>p>>q;
    //             D.merge(p,q);
    //         }else if(op==2){
    //             cin>>p>>q;
    //             D.move(p,q);
    //         }else{
    //             cin>>p;
    //             p=D.fd(p);
    //             cout<<D.sz[p]<<" "<<D.sum[p]<<"\n";
    //         }
    //     }
    // }
}
```

=== 带权并查集 (WDSU)

#note[
    包含多种类型其实

    + 拓展域并查集/种类并查集 (一个点拆分为多个状态)
    + *维护边权并查集*

    在这里说一下种类并查集:

    如果题目中的种类关系可以简单推导(如 敌对关系) \
    那么可以外开一个`enemy`数组表示对立关系(必然同一类的代表元), 在涉及合并时跟着合并/设置
]

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
struct WDSU{
    vector<int> f,sz;
    vector<LL> w;
    void init(int n){
        f.resize(n);iota(f.begin(),f.end(),0);
        sz.assign(n,1);
        w.assign(n,0);
    }
     int fd(int x) {
        if (f[x] == x) return x;
        int rt = fd(f[x]);
        w[x] += w[f[x]]; 
        return f[x] = rt;
        // w[x] = (w[x]+w[f[x]]+3)%3;// !!!维护同余关系 
    }
    bool same(int x,int y){
        return fd(x)==fd(y);
    }
    LL dist(int x,int y){
        return w[y]-w[x];
        // return (w[y]-w[x]+3)%3;// !!!维护同余关系
    }
    // y - x = d
    bool merge(int x,int y,LL d){
        int tx=x,ty=y;
        x=fd(x),y=fd(y);
        LL d0 = dist(tx,ty);
        if(x==y)return d0==d;
        if(sz[x]<sz[y])swap(x,y),d=-d,d0=-d0;
        // if(x==y)return (d0-d+3)%3==0;// !!!维护同余关系
        // y - x = d0 右侧需要增加 d-d0
        // 因为 y 是断层处所以 y 需要增加 d-d0 
        w[y]=d-d0;
        // w[y]=(d-d0+30)%3;// !!!维护同余关系
        sz[x]+=sz[y];
        f[y]=x;
        return true;
    }
    // 这是 P1196题意的操作 不可以启发式合并
    // 将 x 移动到 y 后面
    void move(int x,int y){
        x=fd(x),y=fd(y);
        if(x==y)return;
        f[x]=y;
        w[x]+=sz[y];
        sz[y]+=sz[x];
    }
}D;
int n,m,q,l,r;LL S;
void solve_P8779(){
    cin>>n>>m>>q;
    D.init(n+1);
    while(m--)cin>>l>>r>>S,D.merge(l-1,r,S);
    while(q--){
        cin>>l>>r;
        if(!D.same(l-1,r))cout<<"UNKNOWN\n";
        else cout<<D.dist(l-1,r)<<"\n";
    }
}
void solve_P2294(){
    bool ok=true;cin>>n>>m;
    D.init(n+1);
    while(m--)cin>>l>>r>>S,ok&=D.merge(l-1,r,S);
    cout<<(ok?"true":"false")<<"\n";
}
void solve_HDU3038(){
    for(int cnt=0;cin>>n>>m;cnt=0){
        D.init(n+1);
        while(m--)cin>>l>>r>>S,cnt+=(!D.merge(l-1,r,S));
        cout<<cnt<<"\n";
    }
}
void solve_P1196(){
    cin>>m;char op;
    D.init(30000+1);
    while(m--){
        cin>>op>>l>>r;
        if(op=='M')D.move(l,r);
        else cout<<(D.same(l,r)?abs(D.dist(l,r))-1:-1)<<"\n";
    }
}
void solve_P2024(){
    cin>>n>>m;int cnt=0;
    D.init(n+1);
    while(m--){
        cin>>S>>l>>r;
        if(l>n||r>n)cnt++;
        else if(S==1)cnt+=!D.merge(l,r,0);
        else if(!D.same(l,r))D.merge(l,r,1);
        else cnt+=D.dist(l,r)!=1;
    }
    cout<<cnt<<"\n";
}
// 最后还有一道 十里淘金的题 
// 给出几条声明
// 1 x v x==v
// 2 x y v x^y==v
// 3 n a_1 a_2 ... a_n 求 xor 和 
// 关键点: 
// 声明1 的头一定是 0 不能变 合并的时候 不允许改变 0 
// 查询的时候 按组求值 0 为头的一定可求 其他为头的只能出现偶数次 
int main(){
    cin.tie(0)->sync_with_stdio(0);
    // solve_P8779();
    int T;cin>>T;while(T--)solve_P2294();
    // solve_HDU3038();
    // solve_P1196();
    // solve_P2024();
}
```

=== 可撤销并查集 (RDSU)

#note[用于线段树分治等]

```cpp
struct DSU{
    int n = 0, tot = 0, fa[N], sz[N], s[N];
    void ins(){n++, fa[n] = n, sz[n] = 1;}//插入节点
    int F(int x){return fa[x] == x? x : F(fa[x]);}//即find查找函数
    void U(int x, int y){//合并函数
        x = F(x), y = F(y);
        if(x == y) return;
        if(sz[x] < sz[y]) swap(x, y);
        s[++tot] = y, fa[y] = x, sz[x] += sz[y];
    }
    void D(){//删除栈顶边
        if(!tot) return;
        int y = s[tot--]; sz[fa[y]] -= sz[y], fa[y] = y;
    }
    void back(int t = 0){while(tot > t) D();}//删除到只剩t条边
}d;
```

=== 可持久化并查集 (PDSU)

#note[见【可持久化线段树】]

== 堆

=== 二叉堆 (priority_queue)

#note[见【堆排】]

=== 配对堆 (\_\_gnu_pbds::priority_queue)

#note[
    见 pb_ds
]

=== 左偏树 

==== 普通左偏树 (LTree)

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=1e6+5;
namespace LTree{
    struct LeftistTree{
        int lc,rc,d=-1,up;// up 是直接上级 (可选)
        int val,id;// 携带信息
        bool rm;// 携带信息
        bool operator<(const LeftistTree& o)const {
            return val^o.val?val>o.val:id>o.id;
        }
    }tr[N];
    int f[N];// 内置并查集
    void init(int n){iota(f,f+1+n,0);}
    int fd(int x){if(f[x]!=x)f[x]=fd(f[x]);return f[x];}
    int merge(int x,int y){
        if(!x||!y)return x|y;
        if(tr[x]<tr[y])swap(x,y);// 默认大根堆的性质
        // x > y 
        tr[x].rc = merge(tr[x].rc,y);
        f[tr[x].rc]=x;
        // up (可选)
        tr[tr[x].rc].up = x;
        if(tr[tr[x].lc].d<tr[tr[x].rc].d)swap(tr[x].lc,tr[x].rc);
        tr[x].d = tr[tr[x].rc].d+1;
        return x;
    }
    // 仅 弹出 x 所在堆的 堆顶
    int pop(int x){
        x=fd(x);
        f[tr[x].lc]=tr[x].lc;
        f[tr[x].rc]=tr[x].rc;
        f[x]=merge(tr[x].lc,tr[x].rc);
        // up (可选)
        tr[f[x]].up=0;
        return f[x];
    }
    // 前置： up 
    int del(int x){
        int fx=fd(x);
        f[tr[x].lc]=tr[x].lc;
        f[tr[x].rc]=tr[x].rc;
        int y=merge(tr[x].lc,tr[x].rc);
        int z=tr[x].up;// 老 up
        f[x]=y;
        tr[y].up=z;// 继承上了 
        // 之前是 pop 作用
        if(fx!=x){
            tr[y].up=fx;
            (tr[z].lc==x?tr[z].lc:tr[z].rc)=y;
            for(int d=tr[y].d;tr[z].d>d+1;z=tr[z].up,d++){
                tr[z].d=d+1;
                if(tr[tr[z].lc].d<tr[tr[z].rc].d)
                    swap(tr[z].lc,tr[z].rc);
            }
        }
        tr[x].up=tr[x].lc=tr[x].rc=tr[x].d=0;
        return f[y];
    }
}using LTree::tr,LTree::f;
void solve(){
    int n,m;
    cin>>n>>m;
    LTree::init(n);// 并查集初始化
    for(int i=1;i<=n;i++)cin>>tr[i].val,tr[i].id=i;
    for(int i=1,op,x,y;i<=m;i++){
        cin>>op;
        if(op==1){
            cin>>x>>y;
            if(tr[x].rm||tr[y].rm)continue;
            int fx=LTree::fd(x),fy=LTree::fd(y);
            if(fx==fy)continue;// wc 写成 return 了 !!!
            int rt = LTree::merge(fx,fy);
            f[rt]=rt;
        }else if(op==2){
            cin>>x;
            if(tr[x].rm){
                cout<<-1<<'\n';
            }else {
                int fx=LTree::fd(x);
                cout<<tr[fx].val<<'\n';
                // pop(fx);
                LTree::del(fx);
                tr[fx].rm=true;
            }
        }else assert(0&&"INVALID OP");
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

#note[
  PS:
  1. 合并前要检查是否*已经在同一堆中*。
  2. 左偏树的深度可能达到 $O(n)$ 因此找一个点所在的堆顶要用并查集维护，*不能*直接暴力跳父亲。
]

==== 懒更新左偏树 (LLTree)

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=2e6+5;
namespace LLTree{
    struct LazyLeftistTree{
        int lc,rc,d;
        LL val,add,mul=1;// 少用
        bool lz;
        bool operator<(const LazyLeftistTree& o)const {
            return val>o.val;
        }
    }tr[N];// 城市树某一节点上的
    void lazy_add(int x,LL v){
        tr[x].val+=v;tr[x].add+=v;
        tr[x].lz=1;
    }
    void lazy_mul(int x,LL v){
        tr[x].val*=v;tr[x].mul*=v;tr[x].add*=v;
        tr[x].lz=1;
    }
    void down(int x){
        if(tr[x].lz){
            lazy_mul(tr[x].lc,tr[x].mul);
            lazy_mul(tr[x].rc,tr[x].mul);
            tr[x].mul=1;
            lazy_add(tr[x].lc,tr[x].add);
            lazy_add(tr[x].rc,tr[x].add);
            tr[x].add=0;
            tr[x].lz=0;
        }
    }
    int merge(int x,int y){
        if(!x||!y)return x|y;
        down(x);down(y);
        if(tr[x]<tr[y])swap(x,y);
        tr[x].rc=merge(tr[x].rc,y);
        if(tr[tr[x].lc].d<tr[tr[x].rc].d)swap(tr[x].lc,tr[x].rc);
        tr[x].d=tr[tr[x].rc].d+1;
        return x;
    }
    int pop(int x){return merge(tr[x].lc,tr[x].rc);}
}using LLTree::tr;

// fa[] 城市树结构 a[]奖励类型 dep[] 城市树深度 
// top[] 城市树某一节点对应的左偏树根编号
int n,m,fa[N],a[N],dep[N],top[N],die[N],ans[N];
// v[] 奖励值 h[] 城市防御值
LL v[N],h[N];
// 约束：x 是堆顶，请弹出 返回新的堆顶

void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>h[i];
    for(int i=2;i<=n;i++)cin>>fa[i]>>a[i]>>v[i];
    for(int i=1;i<=n;i++)dep[i]=dep[fa[i]]+1;
    for(int c,i=1;i<=m;i++){
        cin>>tr[i].val>>c;
        ans[i]=dep[c];
        top[c]=LLTree::merge(top[c],i);
    }
    for(int i=n;i>=1;i--){
        while(top[i]){
            LLTree::down(top[i]);
            if(tr[top[i]].val<h[i]){
                die[i]++;
                ans[top[i]]-=dep[i];
                top[i]=LLTree::pop(top[i]);
            }else break;
        }
        if(top[i]){
            if(a[i]==0)LLTree::lazy_add(top[i],v[i]);
            else LLTree::lazy_mul(top[i],v[i]);
            top[fa[i]]=LLTree::merge(top[i],top[fa[i]]);
        }
    }
    for(int i=1;i<=n;i++)cout<<die[i]<<'\n';
    for(int i=1;i<=m;i++)cout<<ans[i]<<'\n';
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

== 块状数据结构 

=== 块状数组 (BArray)

#note[
    分块原理
    + 分块数据结构维护信息时 块内的信息暴力维护 整块的信息修改标签即可
    + 区间修改 区间查询 最多处理 *左散块 + 中间若干整块 + 右散块* 即可 块内块间均为 $O(sqrt(n))$
    
    分块使用场景
    + *区间不可合并* 的信息 线段树难以维护
    + 分块维护信息很容易, 会衍生处很多强大变体.
    + 分块好想 好写 常数小
    + 题目思维难度大时 如果分块的做法已经很难 那么更优的结构只会更难 (启示: *没有思路想想分块*)
    + 分块的递归非必需 收益高

    *分块卡常*
    + 块间操作常数时间较大时 增加块长
    + 块内操作常数时间较大时 减少块长
]

#note(title:"模板题1")[
    区间增加 区间查询
]

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=1e6+5;
const int B=1e3+100;

/* 这是一个区间增加 区间查询个数的 code */
/* 
还有一种 code(未给出) 是解决 区间设置 区间查询个数的 code 同样需要sort_block
只需要定义 d[] 为块区间设置标记即可
*/
struct BArray{
    int n,len,bn;// 参数
    LL a[N],t[N];// a原数组 辅助数组
    int id[N];// 所属块编号
    int st[B],ed[B],sz[B];// 块基本信息
    LL tag[B];// 块附加信息
    void build(int n){
        this->n=n;// n
        len=sqrt(n);// len
        bn=(n+len-1)/len;// bn 向上取整
        // B 规模
        for(int i=1;i<=bn;i++){
            // 基本信息初始化
            st[i]=(i-1)*len+1;// st
            ed[i]=min(n,i*len);// ed
            sz[i]=ed[i]-st[i]+1;// sz
            fill(id+st[i],id+ed[i]+1,i);// 批量赋值 id
            _sort(st[i],ed[i]);// 【警告】build 的时候也要sort啊啊啊
            // 附加信息初始化
            tag[i]=0;// tag 
        }
    }
    // 暴力排序
    void _sort(int l,int r){
        memcpy(t+l,a+l,sizeof(a[0])*(r-l+1));
        sort(t+l,t+r+1);
    }
    // 暴力增加
    void _add(int l,int r,LL v){
        for(int i=l;i<=r;i++)a[i]+=v;
    }
    // 暴力查询
    int _ge(int l,int r,LL v){
        int res=0;
        for(int i=l;i<=r;i++)res+=(a[i]>=v);
        return res;
    }
    void add(int l,int r,LL v){
        int L=id[l],R=id[r];
        if(L==R){
            _add(l,r,v);_sort(st[L],ed[L]);// 
        }else {
            for(int I=L+1;I<R;I++)
                tag[I]+=v;
            _add(l,ed[L],v);_sort(st[L],ed[L]);// 
            _add(st[R],r,v);_sort(st[R],ed[R]);// 
        }
    }
    int ge(int l,int r,LL v){
        int res=0,L=id[l],R=id[r];
        if(L==R){
            res+=_ge(l,r,v-tag[L]);
        }else {
            for(int I=L+1;I<R;I++)
                res+=sz[I]-(lower_bound(t+st[I],t+ed[I]+1,v-tag[I])-t-st[I]);
            res+=_ge(l,ed[L],v-tag[L]);
            res+=_ge(st[R],r,v-tag[R]);
        }
        return res;
    }
}A;
void solve(){
    int n,q,l,r,v;cin>>n>>q;char op;
    for(int i=1;i<=n;i++)cin>>A.a[i];
    A.build(n);
    while(q--){
        cin>>op>>l>>r>>v;
        if(op=='M')A.add(l,r,v);
        else cout<<A.ge(l,r,v)<<"\n";
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

#note(title:"模板题2")[
    - 无修改 查询区间众数
    - `freq[i][j], mode[i][j]` 的使用
]

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=4e4+5;
const int B=2e2+100;
struct BArray{
    int n,len,bn;
    int a[N];
    int id[N];
    int st[N],ed[N];
    int freq[B][N],mode[B][B],cnt[N];
    void build(int n){
        this->n=n;
        len=sqrt(n);
        bn=(n+len-1)/len;
        for(int i=1;i<=bn;i++){
            st[i]=(i-1)*len+1;
            ed[i]=min(n,st[i]+len-1);
            fill(id+st[i],id+ed[i]+1,i);// 
        }
        // DIY...
        fill(freq[0],freq[0]+n+1,0);
        for(int i=1;i<=bn;i++){// O(sqrt(n))
            memcpy(freq[i],freq[i-1],sizeof(freq[i][0])*(n+1));// O(n)
            for(int j=st[i];j<=ed[i];j++)freq[i][a[j]]++;// O(sqrt(n))
        }// 共 O(n sqrt(n))
        int best;
        for(int i=1;i<=bn;i++){// O(sqrt(n))
            best=0;
            for(int j=i;j<=bn;j++){// O(sqrt(n))
                mode[i][j]=mode[i][j-1];// [!!!] !!! 
                for(int k=st[j];k<=ed[j];k++){// O(sqrt(n))
                    ++cnt[a[k]];
                    if(cnt[a[k]]>cnt[best]||cnt[a[k]]==cnt[best]&&a[k]<best)
                    best=a[k];
                }
                mode[i][j]=best;
            }// 共 O(n)
            fill(cnt,cnt+1+n,0);// O(n) clear !!!
        }// 共 O(n sqrt(n))
    }
    int query(int l,int r){
        int L=id[l],R=id[r];
        if(L==R){
            int best=0;
            for(int i=l;i<=r;i++){
                cnt[a[i]]++;
                if(cnt[a[i]]>cnt[best]||cnt[a[i]]==cnt[best]&&a[i]<best)
                best=a[i];
            }
            for(int i=l;i<=r;i++)cnt[a[i]]--;// !!!
            return best;
        }else {
            #define total(x) (cnt[x]+freq[R-1][x]-freq[L][x])
            int best=mode[L+1][R-1];
            for(int i=l;i<=ed[L];i++){
                cnt[a[i]]++;
                if(total(a[i])>total(best)||total(a[i])==total(best)&&a[i]<best)
                    best=a[i];
            }
            for(int i=st[R];i<=r;i++){
                cnt[a[i]]++;
                if(total(a[i])>total(best)||total(a[i])==total(best)&&a[i]<best)
                    best=a[i];
            }
            for(int i=l;i<=ed[L];i++)cnt[a[i]]--;// !!!
            for(int i=st[R];i<=r;i++)cnt[a[i]]--;// !!!
            #undef total
            return best;
        }
    }
}A;
int n,m,l,r,lst;
int a[N],b[N],cntA;
void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>a[i],b[++cntA]=a[i];
    sort(b+1,b+1+cntA);
    cntA=unique(b+1,b+1+cntA)-b-1;
    for(int i=1;i<=n;i++)A.a[i]=lower_bound(b+1,b+1+cntA,a[i])-b;
    A.build(n);
    while(m--){
        cin>>l>>r;
        l=(l+lst-1)%n+1;
        r=(r+lst-1)%n+1;
        if(l>r)swap(l,r);
        cout<<(lst=b[A.query(l,r)])<<"\n";
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

#note(title:"模板题3")[
    - 少量空间 查询区间众数*次数*
    - `array<int,2> sort_list[i], mode_cnt[i][j]` 的使用
]

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=5e5+5;
const int B=8e2+5;
struct BArray{
    int n,len,bn;
    int a[N];
    array<int,2> sort_list[N];
    int pos[N];
    int id[N];
    int st[B],ed[B];
    int mode_cnt[B][B],cnt[N];
    void build(int n){
        this->n=n;
        len=sqrt(n);
        bn=(n+len-1)/len;
        for(int i=1;i<=bn;i++){
            st[i]=i*len-len+1;
            ed[i]=min(n,st[i]+len-1);
            fill(id+st[i],id+ed[i]+1,i);
        }
        // DIY...
        for(int i=1;i<=bn;i++){
            int best_cnt=0;
            for(int j=i;j<=bn;j++){
                for(int k=st[j];k<=ed[j];k++){
                    ++cnt[a[k]];
                    if(cnt[a[k]]>best_cnt)best_cnt=cnt[a[k]];
                }
                mode_cnt[i][j]=best_cnt;
            }
            fill(cnt,cnt+1+n,0);
        }
        // sort_list pos
        for(int i=1;i<=n;i++)sort_list[i]={a[i],i};
        sort(sort_list+1,sort_list+1+n);
        for(int i=1;i<=n;i++)pos[sort_list[i][1]]=i;
    }
    int query(int l,int r){
        int L=id[l],R=id[r];
        if(L==R){
            int best_cnt=0;
            for(int i=l;i<=r;i++)if(++cnt[a[i]]>best_cnt)best_cnt=cnt[a[i]];
            for(int i=l;i<=r;i++)cnt[a[i]]--;
            return best_cnt;
        }else {
            int best_cnt=mode_cnt[L+1][R-1];
            for(int i=l;i<=ed[L];i++){
                int p=pos[i];// pos[i] !!!
                while(p+best_cnt<=n&&sort_list[p+best_cnt][0]==a[i]&&sort_list[p+best_cnt][1]<=r)
                    best_cnt++;
            }
            for(int i=st[R];i<=r;i++){
                int p=pos[i];// pos[i] !!!
                while(p-best_cnt>=1&&sort_list[p-best_cnt][0]==a[i]&&sort_list[p-best_cnt][1]>=l)
                    best_cnt++;
            }
            return best_cnt;
        }
    }
}A;
int n,m,lst,l,r;
void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>A.a[i];
    A.build(n);// [!!!] CD
    while(m--){
        cin>>l>>r;l^=lst;r^=lst;
        if(l>r)swap(l,r);
        cout<<(lst=A.query(l,r))<<"\n";
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

#note(title:"更多 分块 code")[
    + (P4135 在线查询 `[l,r]` 范围内正偶数次出现的次数)
        - `freq[i][j]` 的应用
    + (P5356 由乃打扑克)
        - `[l,r]` 第 `k` 小的数
        - `[l,r]` 区间加 `v` 
        - 二分答案
    + (P3863 序列)
        - `[l,r]` 区间加 `v`
        - 查询 `a[p]>=v` 的时间戳数量
        - *时间分块*: 
            + 离线处理,将查询挂在 `p` 上
            + 每一个区间加 换为在时间轴上的后缀差分 挂在 `l` 和 `r+1` 上
            + `p` 从 1 开始往右扫, 先处理 修改, 再处理 查询
            + 每次查询 即为 `tag[i]>=v-a[p], i<query_time[i]` 的数量
            + 即 题目转化为 *模板题1*
                + 区间加减
                + 区间查询大于某个数的数量
    + (CF198E 磁力块)
        - 初始有一个磁力(质量<=磁力),半径(在半径内) 问最终能吸引多少个磁力块
        - *分块bfs*:
            + 按质量排序 分块
            + 块内按照距离重排 记录块内质量最大值
            + case 
                - 质量足够 -> 按照距离逐个加入 $O(sqrt(n))$ 次访问
                - 质量不够(本层结束) -> 按照距离逐个加入  
                - 共 $O(n sqrt(n))$ 的复杂度
    + (P5046 区间逆序对)
        - 在线查询区间逆序对数量
        - *整散分类讨论 + 区间块dp*:
            + `int f(X,xl,xr,Y,yl,yr)` 使用 *双指针* 计算块间逆序对数量
            + `int pre[i][j],int suf[i][j]` 维护块内前后缀逆序对数量
            + `cnt[i][j]` 维护前缀块内 `<=j` 的个数(辅助信息)
            + `dp[l][r]` 维护区间 `[l,r]` 内逆序对个数(区间容斥dp) 
                - `dp[l][r]=dp[l+1][r]+dp[l][r-1]-dp[l+1][r-1]+f(l,st[l],ed[l],r,st[r],ed[r])` 
        - 存在卡常 由于块内处理多一个 BIT log 应该适当减少块长
]

=== 块状链表 (rope)

#note[
    *可持久化块状数组* 

    rope 教程了属于是 
    - ```cpp #include<ext/rope>```
    - ```cpp using namespace __gnu_cxx```
    + `insert(pos,c_str)`
    + `erase(pos,n)`
    + `substr(pos,n)`
    + `copy(pos,k,c_str)`
    + `at(pos)`
]

```cpp
#include<bits/stdc++.h>
#include<ext/rope>
using namespace std;
using namespace __gnu_cxx;
int main(){
    // freopen("rope.in","r",stdin);
    int q,n,k,pos=0;
    rope<char> S;
    string op,s;
    cin>>q;
    while(q--){
        cin>>op;
        if(op=="Move"){
            cin>>k;
            pos=k;
        }else if(op=="Insert"){
            cin>>n;
            s.clear();
            while(n--){
                char c;
                while((c=getchar())=='\n');
                s+=c;
            }
            S.insert(pos,s.data());
        }else if(op=="Delete"){
            cin>>n;
            S.erase(pos,n);
        }else if(op=="Get"){
            cin>>n;
            cout<<S.substr(pos,n)<<"\n";
        }else if(op=="Prev"){
            pos--;
        }else if(op=="Next"){
            pos++;
        }else if(op=="At"){
            cin>>k;
            cout<<S.at(k)<<"\n";
        }else if(op=="Replace"){
            cin>>k>>n>>s;
            S.copy(pos,k,s.data());
        }
    }
}
```

=== 树分块

#note(title:"重链序列分块")[
    重链剖分之后
    
    对节点 *dfn 序号* 进行分块

    适用于 *子树*(dfn 序 连续) *路径*(log 条链) 的修改/查询问题

    单次子树操作 $O(sqrt(n))$
    单次路径操作 $O(sqrt(n) log n)$
]

#note(title:"随机撒点分块")[
    随机选 $sqrt(n)$ 个点作为关键点 距离期望 $O(sqrt(n))$
    - *非关键点* 和其他最近的 *关键点* 之间视为 *散块*
    - 两个相邻的 *关键点* 之间视为 *整块* 
]

#note(title:"更多 树分块 code")[
    + (CF1491H 区间父变小)
        - 神秘的区间 `fa[i]-=v` 
        - 查询 `lca(x,y)`
        - `fa[x], out[x]` 的设计: 跳一级 / 跳一块
        - 关于块操作结果 关于 操作次数的结论: 整块操作次数>=len 即收敛
]

=== 分块技巧

==== 双层分块

#note(title:"题目1 ")[
    + `[l,r]` 区间 `x` 改为 `y`
    + `[l,r]` 区间 查询第 `k` 小值
    - 序列分块 + 值域分块
]

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=1e5+5;
const int B=405;
struct B2Array{
    int n,len,bn,vn;
    int a[N];
    int id[N];
    int st[B],ed[B];
    // 前 i 个序列块中 处于第 j 个值域块的 个数
    // 前 i 个序列块中 值 j 的个数
    int sumB[B][B],sumV[B][N];
    // 临时散块计数
    int cntB[B],cntV[N];
    // [位置-集合-值 三位一体]
    // 第 i 个位置 所属集合 
    // 第 i 块值 j 所属集合
    // 第 i 块集合 j 所对应的值
    // 为什么这么搞 因为每次修改都是重新编号的 保证空间复用 
    int set_id[N];
    int val_set[B][N],set_val[B][B];
    void build(int n){
        this->n=n;
        // len=sqrt(max(n,*max_element(a+1,a+1+n)));
        len=400;
        bn=(n+len-1)/len;
        vn=(N-1+len-1)/len;
        for(int i=1;i<N;i++)id[i]=(i-1)/len+1;// 为了 val 分块
        for(int i=1;i<=bn;i++){
            st[i]=(i-1)*len+1;
            ed[i]=min(n,st[i]+len-1);
            // fill(id+st[i],id+ed[i]+1,i); // 有 val 分块
        }
        // DIY...
        for(int i=1;i<=bn;i++){
            memcpy(sumB[i],sumB[i-1],sizeof(sumB[i]));
            memcpy(sumV[i],sumV[i-1],sizeof(sumV[i]));
            for(int k=st[i];k<=ed[i];k++){
                sumB[i][id[a[k]]]++;
                sumV[i][a[k]]++;
            }
            rebuild(i);
        }
    }
    // 暴力
    void rebuild(int I){
        for(int i=1;i<=len;i++)val_set[I][set_val[I][i]]=0;// 把所有涉及到的集合 清空 
        for(int i=st[I],s=0;i<=ed[I];i++){
            int v=a[i];
            if(!val_set[I][v]){
                val_set[I][v]=++s;
                set_val[I][s]=v;
            }
            set_id[i]=val_set[I][v];
        }
    }
    // 暴力
    void down(int I){
        for(int i=st[I];i<=ed[I];i++)
            a[i]=set_val[I][set_id[i]];// 我这个位置对应的集合的值是什么
    }
    // 暴力 change
    void change(int I,int l,int r,int x,int y){
        // 既然都 暴力了 我暴力一个 down 没什么吧
        down(I);
        int X=(x-1)/len+1,Y=(y-1)/len+1;
        for(int i=l;i<=r;i++){
            if(a[i]==x){
                sumB[I][X]--;sumB[I][Y]++;
                sumV[I][x]--;sumV[I][y]++;
                a[i]=y;
            }
        }
        // 既然都 暴力了 我暴力一个 rebuild 没什么吧
        rebuild(I);
    }
    // 有 x 无 y 懒住 
    void lazy(int I,int x,int y){
        val_set[I][y]=val_set[I][x];// fa[y]=fa[x] 顶替 x, 值对应的集合发生移动
        val_set[I][x]=0;// 本质上是 位置-集合-值 的三级关系
        set_val[I][val_set[I][y]]=y;// fa[y] 的值设置为 y
    }
    // 修改 l r 范围内的 x 变为 y
    void modify(int l,int r,int x,int y){
        int L=id[l],R=id[r];
        // 粗略剪枝
        if(x==y||sumV[R][x]-sumV[L-1][x]==0)return;
        int X=id[x],Y=id[y];
        // 前缀差分
        for(int i=vn;i>=L;i--){
            sumB[i][X]-=sumB[i-1][X];
            sumB[i][Y]-=sumB[i-1][Y];
            sumV[i][x]-=sumV[i-1][x];
            sumV[i][y]-=sumV[i-1][y];
        }
        if(L==R){
            // 需要更新的信息:
            // 1 sumB sumV x 变成 y 的块变动 值变动
            // 2 val_set set_val 这是整块的信息 不需要变动
            change(L,l,r,x,y);
        }else {
            // 左右散块仍然是 暴力
            change(L,l,ed[L],x,y);
            change(R,st[R],r,x,y);
            // 中间的块看是否有 y 
            for(int i=L+1;i<=R-1;i++){
                if(!sumV[i][x])continue;// 必然无更改
                if(!sumV[i][y]){// 注意这里已经差分完成了
                    // sum 信息快速维护
                    sumB[i][X]-=sumV[i][x];
                    sumB[i][Y]+=sumV[i][x];
                    sumV[i][y]+=sumV[i][x];
                    sumV[i][x]=0;
                    // 懒住了
                    lazy(i,x,y);
                }else change(i,st[i],ed[i],x,y);
            }
        }
        // 前缀和
        for(int i=L;i<=vn;i++){
            sumB[i][X]+=sumB[i-1][X];
            sumB[i][Y]+=sumB[i-1][Y];
            sumV[i][x]+=sumV[i-1][x];
            sumV[i][y]+=sumV[i-1][y];
        }
    }
    void add(int l,int r){
        for(int i=l;i<=r;i++)cntB[id[a[i]]]++;
        for(int i=l;i<=r;i++)cntV[a[i]]++;
    }
    void del(int l,int r){
        for(int i=l;i<=r;i++)cntB[id[a[i]]]--;
        for(int i=l;i<=r;i++)cntV[a[i]]--;
    }
    // 查询 l r 范围内的第 k 小
    int kth(int l,int r,int k){
        int L=id[l],R=id[r];
        bool inner=L==R;
        if(inner){
            down(L);add(l,r);
        }else {
            down(L);add(l,ed[L]);
            down(R);add(st[R],r);
        }
        int b,v;
        for(b=1;b<=vn;b++){
            int tk=cntB[b]+(inner?0:sumB[R-1][b]-sumB[L][b]);
            if(k<=tk)break;
            k-=tk;
        }
        // 第 b 块的第几个值?
        for(v=(b-1)*len+1;v<=b*len;v++){
            int tk=cntV[v]+(inner?0:sumV[R-1][v]-sumV[L][v]);
            if(k<=tk)break;
            k-=tk;
        }
        if(inner){
            del(l,r);
        }else{
            del(l,ed[L]);
            del(st[R],r);
        }
        return v;
    }
}A;
int n,m,op,l,r,x,y,k;
void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>A.a[i];
    A.build(n);
    while(m--){
        cin>>op;
        if(op==1){
            cin>>l>>r>>x>>y;
            A.modify(l,r,x,y);
        }else {
            cin>>l>>r>>k;
            cout<<A.kth(l,r,k)<<"\n";
        }
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

#note(title:"题目2")[
    + `a[x]` 改为 `y`
    +  `[l,r]` 区间查询 `max <= x` 的子数组个数
    - 基数排序plus 提速!!!
    - *离线*收集 + *按块结算* + 增量求`ans` 技术!!!
    - 其余的就是 关于计算答案的*小巧思*
]

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=3e5+5;
const int B=605;
const int OFFSET=10;
const int BASE=1<<OFFSET;
const int MASK=BASE-1;
// op==1 x 位置改为 y
// op==2 [l..r] 区间内有多少值小于 x
namespace B2Array{
    // 基础分块
    int n,m,len,bn;
    int a[N];
    int id[N];
    int st[B],ed[B];
    // 整块求解辅助
    int pos[N],prev[N],next[N];
    // 基数排序辅助
    int cnt[BASE],help[N];
    // 查询: 只能散着来了 !!!
    int qid[N],op[N],qx[N],qy[N],ql[N],qr[N];
    int pre[N],suf[N];LL ans[N];
    void build(int nn){
        n=nn;
        len=sqrt(n);
        bn=(n+len-1)/len;
        for(int i=1;i<=bn;i++){
            st[i]=(i-1)*len+1;
            ed[i]=min(n,st[i]+len-1);
            fill(id+st[i],id+ed[i]+1,i);
        }
    }
    // 将索引 idx 按照 key[idx] 大小排序 
    void radix(int* idx,int* key,int l,int r){
        // [特别特别特别注意]
        // 前提要保证 OFFSET*len 的位数覆盖了 key[] 的值域
        // 否则 请保证 最后的一趟排序 不取 MASK(cnt[]要适当开大) 
        for(int d=0;d<OFFSET*2;d+=OFFSET){
            fill(cnt,cnt+BASE,0);
            for(int i=l;i<=r;i++)cnt[key[idx[i]]>>d&MASK]++;
            for(int i=1;i<BASE;i++)cnt[i]+=cnt[i-1];// BASE !!!!
            for(int i=r;i>=l;i--)help[cnt[key[idx[i]]>>d&MASK]--]=idx[i];
            memcpy(idx+l,help+1,sizeof(idx[0])*(r-l+1));
        }
    }
    // 暴力 计算 l r 范围内的 信息
    void calc(int l,int r,int x,LL& q_ans,int& q_pre,int& q_suf,int& q_sz){
        q_ans=q_pre=q_suf=q_sz=0;
        int cn=0;
        for(int i=l;i<=r;i++){
            if(a[i]<=x)q_ans+=++cn;
            else cn=0;
        }
        while(l+q_pre<=r&&a[l+q_pre]<=x)q_pre++;
        while(r-q_suf>=l&&a[r-q_suf]<=x)q_suf++;
        q_sz=r-l+1;
    }
    // 按块 将若干信息合并到 q_id 上去
    void merge(int q_id,LL q_ans,int q_pre,int q_suf,int q_sz){
        ans[q_id]+=q_ans+suf[q_id]*q_pre;
        suf[q_id]=q_suf+(q_suf==q_sz?suf[q_id]:0);
    }
    int buf[N];
    void compute(int l,int r){
        int tp=0;
        // 筛选相关操作 
        for(int i=1;i<=m;i++){
            if(op[qid[i]]==1){
                if(qx[qid[i]]>=l&&qx[qid[i]]<=r)buf[++tp]=qid[i];
            }else if(ql[qid[i]]<=r&&qr[qid[i]]>=l)buf[++tp]=qid[i];
        }
        // 开工
        for(int i=1;i<=tp;i++){
            if(op[buf[i]]==1){
                // 暴力更新
                a[qx[buf[i]]]=qy[buf[i]];
            }else {
                int s=i;
                while(i<=tp&&op[buf[i]]==2)i++;
                i--;
                // 收割
                // 构建链表
                for(int j=l-1;j<=r+1;j++){
                    pos[j]=j;
                    prev[j]=j-1;
                    next[j]=j+1;
                }
                // 逐个启用
                radix(pos,a,l,r);
                // 询问从小到大
                radix(buf,qx,s,i);
                int cur_pre=0,cur_suf=0,cur_sz=(r-l+1);LL cur_ans=0;
                int p=l;
                for(int j=s;j<=i;j++){
                    int q_id=buf[j];
                    if(ql[q_id]<=l&&r<=qr[q_id]){
                        // 全包 正常处理
                        while(p<=r&&a[pos[p]]<=qx[q_id]){
                            cur_ans+=(pos[p]-prev[pos[p]])*(next[pos[p]]-pos[p]);
                            prev[next[pos[p]]]=prev[pos[p]];
                            next[prev[pos[p]]]=next[pos[p]];
                            cur_pre=next[l-1]-l;// 
                            cur_suf=r-prev[r+1];// 
                            p++;
                        }
                        merge(q_id,cur_ans,cur_pre,cur_suf,cur_sz);
                    }else {
                        // 散块 立即暴力
                        int q_pre,q_suf,q_sz;LL q_ans;
                        calc(max(l,ql[q_id]),min(r,qr[q_id]),qx[q_id],q_ans,q_pre,q_suf,q_sz);
                        merge(q_id,q_ans,q_pre,q_suf,q_sz);
                    }
                }
            }
        }
    }
    void solve(int mm){
        m=mm;
        for(int i=1;i<=bn;i++)compute(st[i],ed[i]);
    }
}using B2Array::qid,B2Array::ql,B2Array::qr,B2Array::qx,B2Array::qy,B2Array::op;
int n,m;
void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>B2Array::a[i];
    B2Array::build(n);
    for(int i=1;i<=m;i++){
        cin>>op[i];
        qid[i]=i;// [!!!]
        if(op[i]==1)cin>>qx[i]>>qy[i];
        else cin>>ql[i]>>qr[i]>>qx[i];
    }
    B2Array::solve(m);
    for(int i=1;i<=m;i++)
        if(op[i]==2)cout<<B2Array::ans[i]<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

#note(title:"题目3")[
    + `[l,r]` 区间 大于 `x` 的数减去 `x`
    + `[l,r]` 区间 查询 `x` 的出现次数
    - *真·并查集* 
    - *全局差分转化+类根号分治* 控制复杂度的懒信息维护方式
]

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=1e6+5;
const int B=1e3+5;
// 1 l r x [l..r] 大于 x 的数字减去 x
// 2 l r x [l..r] 查询 x 的个数
namespace B2Array{
    // 基础分块
    int n,m,len,bn;
    int a[N];
    int id[N];
    int st[B],ed[B];
    // 答案辅助
    int cnt[N],lazy,maxv,pre0[N];
    // 查询数据
    int op[N],ql[N],qr[N],qx[N],ans[N];
    void build(int nn){
        n=nn;
        len=sqrt(n);
        bn=(n+len-1)/len;
        for(int i=1;i<=bn;i++){// bn!!!
            st[i]=(i-1)*len+1;
            ed[i]=min(n,st[i]+len-1);
            fill(id+st[i],id+ed[i]+1,i);
        }
        for(int i=1;i<=n;i++)pre0[i]=pre0[i-1]+(a[i]==0);
    }
    // 并查集
    int f[N];
    int find(int x){
        return f[x]==x?x:f[x]=find(f[x]);
    }
    // 并查集 contract 结算
    void down(int l,int r){
        for(int i=l;i<=r;i++)a[i]=find(a[i]);
    }
    // 修改操作 
    void sub(int q_i,int l,int r){
        int q_l=ql[q_i],q_r=qr[q_i],q_x=qx[q_i];
        if(q_l<=l&&q_r>=r){// 整块lazy 总体 O(v)
            if(q_x>=maxv-lazy)return;// 没有影响 直接跳过保证势能 O(v)
            if(q_x*2<=maxv-lazy){
                // 较小的数 += q_x 
                // 存储状况 最大值不变
                for(int i=1+lazy;i<=q_x+lazy;i++){
                    cnt[i+q_x]+=cnt[i];
                    cnt[i]=0;
                    f[i]=f[i+q_x];
                }
                lazy+=q_x;
            }else {
                // 存储状况 最大值 -=q_x
                for(int i=maxv;i>q_x+lazy;i--){
                    cnt[i-q_x]+=cnt[i];
                    cnt[i]=0;
                    f[i]=f[i-q_x];
                }
                // maxv-=q_x;// [WC] 这里不对 你想错了 maxv 不会继承!!!
                // [!!!!!]
                // down 之后 如果没有修改 直接O(1)退出 否则总势能O(v)退出
                for(int i=maxv;i>=0;i--){
                    if(cnt[i]){
                        maxv=i;
                        break;
                    }
                }
            }
        }else {// 散块暴力 O(sqrt(n))
            down(l,r);
            for(int i=max(l,q_l);i<=min(r,q_r);i++)
                if(a[i]>q_x+lazy){
                    cnt[a[i]]--;
                    a[i]-=q_x;// [hyw] !!!!!!!!!
                    cnt[a[i]]++;
                }
            // [!!!!!]
            // down 之后 如果没有修改 直接O(1)退出 否则总势能O(v)退出
            for(int i=maxv;i>=0;i--){
                if(cnt[i]){
                    maxv=i;
                    break;
                }
            }
        }
    }
    // 查询操作 
    void query(int q_i,int l,int r){
        int q_l=ql[q_i],q_r=qr[q_i],q_x=qx[q_i];
        if(q_l<=l&&q_r>=r){// 整块 O(1)
            ans[q_i]+=cnt[q_x+lazy];
        }else {// 散块暴力O(sqrt(n))
            down(l,r);
            // down 之后 如果没有修改 直接O(1)退出 否则总势能O(v)退出
            for(int i=maxv;i>=0;i--){
                if(cnt[i]){
                    maxv=i;
                    break;
                }
            }
            for(int i=max(l,q_l);i<=min(r,q_r);i++)
                if(a[i]==q_x+lazy)ans[q_i]++;
        }
    }
    void compute(int l,int r){
        // 每一块的查询都初始化
        lazy=0;maxv=0;// lazy maxv
        iota(f,f+N,0);// f
        fill(cnt,cnt+N,0);// cnt
        // 填入 cnt maxv 
        for(int i=l;i<=r;i++)cnt[a[i]]++,maxv=max(maxv,a[i]);
        for(int i=1;i<=m;i++){
            if(op[i]==2&&qx[i]==0)continue;// 到时候
            if(ql[i]>r||qr[i]<l)continue;// 无关询问 过滤掉
            int q_i=i;
            if(op[i]==1)sub(q_i,l,r);
            else query(q_i,l,r);
        }
    }
    void solve(int mm){
        m=mm;
        for(int i=1;i<=bn;i++)compute(st[i],ed[i]);
        for(int i=1;i<=m;i++)if(op[i]==2&&qx[i]==0)
            ans[i]=pre0[qr[i]]-pre0[ql[i]-1];
    }
}using B2Array::op,B2Array::ql,B2Array::qr,B2Array::qx,B2Array::ans;
int n,m;
void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>B2Array::a[i];
    B2Array::build(n);
    // cout<<"build!\n";
    for(int i=1;i<=m;i++)cin>>op[i]>>ql[i]>>qr[i]>>qx[i];
    B2Array::solve(m);
    // cout<<"solve!\n";
    for(int i=1;i<=m;i++)
        if(op[i]==2)cout<<ans[i]<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

==== 时间分块与可撤销并查集

#note(title:"题目1")[
    无向图 
    + `1 e w` 修改边权
    + `2 s w` 求以 s 为起点只能走>=w的桥的可达点数
    - 时间分块 加速 可撤销并查集
]

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=5e4+5,M=1e5+5;
const int B=4e2+5;
// 1 x y 将 x 边权设置为 y
// 2 x y 在 x 点出发 边权>=y 的点数
namespace B3Array{
    // 可撤销并查集
    int tp;
    int f[N],sz[N];
    array<int,2> stk[N];
    int find(int x){
        return f[x]==x?x:find(f[x]);
    }
    void merge(int x,int y){
        int fx=find(x),fy=find(y);
        if(fx==fy)return;
        if(sz[fx]<sz[fy])swap(fx,fy);
        f[fy]=fx;
        sz[fx]+=sz[fy];
        stk[++tp]={fx,fy};
    }
    void back(){
        auto [fx,fy]=stk[tp--];
        f[fy]=fy;
        sz[fx]-=sz[fy];
    }
    
    // 这里的 q 是操作数量 m 是边数量 n 是点数量
    int q,m,n,len,bn;
    // 基本量
    array<int,2> e[M];// 边属性
    int w[M],cur_w[M];// 边属性
    bool change[M];// 边属性
    int edge[M];// 边编号 全局
    // 操作
    struct Node{int op,x,y;}Q[M];// 操作属性
    int update[M],query[M],cntu,cntq;// 操作编号 动态
    // 答案
    int ans[M];
    void build(){
        // [[[[[NB!!!!!]]]]] 真得分析复杂度!!! 卡常!!!!  
        // [[[[[NB!!!!!]]]]] 真得分析复杂度!!! 卡常!!!!  
        // [[[[[NB!!!!!]]]]] 真得分析复杂度!!! 卡常!!!!  
        // f(t)/x + g(t)x -> x= sqrt(f(t)g(t)) 
        // f(t)/x + g(t)x -> x= sqrt(f(t)g(t)) 
        // f(t)/x + g(t)x -> x= sqrt(f(t)g(t)) 
        len=sqrt(q*__lg(n+2));
        bn=(q+len-1)/len;
    }
    // sqrt(q)*(n+m+sqrt(q)+sqrt(q)logq+sqrt(q)*sqrt(q)logn) = q sqrt(q) log n + sqrt(q) m 
    void compute(int l,int r){// O(sqrt(q))
        // [!!!] Cao!!! 边权变了 重新 排序!
        sort(edge+1,edge+1+m,[](int a,int b){
            return w[a]>w[b];
        });
        // cout<<"compute"<<l<<" "<<r<<"\n";
        // O(n) 初始化并查集
        iota(f,f+1+n,0);fill(sz,sz+1+n,1);
        // O(m) 清空 change 记录
        fill(change,change+m+1,false);
        // O(sqrt(q)) 首先将修改和查询操作分开
        cntu=cntq=0;
        for(int i=l;i<=r;i++){// 
            if(Q[i].op==1){
                update[++cntu]=i,change[Q[i].x]=true;// 修改操作
                // cout<<"change:"<<Q[i].x<<"\n";
            }else {
                query[++cntq]=i;// 查询操作
            }
        }
        // O(sqrt(q) log q) 查询按照 W 降序排列
        sort(query+1,query+1+cntq,[](int a,int b){return Q[a].y>Q[b].y;});
        // O(sqrt(q)) 逐个查询
        for(int i=1,j=1;i<=cntq;i++){
            auto [_,S,W]=Q[query[i]];// 获取查询
            // cout<<"query "<<query[i]<<":"<<S<<" "<<W<<"\n";
            // 总 O(m log n) 启用>=W的所有无关边
            while(j<=m&&w[edge[j]]>=W){
                // cout<<"j+="<<j<<" ";
                if(!change[edge[j]]){
                    merge(e[edge[j]][0],e[edge[j]][1]);
                    // cout<<"merge:"<<e[edge[j]][0]<<" "<<e[edge[j]][1]<<"\n";
                }
                j++;
            }
            //从零开始
            tp=0;
            // O(sqrt(q)) 边 的默认值
            for(int j=1;j<=cntu;j++){
                cur_w[Q[update[j]].x]=w[Q[update[j]].x];
                // cout<<"init:"<<Q[update[j]].x<<"->"<<w[Q[update[j]].x]<<"\n";
            }
            // O(sqrt(q)) 个修改
            for(int j=1;j<=cntu&&update[j]<query[i];j++){// O(sqrt(q))
                // 早于它 就启用 注意可能多次启用
                cur_w[Q[update[j]].x]=Q[update[j]].y;
                // cout<<"update:"<<Q[update[j]].x<<"->"<<Q[update[j]].y<<"\n";
            }
            // O(sqrt(q)) 边 是否启用
            for(int j=1;j<=cntu;j++){
                if(cur_w[Q[update[j]].x]>=W){
                    merge(e[Q[update[j]].x][0],e[Q[update[j]].x][1]);
                    // cout<<"extra:"<<e[Q[update[j]].x][0]<<" "<<e[Q[update[j]].x][1]<<"\n";
                }
            }
            ans[query[i]]=sz[find(S)];
            while(tp)back();// 删除这些边
        }
        // O(sqrt(q)) 将所有涉及到的边最终都要全部设置 
        for(int i=1;i<=cntu;i++){
            w[Q[update[i]].x]=Q[update[i]].y;
            // cout<<"reset:"<<Q[update[i]].x<<"->"<<Q[update[i]].y<<"\n\n";
        }
    }
    void solve(){
        // 时间分块
        for(int i=1;i<=bn;i++){
            int l=(i-1)*len+1;
            int r=min(q,i*len);
            compute(l,r);
        }
    }
}using B3Array::e,B3Array::w,B3Array::Q,B3Array::edge;
int n,m,q;
void solve(){
    cin>>n>>m;
    for(int i=1;i<=m;i++)cin>>e[i][0]>>e[i][1]>>w[i],edge[i]=i;
    cin>>q;
    for(int i=1;i<=q;i++)cin>>Q[i].op>>Q[i].x>>Q[i].y;// [Cao!!!] id=i
    B3Array::n=n;
    B3Array::m=m;
    B3Array::q=q;
    B3Array::build();
    // cout<<"build!\n";
    B3Array::solve();
    // cout<<"solve!\n";
    for(int i=1;i<=q;i++)
        if(Q[i].op==2)cout<<B3Array::ans[i]<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

#note(title:"题目2 略")[
    同样是 边权二维偏序 查询连通对是否存在
    + `u v a b` 查询 `u` `v` 之间边权 `<=a <=b` 且 `maxa=a, maxb=b` 是否存在
    - 先将 `a` 边权排序分块
    - 枚举每一块 每个查询仅在 即将过期(即将`>`查询的`a`) 时结算 并按照 `b` 排序
    - 枚举过的块 按照 `b` 排序尝试合并, 由此可以使得之前的边合并后不再回退
    - 针对每一个查询 只需关注 `b`, 可以 $O(sqrt(n))$ 暴力扫描本块 `b` 的方式维护可撤销并查集 
    - 一通计算时间复杂度 $O(m/x (q+n+m log m+ m log n)+q x log n)$ x 为块长
    - 所以求导 原式 = 0 可以得到最佳分块长度!!!
]

=== Sqrt Tree

#note[
    TO DO 真火箭毛毛虫
    
    高级版的 ST 表 !!!
    
    但是仅将 $O(n log n)$ 优化成了 $O(n log log n)$
]

== 单调栈 (MStack)

```cpp
int stk[N],sz;
for(int i=1;i<=n;i++){
    while(sz&&a[stk[sz]]>=a[i])sz--;// 单调递增
    stk[++sz]=i;
}
```

== 单调队列 (MQueue)

```cpp
int que[N],h=0,t=-1,len;
for(int i=1;i<=n;i++){
    while(h<=t&&a[que[t]]<a[i])t--;// 维护最大值
    que[++t]=i;
    // ...
    if(i-que[h]+1==len)h++;
}
```

== ST表 (STable)

```cpp
int st[N][__lg(N)+2],P;
// 初始化
P = __lg(n)+1;
for(int i=1;i<=n;i++)
    st[i][0]=/*fa[i](跳转型) or a[i](RMQ型)*/;
for(int p=1;p<=P;p++){
    for(int i=1;i<=n;i++){
        // 1 跳转型
        // st[i][p]=st[st[i][p-1]][p-1];
        
        // 2 RMQ型
        int ed=min(n,i+(1<<(p-1)));
        st[i][p]=binary_op(st[i][p-1],st[ed][p-1]);
    }
}

// 使用方式1
int u;
for(int p=P;p>=0;p--)
    if(dep[st[u][p]]<...)u=st[u][p];
// finally: 
u=st[u][0]

// 使用方式2
int query(int l,int r){
    if(l>r)return ?;
    int p=__lg(r-l+1);
    return binary_op(st[l][p],st[r-(1<<p)+1][p]);
}
```

== 树状数组 

=== 一维 (BIT)

#note[
    $O(log n)$
]

```cpp
// 含0
struct BIT{
    vector<int> tr;
    int n;
    BIT(int _):n(_+1),tr(_+2){}
    void add(int i,int v){
      for(i++;i<=n;i+=i&-i)tr[i]+=v;
    }
    int query(int i){
        int res=0;
        for(i++;i;i-=i&-i)res+=tr[i];
        return res;
    }
    int range(int l,int r){
      return query(r)-query(l-1);
    }
};
```

=== 二维

==== 单点修改 (BIT2)

$O(log n log m)$

```cpp
// 不含0
struct BIT2{
    vector<vector<int>> tr;
    int n,m;
    BIT2(int n1,int n2):n(n1),m(n2){
        tr=vector<vector<int>>(n1+1,vector<int>(n2+1));
    }
    void add(int i,int j,int v){
        for(int a=i;a<=n;a+=a&-a)
            for(int b=j;b<=m;b+=b&-b)
        		tr[a][b]+=v;
    }
    int query(int i,int j){
        int res=0;
        for(int a=i;a;a-=a&-a)
            for(int b=j;b;b-=b&-b)
                res+=tr[a][b];
        return res;
    }
};
```

==== 区间修改 (BIT2Pro)

#note [
    $O(log n log m)$
]

```cpp
// 不含0
struct BIT2Pro{
    BIT2 tr,tri,trj,trij;
    BIT2Pro(int n1,int n2):tr(n1,n2),tri(n1,n2),trj(n1,n2),trij(n1,n2){}
    void addall(int i,int j,int v){
        tr.add(i,j,v);
        tri.add(i,j,v*i);
        trj.add(i,j,v*j);
        trij.add(i,j,v*i*j);
    }
    void addall(int a,int b,int c,int d,int v){
        addall(a,b,v);addall(c+1,d+1,v);// 注意看清是前缀还是差分
        addall(a,d+1,-v);addall(c+1,b,-v);
    }
    int queryall(int i,int j){
       return 
           tr.query(i,j)*(i*j+i+j+1)
           -tri.query(i,j)*(j+1)
           -trj.query(i,j)*(i+1)
           +trij.query(i,j); 
    }
    int queryall(int a,int b,int c,int d){
        return queryall(a-1,b-1)+queryall(c,d)-queryall(a-1,d)-queryall(c,b-1);
    }
};
```

=== 权值树状数组 (WBIT)

#note[ 占位 ]

==== 查询区间第 $k$ 小

```cpp
struct BIT{
  vector<int> tr;
    int n;// 表示 [0,n] 映射到 [1,n+1] 
    BIT(int _):n(_+1),tr(_+2){}
    void add(int i,int v){
      for(i++;i<=n;i+=i&-i)tr[i]+=v;
    }
    int query(int i){
        int res=0;
        for(i++;i;i-=i&-i)res+=tr[i];
        return res;
    }
    // 填充的是原来的[0,n],如果略。0特殊处理add(0,-v);
    void add_all(int v,bool zero){
        for(int i=0+1;i<=n;i++)tr[i]+=v*(i&-i);
        if(!zero)add(0,-v);
    }
    // 真正像 lower_bound 
    int lower_bound(int k){
        int sum=0,x=0;
        for(int i=log2(n);i>=0;i--){
            x+=1<<i;
            if(x>=n||sum+tr[x]>=k)
                x-=1<<i;
            else sum+=tr[x];// 始终维持小于k的状态
        }
        return x+1-1;// +1 就等于 k 提供到外界 -1 
    }
};
```

==== 全局逆序对

#note[简单]

==== 树状数组维护不可差分信息（不推荐?四毛子）

#note[不推荐]

=== BIT Tricks

- $O(n)$ 建树

```cpp
// 1 Θ(n) 建树
void init() {
  for (int i = 1; i <= n; ++i) {
    t[i] += a[i];
    int j = i + lowbit(i);
    if (j <= n) t[j] += t[i];
  }
}
// 2 Θ(n) 建树
void init() {
  for (int i = 1; i <= n; ++i) {
    t[i] = sum[i] - sum[i - lowbit(i)];
  }
}
```

- 时间戳优化

```cpp
// 时间戳优化
int tag[MAXN], t[MAXN], Tag;
void reset() { ++Tag; }
void add(int k, int v) {
  while (k <= n) {
    if (tag[k] != Tag) t[k] = 0;
    t[k] += v, tag[k] = Tag;
    k += lowbit(k);
  }
}
int getsum(int k) {
  int ret = 0;
  while (k) {
    if (tag[k] == Tag) ret += t[k];
    k -= lowbit(k);
  }
  return ret;
}
```

== 线段树

=== 数组线段树 (STree)

```cpp
struct SegmentTree{
    int f[N*4],added[N*4],updated_num[N*4];
    bool updated[N*4];
    void up(int i){
        f[i]=f[i*2]+f[i*2+1];
    }
    void lazy_add(int i,int n,int v){
        f[i]+=n*v;
        added[i]+=v;
    }
    void lazy_update(int i,int n,int v){
        f[i]=n*v;
        updated_num[i]=v;
        updated[i]=true;
        added[i]=0;// 注意 这里类似于清空栈
    }
    void down(int i,int ln,int rn){
        if(updated[i]){// 先设置再增加 ，否则无意义，用栈的形式理解，upd 清空 add栈
            lazy_update(i*2,ln,updated_num[i]);
            lazy_update(i*2+1,rn,updated_num[i]);
            updated[i]=0;
        }
        if(added[i]){
            lazy_add(i*2,ln,added[i]);
            lazy_add(i*2+1,rn,added[i]);
            added[i]=0;
        }
    }
    void build(int i,int l,int r,int* data){
        added[i]=updated[i]=0;
        if(l==r)return f[i]=data[l],void();
        int mid=(l+r)/2;
        build(i*2,l,mid,data);
        build(i*2+1,r,mid+1,data);
        up(i);
    }
    void add(int i,int l,int r,int jl,int jr,int v){
        if(jl<=l&&r<=jr)return lazy_add(i,r-l+1,v),void();
        int mid=(l+r)/2;
        down(i,mid-l+1,r-mid);
        if(jl<=mid)add(i*2,l,mid,jl,jr,v);
        if(jr>mid)add(i*2+1,mid+1,r,jl,jr,v);
        up(i);
    }
    void update(int i,int l,int r,int jl,int jr,int v){
        if(jl<=l&&r<=jr)return lazy_update(i,r-l+1,v),void();
        int mid=(l+r)/2;
        down(i,mid-l+1,r-mid);
        if(jl<=mid)update(i*2,l,mid,jl,jr,v);
        if(jr>mid)update(i*2+1,mid+1,r,jl,jr,v);
        up(i);
    }
    int qsum(int i,int l,int jl,int jr){
        if(jl<=l&&r<=jr)return f[i];
        int res=0,mid=(l+r)/2;
        down(i,mid-l+1,r-mid);
        if(jl<=mid)res+=qsum(i*2,l,mid,jl,jr);
        if(jr>mid)res+=qsum(i*2+1,mid+1,r,jl,jr);
        return res;
    }
}
```

=== 动态开点线段树 (DSTree)

#note[
    1. 减少内存占用 (适合大值域) (但是大值域优先考虑离散化 其次是动态开点强制实现)
    2. 实现合并分裂操作 (往往无法直接区间更新,但是好像可以标记永久化)
    3. 实现可持久化
]

```cpp
#include <bits/stdc++.h>
using namespace std;
using LL = long long;

const int N = 1e9 + 5;        // 初始化有 N 
const int M = 1e3 + 5;        // 操作次数 M 
struct DynamicSegmentTree{
    int lc,rc;
    LL sum;
    LL added;
} tr[2*M*(1+__lg(N)+10)];// 适当调大 

#define lc(u) tr[u].lc
#define rc(u) tr[u].rc
#define sum(u) tr[u].sum
#define added(u) tr[u].added

int tot;

void up(int i) {
    sum(i) = sum(lc(i)) + sum(rc(i));
}
// 懒操作
void lazy_add(int i,int n,LL v){
    added(i)+=v;
    sum(i)+=n*v;
}
// 下传懒标记
void down(int i,int ln,int rn) {
    if (added(i)) {
        if(!lc(i))lc(i)=++tot;
        if(!rc(i))rc(i)=++tot;
        lazy_add(lc(i),ln,added(i));
        lazy_add(rc(i),rn,added(i));
        added(i) = 0;
    }
}
// O(log V)
// 区间加：[jl, jr] 每个位置加 v
void add(int i,int l,int r,int jl,int jr,LL v) {
    if(jl<=l&&r<=jr){
        lazy_add(i,r-l+1,v);
    }else {
        int mid=(l+r)/2;
        down(i,mid-l+1,r-mid);
        if(jl<=mid){
            if(!lc(i))lc(i)=++tot;
            add(lc(i),l,mid,jl,jr,v);
        }
        if(jr>mid){
            if(!rc(i))rc(i)=++tot;
            add(rc(i),mid+1,r,jl,jr,v);
        }
        up(i);
    }
}
// O(log V)
// 区间求和：查询 [jl, jr] 的和
LL query_sum(int i,int l,int r,int jl,int jr) {
    if(jl<=l&&r<=jr){
        return sum(i);
    }else {
        int mid=(l+r)/2;
        down(i,mid-l+1,r-mid);
        LL res=0;
        if(jl<=mid&&lc(i)){// 这里和 add 不同 因为没必要 
            res+=query_sum(lc(i),l,mid,jl,jr);
        }
        if(jr>mid&&rc(i)){
            res+=query_sum(rc(i),mid+1,r,jl,jr);
        }
        return res;
    }
}

int n,m;

void solve(){
    cin>>n>>m;
    tot=1;// 这是建立根！
    for(LL i=1,op,l,r,v;i<=m;i++){
        cin>>op;
        if(op==1){
            cin>>l>>r>>v;
            add(1,1,n,l,r,v);
        }else {
            cin>>l>>r;
            cout<<query_sum(1,1,n,l,r)<<'\n';
        }
    }
}

int main(){
    cin.tie(0)->sync_with_stdio(0);
    int t=1;
    // cin>>t;
    while(t--)solve();
    return 0;
}
```

=== 标记永久化技术 (TPSTree) (未持久化==SHI)

#note[仅对于 *可持久化线段树* 有优化效果]

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;

const int N=2e5+5;

LL n,m,a[N];

struct TagPermanentizationSegmentTree{
    LL sum[N*4],add_tag[N*4];

    void build(int i,int l,int r){
        if(l==r){
            sum[i]=a[l];
        }else {
            int mid=(l+r)/2;
            build(i*2,l,mid);
            build(i*2+1,mid+1,r);
            sum[i]=sum[i*2]+sum[i*2+1];
        }
        add_tag[i]=0;
    }

    void add(int i,int l,int r,int jl,int jr,LL v){
        int a = max(jl,l),b=min(jr,r);
        sum[i]+=(b-a+1)*v;
        if(jl<=l&&r<=jr){
            add_tag[i]+=v;
        }else {
            int mid = (l+r)/2;
            if(jl<=mid)add(i*2,l,mid,jl,jr,v);
            if(jr>mid)add(i*2+1,mid+1,r,jl,jr,v);
        }
    }

    // 询问的时候需要多一些
    LL query(int i,int l,int r,int jl,int jr,LL add_his){
        if(jl<=l&&r<=jr){
            return sum[i]+add_his*(r-l+1);
        }else {
            int mid=(l+r)/2;
            LL res=0;
            add_his+=add_tag[i];
            if(jl<=mid)res+=query(i*2,l,mid,jl,jr,add_his);
            if(jr>mid)res+=query(i*2+1,mid+1,r,jl,jr,add_his);
            return res;
        }
    }
}T;

void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>a[i];
    T.build(1,1,n);
    LL op,l,r,v;
    for(int i=1;i<=m;i++){
        cin>>op;
        if(op==1){
            cin>>l>>r>>v;
            T.add(1,1,n,l,r,v);
        }else {
            cin>>l>>r;
            cout<<T.query(1,1,n,l,r,0)<<'\n';
        }
    }
}

int main(){
    cin.tie(0)->sync_with_stdio(0);
    int t=1;
    // cin>>t;
    while(t--)solve();
    return 0;
}
```

=== 线段树合并 & 分裂

==== 合并

```cpp
// P4556 【模板】线段树合并
// 此处优先使用离散化
#include<bits/stdc++.h>
using namespace std;

const int N=1e5+5;

struct DynamicSegmentTree{
    int lc,rc;
    int sum;
}tr[N*(1+__lg(N)+5)];// 够了 不够！

int tot,rt[N];

void up(int i){
    tr[i].sum=tr[tr[i].lc].sum+tr[tr[i].rc].sum;
}

int add(int i,int l,int r,int p,int v){
    if(!i)i=++tot;// 额
    if(l==r){
        tr[i].sum+=v;
    }else {
        int mid=(l+r)/2;
        if(p<=mid){
            tr[i].lc = add(tr[i].lc,l,mid,p,v);
        }else {
            tr[i].rc = add(tr[i].rc,mid+1,r,p,v);
        }
        up(i);
    }
    return i;
}

int query_sum(int i,int l,int r,int jl,int jr){
    if(jl>jr||!i)return 0;
    if(jl<=l&&r<=jr){
        return tr[i].sum;
    }else {
        int mid=(l+r)/2;
        int res=0;
        if(jl<=mid)res+=query_sum(tr[i].lc,l,mid,jl,jr);
        if(jr>mid)res+=query_sum(tr[i].rc,mid+1,r,jl,jr);
        return res;
    }
}

// 加到 i 上
int merge(int i,int j,int l,int r){
    if(!i||!j)return i|j;
    if(l==r){
        tr[i].sum+=tr[j].sum;
    }else {    
        int mid=(l+r)/2;
        tr[i].lc = merge(tr[i].lc,tr[j].lc,l,mid);
        tr[i].rc = merge(tr[i].rc,tr[j].rc,mid+1,r);
        up(i);
    }
    return i;
}

int n;
int p[N],sP[N],ans[N];
int cntP;
unordered_map<int,int> getP;
vector<int> e[N];

void dfs(int u){
    rt[u]=add(rt[u],1,cntP,getP[p[u]],1);
    for(auto v:e[u]){
        dfs(v);
        merge(rt[u],rt[v],1,cntP);
    }
    ans[u]=query_sum(rt[u],1,cntP,getP[p[u]]+1,cntP);
}

void solve(){
    cin>>n;
    for(int i=1;i<=n;i++)cin>>p[i],sP[i]=p[i];
    sort(sP+1,sP+1+n);
    cntP = unique(sP+1,sP+1+n)-sP-1;
    for(int i=1;i<=cntP;i++)getP[sP[i]]=i;
    for(int i=2,f;i<=n;i++)cin>>f,e[f].push_back(i);
    dfs(1);
    for(int i=1;i<=n;i++)cout<<ans[i]<<'\n';
}

int main(){
    cin.tie(0)->sync_with_stdio(0);
    int t=1;
    // cin>>t;
    while(t--)solve();
    return 0;
}
```

==== 分裂

```cpp
// P5494 【模板】线段树分裂
// 含简单的线段树合并的代码
#include<bits/stdc++.h>
using namespace std;
using LL = long long;

const int N = 2e5+5;
const int M = 2e5+5;

struct DynamicSegmentTree{
    int lc,rc;
    LL sum;
}tr[(N+M*2)*(1+__lg(N)+5)];

int tot,rt[N],id;

LL n,m,a[N];

void up(int i){
    tr[i].sum = tr[tr[i].lc].sum + tr[tr[i].rc].sum;
}

// 有 build 但是之后会有分裂 又有 add 所以 add 仍然需要动态 开点
int build(int l,int r){
    int i=++tot;
    if(l==r){
        tr[i].sum = a[l];
    }else {
        int mid=(l+r)/2;
        tr[i].lc=build(l,mid);
        tr[i].rc=build(mid+1,r);
        up(i);
    }
    return i;
}

// 但是分裂后是需要 继续开点的 
int add(int i,int l,int r,int p,LL v){
    if(!i)i=++tot;
    if(l==r){
        tr[i].sum+=v;
    }else {
        int mid=(l+r)/2;
        if(p<=mid)tr[i].lc=add(tr[i].lc,l,mid,p,v);
        else tr[i].rc=add(tr[i].rc,mid+1,r,p,v);
        up(i);
    }
    return i;
}

LL query_sum(int i,int l,int r,int jl,int jr){
    if(jl>jr||!i)return 0;
    if(jl<=l&&r<=jr){
        return tr[i].sum;
    }else {
        int mid=(l+r)/2;
        LL res=0;
        if(jl<=mid)res+=query_sum(tr[i].lc,l,mid,jl,jr);
        if(jr>mid)res+=query_sum(tr[i].rc,mid+1,r,jl,jr);
        return res;
    }
}

int merge(int i,int j,int l,int r){
    if(!i||!j)return i|j;
    if(l==r){
        tr[i].sum+=tr[j].sum;
    }else {
        int mid=(l+r)/2;
        tr[i].lc = merge(tr[i].lc,tr[j].lc,l,mid);
        tr[i].rc = merge(tr[i].rc,tr[j].rc,mid+1,r);
        up(i);
    }
    return i;
}

// 但是 j 需要开新的点 
int split(int i,int& j,int l,int r,int jl,int jr){
    if(jl>jr||!i)return 0;
    if(jl<=l&&r<=jr){
        j=i;
        return 0;
    }else {
        j=++tot;// 我只在这里用了引用 j 
        int mid=(l+r)/2;
        // 注意:jl jr 和 mid 的关系判断别忘了写！
        if(jl<=mid)tr[i].lc = split(tr[i].lc,tr[j].lc,l,mid,jl,jr);
        if(jr>mid)tr[i].rc = split(tr[i].rc,tr[j].rc,mid+1,r,jl,jr);
        up(i);
        up(j);
        return i;
    }
}

int query_kth(int i,int l,int r,LL k){
    if(!i||k>tr[i].sum)return -1;
    if(l==r)return l;
    LL d=tr[tr[i].lc].sum;
    int mid=(l+r)/2;
    if(k<=d)return query_kth(tr[i].lc,l,mid,k);
    else return query_kth(tr[i].rc,mid+1,r,k-d);
}

void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>a[i];
    rt[id=1]=build(1,n);
    for(LL op,p,t,x,y,q,k,i=1;i<=m;i++){
        cin>>op;
        if(op==0){
            cin>>p>>x>>y;
            rt[p]=split(rt[p],rt[++id],1,n,x,y);
        }else if(op==1){
            cin>>p>>t;
            rt[p]=merge(rt[p],rt[t],1,n);
            rt[t]=0;
        }else if(op==2){
            cin>>p>>x>>q;
            rt[p] = add(rt[p],1,n,q,x);
        }else if(op==3){
            cin>>p>>x>>y;
            cout<<query_sum(rt[p],1,n,x,y)<<'\n';
        }else if(op==4){
            cin>>p>>k;
            cout<<query_kth(rt[p],1,n,k)<<'\n';
        }else assert(0&&"UNKOWN_OP");
    }
}

int main(){
    cin.tie(0)->sync_with_stdio(0);
    int t=1;
    // cin>>t;
    while(t--)solve();
    return 0;
}
```

=== 李超线段树 

==== 数组实现 (LiTree)

```cpp
// HEOI 2013 Segment
#include <iostream>
constexpr int MOD1 = 39989;
constexpr int MOD2 = 1000000000;
constexpr int MAXT = 40000;
using namespace std;
using pdi = pair<double, int>;

constexpr double eps = 1e-9;

int cmp(double x, double y) {
  if (x - y > eps) return 1;
  if (y - x > eps) return -1;
  return 0;
}

struct line {
  double k, b;
} p[100005];

int s[160005];
int cnt;

double calc(int id, int d) { return p[id].b + p[id].k * d; }

void add(int x0, int y0, int x1, int y1) {
  cnt++;
  if (x0 == x1)  // 特判直线斜率不存在的情况
    p[cnt].k = 0, p[cnt].b = max(y0, y1);
  else
    p[cnt].k = 1.0 * (y1 - y0) / (x1 - x0), p[cnt].b = y0 - p[cnt].k * x0;
}

void upd(int root, int cl, int cr, int u) {  // 对线段完全覆盖到的区间进行修改
  int &v = s[root], mid = (cl + cr) >> 1;
  int bmid = cmp(calc(u, mid), calc(v, mid));
  if (bmid == 1 || (!bmid && u < v)) swap(u, v);
  int bl = cmp(calc(u, cl), calc(v, cl)), br = cmp(calc(u, cr), calc(v, cr));
  if (bl == 1 || (!bl && u < v)) upd(root << 1, cl, mid, u);
  if (br == 1 || (!br && u < v)) upd(root << 1 | 1, mid + 1, cr, u);
}

void update(int root, int cl, int cr, int l, int r,
            int u) {  // 定位插入线段完全覆盖到的区间
  if (l <= cl && cr <= r) {
    upd(root, cl, cr, u);
    return;
  }
  int mid = (cl + cr) >> 1;
  if (l <= mid) update(root << 1, cl, mid, l, r, u);
  if (mid < r) update(root << 1 | 1, mid + 1, cr, l, r, u);
}

pdi pmax(pdi x, pdi y) {  // pair max函数
  if (cmp(x.first, y.first) == -1)
    return y;
  else if (cmp(x.first, y.first) == 1)
    return x;
  else
    return x.second < y.second ? x : y;
}

pdi query(int root, int l, int r, int d) {  // 查询
  if (r < d || d < l) return {0, 0};
  int mid = (l + r) >> 1;
  double res = calc(s[root], d);
  if (l == r) return {res, s[root]};
  return pmax({res, s[root]}, pmax(query(root << 1, l, mid, d),
                                   query(root << 1 | 1, mid + 1, r, d)));
}

int main() {
  ios::sync_with_stdio(false);
  int n, lastans = 0;
  cin >> n;
  while (n--) {
    int op;
    cin >> op;
    if (op == 1) {
      int x0, y0, x1, y1;
      cin >> x0 >> y0 >> x1 >> y1;
      x0 = (x0 + lastans - 1 + MOD1) % MOD1 + 1,
      x1 = (x1 + lastans - 1 + MOD1) % MOD1 + 1;
      y0 = (y0 + lastans - 1 + MOD2) % MOD2 + 1,
      y1 = (y1 + lastans - 1 + MOD2) % MOD2 + 1;
      if (x0 > x1) swap(x0, x1), swap(y0, y1);
      add(x0, y0, x1, y1);
      update(1, 1, MOD1, x0, x1, cnt);
    } else {
      int x;
      cin >> x;
      x = (x + lastans - 1 + MOD1) % MOD1 + 1;
      cout << (lastans = query(1, 1, MOD1, x).second) << endl;
    }
  }
  return 0;
}
```

==== 动态开点实现 (DLiTree)

```cpp
// 只是改成了开点写法
#include<bits/stdc++.h>
using namespace std;
using PDI = pair<double,int>;

const int N=1e5+5;
const int mod1=39989,mod2=1e9;
const double eps = 1e-9;
const int inf = 1e9;

int sign(double x){
    if(x>eps)return 1;
    if(x<-eps)return -1;
    return 0;
}

struct Line{
    double k,b=-inf;
    double f(double x){
        return k*x+b;
    }
}line[N];
int cntL;

int sub(int a,int b,int x){
    return sign(line[a].f(x)-line[b].f(x));
}

void addLine(int x0,int y0,int x1,int y1){
    ++cntL;
    if(x0==x1){
        line[cntL]={0,max(y0,y1)};
    }else {
        line[cntL].k =(double)(y1-y0)/(x1-x0); 
        line[cntL].b =y0-line[cntL].k*x0;
    }
}

struct LiChaoSegmentTree{
    int lc,rc,id;
}tr[N*(1+__lg(N))];

// 单个根很有必要！
int tot,rt;

int _update(int i,int l,int r,int u){
    if(!i){
        i=++tot;
        tr[i].id=u;
    }else {
        int& v=tr[i].id;
        int mid=(l+r)/2;
        int bm = sub(u,v,mid);
        if(bm==1||(!bm&&u<v))swap(u,v);
        int bl=sub(u,v,l),br=sub(u,v,r);
        if(bl==1||(!br&&u<v))tr[i].lc = _update(tr[i].lc,l,mid,u);
        if(br==1||(!br&&u<v))tr[i].rc = _update(tr[i].rc,mid+1,r,u);
    }
    return i;
}

int update(int i,int l,int r,int jl,int jr,int id){
    if(!i)i=++tot;
    if(jl<=l&&r<=jr){
        _update(i,l,r,id);
    }else {
        int mid=(l+r)/2;
        if(jl<=mid)tr[i].lc = update(tr[i].lc,l,mid,jl,jr,id);
        if(jr>mid)tr[i].rc = update(tr[i].rc,mid+1,r,jl,jr,id);
        // 没有up
    }
    return i;
}

// 扩展：合并 (未测试)
int merge(int i,int j, int l, int r) {
    if(!i||!j)return i|j;
    if(l==r){
        int b=sub(tr[j].id,tr[i].id,l);
        if(b==1||(!b&&tr[j].id<tr[i].id))i=j;
    }else {
        // 因为这是中点代表点，所以需要传递一下
        _update(i,l,r,tr[j].id);
        int mid=(l+r)/2;
        tr[i].lc = merge(tr[i].lc,tr[j].lc,l,mid);
        tr[i].rc = merge(tr[i].rc,tr[j].rc,mid+1,r);
    }
    return i;
}

PDI pdi_max(PDI a,PDI b){
    if(sign(a.first-b.first)==1)return a;
    if(sign(a.first-b.first)==-1)return b;
    return a.second<b.second?a:b;
}

PDI query_max(int i,int l,int r,int x){
    if(!i||r<x||x<l)return {0,0};
    PDI cur = {line[tr[i].id].f(x),tr[i].id};
    if(l==r){
        return cur;// 不要用这个，这个不对 除非你初始化 b=-inf
    }else {
        int mid=(l+r)/2;
        PDI res = pdi_max(query_max(tr[i].lc,l,mid,x),query_max(tr[i].rc,mid+1,r,x));
        return pdi_max(cur,res);
    }
}

int n;

void solve(){
    cin>>n;
    int op,k,x0,y0,x1,y1,lastans=0,x;
    for(int i=1;i<=n;i++){
        cin>>op;
        if(op==0){
            cin>>k;
            x=(k+lastans-1+mod1)%mod1+1;
            lastans=query_max(1,1,mod1,x).second;
            cout<<lastans<<'\n';
        }else {
            cin>>x0>>y0>>x1>>y1;
            x0=(x0+lastans-1+mod1)%mod1+1;
            x1=(x1+lastans-1+mod1)%mod1+1;
            y0=(y0+lastans-1+mod2)%mod2+1;
            y1=(y1+lastans-1+mod2)%mod2+1;
            if(x0>x1)swap(x0,x1),swap(y0,y1);
            addLine(x0,y0,x1,y1);
            rt=update(rt,1,mod1,x0,x1,cntL);
        }
    }
}

int main(){
    cin.tie(0)->sync_with_stdio(0);
    int t=1;
    // cin>>t;
    while(t--)solve();
    return 0;
}
```

=== 猫树

#note[
    TO DO 依然火箭毛毛虫

    好像仅限于 离线 信息(特别是线性基)合并
]

=== 区间最值操作 & 区间历史最值

#note[
    TO DO !! 还有3个 区间历史最值
]

===== JiTree 演示 demo (check_min)

#note[
    有关操作(上限)/对应需要的数据结构
    + `check_min`: 上限检查 (`int chmn[]`,`bool tag_chmn[]`)
    + `query_max`: 查询上限(最大值) (`int mx1[]`, `int mx2[]`, `int cn[]`(最大值统计数))
    + `query_sum`: 查询区间和 (`LL sum[]`)
]

```cpp
// HDU5306 Gorgeous Sequence
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N = 1e6+5,N4=N*4;
const int inf = 1e9+7;

struct JiTree{
    LL sum[N4];// 总和
    int mx1[N4],mx2[N4],cn[N4],chmn[N4];// 最大 次大 最大统计值 check_min 懒标记值
    bool tag_chmn[N4];// check_min 懒标记 
    // 【重点】 up 操作的处理
    void up(int i){
        int l=i*2,r=l+1;
        sum[i]=sum[l]+sum[r];
        if(mx1[l]==mx1[r]){
            // 相等直接合并
            mx1[i]=mx1[l];
            cn[i]=cn[l]+cn[r];
            // 次大都是 2
            mx2[i]=max(mx2[l],mx2[r]);
        }else {
            // 不相等的话
            if(mx1[l]<mx1[r])swap(l,r);// 让 l 为较大者
            mx1[i]=mx1[l];
            cn[i]=cn[l];
            mx2[i]=max(mx2[l],mx1[r]);
        }
    }
    // 【重点】 懒操作的方式
    void lazy_chmn(int i,int v){
        if(v>=mx1[i])return;
        sum[i]+=(LL)cn[i]*(v-mx1[i]);
        chmn[i]=mx1[i]=v;
        tag_chmn[i]=true;
    }
    void build(int i,int l,int r,int* a){
        tag_chmn[i]=false;
        if(l==r){
            mx1[i]=sum[i]=a[l];
            mx2[i]=-inf;
            cn[i]=1;
            return;
        }
        int mid=(l+r)/2;
        build(i*2,l,mid,a);
        build(i*2+1,mid+1,r,a);
        up(i);
    }
    void down(int i){
        if(tag_chmn[i]){
            lazy_chmn(i*2,chmn[i]);
            lazy_chmn(i*2+1,chmn[i]);
            tag_chmn[i]=false;
        }
    }
    // 【重点】 check_min 懒操作的时机 
    void check_min(int i,int l,int r,int jl,int jr,int v){
        if(v>=mx1[i])return;
        if(jl<=l&&r<=jr&&v>mx2[i]){
            // 就是这样的条件 到叶子的时候 触发 inf 必然正确
            lazy_chmn(i,v);
        }else {
            int mid=(l+r)/2;
            down(i);// down 随便 down 只要第一次 lazy 正确 之后的都会正确
            if(jl<=mid)check_min(i*2,l,mid,jl,jr,v);
            if(jr>mid)check_min(i*2+1,mid+1,r,jl,jr,v);
            up(i);
        }
    }
    int query_max(int i,int l,int r,int jl,int jr){
        if(jl<=l&&r<=jr){
            return mx1[i];
        }else {
            int mid=(l+r)/2;
            down(i);
            int res=-inf;
            if(jl<=mid)res=max(res,query_max(i*2,l,mid,jl,jr));
            if(jr>mid)res=max(res,query_max(i*2+1,mid+1,r,jl,jr));
            return res;
        }
    }
    LL query_sum(int i,int l,int r,int jl,int jr){
        if(jl<=l&&r<=jr){
            return sum[i];
        }else {
            int mid=(l+r)/2;
            down(i);
            LL res=0;
            if(jl<=mid)res+=query_sum(i*2,l,mid,jl,jr);
            if(jr>mid)res+=query_sum(i*2+1,mid+1,r,jl,jr);
            return res;
        }
    }
}T;

int n,m;
int a[N];

void solve(){
    // 0 x y t 区间取 min t
    // 1 x y 区间查询最大值
    // 2 x y 区间查询和
    int op,x,y,t;
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>a[i];
    T.build(1,1,n,a);
    while(m--){
        cin>>op>>x>>y;
        if(op==0){
            cin>>t;
            T.check_min(1,1,n,x,y,t);
        }else if(op==1){
            cout<<T.query_max(1,1,n,x,y)<<"\n";
        }else {
            cout<<T.query_sum(1,1,n,x,y)<<"\n";
        }
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    int T=1;
    cin>>T;
    while(T--)solve();
}
```

===== JiTreePro (check_min check_max)

#note[
    + 优化了变量命名
    + 新增了一些【重点】操作
]

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N = 5e5+5,N4=N*4;
const int inf = 1e9+7;
/*
1 l r x 区间加 x
2 l r x 区间 check_max
3 l r x 区间 check_min
4 l r 区间和
5 l r 区间 max
6 l r 区间 min
*/
struct JiTreePro{
    LL sum[N4];
    int cmx[N4],cmn[N4];
    LL mx[N4],mx2[N4],tmn[N4];
    LL mn[N4],mn2[N4],tmx[N4];
    LL tad[N4];// 确实啊啊啊 xx2 cxx txx 确实好用
    void up(int i){
        int l=i*2,r=l+1;
        sum[i]=sum[l]+sum[r];
        
        if(mx[l]<mx[r])swap(l,r);
        mx[i]=mx[l];
        cmx[i]=cmx[l];
        if(mx[l]==mx[r]){
            cmx[i]+=cmx[r];
            mx2[i]=max(mx2[l],mx2[r]);
        }else mx2[i]=max(mx2[l],mx[r]);
        
        if(mn[l]>mn[r])swap(l,r);
        mn[i]=mn[l];
        cmn[i]=cmn[l];
        if(mn[l]==mn[r]){
            cmn[i]+=cmn[r];
            mn2[i]=min(mn2[l],mn2[r]);
        }else mn2[i]=min(mn2[l],mn[r]);
    }
    void build(int i,int l,int r,LL* a){
        tmx[i]=-inf;tmn[i]=inf;tad[i]=0;
        if(l==r){
            mx[i]=mn[i]=sum[i]=a[l];
            mx2[i]=-inf;
            mn2[i]=inf;
            cmx[i]=cmn[i]=1;
        }else {
            int mid=(l+r)/2;
            build(i*2,l,mid,a);
            build(i*2+1,mid+1,r,a);
            up(i);
        }
    }
    void push_add(int i,int n,LL v){
        sum[i]+=n*v;
        mx[i]+=v;
        mn[i]+=v;
        // 便利的同时也要注意 
        if(mx2[i]!=-inf)mx2[i]+=v;
        if(mn2[i]!=inf)mn2[i]+=v;
        // 这两个更不能忘了: 绝对不能改变 inf -inf 
        if(tmx[i]!=-inf)tmx[i]+=v;
        if(tmn[i]!=inf)tmn[i]+=v;
        tad[i]+=v;
    }
    void push_min(int i,LL v){
        if(v>=mx[i])return;
        sum[i]+=(LL)cmx[i]*(v-mx[i]);
        // 【在这里转了好久】
        // 【重点重点重点】 保证所有的旧数据都更新
        // 极端情况: 全员取 min
        if(mn[i]==mx[i])mn[i]=v;// mn mn2 互斥
        else if(mn2[i]==mx[i])mn2[i]=v;//
        tmx[i]=min(tmx[i],v);// tag 永远跟随
        mx[i]=tmn[i]=v;
    }
    void push_max(int i,LL v){
        if(v<=mn[i])return;
        sum[i]+=(LL)cmn[i]*(v-mn[i]);
        // 【在这里转了好久】
        // 【重点重点重点】 保证所有的旧数据都更新
        // 极端情况: 全员取 max
        if(mx[i]==mn[i])mx[i]=v;// mx mx2 互斥
        else if(mx2[i]==mn[i])mx2[i]=v;// 
        tmn[i]=max(tmn[i],v);// tag 永远跟随
        mn[i]=tmx[i]=v;
    }
    void down(int i,int ln,int rn){
        if(tad[i]){
            push_add(i*2,ln,tad[i]);
            push_add(i*2+1,rn,tad[i]);
            tad[i]=0;
        }
        if(tmn[i]!=inf){
            push_min(i*2,tmn[i]);
            push_min(i*2+1,tmn[i]);
            tmn[i]=inf;
        }
        if(tmx[i]!=-inf){
            push_max(i*2,tmx[i]);
            push_max(i*2+1,tmx[i]);
            tmx[i]=-inf;
        }
    }
    void add(int i,int l,int r,int jl,int jr,LL v){
        if(l>r)return;
        if(jl<=l&&r<=jr){
            push_add(i,r-l+1,v);
        }else {
            int mid=(l+r)/2;
            down(i,mid-l+1,r-mid);
            if(jl<=mid)add(i*2,l,mid,jl,jr,v);
            if(jr>mid)add(i*2+1,mid+1,r,jl,jr,v);
            up(i);
        }
    }
    void check_min(int i,int l,int r,int jl,int jr,LL v){
        if(l>r||v>=mx[i])return;
        if(jl<=l&&r<=jr&&v>mx2[i]){
            push_min(i,v);
        }else {
            int mid=(l+r)/2;
            down(i,mid-l+1,r-mid);
            if(jl<=mid)check_min(i*2,l,mid,jl,jr,v);
            if(jr>mid)check_min(i*2+1,mid+1,r,jl,jr,v);
            up(i);
        }
    }
    void check_max(int i,int l,int r,int jl,int jr,LL v){
        if(l>r||v<=mn[i])return;
        if(jl<=l&&r<=jr&&v<mn2[i]){
            push_max(i,v);
        }else {
            int mid=(l+r)/2;
            down(i,mid-l+1,r-mid);
            if(jl<=mid)check_max(i*2,l,mid,jl,jr,v);
            if(jr>mid)check_max(i*2+1,mid+1,r,jl,jr,v);
            up(i);
        }
    }
    LL query_sum(int i,int l,int r,int jl,int jr){
        if(l>r)return 0;
        if(jl<=l&&r<=jr){
            return sum[i];
        }else {
            int mid=(l+r)/2;
            down(i,mid-l+1,r-mid);
            LL res=0;
            if(jl<=mid)res+=query_sum(i*2,l,mid,jl,jr);
            if(jr>mid)res+=query_sum(i*2+1,mid+1,r,jl,jr);
            return res;
        }
    }
    LL query_max(int i,int l,int r,int jl,int jr){
        if(l>r)return -inf;
        if(jl<=l&&r<=jr){
            return mx[i];
        }else {
            int mid=(l+r)/2;
            down(i,mid-l+1,r-mid);
            LL res=-inf;
            if(jl<=mid)res=max(res,query_max(i*2,l,mid,jl,jr));
            if(jr>mid)res=max(res,query_max(i*2+1,mid+1,r,jl,jr));
            return res;
        }
    }
    LL query_min(int i,int l,int r,int jl,int jr){
        if(l>r)return inf;
        if(jl<=l&&r<=jr){
            return mn[i];
        }else {
            int mid=(l+r)/2;
            down(i,mid-l+1,r-mid);
            LL res=inf;
            if(jl<=mid)res=min(res,query_min(i*2,l,mid,jl,jr));
            if(jr>mid)res=min(res,query_min(i*2+1,mid+1,r,jl,jr));
            return res;
        }
    }
}T;
int n,m;
LL a[N];
int main(){
    cin.tie(0)->sync_with_stdio(0);
    cin>>n;
    for(int i=1;i<=n;i++)cin>>a[i];
    T.build(1,1,n,a);    
    cin>>m;
    while(m--){
        int op,l,r;LL x;
        cin>>op>>l>>r;
        if(op==1){
            cin>>x;
            T.add(1,1,n,l,r,x);
        }else if(op==2){
            cin>>x;
            T.check_max(1,1,n,l,r,x);
        }else if(op==3){
            cin>>x;
            T.check_min(1,1,n,l,r,x);
        }else if(op==4){
            cout<<T.query_sum(1,1,n,l,r)<<"\n";
        }else if(op==5){
            cout<<T.query_max(1,1,n,l,r)<<"\n";
        }else {
            cout<<T.query_min(1,1,n,l,r)<<"\n";
        }
    }
}
```

===== JiTreeUltra (check_min histroy_max)

#note[
    注意: 此处的区间最值操作维护方法和之前不一样!!!(使用分类add_tag)
]

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N = 5e5+5,N4=N*4;
const LL inf = 1e18+7;
/*
增量法:维护最大值次大值
1 l r x 区间加
2 l r x 区间 check_min
3 l r 区间和
4 l r 区间最大值
5 l r 区间历史最大值
*/
struct JiTreeUltra{
    LL sum[N4],mx[N4],mx2[N4],tad[N4],tad2[N4],mtad[N4],mtad2[N4],hmx[N4];
    int cmx[N4];
    void up(int i){
        int l=i*2,r=l+1;
        sum[i]=sum[l]+sum[r];
        hmx[i]=max(hmx[l],hmx[r]);//
        if(mx[l]<mx[r])swap(l,r);
        mx[i]=mx[l];
        cmx[i]=cmx[l];
        if(mx[l]==mx[r]){
            cmx[i]+=cmx[r];
            mx2[i]=max(mx2[l],mx2[r]);
        }else mx2[i]=max(mx2[l],mx[r]);
    }
    void build(int i,int l,int r,LL* a){
        tad[i]=tad2[i]=mtad[i]=mtad2[i]=0;
        if(l==r){
            hmx[i]=sum[i]=mx[i]=a[l];//
            cmx[i]=1;// 
            mx2[i]=-inf;
        }else {
            int mid=(l+r)/2;
            build(i*2,l,mid,a);
            build(i*2+1,mid+1,r,a);
            up(i);
        }
    }
    void push_add(int i,int n,LL v,LL v2,LL mv,LL mv2){
        mtad[i]=max(mtad[i],tad[i]+mv);
        mtad2[i]=max(mtad2[i],tad2[i]+mv2);
        hmx[i]=max(hmx[i],mx[i]+mv);

        sum[i]+=cmx[i]*v;
        sum[i]+=(n-cmx[i])*v2;
        mx[i]+=v;
        tad[i]+=v;
        if(mx2[i]!=-inf)mx2[i]+=v2;/// ???? 不知道怎么就 WA了
        if(mx2[i]!=-inf)tad2[i]+=v2;///  ????
    }
    void down(int i,int ln,int rn){
        int l=i*2,r=i*2+1;
        LL tmp = max(mx[l],mx[r]);
        if(tad[i]){
            if(mx[l]==tmp){
                push_add(l,ln,tad[i],tad2[i],mtad[i],mtad2[i]);
            }else push_add(l,ln,tad2[i],tad2[i],mtad2[i],mtad2[i]);
            if(mx[r]==tmp){
                push_add(r,rn,tad[i],tad2[i],mtad[i],mtad2[i]);
            }else push_add(r,rn,tad2[i],tad2[i],mtad2[i],mtad2[i]);
            tad[i]=tad2[i]=mtad[i]=mtad2[i]=0;
        }
    }
    void check_min(int i,int l,int r,int jl,int jr,LL v){
        if(v>=mx[i])return;
        if(jl<=l&&r<=jr&&v>mx2[i]){
            push_add(i,r-l+1,v-mx[i],0,v-mx[i],0);
        }else {
            int mid=(l+r)/2;
            down(i,mid-l+1,r-mid);
            if(jl<=mid)check_min(i*2,l,mid,jl,jr,v);
            if(jr>mid)check_min(i*2+1,mid+1,r,jl,jr,v);
            up(i);
        }
    }
    void add(int i,int l,int r,int jl,int jr,LL v){
        if(jl<=l&&r<=jr){
            push_add(i,r-l+1,v,v,v,v);
        }else {
            int mid=(l+r)/2;
            down(i,mid-l+1,r-mid);
            if(jl<=mid)add(i*2,l,mid,jl,jr,v);
            if(jr>mid)add(i*2+1,mid+1,r,jl,jr,v);
            up(i);
        }
    }
    LL query_max(int i,int l,int r,int jl,int jr){
        if(jl<=l&&r<=jr){
            return mx[i];
        }else {
            int mid=(l+r)/2;
            down(i,mid-l+1,r-mid);
            LL res=-inf;
            if(jl<=mid)res=max(res,query_max(i*2,l,mid,jl,jr));
            if(jr>mid)res=max(res,query_max(i*2+1,mid+1,r,jl,jr));
            return res;
        }
    }
    LL query_history_max(int i,int l,int r,int jl,int jr){
        if(jl<=l&&r<=jr){
            return hmx[i];
        }else {
            int mid=(l+r)/2;
            down(i,mid-l+1,r-mid);
            LL res=-inf;
            if(jl<=mid)res=max(res,query_history_max(i*2,l,mid,jl,jr));
            if(jr>mid)res=max(res,query_history_max(i*2+1,mid+1,r,jl,jr));
            return res;
        }
    }
    LL query_sum(int i,int l,int r,int jl,int jr){
        if(jl<=l&&r<=jr){
            return sum[i];
        }else {
            int mid=(l+r)/2;
            down(i,mid-l+1,r-mid);
            LL res=0;
            if(jl<=mid)res+=query_sum(i*2,l,mid,jl,jr);
            if(jr>mid)res+=query_sum(i*2+1,mid+1,r,jl,jr);
            return res;
        }
    }
}T;
int n,m;
LL a[N];
void solve(){
    int op,l,r;LL x;
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>a[i];
    T.build(1,1,n,a);
    while(m--){
        cin>>op>>l>>r;
        if(op==1){
            cin>>x;
            T.add(1,1,n,l,r,x);
        }else if(op==2){
            cin>>x;
            T.check_min(1,1,n,l,r,x);
        }else if(op==3){
            cout<<T.query_sum(1,1,n,l,r)<<"\n";
        }else if(op==4){
            cout<<T.query_max(1,1,n,l,r)<<"\n";
        }else if(op==5){
            cout<<T.query_history_max(1,1,n,l,r)<<"\n";
        }
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

== 划分树

#note[
    TO DO 比较简单的火箭毛毛虫:归并树
]

== 搜索树 & 平衡树

=== Treap

==== FHQTreap

- Treap 的重要特性：
  - 无论怎么 merge， Treap 始终维持 merge 前中序遍历的有序性
  - 因此可以用于文本操作 (需要使用根据 rank 的 split)

==== 普通平衡树 (Treap)

#note[split 根据 key]

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=2e6+5;
const int inf = INT_MAX;
// 所有适合可持久化的东西都这么写
namespace Treap{
    struct FHQTreap{
        int lc,rc,sz,val;
        int key;
    }tr[N];
    int rt,tot;
    #define lc(i) tr[i].lc
    #define rc(i) tr[i].rc
    #define sz(i) tr[i].sz
    #define val(i) tr[i].val
    #define key(i) tr[i].key
    // 【必备】初始化
    void clear(){rt=tot=0;}
    // 【必备】创建节点
    int new_node(int k){
        ++tot;
        key(tot)=k;
        sz(tot)=1;
        val(tot)=rand()^(rand()<<15);
        return tot;
    }
    // 【必备】整合信息
    void up(int i){
        sz(i)=1+sz(lc(i))+sz(rc(i));
    }
    // 【必备】按key分裂
    // <=x 放在左树 >x 的放在右树
    void split(int i,int l,int r,int k){
        if(!i)rc(l)=lc(r)=0;// 空节点
        else {
            if(key(i)<=k){// 小于等于
                rc(l)=i;// 放在左树的右边 
                // 自己的右树递归 自己作为左
                split(rc(i),i,r,k);
            }else {
                lc(r)=i;// 放在右树的左边
                // 自己的左树递归 自己作为右
                split(lc(i),l,i,k);
            }
            up(i);
        }
    }
    // 【必备】按val合并
    // 合并 l r 树
    int merge(int l,int r){
        if(!l||!r)return l|r;// 某一个空
        if(val(l)>=val(r)){// 左边大
            rc(l)=merge(rc(l),r);// 左边的右树递归
            up(l);// 整合到左边
            return l;
        }else {// 右边大
            lc(r)=merge(l,lc(r));// 右边的左树递归
            up(r);// 整合到右边
            return r;
        }
    }
    // 【必备】插入 (3log)
    void insert(int k){
        split(rt,0,0,k);// 0 节点作为辅助
        // 注意这里是的顺序左右是反过来的
        rt=merge(merge(rc(0),new_node(k)),lc(0));
    }
    // 【必备】删除 (5log)
    void erase(int k){
        split(rt,0,0,k);
        int lm=rc(0),r=lc(0);// 同样反过来
        split(lm,0,0,k-1);
        int l=rc(0),m=lc(0);// 同样反过来
        rt=merge(merge(l,merge(lc(m),rc(m))),r);// 不是 0 不反
    }
    // 【必备】按key查找 (迭代)
    int rank(int k){
        // if(!rt)return 0;// WA 按照题目尿性 res>=1
        int i=rt,res=1;  
        while(i){
            if(k<=key(i))i=lc(i);
            else res+=sz(lc(i))+1,i=rc(i);
        }
        return res;
    }
    // 【必备】按索引查找 (迭代)
    int at(int x){
        if(x<1)return -inf;
        if(x>sz(rt))return inf;
        int i=rt;
        while(i){
            if(x<=sz(lc(i)))i=lc(i);
            else if(x==sz(lc(i))+1)return key(i);
            else x-=sz(lc(i))+1,i=rc(i);
        }
        assert(0&&"EMPTY");
    }
    // 【重要】 key前驱 (2迭代)
    int prev(int k){return at(rank(k)-1);}
    // // 【重要】 key后继 (2迭代)
    int next(int k){return at(rank(k+1));}
}
void solve2(){
    Treap::clear();
    int n,m,op,a,x,lst=0,ans=0;
    cin>>n>>m;
    while(n--)cin>>a,Treap::insert(a);
    while(m--){
        cin>>op>>x;x^=lst;
        if(op==1)Treap::insert(x);
        else if(op==2)Treap::erase(x);
        else if(op==3)ans^=lst=Treap::rank(x);
        else if(op==4)ans^=lst=Treap::at(x);
        else if(op==5)ans^=lst=Treap::prev(x);
        else if(op==6)ans^=lst=Treap::next(x);
        else assert(0&&"ERROR");
    }
    cout<<ans<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve2();
}
```

==== 文艺平衡树 (LTreap)

#note[split 根据 索引]

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=2e6+5;
const int inf = INT_MAX;
// 所有适合可持久化的东西都这么写
/*
你现在的代码其实是一个 “超级动态数组”。
如果你需要处理的题目只涉及区间加减和求和，且序列长度固定，线段树更快；
但如果题目涉及 翻转、移动区间、在中间插入删除
那么你这段代码就是唯一正确的选择（或者用 Splay 树，但 FHQ Treap 更好写）。
*/
namespace LTreap{
    struct FHQLTree{
        int lc,rc,sz,val;
        int key;
        bool rev;
    }tr[N];
    int rt,tot;
    #define lc(i) tr[i].lc
    #define rc(i) tr[i].rc
    #define sz(i) tr[i].sz
    #define val(i) tr[i].val
    #define key(i) tr[i].key
    #define rev(i) tr[i].rev
    // 【必备】初始化
    void clear(){rt=tot=0;}
    // 【必备】创建节点
    int new_node(int k){
        ++tot;
        key(tot)=k;
        sz(tot)=1;
        val(tot)=rand()^(rand()<<15);
        rev(tot)=0;// 【新增】
        return tot;
    }
    // 【必备】整合信息
    void up(int i){
        sz(i)=1+sz(lc(i))+sz(rc(i));
    }
    // 【新增】下传信息
    void down(int i){
        if(rev(i)){
            rev(lc(i))^=1;
            rev(rc(i))^=1;
            swap(lc(i),rc(i));
            rev(i)=0;
        }
    }
    // 【孪生】按索引分裂  
    // <=x 个放在左树 其余放在右树
    void split(int i,int l,int r,int x){
        if(!i)rc(l)=lc(r)=0;
        else {// 关键看 i 属于谁
            down(i);// 【新增】
            if(sz(lc(i))+1<=x){
                rc(l)=i;
                split(rc(i),i,r,x-sz(lc(i))-1);
            }else {
                lc(r)=i;
                split(lc(i),l,i,x);
            }
            up(i);
        }
    }
    // 【必备】按val合并
    // 合并 l r 树
    int merge(int l,int r){
        if(!l||!r)return l|r;// 某一个空
        if(val(l)>=val(r)){// 左边大
            down(l);// 【新增】
            rc(l)=merge(rc(l),r);// 左边的右树递归
            up(l);// 整合到左边
            return l;
        }else {// 右边大
            down(r);// 【新增】
            lc(r)=merge(l,lc(r));// 右边的左树递归
            up(r);// 整合到右边
            return r;
        }
    }
    // 【必备】【修改】"定点"插入 (3log)
    void insert(int x,int k){
        split(rt,0,0,x-1);// 0 节点作为辅助
        // 注意这里是的顺序左右是反过来的
        rt=merge(merge(rc(0),new_node(k)),lc(0));
    }
    // 【必备】【修改】"定点"删除 (5log)
    void erase(int x){
        split(rt,0,0,x);
        int lm=rc(0),r=lc(0);// 同样反过来
        split(lm,0,0,x-1);
        int l=rc(0),m=lc(0);// 同样反过来
        rt=merge(merge(l,merge(lc(m),rc(m))),r);// 不是 0 不反
    }
    // 【新增】 区间翻转 (4log)
    void reverse(int x,int y){
        split(rt,0,0,y);
        int lm=rc(0),r=lc(0);
        split(lm,0,0,x-1);
        int l=rc(0),m=lc(0);
        rev(m)^=1;
        rt=merge(merge(l,m),r);
    }
    // 【删除】【rank】按key查找
    // 【必备】按索引查找 (迭代)
    int at(int x){
        if(x<1)return -inf;
        if(x>sz(rt))return inf;
        int i=rt;
        while(i){
            down(i);// 【新增】
            if(x<=sz(lc(i)))i=lc(i);
            else if(x==sz(lc(i))+1)return key(i);
            else x-=sz(lc(i))+1,i=rc(i);
        }
        assert(0&&"EMPTY");
    }
}
void solve(){
    LTreap::clear();
    int n,m,op,a,x,l,r;
    cin>>n>>m;
    for(int i=1;i<=n;i++)LTreap::insert(i,i);
    while(m--)cin>>l>>r,LTreap::reverse(l,r);
    for(int i=1;i<=n;i++)cout<<LTreap::at(i)<<" ";
    cout<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

=== Splay 树 

==== 普通平衡树 (Splay)

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=2e6+5;
const int inf=INT_MAX;
bool ok=false;

namespace Splay{
    struct SplayTree{
        int ch[2],fa,sz;
        int key;
    }tr[N];
    int tot,rt;
    #define ch(i,y) tr[i].ch[y]
    #define lc(i) tr[i].ch[0]
    #define rc(i) tr[i].ch[1]
    #define key(i) tr[i].key
    #define sz(i) tr[i].sz
    #define fa(i) tr[i].fa
    // 【继悬挂else后的第二大语法杀手】加括号套住!!!!!
    // 【继悬挂else后的第二大语法杀手】加括号套住!!!!!
    #define dir(i) (i==ch(fa(i),1)) 
    // 【继悬挂else后的第二大语法杀手】加括号套住!!!!!
    // 【继悬挂else后的第二大语法杀手】加括号套住!!!!!
    // 【必备】 初始化
    void clear(){rt=tot=0;}
    // 【必备】 new_node
    int new_node(int k){
        int i=++tot;
        lc(i)=rc(i)=fa(i)=0;
        sz(i)=1;
        key(i)=k;
        return i;
    }
    // 【必备】 上传
    void up(int i){
        sz(i)=1+sz(lc(i))+sz(rc(i));
    }
    // 【必备】旋转
    void rotate(int i){
        int f=fa(i),g=fa(f);
        bool r=dir(i);
        ch(f,r)=ch(i,!r);// f 的新儿子
        ch(i,!r)=f;// i 的新儿子
        if(g)ch(g,dir(f))=i;// g 的新儿子 (此时没有变 fa(f)) 
        if(ch(f,r))fa(ch(f,r))=f;// f 的儿子认亲
        fa(f)=i;// i 的儿子认亲
        fa(i)=g;// g 的儿子认亲
        up(f);
        up(i);
    }
    // 【必备】伸展
    // 节点 i 通过上升的方式 变成节点 g(即该树的根节点)
    void splay(int i,int goal){
        int f=fa(i),g=fa(f);
        for(;f!=goal;rotate(i),g=fa(f=fa(i)))// [1]for zig-zag
            if(g!=goal)rotate(dir(i)==dir(f)?f:i);
        if(!goal)rt=i;
    }
    // 【必备】插入 (迭代+log)
    void insert(int k){
        if(!rt)rt=new_node(k);
        else {
            int i=rt,f=0;
            // 往下扎 等号处理 无讲究
            for(;i;i=ch(f=i,key(i)<k));// [2]for 往下扎
            i=new_node(k);
            ch(f,key(f)<k)=i;// 但是一定要相同
            fa(i)=f;
            splay(i,0);
        }
    }
    // 【必备】按 key 查询 (迭代+log)
    int rank(int k){
        int i=rt,f=i,res=1;
        for(;i;i=ch(f=i,key(i)<k))// [3]for rank
            if(key(i)<k)res+=sz(lc(i))+1;
        splay(f,0);// f 不一定是 key=k 的
        return res;
    }
    // 【必备】定位索引 x 的节点 (迭代(禁止单用))
    // 不能 splay因为 erase 需要 
    int locate(int x){
        if(x<1||x>sz(rt))return 0;
        int i=rt;
        while(x!=sz(lc(i))+1)// [4]独 while 条件挺奇葩 
            if(x<=sz(lc(i)))i=lc(i);
            else x-=sz(lc(i))+1,i=rc(i);
        return i;
    }
    // 【必备】删除一个 key=k 的元素
    void erase(int k){
        int x = rank(k);// 找到一个排名
        if(x!=rank(k+1)){// 如果有
            int i=locate(x);// 这里寻找不会超过 rank(k) 的深度
            splay(i,0);
            if(!lc(i)||!rc(i))rt=lc(i)|rc(i);
            else {
                int j=locate(x+1);
                splay(j,i);
                lc(j)=lc(i);
                fa(lc(j))=j;
                up(j);
                rt=j;
            }
            fa(rt)=0;
        }
    }
    // 【必备】按索引访问 (迭代+log)
    int at(int x){
        int i=locate(x);
        splay(i,0);
        return key(i);
    }
    // 【必备】前驱 (迭代+log)
    int prev(int k){
        int i=rt,f=i,res=-inf;
        for(;i;i=ch(f=i,key(i)<k))// [5]for = 归左边<
            if(key(i)<k)res=max(res,key(i));// 记忆: <k最大的
        splay(f,0);
        return res;
    }
    // 【必备】后继 (迭代+log)
    int next(int k){
        int i=rt,f=i,res=inf;
        for(;i;i=ch(f=i,key(i)<=k))// [6]for = 归右边<=
            if(key(i)>k)res=min(res,key(i));// 记忆: >k最小的
        splay(f,0);
        return res;
    }
}
int n;
void solve2(){
    Splay::clear();
    int n,m,op,a,x,lst=0,ans=0;
    cin>>n>>m;
    while(n--)cin>>a,Splay::insert(a);
    while(m--){
        cin>>op>>x;x^=lst;
        if(op==1)Splay::insert(x);
        else if(op==2)Splay::erase(x);
        else if(op==3)ans^=lst=Splay::rank(x);
        else if(op==4)ans^=lst=Splay::at(x);
        else if(op==5)ans^=lst=Splay::prev(x);
        else if(op==6)ans^=lst=Splay::next(x);
        else assert(0&&"ERROR");
    }
    cout<<ans<<"\n";
}
int main(){
	cin.tie(0)->sync_with_stdio(0);
	solve2();
}
```

=== WBLT

#note[
    TO DO 感觉多余了
]

=== 替罪羊树 

==== 普通平衡树 (SGTree)

#note[
    操作:
    + new_node/up:  创建/更新节点
    + *inorder*:    中序遍历收集节点
    + *build*:      分治重构
    + *rebuild*:    重构入口
    + *imbalance*:  不平衡判断
    + insert/\_insert:  插入(递归)
    + erase/\_erase:    删除(递归)
    + rank/at:      按 键/索引 查询(迭代)
    + prev/next:    前驱值/后继值
    + clear:        清除
]

```cpp
#include<bits/stdc++.h>
using namespace std;
const double ALPHA = 0.75;
const int N=2e6+5;
const int inf = INT_MAX;

// 我的替罪羊树是不是很优雅，是不是史上最简洁的
struct SGTree{
    // tp:最上方的不平衡节点
    inline static int collect[N],ci,*tp;
    int key[N],cnt[N],lc[N],rc[N],sz[N],diff[N];
    int rt,tot;
    // 【必备】初始化
    void clear(){rt=tot=0;}
    // 【必备】新建节点
    int new_node(int k){
        key[++tot]=k;
        lc[tot]=rc[tot]=0;
        cnt[tot]=sz[tot]=diff[tot]=1;
        return tot;
    }
    // 【必备】更新
    void up(int i){
        sz[i]=cnt[i]+sz[lc[i]]+sz[rc[i]];
        diff[i]=(cnt[i]>0)+diff[lc[i]]+diff[rc[i]];
    }
    // 【必备】中序遍历
    void inorder(int i){
        if(!i)return;
        inorder(lc[i]);
        if(cnt[i])collect[++ci]=i;
        inorder(rc[i]);
    }
    // 【必备】重建递归函数
    int build(int l,int r){
        if(l>r)return 0;
        int mid=(l+r)/2;
        int i=collect[mid];
        lc[i]=build(l,mid-1);
        rc[i]=build(mid+1,r);
        up(i);
        return i;
    }
    // 【必备】重建主函数
    void rebuild(){
        if(!tp)return;
        ci=0;
        inorder(*tp);
        *tp = build(1,ci);       
    }
    // 【必备】判断平衡
    bool imbalance(int i){
        return max(diff[lc[i]],diff[rc[i]])>ALPHA*diff[i];
    }
    // insert 入口
    void insert(int k){
        tp=0;
        _insert(rt,k);
        rebuild();
    }
    // 【必备】内部 insert (log)
    void _insert(int& i,int k){
        if(!i)i=new_node(k);
        else {
            if(k==key[i])cnt[i]++;
            else if(k<key[i])_insert(lc[i],k);
            else _insert(rc[i],k);
            up(i);
            if(imbalance(i))tp=&i;
        }
    }
    // erase 的入口
    void erase(int k){
        // if(rank(k)==rank(k+1))return;// 【RE】前提有数 
        tp=0;
        _erase(rt,k);
        rebuild();
    }
    // 【必备】内部 erase (log)
    void _erase(int& i,int k){
        if(!i)return;// 【RE】method
        // 艹艹艹艹艹艹艹艹艹艹艹艹艹悬挂 else艹艹艹艹艹艹艹艹艹艹艹艹艹艹艹艹艹
        // if(k==key[i])if(cnt[i])cnt[i]--;// 【RE】method
        if(k==key[i])cnt[i]?cnt[i]--:0;// 【RE】method
        else if(k<key[i])_erase(lc[i],k);
        else _erase(rc[i],k);
        up(i);
        if(imbalance(i))tp=&i;
    }
    // 【必备】查询排名 (迭代)
    int rank(int k){
        int i=rt,res=1;
        while(i){
            if(k<key[i])i=lc[i];
            else if(k>key[i])res+=sz[lc[i]]+cnt[i],i=rc[i];
            else return res+sz[lc[i]];
        }
        return res;
    }
    // 【必备】查询排名为 x 的数 (迭代)
    int at(int x){
        if(x<1)return -inf;
        if(x>sz[rt])return inf;
        int i=rt;
        while(i){
            if(x<=sz[lc[i]])i=lc[i];
            else if(x>sz[lc[i]]+cnt[i])x-=sz[lc[i]]+cnt[i],i=rc[i];
            else return key[i];
        }
        assert(0&&"EMPTY");
    }
    // 【重要】< k 的最大值 (2迭代)
    int prev(int k){return at(rank(k)-1);}
    // 【重要】> k 的最小值 (2迭代)
    int next(int k){return at(rank(k+1));}
}T;
void solve2(){
    T.clear();
    int n,m,op,a,x,lst=0,ans=0;
    cin>>n>>m;
    while(n--)cin>>a,T.insert(a);
    while(m--){
        cin>>op>>x;x^=lst;
        if(op==1)T.insert(x);
        else if(op==2)T.erase(x);
        else if(op==3)ans^=lst=T.rank(x);
        else if(op==4)ans^=lst=T.at(x);
        else if(op==5)ans^=lst=T.prev(x);
        else if(op==6)ans^=lst=T.next(x);
        else assert(0&&"ERROR");
    }
    cout<<ans<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve2();
}
```

=== 笛卡尔树 (CTree)

#note[
    深入理解:

    + 中序遍历是原序列 => 一个子树的序列是连续的
    + 整个树是一个堆
    + `lca` 代表区间最值
    + 相等元素只会形成 *右链* => 默认忽略左上方相同元素享有的范围 => 一种二维强制偏序
]

+ 可以静态 lca RMQ
+ 可以最值分治(+启发式合并)

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=2e6+5;
struct CTree{
    inline static int stk[N];// 左右孩子 单调栈
    int lc[N],rc[N],rt;
    // 好像可以用 L R 维护当前节点子树的范围
    int L[N],R[N],sz[N];
    int* data;
    void build(int* a,int n,auto cmp){
        data=a;
        for(int i=1,tp=0,pos=0;i<=n;i++){
            // 按需 大根堆:less<>() 小根堆:greater<>()
            while(pos&&cmp(a[stk[pos]],a[i]))pos--;//出栈操作
            if(pos)rc[stk[pos]]=i;
            if(pos<tp)lc[i]=stk[pos+1];
            stk[++pos]=i;
            tp = pos;
        }
        rt=stk[1];// stk[1] 就是根!!!
    }
    void dfs(int i){
        if(!i)return;
        dfs(lc[i]);
        dfs(rc[i]);
        L[i]=lc[i]?L[lc[i]]:i;
        R[i]=rc[i]?R[rc[i]]:i;
        sz[i]=R[i]-L[i]+1;
    }
    inline static int n,a[N];
    inline static long long ans=0;
    void solve_P2659(){
        cin>>n;
        for(int i=1;i<=n;i++)cin>>a[i];
        build(a,n,greater<int>());
        dfs(rt);
        ans=0;
        for(int i=1;i<=n;i++)
        ans=max(ans,(long long)a[i]*(R[i]-L[i]+1));
        cout<<ans<<"\n";
    }
    // map<int,int> S[N];// CF1156E
    // void CF1156E(int u){
    //     if(!u)return;
    //     CF1156E(lc[u]);
    //     CF1156E(rc[u]);
    //     // 【NB】!!!  引用 tmd和指针一样
    //     auto& S1 = S[lc[u]],&S2 = S[rc[u]];
    //     if(S1.size()<S2.size())swap(S1,S2);// 启发式合并
    //     for(auto[a,c]:S2){
    //         auto it = S1.find(data[u]-a);
    //         if(it!=S1.end())ans+=(long long)c*it->second;
    //     }
    //     for(auto[a,c]:S2)S1[a]+=c;
    //     S1[data[u]]++;
    //     swap(S[u],S1);
    // }
    // void solve_CF1156E(){
    //     cin>>n;
    //     for(int i=1;i<=n;i++)cin>>a[i];
    //     build(a,n,less<int>());
    //     ans=0;CF1156E(rt);
    //     cout<<ans<<"\n";
    // }
}T;
int main(){
    cin.tie(0)->sync_with_stdio(0);
    T.solve_P2659();
    // T.solve_CF1156E();
}
```

=== Size Balanced Tree

#note[
    TO DO 火箭毛毛虫 给的模板太 SHI 了 
]

=== AVL 树 / 红黑树 / 左偏红黑树 / AA 树 / 跳表

#note[略略略略略]

== 可持久化数据结构

=== 可持久化线段树 / 主席树

==== 可持久化数组 (PArray) (单点修改 + 单点查询)

- 时间 $O(m log n)$
- 空间 $O(n (4 + log m))$

```cpp
#include <bits/stdc++.h>
using namespace std;
const int N = 1e6+5;
const int M = 1e6+5;
namespace PArray{
    struct PersistentTree{
        int lc,rc,val;
    }tr[N*4+M*(1+__lg(N))];
    int rt[N],tot;
    int build(int l,int r,int* a) {
        int cur=++tot;
        if(l==r){
            tr[cur].val=a[l];
        }else{ 
            int mid=(l+r)/2;
            tr[cur].lc=build(l,mid,a);
            tr[cur].rc=build(mid+1,r,a);
        }
        return cur;
    }
    int modify(int i,int l,int r,int p,int v){
        int cur = ++tot;
        tr[cur]=tr[i];
        if(l==r){
            tr[cur].val=v;
        }else {
            int mid=(l+r)/2;
            if(p<=mid)tr[cur].lc=modify(tr[i].lc,l,mid,p,v);
            else tr[cur].rc=modify(tr[i].rc,mid+1,r,p,v);
        }
        return cur;
    }
    int query(int i,int l,int r,int p) {
        if(l==r) return tr[i].val;
        int mid=(l+r)/2;
        if(p<=mid)return query(tr[i].lc,l,mid,p);
        else return query(tr[i].rc,mid+1,r,p);
    }
}
using PArray::rt;
int n,m,a[N];
void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;++i)cin>>a[i];
        rt[0]=PArray::build(1,n,a);
        for(int i=1,v,op,p,c;i<=m;i++){
            cin>>v>>op>>p;
            if (op==1){
            cin>>c;
            rt[i]=PArray::modify(rt[v],1,n,p,c);
        }else{
            rt[i]=rt[v];
            cout<<PArray::query(rt[i],1,n,p)<<'\n';
        }
    }
}
int main() {
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

==== 可持久化权值线段树 (PWSTree) (静态区间第 $k$ 大 : 单点修改 + 范围查询)

- 时间 $O(m log n)$
- 空间 $O(n (4 + log m))$

```cpp

#include<bits/stdc++.h>
using namespace std;
const int N=2e5+5;
const int M=2e5+5;
// 可持久化权值线段树(主席树)
namespace PWSTree{
    struct PersistentWeightSegmentTree{
            int lc,rc,sum;
    }tr[N*4+M*(1+__lg(N))];
    int tot,rt[N];
    int add(int i,int l,int r,int p,int v){
        int cur=++tot;
        tr[cur]=tr[i];
        tr[cur].sum+=v;
        if(l<r){
            int mid=(l+r)/2;
            if(p<=mid)tr[cur].lc = add(tr[i].lc,l,mid,p,v);
            else tr[cur].rc = add(tr[i].rc,mid+1,r,p,v);
        }
        return cur;
    }
    int query(int i,int j,int l,int r,int k){
        if(l==r)return l;
        else {
            int dl = tr[tr[j].lc].sum-tr[tr[i].lc].sum;
            int mid=(l+r)/2;
            if(k<=dl)return query(tr[i].lc,tr[j].lc,l,mid,k);
            else return query(tr[i].rc,tr[j].rc,mid+1,r,k-dl);
        }
    }
}
using PWSTree::rt;
int n,m,a[N],b[N],cntA;
unordered_map<int,int> getA;
void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>a[i],b[i]=a[i];
    sort(b+1,b+1+n);cntA=unique(b+1,b+1+n)-b-1;
    for(int i=1;i<=cntA;i++)getA[b[i]]=i;
    for(int i=1;i<=n;i++)rt[i]=PWSTree::add(rt[i-1],1,n,getA[a[i]],1);
    for(int i=1,l,r,k;i<=m;i++){
        cin>>l>>r>>k;
        cout<<b[PWSTree::query(rt[l-1],rt[r],1,n,k)]<<'\n';
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

==== 真可持久化线段树 (PSTree) (范围修改 + 范围查询)

#note[标记永久化前提： 修改和查询的性质均有叠加性]

- 时间 $O(m log n)$
- 空间 $O(4n + m(6 + log n))$ 玄学 $+5$ ? or $*4$ ?

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N = 1e5+5;
const int M = 1e5+5;
namespace PSTree{
    struct PersistentSegmentTree{
        int lc,rc;
        LL sum,add_tag;
    }tr[N*4+M*(6+__lg(N))];// 只加 5 + M*log(N) 神秘的额外 +5
    int tot;
    int build(int l,int r,int* a){
        int cur=++tot;
        tr[cur].add_tag = 0;
        if(l==r)tr[cur].sum = a[l];
        else {
            int mid=(l+r)/2;
            tr[cur].lc = build(l,mid,a);
            tr[cur].rc = build(mid+1,r,a);
            tr[cur].sum = tr[tr[cur].lc].sum + tr[tr[cur].rc].sum;
        }
        return cur;
    }
    int add(int i,int l,int r,int jl,int jr,LL v){
        int cur = ++tot,a=max(jl,l),b=min(jr,r);
        tr[cur]=tr[i];
        tr[cur].sum+=(b-a+1)*v;
        if(jl<=l&&r<=jr)tr[cur].add_tag+=v;
        else {
            int mid=(l+r)/2;
            if(jl<=mid)tr[cur].lc = add(tr[cur].lc,l,mid,jl,jr,v);
            if(jr>mid)tr[cur].rc = add(tr[cur].rc,mid+1,r,jl,jr,v);
        }
        return cur;
    }
    LL query_sum(int i,int l,int r,int jl,int jr,LL add_his){
        if(jl<=l&&r<=jr){
            return tr[i].sum + (r-l+1)*add_his;
        }else {
            int mid=(l+r)/2;
            LL res=0;
            add_his+=tr[i].add_tag;
            if(jl<=mid)res+=query_sum(tr[i].lc,l,mid,jl,jr,add_his);
            if(jr>mid)res+=query_sum(tr[i].rc,mid+1,r,jl,jr,add_his);
            return res;
        }
    }
}
int rt[M];
int n,m,a[N];
void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>a[i];
    rt[0]=PSTree::build(1,n,a);
    string op;// SPOJ 连 char 都卡 string 
    for(int i=1,t=0,x,y,z;i<=m;i++){
        cin>>op;
        if(op=="C"){
            cin>>x>>y>>z;
            rt[++t]=PSTree::add(rt[t],1,n,x,y,z);
        }else if(op=="Q"){
            cin>>x>>y;
            cout<<PSTree::query_sum(rt[t],1,n,x,y,0)<<'\n';
        }else if(op=="H"){
            cin>>x>>y>>z;
            cout<<PSTree::query_sum(rt[z],1,n,x,y,0)<<'\n';
        }else cin>>x,t=x;
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

==== 可持久化并查集 (PDSU)

#note[无路径压缩]

```cpp
// P3402
#include <bits/stdc++.h>
using namespace std;

const int N = 1e5+5;
const int M = 2e5+5;

struct PersistentDSU{ 
    int lc,rc,val,rnk;
}tr[N*2+M*40];

#define lc(x) tr[x].lc
#define rc(x) tr[x].rc
#define val(x) tr[x].val
#define rnk(x) tr[x].rnk

int rt[M],n,m,tot;

// 建初始版本：每个点父为自身，秩为1
int build(int l,int r){
    int cur=++tot;
    val(cur)=l;
    rnk(cur)=1;
    if(l==r)return cur;
    int mid=(l+r)/2;
    lc(cur)=build(l,mid);
    rc(cur)=build(mid+1,r);
    return cur;
}
// 修改 p 的父节点为 v，返回新版本根
int modify_val(int i,int l,int r,int p,int v) {
    int cur=++tot;
    tr[cur]=tr[i];
    if (l==r){ 
        val(cur)=v;
    }else{
        int mid=(l+r)/2;
        if (p<=mid)lc(cur)=modify_val(lc(i),l,mid,p,v);
        else rc(cur)=modify_val(rc(i), mid+1,r,p,v);
    }
    return cur;
}
// 修改 p 的秩为 max(原值, v)，返回新版本根
int modify_rnk(int i,int l,int r,int p,int v){
    int cur=++tot;
    tr[cur]=tr[i];
    if(l==r){
        rnk(cur)=max(rnk(cur),v);
    }else {
        int mid=(l+r)/2;
        if(p<=mid)lc(cur)=modify_rnk(lc(cur),l,mid,p,v);
        else rc(cur)=modify_rnk(rc(cur),mid+1,r,p,v);
    }
    return cur;
}
// 查询 p 的父节点值（即 val）
int query_val(int i,int l,int r,int p){
    if(l==r){
        return val(i);
    }else {
        int mid=(l+r)/2;
        if(p<=mid)return query_val(lc(i),l,mid,p);
        else return query_val(rc(i),mid+1,r,p);
    }
}
// 查询位置 p 的秩（用于按秩合并）
int query_rnk(int i,int l,int r,int p){
    if(l==r){
        return rnk(i);
    }else {
        int mid=(l+r)/2;
        if(p<=mid)return query_rnk(lc(i),l,mid,p);
        else return query_rnk(rc(i),mid+1,r,p);
    }
}
// 在版本 i 中查找 x 的根（递归路径查询，无路径压缩）
int fd(int i, int x){
    int f=query_val(i,1,n,x);
    if(x==f)return x;
    else return fd(i,f);
}
int main() {
    cin.tie(0)->sync_with_stdio(0);
    cin>>n>>m;
    rt[0]=build(1,n); // 初始版本
    for (int i =1;i<=m;i++) {
        int op,a,b;
        cin>>op;
        if(op==1){ // 合并 a,b 所在集合（按秩合并）
            cin>>a>>b;
            int fa=fd(rt[i-1],a),fb=fd(rt[i-1],b);
            if(fa==fb)rt[i]=rt[i-1];
            else{
                if (query_rnk(rt[i-1],1,n,fa)>query_rnk(rt[i-1],1,n,fb))swap(fa,fb);
                int tmp=modify_val(rt[i-1],1,n,fa,fb);
                rt[i]=modify_rnk(tmp,1,n,fb,query_rnk(rt[i-1],1,n,fa)+1);
            }
        }else if(op==2){ // 回滚到版本 a
            cin>>a;
            rt[i]=rt[a];
        }else{// 查询 a,b 是否连通
            cin>>a>>b;
            rt[i]=rt[i-1];
            cout<<(fd(rt[i],a)==fd(rt[i],b))<<'\n';
        }
    }
    return 0;
}
```

=== 可持久化块状数组 (rope)

#note[
    STL 中的 `rope` 也起到块状链表的作用，它采用可持久化平衡树实现，可完成随机访问和插入、删除元素的操作。
]

- 不可修改
- 自带 crope 类似字符串
- 拷贝 $O(1)$
- 插入 删除 提取 拼接 $O(log n)$

```cpp
#include<bits/extc++.h>
#include<bits/stdc++.h>
using namespace std;
using namespace __gnu_cxx;
int a0[4] = {1,2,3,4};
void solve(){
    crope s1 = "Hello";
    cout<<s1<<'\n';// 正常
    rope<char> s2 = "World!";
    cout<<s2<<'\n';// 正常
    rope<int> a1(a0);// 有多余数据读入
    for(auto i:a1)cout<<i<<" ";cout<<'\n';
    rope<int> a2(3,6);// 3 个 6
    for(auto i:a2)cout<<i<<" ";cout<<'\n';
    rope<int> a3(99999);// 作为单个元素初始化。。。
    for(auto i:a3)cout<<i<<" ";cout<<'\n';
    rope<int> a4(3,1);// {1,1,1}
    // iota(a4.begin(),a4.end(),0);// 不能用左值不可改
    // a4[0]=9;// 左值不可改
    a4.erase(2,1);// {1,1}
    a4.insert(2,8);// 但是可以删除再插入 {1,1,8}
    a4.insert(2,9);// 但是可以删除再插入 {1,1,9,8}
    for(auto i:a4)cout<<i<<" ";cout<<'\n';
    a4.balance();
    for(auto i:a4)cout<<i<<" ";cout<<'\n';
    rope<int> a5 = a4;
    for(auto i:a5)cout<<i<<" ";cout<<'\n';
    a4.insert(10,-1);// ? 并非数组 可以跳跃式下标
    for(auto i:a4)cout<<i<<" ";cout<<'\n';
    cout<<s1.size()<<'\n';
    s1.insert(10," World!");
    cout<<s1.size()<<'\n';
    cout<<s1<<'\n';
    s1.balance();
    cout<<s1.size()<<'\n';
    cout<<s1.front()<<"!\n";
    cout<<s1.back()<<"!\n";
    s1.push_back('6');
    cout<<s1<<'\n';
}
int main(){
    solve();
    return 0;
}
```

=== 可持久化平衡树

==== 可持久化平衡树 (PTreap)

#note[
    一般的散装版本 PTreap
]

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=5e5+5;
const int M =5e5+5;
const int inf=INT_MAX;
namespace PTreap{
    struct PersistentFHQTreap{
        int lc,rc,sz,val;
        int key;
    }tr[N*(5+5*__lg(M))];
    int tot;
    #define lc(i) tr[i].lc
    #define rc(i) tr[i].rc
    #define sz(i) tr[i].sz
    #define val(i) tr[i].val
    #define key(i) tr[i].key
    // 【注】可持久化操作
    int copy(int i){
        tr[++tot]=tr[i];
        return tot;
    }
    int new_node(int k){
        int i=++tot;
        key(i)=k;sz(i)=1;
        lc(i)=rc(i)=0;
        val(i)=rand()^(rand()<<15);
        return i;
    }
    void up(int i){
        sz(i)=1+sz(lc(i))+sz(rc(i));
    }
    void split(int i,int l,int r,int k){
        if(!i)rc(l)=lc(r)=0;// 这里不是 i 是 l r
        else {
            i = copy(i);// 【注】拷贝
            if(key(i)<=k){
                rc(l)=i;
                split(rc(i),i,r,k);
            }else {
                lc(r)=i;
                split(lc(i),l,i,k);
            }
            up(i);
        }
    }
    int merge(int l,int r){
        if(!l||!r)return l|r;
        if(val(l)>=val(r)){
            l = copy(l);// 【注】拷贝(可能冗余)
            rc(l)=merge(rc(l),r);
            up(l);
            return l;
        }else {
            r=copy(r);// 【注】拷贝(可能冗余)
            lc(r)= merge(l,lc(r));
            up(r);
            return r;
        }
    }
    // 基于 i 版本(树头), 插入键为 k 的元素, 返回新的版本(树头) 
    int insert(int i,int k){
        split(i,0,0,k);
        int l=rc(0),r=lc(0);
        // 【注】后续可能基于0版本生成新版本的树 一定要清空
        lc(0)=rc(0)=0;
        // 【注】修改操作返回版本号(根)
        return merge(merge(l,new_node(k)),r);
    }
    // 基于 i 版本(树头), 删除一个键为 k 的元素, 返回新的版本(树头) 
    int erase(int i,int k){
        split(i,0,0,k);
        int lm=rc(0),r=lc(0);
        split(lm,0,0,k-1);
        int l=rc(0),m=lc(0);
        // 【注】后续可能基于0版本生成新版本的树 一定要清空
        lc(0)=rc(0)=0;
        // 【注】修改操作返回版本号(根)
        return merge(merge(l,merge(lc(m),rc(m))),r);
    }
    // 【注】直接用 i
    int rank(int i,int k){
        if(!i)return 0;// 按照题目尿性 并没有限制 res>=1
        int res=1;
        while(i){
            if(k<=key(i))i=lc(i);
            else res+=sz(lc(i))+1,i=rc(i);
        }
        return res;
    }
    // 【注】直接用 i
    int at(int i,int x){
        if(x<1)return -inf;
        if(x>sz(i))return inf;
        while(i){
            if(x<=sz(lc(i)))i=lc(i);
            else if(x==sz(lc(i))+1)return key(i);
            else x-=sz(lc(i))+1,i=rc(i);     
        }
        assert(0&&"EMPTY");
    }
    // 【注】直接用 i
    int prev(int i,int k){return at(i,rank(i,k)-1);}
    // 【注】直接用 i
    int next(int i,int k){return at(i,rank(i,k+1));}
}
int rt[N];
void solve(){
    int n,v,op,x;
    cin>>n;
    for(int i=1;i<=n;i++){
        cin>>v>>op>>x;
        if(op==1)rt[i]=PTreap::insert(rt[v],x);
        else if(op==2)rt[i]=PTreap::erase(rt[v],x);
        else if(op==3)rt[i]=rt[v],cout<<PTreap::rank(rt[i],x)<<'\n';
        else if(op==4)rt[i]=rt[v],cout<<PTreap::at(rt[i],x)<<'\n';
        else if(op==5)rt[i]=rt[v],cout<<PTreap::prev(rt[i],x)<<'\n';
        else if(op==6)rt[i]=rt[v],cout<<PTreap::next(rt[i],x)<<'\n';
        else assert(0&&"INVALIT OP");
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

#note[
    cnt 计数版本 PTreap
    - `merge` 无需拷贝产生冗余节点
]

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N = 5e5 + 5;
const int inf = INT_MAX;
/*
【另类】 使用 cnt 计数 
性质: merge 时不再需要 copy() (避免了冗余拷贝)
*/
namespace PTreap {
    struct Node {
        int lc, rc, sz, cnt, val, key;
    } tr[N*50]; // 空间通常开 N * 40~50 即可
    int tot;
    #define lc(i) tr[i].lc
    #define rc(i) tr[i].rc
    #define sz(i) tr[i].sz
    #define cnt(i) tr[i].cnt
    #define val(i) tr[i].val
    #define key(i) tr[i].key
    int copy(int i) {
        if (!i) return 0;
        tr[++tot] = tr[i];
        return tot;
    }
    int new_node(int k) {
        int i = ++tot;
        key(i) = k; sz(i) = 1; cnt(i) = 1;
        lc(i) = rc(i) = 0;
        val(i) = rand();
        return i;
    }
    void up(int i) {
        if (!i) return;
        sz(i) = cnt(i) + sz(lc(i)) + sz(rc(i));
    }
    // 标准的可持久化 Split，必须 copy
    void split(int i, int x, int &l, int &r) {
        if (!i) {
            l = r = 0;
            return;
        }
        i = copy(i); // 路径克隆
        if (key(i) <= x) {
            l = i;
            split(rc(i), x, rc(l), r);
        } else {
            r = i;
            split(lc(i), x, l, lc(r));
        }
        up(i);
    }
    // 【关键修改】不再需要 copy
    int merge(int l, int r) {
        if (!l || !r) return l | r;
        // 因为 l 和 r 的祖先路径在 split 时已经 copy 过了
        // 这里直接修改不会破坏历史版本
        if (val(l) > val(r)) {
            rc(l) = merge(rc(l), r);
            up(l);
            return l;
        } else {
            lc(r) = merge(l, lc(r));
            up(r);
            return r;
        }
    }
    int insert(int rt, int k) {
        int l, r, m;
        split(rt, k, l, r);
        split(l, k - 1, l, m);
        if (m) {
            m = copy(m); // 发现已有该键，克隆并增加计数
            cnt(m)++;
            up(m);
        } else m = new_node(k);
        return merge(merge(l, m), r);
    }
    int erase(int rt, int k) {
        int l, r, m;
        split(rt, k, l, r);
        split(l, k - 1, l, m);
        if (m) {
            m = copy(m);
            if (cnt(m) > 1) {
                cnt(m)--;
                up(m);
                l = merge(l, m);
            }// else // cnt 为 1，直接丢弃 m 节点，l 保持原样
        }
        return merge(l, r);
    }
    int rank(int i, int k) {
        int res = 1;
        while (i) {
            if (k < key(i)) i = lc(i);
            else if (k == key(i)) return res + sz(lc(i));
            else res += sz(lc(i)) + cnt(i),i = rc(i);
        }
        return res;
    }
    int at(int i, int x) {
        while (i) {
            if (x <= sz(lc(i))) i = lc(i);
            else if (x <= sz(lc(i)) + cnt(i)) return key(i);
            else x -= (sz(lc(i)) + cnt(i)),i = rc(i);
        }
        return 0;
    }
    int prev(int i, int k) {return at(i,rank(i,k)-1);}
    int next(int i, int k) {return at(i,rank(i,k+1));}
}
int rt[N];
int main() {
    ios::sync_with_stdio(0); cin.tie(0);
    int n; cin >> n;
    for (int i = 1; i <= n; i++) {
        int v, op, x;
        cin >> v >> op >> x;
        if (op == 1) rt[i] = PTreap::insert(rt[v], x);
        else if (op == 2) rt[i] = PTreap::erase(rt[v], x);
        else {
            rt[i] = rt[v];
            if (op == 3) cout << PTreap::rank(rt[i], x) << "\n";
            else if (op == 4) cout << PTreap::at(rt[i], x) << "\n";
            else if (op == 5) cout << PTreap::prev(rt[i], x) << "\n";
            else if (op == 6) cout << PTreap::next(rt[i], x) << "\n";
        }
    }
    return 0;
}
```


==== 可持久化文艺平衡树 (PLTreap)

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N = 2e5+5;
const int M = 2e5+5;
// 注意：文艺平衡树并不是 key 有序
namespace PLTreap{
    struct PersistentLiteraryTree{
        int lc,rc,sz,val;
        int key;
        LL sum;
        bool rev;
    }tr[N*(5+5*__lg(M))];
    int tot;
    #define lc(i) tr[i].lc
    #define rc(i) tr[i].rc
    #define sz(i) tr[i].sz
    #define val(i) tr[i].val
    #define key(i) tr[i].key
    #define sum(i) tr[i].sum
    #define rev(i) tr[i].rev
    // 【注】拷贝
    int copy(int i){
        tr[++tot]=tr[i];
        return tot;
    }
    int new_node(int k){
        int i=++tot;
        sum(i)=key(i)=k;sz(i)=1;// 【】sum(i)=key(i)!!!
        rev(i)=lc(i)=rc(i)=0;
        val(i)=rand()^(rand()<<15);
        return i;
    }
    void up(int i){
        sz(i)=1+sz(lc(i))+sz(rc(i));
        sum(i)=key(i)+sum(lc(i))+sum(rc(i));
    }
    // 【注】儿子要判空 
    void down(int i){
        if(rev(i)){
            if(lc(i))lc(i)=copy(lc(i)),rev(lc(i))^=1;//【注】
            if(rc(i))rc(i)= copy(rc(i)),rev(rc(i))^=1;// 【注】
            swap(lc(i),rc(i));
            rev(i)=0;
        }
    }
    // 【注】
    void split(int i,int l,int r,int x){
        if(!i)rc(l)=lc(r)=0;
        else {
            i=copy(i);// 【注】拷贝
            down(i);
            if(x<=sz(lc(i))){
                lc(r)=i;
                split(lc(i),l,i,x);
            }else {
                rc(l)=i;
                split(rc(i),i,r,x-sz(lc(i))-1);
            }
            up(i);
        }
    }
    // 【注】
    int merge(int l,int r){
        if(!l||!r)return l|r;
        if(val(l)>=val(r)){
            l=copy(l);// 【注】拷贝
            down(l);
            rc(l)=merge(rc(l),r);
            up(l);
            return l;
        }else {
            r=copy(r);// 【注】拷贝
            down(r);
            lc(r)=merge(l,lc(r));
            up(r);
            return r;
        }
    }
    // 【注】有修改操作
    int insert(int i,int x,int k){
        split(i,0,0,x-1);
        int l=rc(0),r=lc(0);
        lc(0)=rc(0)=0;// 【注】
        return merge(merge(l,new_node(k)),r);
    }
    // 【注】有修改操作
    int erase(int i,int x){
        split(i,0,0,x);
        int lm=rc(0),r=lc(0);
        split(lm,0,0,x-1);
        int l=rc(0),m=lc(0);
        lc(0)=rc(0)=0;// 【注】
        return merge(l,r);
    }
    // 【注】有修改操作
    int reverse(int i,int L,int R){
        split(i,0,0,R);
        int lm=rc(0),r=lc(0);
        split(lm,0,0,L-1);
        int l=rc(0),m=lc(0);
        lc(0)=rc(0)=0;// 【注】
        rev(m)^=1;
        return merge(merge(l,m),r);
    }
    // 【注】这里的 query 仍会产生修改 !!! 没办法的
    pair<int,LL> query(int i,int L,int R){
        split(i,0,0,R);
        int lm=rc(0),r=lc(0);
        split(lm,0,0,L-1);
        int l=rc(0),m=lc(0);
        lc(0)=rc(0)=0;// 【注】
        LL tmp=sum(m);
        return {merge(merge(l,m),r),tmp};
    }
}
int rt[N];
void solve(){
    int n;LL lastans=0,v,op,x,l,r,p;cin>>n;
    for(int i=1;i<=n;i++){
        cin>>v>>op;
        if(op==1){
            cin>>p>>x;p^=lastans,x^=lastans;
            rt[i]=PLTreap::insert(rt[v],p+1,x);
        }else if(op==2){
            cin>>p;p^=lastans;
            rt[i]=PLTreap::erase(rt[v],p);
        }else if(op==3){
            cin>>l>>r;l^=lastans,r^=lastans;
            rt[i]=PLTreap::reverse(rt[v],l,r);
        }else if(op==4){
            cin>>l>>r;l^=lastans,r^=lastans;
            tie(rt[i],lastans)=PLTreap::query(rt[v],l,r);
            cout<<lastans<<'\n';
        }
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

==== #strike("可持久化 WBLT")

#note[
    TO DO hyw
]

=== 可持久化字典树 

#note[
    好久不见, 几乎忘了这种东西     
]

- 总之可持久化的字典树用于解决树上区间查询问题
- 利用差分思想

- (个人理解:)
- *对于前缀(边或点)差分*，有两种方法
  - 单根 query 外部差分 $x + y - 2 "lca" / "falca"$ (粗查询)
  - 双根 query 外部分段 $x arrow.t "lca" + y arrow.t "lca"$ (精准查询，其实不是差分)
- *对于子树(点)差分* (未给出)，同样
  - 单 dfn query 外部差分 $(x + "sz") - "fa"$ (粗查询)
  - 双 dfn query 外部分段 $x arrow.t (x + "sz")$ (精准查询，其实不是差分)

==== 可持久化 01Trie (PTrie01)

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=3e5+5;
const int M=3e5+5;
const int B=30;
namespace PTrie01{
    struct PersistentTrie01{
        int ch[2],pass;
    }tr[N*(B+1)*2];// 神秘*2
    int tot;
    int insert(int i,int x){
        int root=++tot;// 创建
        tr[root]=tr[i];// 拷贝
        tr[root].pass++;// ++
        for(int b=B,to,cur=root;b>=0;b--){
            to = x>>b&1;
            i=tr[i].ch[to];
            tr[cur=tr[cur].ch[to]=++tot]=tr[i];
            tr[cur].pass++;// ++ 
        }
        return root;
    }
    int query(int i,int j,int x){
        int ans=0;
        for(int b=B,to;b>=0;b--){
            to = ((x>>b)&1)^1;
            if(tr[tr[i].ch[to]].pass<tr[tr[j].ch[to]].pass){
                ans|=1<<b;
                i=tr[i].ch[to];
                j=tr[j].ch[to];
            }else {
                i=tr[i].ch[to^1];
                j=tr[j].ch[to^1];
            }
        }
        return ans;
    }
}
int rt[N+M];// 忘啦新根 ！
int n,m,xor_sum;
void solve(){
    cin>>n>>m;
    rt[0]=PTrie01::insert(rt[0]=0,xor_sum=0);
    for(int i=1,x;i<=n;i++){
        cin>>x;
        xor_sum^=x;// 区间和往往插入 前缀和进行差分
        rt[i]=PTrie01::insert(rt[i-1],xor_sum);
    }
    string op;
    for(int i=1,x,y,z;i<=m;i++){
        cin>>op;
        if(op=="A"){
            cin>>x;xor_sum^=x;
            rt[++n]=PTrie01::insert(rt[n],xor_sum);
        }else {
            cin>>x>>y>>z;
            if(x==1)cout<<PTrie01::query(0,rt[y-1],xor_sum^z)<<'\n';
            else cout<<PTrie01::query(rt[x-1-1],rt[y-1],xor_sum^z)<<'\n';
        }
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();// P4735 最大异或和
}
```

==== 可持久化 Trie (PTrie)

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=1e5+5;
const int C=26,L=10;
int path(char c){return c-'a';}
namespace PTrie{
    struct PersistentTrie{
        int ch[C],pass;
    }tr[N*(L+1)];
    int tot;
    int insert(int i,string s){
        int root=++tot;
        tr[root]=tr[i];
        tr[root].pass++;
        for(int b=0,cur=root,to;b<s.size();b++){
            to=path(s[b]);
            i=tr[i].ch[to];
            tr[cur=tr[cur].ch[to]=++tot]=tr[i];
            tr[cur].pass++;
        }
        return root;
    }
    // 除了外部差分，其实也可以内差分，比如这里加上 j 限制 d_pass
    int query(int i,string s){
        for(int b=0,to;b<s.size();b++){
            to=path(s[b]);
            i=tr[i].ch[to];
            if(!i)return 0;
        }
        return tr[i].pass;
    }
}
int rt[N];
int n,q,P;
int st[N][2+__lg(N)],dep[N];
vector<pair<int,string>> e[N];
void dfs0(int u){
    dep[u]=dep[st[u][0]]+1;
    for(int p=1;p<=P;p++)st[u][p]=st[st[u][p-1]][p-1];
    for(auto& [v,w]:e[u])if(v!=st[u][0]){
        st[v][0]=u;
        dfs0(v);
    }
}
int lca(int a,int b){
    if(dep[a]<dep[b])swap(a,b);
    for(int p=P;p>=0;p--)if(dep[st[a][p]]>=dep[b])a=st[a][p];
    if(a==b)return a;
    for(int p=P;p>=0;p--)if(st[a][p]!=st[b][p])a=st[a][p],b=st[b][p];
    return st[a][0];
}
void dfs1(int u){
    for(auto& [v,w]:e[u])if(v!=st[u][0]){
        rt[v]=PTrie::insert(rt[u],w);
        dfs1(v);
    }
}
void solve(){
    cin>>n;P=__lg(n)+1;
    string w;
    for(int u,v,i=1;i<n;i++){
        cin>>u>>v>>w;
        e[u].emplace_back(v,w);
        e[v].emplace_back(u,w);
    }
    dfs0(1);dfs1(1);
    cin>>q;
    for(int x,y,i=1;i<=q;i++){
        cin>>x>>y>>w;
        cout<<PTrie::query(rt[x],w)+PTrie::query(rt[y],w)-2*PTrie::query(rt[lca(x,y)],w)<<'\n';
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();// P6088 字符串树
}
```

=== 可持久化可并堆 (PLTree)

#note[
    核心代码
]

```cpp
int merge(int x,int y){
    if(!x||!y)return x|y;
    int z=++tot;
    if(tr[x]<tr[y])swap(x,y);
    tr[z]=tr[x];
    tr[z].rc=merge(tr[z].rc,y);
    if(tr[tr[z].lc].d<tr[tr[z].rc].d)swap(tr[z].lc,tr[z].rc);
    tr[z].d=tr[tr[z].rc].d+1;
    return z;
}
```

==== $k$ 短路

时间 $O((n+m) log n + k log k)$

```cpp
#include<bits/stdc++.h>
using namespace std;
// k-短路
// 复杂度是 (n+m)*log(n) + klog(k)
const int N=5e3+5;
const int M=2e5+5;
const double inf = 1e18;
const double eps = 1e-6;
namespace PLTree{
    struct PersistentLeftistTree{
        // 尽可能避免在结构体里面赋非0值 
        // 因为一旦有一个，编译文件过大，所以说建议用init用一个初始化一个
        int lc,rc,d; 
        int v;// 信息1：冗余路目标
        double w;// 信息2：冗余路长度
        bool operator<(const PersistentLeftistTree& o)const{
            return w>o.w+eps;
        }
    }tr[N*500];
    int tot;
    // 左偏树操作1：merge
    int merge(int x,int y){
        if(!x||!y)return x|y;
        int z=++tot;
        if(tr[x]<tr[y])swap(x,y);
        tr[z]=tr[x];
        tr[z].rc=merge(tr[z].rc,y);
        if(tr[tr[z].lc].d<tr[tr[z].rc].d)swap(tr[z].lc,tr[z].rc);
        tr[z].d=tr[tr[z].rc].d+1;
        return z;
    }
    // 左偏树操作2：简单封装insert
    int insert(int x,int v,double w){
        tr[++tot].v=v;
        tr[tot].w=w;
        return merge(x,tot);
    }    
}using PLTree::tr;
int top[N];
// 唉wc 有重边 不能直接判 节点
// e[0]正向边 e[1]反向边 对应编号相同
struct Edge{
    int to,nxt;
    double w;
}e[2][M];
int cntE[2],hd[2][N];
// 注意这里的 w 别写成 int 了 
void addEdge(int u,int v,double w,int i){
    e[i][++cntE[i]]={v,hd[i][u],w};
    hd[i][u]=cntE[i];
}
int n,m;
double E;
double h[N];// 启发函数
bool vis[N];// dijk 辅助
int lst[N];// dijk 更新最短路对应父边编号, 可求得具体父节点
void dijk(int s){
    fill(h,h+n+1,inf);
    memset(vis,0,sizeof(vis[0])*(n+1));
    priority_queue<pair<double,int>> Q;
    h[s]=0;
    Q.push({0,s});
    while(Q.size()){
        auto [d,u] = Q.top();Q.pop();
        if(vis[u])continue;
        vis[u]=true;
        for(int i=hd[1][u];i;i=e[1][i].nxt){
            int v=e[1][i].to;
            double w=e[1][i].w;
            if(h[v]>h[u]+w+eps){
                h[v]=h[u]+w;
                lst[v]=i;
                Q.push({-h[v],v});
            }
        }
    }
}
// dfs 收集堆 不能保证 h 递增
// 收集堆的正解： bfs! 按照 h 升序 
int order[N];
void init(){
    iota(order,order+n,1);
    sort(order,order+n,[&](int a,int b){
        return h[a]<h[b];
    });
    for(int i=1;i<n;i++){
        int u=order[i];
        // 这样根据父边可以找到父节点 
        top[u]=top[e[0][lst[u]].to];
        for(int i=hd[0][u];i;i=e[0][i].nxt){
            int v=e[0][i].to;
            double w=e[0][i].w;
            if(i==lst[u])continue;
            top[u]=PLTree::insert(top[u],v,h[v]-h[u]+w);
        }
    }
}
void solve(){
    cin>>n>>m>>E;
    int u,v;
    double w;
    for(int i=1;i<=m;i++){
        cin>>u>>v>>w;
        if(u==n)continue;
        addEdge(u,v,w,0);
        addEdge(v,u,w,1);
    }
    dijk(n);
    init();
    E-=h[1];
    if(E+eps<0){cout<<"0\n";return;}
    int ans=1;
    // <冗余路径代价, 对应左偏树节点编号>
    priority_queue<pair<double,int>>Q; 
    if(top[1])
        Q.emplace(-(h[1]+tr[top[1]].w),top[1]);
    while(Q.size()){
        auto [d,x]=Q.top();Q.pop();
        d=-d;
        E-=d;
        if(E+eps<0)break;
        ans++;
        if(tr[x].lc)// 前提是有冗余路
            Q.emplace(-(d-tr[x].w+tr[tr[x].lc].w),tr[x].lc);
        if(tr[x].rc)// 前提是有冗余路
            Q.emplace(-(d-tr[x].w+tr[tr[x].rc].w),tr[x].rc);
        if(top[tr[x].v])// 前提是有冗余路
            Q.emplace(-(d+tr[top[tr[x].v]].w),top[tr[x].v]);
    }
    cout<<ans<<'\n';
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

== 树套树

=== 原理

- 外部结构 嵌套 内部结构 
    - 结构可以是 *树状数组* *线段树* *平衡树* *分块结构*
    - 外部结构组织的每一个范围 其中的信息 都对应一个内部结构来维护
    - 单次操作的时间复杂度: 外部\*内部

- 树套树的类型很多 具体问题具体分析 
    + 确定外部如何*拆分范围* 
    + 然后确定内部如何*维护信息*

- 码量大 空间多
    - 常用手段 值域离散化 & 开点线段树

=== 线段树 套 线段树 (STreeSTree)

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=102,M=1002;
struct STree{
    int f[M*4];
    void up(int i){f[i]=max(f[i*2],f[i*2+1]);}
    void build(int i,int l,int r){
        if(l==r){
            f[i]=-9;
        }else { 
            int mid=(l+r)/2;
            build(i*2,l,mid);
            build(i*2+1,mid+1,r);
            up(i);
        }
    }
    void set(int i,int l,int r,int p,int v){
        if(l==r){
            f[i]=v;// 这里小巧思
        }else {
            int mid=(l+r)/2;
            if(p<=mid)set(i*2,l,mid,p,v);
            else set(i*2+1,mid+1,r,p,v);
            up(i);
        }
    }
    int query_max(int i,int l,int r,int jl,int jr){
        if(jl<=l&&r<=jr){
            return f[i];
        }else {
            int mid=(l+r)/2;
            int res=-9;
            if(jl<=mid)res=max(res,query_max(i*2,l,mid,jl,jr));
            if(jr>mid)res=max(res,query_max(i*2+1,mid+1,r,jl,jr));
            return res;
        }
    }
};

struct STreeSTree{
    int m;
    STree f[N*4];
    void init(int n,int m){
        this->m=m;
        build(1,1,n);
    }
    void build(int i,int l,int r){
        f[i].build(1,1,m);
        if(l==r){

        }else {
            int mid=(l+r)/2;
            build(i*2,l,mid);
            build(i*2+1,mid+1,r);
        }
    }
    void set(int i,int l,int r,int jp,int kp,int v){
        if(f[i].query_max(1,1,m,kp,kp)<v)// 啊 我的我的我的
            f[i].set(1,1,m,kp,v);
        if(l==r){

        }else {
            int mid=(l+r)/2;
            if(jp<=mid)set(i*2,l,mid,jp,kp,v);
            else set(i*2+1,mid+1,r,jp,kp,v);
        }
    }
    int query(int i,int l,int r,int jl,int jr,int kl,int kr){
        if(jl<=l&&r<=jr){
            return f[i].query_max(1,1,m,kl,kr);
        }else {
            int mid=(l+r)/2;
            int res=-9;// 我的 
            if(jl<=mid)res=max(res,query(i*2,l,mid,jl,jr,kl,kr));
            if(jr>mid)res=max(res,query(i*2+1,mid+1,r,jl,jr,kl,kr));
            return res;
        }
    }

}T;
int m,a,b;
double x,y;
void solve(){
    while(cin>>m,m){// 又是 杭电多测 aaaaaa
        T.init(N-1,M-1);
        while(m--){
            char op;
            cin>>op;
            if(op=='I'){
                cin>>a>>x>>y;
                a-=99;
                x=x*10+1;
                y=y*10+1;
                // [最大笑话]: 带着调试代码提交
                // cout<<a<<" "<<x<<" "<<y<<"\n";
                T.set(1,1,N-1,a,x,y);
            }else {
                cin>>a>>b>>x>>y;
                a-=99;b-=99;x=x*10+1;y=y*10+1;
                if(x>y)swap(x,y);
                if(a>b)swap(a,b);
                // [最大笑话]: 带着调试代码提交
                // cout<<a<<" "<<b<<" "<<x<<" "<<y<<"\n";
                double ans=(T.query(1,1,N-1,a,b,x,y)-1)/10.0;
                if(ans<0)cout<<-1<<"\n";
                else cout<<ans<<"\n";
            }
        }
    }
}
int main(){
    cout<<fixed<<setprecision(1);
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

=== 线段树 套 动态开点线段树 (STreeDSTree)

#note[code 夹带私货]

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=5e4+5;
struct STreeDSTree{
    struct DSTree{
        int lc,rc,tag;
        LL sum;
    }tr[N*__lg(N)*20];// YES 一发入魂 !!!
    int m;
    int tot,rt[N*4];
    // 新建节点 全部清空
    int _new_node(){
        ++tot;
        memset(tr+tot,0,sizeof(tr[0]));
        return tot;
    }
    // 上传信息
    void _up(int i){
        tr[i].sum=tr[tr[i].lc].sum+tr[tr[i].rc].sum;
    }
    // 懒标记
    void _lazy_add(int i,int n,int v){
        tr[i].tag+=v;
        tr[i].sum+=n*v;// 这里不会爆 因为 要么 n*1 要么 n/2*n 没有爆 long long
    }
    // 下传标记
    void _down(int i,int ln,int rn){
        if(!tr[i].lc)tr[i].lc=_new_node();
        if(!tr[i].rc)tr[i].rc=_new_node();
        if(tr[i].tag){
            _lazy_add(tr[i].lc,ln,tr[i].tag);
            _lazy_add(tr[i].rc,rn,tr[i].tag);
            tr[i].tag=0;
        }
    }
    // 区间加 v
    void _add(int i,int l,int r,int jl,int jr,int v){
        if(jl<=l&&r<=jr){
            _lazy_add(i,r-l+1,v);
        }else {
            int mid=(l+r)/2;
            _down(i,mid-l+1,r-mid);
            if(jl<=mid)_add(tr[i].lc,l,mid,jl,jr,v);
            if(jr>mid)_add(tr[i].rc,mid+1,r,jl,jr,v);
            _up(i);
        }
    }
    // 区间查询 
    LL _query_sum(int i,int l,int r,int jl,int jr){
        if(jl<=l&&r<=jr){
            return tr[i].sum;
        }else {
            int mid=(l+r)/2;
            _down(i,mid-l+1,r-mid);
            LL res=0;
            if(jl<=mid)res+=_query_sum(tr[i].lc,l,mid,jl,jr);
            if(jr>mid)res+=_query_sum(tr[i].rc,mid+1,r,jl,jr);
            return res;
        }
    }
    // 初始化 内层 m 要有 
    void init(int n,int m){
        this->m=m;
        tot=0;
        build(1,1,n);
    }
    // 构建外层
    void build(int i,int l,int r){
        rt[i]=_new_node();// 首先先占个坑 数据都是 0
        if(l==r){
            
        }else {
            int mid=(l+r)/2;
            build(i*2,l,mid);
            build(i*2+1,mid+1,r);
        }
    }
    // kl kr 新增一个 p
    void add(int i,int l,int r,int p,int kl,int kr){
        _add(rt[i],1,m,kl,kr,1);// 掌管 该值域 的集合 p 位置同样也要加 1
        if(l==r){
            
        }else {
            int mid=(l+r)/2;
            if(p<=mid)add(i*2,l,mid,p,kl,kr);
            else add(i*2+1,mid+1,r,p,kl,kr);
        }
    }
    // kl kr 区间第 k 大
    int kth(int i,int l,int r,LL k,int kl,int kr){
        if(l==r)return l;// 必定被 >=1 接住
        LL rsum = _query_sum(rt[i*2+1],1,m,kl,kr);// 右侧个数
        int mid=(l+r)/2;
        if(k>rsum)return kth(i*2,l,mid,k-rsum,kl,kr);// 始终位于 >0 的位置
        else return kth(i*2+1,mid+1,r,k,kl,kr); 
    }
}T;
int n,m;
int a[N],cntA;
array<LL,4> q[N];
int getA(int v){return lower_bound(a+1,a+1+cntA,v)-a;}
void solve(){
    cin>>n>>m;
    cntA=0;
    for(int i=1;i<=m;i++){
        auto& [op,l,r,v]=q[i];
        cin>>op>>l>>r>>v;
        if(op==1)a[++cntA]=v;
    }
    sort(a+1,a+1+cntA);
    cntA = unique(a+1,a+1+cntA)-a-1;
    T.init(cntA,n);
    for(int i=1;i<=m;i++){
        auto [op,l,r,v]=q[i];
        if(op==1)T.add(1,1,cntA,getA(v),l,r);
        else cout<<a[T.kth(1,1,cntA,v,l,r)]<<"\n";
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
/*
N 个可重集 N 个操作 
1. 区间增加元素 c 
2. 区间查询 k 大值
    a. 如果是 值域 套 权值线段树 那么 
    1. 单点 套 区间加 (单点路径上 也要加 log^2) 
    2. 前缀区间 套 区间查询  (log 次 log 区间查询 以二分 log^2)
    可见 外部静态 内部动态开点
    b. 如果是 集合 套 权值线段树 那么
    1. 区间 套 单点加 (区间路径上 单点加 ? 但是外层懒更新代价太大 ???)
    2. 区间 套 前缀查询 (log 次 log 前缀查询 另外加 log 次二分以确定 log^3)
    
    基米说: 你的直觉极其敏锐！在树套树中，如果遇到“区间修改”，我们通常必须让“区间（位置）”作为内层树，这样就可以在内层无痛使用 Lazy Tag。
    1. 单点修改 + 区间查询：外层位置树 + 内层权值树（经典做法，可以用树状数组套主席树优化）。
    2. 区间修改 + 区间查询：外层权值树 + 内层位置树（必须这么做，避免外层打 Tag 的灾难）。

    关于 _down 中的 _new_node 时机 
    
    不是吧，你想想，内部开点线段树的所有操作，最终都是以懒标记结束的，如果查询或修改的时候，需要分裂，
    那么down 操作中的 !lc !rc 第一次是必然触发的，这是必然的操作，否则懒标记无处下放或者？？ 
    等等， 目前可能的优化只能是 将 !lc !rc 放在 if tag 内 然后允许进入 0 节点，返回的是空值。
    我没有改进就过了，可能是因为 每次查询保证了一定能查到有效值。
    
    结论: 放在 if(tag) 内更节省 但是注意需要加一些 !i 空节点处理

    【!?虽?!】 真正的 tr 大小怎么算????

    (N 次操作)*(外层 log N)*(内层 4 log N) = 5e4 * 16 * (4 * 16)
    但是由于节点复用 可以大约乘以个 1/3

    【!?强?!】 为什么内层开点线段树访问量为 4logN ?

    可以理解为 在寻找 jl jr 边界时 先分叉 变为 2分支
    左分支的右一定懒住 右分支的左一定懒住 所以 一层最多 4 次访问
*/
```

=== 线段树 套 平衡树 (STreeSGTree)

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=5e4+5;
const double ALPHA=0.7;
const int inf=INT_MAX;

struct STreeSGTree{
    inline static int collect[N],ci,*tp;// 容量为 N
    struct SGTree{
        int lc,rc,cnt,sz,diff;
        int key;
    }tr[N*__lg(N)*3];// 初始的 N + N 次 log N 插入 但是要开3倍才过这个 hyw???
    #define lc(i) tr[i].lc
    #define rc(i) tr[i].rc
    #define cnt(i) tr[i].cnt
    #define sz(i) tr[i].sz
    #define diff(i) tr[i].diff
    #define key(i) tr[i].key
    int tot;
    // 新建节点
    int _new_node(int k){
        ++tot;
        lc(tot)=rc(tot)=0;// 
        cnt(tot)=sz(tot)=diff(tot)=1;/// 
        key(tot)=k;
        return tot;
    }
    // 上传
    void _up(int i){
        sz(i)=cnt(i)+sz(lc(i))+sz(rc(i));
        diff(i)=(cnt(i)>0)+diff(lc(i))+diff(rc(i));// !!!
    }
    // 中序遍历
    void _inorder(int i){
        if(!i)return;
        _inorder(lc(i));
        if(cnt(i))collect[++ci]=i;// !!!
        _inorder(rc(i));
    }
    // 构建
    int _build(int l,int r){
        if(l>r)return 0;
        int mid=(l+r)/2;
        int i=collect[mid];
        lc(i)=_build(l,mid-1);
        rc(i)=_build(mid+1,r);
        _up(i);
        return i;
    }
    // 重构
    void _rebuild(){
        if(!tp)return;
        ci=0;
        _inorder(*tp);
        *tp=_build(1,ci);
    }
    // 不稳定 子树偏大
    bool _imbalance(int i){
        return max(diff(lc(i)),diff(rc(i)))>ALPHA*diff(i);
    }
    // root 插入 k
    void _insert(int& root,int k){
        tp=0;
        __insert(root,k);
        _rebuild();
    }
    // 内部插入
    void __insert(int& i,int k){
        if(!i)i=_new_node(k);
        else {
            if(k==key(i))cnt(i)++;
            else if(k<key(i))__insert(lc(i),k);
            else __insert(rc(i),k);
            _up(i);
            if(_imbalance(i))tp=&i;
        }
    }
    // root 删除 k
    void _erase(int& root,int k){
        tp=0;
        __erase(root,k);
        _rebuild();
    }
    // 内部删除 
    void __erase(int& i,int k){
        if(!i)return;// RE
        else {
            if(k==key(i))cnt(i)?cnt(i)--:0;
            else if(k<key(i))__erase(lc(i),k);
            else __erase(rc(i),k);
            _up(i);
            if(_imbalance(i))tp=&i;
        }
    }
    // 特殊需要
    int _small(int root,int k){
        int i=root,res=0;
        while(i){
            if(k<key(i))i=lc(i);
            else if(k>key(i))res+=sz(lc(i))+cnt(i),i=rc(i);
            else return res+sz(lc(i));
        }
        return res;
    }
    int _rank(int root,int k){return _small(root,k)+1;}
    int _at(int root,int x){
        if(x<1)return -inf;
        if(x>sz(root))return inf;
        int i=root;
        while(i){
            if(x<=sz(lc(i)))i=lc(i);
            else if(x>sz(lc(i))+cnt(i))x-=sz(lc(i))+cnt(i),i=rc(i);
            else return key(i);
        }
        assert(0&&"EMPTY");
    }
    int _prev(int root,int k){return _at(root,_rank(root,k)-1);}
    int _next(int root,int k){return _at(root,_rank(root,k+1));}
    
    // 正片开始
    int n;
    int rt[N*4];
    void init(int n){
        this->n=n;
        tot=0;
        build(1,1,n);
    }
    void build(int i,int l,int r){
        rt[i]=0;
        if(l==r){

        }else {
            int mid=(l+r)/2;
            build(i*2,l,mid);
            build(i*2+1,mid+1,r);
        }
    }
    void insert(int i,int l,int r,int p,int k){
        _insert(rt[i],k);
        if(l==r){

        }else {
            int mid=(l+r)/2;
            if(p<=mid)insert(i*2,l,mid,p,k);
            else insert(i*2+1,mid+1,r,p,k);
        }
    }
    void erase(int i,int l,int r,int p,int k){
        _erase(rt[i],k);
        if(l==r){

        }else {
            int mid=(l+r)/2;
            if(p<=mid)erase(i*2,l,mid,p,k);
            else erase(i*2+1,mid+1,r,p,k);
        }
    }
    // 因为多分支 所以 改成 small 吧
    int small(int i,int l,int r,int jl,int jr,int k){
        if(jl<=l&&r<=jr){
            return _small(rt[i],k);
        }else {
            int mid=(l+r)/2;
            int res=0;
            if(jl<=mid)res+=small(i*2,l,mid,jl,jr,k);
            if(jr>mid)res+=small(i*2+1,mid+1,r,jl,jr,k);
            return res;
        }
    }
    // log^3 恐怖
    int at(int i,int l,int r,int jl,int jr,int x){
        int L=0,R=1e8,M,ans=-1;
        while(L<=R){
            M=(L+R)/2;
            // 统计 <= M 的个数 如果冲到了 x 我要那个最小值 M 
            if(small(i,l,r,jl,jr,M+1)>=x)ans=M,R=M-1;
            else L=M+1;// <=M 的 有 <x 个
        }
        return ans;
    }
    int prev(int i,int l,int r,int jl,int jr,int k){
        if(jl<=l&&r<=jr){
            return _prev(rt[i],k);
        }else {
            int mid=(l+r)/2;
            int res=-inf;
            if(jl<=mid)res=max(res,prev(i*2,l,mid,jl,jr,k));
            if(jr>mid)res=max(res,prev(i*2+1,mid+1,r,jl,jr,k));
            return res;
        }
    }
    int next(int i,int l,int r,int jl,int jr,int k){
        if(jl<=l&&r<=jr){
            return _next(rt[i],k);
        }else {
            int mid=(l+r)/2;
            int res=inf;
            if(jl<=mid)res=min(res,next(i*2,l,mid,jl,jr,k));
            if(jr>mid)res=min(res,next(i*2+1,mid+1,r,jl,jr,k));
            return res;
        }
    }
    // 特殊的 单点 get 
    int get(int i,int l,int r,int p){
        if(l==r){
            assert(rt[i]);
            return key(rt[i]);// 不一定吧 啊对的对的 因为 只有一个元素 一定会保证 是根
            // return _at(rt[i],1);// 
        }else {
            int mid=(l+r)/2;
            if(p<=mid)return get(i*2,l,mid,p);
            else return get(i*2+1,mid+1,r,p);
        }
    }
}T;
int n,m,op,l,r,p,k;
void solve(){
    cin>>n>>m;
    T.init(n);
    for(int i=1;i<=n;i++)cin>>k,T.insert(1,1,n,i,k);
    while(m--){
        cin>>op;
        if(op==1){
            cin>>l>>r>>k;cout<<T.small(1,1,n,l,r,k)+1<<"\n";
        }else if(op==2){
            cin>>l>>r>>k;cout<<T.at(1,1,n,l,r,k)<<"\n";
        }else if(op==3){
            cin>>p>>k;T.erase(1,1,n,p,T.get(1,1,n,p));T.insert(1,1,n,p,k);
        }else if(op==4){
            cin>>l>>r>>k;cout<<T.prev(1,1,n,l,r,k)<<"\n";
        }else {
            cin>>l>>r>>k;cout<<T.next(1,1,n,l,r,k)<<"\n";
        }
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

=== 树状数组 套 动态开点线段树 (BITDSTree)

#note[题目同上]

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N=5e4+5;
const int inf=INT_MAX;
struct BITDSTree{
    inline static int a[N],b[N],ca,cb;
    int n,m;
    struct DSTree{
        int lc,rc;
        int sum;
    }tr[N*__lg(N)*__lg(N)*2];// N + N 次 log 外层 log 内层
    int tot;
    // 新建节点
    int _new_node(){
        ++tot;
        memset(tr+tot,0,sizeof(tr[0]));
        return tot;
    }
    // 更新
    void _up(int i){
        tr[i].sum=tr[tr[i].lc].sum+tr[tr[i].rc].sum;
    }
    // 单点增加
    void _add(int& i,int l,int r,int p,int v){
        if(!i)i=_new_node();
        if(l==r){
            tr[i].sum+=v;
        }else {
            int mid=(l+r)/2;
            if(p<=mid)_add(tr[i].lc,l,mid,p,v);
            else _add(tr[i].rc,mid+1,r,p,v);
            _up(i);
        }
    }
    // 批量前缀和
    int _pre_sum(int p){
        int l=1,r=m,mid,ta,tb;
        int res=0;
        while(l<r){/// <= 改成 < !!! 死循环 !!!
            mid=(l+r)/2;
            ta=tb=0;
            if(mid<=p){
                l=mid+1;
                for(int i=1;i<=ca;i++)if(a[i]){
                    res+=tr[tr[a[i]].lc].sum;
                    a[++ta]=tr[a[i]].rc;
                }
                for(int i=1;i<=cb;i++)if(b[i]){
                    res-=tr[tr[b[i]].lc].sum;
                    b[++tb]=tr[b[i]].rc;
                }
            }else {
                r=mid;
                for(int i=1;i<=ca;i++)if(a[i])a[++ta]=tr[a[i]].lc;
                for(int i=1;i<=cb;i++)if(b[i])b[++tb]=tr[b[i]].lc;
            }
            ca=ta;cb=tb;
        }
        // 修改 2：补充处理叶子节点
        if (l <= p) {
            for(int i=1;i<=ca;i++) if(a[i]) res += tr[a[i]].sum;
            for(int i=1;i<=cb;i++) if(b[i]) res -= tr[b[i]].sum;
        }
        return res;
    }
    // 批量前缀卡壳
    int _at(int x){
        int l=1,r=m,mid,ta,tb;
        int lsum;
        while(l<r){
            mid=(l+r)/2;
            lsum=0;
            ta=tb=0;
            for(int i=1;i<=ca;i++)if(a[i])lsum+=tr[tr[a[i]].lc].sum;
            for(int i=1;i<=cb;i++)if(b[i])lsum-=tr[tr[b[i]].lc].sum;
            if(x<=lsum){
                r=mid;
                for(int i=1;i<=ca;i++)if(a[i])a[++ta]=tr[a[i]].lc;
                for(int i=1;i<=cb;i++)if(b[i])b[++tb]=tr[b[i]].lc;
            }else {
                x-=lsum;
                l=mid+1;
                for(int i=1;i<=ca;i++)if(a[i])a[++ta]=tr[a[i]].rc;
                for(int i=1;i<=cb;i++)if(b[i])b[++tb]=tr[b[i]].rc;
            }
            ca=ta;cb=tb;
        }
        return l;
    }

    // 正片开始
    int rt[N];
    int arr[N];
    // 初始化 内外围
    void init(int n,int m){
        this->n=n;this->m=m;
        tot=0;
        fill(rt,rt+1+n,0);
    }
    // p 位置设置 k
    void insert(int p,int k){
        arr[p]=k;
        for(int i=p;i<=n;i+=i&-i)_add(rt[i],1,m,k,1);
    }
    // 删除 p 位置
    void erase(int p){
        for(int i=p;i<=n;i+=i&-i)_add(rt[i],1,m,arr[p],-1);// -1 
        arr[p]=0;
    }
    // p 位置改为 k
    void modify(int p,int k){erase(p);insert(p,k);}
    // [l,r] 内 <k 的个数
    int small(int l,int r,int k){
        ca=cb=0;
        for(int i=r;i;i-=i&-i)a[++ca]=rt[i];// !!!
        for(int i=l-1;i;i-=i&-i)b[++cb]=rt[i];// !!!
        return _pre_sum(k-1);
    }
    // [l,r] 内第 x 位数
    int at(int l,int r,int x){
        ca=cb=0;
        for(int i=r;i;i-=i&-i)a[++ca]=rt[i];// !!!
        for(int i=l-1;i;i-=i&-i)b[++cb]=rt[i];// !!!
        return _at(x);    
    }
    // [l,r] 内 k 的前驱
    int prev(int l,int r,int k){
        int sml=small(l,r,k);
        if(sml==0)return 0;
        return at(l,r,sml);
    }
    // [l,r] 内 k 的后继
    int next(int l,int r,int k){
        int le=small(l,r,k+1);
        int sz=small(l,r,m+1);
        if(le==sz)return m+1;
        return at(l,r,le+1);
    }
}T;
int n,m,p,k,l,r;
int a[N];
int A[N*2],cntA;
int getA(int v){return lower_bound(A+1,A+1+cntA,v)-A;}
array<int,4> q[N];
void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>a[i],A[++cntA]=a[i];
    for(int i=1;i<=m;i++){
        auto&[op,l,r,k]=q[i];
        cin>>op;
        if(op!=3)cin>>l>>r>>k;
        else cin>>l>>k;
        if(op!=2)A[++cntA]=k;
    }
    sort(A+1,A+1+cntA);
    cntA=unique(A+1,A+1+cntA)-A-1;
    A[0]=-inf;A[cntA+1]=inf;
    T.init(n,cntA);
    for(int i=1;i<=n;i++)T.insert(i,getA(a[i]));
    for(int i=1;i<=m;i++){
        auto[op,l,r,k]=q[i];
        if(op==1){
            cout<<T.small(l,r,getA(k))+1<<"\n";
        }else if(op==2){
            cout<<A[T.at(l,r,k)]<<"\n";
        }else if(op==3){
            T.modify(l,getA(k));
        }else if(op==4){
            cout<<A[T.prev(l,r,getA(k))]<<"\n";
        }else {
            cout<<A[T.next(l,r,getA(k))]<<"\n";
        }
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

#note[
    其实还有一道题是 树上 带修改 查询路径点权第 k 大
    
    显然需要 dfn序 lca 路径处理 

    - 如果没有修改 那么 *主席树* 是可以 *双版本阵营* 查询的

    - 但是有了修改 那么需要 改变 *节点存储逻辑* 
        - 确定任意一个为根
        + 一个节点的出现 只在它的子树中 dfn 序连续 
        + 那么 就可以 在 树状数组上 逆序差分 l++ (r+1)--
        + 这就是 
            + 区间集合 insert / modify 
            + *双"版本"阵营* query small / at 
        + 树状数组 套 动态开点(权值)线段树 即可!!!
]

== K-D Tree

#note[
    K-D Tree 原来是 $K$ 维循环平衡的树 
]

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=2e5+5;
const int K=2;
namespace KDT{
    int collect[N],ci;
    array<int,K> a,b;// a 为较小者 b 为较大者
    struct Node{
        int lc,rc;// 左右孩子
        array<int,K> p,L,R;// 当前点的坐标 最小坐标集 最大坐标集
        int v;// 值
        LL sum;// 子树值的和
    }tr[N];
    int tot,rt[__lg(N)+2];
    // 新建节点
    int new_node(array<int,K> p,int v){
        int i=++tot;
        tr[i].lc=tr[i].rc=0;
        tr[i].p=tr[i].L=tr[i].R=p;// 
        tr[i].v=tr[i].sum=v;// 
        return i;
    }
    // 上传信息
    void up(int i){
        tr[i].sum=tr[i].v+tr[tr[i].lc].sum+tr[tr[i].rc].sum;
        tr[i].L=tr[i].R=tr[i].p;// 初始化 p -> L R 
        for(int k=0;k<K;k++){
            if(tr[i].lc){// 左 Lmin Rmax
                tr[i].L[k]=min(tr[i].L[k],tr[tr[i].lc].L[k]);
                tr[i].R[k]=max(tr[i].R[k],tr[tr[i].lc].R[k]);
            }
            if(tr[i].rc){// 右 Lmin Rmax
                tr[i].L[k]=min(tr[i].L[k],tr[tr[i].rc].L[k]);
                tr[i].R[k]=max(tr[i].R[k],tr[tr[i].rc].R[k]);
            }
        }
    }
    // 收集节点 任意顺序皆可 因为有 nth_element
    void inorder(int i){
        if(!i)return;
        inorder(tr[i].lc);
        collect[++ci]=i;
        inorder(tr[i].rc);
        // i=0;// 更加方便 不用考虑悬空了 
    }
    // 构建/重构
    void build(int& i,int l,int r,int k=0){
        if(l>r)return void(i=0);// 空 更加显式
        int mid=(l+r)/2;// mid 
        nth_element(collect+l,collect+mid,collect+r+1,[k](int a,int b){
            return tr[a].p[k]<tr[b].p[k];
        });
        i=collect[mid];// [] 必须设置
        k=(k+1)%K;// 下一层
        build(tr[i].lc,l,mid-1,k);// [] 啊啊啊 这里 挖掉 mid
        build(tr[i].rc,mid+1,r,k);
        up(i);// 上传
    }
    // 查询一个子树的和 (已有全局ab构成的超长方体) 
    LL query_sum(int i){
        if(!i)return 0;
        bool f=0;
        for(int k=0;k<K;k++)f|=a[k]>tr[i].L[k]||b[k]<tr[i].R[k];// LR 查看是否存在冗余越界
        if(!f)return tr[i].sum;// 没有冗余 直接懒住
        for(int k=0;k<K;k++)if(a[k]>tr[i].R[k]||b[k]<tr[i].L[k])return 0;// 有一个全额越界
        LL ans=0;// 注意 此时 f=true
        for(int k=0;k<K;k++)f&=tr[i].p[k]>=a[k]&&tr[i].p[k]<=b[k];// x 查看是否都在界内
        if(f)ans=tr[i].v;// yes
        return ans+query_sum(tr[i].lc)+query_sum(tr[i].rc);// 递归
    }
    // 插入一个 p 点 v 值
    void insert(array<int,K> p,int v){
        collect[++ci]=new_node(p,v);// 等待构建
        for(int i=0;i<__lg(N)+2;i++){
            if(!rt[i]){// 终于找到了第一个 0
                build(rt[i],1,ci);
                ci=0;
                break;// [] 必须跳出
            }else {// 收集一路上的所有 1 
                inorder(rt[i]);
                rt[i]=0;
            }
        }
    }
    // 对于每个二进制子树都查询累加
    LL query(array<int,K> aa,array<int,K> bb){
        a=aa;b=bb;// kb
        LL res=0;
        for(int i=0;i<__lg(N)+2;i++)res+=query_sum(rt[i]);
        return res;
    }
}
void solve(){
    int n,op,x1,y1,x2,y2,a,lst=0;// 这里的的 y1 !!!!
    cin>>n;
    while(cin>>op,op!=3){
        if(op==1){
            cin>>x1>>y1>>a;x1^=lst;y1^=lst;a^=lst;
            KDT::insert({x1,y1},a);
        }else {
            cin>>x1>>y1>>x2>>y2;x1^=lst;y1^=lst;x2^=lst;y2^=lst;
            cout<<(lst=KDT::query({x1,y1},{x2,y2}))<<"\n";
        }
    }

}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

== 动态树

#note[
    TO DO !!! 动态树
]

== 析合树 / PQ树  

#note[
    TO DO ? 析合树 / PQ树
]   

== 手指树 / 霍夫曼树

#note[略]