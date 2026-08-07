#include<bits/stdc++.h>
using namespace std;
const int N=2e5+5;
int n,m,len;
int a[N];
struct Query{
    int id,L,R;
    bool operator<(const Query& o)const {
        if((L-1)/len+1!=(o.L-1)/len+1)return L<o.L;
        return R>o.R;
    }
}q[N];
int cur_ans,tmp_ans,tmp_job;
int cnt[N];
int ans[N];
void add(int v){
    ++cnt[v];
    // 不要改答案 虽然你可以计算 但是这里是只删!!!
    // while(cnt[cur_ans])cur_ans++; 
}
void del(int v){
    if(--cnt[v]==0&&v<cur_ans)cur_ans=v;
}
void solve(){
    cin>>n>>m;
    len=ceil(sqrt(n));
    for(int i=1;i<=n;i++)cin>>a[i],cnt[a[i]]++;
    for(int i=1;i<=m;i++){
        auto&[id,L,R]=q[i];
        cin>>L>>R;id=i;
    }
    sort(q+1,q+1+m);
    int qi=1,bn=(n+len-1)/len,l=1,r=n;
    /* 在调用之前请先计算出 [1,n] 的全局答案 */
    while(cnt[cur_ans])cur_ans++;
    for(int i=1;i<=bn;i++){
        int st=(i-1)*len+1,ed=min(n,i*len);// ed 还是需要的
        while(l<st)del(a[l++]);// 从 [st1,n] 删除一块 
        tmp_job=cur_ans;// 缓存 job [st2,n]
        for(;qi<=m&&q[qi].L<=ed;qi++){
            auto[id,L,R]=q[qi];// [艹] 注意这里 qi !!! 
            while(R<r)del(a[r--]);
            tmp_ans=cur_ans;
            while(l<L)del(a[l++]);
            ans[id]=cur_ans;
            cur_ans=tmp_ans;
            while(st<l)add(a[--l]);// 恢复 [l=st2]
        }
        while(r<n)add(a[++r]);// 恢复 [r=n]
        cur_ans=tmp_job;// 复原 [st2,n]
    }
    for(int i=1;i<=m;i++)cout<<ans[i]<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}