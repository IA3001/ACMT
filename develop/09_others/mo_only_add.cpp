#include<bits/stdc++.h>
using namespace std;
const int N=2e5+5;
int n,m,len;
int a[N],A[N],cntA;
int getA(int v){return lower_bound(A+1,A+1+cntA,v)-A;}
struct Query{
    int id,L,R;
    bool operator<(const Query& o)const {
        // 第一关键字: L 块号
        if((L-1)/len+1!=(o.L-1)/len+1)return L<o.L;
        // 第二关键字: R (特别注意)
        return R<o.R;
    }
}q[N];
int f_fst[N];// 暴力专用
int force(int L,int R){
    int res=0;
    for(int i=L;i<=R;i++){
        if(!f_fst[a[i]])f_fst[a[i]]=i;
        else res=max(res,i-f_fst[a[i]]);
    }
    // 清空
    for(int i=L;i<=R;i++)
        f_fst[a[i]]=0;
    return res;
}
int lst[N];// 数字 i 最右侧的位置
int fst[N];// 数字 i 最左侧的位置 
int cur_ans;// 当前答案
int ans[N];
void add_l(int i){
    // cout<<"add_l:"<<i<<" "<<a[i]<<"\n";
    // 左侧 i 处进队 需要查询 lst 
    /*
    注意 fst 不需要更新 因为 fst 是用于 add_r 求答案的 
    但是 只增回滚莫队 总是先 add_r 再 add_l 之后 del_l
    所以 add_r 所遭遇的信息 总是之前的 add_r 计算出的, 与 add_l 无关 
    */
   int v=a[i];
   // 1. lst=0
   if(!lst[v])lst[v]=i;
   // 2. lst!=0
   else cur_ans=max(cur_ans,lst[v]-i);
}
void add_r(int i){
    // cout<<"add_r:"<<i<<" "<<a[i]<<"\n";
    int v=a[i];
    if(!fst[v])fst[v]=i;
    lst[v]=i;// 永远直接赋值
    cur_ans=max(cur_ans,i-fst[v]);// [艹] 原来是 i v 混了!!!!
}
// del_l 的主要功能是 用于撤回 自己由于 add_l 修改的间接答案信息 
// 需要传一个小小的 ed
void del_l(int ed,int i){
    // cout<<"del_l:"<<i<<" "<<a[i]<<"\n";
    int v=a[i];
    if(lst[v]<ed)lst[v]=0;
}
// 只增回滚莫队 del_r 是不存在的
// void del_r(int i){}

void solve(){
    cin>>n;
    len=ceil(sqrt(n));
    for(int i=1;i<=n;i++)cin>>a[i],A[++cntA]=a[i];
    sort(A+1,A+1+cntA);
    cntA=unique(A+1,A+1+cntA)-A-1;
    for(int i=1;i<=n;i++)a[i]=getA(a[i]);
    // for(int i=1;i<=n;i++){
    //     cout<<a[i]<<", ";
    // }cout<<"\n";
    cin>>m;
    for(int i=1;i<=m;i++){
        auto& [id,L,R]=q[i];
        cin>>L>>R;id=i;
    }
    sort(q+1,q+1+m);
    int qi=1,bn=(n+len-1)/len;
    for(int i=1;i<=bn;i++){
        int ed=min(n,i*len);
        // 注意这里 l,r归位 一切记录清零
        // 相当于 初始化多次 普通莫队
        int l=ed+1,r=ed;
        fill(fst,fst+1+cntA,0);
        fill(lst,lst+1+cntA,0);
        cur_ans=0;
        for(;qi<=m&&q[qi].L<=ed;qi++){
            auto[id,L,R]=q[qi];
            // cout<<"id "<<id<<" L "<<L<<" R "<<R<<"\n";
            if(R<=ed){
                // cout<<"force!\n";
                ans[id]=force(L,R);
            }else {
                // 此处 还未左扩 先右扩
                while(r<R)add_r(++r);
                int tmp_ans=cur_ans;// 存储此时的仅右扩答案
                while(L<l)add_l(--l);
                ans[id]=cur_ans;
                // cout<<"ans="<<cur_ans<<"\n";
                cur_ans=tmp_ans;// 回档
                while(l<ed+1)del_l(ed,l++);// 只增的回滚莫队 不会在 del 中更新 ans
            }
        }
    }
    for(int i=1;i<=m;i++)cout<<ans[i]<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}

