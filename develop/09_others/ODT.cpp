#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=2e5+5;
// AUV 这里的 ksm(a,b,mod) 的 a 必须保证 < mod 啊啊啊
LL ksm(LL a,LL b,LL mod){
    LL res=1;
    for(;b;b>>=1,a=a*a%mod)if(b&1)res=res*a%mod;
    return res;
}
namespace ODT{
    struct Node{
        int l,r;
        mutable LL v;
        Node(int ll,int rr=-1,LL vv=0):l(ll),r(rr),v(vv){}
        bool operator<(const Node& o)const {return l<o.l;}
    };
    set<Node> S;
    void init(int n,LL v){
        S.clear();
        S.insert(Node(1,n+1,v));
    }
    // [分裂]
    set<Node>::iterator split(int x){
        auto it=S.lower_bound(Node(x));
        if(it!=S.end()&&it->l==x)return it;
        it--;
        int l=it->l,r=it->r;
        LL v=it->v;
        S.erase(it);
        S.emplace(l,x-1,v);
        return S.emplace(x,r,v).first;
    }
    // [区间赋值]
    void assign(int l,int r,LL v){
        auto R=split(r+1),L=split(l);// 注意顺序 要不然 L 迭代器被删了
        S.erase(L,R);
        S.emplace(l,r,v);
    }
    // 示例
    // void perform(int l,int r){
    //     auto R=split(r+1),L=split(l);
    //     for(;L!=R;L++){
    //         // op
    //     }   
    // }
    void add(int l,int r,LL v){
        auto R=split(r+1),L=split(l);
        for(;L!=R;L++)L->v+=v;
    }
    LL kth(int l,int r,int k){
        auto R=split(r+1),L=split(l);
        vector<pair<LL,int>> tmp;
        for(;L!=R;L++)tmp.emplace_back(L->v,L->r-L->l+1);
        sort(tmp.begin(),tmp.end());
        for(auto [v,c]:tmp){
            if(k<=c)return v;
            k-=c;
        }
        assert(0);
        return -1;
    }
    LL pow_sum(int l,int r,LL x,LL y){
        auto R=split(r+1),L=split(l);
        LL res=0;
        // 先模 y !!!
        for(;L!=R;L++)res=(res+ksm(L->v%y,x,y)*(L->r-L->l+1))%y;
        return res;
    }
}
int n,m,seed,vmax,a[N];
int rnd(){
    int ret=seed;
    seed=((LL)seed*7+13)%1000000007;
    return ret;
}
void solve(){
    cin>>n>>m>>seed>>vmax;
    ODT::init(n,0);
    for(int i=1;i<=n;i++)a[i]=rnd()%vmax+1,ODT::assign(i,i,a[i]);
    for(int i=1;i<=m;i++){
        int op=rnd()%4+1,l=rnd()%n+1,r=rnd()%n+1,x,y;
        if(l>r)swap(l,r);
        if(op==3)x=rnd()%(r-l+1)+1;
        else x=rnd()%vmax+1;
        if(op==4)y=rnd()%vmax+1;
        if(op==1)ODT::add(l,r,x);
        else if(op==2)ODT::assign(l,r,x);
        else if(op==3)cout<<ODT::kth(l,r,x)<<"\n";
        else cout<<ODT::pow_sum(l,r,x,y)<<"\n";
    }
}
int main(){
    solve();
}