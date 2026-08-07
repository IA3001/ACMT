#include<bits/stdc++.h>
using namespace std;
const int N=1e5+5;
const int C=26,L=10;
int path(char c){return c-'a';}
namespace PTrie{
    struct PersistentTrie{
        int ch[C],pass;
    }tr[N*(L+1)];
    int tot;
    int insert(int i,string s){
        int root=++tot;
        tr[root]=tr[i];
        tr[root].pass++;
        for(int b=0,cur=root,to;b<s.size();b++){
            to=path(s[b]);
            i=tr[i].ch[to];
            tr[cur=tr[cur].ch[to]=++tot]=tr[i];
            tr[cur].pass++;
        }
        return root;
    }
    // 除了外部差分，其实也可以内差分，比如这里加上 j 限制 d_pass
    int query(int i,string s){
        for(int b=0,to;b<s.size();b++){
            to=path(s[b]);
            i=tr[i].ch[to];
            if(!i)return 0;
        }
        return tr[i].pass;
    }
}
int rt[N];
int n,q,P;
int st[N][2+__lg(N)],dep[N];
vector<pair<int,string>> e[N];
void dfs0(int u){
    dep[u]=dep[st[u][0]]+1;
    for(int p=1;p<=P;p++)st[u][p]=st[st[u][p-1]][p-1];
    for(auto& [v,w]:e[u])if(v!=st[u][0]){
        st[v][0]=u;
        dfs0(v);
    }
}
int lca(int a,int b){
    if(dep[a]<dep[b])swap(a,b);
    for(int p=P;p>=0;p--)if(dep[st[a][p]]>=dep[b])a=st[a][p];
    if(a==b)return a;
    for(int p=P;p>=0;p--)if(st[a][p]!=st[b][p])a=st[a][p],b=st[b][p];
    return st[a][0];
}
void dfs1(int u){
    for(auto& [v,w]:e[u])if(v!=st[u][0]){
        rt[v]=PTrie::insert(rt[u],w);
        dfs1(v);
    }
}
void solve(){
    cin>>n;P=__lg(n)+1;
    string w;
    for(int u,v,i=1;i<n;i++){
        cin>>u>>v>>w;
        e[u].emplace_back(v,w);
        e[v].emplace_back(u,w);
    }
    dfs0(1);dfs1(1);
    cin>>q;
    for(int x,y,i=1;i<=q;i++){
        cin>>x>>y>>w;
        cout<<PTrie::query(rt[x],w)+PTrie::query(rt[y],w)-2*PTrie::query(rt[lca(x,y)],w)<<'\n';
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();// P6088
}