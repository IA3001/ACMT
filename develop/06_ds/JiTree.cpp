// HDU5306 Gorgeous Sequence
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N = 1e6+5,N4=N*4;
const int inf = 1e9+7;
struct JiTree{
    LL sum[N4];// 总和
    int mx1[N4],mx2[N4],cn[N4],chmn[N4];// 最大 次大 最大统计值 check_min 懒标记值
    bool tag_chmn[N4];// check_min 懒标记 
    void up(int i){
        int l=i*2,r=l+1;
        sum[i]=sum[l]+sum[r];
        if(mx1[l]==mx1[r]){
            // 相等直接合并
            mx1[i]=mx1[l];
            cn[i]=cn[l]+cn[r];
            // 次大都是 2
            mx2[i]=max(mx2[l],mx2[r]);
        }else {
            // 不相等的话
            if(mx1[l]<mx1[r])swap(l,r);// 让 l 为较大者
            mx1[i]=mx1[l];
            cn[i]=cn[l];
            mx2[i]=max(mx2[l],mx1[r]);
        }
    }
    void lazy_chmn(int i,int v){
        if(v>=mx1[i])return;
        sum[i]+=(LL)cn[i]*(v-mx1[i]);
        chmn[i]=mx1[i]=v;
        tag_chmn[i]=true;
    }
    void build(int i,int l,int r,int* a){
        tag_chmn[i]=false;
        if(l==r){
            mx1[i]=sum[i]=a[l];
            mx2[i]=-inf;
            cn[i]=1;
            return;
        }
        int mid=(l+r)/2;
        build(i*2,l,mid,a);
        build(i*2+1,mid+1,r,a);
        up(i);
    }
    void down(int i){
        if(tag_chmn[i]){
            lazy_chmn(i*2,chmn[i]);
            lazy_chmn(i*2+1,chmn[i]);
            tag_chmn[i]=false;
        }
    }
    void check_min(int i,int l,int r,int jl,int jr,int v){
        if(v>=mx1[i])return;
        if(jl<=l&&r<=jr&&v>mx2[i]){
            // 就是这样的条件 到叶子的时候 触发 inf 必然正确
            lazy_chmn(i,v);
        }else {
            int mid=(l+r)/2;
            down(i);// down 随便 down 只要第一次 lazy 正确 之后的都会正确
            if(jl<=mid)check_min(i*2,l,mid,jl,jr,v);
            if(jr>mid)check_min(i*2+1,mid+1,r,jl,jr,v);
            up(i);
        }
    }
    int query_max(int i,int l,int r,int jl,int jr){
        if(jl<=l&&r<=jr){
            return mx1[i];
        }else {
            int mid=(l+r)/2;
            down(i);
            int res=-inf;
            if(jl<=mid)res=max(res,query_max(i*2,l,mid,jl,jr));
            if(jr>mid)res=max(res,query_max(i*2+1,mid+1,r,jl,jr));
            return res;
        }
    }
    LL query_sum(int i,int l,int r,int jl,int jr){
        if(jl<=l&&r<=jr){
            return sum[i];
        }else {
            int mid=(l+r)/2;
            down(i);
            LL res=0;
            if(jl<=mid)res+=query_sum(i*2,l,mid,jl,jr);
            if(jr>mid)res+=query_sum(i*2+1,mid+1,r,jl,jr);
            return res;
        }
    }
}T;

int n,m;
int a[N];

void solve(){
    // 0 x y t 区间取 min t
    // 1 x y 区间查询最大值
    // 2 x y 区间查询和
    int op,x,y,t;
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>a[i];
    T.build(1,1,n,a);
    while(m--){
        cin>>op>>x>>y;
        if(op==0){
            cin>>t;
            T.check_min(1,1,n,x,y,t);
        }else if(op==1){
            cout<<T.query_max(1,1,n,x,y)<<"\n";
        }else {
            cout<<T.query_sum(1,1,n,x,y)<<"\n";
        }
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    int T=1;
    cin>>T;
    while(T--)solve();
}