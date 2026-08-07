
#include<bits/stdc++.h>
using namespace std;
const int N=2e6+5;
struct CTree{
    inline static int stk[N];// 左右孩子 单调栈
    int lc[N],rc[N],rt;
    // 好像可以用 L R 维护当前节点子树的范围
    int L[N],R[N],sz[N];
    int* data;
    void build(int* a,int n,auto cmp){
        data=a;
        for(int i=1,tp=0,pos=0;i<=n;i++){
            // 按需修改 大根堆:< 小根堆:>
            while(pos&&cmp(a[stk[pos]],a[i]))pos--;//出栈操作
            if(pos)rc[stk[pos]]=i;
            if(pos<tp)lc[i]=stk[pos+1];
            stk[++pos]=i;
            tp = pos;
        }
        rt=stk[1];// stk[1] 就是根!!!
    }
    void dfs(int i){
        if(!i)return;
        dfs(lc[i]);
        dfs(rc[i]);
        L[i]=lc[i]?L[lc[i]]:i;
        R[i]=rc[i]?R[rc[i]]:i;
        sz[i]=R[i]-L[i]+1;
    }
    inline static int n,a[N];
    inline static long long ans=0;
    void solve_P2659(){
        cin>>n;
        for(int i=1;i<=n;i++)cin>>a[i];
        build(a,n,greater<>());
        dfs(rt);
        ans=0;
        for(int i=1;i<=n;i++)
        ans=max(ans,(long long)a[i]*(R[i]-L[i]+1));
        cout<<ans<<"\n";
    }
    // map<int,int> S[N];// CF1156E
    // void CF1156E(int u){
    //     if(!u)return;
    //     CF1156E(lc[u]);
    //     CF1156E(rc[u]);
    //     // 【NB】!!!  引用 tmd和指针一样
    //     auto& S1 = S[lc[u]],&S2 = S[rc[u]];
    //     if(S1.size()<S2.size())swap(S1,S2);// 启发式合并
    //     for(auto[a,c]:S2){
    //         auto it = S1.find(data[u]-a);
    //         if(it!=S1.end())ans+=(long long)c*it->second;
    //     }
    //     for(auto[a,c]:S2)S1[a]+=c;
    //     S1[data[u]]++;
    //     swap(S[u],S1);
    // }
    // void solve_CF1156E(){
    //     cin>>n;
    //     for(int i=1;i<=n;i++)cin>>a[i];
    //     build(a,n,less<>());
    //     ans=0;CF1156E(rt);
    //     cout<<ans<<"\n";
    // }
}T;
int main(){
    cin.tie(0)->sync_with_stdio(0);
    T.solve_P2659();
    // T.solve_CF1156E();
}