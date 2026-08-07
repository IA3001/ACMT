#include<bits/stdc++.h>
using namespace std;
const int N=2e5+5;

int n,m;
int a[N],A[N],cntA;
int getA(int v){return lower_bound(A+1,A+1+cntA,v)-A;}

// 简单的 "位值" 树状数组 [因为有 pos 优化, 不必要可以写 clear]
struct BIT{
    int n;
    vector<int> tr;
    void init(int n){
        // [!!!] n+1 与 n+2 !!!!!!
        this->n=n+1;// 一个是位移 一个是右开
        tr.assign(n+2,0);
    }
    void add(int i,int v){for(i++;i<=n;i+=i&-i)tr[i]+=v;}
    int query(int i){int res=0;for(i++;i;i-=i&-i)res+=tr[i];return res;}// Q !!!
}T;

// [操作] 定义
struct Query{
    int l,r,k;
}Q[N];// Q[i] 表示编号为 i 的询问 // 已经用q,ql,qr 了, 万年不变
int q[N],ql[N],qr[N];
// 维护分治中心 pos
int pos;// 右端点 为 n
// A 列表 <val,idx>
array<int,2> A_list[N];
// 答案
int ans[N];

// 当前答案范围来到 [vl..vr] 回答 q[jl..jr] "号"对应的询问 
void pbinary(int vl,int vr,int jl,int jr){
    if(jl>jr)return;
    if(vl==vr){
        for(int i=jl;i<=jr;i++)ans[q[i]]=vl;
        return;
    }
    int vm=(vl+vr)/2;
    // 维护分治中心
    while(pos+1<=n&&A_list[pos+1][0]<=vm)T.add(A_list[++pos][1],1);
    while(pos>=1&&A_list[pos][0]>vm)T.add(A_list[pos--][1],-1);
    int cntl=0,cntr=0;// [[[艹艹艹艹艹艹艹艹艹艹艹艹艹艹艹艹]]]
    for(int i=jl;i<=jr;i++){
        // 注意 不应修改询问信息
        // 注意 不应修改询问信息
        // 注意 不应修改询问信息
        auto [l,r,k]=Q[q[i]];// [!!!] 注意 这里一定 """不""" 要引用 k !!!!!!
        int tk=T.query(r)-T.query(l-1);
        // cout<<q[i]<<":"<<tk<<"\n";
        if(k<=tk)ql[++cntl]=q[i];
        else qr[++cntr]=q[i];
    }
    memcpy(q+jl,ql+1,sizeof(q[0])*cntl);
    memcpy(q+jl+cntl,qr+1,sizeof(q[0])*cntr);
    pbinary(vl,vm,jl,jl+cntl-1);
    pbinary(vm+1,vr,jl+cntl,jr);
}

void solve(){
    // 标准离散化
    cin>>n>>m;cntA=n;
    for(int i=1;i<=n;i++)cin>>a[i];
    memcpy(A,a,sizeof(a[0])*(n+1));
    sort(A+1,A+1+cntA);
    cntA = unique(A+1,A+1+cntA)-A-1;
    // 为了维护分治中心 pos 计算 _list 二元<值,索引>对
    for(int i=1;i<=n;i++)A_list[i]={getA(a[i]),i};
    sort(A_list+1,A_list+1+n);
    // 标准读入询问
    for(int i=1;i<=m;i++){
        auto&[l,r,k]=Q[i];
        cin>>l>>r>>k;
    }
    // 初始化 n 个位置
    T.init(n);
    // 可能的优化: 只使用查询编号
    iota(q,q+1+m,0);
    pos=0;
    pbinary(1,cntA,1,m);
    for(int i=1;i<=m;i++)cout<<A[ans[i]]<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();    
}