#include<bits/stdc++.h>
using namespace std;
const int N=1e5+5;
struct BIT{
    int n;
    vector<int> tr;
    void init(int n){
        this->n=n+1;
        tr.assign(n+2,0);
    }
    void add(int i,int v){for(i++;i<=n;i+=i&-i)tr[i]+=v;}
    int query(int i){int res=0;for(i++;i;i-=i&-i)res+=tr[i];return res;}
    void erase(int i){for(i++;i<=n;i+=i&-i)tr[i]=0;}// 简单的清除
}T;
int p[N];
int n,m;
// 这里不必要记录时间了,因为第一维就是时间,天然排序了
// 注意只有两种操作 op=1 or op=-1 只有两种id 0 和非0 0相当于总贡献 非0相当于删除者的贡献
struct Query{
    int id,op,x,v;// op+=1 对应的操作 对全局逆序对的贡献 算到 ans[id] 里去!!!
}q[N*2];
int cntq;
int64_t ans[N*2];// 开 i64 !!!
void merge(int l,int mid,int r){
    // 现在 [l,mid] [mid+1,r] 两段已经按照 v 排好序
    // 因为要保证时间顺序 所以需要 枚举右v 1. 查找左>v中记录<x数量 2.查找左<v中记录>x数量 
    // 显然按照的是 v 排序 p2 跟着 p1 保持 p2的v<=p1的v 向树状数组中插入 x, 
    // 比右边大 在前面
    for(int R=r,L=mid;R>=mid+1;R--){
        while(L>=l&&q[L].v>q[R].v){
            T.add(q[L].x,q[L].op);
            L--;
        }
        ans[q[R].id]+=T.query(q[R].x-1)*q[R].op;
    }
    // 清空!!!
    for(int i=l;i<=mid;i++)T.erase(q[i].x);
    // 比右边小 在后面
    for(int R=mid+1,L=l;R<=r;R++){// [???] 你怎么写成的 L=1 ???
        while(L<=mid&&q[L].v<q[R].v){
            T.add(q[L].x,q[L].op);
            L++;
        }
        ans[q[R].id]+=(T.query(n)-T.query(q[R].x))*q[R].op;
    }
    // 清空!!!
    for(int i=l;i<=mid;i++)T.erase(q[i].x);
    // merge 后才总体sort
    sort(q+l,q+r+1,[](const Query& a,const Query& b){return a.v<b.v;});
}
void cdq(int l,int r){
    if(l==r)return;
    int mid=(l+r)/2;
    cdq(l,mid);
    cdq(mid+1,r);
    merge(l,mid,r);
}
void solve(){
    cin>>n>>m;
    T.init(n);
    for(int i=1,a;i<=n;i++)cin>>a,p[a]=i,q[++cntq]={0,1,i,a};
    for(int i=1,a;i<=m;i++){
        cin>>a;
        q[++cntq]={i,-1,p[a],a};
    }
    cdq(1,cntq);
    for(int i=1;i<=m;i++){
        ans[i]+=ans[i-1];
        cout<<ans[i-1]<<"\n";
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}