#include<bits/stdc++.h>
using LL = long long;
using namespace std;
const int N=5e3+5,M=5e4+5;
const LL INF = 1e10;
namespace PD{
    struct Edge{
        int to,nxt;
        LL w,c;
    }e[M*2];
    int hd[N],cntE;
    int n,s,t;
    LL d[N],h[N];
    bool vis[N];
    int p[N];// 记录路径上的边
    LL ans,cost;
    void init(int nn){
        n=nn;
        fill(hd,hd+1+n,0);
        cntE=1;
    }
    inline void add_edge(int u,int v,LL w,LL c){
        e[++cntE]={v,hd[u],w,c};hd[u]=cntE;
        e[++cntE]={u,hd[v],0,-c};hd[v]=cntE;
    }
    void spfa(){
        queue<int> q;
        fill(h,h+1+n,INF);
        q.push(s);h[s]=0;
        while(q.size()){
            int u=q.front();q.pop();
            vis[u]=0;
            for(int i=hd[u],v;i;i=e[i].nxt){
                v=e[i].to;
                if(e[i].w&&h[v]>h[u]+e[i].c){
                    h[v]=h[u]+e[i].c;
                    if(!vis[v])q.push(v),vis[v]=1;
                }
            }
        }
    }
    bool dijk(){
        priority_queue<pair<LL,int>>Q;// first(dist) 取负 小根堆 
        fill(d,d+1+n,INF);
        fill(vis,vis+1+n,false);
        Q.push({-0,s});
        d[s]=0;
        while(Q.size()){
            int u=Q.top().second;Q.pop();
            if(vis[u])continue;
            vis[u]=1;
            LL nc;
            for(int i=hd[u],v;i;i=e[i].nxt){
                v=e[i].to;nc=e[i].c+h[u]-h[v];
                if(e[i].w&&d[v]>d[u]+nc){
                    d[v]=d[u]+nc;
                    p[v]=i;
                    if(!vis[v])Q.push({-d[v],v});
                }
            }
        }
        return d[t]!=INF;
    }
    pair<LL,LL> calc(int ss,int tt){
        s=ss;t=tt;
        ans=cost=0;
        spfa();
        while(dijk()){
            LL tk=INF;
            for(int i=1;i<=n;i++)h[i]+=d[i];
            for(int i=t;i!=s;i=e[p[i]^1].to)
                tk=min(tk,e[p[i]].w);
            for(int i=t;i!=s;i=e[p[i]^1].to)
                e[p[i]].w-=tk,e[p[i]^1].w+=tk;
            ans+=tk;
            cost+=tk*h[t];
        }
        return {ans,cost};
    }
}
int n,m,s,t,u,v;LL w,c;
void solve_CF(){
    cin>>n>>m>>s>>t;
    PD::init(n);
    while(m--)cin>>u>>v>>w>>c,PD::add_edge(u,v,w,c);
    auto [ans,cost] = PD::calc(s,t);
    cout<<ans<<" "<<cost<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve_CF();
}