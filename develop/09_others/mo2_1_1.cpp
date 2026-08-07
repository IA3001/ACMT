#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=1e5+5,V=(1<<14)+1;
int n,m,k,len;
int a[N];
struct Query{
    int id,L,R;
    bool operator<(const Query& o)const {
        if((L-1)/len+1!=(o.L-1)/len+1)return L<o.L;
        return ((L-1)/len+1)&1?R<o.R:R>o.R;
    }
}q[N];
struct Query2{
    int id,l,r,op;// 哦 这里不用写 x
};
vector<Query2> q2l[N],q2r[N];
vector<int> cand;

int cnt[V];
LL pre[N],suf[N];
LL ans[N];

void solve(){
    cin>>n>>m>>k;
    cand.clear();
    for(int i=0;i<(1<<14);i++)
        if(__builtin_popcount(i)==k)cand.push_back(i);
    len=ceil(sqrt(n));
    for(int i=1;i<=n;i++)cin>>a[i];
    for(int i=1;i<=m;i++){
        auto&[id,L,R]=q[i];
        cin>>L>>R;id=i;
    }
    if(k>14){// 特判!!!
        while(m--)cout<<0<<"\n";
        return;
    }
    sort(q+1,q+1+m);
    // 清空
    fill(cnt,cnt+V,0);
    // 首先预处理 辅助信息 pre
    for(int i=1;i<=n;i++){
        pre[i]=pre[i-1]+cnt[a[i]];
        for(auto v:cand)cnt[a[i]^v]++;
    }
    fill(cnt,cnt+V,0);
    // 首先预处理 辅助信息 suf
    for(int i=n;i>=1;i--){
        suf[i]=suf[i+1]+cnt[a[i]];
        for(auto v:cand)cnt[a[i]^v]++;
    }
    // 首先 第一次莫队 走个形式
    for(int i=1,l=1,r=0;i<=m;i++){
        auto[id,L,R]=q[i];
        // [!!!] 事实上 先右扩右缩 然后左扩左缩 节省代码行数 r=R l=L
        if(r<R){// 右扩 [l,r] -> [r+1,R] ans+= pre[r+1,R] - 二次离线左
            q2l[l-1].push_back({id,r+1,R,-1});
            ans[id]+=pre[R]-pre[r];
        }
        if(R<r){// 右缩
            q2l[l-1].push_back({id,R+1,r,1});
            ans[id]-=pre[r]-pre[R];
        }
        r=R;
        if(L<l){// 左扩 [L,l-1] <- [l,r] ans+= suf[L,l-1] - 二次离线右
            q2r[r+1].push_back({id,L,l-1,-1}); 
            ans[id]+=suf[L]-suf[l];
        }
        if(l<L){// 左缩 [l,L-1] -> [L,r]
            q2r[r+1].push_back({id,l,L-1,1}); // 那么这里只需要 互换后 变为 -1
            // 那么现在这里其实连符号都不用变了 ? 不对 得变!!!!
            ans[id]-=suf[l]-suf[L];
        }
        l=L;
        // [艹] 忘了 !!! 不应该在这里一起赋值 l r 
    }
    // 第二次莫队 
    fill(cnt,cnt+V,0);
    // 先玩 q2l[0,n] 注意这里从 0 开始
    for(int i=0;i<=n;i++){
        if(i>=1)for(auto v:cand)cnt[v^a[i]]++;
        for(auto [id,L,R,op]:q2l[i]){
            // 乖乖站好
            for(int i=L;i<=R;i++)ans[id]+=op*cnt[a[i]];
        }
    }
    fill(cnt,cnt+V,0);
    // 再 q2r[n+1,1] 注意这里从 n+1 开始
    for(int i=n+1;i>=1;i--){
        if(i<=n)for(auto v:cand)cnt[v^a[i]]++;
        for(auto [id,L,R,op]:q2r[i]){
            // 乖乖站好
            for(int i=L;i<=R;i++)ans[id]+=op*cnt[a[i]];
        }
    }
    // 因为是离线啊 所以别忘了求一个前缀和 
    // [艹] 依赖关系不是 i-1 而是 q[i-1].id !!!
    for(int i=2;i<=m;i++)
        ans[q[i].id]+=ans[q[i-1].id];
    for(int i=1;i<=m;i++)
        cout<<ans[i]<<"\n";
}
int main(){
    // cin.tie(0)->sync_with_stdio(0);
    solve();
}