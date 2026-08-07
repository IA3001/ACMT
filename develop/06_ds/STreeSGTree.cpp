#include<bits/stdc++.h>
using namespace std;
const int N=5e4+5;
const double ALPHA=0.7;
const int inf=INT_MAX;

struct STreeSGTree{
    inline static int collect[N],ci,*tp;// 容量为 N
    struct SGTree{
        int lc,rc,cnt,sz,diff;
        int key;
    }tr[N*__lg(N)*3];// 初始的 N + N 次 log N 插入 但是要开3倍才过这个 hyw???
    #define lc(i) tr[i].lc
    #define rc(i) tr[i].rc
    #define cnt(i) tr[i].cnt
    #define sz(i) tr[i].sz
    #define diff(i) tr[i].diff
    #define key(i) tr[i].key
    int tot;
    // 新建节点
    int _new_node(int k){
        ++tot;
        lc(tot)=rc(tot)=0;// 
        cnt(tot)=sz(tot)=diff(tot)=1;/// 
        key(tot)=k;
        return tot;
    }
    // 上传
    void _up(int i){
        sz(i)=cnt(i)+sz(lc(i))+sz(rc(i));
        diff(i)=(cnt(i)>0)+diff(lc(i))+diff(rc(i));// !!!
    }
    // 中序遍历
    void _inorder(int i){
        if(!i)return;
        _inorder(lc(i));
        if(cnt(i))collect[++ci]=i;// !!!
        _inorder(rc(i));
    }
    // 构建
    int _build(int l,int r){
        if(l>r)return 0;
        int mid=(l+r)/2;
        int i=collect[mid];
        lc(i)=_build(l,mid-1);
        rc(i)=_build(mid+1,r);
        _up(i);
        return i;
    }
    // 重构
    void _rebuild(){
        if(!tp)return;
        ci=0;
        _inorder(*tp);
        *tp=_build(1,ci);
    }
    // 不稳定 子树偏大
    bool _imbalance(int i){
        return max(diff(lc(i)),diff(rc(i)))>ALPHA*diff(i);
    }
    // root 插入 k
    void _insert(int& root,int k){
        tp=0;
        __insert(root,k);
        _rebuild();
    }
    // 内部插入
    void __insert(int& i,int k){
        if(!i)i=_new_node(k);
        else {
            if(k==key(i))cnt(i)++;
            else if(k<key(i))__insert(lc(i),k);
            else __insert(rc(i),k);
            _up(i);
            if(_imbalance(i))tp=&i;
        }
    }
    // root 删除 k
    void _erase(int& root,int k){
        tp=0;
        __erase(root,k);
        _rebuild();
    }
    // 内部删除 
    void __erase(int& i,int k){
        if(!i)return;// RE
        else {
            if(k==key(i))cnt(i)?cnt(i)--:0;
            else if(k<key(i))__erase(lc(i),k);
            else __erase(rc(i),k);
            _up(i);
            if(_imbalance(i))tp=&i;
        }
    }
    // 特殊需要
    int _small(int root,int k){
        int i=root,res=0;
        while(i){
            if(k<key(i))i=lc(i);
            else if(k>key(i))res+=sz(lc(i))+cnt(i),i=rc(i);
            else return res+sz(lc(i));
        }
        return res;
    }
    int _rank(int root,int k){return _small(root,k)+1;}
    int _at(int root,int x){
        if(x<1)return -inf;
        if(x>sz(root))return inf;
        int i=root;
        while(i){
            if(x<=sz(lc(i)))i=lc(i);
            else if(x>sz(lc(i))+cnt(i))x-=sz(lc(i))+cnt(i),i=rc(i);
            else return key(i);
        }
        assert(0&&"EMPTY");
    }
    int _prev(int root,int k){return _at(root,_rank(root,k)-1);}
    int _next(int root,int k){return _at(root,_rank(root,k+1));}
    
