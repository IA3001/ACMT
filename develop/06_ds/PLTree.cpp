
#include<bits/stdc++.h>
using namespace std;
// k-短路
// 复杂度是 (n+m)*log(n) + klog(k)
const int N=5e3+5;
const int M=2e5+5;
const double inf = 1e18;
const double eps = 1e-6;
namespace PLTree{
    struct PersistentLeftListTree{
        // 尽可能避免在结构体里面赋非0值 
        // 因为一旦有一个，编译文件过大，所以说建议用init用一个初始化一个
        int lc,rc,d; 
        int v;// 信息1：冗余路目标
        double w;// 信息2：冗余路长度
        bool operator<(const PersistentLeftListTree& o)const{
            return w>o.w+eps;
        }
    }tr[N*500];
    int tot;
    // 左偏树操作1：merge
    int merge(int x,int y){
        if(!x||!y)return x|y;
        int z=++tot;
        if(tr[x]<tr[y])swap(x,y);
        tr[z]=tr[x];
        tr[z].rc=merge(tr[z].rc,y);
        if(tr[tr[z].lc].d<tr[tr[z].rc].d)swap(tr[z].lc,tr[z].rc);
        tr[z].d=tr[tr[z].rc].d+1;
        return z;
    }
    // 左偏树操作2：简单封装insert
    int insert(int x,int v,double w){
        tr[++tot].v=v;
        tr[tot].w=w;
        return merge(x,tot);
    }    
}using PLTree::tr;
int top[N];
// 唉wc 有重边 不能直接判 节点
// e[0]正向边 e[1]反向边 对应编号相同
struct Edge{
    int to,nxt;
    double w;
}e[2][M];
int cntE[2],hd[2][N];
// 注意这里的 w 别写成 int 了 
void addEdge(int u,int v,double w,int i){
    e[i][++cntE[i]]={v,hd[i][u],w};
    hd[i][u]=cntE[i];
}
int n,m;
double E;
double h[N];// 启发函数
bool vis[N];// dijk 辅助
int lst[N];// dijk 更新最短路对应父边编号, 可求得具体父节点
void dijk(int s){
    fill(h,h+n+1,inf);
    memset(vis,0,sizeof(vis[0])*(n+1));
    priority_queue<pair<double,int>> Q;
    h[s]=0;
    Q.push({0,s});
    while(Q.size()){
        auto [d,u] = Q.top();Q.pop();
        if(vis[u])continue;
        vis[u]=true;
        for(int i=hd[1][u];i;i=e[1][i].nxt){
            int v=e[1][i].to;
            double w=e[1][i].w;
            if(h[v]>h[u]+w+eps){
                h[v]=h[u]+w;
                lst[v]=i;
                Q.push({-h[v],v});
            }
        }
    }
}
// dfs 收集堆 不能保证 h 递增
// 收集堆的正解： bfs! 按照 h 升序 
int order[N];
void init(){
    iota(order,order+n,1);
    sort(order,order+n,[&](int a,int b){
        return h[a]<h[b];
    });
    for(int i=1;i<n;i++){
        int u=order[i];
        // 这样根据父边可以找到父节点 
        top[u]=top[e[0][lst[u]].to];
        for(int i=hd[0][u];i;i=e[0][i].nxt){
            int v=e[0][i].to;
            double w=e[0][i].w;
            if(i==lst[u])continue;
            top[u]=PLTree::insert(top[u],v,h[v]-h[u]+w);
        }
    }
}
void solve(){
    cin>>n>>m>>E;
    int u,v;
    double w;
    for(int i=1;i<=m;i++){
        cin>>u>>v>>w;
        if(u==n)continue;
        addEdge(u,v,w,0);
        addEdge(v,u,w,1);
    }
    dijk(n);
    init();
    E-=h[1];
    if(E+eps<0){cout<<"0\n";return;}
    int ans=1;
    // <冗余路径代价, 对应左偏树节点编号>
    priority_queue<pair<double,int>>Q; 
    if(top[1])
        Q.emplace(-(h[1]+tr[top[1]].w),top[1]);
    while(Q.size()){
        auto [d,x]=Q.top();Q.pop();
        d=-d;
        E-=d;
        if(E+eps<0)break;
        ans++;
        if(tr[x].lc)// 前提是有冗余路
            Q.emplace(-(d-tr[x].w+tr[tr[x].lc].w),tr[x].lc);
        if(tr[x].rc)// 前提是有冗余路
            Q.emplace(-(d-tr[x].w+tr[tr[x].rc].w),tr[x].rc);
        if(top[tr[x].v])// 前提是有冗余路
            Q.emplace(-(d+tr[top[tr[x].v]].w),top[tr[x].v]);
    }
    cout<<ans<<'\n';
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}