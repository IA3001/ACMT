#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N = 1e5+5;
const int M = 1e5+5;
namespace PSTree{
    struct PersistentSegmentTree{
        int lc,rc;
        LL sum,add_tag;
    }tr[N*4+M*(6+__lg(N))];// 只加 5 + M*log(N) 神秘的额外 +5
    int tot;
    int build(int l,int r,int* a){
        int cur=++tot;
        tr[cur].add_tag = 0;
        if(l==r)tr[cur].sum = a[l];
        else {
            int mid=(l+r)/2;
            tr[cur].lc = build(l,mid,a);
            tr[cur].rc = build(mid+1,r,a);
            tr[cur].sum = tr[tr[cur].lc].sum + tr[tr[cur].rc].sum;
        }
        return cur;
    }
    int add(int i,int l,int r,int jl,int jr,LL v){
        int cur = ++tot,a=max(jl,l),b=min(jr,r);
        tr[cur]=tr[i];
        tr[cur].sum+=(b-a+1)*v;
        if(jl<=l&&r<=jr)tr[cur].add_tag+=v;
        else {
            int mid=(l+r)/2;
            if(jl<=mid)tr[cur].lc = add(tr[cur].lc,l,mid,jl,jr,v);
            if(jr>mid)tr[cur].rc = add(tr[cur].rc,mid+1,r,jl,jr,v);
        }
        return cur;
    }
    LL query_sum(int i,int l,int r,int jl,int jr,LL add_his){
        if(jl<=l&&r<=jr){
            return tr[i].sum + (r-l+1)*add_his;
        }else {
            int mid=(l+r)/2;
            LL res=0;
            add_his+=tr[i].add_tag;
            if(jl<=mid)res+=query_sum(tr[i].lc,l,mid,jl,jr,add_his);
            if(jr>mid)res+=query_sum(tr[i].rc,mid+1,r,jl,jr,add_his);
            return res;
        }
    }
}
int rt[M];
int n,m,a[N];
void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>a[i];
    rt[0]=PSTree::build(1,n,a);
    string op;// SPOJ 连 char 都卡 string 
    for(int i=1,t=0,x,y,z;i<=m;i++){
        cin>>op;
        if(op=="C"){
            cin>>x>>y>>z;
            rt[++t]=PSTree::add(rt[t],1,n,x,y,z);
        }else if(op=="Q"){
            cin>>x>>y;
            cout<<PSTree::query_sum(rt[t],1,n,x,y,0)<<'\n';
        }else if(op=="H"){
            cin>>x>>y>>z;
            cout<<PSTree::query_sum(rt[z],1,n,x,y,0)<<'\n';
        }else cin>>x,t=x;
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}