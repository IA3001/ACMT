#include<bits/stdc++.h>
using namespace std;
const int N=3e5+5;
const int M=3e5+5;
const int B=30;
namespace PTrie01{
    struct PersistentTrie01{
        int ch[2],pass;
    }tr[N*(B+1)*2];// 神秘*2
    int tot;
    int insert(int i,int x){
        int root=++tot;// 创建
        tr[root]=tr[i];// 拷贝
        tr[root].pass++;// ++
        for(int b=B,to,cur=root;b>=0;b--){
            to = x>>b&1;
            i=tr[i].ch[to];
            tr[cur=tr[cur].ch[to]=++tot]=tr[i];
            tr[cur].pass++;// ++ 
        }
        return root;
    }
    int query(int i,int j,int x){
        int ans=0;
        for(int b=B,to;b>=0;b--){
            to = ((x>>b)&1)^1;
            if(tr[tr[i].ch[to]].pass<tr[tr[j].ch[to]].pass){
                ans|=1<<b;
                i=tr[i].ch[to];
                j=tr[j].ch[to];
            }else {
                i=tr[i].ch[to^1];
                j=tr[j].ch[to^1];
            }
        }
        return ans;
    }
}
int rt[N+M];// 忘啦新根 ！
int n,m,xor_sum;
void solve(){
    cin>>n>>m;
    rt[0]=PTrie01::insert(rt[0]=0,xor_sum=0);
    for(int i=1,x;i<=n;i++){
        cin>>x;
        xor_sum^=x;// 区间和往往插入 前缀和进行差分
        rt[i]=PTrie01::insert(rt[i-1],xor_sum);
    }
    string op;
    for(int i=1,x,y,z;i<=m;i++){
        cin>>op;
        if(op=="A"){
            cin>>x;xor_sum^=x;
            rt[++n]=PTrie01::insert(rt[n],xor_sum);
        }else {
            cin>>x>>y>>z;
            if(x==1)cout<<PTrie01::query(0,rt[y-1],xor_sum^z)<<'\n';
            else cout<<PTrie01::query(rt[x-1-1],rt[y-1],xor_sum^z)<<'\n';
        }
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
