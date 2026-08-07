#include<bits/stdc++.h>
using namespace std;
using LL = long long;
struct WDSU{
    vector<int> f,sz;
    vector<LL> w;
    void init(int n){
        f.resize(n);iota(f.begin(),f.end(),0);
        sz.assign(n,1);
        w.assign(n,0);
    }
     int fd(int x) {
        if (f[x] == x) return x;
        int rt = fd(f[x]);
        w[x] += w[f[x]]; 
        return f[x] = rt;
        // w[x] = (w[x]+w[f[x]]+3)%3;// !!!维护同余关系 
    }
    bool same(int x,int y){
        return fd(x)==fd(y);
    }
    LL dist(int x,int y){
        return w[y]-w[x];
        // return (w[y]-w[x]+3)%3;// !!!维护同余关系
    }
    // y - x = d
    bool merge(int x,int y,LL d){
        int tx=x,ty=y;
        x=fd(x),y=fd(y);
        LL d0 = dist(tx,ty);
        if(x==y)return d0==d;
        if(sz[x]<sz[y])swap(x,y),d=-d,d0=-d0;
        // if(x==y)return (d0-d+3)%3==0;// !!!维护同余关系
        // y - x = d0 右侧需要增加 d-d0
        // 因为 y 是断层处所以 y 需要增加 d-d0 
        w[y]=d-d0;
        // w[y]=(d-d0+30)%3;// !!!维护同余关系
        sz[x]+=sz[y];
        f[y]=x;
        return true;
    }
    // 这是 P1196题意的操作 不可以启发式合并
    // 将 x 移动到 y 后面
    void move(int x,int y){
        x=fd(x),y=fd(y);
        if(x==y)return;
        f[x]=y;
        w[x]+=sz[y];
        sz[y]+=sz[x];
    }
}D;
int n,m,q,l,r;LL S;
void solve_P8779(){
    cin>>n>>m>>q;
    D.init(n+1);
    while(m--)cin>>l>>r>>S,D.merge(l-1,r,S);
    while(q--){
        cin>>l>>r;
        if(!D.same(l-1,r))cout<<"UNKNOWN\n";
        else cout<<D.dist(l-1,r)<<"\n";
    }
}
void solve_P2294(){
    bool ok=true;cin>>n>>m;
    D.init(n+1);
    while(m--)cin>>l>>r>>S,ok&=D.merge(l-1,r,S);
    cout<<(ok?"true":"false")<<"\n";
}
void solve_HDU3038(){
    for(int cnt=0;cin>>n>>m;cnt=0){
        D.init(n+1);
        while(m--)cin>>l>>r>>S,cnt+=(!D.merge(l-1,r,S));
        cout<<cnt<<"\n";
    }
}
void solve_P1196(){
    cin>>m;char op;
    D.init(30000+1);
    while(m--){
        cin>>op>>l>>r;
        if(op=='M')D.move(l,r);
        else cout<<(D.same(l,r)?abs(D.dist(l,r))-1:-1)<<"\n";
    }
}
void solve_P2024(){
    cin>>n>>m;int cnt=0;
    D.init(n+1);
    while(m--){
        cin>>S>>l>>r;
        if(l>n||r>n)cnt++;
        else if(S==1)cnt+=!D.merge(l,r,0);
        else if(!D.same(l,r))D.merge(l,r,1);
        else cnt+=D.dist(l,r)!=1;
    }
    cout<<cnt<<"\n";
}
// 最后还有一道 十里淘金的题 
// 给出几条声明
// 1 x v x==v
// 2 x y v x^y==v
// 3 n a_1 a_2 ... a_n 求 xor 和 
// 关键点: 
// 声明1 的头一定是 0 不能变 合并的时候 不允许改变 0 
// 查询的时候 按组求值 0 为头的一定可求 其他为头的只能出现偶数次 
int main(){
    cin.tie(0)->sync_with_stdio(0);
    // solve_P8779();
    int T;cin>>T;while(T--)solve_P2294();
    // solve_HDU3038();
    // solve_P1196();
    // solve_P2024();
}
