#include<bits/stdc++.h>
using namespace std;
const int N=1e5+5,M=5e5+5;

int n,cnt,q;
vector<int> e[N];
bool black[N];

// dist 求解
int dep[N],st[N][__lg(N)+2],P;
void dfs0(int u,int fa){
    dep[u]=dep[fa]+1;
    st[u][0]=fa;
    for(int p=1;p<=P;p++)st[u][p]=st[st[u][p-1]][p-1];
    for(auto v:e[u])if(v!=fa)dfs0(v,u);
}
int lca(int a,int b){
    if(dep[a]<dep[b])swap(a,b);
    for(int p=P;p>=0;p--)
        if(dep[st[a][p]]>=dep[b])a=st[a][p];
    if(a==b)return a;
    for(int p=P;p>=0;p--)
        if(st[a][p]!=st[b][p])a=st[a][p],b=st[b][p];
    return st[a][0];
}
int dist(int a,int b){return dep[a]+dep[b]-dep[lca(a,b)]*2;}

// Trick: 延迟删除堆
struct Heap{
    priority_queue<int> Q,D;
    void clean(){while(D.size()&&Q.top()==D.top())Q.pop(),D.pop();}
    int size(){return Q.size()-D.size();}
    // WC 了!!! 没有返回值 直接本地 神秘 RE !!!!!!!!!!!!!!!!!!!!!!!!! 
    // WC 了!!! 没有返回值 直接本地 神秘 RE !!!!!!!!!!!!!!!!!!!!!!!!! 
    // WC 了!!! 没有返回值 直接本地 神秘 RE !!!!!!!!!!!!!!!!!!!!!!!!! 
    void push(int x){Q.push(x);}// x 不是头必定不动 / x 是头必定不错 
    // int pop(){Q.pop();clean();}// 没有这东西 
    int top(){return Q.top();}
    int top2(){
        int tmp=Q.top();Q.pop();clean();
        int res=Q.top();Q.push(tmp);
        return res;
    }
    void del(int x){D.push(x);clean();}// 必须 clean
}S[N],cand[N],ans;

// 点分治
namespace PDC{
    bool vis[N];
    int sz[N];
    // 点分树
    int p[N];
    void get_size(int u,int fa){
        sz[u]=1;
        for(auto v:e[u])if(v!=fa&&!vis[v])
            get_size(v,u),sz[u]+=sz[v];
    }
    int get_centroid(int u,int fa){
        get_size(u,fa);
        int n=sz[u];
        bool f;
        do{
            f=false;
            for(auto v:e[u])if(v!=fa&&!vis[v]&&sz[v]>n/2){
                fa=u;u=v;f=true;break;
            }
        }while(f);
        return u;
    }
    void pdc(int u,int fa){
        vis[u]=true;
        p[u]=fa;
        for(auto v:e[u])if(!vis[v])pdc(get_centroid(v,u),u);
    }
    // 上传到全局答案
    void push_ans(int u){
        if(cand[u].size()>=2)ans.push(cand[u].top()+cand[u].top2());
    }
    // 删除全局答案
    void del_ans(int u){
        if(cand[u].size()>=2)ans.del(cand[u].top()+cand[u].top2());
    }
    // u 这个点可以作为一个地标
    void add(int u){
        // 上级 对全局答案 的贡献 可能要更新 先删除  
        del_ans(u);
        cand[u].push(0);// 显然可以是自己作为端点
        // 更新自己的贡献
        push_ans(u);// 更新完成
        // 现在更新 祖先的 cand
        for(int cur=u,fa=p[cur];fa;cur=fa,fa=p[cur]){
            del_ans(fa);
            // 首先 我的 S 更新了(插入一个元素) 所以要 撤回 S 在上级的贡献 (前提要有)
            if(S[cur].size())cand[fa].del(S[cur].top());
            // 然后 S 才能插入
            S[cur].push(dist(u,fa));
            // 重新贡献上级 
            cand[fa].push(S[cur].top());
            push_ans(fa);
        }
    }
    void del(int u){
        del_ans(u);
        cand[u].del(0);
        push_ans(u);
        for(int cur=u,fa=p[cur];fa;cur=fa,fa=p[cur]){
            del_ans(fa);
            assert(S[cur].size());// 必须
            // 依然撤回在上级的贡献 
            cand[fa].del(S[cur].top());
            // 然后 S 才能 删除
            S[cur].del(dist(u,fa));
            // 依然重新贡献上级 (前提还剩)
            if(S[cur].size())cand[fa].push(S[cur].top());
            push_ans(fa);
        }
    }
    int query(){assert(ans.size());return ans.top();}
}

void solve(){
    cin>>n;cnt=n;
    P=__lg(n);
    for(int u,v,i=1;i<n;i++){
        cin>>u>>v;
        e[u].push_back(v);
        e[v].push_back(u);
    }
    dfs0(1,0);// dist
    PDC::pdc(PDC::get_centroid(1,0),0);// 点分树 
    for(int i=1;i<=n;i++)PDC::add(i),black[i]=true;// 初始化都染成黑色
    char op;int x;cin>>q;
    while(q--){
        cin>>op;
        if(op=='C'){
            cin>>x;
            if(black[x])PDC::del(x),cnt--;
            else PDC::add(x),cnt++;
            black[x]^=1;
        }else {
            if(cnt<=1)cout<<cnt-1<<"\n";
            else cout<<PDC::query()<<"\n";
        }
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}