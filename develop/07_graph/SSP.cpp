#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=5e3+5,M=5e4+5;
const LL INF = 1e10;// d 是 LL !!!

namespace SSP{
    struct Edge{
        int to,nxt;
        LL w,c;// c 代价
    }e[M*2];
    int hd[N],cur[N],cntE;
    int n,s,t;
    bool inq[N];
    LL d[N];// [开LL] 边权不是 1 GAP 没了
    LL ans,cost;// 最大流 / 总费用
    void init(int nn){
        n=nn;
        fill(hd,hd+1+n,0);
        cntE=1;
    }
    inline void add_edge(int u,int v,LL w,LL c){
        e[++cntE]={v,hd[u],w,c};hd[u]=cntE;
        e[++cntE]={u,hd[v],0,-c};hd[v]=cntE;// 注意这里 -c
    }
    bool spfa(){// 可能负环 只能 spfa 除非 Js
        fill(d,d+1+n,INF);
        queue<int> q;
        q.push(s);d[s]=0;
        while(q.size()){
            int u=q.front();q.pop();inq[u]=0;
            for(int i=hd[u],v;i;i=e[i].nxt){
                v=e[i].to;
                if(e[i].w&&d[v]>d[u]+e[i].c){
                    d[v]=d[u]+e[i].c;
                    if(!inq[v])q.push(v),inq[v]=1;
                }
            }
        }
        return d[t]!=INF;
    }
    LL dfs(int u=s,LL sum=INF){
        if(u==t)return sum;
        inq[u]=1;
        LL res=0,tk;
        for(int& i=cur[u],v;i&&sum;i=e[i].nxt){
            v=e[i].to;// [SB写成nxt] 666 
            if(!inq[v]&&e[i].w&&d[v]==d[u]+e[i].c){
                tk=dfs(v,min(sum,e[i].w));
                if(tk){
                    e[i].w-=tk;
                    e[i^1].w+=tk;
                    res+=tk;
                    sum-=tk;
                    cost+=tk*e[i].c;// [注意!!!]
                }else d[v]=INF;
            }
        }
        inq[u]=0;
        return res;
    }
    pair<LL,LL> calc(int ss,int tt){// [确实]
        s=ss;t=tt;
        ans=cost=0;
        while(spfa()){
            memcpy(cur,hd,sizeof(hd[0])*(n+1));
            LL x=0;while(x=dfs())ans+=x;
        }
        return {ans,cost};
    }
}
int n,m,s,t,u,v;LL w,c;
void solve_CF(){
    cin>>n>>m>>s>>t;
    SSP::init(n);
    while(m--)cin>>u>>v>>w>>c,SSP::add_edge(u,v,w,c);
    auto [ans,cost] = SSP::calc(s,t);
    cout<<ans<<" "<<cost<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve_CF();
}