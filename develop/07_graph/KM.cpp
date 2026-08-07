#include<bits/stdc++.h>
using LL = long long;
using namespace std;
const int N = 505;
const LL INF = 1e16;
namespace KM{
    int n;
    LL g[N][N],la[N],lb[N],d[N];
    int match[N],pre[N];
    bool vb[N];
    void bfs(int x){
        fill(vb,vb+1+n,false);
        fill(pre,pre+1+n,0);
        fill(d,d+1+n,INF);
        int y=0,yy=0;
        match[0]=x;
        do{
            LL k=INF;
            x=match[y];
            vb[y]=true;
            for(int i=1;i<=n;i++){
                if(vb[i])continue;
                if(d[i]>la[x]+lb[i]-g[x][i]){// la[x!!!] + lb[i] 
                    d[i]=la[x]+lb[i]-g[x][i];
                    pre[i]=y;
                }
                if(k>d[i])k=d[i],yy=i;
            }
            for(int i=0;i<=n;i++)// 从 0 开始
                if(vb[i])la[match[i]]-=k,lb[i]+=k;
                else d[i]-=k;
            y=yy;
        }while(match[y]);
        while(y){
            match[y]=match[pre[y]];
            y=pre[y];
        }
    }
    LL calc(int nn){
        n=nn;
        fill(la,la+1+n,false);
        fill(lb,lb+1+n,false);
        fill(match,match+1+n,0);
        for(int i=1;i<=n;i++)bfs(i);
        LL ans=0;
        for(int i=1;i<=n;i++)
            ans+=g[match[i]][i];
        return ans;
    }   
}using KM::g;

void solve_perfect_match(){// P6577
    int n,u,v,k;LL w;
    cin>>n>>k;
    for(int i=1;i<=n;i++)
        for(int j=1;j<=n;j++)
            g[i][j]=-INF;
    for(int i=1;i<=k;i++){
        cin>>u>>v>>w;
        g[u][v]=max(g[u][v],w);
    }
    cout<<KM::calc(n)<<"\n";
    for(int i=1;i<=n;i++)
        cout<<KM::match[i]<<" ";
    cout<<"\n";
}
void solve_normal_match(){// UOJ80
    int n,m,mx,u,v,k;LL w;
    cin>>n>>m>>k;swap(n,m);// [按需]女左 n 男右 m
    mx=max(n,m);// 扩展为最大值
    for(int i=1;i<=mx;i++)
        for(int j=1;j<=mx;j++)
            g[i][j]=0;// 初始化 0 !!!
    for(int i=1;i<=k;i++){
        cin>>u>>v>>w;swap(u,v);// [按需]女 u 男 v
        g[u][v]=max(g[u][v],w);
    }
    cout<<KM::calc(mx)<<"\n";
    for(int i=1;i<=m;i++)
        // 方案: 因为题目保证 w!=0 所以可以判断是否命中已有边
        cout<<(g[KM::match[i]][i]?KM::match[i]:0)<<" ";
        // 更稳健的写法：判断匹配到的点是否是真实点
        // 即编号 <= 真实的左部点数量 而不是判断边权
    cout<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve_perfect_match();
    // solve_normal_match();
}

