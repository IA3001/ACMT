#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=1e5+5;
namespace BIT{
    int tr[N];
    array<int,2> stk[N*2];
    int tp;
    void add(int i,int v){
        stk[++tp]={i,v};
        for(i++;i<N;i+=i&-i)tr[i]+=v;
    }
    int query(int i){
        int res=0;
        for(i++;i;i-=i&-i)res+=tr[i];
        return res;
    }
    void clear(){
        while(tp){
            auto [i,v]=stk[tp--];
            for(i++;i<N;i+=i&-i)tr[i]-=v;
        }
    }
}
int n,L,W;
vector<pair<int,int>> e[N];
bool vis[N];// 其一 vis pdc 
int sz[N];// 其二 sz pdc
void get_size(int u,int fa){
    // cout<<"get_size"<<u<<"\n";
    sz[u]=1;
    for(auto [v,_]:e[u])if(v!=fa&&!vis[v]){
        get_size(v,u);
        sz[u]+=sz[v];
    }
}
int get_centroid(int u,int fa){
    get_size(u,fa);
    int n=sz[u];
    bool f;
    do{
        f=false;
        for(auto [v,_]:e[u])if(v!=fa&&!vis[v]&&sz[v]>n/2){
            fa=u;u=v;f=true;
            break;
        }
    }while(f);
    return u;
}
struct Node{int d,e;}p[N];int cntP;
void dfs(int u,int fa,int dis,int edg){
    if(dis>W||edg>L)return;// 防止 long long
    p[++cntP]={dis,edg};
    for(auto [v,w]:e[u])if(v!=fa&&!vis[v])
        dfs(v,u,dis+w,edg+1);
}
LL calc(int u,int fa,int dis,int edg){
    // cout<<"calc"<<u<<"\n";
    dfs(u,fa,dis,edg);
    sort(p+1,p+1+cntP,[](const Node& a,const Node& b){return a.d<b.d;});
    for(int i=1;i<=cntP;i++)BIT::add(p[i].e,1);
    LL res=0;
    int l=1,r=cntP;
    while(l<r){
        if(p[l].d+p[r].d<=W&&L>=p[l].e){
            BIT::add(p[l].e,-1);
            res+=BIT::query(L-p[l].e);
            l++;
        }else {
            BIT::add(p[r].e,-1);
            r--;
        }
    }
    BIT::clear();
    cntP=0;
    return res;
}
LL pdc(int u){
    // cout<<"pdc"<<u<<"\n";
    vis[u]=true;
    LL res=calc(u,0,0,0);
    for(auto [v,w]:e[u])if(!vis[v]){
        res-=calc(v,u,w,1);// 容斥!!!
        res+=pdc(get_centroid(v,u));
    }
    return res;
}
void solve(){
    cin>>n>>L>>W;
    for(int i=2,f,w;i<=n;i++){
        cin>>f>>w;
        e[f].emplace_back(i,w);
        e[i].emplace_back(f,w);
    }
    cout<<pdc(get_centroid(1,0))<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}