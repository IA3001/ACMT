#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=1e5+5,B=355;
int n,m,len;
int a[N],A[N],cntA;
int getA(int v){return lower_bound(A+1,A+1+cntA,v)-A;}

// 树状数组 
struct BIT{
    int n;
    vector<int> tr;
    void init(int n){
        this->n=n+1;
        tr.assign(n+2,0);
    }
    // 区间加 O(log n)
    void add(int i,int v){for(i++;i<=n;i+=i&-i)tr[i]+=v;}
    // 单点查 O(log n)
    int query(int i){int res=0;for(i++;i;i-=i&-i)res+=tr[i];return res;}
}Tree;
// 块状数组
struct BArray{
    int n,len,bn;
    int a[N],id[N];
    int st[B],ed[B],tag[N];
    void init(int n){
        len=ceil(sqrt(n));
        bn=(n+len-1)/len;
        for(int i=1;i<=bn;i++){
            st[i]=(i-1)*len+1;
            ed[i]=min(n,st[i]+len-1);
            fill(id+st[i],id+ed[i]+1,i);
        }
        // 清空数据!!!
        fill(a,a+n+1,0);
        fill(tag,tag+1+bn,0);
    }
    // 区间加 O(sqrt(n)) 
    void add(int l,int r,int v){
        if(l>r)return;// [!? 艹 ?!] 缺少处理? ??????
        int L=id[l],R=id[r];
        if(L==R){
            for(int i=l;i<=r;i++)a[i]+=v;
        }else {
            for(int i=l;i<=ed[L];i++)a[i]+=v;
            for(int i=st[R];i<=r;i++)a[i]+=v;
            for(int i=L+1;i<=R-1;i++)tag[i]+=v;
        }
    }
    // 单点查 O(1)
    int query(int i){return a[i]+tag[id[i]];}
}Arr;

struct Query{
    int id,L,R;
    bool operator<(const Query& o)const {
        if((L-1)/len+1!=(o.L-1)/len+1)return L<o.L;
        return ((L-1)/len+1)&1?R<o.R:R>o.R;
    }
}q[N];
struct Query2{int id,L,R,op;};
vector<Query2> q2l[N],q2r[N];

// 注意 pre
LL pre[N],suf[N];
LL ans[N];

void solve(){
    cin>>n>>m;
    len=ceil(sqrt(n));
    for(int i=1;i<=n;i++)cin>>a[i],A[++cntA]=a[i];
    sort(A+1,A+1+cntA);
    cntA=unique(A+1,A+1+cntA)-A-1;
    for(int i=1;i<=n;i++)a[i]=getA(a[i]);
    for(int i=1;i<=m;i++){
        auto&[id,L,R]=q[i];
        cin>>L>>R;id=i;
    }
    sort(q+1,q+1+m);
    // 预处理信息
    Tree.init(cntA);
    for(int i=1;i<=n;i++){
        pre[i]=pre[i-1]+Tree.query(cntA)-Tree.query(a[i]);
        Tree.add(a[i],1);
    }
    Tree.init(cntA);
    for(int i=n;i>=1;i--){
        suf[i]=suf[i+1]+Tree.query(a[i]-1);
        Tree.add(a[i],1);
    }
    for(int i=1,l=1,r=0;i<=m;i++){
        auto[id,L,R]=q[i];
        if(r<R){// 右扩 右边的连续增量 - 左边的定点查询
            ans[id]+=pre[R]-pre[r];
            q2l[l-1].push_back({id,r+1,R,-1});
        }
        if(R<r){// 右缩
            ans[id]-=pre[r]-pre[R];
            q2l[l-1].push_back({id,R+1,r,1});
        }
        r=R;
        if(L<l){// 左扩 左边的增量 - 右边的定点查询 
            ans[id]+=suf[L]-suf[l];
            q2r[r+1].push_back({id,L,l-1,-1});
        }
        if(l<L){// 左缩
            ans[id]-=suf[l]-suf[L];
            q2r[r+1].push_back({id,l,L-1,1});
        }
        l=L;
    }
    // 开始二次离线
    // 先处理左边的定点查询 查询的必然是 >x 的数量
    Arr.init(cntA);
    for(int i=0;i<=n;i++){
        if(i>=1)Arr.add(1,a[i]-1,1);// 受益者必然是 < a[i] 的
        for(auto[id,L,R,op]:q2l[i])
            for(int i=L;i<=R;i++)
                ans[id]+=op*Arr.query(a[i]);
    }
    // 然后处理右边的定点查询 查询的必然是 <x 的数量
    Arr.init(cntA);
    for(int i=n+1;i>=1;i--){
        if(i<=n)Arr.add(a[i]+1,cntA,1);// 收益者必然是 > a[i] 的
        for(auto[id,L,R,op]:q2r[i])
            for(int i=L;i<=R;i++)
                ans[id]+=op*Arr.query(a[i]);
    }
    for(int i=2;i<=m;i++)ans[q[i].id]+=ans[q[i-1].id];
    for(int i=1;i<=m;i++)cout<<ans[i]<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}