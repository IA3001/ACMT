#include<bits/stdc++.h>
using namespace std;
const int N=5e4+5;
const int inf=INT_MAX;
struct BITDSTree{
    inline static int a[N],b[N],ca,cb;
    int n,m;
    struct DSTree{
        int lc,rc;
        int sum;
    }tr[N*__lg(N)*__lg(N)*2];// N + N 次 log 外层 log 内层
    int tot;
    // 新建节点
    int _new_node(){
        ++tot;
        memset(tr+tot,0,sizeof(tr[0]));
        return tot;
    }
    // 更新
    void _up(int i){
        tr[i].sum=tr[tr[i].lc].sum+tr[tr[i].rc].sum;
    }
    // 单点增加
    void _add(int& i,int l,int r,int p,int v){
        if(!i)i=_new_node();
        if(l==r){
            tr[i].sum+=v;
        }else {
            int mid=(l+r)/2;
            if(p<=mid)_add(tr[i].lc,l,mid,p,v);
            else _add(tr[i].rc,mid+1,r,p,v);
            _up(i);
        }
    }
    // 批量前缀和
    int _pre_sum(int p){
        int l=1,r=m,mid,ta,tb;
        int res=0;
        while(l<r){/// <= 改成 < !!! 死循环 !!!
            mid=(l+r)/2;
            ta=tb=0;
            if(mid<=p){
                l=mid+1;
                for(int i=1;i<=ca;i++)if(a[i]){
                    res+=tr[tr[a[i]].lc].sum;
                    a[++ta]=tr[a[i]].rc;
                }
                for(int i=1;i<=cb;i++)if(b[i]){
                    res-=tr[tr[b[i]].lc].sum;
                    b[++tb]=tr[b[i]].rc;
                }
            }else {
                r=mid;
                for(int i=1;i<=ca;i++)if(a[i])a[++ta]=tr[a[i]].lc;
                for(int i=1;i<=cb;i++)if(b[i])b[++tb]=tr[b[i]].lc;
            }
            ca=ta;cb=tb;
        }
        // 修改 2：补充处理叶子节点
        if (l <= p) {
            for(int i=1;i<=ca;i++) if(a[i]) res += tr[a[i]].sum;
            for(int i=1;i<=cb;i++) if(b[i]) res -= tr[b[i]].sum;
        }
        return res;
    }
    // 批量前缀卡壳
    int _at(int x){
        int l=1,r=m,mid,ta,tb;
        int lsum;
        while(l<r){
            mid=(l+r)/2;
            lsum=0;
            ta=tb=0;
            for(int i=1;i<=ca;i++)if(a[i])lsum+=tr[tr[a[i]].lc].sum;
            for(int i=1;i<=cb;i++)if(b[i])lsum-=tr[tr[b[i]].lc].sum;
            if(x<=lsum){
                r=mid;
                for(int i=1;i<=ca;i++)if(a[i])a[++ta]=tr[a[i]].lc;
                for(int i=1;i<=cb;i++)if(b[i])b[++tb]=tr[b[i]].lc;
            }else {
                x-=lsum;
                l=mid+1;
                for(int i=1;i<=ca;i++)if(a[i])a[++ta]=tr[a[i]].rc;
                for(int i=1;i<=cb;i++)if(b[i])b[++tb]=tr[b[i]].rc;
            }
            ca=ta;cb=tb;
        }
        return l;
    }

    // 正片开始
    int rt[N];
    int arr[N];
    // 初始化 内外围
    void init(int n,int m){
        this->n=n;this->m=m;
        tot=0;
        fill(rt,rt+1+n,0);
    }
    // p 位置设置 k
    void insert(int p,int k){
        arr[p]=k;
        for(int i=p;i<=n;i+=i&-i)_add(rt[i],1,m,k,1);
    }
    // 删除 p 位置
    void erase(int p){
        for(int i=p;i<=n;i+=i&-i)_add(rt[i],1,m,arr[p],-1);// -1 
        arr[p]=0;
    }
    // p 位置改为 k
    void modify(int p,int k){erase(p);insert(p,k);}
    // [l,r] 内 <k 的个数
    int small(int l,int r,int k){
        ca=cb=0;
        for(int i=r;i;i-=i&-i)a[++ca]=rt[i];// !!!
        for(int i=l-1;i;i-=i&-i)b[++cb]=rt[i];// !!!
        return _pre_sum(k-1);
    }
    // [l,r] 内第 x 位数
    int at(int l,int r,int x){
        ca=cb=0;
        for(int i=r;i;i-=i&-i)a[++ca]=rt[i];// !!!
        for(int i=l-1;i;i-=i&-i)b[++cb]=rt[i];// !!!
        return _at(x);    
    }
    // [l,r] 内 k 的前驱
    int prev(int l,int r,int k){
        int sml=small(l,r,k);
        if(sml==0)return 0;
        return at(l,r,sml);
    }
    // [l,r] 内 k 的后继
    int next(int l,int r,int k){
        int le=small(l,r,k+1);
        int sz=small(l,r,m+1);
        if(le==sz)return m+1;
        return at(l,r,le+1);
    }
}T;
int n,m,p,k,l,r;
int a[N];
int A[N*2],cntA;
int getA(int v){return lower_bound(A+1,A+1+cntA,v)-A;}
array<int,4> q[N];
void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>a[i],A[++cntA]=a[i];
    for(int i=1;i<=m;i++){
        auto&[op,l,r,k]=q[i];
        cin>>op;
        if(op!=3)cin>>l>>r>>k;
        else cin>>l>>k;
        if(op!=2)A[++cntA]=k;
    }
    sort(A+1,A+1+cntA);
    cntA=unique(A+1,A+1+cntA)-A-1;
    A[0]=-inf;A[cntA+1]=inf;
    T.init(n,cntA);
    for(int i=1;i<=n;i++)T.insert(i,getA(a[i]));
    for(int i=1;i<=m;i++){
        auto[op,l,r,k]=q[i];
        if(op==1){
            cout<<T.small(l,r,getA(k))+1<<"\n";
        }else if(op==2){
            cout<<A[T.at(l,r,k)]<<"\n";
        }else if(op==3){
            T.modify(l,getA(k));
        }else if(op==4){
            cout<<A[T.prev(l,r,getA(k))]<<"\n";
        }else {
            cout<<A[T.next(l,r,getA(k))]<<"\n";
        }
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}