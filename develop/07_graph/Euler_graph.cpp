// 在 有向图/无向图 中 寻找字典序最小的欧拉路
#include<bits/stdc++.h>
#define DIRECTED
using namespace std;
const int N=1e5+5,M=2e5+5;
struct DSU{
    vector<int> f,sz;
    void init(int n){
        f.resize(n);
        iota(f.begin(),f.end(),0);
        sz.assign(n,1);
    }
    int fd(int x){
        if(f[x]!=x)f[x]=fd(f[x]);
        return f[x];
    }
    void merge(int x,int y){
        x=fd(x),y=fd(y);
        if(x==y)return;
        if(sz[x]<sz[y])swap(x,y);
        sz[x]+=sz[y];
        f[y]=x;
    }
}D;
struct Edge{
    int to,nxt,id;
}e[M*2];
bool vis[M*2];
int cntE,hd[N];
int n,m;
vector<pair<int,int>> tmp[N];
int in[N],out[N];
vector<int> path;
void init(){
    memset(hd,0,sizeof(hd[0])*(n+1));
    memset(in,0,sizeof(in[0])*(n+1));
    memset(out,0,sizeof(out[0])*(n+1));
    memset(vis,0,sizeof(vis[0])*(cntE+1));
    for(int i=1;i<=n;i++)tmp[i].clear();
    path.clear();
    cntE=0;
}
void add_edge(int u,int v,int id){
    e[++cntE]={v,hd[u],id};
    hd[u]=cntE;
    // cout<<"add "<<u<<"->"<<v<<" "<<id<<"\n";
}
void dfs(int u){
    // cout<<"vis:"<<u<<"\n";
    for(int& i=hd[u];i;i=e[i].nxt){
        if(vis[e[i].id])continue;
        vis[e[i].id]=true;
        dfs(e[i].to);
    }
    path.push_back(u);
}
int check_u(){
    int cn=0,first=0;
    D.init(n+1);
    for(int u=1;u<=n;u++){
        if(in[u]){
            // WC 忘了奇度了
            if(!first||in[first]%2==0&&in[u]&1)first=u;
            cn++;
            for(auto [v,id]:tmp[u])D.merge(u,v);
        }
    }
    if(D.sz[D.fd(first)]!=cn)return 0;
    if(!first)return -1;
    return first;// -1 表示全部都是点集
}
int check_d(){
    int cn=0,x=0,first=0;
    D.init(n+1);
    for(int u=1;u<=n;u++){
        if(in[u]||out[u]){
            if(!first)first=u;
            cn++;
            int d = in[u]-out[u];
            if(d==-1){
                if(x)return 0;
                x=u;
            }else if(d!=0&&d!=1)return 0;
            
            for(auto [v,id]:tmp[u])D.merge(u,v);
        }
    }
    if(!first)return -1;
    if(D.sz[D.fd(first)]!=cn)return 0;
    return x?x:first;// -1 表示全是点集
}
void solve(){
    init();
    n=500;
    cin>>m;
    // cin>>n>>m;
    int u,v;
    for(int i=1;i<=m;i++){
        cin>>u>>v;
        // case 1 无向图:
        tmp[u].push_back({v,i});
        tmp[v].push_back({u,i});
        out[u]++,in[v]++;
        out[v]++,in[u]++;
        // // case 2 有向图:
        // tmp[u].push_back({v,i});
        // out[u]++,in[v]++;
    }
    // 起点字典序最小处理
    // 【注意】使用前请保证该图为 连通欧拉图 + 孤立点集
    // case 1 无向图:
    int st = check_u();// AC
    // // case 2 有向图:
    // int st = check_d();// AC
    if(!st){cout<<"No\n";return;}
    // 字典序最小处理
    for(int u=1;u<=n;u++){
        // 【WC】 我 SB 了 【链式前向星】是 【头插】的
        sort(tmp[u].begin(),tmp[u].end(),greater<>());
        for(auto [v,id]:tmp[u])add_edge(u,v,id);
    }
    dfs(st);// AC AC 
    reverse(path.begin(),path.end());
    for(auto u:path)cout<<u<<"\n";
    // for(auto u:path)cout<<u<<" ";
    cout<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}