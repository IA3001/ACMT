#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N = 5e5+5,N4=N*4;
const LL inf = 1e18+7;
/*
增量法:维护最大值次大值
1 l r x 区间加
2 l r x 区间 check_min
3 l r 区间和
4 l r 区间最大值
5 l r 区间历史最大值
*/
struct JiTreeUltra{
    LL sum[N4],mx[N4],mx2[N4],tad[N4],tad2[N4],mtad[N4],mtad2[N4],hmx[N4];
    int cmx[N4];
    void up(int i){
        int l=i*2,r=l+1;
        sum[i]=sum[l]+sum[r];
        hmx[i]=max(hmx[l],hmx[r]);//
        if(mx[l]<mx[r])swap(l,r);
        mx[i]=mx[l];
        cmx[i]=cmx[l];
        if(mx[l]==mx[r]){
            cmx[i]+=cmx[r];
            mx2[i]=max(mx2[l],mx2[r]);
        }else mx2[i]=max(mx2[l],mx[r]);
    }
    void build(int i,int l,int r,LL* a){
        tad[i]=tad2[i]=mtad[i]=mtad2[i]=0;
        if(l==r){
            hmx[i]=sum[i]=mx[i]=a[l];//
            cmx[i]=1;// 
            mx2[i]=-inf;
        }else {
            int mid=(l+r)/2;
            build(i*2,l,mid,a);
            build(i*2+1,mid+1,r,a);
            up(i);
        }
    }
    void push_add(int i,int n,LL v,LL v2,LL mv,LL mv2){
        mtad[i]=max(mtad[i],tad[i]+mv);
        mtad2[i]=max(mtad2[i],tad2[i]+mv2);
        hmx[i]=max(hmx[i],mx[i]+mv);

        sum[i]+=cmx[i]*v;
        sum[i]+=(n-cmx[i])*v2;
        mx[i]+=v;
        tad[i]+=v;
        if(mx2[i]!=-inf)mx2[i]+=v2;/// ???? 不知道怎么就 WA了
        if(mx2[i]!=-inf)tad2[i]+=v2;///  ????
    }
    void down(int i,int ln,int rn){
        int l=i*2,r=i*2+1;
        LL tmp = max(mx[l],mx[r]);
        if(tad[i]){
            if(mx[l]==tmp){
                push_add(l,ln,tad[i],tad2[i],mtad[i],mtad2[i]);
            }else push_add(l,ln,tad2[i],tad2[i],mtad2[i],mtad2[i]);
            if(mx[r]==tmp){
                push_add(r,rn,tad[i],tad2[i],mtad[i],mtad2[i]);
            }else push_add(r,rn,tad2[i],tad2[i],mtad2[i],mtad2[i]);
            tad[i]=tad2[i]=mtad[i]=mtad2[i]=0;
        }
    }
    void check_min(int i,int l,int r,int jl,int jr,LL v){
        if(v>=mx[i])return;
        if(jl<=l&&r<=jr&&v>mx2[i]){
            push_add(i,r-l+1,v-mx[i],0,v-mx[i],0);
        }else {
            int mid=(l+r)/2;
            down(i,mid-l+1,r-mid);
            if(jl<=mid)check_min(i*2,l,mid,jl,jr,v);
            if(jr>mid)check_min(i*2+1,mid+1,r,jl,jr,v);
            up(i);
        }
    }
    void add(int i,int l,int r,int jl,int jr,LL v){
        if(jl<=l&&r<=jr){
            push_add(i,r-l+1,v,v,v,v);
        }else {
            int mid=(l+r)/2;
            down(i,mid-l+1,r-mid);
            if(jl<=mid)add(i*2,l,mid,jl,jr,v);
            if(jr>mid)add(i*2+1,mid+1,r,jl,jr,v);
            up(i);
        }
    }
    LL query_max(int i,int l,int r,int jl,int jr){
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
    LL query_history_max(int i,int l,int r,int jl,int jr){
        if(jl<=l&&r<=jr){
            return hmx[i];
        }else {
            int mid=(l+r)/2;
            down(i,mid-l+1,r-mid);
            LL res=-inf;
            if(jl<=mid)res=max(res,query_history_max(i*2,l,mid,jl,jr));
            if(jr>mid)res=max(res,query_history_max(i*2+1,mid+1,r,jl,jr));
            return res;
        }
    }
    LL query_sum(int i,int l,int r,int jl,int jr){
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
}T;
int n,m;
LL a[N];
void solve(){
    int op,l,r;LL x;
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>a[i];
    T.build(1,1,n,a);
    while(m--){
        cin>>op>>l>>r;
        if(op==1){
            cin>>x;
            T.add(1,1,n,l,r,x);
        }else if(op==2){
            cin>>x;
            T.check_min(1,1,n,l,r,x);
        }else if(op==3){
            cout<<T.query_sum(1,1,n,l,r)<<"\n";
        }else if(op==4){
            cout<<T.query_max(1,1,n,l,r)<<"\n";
        }else if(op==5){
            cout<<T.query_history_max(1,1,n,l,r)<<"\n";
        }
    }
}

int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}