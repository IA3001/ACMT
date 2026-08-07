#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=5e4+5;
struct STreeDSTree{
    struct DSTree{
        int lc,rc,tag;
        LL sum;
    }tr[N*__lg(N)*20];// YES 一发入魂 !!!
    int m;
    int tot,rt[N*4];
    // 新建节点 全部清空
    int _new_node(){
        ++tot;
        memset(tr+tot,0,sizeof(tr[0]));
        return tot;
    }
    // 上传信息
    void _up(int i){
        tr[i].sum=tr[tr[i].lc].sum+tr[tr[i].rc].sum;
    }
    // 懒标记
    void _lazy_add(int i,int n,int v){
        tr[i].tag+=v;
        tr[i].sum+=n*v;// 这里不会爆 因为 要么 n*1 要么 n/2*n 没有爆 long long
    }
    // 下传标记
    void _down(int i,int ln,int rn){
        if(!tr[i].lc)tr[i].lc=_new_node();
        if(!tr[i].rc)tr[i].rc=_new_node();
        if(tr[i].tag){
            _lazy_add(tr[i].lc,ln,tr[i].tag);
            _lazy_add(tr[i].rc,rn,tr[i].tag);
            tr[i].tag=0;
        }
    }
    // 区间加 v
    void _add(int i,int l,int r,int jl,int jr,int v){
        if(jl<=l&&r<=jr){
            _lazy_add(i,r-l+1,v);
        }else {
            int mid=(l+r)/2;
            _down(i,mid-l+1,r-mid);
            if(jl<=mid)_add(tr[i].lc,l,mid,jl,jr,v);
            if(jr>mid)_add(tr[i].rc,mid+1,r,jl,jr,v);
            _up(i);
        }
    }
    // 区间查询 
    LL _query_sum(int i,int l,int r,int jl,int jr){
        if(jl<=l&&r<=jr){
            return tr[i].sum;
        }else {
            int mid=(l+r)/2;
            _down(i,mid-l+1,r-mid);
            LL res=0;
            if(jl<=mid)res+=_query_sum(tr[i].lc,l,mid,jl,jr);
            if(jr>mid)res+=_query_sum(tr[i].rc,mid+1,r,jl,jr);
            return res;
        }
    }
    // 初始化 内层 m 要有 
    void init(int n,int m){
        this->m=m;
        tot=0;
        build(1,1,n);
    }
    // 构建外层
    void build(int i,int l,int r){
        rt[i]=_new_node();// 首先先占个坑 数据都是 0
        if(l==r){
            
        }else {
            int mid=(l+r)/2;
            build(i*2,l,mid);
            build(i*2+1,mid+1,r);
        }
    }
    // kl kr 新增一个 p
    void add(int i,int l,int r,int p,int kl,int kr){
        _add(rt[i],1,m,kl,kr,1);// 掌管 该值域 的集合 p 位置同样也要加 1
        if(l==r){
            
        }else {
            int mid=(l+r)/2;
            if(p<=mid)add(i*2,l,mid,p,kl,kr);
            else add(i*2+1,mid+1,r,p,kl,kr);
        }
    }
    // kl kr 区间第 k 大
    int kth(int i,int l,int r,LL k,int kl,int kr){
        if(l==r)return l;// 必定被 >=1 接住
        LL rsum = _query_sum(rt[i*2+1],1,m,kl,kr);// 右侧个数
        int mid=(l+r)/2;
        if(k>rsum)return kth(i*2,l,mid,k-rsum,kl,kr);// 始终位于 >0 的位置
        else return kth(i*2+1,mid+1,r,k,kl,kr); 
    }
}T;
int n,m;
int a[N],cntA;
array<LL,4> q[N];
int getA(int v){return lower_bound(a+1,a+1+cntA,v)-a;}
void solve(){
    cin>>n>>m;
    cntA=0;
    for(int i=1;i<=m;i++){
        auto& [op,l,r,v]=q[i];
        cin>>op>>l>>r>>v;
        if(op==1)a[++cntA]=v;
    }
    sort(a+1,a+1+cntA);
    cntA = unique(a+1,a+1+cntA)-a-1;
    T.init(cntA,n);
    for(int i=1;i<=m;i++){
        auto [op,l,r,v]=q[i];
        if(op==1)T.add(1,1,cntA,getA(v),l,r);
        else cout<<a[T.kth(1,1,cntA,v,l,r)]<<"\n";
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
/*
N 个可重集 N 个操作 
1. 区间增加元素 c 
2. 区间查询 k 大值
    a. 如果是 值域 套 权值线段树 那么 
    1. 单点 套 区间加 (单点路径上 也要加 log^2) 
    2. 前缀区间 套 区间查询  (log 次 log 区间查询 以二分 log^2)
    可见 外部静态 内部动态开点
    b. 如果是 集合 套 权值线段树 那么
    1. 区间 套 单点加 (区间路径上 单点加 ? 但是外层懒更新代价太大 ???)
    2. 区间 套 前缀查询 (log 次 log 前缀查询 另外加 log 次二分以确定 log^3)
    
    基米说: 你的直觉极其敏锐！在树套树中，如果遇到“区间修改”，我们通常必须让“区间（位置）”作为内层树，这样就可以在内层无痛使用 Lazy Tag。
    1. 单点修改 + 区间查询：外层位置树 + 内层权值树（经典做法，可以用树状数组套主席树优化）。
    2. 区间修改 + 区间查询：外层权值树 + 内层位置树（必须这么做，避免外层打 Tag 的灾难）。

    关于 _down 中的 _new_node 时机 
    
    不是吧，你想想，内部开点线段树的所有操作，最终都是以懒标记结束的，如果查询或修改的时候，需要分裂，
    那么down 操作中的 !lc !rc 第一次是必然触发的，这是必然的操作，否则懒标记无处下放或者？？ 
    等等， 目前可能的优化只能是 将 !lc !rc 放在 if tag 内 然后允许进入 0 节点，返回的是空值。
    我没有改进就过了，可能是因为 每次查询保证了一定能查到有效值。
    
    结论: 放在 if(tag) 内更节省 但是注意需要加一些 !i 空节点处理
*/