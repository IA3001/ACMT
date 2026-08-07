/* Coding 体验最差的一集: 洛谷评测机 神人扰动 */
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=5e5+5,V=5e5+1;
int MX,sMX;// 变常量

int n,m,len;
int a[N];

vector<int> factors[V];
void calc(int i){
    // 随取随用 ??? why ???
    if(factors[i].empty()){
        int ed=sqrt(i);
        for(int j=1;j<=ed;j++){
            if(i%j==0){
                factors[i].push_back(j);
                if(j!=i/j)factors[i].push_back(i/j);
            }
        }
    }
}

struct Query{
    int id,L,R;
    bool operator<(const Query& o)const {
        if((L-1)/len+1!=(o.L-1)/len+1)return L<o.L;
        return ((L-1)/len+1)&1?R<o.R:R>o.R;
    }
}q[N];

// 链式前向星虽然 NB 但是 如果你这样同样可以 得到相近的 效率 
// emplace_back 不NB 事实上
struct Query23{
    int id,L,R,op,x;
    // Query23(int ii=0,int LL=0,int RR=0,int oo=0,int xx=0):id(ii),L(LL),R(RR),op(oo),x(xx){}
};
vector<Query23> q23[N],Q;// 虽然这里需要 二倍的空间

LL ans[N];
int cnt_ge[V];// v 命中的 倍数个数
int cntv[V];// 前缀词频统计 (枚举因子)
LL pre[N];// 前缀统计量

void solve(){
    cin>>n>>m;
    len=ceil(sqrt(n));
    for(int i=1;i<=n;i++)cin>>a[i];
    MX=*max_element(a+1,a+1+n);
    // sMX=ceil(sqrt(MX));// 不行啊
    sMX=100;// AC
    for(int i=1;i<=m;i++){
        auto&[id,L,R]=q[i];
        cin>>L>>R;id=i;
    }
    sort(q+1,q+1+m);
    // 预处理:
    for(int i=1;i<=n;i++){
        pre[i]=pre[i-1]+cnt_ge[a[i]];
        calc(a[i]);// !!!
        for(auto v:factors[a[i]]){
            pre[i]+=cntv[v];// 自己命中的前缀因子个数
            cnt_ge[v]++;// 为后续布置倍数统计
        }
        cntv[a[i]]++;// 为后续布置词频
    }
    for(int i=1,l=1,r=0;i<=m;i++){
        const auto& [id,L,R]=q[i];
        if(r<R){// 右扩
            ans[id]+=pre[R]-pre[r];
            q23[l-1].push_back({id,r+1,R,-1,l-1});
            Q.push_back({id,r+1,R,-1,l-1});
        }else if(R<r){// 右缩
            ans[id]-=pre[r]-pre[R];
            q23[l-1].push_back({id,R+1,r,1,l-1});
            Q.push_back({id,R+1,r,1,l-1});
        }
        r=R;
        if(L<l){// 左扩
            q23[r].push_back({id,L,l-1,1,r});
            Q.push_back({id,L,l-1,1,r});
            ans[id]-=pre[l-1]-pre[L-1]+2*(l-1-L+1);
        }else if(l<L){// 左缩
            q23[r].push_back({id,l,L-1,-1,r});
            Q.push_back({id,l,L-1,-1,r});
            ans[id]+=pre[L-1]-pre[l-1]+2*(L-1-l+1);
        }
        l=L;
    }
    // 开始二次离线
    // 重置
    fill(cntv,cntv+MX+1,0);
    for(int i=0;i<=n;i++){
        if(i>=1){
            // 为后续布置倍数
            calc(a[i]);// !!!
            for(const auto& v:factors[a[i]])cntv[v]++;
            // 为后续布置大因子 此处的 cntv[v] 表示 v 命中的因子个数
            if(a[i]>sMX)
                // [艹] 遮沙避风!!!!
                for(int j=a[i];j<=MX;j+=a[i])
                    cntv[j]++;
            }
            // [!!!] 啊啊啊
            for(const auto& [id,L,R,op,x]:q23[i]){
                for(int k=L;k<=R;k++)// [艹] 忘了写这个 for [L,R] 了 !!!
                    ans[id]+=op*cntv[a[k]];// 二合一 !!!
            }
    }
    // 开始三次离线
    // 枚举 v
    for(int v=1;v<=sMX;v++){
        int cnt=0;
        // 预处理 前缀 v 的倍数的个数
        for(int i=1;i<=n;i++){
            pre[i]=pre[i-1]+(a[i]%v==0);
            cntv[i]=cntv[i-1]+(a[i]==v);
        }
        // 开始滚动
        for(const auto& [id,L,R,op,x]:Q)
            ans[id]+=(LL)op*cntv[x]*(pre[R]-pre[L-1]);
    }
    for(int i=2;i<=m;i++)ans[q[i].id]+=ans[q[i-1].id];
    for(int i=1;i<=m;i++)ans[q[i].id]+=q[i].R-q[i].L+1;
    for(int i=1;i<=m;i++)cout<<ans[i]<<"\n";
}
int main(){
    // for(int i=1;i<V;i++)calc(i);// 服了 !!! 我全部预处理竟然 TLE ???
    cin.tie(0)->sync_with_stdio(0);
    solve();
}