#include<bits/stdc++.h>
using namespace std;
const int N=14e4+5,NUM=1e6+5;
int n,_,m,t,len;
struct Modify{
    int p,v;
}modify[N];
struct Query{
    int id,L,R,T;
    bool operator<(const Query& o)const {
        if((L-1)/len+1!=(o.L-1)/len+1)return L<o.L;
        if((R-1)/len+1!=(o.R-1)/len+1)return R<o.R;
        return T<o.T;
    }
}q[N];
int a[N];
int cnt[NUM];
int cur_type;
int ans[N];
void add(int v){if(++cnt[v]==1)cur_type++;}
void del(int v){if(--cnt[v]==0)cur_type--;}
void change(int L,int R,int i){
    auto& [p,v]=modify[i];
    if(L<=p&&p<=R)del(a[p]),add(v);
    swap(a[p],v);
}
void solve(){
    cin>>n>>_;
    for(int i=1;i<=n;i++)cin>>a[i];
    for(int i=1;i<=_;i++){
        char op;cin>>op;
        if(op=='Q'){
            auto& [id,L,R,T]=q[++m];
            id=m;T=t;
            cin>>L>>R;
        }else {
            auto& [p,v]=modify[++t];
            cin>>p>>v;
        }
    }
    // assert(m) // 必须有输出呗
    // len=ceil(pow(n,2.0/3));// 6.35s
    // len=ceil(pow(4.0*n*n,1.0/3));// 4.84s [嘿嘿] 我就说嘛!!!
    len=max(1,(int)pow(2.0*n*n*(n+t)/max(1,m),1.0/3));// 4.34s [嘿嘿] 我就说嘛!!!
    sort(q+1,q+1+m);
    int l=1,r=0,t=0;
    for(int i=1;i<=m;i++){
        auto[id,L,R,T]=q[i];
        while(L<l)add(a[--l]);
        while(r<R)add(a[++r]);
        while(l<L)del(a[l++]);
        while(R<r)del(a[r--]);
        while(t<T)change(L,R,++t);
        while(T<t)change(L,R,t--);
        ans[id]=cur_type;
    }
    for(int i=1;i<=m;i++)cout<<ans[i]<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}