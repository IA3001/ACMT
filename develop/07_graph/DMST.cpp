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
