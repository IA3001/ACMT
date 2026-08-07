#include<bits/stdc++.h>
using namespace std;
const int N=2e5+5;
int n,m,len;
struct Query{
    int id,l,r;
    bool operator<(const Query& o)const {
        // 正宗的块间排序
        // [唐唐唐] 你为什么在这里写 < 
        if((l-1)/len+1!=(o.l-1)/len+1)return l<o.l;
        // 正宗的块内奇升偶降排序
        return (((l-1)/len+1)&1)?r<o.r:r>o.r;
    }
}q[N];
int a[N];// 原数组
int cnt[N];// v 的词频
int cntcnt[N];// 词频为 f 的个数
int ans[N];// 查询 [l,r] 区间 最大词频
int cur_ans;// 当前 [l,r] 区间 最大词频
// v 的词频+1
void add(int v){
    cntcnt[cnt[v]]--;
    cntcnt[++cnt[v]]++;
    if(cnt[v]>cur_ans)cur_ans++;// assert
}
// v 的词频-1
void del(int v){
    cntcnt[cnt[v]]--;
    cntcnt[--cnt[v]]++;
    if(!cntcnt[cur_ans])cur_ans--;// assert
}
int A[N],cntA;
int getA(int v){return lower_bound(A+1,A+1+cntA,v)-A;}
void solve(){
    cin>>n>>m;
    len=ceil(sqrt(n));

    for(int i=1;i<=n;i++)cin>>a[i],A[++cntA]=a[i];
    sort(A+1,A+1+cntA);
    cntA=unique(A+1,A+1+cntA)-A-1;
    for(int i=1;i<=n;i++)a[i]=getA(a[i]);
    
    for(int i=1;i<=m;i++)
        cin>>q[i].l>>q[i].r,q[i].id=i;
    sort(q+1,q+1+m);

    cntcnt[0]=0;
    for(int i=1,l=1,r=0;i<=m;i++){
        auto[id,L,R]=q[i];
        while(L<l)add(a[--l]);
        while(r<R)add(a[++r]);
        while(l<L)del(a[l++]);
        while(R<r)del(a[r--]);
        ans[id]=cur_ans;
    }
    for(int i=1;i<=m;i++)cout<<-ans[i]<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}