#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=2005,M=1e6+5;// [SB] 二分图的 N 两倍在这里改 
const LL INF =1e16;
namespace ISAP{
    struct Edge{
        int to,nxt;
        LL w;
    }e[M*2+N*2];// 二分图最大匹配 + N*2
    int hd[N],cur[N],cntE;
    int n,s,t;
    int d[N],gap[N];// [新]gap
    void init(int nn){
        n=nn;
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
    LL calc(int ss,int tt){
        s=ss;t=tt;
        LL ans=0;
        bfs();
        while(d[s]<n){// [!] d[s]<n
            memcpy(cur,hd,sizeof(hd[0])*(n+1));// [+] 当前弧
            ans+=dfs();
        }
        return ans;
    }
}
void solve_demo(){
    int n,m,s,t,u,v;LL w;
    cin>>n>>m>>s>>t;
    ISAP::init(n);
    while(m--)cin>>u>>v>>w,ISAP::add_edge(u,v,w);
    cout<<ISAP::calc(s,t)<<"\n";
}
void solve_pilot(){
    int m,n,u,v,S,T;
    cin>>m>>n;S=n+1;T=n+2;
    ISAP::init(n+2);
    for(int i=1;i<=m;i++)ISAP::add_edge(n+1,i,1);
    for(int i=m+1;i<=n;i++)ISAP::add_edge(i,n+2,1);
    while(cin>>u>>v,(u!=-1&&v!=-1))ISAP::add_edge(u,v,1);
    cout<<ISAP::calc(S,T)<<"\n";
    for(int u=1;u<=m;u++)
    for(int i=ISAP::hd[u];i;i=ISAP::e[i].nxt)
        if(ISAP::e[i^1].w&&ISAP::e[i].to<=n)
            cout<<u<<" "<<ISAP::e[i].to<<"\n";
}
void solve_bigraph_match(){
    int n,m,e,u,v,S,T;
    cin>>n>>m>>e;S=n+m+1;T=n+m+2;
    ISAP::init(n+m+2);
    for(int i=1;i<=n;i++)ISAP::add_edge(n+m+1,i,1);
    for(int i=1;i<=m;i++)ISAP::add_edge(i+n,n+m+2,1);
    while(e--)cin>>u>>v,ISAP::add_edge(u,v+n,1);
    cout<<ISAP::calc(S,T)<<"\n";
}
void solve_no_ST_any(){
    int n,m,S,T,cnte,u,v;LL a,b,l[N*2]={0},F[N]={0};
    cin>>n>>m;S=n+1;T=n+2;
    ISAP::init(n+2);cnte=1;
    for(int i=1;i<=m;i++){
        cin>>u>>v>>a>>b;
        ISAP::add_edge(u,v,b-a);
        l[++cnte]=a,++cnte;
        F[u]-=a;F[v]+=a;
    }
    LL tot=0;
    for(int i=1;i<=n;i++)
    if(F[i]>0)ISAP::add_edge(S,i,F[i]),tot+=F[i];
    else if(F[i]<0)ISAP::add_edge(i,T,-F[i]);
    if(tot!=ISAP::calc(S,T)){
        cout<<"No\n";
    }else {
        cout<<"Yes\n";
        for(int i=2;i<=1+m*2;i+=2)
        cout<<(l[i]+ISAP::e[i^1].w)<<"\n";// [异或1] 才是使用量
    }
}
void solve_ST_m(bool is_max){
    int n,m,s,t,S,T,cnte,u,v;LL a,b,l[N*2]={0},F[N]={0};
    cin>>n>>m>>s>>t;S=n+1;T=n+2;
    ISAP::init(n+2);cnte=1;
    for(int i=1;i<=m;i++){
        cin>>u>>v>>a>>b;
        ISAP::add_edge(u,v,b-a);
        l[++cnte]=a,++cnte;
        F[u]-=a;F[v]+=a;
    }
    ISAP::add_edge(t,s,INF);// [] 保持和 cnte 同频 
    LL tot=0;
    for(int i=1;i<=n;i++)
    if(F[i]>0)ISAP::add_edge(S,i,F[i]),tot+=F[i];
    else if(F[i]<0)ISAP::add_edge(i,T,-F[i]);
    if(tot!=ISAP::calc(S,T)){
        cout<<"N\n";
    }else {
        LL ans=ISAP::e[cnte+2].w;// 已经使用的流量
        ISAP::e[cnte+1].w=ISAP::e[cnte+2].w=0;// 断边
        if(is_max)ans+=ISAP::calc(s,t);// 我觉得残余 反悔边权 存在 计算的仍然是 s->t 最大增量 
        else ans-=ISAP::calc(t,s);// 显然 使用边权流守恒 可以证明 要不然这里怎么退流
        cout<<ans<<"\n";
    }
}
void solve_min_points_cover(){// UVA11419
    // 一个 enemy 就代表一个边 连接 row col
    // 只要我选择任意一个点 row/col 就可以覆盖这个边
    // 要消灭所有边 需要选用的最少 row/col 数量
    int n,m,k,r,c;
    while(cin>>n>>m>>k,n||m||k){
        int S=n+m+1,T=n+m+2;
        ISAP::init(n+m+2);
        vector<bool> use(n+m+3),vis(n+m+3);
        // 二分图 最小点覆盖/最大独立集 附加代码
        // 前提: use
        // 点覆盖: 左 !vis 右 vis 独立集相反
        function<void(int)> color;// [NB] c++11 就支持 function了
        color = [&](int u){
            vis[u]=true;
            for(int i=ISAP::hd[u],v;i;i=ISAP::e[i].nxt){
                v=ISAP::e[i].to;
                if(!vis[v]&&ISAP::e[i].w)color(v);
            }
        };
        for(int i=1;i<=k;i++){
            cin>>r>>c;
            ISAP::add_edge(r,n+c,1);
            use[r]=use[n+c]=true;
        }
        for(int i=1;i<=n;i++)if(use[i])ISAP::add_edge(S,i,1);
        for(int i=1;i<=m;i++)if(use[n+i])ISAP::add_edge(n+i,T,1);
        int cnt=ISAP::calc(S,T),cnt2=0;
        color(S);
        cout<<cnt<<" ";
        for(int i=1;i<=n;i++)if(use[i]&&!vis[i])
            cnt2++,cout<<"r"<<i<<" ";
        for(int i=1;i<=m;i++)if(use[n+i]&&vis[n+i])
            cnt2++,cout<<"c"<<i<<" ";
        assert(cnt==cnt2);
        cout<<"\n";
    }
}
void solve_min_paths_cover(){// 模板题
    int n,m,S,T,u,v;
    cin>>n>>m;S=n*2+1;T=n*2+2;
    vector<int> pre(n+1),nxt(n+1);
    ISAP::init(n*2+2);
    for(int i=1;i<=n;i++)ISAP::add_edge(S,i,1),ISAP::add_edge(n+i,T,1);
    for(int i=1;i<=m;i++)
        cin>>u>>v,ISAP::add_edge(u,v+n,1);
    int cnt=ISAP::calc(S,T);
    for(int u=1;u<=n;u++)
        for(int i=ISAP::hd[u],v;i;i=ISAP::e[i].nxt){
            v=ISAP::e[i].to;
            if(!ISAP::e[i].w&&v<=n*2)pre[v-n]=u,nxt[u]=v-n;
        }
    for(int u=1;u<=n;u++){
        int x=u;
        if(!pre[x]){
            do cout<<x<<" ";while(x=nxt[x]);
            cout<<"\n";
        }
    }
    cout<<n-cnt<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    // solve_demo();
    // solve_pilot();
    // solve_bigraph_match();
    // solve_no_ST_any();
    // solve_ST_m(true);
    // solve_ST_m(false);
    // solve_min_points_cover();
    solve_min_paths_cover();
}