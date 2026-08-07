#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=3e5+5;
const int B=605;
const int OFFSET=10;
const int BASE=1<<OFFSET;
const int MASK=BASE-1;
// op==1 x 位置改为 y
// op==2 [l..r] 区间内有多少值小于 x
namespace B2Array{
    // 基础分块
    int n,m,len,bn;
    int a[N];
    int id[N];
    int st[B],ed[B];
    // 整块求解辅助
    int pos[N],prev[N],next[N];
    // 基数排序辅助
    int cnt[BASE],help[N];
    // 查询: 只能散着来了 !!!
    int qid[N],op[N],qx[N],qy[N],ql[N],qr[N];
    int pre[N],suf[N];LL ans[N];
    void build(int nn){
        n=nn;
        len=sqrt(n);
        bn=(n+len-1)/len;
        for(int i=1;i<=bn;i++){
            st[i]=(i-1)*len+1;
            ed[i]=min(n,st[i]+len-1);
            fill(id+st[i],id+ed[i]+1,i);
        }
    }
    // 将索引 idx 按照 key[idx] 大小排序 
    void radix(int* idx,int* key,int l,int r){
        // [特别特别特别注意]
        // 前提要保证 OFFSET*len 的位数覆盖了 key[] 的值域
        // 否则 请保证 最后的一趟排序 不取 MASK(cnt[]要适当开大) 
        for(int d=0;d<OFFSET*2;d+=OFFSET){
            fill(cnt,cnt+BASE,0);
            for(int i=l;i<=r;i++)cnt[key[idx[i]]>>d&MASK]++;
            for(int i=1;i<BASE;i++)cnt[i]+=cnt[i-1];// BASE !!!!
            for(int i=r;i>=l;i--)help[cnt[key[idx[i]]>>d&MASK]--]=idx[i];
            memcpy(idx+l,help+1,sizeof(idx[0])*(r-l+1));
        }
    }
    // 暴力 计算 l r 范围内的 信息
    void calc(int l,int r,int x,LL& q_ans,int& q_pre,int& q_suf,int& q_sz){
        q_ans=q_pre=q_suf=q_sz=0;
        int cn=0;
        for(int i=l;i<=r;i++){
            if(a[i]<=x)q_ans+=++cn;
            else cn=0;
        }
        while(l+q_pre<=r&&a[l+q_pre]<=x)q_pre++;
        while(r-q_suf>=l&&a[r-q_suf]<=x)q_suf++;
        q_sz=r-l+1;
    }
    // 按块 将若干信息合并到 q_id 上去
    void merge(int q_id,LL q_ans,int q_pre,int q_suf,int q_sz){
        ans[q_id]+=q_ans+suf[q_id]*q_pre;
        suf[q_id]=q_suf+(q_suf==q_sz?suf[q_id]:0);
    }
    int buf[N];
    void compute(int l,int r){
        int tp=0;
        // 筛选相关操作 
        for(int i=1;i<=m;i++){
            if(op[qid[i]]==1){
                if(qx[qid[i]]>=l&&qx[qid[i]]<=r)buf[++tp]=qid[i];
            }else if(ql[qid[i]]<=r&&qr[qid[i]]>=l)buf[++tp]=qid[i];
        }
        // 开工
        for(int i=1;i<=tp;i++){
            if(op[buf[i]]==1){
                // 暴力更新
                a[qx[buf[i]]]=qy[buf[i]];
            }else {
                int s=i;
                while(i<=tp&&op[buf[i]]==2)i++;
                i--;
                // 收割
                // 构建链表
                for(int j=l-1;j<=r+1;j++){
                    pos[j]=j;
                    prev[j]=j-1;
                    next[j]=j+1;
                }
                // 逐个启用
                radix(pos,a,l,r);
                // 询问从小到大
                radix(buf,qx,s,i);
                int cur_pre=0,cur_suf=0,cur_sz=(r-l+1);LL cur_ans=0;
                int p=l;
                for(int j=s;j<=i;j++){
                    int q_id=buf[j];
                    if(ql[q_id]<=l&&r<=qr[q_id]){
                        // 全包 正常处理
                        while(p<=r&&a[pos[p]]<=qx[q_id]){
                            cur_ans+=(pos[p]-prev[pos[p]])*(next[pos[p]]-pos[p]);
                            prev[next[pos[p]]]=prev[pos[p]];
                            next[prev[pos[p]]]=next[pos[p]];
                            cur_pre=next[l-1]-l;// 
                            cur_suf=r-prev[r+1];// 
                            p++;
                        }
                        merge(q_id,cur_ans,cur_pre,cur_suf,cur_sz);
                    }else {
                        // 散块 立即暴力
                        int q_pre,q_suf,q_sz;LL q_ans;
                        calc(max(l,ql[q_id]),min(r,qr[q_id]),qx[q_id],q_ans,q_pre,q_suf,q_sz);
                        merge(q_id,q_ans,q_pre,q_suf,q_sz);
                    }
                }
            }
        }
    }
    void solve(int mm){
        m=mm;
        for(int i=1;i<=bn;i++)compute(st[i],ed[i]);
    }
}using B2Array::qid,B2Array::ql,B2Array::qr,B2Array::qx,B2Array::qy,B2Array::op;
int n,m;
void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>B2Array::a[i];
    B2Array::build(n);
    for(int i=1;i<=m;i++){
        cin>>op[i];
        qid[i]=i;// [!!!]
        if(op[i]==1)cin>>qx[i]>>qy[i];
        else cin>>ql[i]>>qr[i]>>qx[i];
    }
    B2Array::solve(m);
    for(int i=1;i<=m;i++)
        if(op[i]==2)cout<<B2Array::ans[i]<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}