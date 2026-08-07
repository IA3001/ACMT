
#include<bits/stdc++.h>
using namespace std;
const int N=2e5+5;
const int M=2e5+5;
// 可持久化权值线段树(主席树)
namespace PWSTree{
    struct PersistentWeightSegmentTree{
            int lc,rc,sum;
    }tr[N*4+M*(1+__lg(N))];
    int tot,rt[N];
    int add(int i,int l,int r,int p,int v){
        int cur=++tot;
        tr[cur]=tr[i];
        tr[cur].sum+=v;
        if(l<r){
            int mid=(l+r)/2;
            if(p<=mid)tr[cur].lc = add(tr[i].lc,l,mid,p,v);
            else tr[cur].rc = add(tr[i].rc,mid+1,r,p,v);
        }
        return cur;
    }
    int query(int i,int j,int l,int r,int k){
        if(l==r)return l;
        else {
            int dl = tr[tr[j].lc].sum-tr[tr[i].lc].sum;
            int mid=(l+r)/2;
            if(k<=dl)return query(tr[i].lc,tr[j].lc,l,mid,k);
            else return query(tr[i].rc,tr[j].rc,mid+1,r,k-dl);
        }
    }
}
using PWSTree::rt;
int n,m,a[N],b[N],cntA;
unordered_map<int,int> getA;
void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>a[i],b[i]=a[i];
    sort(b+1,b+1+n);cntA=unique(b+1,b+1+n)-b-1;
    for(int i=1;i<=cntA;i++)getA[b[i]]=i;
    for(int i=1;i<=n;i++)rt[i]=PWSTree::add(rt[i-1],1,n,getA[a[i]],1);
    for(int i=1,l,r,k;i<=m;i++){
        cin>>l>>r>>k;
        cout<<b[PWSTree::query(rt[l-1],rt[r],1,n,k)]<<'\n';
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}