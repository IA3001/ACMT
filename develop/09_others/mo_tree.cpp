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
    l++;// 注意 dfn 序的求 lca 从 l+1 !!!!!!!!!!!!!!!!!!!!!!!
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

