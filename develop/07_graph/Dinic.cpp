#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N = 1205,M=2e5+5;// [SB] 二分图的 N 两倍在这里改 
const LL INF = 1e16;// 其实不必要一次性塞满 
namespace Dinic{
    struct Edge{
        int to,nxt;
        LL w;
    }e[M*2+N*2];
    int hd[N],cur[N],cntE;
    int n,s,t;
    int d[N];
    void init(int nn){
        n=nn;
        fill(hd,hd+1+n,0);
        cntE=1;
    }
    inline void add_edge(int u,int v,LL w){
        e[++cntE]={v,hd[u],w};hd[u]=cntE;
        e[++cntE]={u,hd[v],0};hd[v]=cntE;
    }
    inline bool bfs(){
        fill(d,d+1+n,-1);
        queue<int> Q;
        Q.push(s);d[s]=0;cur[s]=hd[s];// 素质三连
        while(Q.size()){
            int u=Q.front();Q.pop();
            if(u==t)return true;
            for(int i=hd[u],v;i;i=e[i].nxt){
                v=e[i].to;
                if(!e[i].w||~d[v])continue;// 跳过反向边
                Q.push(v);d[v]=d[u]+1;cur[v]=hd[v];// 素质三连
            }
        }
        return false;
    }
    LL dfs(int u=s,LL sum=INF){
        if(u==t)return sum;
        LL res=0,tk;
        for(int i=cur[u],v;i&&sum;i=e[i].nxt){// sum 剪枝
            cur[u]=i;// 当前弧优化
            v=e[i].to;
            if(d[v]!=d[u]+1||!e[i].w)continue;// 死路剪枝1
            tk=dfs(v,min(sum,e[i].w));
            if(tk){
                sum-=tk;
                res+=tk;
                e[i].w-=tk;
                e[i^1].w+=tk;
            }else d[v]=-1;// 死路剪枝2
        }
        return res;
    }
    LL calc(int ss,int tt){
        s=ss;t=tt;
        LL ans=0;
        while(bfs())ans+=dfs();
        return ans;
    }
}
int n,m,s,t,u,v,e,cnte,S,T;LL w,a,b,l[M*2],F[N];
void solve_demo(){
    cin>>n>>m>>s>>t;
    Dinic::init(n);
    while(m--)cin>>u>>v>>w,Dinic::add_edge(u,v,w);
    cout<<Dinic::calc(s,t)<<"\n";
}
void solve_pilot(){
    cin>>m>>n;S=n+1;T=n+2;
    Dinic::init(n+2);
    for(int i=1;i<=m;i++)Dinic::add_edge(n+1,i,1);
    for(int i=m+1;i<=n;i++)Dinic::add_edge(i,n+2,1);
    while(cin>>u>>v,(u!=-1&&v!=-1))Dinic::add_edge(u,v,1);
    cout<<Dinic::calc(S,T)<<"\n";
    for(int u=1;u<=m;u++)
        for(int i=Dinic::hd[u];i;i=Dinic::e[i].nxt)
            if(Dinic::e[i^1].w&&Dinic::e[i].to<=n)cout<<u<<" "<<Dinic::e[i].to<<"\n";
}
void solve_bigraph_match(){
    cin>>n>>m>>e;S=n+m+1;T=n+m+2;
    Dinic::init(n+m+2);
    for(int i=1;i<=n;i++)Dinic::add_edge(n+m+1,i,1);
    for(int i=1;i<=m;i++)Dinic::add_edge(i+n,n+m+2,1);
    while(e--)cin>>u>>v,Dinic::add_edge(u,v+n,1);
    cout<<Dinic::calc(S,T)<<"\n";
}
void solve_no_ST_any(){
    cin>>n>>m;
    S=n+1;T=n+2;Dinic::init(n+2);cnte=1;
    for(int i=1;i<=m;i++){
        cin>>u>>v>>a>>b;
        Dinic::add_edge(u,v,b-a);
        l[++cnte]=a,++cnte;
        F[u]-=a;F[v]+=a;
    }
    LL tot=0;
    for(int i=1;i<=n;i++)
        if(F[i]>0)Dinic::add_edge(S,i,F[i]),tot+=F[i];
        else if(F[i]<0)Dinic::add_edge(i,T,-F[i]);
    if(tot!=Dinic::calc(S,T)){
        cout<<"No\n";
    }else {
        cout<<"Yes\n";
        for(int i=2;i<=1+m*2;i+=2)
            cout<<(l[i]+Dinic::e[i^1].w)<<"\n";// [异或1] 才是使用量
    }
}
void solve_ST_m(bool is_max){
    cin>>n>>m>>s>>t;
    S=n+1;T=n+2;Dinic::init(n+2);cnte=1;
    for(int i=1;i<=m;i++){
        cin>>u>>v>>a>>b;
        Dinic::add_edge(u,v,b-a);
        l[++cnte]=a,++cnte;
        F[u]-=a;F[v]+=a;
    }
    Dinic::add_edge(t,s,INF);// [] 保持和 cnte 同频 
    LL tot=0;
    for(int i=1;i<=n;i++)
    if(F[i]>0)Dinic::add_edge(S,i,F[i]),tot+=F[i];
    else if(F[i]<0)Dinic::add_edge(i,T,-F[i]);
    if(tot!=Dinic::calc(S,T)){
        cout<<"N\n";
    }else {
        LL ans=Dinic::e[cnte+2].w;// 已经使用的流量
        Dinic::e[cnte+1].w=Dinic::e[cnte+2].w=0;// 断边
        if(is_max)ans+=Dinic::calc(s,t);// 我觉得残余 反悔边权 存在 计算的仍然是 s->t 最大增量 
        else ans-=Dinic::calc(t,s);// 显然 使用边权流守恒 可以证明 要不然这里怎么退流
        cout<<ans<<"\n";
    }
}
void solve_min_points_cover(){// 五字OJ 
    int n,m,k;
    while(cin>>n,n){
        cin>>m>>k;
        // A n 种 B m 种 k 个任务 
        int S=n+m+1,T=n+m+2;
        vector<bool> vis(n+m+3),use(n+m+3);
        Dinic::init(n+m+2);
        for(int i=1,id,a,b;i<=k;i++){
            cin>>id>>a>>b;
            if(a&&b)Dinic::add_edge(a+1,n+b+1,1),use[a+1]=use[n+b+1]=true;
        }
        for(int i=1;i<=n;i++)if(use[i])Dinic::add_edge(S,i,1);
        for(int i=n+1;i<=n+m;i++)if(use[i])Dinic::add_edge(i,T,1);
        int cnt=Dinic::calc(S,T),cnt2=0;
        // 具体方案:
        using Dinic::e,Dinic::hd;
        auto color=[&](auto&& self,int u)->void{
            vis[u]=true;
            for(int i=hd[u],v;i;i=e[i].nxt){
                v=e[i].to;
                if(!vis[v]&&e[i].w)self(self,v);
            }
        };
        color(color,S);
        for(int i=1;i<=n;i++)if(use[i]&&!vis[i])cnt2++;
        for(int i=n+1;i<=n+m;i++)if(use[i]&&vis[i])cnt2++;
        cout<<cnt<<" "<<cnt2<<"\n";
        // assert(cnt==cnt2);
        cout<<cnt<<"\n";
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    // solve_demo();
    // solve_pilot();
    // solve_bigraph_match();
    // solve_no_ST_any();
    // solve_ST_m(true);
    // solve_ST_m(false);
    solve_min_points_cover();
}