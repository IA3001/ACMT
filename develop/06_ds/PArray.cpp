
#include <bits/stdc++.h>
using namespace std;
const int N = 1e6+5;
const int M = 1e6+5;
namespace PArray{
    struct PersistentTree{
        int lc,rc,val;
    }tr[N*4+M*(1+__lg(N))];
    int rt[N],tot;
    int build(int l,int r,int* a) {
        int cur=++tot;
        if(l==r){
            tr[cur].val=a[l];
        }else{ 
            int mid=(l+r)/2;
            tr[cur].lc=build(l,mid,a);
            tr[cur].rc=build(mid+1,r,a);
        }
        return cur;
    }
    int modify(int i,int l,int r,int p,int v){
        int cur = ++tot;
        tr[cur]=tr[i];
        if(l==r){
            tr[cur].val=v;
        }else {
            int mid=(l+r)/2;
            if(p<=mid)tr[cur].lc=modify(tr[i].lc,l,mid,p,v);
            else tr[cur].rc=modify(tr[i].rc,mid+1,r,p,v);
        }
        return cur;
    }
    int query(int i,int l,int r,int p) {
        if(l==r) return tr[i].val;
        int mid=(l+r)/2;
        if(p<=mid)return query(tr[i].lc,l,mid,p);
        else return query(tr[i].rc,mid+1,r,p);
    }
}
using PArray::rt;
int n,m,a[N];
void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;++i)cin>>a[i];
        rt[0]=PArray::build(1,n,a);
        for(int i=1,v,op,p,c;i<=m;i++){
            cin>>v>>op>>p;
            if (op==1){
            cin>>c;
            rt[i]=PArray::modify(rt[v],1,n,p,c);
        }else{
            rt[i]=rt[v];
            cout<<PArray::query(rt[i],1,n,p)<<'\n';
        }
    }
}
int main() {
    cin.tie(0)->sync_with_stdio(0);
    solve();
}