/*
温馨提醒: 重排要保持稳定性 stable_sort
*/
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=8e4+5;
const LL INF=1e12;
const int mod=998244353;

// 带统计次数 的 前缀最大值 树状数组
struct BIT{
    int n;
    vector<pair<LL,int>> tr;
    void init(int n){
        this->n=n+1;
        tr=vector<pair<LL,int>>(n+2,{-INF,0});
    }
    void add(int i,LL v,int c){
        c%=mod;
        for(i++;i<=n;i+=i&-i)
            if(v>tr[i].first)tr[i]={v,c};
            else if(v==tr[i].first)(tr[i].second+=c)%=mod;// 注意取模
    }
    pair<LL,int> query(int i){
        pair<LL,int> res={-INF,0};
        for(i++;i;i-=i&-i)
            if(tr[i].first>res.first)res=tr[i];
            else if(tr[i].first==res.first)(res.second+=tr[i].second)%=mod;// 注意取模
        return res;
    }
    void erase(int i){// [突然发现] 这里必须单独设置一个 才行
        for(i++;i<=n;i+=i&-i)tr[i]={-INF,0};
    }
}T;

LL f[N];
int cnt[N];

struct Query{
    int id,a,b,c,d;
    LL v;
    bool left;
}q[N],q2[N];

// 注意!!! merge2 是基于 q2进行操作的!!!
// merge2 本质上是 "有 标签指导的 3维偏序"
// merge2 在贴有序标签(a)的前提下 已经有一个有序(b)分隔 重排序(c) 查询(d)范围内的 最大值 即可
void merge2(int l,int mid,int r){
    // cdq_dp merge 时, "先重排序"
    stable_sort(q2+l,q2+mid+1,[](const Query&a,const Query& b){return a.c<b.c;});
    stable_sort(q2+mid+1,q2+r+1,[](const Query&a,const Query& b){return a.c<b.c;});
    int L,R;
    for(L=l,R=mid+1;R<=r;R++){
        while(L<=mid&&q2[L].c<=q2[R].c){// 题目说的是 <=
            // 必须是左边 才能增加
            if(q2[L].left)T.add(q2[L].d,f[q2[L].id],cnt[q2[L].id]);// [!!!] 用 cnt 不是 1 !!!
            L++;
        }
        if(!q2[R].left){// 必须是右边 才能接收
            auto[v,c] = T.query(q2[R].d);// 题目说的是 <=
            if(v+q2[R].v>f[q2[R].id]){
                f[q2[R].id]=v+q2[R].v;// 注意 合并答案的时候 请选择自己
                cnt[q2[R].id]=c;// 自己这里显然 *1
            }else if(v+q2[R].v==f[q2[R].id])(cnt[q2[R].id]+=c)%=mod;// 注意取模
        }
    }
    // 清空!!! // 优化: [l,L)
    for(int i=l;i<L;i++)
        if(q2[i].left)T.erase(q2[i].d);
}
void cdq2(int l,int r){
    if(l==r)return;
    int mid=(l+r)/2;
    cdq2(l,mid);// 左递归
    cdq2(mid+1,r);// 右递归
    // [!!!!] 这里不是推 DP 啊啊啊 这是计算偏序对啊啊啊
    // [!!!!] 这里不是推 DP 啊啊啊 这是计算偏序对啊啊啊
    // [!!!!] 这里不是推 DP 啊啊啊 这是计算偏序对啊啊啊
    merge2(l,mid,r);// 中间 真·3.5维偏序
}
// merge1 是专门贴标签的 左/右 
void merge1(int l,int mid,int r){
    // // for(int i=l;i<=r;i++)q[i].left=i<=mid;// 标记左侧 一定要全部遍历 要不然有残留 
    memcpy(q2+l,q+l,sizeof(q[0])*(r-l+1));// 拷贝!!!
    // !!! 题目说的必然是 <= 要不然 这里怎么会随意设置 left(可能切割a相同的值)
    for(int i=l;i<=mid;i++)q2[i].left=true;// 标记左侧 但是这里是 q2 不必考虑残留
    // "第二维排序" 要满足a的前提稳定!!! 肯定是 <= 
    stable_sort(q2+l,q2+r+1,[](const Query& a,const Query& b){return a.b<b.b;});
    // 调用 cdq2 进行4维偏序转移计算答案
    cdq2(l,r);
}
// 入口
void cdq1(int l,int r){
    if(l==r)return;
    int mid=(l+r)/2;
    cdq1(l,mid);// 先解决左边
    // 这里才是 推 DP!!!
    // 这里才是 推 DP!!!
    // 这里才是 推 DP!!!
    merge1(l,mid,r);// 加个标签 启动4维!!!
    cdq1(mid+1,r);// 再解决右边
}
int n,m;
int D[N],cntD;
int getD(int v){return lower_bound(D+1,D+1+cntD,v)-D;}
void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++){
        auto&[id,a,b,c,d,v,_]=q[i];
        cin>>a>>b>>c>>d>>v;
        D[++cntD]=d;
    }
    // [啊啊啊 注意用到数据结构索引的那一维 离散化]
    // [啊啊啊 注意用到数据结构索引的那一维 离散化]
    // [啊啊啊 注意用到数据结构索引的那一维 离散化]
    sort(D+1,D+1+cntD);
    cntD=unique(D+1,D+1+cntD)-D-1;
    for(int i=1;i<=n;i++)q[i].d=getD(q[i].d);
    // 沟槽的 去重合并
    sort(q+1,q+1+n,[](const Query&a,const Query& b){return a.a!=b.a?a.a<b.a:a.b!=b.b?a.b<b.b:a.c!=b.c?a.c<b.c:a.d<b.d;});
    int tn=1;
    for(int i=2;i<=n;i++){
        if(q[i].a==q[tn].a&&q[i].b==q[tn].b&&q[i].c==q[tn].c&&q[i].d==q[tn].d)q[tn].v+=q[i].v;
        else q[++tn]=q[i];
    }
    n=tn;
    for(int i=1;i<=n;i++){
        q[i].id=i;
        f[i]=q[i].v;// [必须] 初始化 dp 值!!!
        cnt[i]=1;// [!!!] cnt 差点忘了!!!
    }
    // "第一维排序" 其实已经排过了 
    // sort(q+1,q+1+n,[](const Query&a,const Query& b){return a.a<b.a;});
    T.init(cntD);// 忘了 init 了 !!!!!! 这个 m 还真的有用!?!
    cdq1(1,n);
    int ans=0;
    LL mx=*max_element(f+1,f+1+n);
    for(int i=1;i<=n;i++)
        if(f[i]==mx)ans=(ans+cnt[i])%mod;
    cout<<mx<<"\n"<<ans<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}