    // 正片开始
    int n;
    int rt[N*4];
    void init(int n){
        this->n=n;
        tot=0;
        build(1,1,n);
    }
    void build(int i,int l,int r){
        rt[i]=0;
        if(l==r){

        }else {
            int mid=(l+r)/2;
            build(i*2,l,mid);
            build(i*2+1,mid+1,r);
        }
    }
    void insert(int i,int l,int r,int p,int k){
        _insert(rt[i],k);
        if(l==r){

        }else {
            int mid=(l+r)/2;
            if(p<=mid)insert(i*2,l,mid,p,k);
            else insert(i*2+1,mid+1,r,p,k);
        }
    }
    void erase(int i,int l,int r,int p,int k){
        _erase(rt[i],k);
        if(l==r){

        }else {
            int mid=(l+r)/2;
            if(p<=mid)erase(i*2,l,mid,p,k);
            else erase(i*2+1,mid+1,r,p,k);
        }
    }
    // 因为多分支 所以 改成 small 吧
    int small(int i,int l,int r,int jl,int jr,int k){
        if(jl<=l&&r<=jr){
            return _small(rt[i],k);
        }else {
            int mid=(l+r)/2;
            int res=0;
            if(jl<=mid)res+=small(i*2,l,mid,jl,jr,k);
            if(jr>mid)res+=small(i*2+1,mid+1,r,jl,jr,k);
            return res;
        }
    }
    // log^3 恐怖
    int at(int i,int l,int r,int jl,int jr,int x){
        int L=0,R=1e8,M,ans=-1;
        while(L<=R){
            M=(L+R)/2;
            // 统计 <= M 的个数 如果冲到了 x 我要那个最小值 M 
            if(small(i,l,r,jl,jr,M+1)>=x)ans=M,R=M-1;
            else L=M+1;// <=M 的 有 <x 个
        }
        return ans;
    }
    int prev(int i,int l,int r,int jl,int jr,int k){
        if(jl<=l&&r<=jr){
            return _prev(rt[i],k);
        }else {
            int mid=(l+r)/2;
            int res=-inf;
            if(jl<=mid)res=max(res,prev(i*2,l,mid,jl,jr,k));
            if(jr>mid)res=max(res,prev(i*2+1,mid+1,r,jl,jr,k));
            return res;
        }
    }
    int next(int i,int l,int r,int jl,int jr,int k){
        if(jl<=l&&r<=jr){
            return _next(rt[i],k);
        }else {
            int mid=(l+r)/2;
            int res=inf;
            if(jl<=mid)res=min(res,next(i*2,l,mid,jl,jr,k));
            if(jr>mid)res=min(res,next(i*2+1,mid+1,r,jl,jr,k));
            return res;
        }
    }
    // 特殊的 单点 get 
    int get(int i,int l,int r,int p){
        if(l==r){
            assert(rt[i]);
            return key(rt[i]);// 不一定吧 啊对的对的 因为 只有一个元素 一定会保证 是根
            // return _at(rt[i],1);//
        }else {
            int mid=(l+r)/2;
            if(p<=mid)return get(i*2,l,mid,p);
            else return get(i*2+1,mid+1,r,p);
        }
    }
}T;
int n,m,op,l,r,p,k;
void solve(){
    cin>>n>>m;
    T.init(n);
    for(int i=1;i<=n;i++)cin>>k,T.insert(1,1,n,i,k);
    while(m--){
        cin>>op;
        if(op==1){
            cin>>l>>r>>k;cout<<T.small(1,1,n,l,r,k)+1<<"\n";
        }else if(op==2){
            cin>>l>>r>>k;cout<<T.at(1,1,n,l,r,k)<<"\n";
        }else if(op==3){
            cin>>p>>k;T.erase(1,1,n,p,T.get(1,1,n,p));T.insert(1,1,n,p,k);
        }else if(op==4){
            cin>>l>>r>>k;cout<<T.prev(1,1,n,l,r,k)<<"\n";
        }else {
            cin>>l>>r>>k;cout<<T.next(1,1,n,l,r,k)<<"\n";
        }
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}