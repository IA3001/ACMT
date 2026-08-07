#include<bits/stdc++.h>
using namespace std;
const int N=2e5+5;
namespace DT{
    int n;
    vector<int> e[N],re[N],buf[N];
    int dfn[N],rnk[N],dfncnt,fa[N],mn[N],sdom[N],idom[N],f[N];
    int sz[N];
    void init(int nn){
        n=nn;
        dfncnt=0;
    }
    void dfs1(int u){
        rnk[dfn[u]=++dfncnt]=u;
        for(auto v:e[u])if(!dfn[v]){
            fa[v]=u;
            dfs1(v);
        }
    }
    int fd(int x){// 简单并查集 
        if(f[x]==x)return x;
        int fx=fd(f[x]);
        if(dfn[sdom[mn[f[x]]]]<dfn[sdom[mn[x]]])
        mn[x]=mn[f[x]];
        return f[x]=fx;
    }
    void LT(int S){
        dfs1(S);
        // 事后 clear 
        for(int i=1;i<=n;i++){
            f[i]=sdom[i]=mn[i]=i;
            e[i].clear();
        }
        for(int u,i=dfncnt;i>=2;i--){// dfncnt!!! !!! !!!
            u=rnk[i];
            for(auto v:re[u])if(dfn[v]){
                fd(v);
                if(dfn[sdom[mn[v]]]<dfn[sdom[u]])
                sdom[u]=sdom[mn[v]];
            }
            f[u]=fa[u];
            buf[sdom[u]].push_back(u);
            u=rnk[i-1];
            for(auto v:buf[u]){
                fd(v);
                if(sdom[mn[v]]==sdom[v])
                idom[v]=sdom[v];
                else idom[v]=mn[v];
            }
        }
        for(int u,i=2;i<=dfncnt;i++){// dfncnt!!! ??? !!!
            u=rnk[i];
            if(idom[u]!=sdom[u])
            idom[u]=idom[idom[u]];
            e[idom[u]].push_back(u);
        }
    }
    void dfs2(int u){
        sz[u]=1;
        for(auto v:e[u]){
            dfs2(v);
            sz[u]+=sz[v];
        }
    }
}using DT::e,DT::re;
void solve(){
    int n,m;cin>>n>>m;
    DT::init(n);
    for(int u,v,i=1;i<=m;i++){
        cin>>u>>v;
        e[u].push_back(v);
        re[v].push_back(u);
    }
    DT::LT(1);DT::dfs2(1);
    for(int i=1;i<=n;i++)cout<<DT::sz[i]<<" ";cout<<"\n";
}
void solve_CF757E(){
    int n,m,S;cin>>n>>m>>S;
    DT::init(n);
    vector<vector<pair<int,int>>> E(n+1);
    for(int u,v,w,i=1;i<=m;i++){
        cin>>u>>v>>w;
        E[u].push_back({v,w});
        E[v].push_back({u,w});
    }
    priority_queue<pair<long long,int>> Q;
    vector<long long> dis(n+1,1e18);
    dis[S]=0;
    Q.push({-0,S});
    while(Q.size()){
        int u=Q.top().second;Q.pop();
        for(auto [v,w]:E[u])
            if(dis[v]>dis[u]+w){
                dis[v]=dis[u]+w;
                Q.push({-dis[v],v});
            }
    }
    for(int u=1;u<=n;u++){
        for(auto [v,w]:E[u]){
            if(dis[v]==dis[u]+w){
                e[u].push_back(v);
                re[v].push_back(u);
            }
        }
    }
    DT::LT(S);DT::dfs2(S);
    int ans=0;
    for(auto v:e[S])ans=max(ans,DT::sz[v]);cout<<ans<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
    // solve_CF757E();
}