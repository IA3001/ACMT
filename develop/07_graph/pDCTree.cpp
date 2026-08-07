#include<bits/stdc++.h>
using namespace std;
const int N=1e5+5;
// 题目数据
int n,q;
vector<int> e[N];
int w[N];
// 求解 dist
int dep[N],st[N][__lg(N)+2],P;
void dfs0(int u,int fa){
    dep[u]=dep[fa]+1;
    st[u][0]=fa;
    for(int p=1;p<=P;p++)st[u][p]=st[st[u][p-1]][p-1];
    for(auto v:e[u])if(v!=fa)dfs0(v,u);
}
int lca(int a,int b){
    if(dep[a]<dep[b])swap(a,b);
    for(int p=P;p>=0;p--)
    if(dep[st[a][p]]>=dep[b])a=st[a][p];
    if(a==b)return a;
    for(int p=P;p>=0;p--)
    if(st[a][p]!=st[b][p])a=st[a][p],b=st[b][p];
    return st[a][0];
}
int dist(int a,int b){return dep[a]+dep[b]-2*dep[lca(a,b)];}
// 动态开点线段树 单点增加 区间查询
namespace DSTree{
    struct DSTree{
        int lc,rc;
        int sum;    
    }tr[N*__lg(N)*__lg(N)*2];
    int tot;
    int new_node(){
        ++tot;
        memset(tr+tot,0,sizeof(tr[0]));
        return tot;
    }
    void add(int& i,int l,int r,int p,int v){
        if(!i)i=new_node();
        tr[i].sum+=v;
        if(l==r){
            // 既然单点更新 就不 up 了 
        }else {
            int mid=(l+r)/2;
            if(p<=mid)add(tr[i].lc,l,mid,p,v);
            else add(tr[i].rc,mid+1,r,p,v);
        }
    }
    int query(int i,int l,int r,int jl,int jr){
        if(l>r)return 0;// 
        if(!i)return 0;
        if(jl<=l&&r<=jr){
            return tr[i].sum;
        }else {
            int mid=(l+r)/2;
            int res=0;
            if(jl<=mid)res=query(tr[i].lc,l,mid,jl,jr);// 6
            if(jr>mid)res+=query(tr[i].rc,mid+1,r,jl,jr);
            return res;
        }
    }
}
// 点分治
namespace PDC{
    bool vis[N];
    int sz[N];
    // 点分树
    int p[N];
    // 线段树 一个加 一个减
    int rt[N],rt2[N];
    void get_size(int u,int fa){
        sz[u]=1;
        for(auto v:e[u])if(v!=fa&&!vis[v]){
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
            for(auto v:e[u])if(v!=fa&&!vis[v]&&sz[v]>n/2){
                fa=u;u=v;f=true;break;
            }
        }while(f);
        return u;
    }
    void pdc(int u,int fa){
        vis[u]=true;
        p[u]=fa;
        for(auto v:e[u])if(!vis[v])
            pdc(get_centroid(v,u),u);
    }
    // u 节点增加 k
    // 我一直理解错了 原来不是孩子的直接影响
    // 而是容斥掉来自子树的影响啊啊啊 
    void add(int u,int k){
        int cur=u;
        // 自身要加
        DSTree::add(rt[u],0,n,0,k);
        while(p[cur]){// 如果有父亲
            int d=dist(u,p[cur]);
            DSTree::add(rt[p[cur]],0,n,d,k);
            DSTree::add(rt2[cur],0,n,d,k);// 容斥
            cur=p[cur];
        }
    }
    // 查询 距离 u 节点 d 距离的所有点权和 
    int query(int u,int d){
        if(d<0)return 0;
        int cur=u;
        // 自身
        int res=DSTree::query(rt[u],0,n,0,d);
        while(p[cur]){// 如果有父亲 且 够得到
            int dis=dist(u,p[cur]);
            if(d>=dis){// 不要以为点分树上的距离 ?!? 这里是 u !!! 
                res+=DSTree::query(rt[p[cur]],0,n,0,d-dis);// 这里要减 !!!!
                res-=DSTree::query(rt2[cur],0,n,0,d-dis);// 容斥 !!!
            }
            cur=p[cur];// 死循环!!!
        }
        return res;
    }
}
void solve(){
    cin>>n>>q;
    P=__lg(n)+1;
    for(int i=1;i<=n;i++)cin>>w[i];
    for(int u,v,i=1;i<n;i++){
        cin>>u>>v;
        e[u].push_back(v);
        e[v].push_back(u);
    }
    dfs0(1,0);// 准备 dist
    PDC::pdc(PDC::get_centroid(1,0),0);// 构建 点分树 
    for(int i=1;i<=n;i++)PDC::add(i,w[i]);// 初始化点权
    int op,x,k,y,lst=0;
    while(q--){
        cin>>op;
        if(op==0){
            cin>>x>>k;x^=lst;k^=lst;
            cout<<(lst=PDC::query(x,k))<<"\n";
        }else { 
            cin>>x>>y;x^=lst;y^=lst;
            PDC::add(x,y-w[x]);
            w[x]=y;
        }
    }
}
int main(){
    solve();
}
