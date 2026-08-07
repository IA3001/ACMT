#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=605;
const LL INF=1e18;
int n,m,cnt;
LL g[N][N],d[N];
bool bin[N],vis[N];
LL SW(){
    LL ans=INF;
    for(int i=1;i<n;i++){
        int s=0,t=0;
        fill(vis,vis+1+n,false);
        fill(d,d+1+n,0);
        for(int j=1,now;j<=n-i+1;j++){
            now=0;
            for(int k=1;k<=n;k++)
                if(!bin[k]&&!vis[k]&&d[k]>=d[now])now=k;
            s=t;t=now;
            vis[now]=true;
            for(int k=1;k<=n;k++)d[k]+=g[k][now];
        }
        ans=min(ans,d[t]);
        bin[t]=true;
        for(int j=1;j<=n;j++)
            if(j!=s)g[s][j]=g[j][s]+=g[t][j];
    }
    return ans;
}
void solve(){
    cin>>n>>m;
    int u,v;LL w;
    for(int i=1;i<=m;i++){
        cin>>u>>v>>w;
        g[u][v]=g[v][u]+=w;
    }
    cout<<SW()<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}