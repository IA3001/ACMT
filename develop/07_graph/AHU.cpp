#include<bits/stdc++.h>
using namespace std;
const int N=2e2+5;
const int mod=1e9+7;
const int base=233;
int pbase[N];
vector<int> e[N];
int n,h[N],sz[N],mx[N],ans;
map<int,int> rcd;
void init(){
    pbase[0]=1;
    for(int i=1;i<N;i++)// 初始化 base^i
        pbase[i]=1LL*pbase[i-1]*base%mod;
}
void dfs1(int u,int fa){// dfs 求重心
    sz[u]=1;mx[u]=0;// sz mx
    for(auto v:e[u])if(v!=fa){
        dfs1(v,u);
        sz[u]+=sz[v];// sz+=
        mx[u]=max(mx[u],sz[v]);// mx=max
    }
    mx[u]=max(mx[u],n-sz[u]);// mx=max
    ans=min(ans,mx[u]);// ans 
}
void dfs2(int u,int fa){// 求 hash
    h[u]=1;// 初始化 hash
    sz[u]=1;// 重心不一样 要重新计算
    for(auto v:e[u])if(v!=fa){
        dfs2(v,u);// 递归
        sz[u]+=sz[v];// 重心不一样 要重新计算
    }
    sort(e[u].begin(),e[u].end(),[&](const int& a,const int& b){
        return h[a]<h[b];
    });
    for(auto v:e[u])if(v!=fa)// 字符串 hash 
        h[u]=(1LL*h[u]*pbase[sz[v]]+h[v])%mod;
    h[u]=1LL*h[u]*base%mod;// ???
}
void solve(){
    int m;cin>>m;
    for(int i=1;i<=m;i++){
        cin>>n;
        // 清理树
        for(int i=1;i<=n;i++)e[i].clear();
        // 建树
        for(int i=1,fa;i<=n;i++){
            cin>>fa;if(!fa)continue;// C!
            e[fa].push_back(i);
            e[i].push_back(fa);
        }
        ans=n;// 初始化 ans
        dfs1(1,0);// 求解重心 
        int res=INT_MAX;
        for(int i=1;i<=n;i++)if(mx[i]==ans)
            dfs2(i,0),res=min(res,h[i]);// 取重心dfs
        if(!rcd.count(res))rcd[res]=i,cout<<i<<"\n";
        else cout<<rcd[res]<<"\n";// 已有
    }
}
int main(){
    init();// 初始化
    cin.tie(0)->sync_with_stdio(0);
    solve();
}

