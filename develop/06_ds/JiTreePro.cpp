#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N = 5e5+5,N4=N*4;
const int inf = 1e9+7;
/*
1 l r x 区间加 x
2 l r x 区间 check_max
3 l r x 区间 check_min
4 l r 区间和
5 l r 区间 max
6 l r 区间 min
*/
struct JiTreePro{
    LL sum[N4];
    int cmx[N4],cmn[N4];
    LL mx[N4],mx2[N4],tmn[N4];
    LL mn[N4],mn2[N4],tmx[N4];
    LL tad[N4];// 确实啊啊啊 xx2 cxx txx 确实好用
    void up(int i){
        int l=i*2,r=l+1;
        sum[i]=sum[l]+sum[r];
        
        if(mx[l]<mx[r])swap(l,r);
        mx[i]=mx[l];
        cmx[i]=cmx[l];
        if(mx[l]==mx[r]){
            cmx[i]+=cmx[r];
            mx2[i]=max(mx2[l],mx2[r]);
        }else mx2[i]=max(mx2[l],mx[r]);
        
        if(mn[l]>mn[r])swap(l,r);
        mn[i]=mn[l];
        cmn[i]=cmn[l];
        if(mn[l]==mn[r]){
            cmn[i]+=cmn[r];
            mn2[i]=min(mn2[l],mn2[r]);
        }else mn2[i]=min(mn2[l],mn[r]);
    }
    void build(int i,int l,int r,LL* a){
        tmx[i]=-inf;tmn[i]=inf;tad[i]=0;
        if(l==r){
            mx[i]=mn[i]=sum[i]=a[l];
            mx2[i]=-inf;
            mn2[i]=inf;
            cmx[i]=cmn[i]=1;
        }else {
            int mid=(l+r)/2;
            build(i*2,l,mid,a);
            build(i*2+1,mid+1,r,a);
            up(i);
        }
    }
    void push_add(int i,int n,LL v){
        sum[i]+=n*v;
        mx[i]+=v;
        mn[i]+=v;
        // 便利的同时也要注意 
        if(mx2[i]!=-inf)mx2[i]+=v;
        if(mn2[i]!=inf)mn2[i]+=v;
        // 这两个更不能忘了: 绝对不能改变 inf -inf 
        if(tmx[i]!=-inf)tmx[i]+=v;
        if(tmn[i]!=inf)tmn[i]+=v;
        tad[i]+=v;
    }
    void push_min(int i,LL v){
        if(v>=mx[i])return;
        sum[i]+=(LL)cmx[i]*(v-mx[i]);
        // 【在这里转了好久】
        // 【重点重点重点】 保证所有的旧数据都更新
        // 极端情况: 全员取 min
        if(mn[i]==mx[i])mn[i]=v;// mn mn2 互斥
        else if(mn2[i]==mx[i])mn2[i]=v;//
        tmx[i]=min(tmx[i],v);// tag 永远跟随
        mx[i]=tmn[i]=v;
    }
    void push_max(int i,LL v){
        if(v<=mn[i])return;
        sum[i]+=(LL)cmn[i]*(v-mn[i]);
        // 【在这里转了好久】
        // 【重点重点重点】 保证所有的旧数据都更新
        // 极端情况: 全员取 max
        if(mx[i]==mn[i])mx[i]=v;// mx mx2 互斥
        else if(mx2[i]==mn[i])mx2[i]=v;// 
        tmn[i]=max(tmn[i],v);// tag 永远跟随
        mn[i]=tmx[i]=v;
    }
    void down(int i,int ln,int rn){
        if(tad[i]){
            push_add(i*2,ln,tad[i]);
            push_add(i*2+1,rn,tad[i]);
            tad[i]=0;
        }
        if(tmn[i]!=inf){
            push_min(i*2,tmn[i]);
            push_min(i*2+1,tmn[i]);
            tmn[i]=inf;
        }
        if(tmx[i]!=-inf){
            push_max(i*2,tmx[i]);
            push_max(i*2+1,tmx[i]);
            tmx[i]=-inf;
        }
    }
    void add(int i,int l,int r,int jl,int jr,LL v){
        if(l>r)return;
        if(jl<=l&&r<=jr){
            push_add(i,r-l+1,v);
        }else {
            int mid=(l+r)/2;
            down(i,mid-l+1,r-mid);
            if(jl<=mid)add(i*2,l,mid,jl,jr,v);
            if(jr>mid)add(i*2+1,mid+1,r,jl,jr,v);
            up(i);
        }
    }
    void check_min(int i,int l,int r,int jl,int jr,LL v){
        if(l>r||v>=mx[i])return;
        if(jl<=l&&r<=jr&&v>mx2[i]){
            push_min(i,v);
        }else {
            int mid=(l+r)/2;
            down(i,mid-l+1,r-mid);
            if(jl<=mid)check_min(i*2,l,mid,jl,jr,v);
            if(jr>mid)check_min(i*2+1,mid+1,r,jl,jr,v);
            up(i);
        }
    }
    void check_max(int i,int l,int r,int jl,int jr,LL v){
        if(l>r||v<=mn[i])return;
        if(jl<=l&&r<=jr&&v<mn2[i]){
            push_max(i,v);
        }else {
            int mid=(l+r)/2;
            down(i,mid-l+1,r-mid);
            if(jl<=mid)check_max(i*2,l,mid,jl,jr,v);
            if(jr>mid)check_max(i*2+1,mid+1,r,jl,jr,v);
            up(i);
        }
    }
    LL query_sum(int i,int l,int r,int jl,int jr){
        if(l>r)return 0;
        if(jl<=l&&r<=jr){
            return sum[i];
        }else {
            int mid=(l+r)/2;
            down(i,mid-l+1,r-mid);
            LL res=0;
            if(jl<=mid)res+=query_sum(i*2,l,mid,jl,jr);
            if(jr>mid)res+=query_sum(i*2+1,mid+1,r,jl,jr);
            return res;
        }
    }
    LL query_max(int i,int l,int r,int jl,int jr){
        if(l>r)return -inf;
        if(jl<=l&&r<=jr){
            return mx[i];
        }else {
            int mid=(l+r)/2;
            down(i,mid-l+1,r-mid);
            LL res=-inf;
            if(jl<=mid)res=max(res,query_max(i*2,l,mid,jl,jr));
            if(jr>mid)res=max(res,query_max(i*2+1,mid+1,r,jl,jr));
            return res;
        }
    }
    LL query_min(int i,int l,int r,int jl,int jr){
        if(l>r)return inf;
        if(jl<=l&&r<=jr){
            return mn[i];
        }else {
            int mid=(l+r)/2;
            down(i,mid-l+1,r-mid);
            LL res=inf;
            if(jl<=mid)res=min(res,query_min(i*2,l,mid,jl,jr));
            if(jr>mid)res=min(res,query_min(i*2+1,mid+1,r,jl,jr));
            return res;
        }
    }
}T;
int n,m;
LL a[N];
int main(){
    cin.tie(0)->sync_with_stdio(0);
    cin>>n;
    for(int i=1;i<=n;i++)cin>>a[i];
    T.build(1,1,n,a);    
    cin>>m;
    while(m--){
        int op,l,r;LL x;
        cin>>op>>l>>r;
        if(op==1){
            cin>>x;
            T.add(1,1,n,l,r,x);
        }else if(op==2){
            cin>>x;
            T.check_max(1,1,n,l,r,x);
        }else if(op==3){
            cin>>x;
            T.check_min(1,1,n,l,r,x);
        }else if(op==4){
            cout<<T.query_sum(1,1,n,l,r)<<"\n";
        }else if(op==5){
            cout<<T.query_max(1,1,n,l,r)<<"\n";
        }else {
            cout<<T.query_min(1,1,n,l,r)<<"\n";
        }
    }
}