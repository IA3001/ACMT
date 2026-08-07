#include<bits/stdc++.h>
using namespace std;
const int N=5e4+5,M=1e5+5;
const int B=4e2+5;
// 1 x y 将 x 边权设置为 y
// 2 x y 在 x 点出发 边权>=y 的点数
namespace B3Array{
    // 可撤销并查集
    int tp;
    int f[N],sz[N];
    array<int,2> stk[N];
    int find(int x){
        return f[x]==x?x:find(f[x]);
    }
    void merge(int x,int y){
        int fx=find(x),fy=find(y);
        if(fx==fy)return;
        if(sz[fx]<sz[fy])swap(fx,fy);
        f[fy]=fx;
        sz[fx]+=sz[fy];
        stk[++tp]={fx,fy};
    }
    void back(){
        auto [fx,fy]=stk[tp--];
        f[fy]=fy;
        sz[fx]-=sz[fy];
    }
    
    // 这里的 q 是操作数量 m 是边数量 n 是点数量
    int q,m,n,len,bn;
    // 基本量
    array<int,2> e[M];// 边属性
    int w[M],cur_w[M];// 边属性
    bool change[M];// 边属性
    int edge[M];// 边编号 全局
    // 操作
    struct Node{int op,x,y;}Q[M];// 操作属性
    int update[M],query[M],cntu,cntq;// 操作编号 动态
    // 答案
    int ans[M];
    void build(){
        // [[[[[NB!!!!!]]]]] 真得分析复杂度!!! 卡常!!!!  
        // [[[[[NB!!!!!]]]]] 真得分析复杂度!!! 卡常!!!!  
        // [[[[[NB!!!!!]]]]] 真得分析复杂度!!! 卡常!!!!  
        // f(t)/x + g(t)x -> x= sqrt(f(t)g(t)) 
        // f(t)/x + g(t)x -> x= sqrt(f(t)g(t)) 
        // f(t)/x + g(t)x -> x= sqrt(f(t)g(t)) 
        len=sqrt(q*__lg(n+2));
        bn=(q+len-1)/len;
    }
    // sqrt(q)*(n+m+sqrt(q)+sqrt(q)logq+sqrt(q)*sqrt(q)logn) = q sqrt(q) log n + sqrt(q) m 
    void compute(int l,int r){// O(sqrt(q))
        // [!!!] Cao!!! 边权变了 重新 排序!
        sort(edge+1,edge+1+m,[](int a,int b){
            return w[a]>w[b];
        });
        // cout<<"compute"<<l<<" "<<r<<"\n";
        // O(n) 初始化并查集
        iota(f,f+1+n,0);fill(sz,sz+1+n,1);
        // O(m) 清空 change 记录
        fill(change,change+m+1,false);
        // O(sqrt(q)) 首先将修改和查询操作分开
        cntu=cntq=0;
        for(int i=l;i<=r;i++){// 
            if(Q[i].op==1){
                update[++cntu]=i,change[Q[i].x]=true;// 修改操作
                // cout<<"change:"<<Q[i].x<<"\n";
            }else {
                query[++cntq]=i;// 查询操作
            }
        }
        // O(sqrt(q) log q) 查询按照 W 降序排列
        sort(query+1,query+1+cntq,[](int a,int b){return Q[a].y>Q[b].y;});
        // O(sqrt(q)) 逐个查询
        for(int i=1,j=1;i<=cntq;i++){
            auto [_,S,W]=Q[query[i]];// 获取查询
            // cout<<"query "<<query[i]<<":"<<S<<" "<<W<<"\n";
            // 总 O(m log n) 启用>=W的所有无关边
            while(j<=m&&w[edge[j]]>=W){
                // cout<<"j+="<<j<<" ";
                if(!change[edge[j]]){
                    merge(e[edge[j]][0],e[edge[j]][1]);
                    // cout<<"merge:"<<e[edge[j]][0]<<" "<<e[edge[j]][1]<<"\n";
                }
                j++;
            }
            //从零开始
            tp=0;
            // O(sqrt(q)) 边 的默认值
            for(int j=1;j<=cntu;j++){
                cur_w[Q[update[j]].x]=w[Q[update[j]].x];
                // cout<<"init:"<<Q[update[j]].x<<"->"<<w[Q[update[j]].x]<<"\n";
            }
            // O(sqrt(q)) 个修改
            for(int j=1;j<=cntu&&update[j]<query[i];j++){// O(sqrt(q))
                // 早于它 就启用 注意可能多次启用
                cur_w[Q[update[j]].x]=Q[update[j]].y;
                // cout<<"update:"<<Q[update[j]].x<<"->"<<Q[update[j]].y<<"\n";
            }
            // O(sqrt(q)) 边 是否启用
            for(int j=1;j<=cntu;j++){
                if(cur_w[Q[update[j]].x]>=W){
                    merge(e[Q[update[j]].x][0],e[Q[update[j]].x][1]);
                    // cout<<"extra:"<<e[Q[update[j]].x][0]<<" "<<e[Q[update[j]].x][1]<<"\n";
                }
            }
            ans[query[i]]=sz[find(S)];
            while(tp)back();// 删除这些边
        }
        // O(sqrt(q)) 将所有涉及到的边最终都要全部设置 
        for(int i=1;i<=cntu;i++){
            w[Q[update[i]].x]=Q[update[i]].y;
            // cout<<"reset:"<<Q[update[i]].x<<"->"<<Q[update[i]].y<<"\n\n";
        }
    }
    void solve(){
        // 时间分块
        for(int i=1;i<=bn;i++){
            int l=(i-1)*len+1;
            int r=min(q,i*len);
            compute(l,r);
        }
    }
}using B3Array::e,B3Array::w,B3Array::Q,B3Array::edge;
int n,m,q;
void solve(){
    cin>>n>>m;
    for(int i=1;i<=m;i++)cin>>e[i][0]>>e[i][1]>>w[i],edge[i]=i;
    cin>>q;
    for(int i=1;i<=q;i++)cin>>Q[i].op>>Q[i].x>>Q[i].y;// [Cao!!!] id=i
    B3Array::n=n;
    B3Array::m=m;
    B3Array::q=q;
    B3Array::build();
    // cout<<"build!\n";
    B3Array::solve();
    // cout<<"solve!\n";
    for(int i=1;i<=q;i++)
        if(Q[i].op==2)cout<<B3Array::ans[i]<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}