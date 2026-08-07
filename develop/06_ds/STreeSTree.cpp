#include<bits/stdc++.h>
using namespace std;
const int N=102,M=1002;
struct STree{
    int f[M*4];
    void up(int i){f[i]=max(f[i*2],f[i*2+1]);}
    void build(int i,int l,int r){
        if(l==r){
            f[i]=-9;
        }else { 
            int mid=(l+r)/2;
            build(i*2,l,mid);
            build(i*2+1,mid+1,r);
            up(i);
        }
    }
    void set(int i,int l,int r,int p,int v){
        if(l==r){
            f[i]=v;// 这里小巧思
        }else {
            int mid=(l+r)/2;
            if(p<=mid)set(i*2,l,mid,p,v);
            else set(i*2+1,mid+1,r,p,v);
            up(i);
        }
    }
    int query_max(int i,int l,int r,int jl,int jr){
        if(jl<=l&&r<=jr){
            return f[i];
        }else {
            int mid=(l+r)/2;
            int res=-9;
            if(jl<=mid)res=max(res,query_max(i*2,l,mid,jl,jr));
            if(jr>mid)res=max(res,query_max(i*2+1,mid+1,r,jl,jr));
            return res;
        }
    }
};

struct STreeSTree{
    int m;
    STree f[N*4];
    void init(int n,int m){
        this->m=m;
        build(1,1,n);
    }
    void build(int i,int l,int r){
        f[i].build(1,1,m);
        if(l==r){

        }else {
            int mid=(l+r)/2;
            build(i*2,l,mid);
            build(i*2+1,mid+1,r);
        }
    }
    void set(int i,int l,int r,int jp,int kp,int v){
        if(f[i].query_max(1,1,m,kp,kp)<v)// 啊 我的我的我的
            f[i].set(1,1,m,kp,v);
        if(l==r){

        }else {
            int mid=(l+r)/2;
            if(jp<=mid)set(i*2,l,mid,jp,kp,v);
            else set(i*2+1,mid+1,r,jp,kp,v);
        }
    }
    int query(int i,int l,int r,int jl,int jr,int kl,int kr){
        if(jl<=l&&r<=jr){
            return f[i].query_max(1,1,m,kl,kr);
        }else {
            int mid=(l+r)/2;
            int res=-9;// 我的 
            if(jl<=mid)res=max(res,query(i*2,l,mid,jl,jr,kl,kr));
            if(jr>mid)res=max(res,query(i*2+1,mid+1,r,jl,jr,kl,kr));
            return res;
        }
    }

}T;
int m,a,b;
double x,y;
void solve(){
    while(cin>>m,m){// 又是 杭电多测 aaaaaa
        T.init(N-1,M-1);
        while(m--){
            char op;
            cin>>op;
            if(op=='I'){
                cin>>a>>x>>y;
                a-=99;
                x=x*10+1;
                y=y*10+1;
                // [最大笑话]: 带着调试代码提交
                // cout<<a<<" "<<x<<" "<<y<<"\n";
                T.set(1,1,N-1,a,x,y);
            }else {
                cin>>a>>b>>x>>y;
                a-=99;b-=99;x=x*10+1;y=y*10+1;
                if(x>y)swap(x,y);
                if(a>b)swap(a,b);
                // [最大笑话]: 带着调试代码提交
                // cout<<a<<" "<<b<<" "<<x<<" "<<y<<"\n";
                double ans=(T.query(1,1,N-1,a,b,x,y)-1)/10.0;
                if(ans<0)cout<<-1<<"\n";
                else cout<<ans<<"\n";
            }
        }
    }
}
int main(){
    cout<<fixed<<setprecision(1);
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
