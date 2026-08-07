#include<bits/stdc++.h>
using namespace std;
using LL = long long;

// 路径压缩-按秩合并(可惜有了虚点分离不能用了)+虚点分离(带删除/带移动)
struct DSUPro {
    vector<int> f,sz;
    vector<LL> sum;// sum 是一个集合的各种元素的指标
    int tot;
    // 初始化 大小为 n 的并查集 0-base 预定 m 次操作 
    // 因为 0-base 好操作 
    void init(int n,int m){
        f.resize(n*2+m);
        sz.resize(n*2+m);
        sum.resize(n*2+m);
        iota(f.begin(),f.begin()+n,n);
        iota(f.begin()+n,f.end(),n);
        fill(sz.begin(),sz.end(),1);
        tot=n*2;
        // 神秘 指标
        iota(sum.begin()+n,sum.begin()+n*2,0);
    }
    int fd(int x) { 
        if(f[x]!=x)f[x]=fd(f[x]);
        return f[x];   
    }
    void merge(int x,int y) {
        x=fd(x),y=fd(y);
        if(x==y)return;
        if(sz[x]<sz[y])swap(x,y);
        f[y]=x;
        sz[x]+=sz[y];
        sum[x]+=sum[y];
    }
    void erase(int x) {
        int fx=fd(x);
        f[x]=tot;
        --sz[fx];
        sum[fx]-=x,sum[tot]+=x;
        tot++;
    }
    void move(int x, int y) {
        int fx=fd(x),fy=fd(y);
        if(fx==fy)return;
        f[x]=fy;
        --sz[fx],++sz[fy];
        sum[fx]-=x,sum[fy]+=x;
    }
}D;

int main(){
    cin.tie(0)->sync_with_stdio(0);
    // // 1. 测试 erase
    int n, m, case_id = 0;
    while ((cin >> n >> m), n) {
        // nmbd 原来是 0-base!
        D.init(n, m);
        while(m--) {
            char ch;
            cin >> ch;
            if (ch == 'M') {
                int x, y;
                cin >> x >> y;
                D.merge(x, y);
            } else if (ch == 'S') {
                int x;
                cin >> x;
                D.erase(x);
            }
        }
        int res = 0;
        for (int i = n; i < D.tot; ++i) {
            if (D.sz[i] && i == D.fd(i)) {
                ++res;
            }
        }
        cout << "Case #" << (++case_id) << ": " << res << '\n';
    }
    // // 2. 测试 move
    // // 艹了 这也能有多测 
    // int n,op,p,q,m;
    // while(cin>>n>>m){
    //     D.init(n+1,m);
    //     while(m--){
    //         cin>>op;
    //         if(op==1){
    //             cin>>p>>q;
    //             D.merge(p,q);
    //         }else if(op==2){
    //             cin>>p>>q;
    //             D.move(p,q);
    //         }else{
    //             cin>>p;
    //             p=D.fd(p);
    //             cout<<D.sz[p]<<" "<<D.sum[p]<<"\n";
    //         }
    //     }
    // }
}