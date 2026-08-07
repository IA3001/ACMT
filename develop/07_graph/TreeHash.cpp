#include<bits/stdc++.h>
using namespace std;
using ULL = unsigned long long;
const int N=2e2+5;
const ULL mod = 998244353;
const ULL mask = mt19937_64(time(0))();
vector<int>e[N];
int n;
int sz[N],mx[N],ans;
ULL h[N];
map<ULL,int> rcd;
ULL shift(ULL x){
    x^=mask;
    x^=x<<13;
    x^=x>>7;
    x^=x<<17;
    x^=mask;
    return x;
}
// 需要 n
void dfs1(int u,int fa){
    sz[u]=1;mx[u]=0;
    for(auto v:e[u])if(v!=fa){
        dfs1(v,u);
        sz[u]+=sz[v];
        mx[u]=max(mx[u],sz[v]);
    }
    mx[u]=max(mx[u],n-sz[u]);
    ans=min(ans,mx[u]);
}
void dfs2(int u,int fa){
    h[u]=1;
    for(auto v:e[u])if(v!=fa){
        dfs2(v,u);
        h[u]+=shift(h[v]);
    }
}
void solve(){
    int m;cin>>m;
    for(int i=1;i<=m;i++){
        cin>>n;
        for(int i=1;i<=n;i++)e[i].clear();
        for(int i=1,fa;i<=n;i++){
            cin>>fa;if(!fa)continue;
            e[i].push_back(fa);
            e[fa].push_back(i);
        }
        ans=n;
        dfs1(1,0);
        ULL res=-1;
        for(int i=1;i<=n;i++)if(ans==mx[i])
            dfs2(i,0),res=min(res,h[i]);
        if(!rcd.count(res))rcd[res]=i;
        cout<<rcd[res]<<"\n";
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}