#include<bits/stdc++.h>
using namespace std;
const int N=5e5+5;
int n,m,s;
vector<int>e[N];
namespace Euler{
    int first[N];
    int euler[N*2],eulercnt;
    int dep[N],rmq[N*2][__lg(N*2)+2],P;
    // C return 没写 
    int upper(int a,int b){return dep[a]<dep[b]?a:b;}
    void dfs(int u,int fa){
        euler[++eulercnt]=u;
        rmq[eulercnt][0]=u;
        first[u]=eulercnt;
        dep[u]=dep[fa]+1;
        for(auto v:e[u])if(v!=fa){
            dfs(v,u);
            euler[++eulercnt]=u;
            rmq[eulercnt][0]=u;
        }
    }
    void build(){
        P=__lg(eulercnt);// !!!
        for(int p=1;p<=P;p++){
            for(int i=1;i<=eulercnt;i++){
                int ed=min(eulercnt,i+(1<<(p-1)));
                rmq[i][p]=upper(rmq[i][p-1],rmq[ed][p-1]);
            }
        }
    }
    int lca(int a,int b){
        int l=first[a],r=first[b];
        if(l>r)swap(l,r);
        int p=__lg(r-l+1);
        return upper(rmq[l][p],rmq[r-(1<<p)+1][p]);
    }
}
// 我寻思着 ST 表不也是 O(n log n) 预处理的吗 完爆 ST 表啊
namespace DFN{
    int dfn[N],dfncnt;
    int dep[N],rmq[N][__lg(N)+2],P;
    int upper(int a,int b){return dep[a]<dep[b]?a:b;}// 记住了 return
    void dfs(int u,int fa){
        dfn[u]=++dfncnt;
        dep[u]=dep[fa]+1;
        rmq[dfncnt][0]=fa;// 和 Euler 序不同的地方
        for(auto v:e[u])if(v!=fa)dfs(v,u);
    }
    void build(){
        P=__lg(dfncnt);
        for(int p=1;p<=P;p++){
            for(int i=1;i<=dfncnt;i++){
                int ed=min(dfncnt,i+(1<<(p-1)));
                rmq[i][p]=upper(rmq[i][p-1],rmq[ed][p-1]);
            }
        }
    }
    int lca(int a,int b){
        if(a==b)return a;// 和 Euler 序不同的地方
        int l=dfn[a],r=dfn[b];
        if(l>r)swap(l,r);
        l++;// 和 Euler 序不同的地方
        int p=__lg(r-l+1);
        return upper(rmq[l][p],rmq[r-(1<<p)+1][p]);
    }
}
void solve(){
    cin>>n>>m>>s;
    for(int u,v,i=1;i<n;i++){
        cin>>u>>v;
        e[u].push_back(v);
        e[v].push_back(u);
    }
    // Euler::dfs(s,0);
    // Euler::build();
    DFN::dfs(s,0);
    DFN::build();
    while(m--){
        int a,b;
        cin>>a>>b;
        // cout<<Euler::lca(a,b)<<"\n";
        cout<<DFN::lca(a,b)<<"\n";
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}