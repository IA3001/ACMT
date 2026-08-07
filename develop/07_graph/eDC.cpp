#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=5e4+5;
int n;
int w[N*2];// WC 了 原来是 点权
LL ans;
struct Edge{
    int to,nxt;
    int c;// 虚边额外的信息 c 
}e[N*2+N*2*2];// 原树 和 重构树
int cntn;// 重构节点编号
int hd0[N],hd[N*2],cntE;// 原树 和 重构树
void init(){
    // 都初始化
    fill(hd0,hd0+1+n,0);
    fill(hd,hd+1+n*2,0);
    cntE=1;// 1
    cntn=n;// n
}
// 记住这里加的都是双边啊啊啊 !
void add_edge(int hd[],int u,int v,int c=1){
    e[++cntE]={v,hd[u],c};hd[u]=cntE;
    e[++cntE]={u,hd[v],c};hd[v]=cntE;
}
namespace EDC{
    bool vis[N*2+N];// [!!!] 这里的是边组 还要加上原树的边 !!!! 虽然树 是冗余的 
    int sz[N*2];// 经典大小
    // 重构
    void rebuild(int u,int fa){
        int lst=0;
        for(int i=hd0[u],v=e[i].to;i;i=e[i].nxt,v=e[i].to)
            if(v!=fa){
                if(!lst){// 第一次
                    // 连接 u -> v
                    add_edge(hd,u,v);
                    lst=u;
                }else {// 必须新建
                    ++cntn;
                    w[cntn]=w[u];// !!! 这回事忘了 
                    // 连接 lst -> cntn 0权
                    add_edge(hd,lst,cntn,0);
                    // 连接 cntn -> v
                    add_edge(hd,cntn,v);
                    lst=cntn;
                }
                rebuild(v,u);
            }
    }
    // 一样的 get_size 
    void get_size(int u,int fa){
        sz[u]=1;
        for(int i=hd[u],v=e[i].to;i;i=e[i].nxt,v=e[i].to)
            if(v!=fa&&!vis[i>>1])get_size(v,u),sz[u]+=sz[v];
    }
    // 这里不需要 fa 了, 好像本来就不需要 fa???
    int get_centroid(int u){
        get_size(u,0);// 好像 0 就可以 因为 分治点/边 会挡住 
        int n=sz[u],fa=0;// 定向重心 / 父子树会用到
        bool f;
        do{
            f=false;
            for(int i=hd[u],v=e[i].to;i;i=e[i].nxt,v=e[i].to)
                if(v!=fa&&!vis[i>>1]&&sz[v]>n/2){
                    fa=u;u=v;f=true;break;
                }
        }while(f);
        // 边分治 扩展代码
        int best=0,edg=0;
        for(int i=hd[u],v=e[i].to;i;i=e[i].nxt,v=e[i].to)
            if(!vis[i>>1]){
                int tmp=v==fa?n-sz[v]:sz[v];// 这里会用到 fa
                if(tmp>best){
                    best=tmp;
                    edg=i;
                }
            }
        return edg;
    }
    struct Node{
        int w,c;
        Node(int ww=0,int cc=0):w(ww),c(cc){}// 
        bool operator<(const Node& o){return w<o.w;}
    };
    void dfs(int u,int fa,int W,int C,vector<Node>& buf){
        buf.emplace_back(W,C);
        for(int i=hd[u],v=e[i].to;i;i=e[i].nxt,v=e[i].to)
            if(v!=fa&&!vis[i>>1])dfs(v,u,min(W,w[v]),C+e[i].c,buf);
    }
    void calc(int i){
        int v1=e[i].to;
        int v2=e[i^1].to;
        // 假设 以 v1 作为分段点
        vector<Node> L(1),R(1);// 可别 size_t 炸了
        dfs(v1,0,w[v1],0,L);
        dfs(v2,0,min(w[v1],w[v2]),e[i].c,R);
        sort(L.begin()+1,L.end());// +1
        sort(R.begin()+1,R.end());// +1
        int mx=-1e9;
        for(int l=L.size()-1,r=R.size()-1;l>=1;l--){
            while(r>=1&&R[r].w>=L[l].w){
                mx=max(mx,R[r].c);
                r--;
            }
            if(r<R.size()-1)ans=max(ans,(LL)L[l].w*(L[l].c+mx+1));
        }
        mx=-1e9;
        for(int l=L.size()-1,r=R.size()-1;r>=1;r--){
            while(l>=1&&L[l].w>=R[r].w){
                mx=max(mx,L[l].c);
                l--;
            }
            if(l<L.size()-1)ans=max(ans,(LL)R[r].w*(R[r].c+mx+1));
        }
    }
    void edc(int u){
        int edg=get_centroid(u);
        // 这里是强制二分递归的 不管两边是不是单点 "空边"
        if(!edg)return;// 必须特殊处理 单个点 找不到边 
        vis[edg>>1]=true;
        calc(edg);
        edc(e[edg].to);
        edc(e[edg^1].to);
    }
}
void print(int u,int fa,int* hd){
    cout<<fa<<" -> "<<u<<"\n";
    for(int i=hd[u],v=e[i].to;i;i=e[i].nxt,v=e[i].to){
        if(v!=fa){
            print(v,u,hd);
        }
    }
}
void solve(){
    cin>>n;
    init();// 先 init !!!
    for(int i=1;i<=n;i++)cin>>w[i];
    for(int u,v,i=1;i<n;i++){
        cin>>u>>v;
        add_edge(hd0,u,v);
    }
    // // 先重构
    EDC::rebuild(1,0);
    // // 再启动
    EDC::edc(1);
    // print(1,0,hd0);
    // print(1,0,hd);
    cout<<ans<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}