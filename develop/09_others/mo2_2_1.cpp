#include<bits/stdc++.h>
using namespace std;
const int N=5e5+5,B=740,V=1e5+1;
using LL = long long;
int n,m,len;
int a[N];

struct BIT{
    int n;
    vector<LL> tr;
    void init(int n){
        this->n=n+1;
        tr.assign(n+2,0);
    }
    void add(int i,LL v){for(i++;i<=n;i+=i&-i)tr[i]+=v;}
    LL query(int i){LL res=0;for(i++;i;i-=i&-i)res+=tr[i];return res;}
}Tcnt,Tsum;
struct BArray{
    int n,len,bn;
    LL a[N];
    int id[N];
    int st[B],ed[B];
    LL tag[B];
    void init(int n){
        this->n=n;
        len=ceil(sqrt(n));
        bn=(n+len-1)/len;
        for(int i=1;i<=bn;i++){
            st[i]=(i-1)*len+1;
            ed[i]=min(n,st[i]+len-1);
            fill(id+st[i],id+ed[i]+1,i);
        }
        fill(a,a+1+n,0);
        fill(tag,tag+1+bn,0);
    }
    void add(int l,int r,LL v){
        if(l>r)return;// 有阴影了 !!!!!!!!!!!!!!!
        int L=id[l],R=id[r];
        if(L==R){
            for(int i=l;i<=r;i++)a[i]+=v;
        }else {
            for(int i=l;i<=ed[L];i++)a[i]+=v;
            for(int i=st[R];i<=r;i++)a[i]+=v;
            for(int i=L+1;i<=R-1;i++)tag[i]+=v;
        }
    }
    LL query(int i){return a[i]+tag[id[i]];}
}Acnt,Asum;

struct Query{
    int id,L,R;
    bool operator<(const Query& o)const {
        if((L-1)/len+1!=(o.L-1)/len+1)return L<o.L;
        return ((L-1)/len+1)&1?R<o.R:R>o.R;
    }
}q[N];
struct Query2{int id,L,R,op;};
vector<Query2> q2[N];
LL pre_a[N];
LL pre[N];
LL ans[N];
void solve(){
    cin>>n>>m;
    len=ceil(sqrt(n));
    for(int i=1;i<=n;i++)cin>>a[i],pre_a[i]=pre_a[i-1]+a[i];
    for(int i=1;i<=m;i++){
        auto&[id,L,R]=q[i];
        cin>>L>>R;id=i;
    }
    sort(q+1,q+1+m);
    // 预处理信息
    Tcnt.init(V);Tsum.init(V);
    for(int i=1;i<=n;i++){
        pre[i]=pre[i-1]+(Tsum.query(V)-Tsum.query(a[i]))+(Tcnt.query(a[i]-1)+0)*a[i];
        Tsum.add(a[i],a[i]);
        Tcnt.add(a[i],1);
    }
    // 开始莫队一次
    for(int i=1,l=1,r=0;i<=m;i++){
        auto[id,L,R]=q[i];
        if(r<R){// 右扩 
            ans[id]+=pre[R]-pre[r];
            q2[l-1].push_back({id,r+1,R,-1});
        }
        if(R<r){// 右缩
            ans[id]-=pre[r]-pre[R];
            q2[l-1].push_back({id,R+1,r,1});
        }
        r=R;// 勿忘!!!!
        if(L<l){// 左扩
            q2[r].push_back({id,L,l-1,1});
            ans[id]-=pre[l-1]-pre[L-1];
        }
        if(l<L){
            q2[r].push_back({id,l,L-1,-1});
            ans[id]+=pre[L-1]-pre[l-1];
        }
        l=L;// 勿忘!!!!
    }
    // 开始莫队二次
    Asum.init(V);Acnt.init(V);
    for(int i=0;i<=n;i++){
        if(i>=1){
            Asum.add(1,a[i]-1,a[i]);
            Acnt.add(a[i]+1,V,1);
        }
        for(auto [id,L,R,op]:q2[i])
            for(int i=L;i<=R;i++)
                ans[id]+=op*(Asum.query(a[i])+(Acnt.query(a[i])+0)*a[i]);
    }
    for(int i=2;i<=m;i++)ans[q[i].id]+=ans[q[i-1].id];

    /*
        [!!!] 夭寿了 计算式中的常系数 在做差分时 会被消掉 
        需要在最终的计算结果补上常系数
    */
    for(int i=1;i<=m;i++){
        auto[id,L,R]=q[i];
        ans[id]+=pre_a[R]-pre_a[L-1];
    }
    for(int i=1;i<=m;i++)cout<<ans[i]<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}