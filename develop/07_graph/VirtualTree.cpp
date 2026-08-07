#include<bits/stdc++.h>
using namespace std;
const int N=2e5+5;
int n,q,m;
vector<int> e[N],E[N];
int a[N],tmp[N],dfn[N],dfncnt,dep[N],st[N][__lg(N)+2],P;
void dfs1(int u){
    dep[u]=dep[st[u][0]]+1;
    dfn[u]=++dfncnt;
    for(int p=1;p<=P;p++)st[u][p]=st[st[u][p-1]][p-1];
    for(auto v:e[u])if(v!=st[u][0]){
        st[v][0]=u;
        // dep[v]=dep[u]+1;
        dfs1(v);
    }
}
int lca(int a,int b){
    if(dep[a]<dep[b])swap(a,b);
    for(int p=P;p>=0;p--)
        if(dep[st[a][p]]>=dep[b])
            a=st[a][p];
    if(a==b)return a;
    for(int p=P;p>=0;p--)
        if(st[a][p]!=st[b][p])
            a=st[a][p],b=st[b][p];
    return st[a][0];
}
// 什么鬼 二次排序还快 也许因为没有 root = 1
int build1(){
    // 1 二次排序
    sort(a+1,a+1+m,[](int a,int b){return dfn[a]<dfn[b];});
    int cn=0;
    for(int i=1;i<m;i++){
        tmp[++cn]=a[i];
        tmp[++cn]=lca(a[i],a[i+1]);
    }
    tmp[++cn]=a[m];
    // [!] ??? lca 的 dfn 序不是介于中间!!!! 而是 <=min(a,b)
    sort(tmp+1,tmp+1+cn,[](int a,int b){return dfn[a]<dfn[b];});
    cn = unique(tmp+1,tmp+1+cn)-tmp-1;
    // [!] ??? lca 的 dfn 序不是介于中间!!!! 而是 <=min(a,b)
    for(int i=1;i<=cn;i++)E[tmp[i]].clear();
    for(int i=1,lc,pre=0;i<cn;i++){
        lc=lca(tmp[i],tmp[i+1]);
        E[lc].push_back(tmp[i+1]);
    }
    return tmp[1];// 显然 dfn 最小者作为整棵子树的树头
}
int stk[N],tp;
int build2(){
    // 2 单调栈
    sort(a+1,a+1+m,[](int a,int b){return dfn[a]<dfn[b];});
    // stk[tp=1]=a[1];// 朴素方法/
    E[1].clear();
    stk[tp=1]=1;// 固定 1
    for(int i=1,lc;i<=m;i++){
        if(a[i]==1)continue;// 固定
        lc=lca(a[i],stk[tp]);
        if(lc!=stk[tp]){
            while(dfn[stk[tp-1]]>dfn[lc]){
                E[stk[tp-1]].push_back(stk[tp]);
                tp--;
            }
            if(dfn[stk[tp-1]]<dfn[lc]){
                E[lc].clear();
                E[lc].push_back(stk[tp]);
                stk[tp]=lc;
            }else E[lc].push_back(stk[tp--]);
        }
        E[a[i]].clear();
        stk[++tp]=a[i];// 入栈清空 
    }
    for(int i=1;i<tp;i++)
        E[stk[i]].push_back(stk[i+1]);
    return stk[1];
}
int ans[N],sz[N];
bool color[N];
void dfs2(int u){
    ans[u]=sz[u]=0;
    for(auto v:E[u]){
        dfs2(v);
        sz[u]+=sz[v];
        ans[u]+=ans[v];
    }
    if(color[u]){
        ans[u]+=sz[u];
        sz[u]=1;
    }else if(sz[u]>1){
        ans[u]++;
        sz[u]=0;
    }
}
void solve(){
    cin>>n;
    P=__lg(n);
    for(int i=1,u,v;i<n;i++){
        cin>>u>>v;
        e[u].push_back(v);
        e[v].push_back(u);
    }
    dfs1(1);
    cin>>q;
    bool ok;
    while(q--){
        ok=true;
        cin>>m;
        for(int i=1;i<=m;i++)cin>>a[i],color[a[i]]=true;
        for(int i=1;i<=m;i++)ok&=!color[st[a[i]][0]];
        if(!ok)cout<<"-1\n";
        else {
            int root=build1();
            // int root=build2();
            dfs2(root);
            cout<<ans[root]<<"\n";
        }
        for(int i=1;i<=m;i++)color[a[i]]=false;
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}