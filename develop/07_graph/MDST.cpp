#include<bits/stdc++.h>
using namespace std;
const int N=2e2+5,M=N*N/2;
const int inf=1e9+7;
int n,m;
int g[N][N];
int val[N],rk[N][N];
array<int,3> edge[M];/// 
int MDST(){
    int ans=inf;
    // Floyd
    for(int c=1;c<=n;c++)
        for(int i=1;i<=n;i++)
            for(int j=1;j<=n;j++)
                g[i][j]=min(g[i][j],g[i][c]+g[c][j]);
    for(int i=1;i<=n;i++){
        for(int j=1;j<=n;j++){
            rk[i][j]=j;
            val[j]=g[i][j];
        }
        // 这就是谁的 val 小哪个编号就排前面
        sort(rk[i]+1,rk[i]+1+n,[&](int a,int b){return val[a]<val[b];});
    }
    for(int i=1;i<=n;i++)ans=min(ans,g[i][rk[i][n]]*2);
    for(int i=1;i<=m;i++){
        auto [u,v,w]=edge[i];
        // int mx=g[v][rk[u][n]];
        for(int p=n,j=n-1;j>=1;j--){
            // 建议只在 g[v][rk[u][j]] 增大时取 ans
            // ans=min(ans,g[u][rk[u][j]]+mx+w); // ??? 为什么这个错了??
            // mx=max(mx,g[v][rk[u][j]]);// ??? 为什么这个错了??
            // 否则答案过小???
            if(g[v][rk[u][j]]>g[v][rk[u][p]]){
                ans=min(ans,g[u][rk[u][j]]+g[v][rk[u][p]]+w);
                p=j;
            }
        }
    }
    return ans;
}
void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++){
        for(int j=1;j<=n;j++)
            g[i][j]=inf;
        g[i][i]=0;// n=1 
    }
    for(int u,v,w,i=1;i<=m;i++){
        cin>>u>>v>>w;
        edge[i]={u,v,w};
        g[u][v]=g[v][u]=w;
    }
    cout<<MDST()/2.0<<"\n";    
}   
int main(){
    cout<<setprecision(2)<<fixed;
    cin.tie(0)->sync_with_stdio(0);
    solve();
}