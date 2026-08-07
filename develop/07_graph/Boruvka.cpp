#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=2e5+5;

// WC 了 CF 的 unordered 卡的真早!!!!!!!
// #define set unordered_set
// #define map unordered_map
/*
    啊啊啊啊啊啊啊 没想到的优化:
    + 修改 Trie，使其在叶子节点直接存储元素的下标。
    + 直接遍历 1 到 n，如果 D.f[i] == i，则 i 是一个连通分量的根。
*/
struct DSU{
    vector<int> f,sz;
    vector<vector<int>> S;
    void init(int n){
        f.resize(n);sz.assign(n,1);
        iota(f.begin(),f.end(),0);
        S=vector<vector<int>>(n);
        for(int i=0;i<n;i++)S[i].push_back(i);
    }
    int fd(int x){
        if(f[x]!=x)f[x]=fd(f[x]);
        return f[x];
    }
    bool same(int x,int y){
        return fd(x)==fd(y);
    }
    void merge(int x,int y){
        x=fd(x),y=fd(y);
        if(x==y)return;
        if(sz[x]<sz[y])swap(x,y);
        f[y]=x;
        sz[x]+=sz[y];
        for(auto v:S[y])S[x].push_back(v);
    }
}D;
struct Trie{
    int ch[N*40][2];
    int pass[N*40];
    int tot=0;
    void init(){
        memset(ch,0,sizeof(ch[0])*(tot+1));
        tot=0;
    }
    void insert(int x){
        int cur=0;
        for(int i=30;i>=0;i--){
            int to=x>>i&1;
            if(!ch[cur][to])ch[cur][to]=++tot;
            cur=ch[cur][to];
            pass[cur]++;
        }
    }
    void del(int x){
        int cur=0;
        for(int i=30;i>=0;i--){
            int to=x>>i&1;
            cur=ch[cur][to];
            pass[cur]--;
        }
    }
    int get(int x){
        int res=0;
        int cur=0;
        for(int i=30;i>=0;i--){
            int to=x>>i&1;
            if(!pass[ch[cur][to]])to=!to;
            cur=ch[cur][to];
            res|=to<<i;
        }
        return res;
    }
}T;
int n;
int a[N];
map<int,int> A;
LL ans;
void Boruvka(){
    T.init();
    for(int i=1;i<=n;i++)T.insert(a[i]);
    D.init(n+1);
    int cnt=0;
    ans=0;
    while(cnt<n-1){
        set<int> F;
        for(int i=1;i<=n;i++)F.insert(D.fd(i));
        map<int,pair<int,int>> E;
        for(auto f:F){
            auto& S = D.S[f];
            for(auto u:S)T.del(a[u]);
            int mnw = INT_MAX;
            int mnv = 0;
            for(auto u:S){
                int x = T.get(a[u]);
                int w = a[u]^x;
                int v = A[x];
                if(mnw>w){
                    mnw=w;
                    mnv=v;
                }
            }
            E[f]={mnv,mnw};
            for(auto u:S)T.insert(a[u]);
        }
        for(auto& [u,p]:E){
            auto [v,w] = p;
            if(!D.same(u,v)){
                D.merge(u,v);
                ans+=w;
                cnt++;
            }
        }
    }
}
void solve(){
    cin>>n;
    for(int i=1;i<=n;i++)cin>>a[i];
    sort(a+1,a+1+n);
    n=unique(a+1,a+1+n)-a-1;
    for(int i=1;i<=n;i++)A[a[i]]=i;
    Boruvka();
    cout<<ans<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}