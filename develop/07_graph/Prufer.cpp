#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=5e6+5;
int n,mode;
LL ans;
vector<int> e[N];
int deg[N],code[N],fa[N];
// 如果给的数据不是 n 为根的树 就用这个跑出来 fa[]
// 然后 deg[fa[i]]++,deg[i]++;
void dfs(int u=n){
    for(auto v:e[u])if(v!=fa[u]){
        fa[v]=u;
        dfs(v);
    }
}
void encode(){
    int cnt=0;
    for(int i=1;i<=n;i++){
        int j=i;
        while(j<=i&&deg[j]==1)
            deg[j=code[++cnt]=fa[j]]--;
    }
}
void decode(){
    for(int i=1;i<=n;i++)deg[i]=1;
    for(int i=1;i<=n-2;i++)deg[code[i]]++;
    code[n-1]=n;// 必须补充 
    // for(int i=1;i<=n;i++)cout<<i<<":"<<deg[i]<<"\n";
    int cnt=0;
    for(int i=1;i<=n;i++){
        // cout<<"i="<<i<<"\n";
        int j=i;
        while(j<=i&&deg[j]==1){
            // cout<<"fa["<<j<<"]="<<code[cnt+1]<<"\n";
            deg[j=fa[j]=code[++cnt]]--;
        }
    }   
}
void solve(){
    cin>>n>>mode;
    if(mode==1){
        for(int i=1;i<n;i++){
            cin>>fa[i];
            deg[fa[i]]++,deg[i]++;
        }
        encode();
        for(int i=1;i<=n-2;i++)ans^=1LL*i*code[i];
    }else {
        for(int i=1;i<=n-2;i++)cin>>code[i];
        decode();
        for(int i=1;i<n;i++)ans^=1LL*i*fa[i];
    }
    cout<<ans<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}