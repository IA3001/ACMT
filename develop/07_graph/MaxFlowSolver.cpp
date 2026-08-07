#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=1205,M=2e5+5;// [SB] 二分图的 N 两倍在这里改 
const LL INF =1e16;
const int inf = 0x3f3f3f3f;// 只需要索引级别的 inf !!!
// HLPP 天然不需要 LL 级别的 INF 
// 但是 依赖 inf 方便求 h 

namespace Dinic{
    struct Edge{
        int to,nxt;
        LL w;
    }e[M*2+N*2];
    int hd[N],cur[N],cntE;
    int n,s,t;
    int d[N];
    void init(int nn,int ss,int tt){
        n=nn;s=ss;t=tt;
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
    LL calc(){
        LL ans=0;
        while(bfs())ans+=dfs();
        return ans;
    }
}

namespace ISAP{
    struct Edge{
        int to,nxt;
        LL w;
    }e[M*2+N*2];// 二分图最大匹配 + N*2
    int hd[N],cur[N],cntE;
    int n,s,t;
    int d[N],gap[N];// [新]gap
    void init(int nn,int ss,int tt){
        n=nn;s=ss;t=tt;
        fill(hd,hd+1+n,0);
        cntE=1;
    }
    inline void add_edge(int u,int v,LL w){
        e[++cntE]={v,hd[u],w};hd[u]=cntE;
        e[++cntE]={u,hd[v],0};hd[v]=cntE;
    }
    void bfs(){
        fill(d,d+1+n,-1);
        fill(gap,gap+1+n,0);// [新]
        queue<int> Q;
        Q.push(t);gap[d[t]=0]=1;// [!]t [+]gap [-]cur
        while(Q.size()){
            int u=Q.front();Q.pop();
            for(int i=hd[u],v;i;i=e[i].nxt){
                v=e[i].to;
                if(e[i].w||~d[v])continue;// [!]跳过正向边
                Q.push(v);gap[d[v]=d[u]+1]++;// [+]gap [-]cur
            }
        }
    }
    LL dfs(int u=s,LL sum=INF){
        if(u==t)return sum;
        LL res=0,tk;
        for(int i=cur[u],v;i;i=e[i].nxt){// [-]sum
            cur[u]=i;
            v=e[i].to;
            if(d[v]+1!=d[u]||!e[i].w)continue;// [!] v+1=u
            tk=dfs(v,min(sum,e[i].w));
            if(!tk)continue;// [+] continue [-] d[v]=-1
            e[i].w-=tk;
            e[i^1].w+=tk;
            sum-=tk;
            res+=tk;
            if(!sum)return res;// [+] return
        }
        if(!--gap[d[u]])d[s]=n;// [+] 断层 
        gap[++d[u]]++;// [+] 抬高
        return res;// [+] 
    }
    LL calc(){
        LL ans=0;
        bfs();
        while(d[s]<n){// [!] d[s]<n
            memcpy(cur,hd,sizeof(hd[0])*(n+1));// [+] 当前弧
            ans+=dfs();
        }
        return ans;
    }
}

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
    // struct cmp{bool operator()(int a,int b)const{return h[a]<h[b];}};
    // priority_queue<int,vector<int>,cmp> Q;// 虽然这个更在线
    priority_queue<pair<int,int>> Q;// 这个其实常数更小 !!!!
    void init(int nn,int ss,int tt){
        n=nn;s=ss;t=tt;
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
    LL calc(){
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

namespace PlaceHolder{
    struct Edge{int to,nxt;LL w;}e[0];
    int hd[0],cntE;
    void init(int nn,int ss,int tt){}
    void add_edge(int u,int v,LL w){}
    LL calc(){return 0;}
}

#define Solver Dinic

int n,m,s,t,u,v,e;LL w;
void solve_demo(){
    cin>>n>>m>>s>>t;
    Solver::init(n,s,t);
    while(m--)cin>>u>>v>>w,Solver::add_edge(u,v,w);
    cout<<Solver::calc()<<"\n";
}
void solve_pilot(){
    cin>>m>>n;
    Solver::init(n+2,n+1,n+2);
    for(int i=1;i<=m;i++)Solver::add_edge(n+1,i,1);
    for(int i=m+1;i<=n;i++)Solver::add_edge(i,n+2,1);
    while(cin>>u>>v,(u!=-1&&v!=-1))Solver::add_edge(u,v,1);
    cout<<Solver::calc()<<"\n";
    for(int u=1;u<=m;u++)
        for(int i=Solver::hd[u];i;i=Solver::e[i].nxt)
            if(Solver::e[i^1].w&&Solver::e[i].to<=n)cout<<u<<" "<<Solver::e[i].to<<"\n";
}
void solve_bigraph_match(){
    cin>>n>>m>>e;
    Solver::init(n+m+2,n+m+1,n+m+2);
    for(int i=1;i<=n;i++)Solver::add_edge(n+m+1,i,1);
    for(int i=1;i<=m;i++)Solver::add_edge(i+n,n+m+2,1);
    while(e--)cin>>u>>v,Solver::add_edge(u,v+n,1);
    cout<<Solver::calc()<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve_demo();
    // solve_pilot();
    // solve_bigraph_match();
}