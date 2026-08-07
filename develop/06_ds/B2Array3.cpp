#include<bits/stdc++.h>
using namespace std;
const int N=1e6+5;
const int B=1e3+5;
// 1 l r x [l..r] 大于 x 的数字减去 x
// 2 l r x [l..r] 查询 x 的个数
namespace B2Array{
    // 基础分块
    int n,m,len,bn;
    int a[N];
    int id[N];
    int st[B],ed[B];
    // 答案辅助
    int cnt[N],lazy,maxv,pre0[N];
    // 查询数据
    int op[N],ql[N],qr[N],qx[N],ans[N];
    void build(int nn){
        n=nn;
        len=sqrt(n);
        bn=(n+len-1)/len;
        for(int i=1;i<=bn;i++){// bn!!!
            st[i]=(i-1)*len+1;
            ed[i]=min(n,st[i]+len-1);
            fill(id+st[i],id+ed[i]+1,i);
        }
        for(int i=1;i<=n;i++)pre0[i]=pre0[i-1]+(a[i]==0);
    }
    // 并查集
    int f[N];
    int find(int x){
        return f[x]==x?x:f[x]=find(f[x]);
    }
    // 并查集 contract 结算
    void down(int l,int r){
        for(int i=l;i<=r;i++)a[i]=find(a[i]);
    }
    // 修改操作 
    void sub(int q_i,int l,int r){
        int q_l=ql[q_i],q_r=qr[q_i],q_x=qx[q_i];
        if(q_l<=l&&q_r>=r){// 整块lazy 总体 O(v)
            if(q_x>=maxv-lazy)return;// 没有影响 直接跳过保证势能 O(v)
            if(q_x*2<=maxv-lazy){
                // 较小的数 += q_x 
                // 存储状况 最大值不变
                for(int i=1+lazy;i<=q_x+lazy;i++){
                    cnt[i+q_x]+=cnt[i];
                    cnt[i]=0;
                    f[i]=f[i+q_x];
                }
                lazy+=q_x;
            }else {
                // 存储状况 最大值 -=q_x
                for(int i=maxv;i>q_x+lazy;i--){
                    cnt[i-q_x]+=cnt[i];
                    cnt[i]=0;
                    f[i]=f[i-q_x];
                }
                // maxv-=q_x;// [WC] 这里不对 你想错了 maxv 不会继承!!!
                // [!!!!!]
                // down 之后 如果没有修改 直接O(1)退出 否则总势能O(v)退出
                for(int i=maxv;i>=0;i--){
                    if(cnt[i]){
                        maxv=i;
                        break;
                    }
                }
            }
        }else {// 散块暴力 O(sqrt(n))
            down(l,r);
            for(int i=max(l,q_l);i<=min(r,q_r);i++)
                if(a[i]>q_x+lazy){
                    cnt[a[i]]--;
                    a[i]-=q_x;// [hyw] !!!!!!!!!
                    cnt[a[i]]++;
                }
            // [!!!!!]
            // down 之后 如果没有修改 直接O(1)退出 否则总势能O(v)退出
            for(int i=maxv;i>=0;i--){
                if(cnt[i]){
                    maxv=i;
                    break;
                }
            }
        }
    }
    // 查询操作 
    void query(int q_i,int l,int r){
        int q_l=ql[q_i],q_r=qr[q_i],q_x=qx[q_i];
        if(q_l<=l&&q_r>=r){// 整块 O(1)
            ans[q_i]+=cnt[q_x+lazy];
        }else {// 散块暴力O(sqrt(n))
            down(l,r);
            // down 之后 如果没有修改 直接O(1)退出 否则总势能O(v)退出
            for(int i=maxv;i>=0;i--){
                if(cnt[i]){
                    maxv=i;
                    break;
                }
            }
            for(int i=max(l,q_l);i<=min(r,q_r);i++)
                if(a[i]==q_x+lazy)ans[q_i]++;
        }
    }
    void compute(int l,int r){
        // 每一块的查询都初始化
        lazy=0;maxv=0;// lazy maxv
        iota(f,f+N,0);// f
        fill(cnt,cnt+N,0);// cnt
        // 填入 cnt maxv 
        for(int i=l;i<=r;i++)cnt[a[i]]++,maxv=max(maxv,a[i]);
        for(int i=1;i<=m;i++){
            if(op[i]==2&&qx[i]==0)continue;// 到时候
            if(ql[i]>r||qr[i]<l)continue;// 无关询问 过滤掉
            int q_i=i;
            if(op[i]==1)sub(q_i,l,r);
            else query(q_i,l,r);
        }
    }
    void solve(int mm){
        m=mm;
        for(int i=1;i<=bn;i++)compute(st[i],ed[i]);
        for(int i=1;i<=m;i++)if(op[i]==2&&qx[i]==0)
            ans[i]=pre0[qr[i]]-pre0[ql[i]-1];
    }
}using B2Array::op,B2Array::ql,B2Array::qr,B2Array::qx,B2Array::ans;
int n,m;
void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>B2Array::a[i];
    B2Array::build(n);
    // cout<<"build!\n";
    for(int i=1;i<=m;i++)cin>>op[i]>>ql[i]>>qr[i]>>qx[i];
    B2Array::solve(m);
    // cout<<"solve!\n";
    for(int i=1;i<=m;i++)
        if(op[i]==2)cout<<ans[i]<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}