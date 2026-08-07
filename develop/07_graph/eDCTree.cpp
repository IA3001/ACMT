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