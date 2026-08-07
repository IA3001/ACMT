#include<bits/stdc++.h>
using namespace std;
using LL = long long;
// [TLE] 眼瞎sizeof(hd[0]*(n+1))
// 从此不再 memset(), fill() 启动 !!!!
const int N=1205,M=2e5+5;
const int inf = 0x3f3f3f3f;// 只需要索引级别的 inf !!!
const LL INF = 1e16;

// HLPP 天然不需要 LL 级别的 INF 
// 但是 依赖 inf 方便求 h 
namespace HLPP{
    struct Edge{
        int to,nxt;
        LL w;
    }e[M*2];
    int hd[N],cntE;
    int n,s,t;
    int h[N],gap[N];// gap[] 还是 1 倍
    LL flow[N];
    bool inq[N];
    priority_queue<pair<int,int>> Q;// 这个其实常数更小 !!!!
    void init(int nn){
        n=nn;
        fill(hd,hd+1+n,0);
        cntE=1;
    }
    inline void add_edge(int u,int v,LL w){
        e[++cntE]={v,hd[u],w};hd[u]=cntE;
        e[++cntE]={u,hd[v],0};hd[v]=cntE;
    }
    bool bfs(){
        fill(h,h+1+n,inf);
        queue<int> q;
        q.push(t);h[t]=0;// [RE] 不套娃了
        while(q.size()){
            int u=q.front();q.pop();
            for(int i=hd[u],v;i;i=e[i].nxt){
                v=e[i].to;
                if(e[i^1].w&&h[v]>h[u]+1)
                    q.push(v),h[v]=h[u]+1;// [RE] 不套娃了
            }
        }
        return h[s]!=inf;
    }
    bool push(int u){
        LL tk;
        for(int i=hd[u],v;i&&flow[u];i=e[i].nxt){
            v=e[i].to;
            if(h[v]!=h[u]-1||!e[i].w)continue;
            tk=min(flow[u],e[i].w);
            flow[u]-=tk;
            flow[v]+=tk;
            e[i].w-=tk;
            e[i^1].w+=tk;
            if(!inq[v]&&v!=s&&v!=t)
                Q.push({h[v],v}),inq[v]=1;
        }
        return flow[u];
    }
    void relabel(int u){
        h[u]=inf;// inf !!!! 
        for(int i=hd[u],v;i;i=e[i].nxt)
            if(e[i].w)
                h[u]=min(h[u],h[e[i].to]);
        if(++h[u]<n){
            gap[h[u]]++;
            Q.push({h[u],u});inq[u]=1;
        }
    }
    LL calc(int ss,int tt){
        s=ss;t=tt;
        if(!bfs())return 0;
        h[s]=n;
        // [RE] 不套娃了 老老实实 判断 inf 求 gap
        for(int i=1;i<=n;i++)if(h[i]!=inf)gap[h[i]]++;
        fill(flow,flow+1+n,0);
        for(int i=hd[s],v;i;i=e[i].nxt){
            v=e[i].to;
            flow[v]+=e[i].w;
            e[i^1].w=e[i].w;
            e[i].w=0;
            // [RE] 初始的堆 没写 h[v]!=inf 一出来就炸了!!!!!!
            if(!inq[v]&&v!=s&&v!=t&&h[v]!=inf)
                Q.push({h[v],v}),inq[v]=1;
        }
        while(Q.size()){
            int u=Q.top().second;Q.pop();inq[u]=0;
            if(push(u)){// 推送如果还有余量
                if(!--gap[h[u]])// 如果 gap 终结
                    for(int i=1;i<=n;i++)// 将 (h,n] 的直接终结
                        if(h[i]>h[u]&&h[i]<n+1&&i!=s&&i!=t)
                            gap[h[i]]--,h[i]=n+1;
                relabel(u);// 重新标号 
            }
        }
        return flow[t];
    }
}
int n,m,s,t,u,v,e,cnte,S,T;LL w,a,b,l[M*2],F[N];
void solve_demo(){
    cin>>n>>m>>s>>t;
    HLPP::init(n);
    while(m--)cin>>u>>v>>w,HLPP::add_edge(u,v,w);
    cout<<HLPP::calc(s,t)<<"\n";
}
void solve_pilot(){
    cin>>m>>n;S=n+1;T=n+2;
    HLPP::init(n+2);
    for(int i=1;i<=m;i++)HLPP::add_edge(n+1,i,1);
    for(int i=m+1;i<=n;i++)HLPP::add_edge(i,n+2,1);
    while(cin>>u>>v,(u!=-1&&v!=-1))HLPP::add_edge(u,v,1);
    cout<<HLPP::calc(S,T)<<"\n";
    for(int u=1;u<=m;u++)
        for(int i=HLPP::hd[u];i;i=HLPP::e[i].nxt)
            if(HLPP::e[i^1].w&&HLPP::e[i].to<=n)cout<<u<<" "<<HLPP::e[i].to<<"\n";
}
void solve_bigraph_match(){
    cin>>n>>m>>e;S=n+m+1;T=n+m+2;
    HLPP::init(n+m+2);
    for(int i=1;i<=n;i++)HLPP::add_edge(n+m+1,i,1);
    for(int i=1;i<=m;i++)HLPP::add_edge(i+n,n+m+2,1);
    while(e--)cin>>u>>v,HLPP::add_edge(u,v+n,1);
    cout<<HLPP::calc(S,T)<<"\n";
}
void solve_no_ST_any(){
    cin>>n>>m;
    S=n+1;T=n+2;HLPP::init(n+2);cnte=1;
    for(int i=1;i<=m;i++){
        cin>>u>>v>>a>>b;
        HLPP::add_edge(u,v,b-a);
        l[++cnte]=a,++cnte;
        F[u]-=a;F[v]+=a;
    }
    LL tot=0;
    for(int i=1;i<=n;i++)
        if(F[i]>0)HLPP::add_edge(S,i,F[i]),tot+=F[i];
        else if(F[i]<0)HLPP::add_edge(i,T,-F[i]);
    if(tot!=HLPP::calc(S,T)){
        cout<<"No\n";
    }else {
        cout<<"Yes\n";
        for(int i=2;i<=1+m*2;i+=2)
            cout<<(l[i]+HLPP::e[i^1].w)<<"\n";// [异或1] 才是使用量
    }
}
void solve_ST_m(bool is_max){
    cin>>n>>m>>s>>t;
    S=n+1;T=n+2;HLPP::init(n+2);cnte=1;
    for(int i=1;i<=m;i++){
        cin>>u>>v>>a>>b;
        HLPP::add_edge(u,v,b-a);
        l[++cnte]=a,++cnte;
        F[u]-=a;F[v]+=a;
    }
    HLPP::add_edge(t,s,INF);// [] 保持和 cnte 同频 
    LL tot=0;
    for(int i=1;i<=n;i++)
    if(F[i]>0)HLPP::add_edge(S,i,F[i]),tot+=F[i];
    else if(F[i]<0)HLPP::add_edge(i,T,-F[i]);
    if(tot!=HLPP::calc(S,T)){
        cout<<"N\n";
    }else {
        LL ans=HLPP::e[cnte+2].w;// 已经使用的流量
        HLPP::e[cnte+1].w=HLPP::e[cnte+2].w=0;// 断边
        if(is_max)ans+=HLPP::calc(s,t);// 我觉得残余 反悔边权 存在 计算的仍然是 s->t 最大增量 
        else ans-=HLPP::calc(t,s);// 显然 使用边权流守恒 可以证明 要不然这里怎么退流
        cout<<ans<<"\n";
    }
}
void solve_min_points_cover(){// 五字OJ 
    // HLPP 算法得到的残余网络 gap优化 缺少退流 不正确
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