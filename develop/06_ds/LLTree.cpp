#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=2e6+5;
namespace LLTree{
    struct LazyLeftistTree{
        int lc,rc,d;
        LL val,add,mul=1;// 少用
        bool lz;
        bool operator<(const LazyLeftistTree& o)const {
            return val>o.val;
        }
    }tr[N];// 城市树某一节点上的
    void lazy_add(int x,LL v){
        tr[x].val+=v;tr[x].add+=v;
        tr[x].lz=1;
    }
    void lazy_mul(int x,LL v){
        tr[x].val*=v;tr[x].mul*=v;tr[x].add*=v;
        tr[x].lz=1;
    }
    void down(int x){
        if(tr[x].lz){
            lazy_mul(tr[x].lc,tr[x].mul);
            lazy_mul(tr[x].rc,tr[x].mul);
            tr[x].mul=1;
            lazy_add(tr[x].lc,tr[x].add);
            lazy_add(tr[x].rc,tr[x].add);
            tr[x].add=0;
            tr[x].lz=0;
        }
    }
    int merge(int x,int y){
        if(!x||!y)return x|y;
        down(x);down(y);
        if(tr[x]<tr[y])swap(x,y);
        tr[x].rc=merge(tr[x].rc,y);
        if(tr[tr[x].lc].d<tr[tr[x].rc].d)swap(tr[x].lc,tr[x].rc);
        tr[x].d=tr[tr[x].rc].d+1;
        return x;
    }
    int pop(int x){return merge(tr[x].lc,tr[x].rc);}
}using LLTree::tr;

// fa[] 城市树结构 a[]奖励类型 dep[] 城市树深度 
// top[] 城市树某一节点对应的左偏树根编号
int n,m,fa[N],a[N],dep[N],top[N],die[N],ans[N];
// v[] 奖励值 h[] 城市防御值
LL v[N],h[N];
// 约束：x 是堆顶，请弹出 返回新的堆顶

void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>h[i];
    for(int i=2;i<=n;i++)cin>>fa[i]>>a[i]>>v[i];
    for(int i=1;i<=n;i++)dep[i]=dep[fa[i]]+1;
    for(int c,i=1;i<=m;i++){
        cin>>tr[i].val>>c;
        ans[i]=dep[c];
        top[c]=LLTree::merge(top[c],i);
    }
    for(int i=n;i>=1;i--){
        while(top[i]){
            LLTree::down(top[i]);
            if(tr[top[i]].val<h[i]){
                die[i]++;
                ans[top[i]]-=dep[i];
                top[i]=LLTree::pop(top[i]);
            }else break;
        }
        if(top[i]){
            if(a[i]==0)LLTree::lazy_add(top[i],v[i]);
            else LLTree::lazy_mul(top[i],v[i]);
            top[fa[i]]=LLTree::merge(top[i],top[fa[i]]);
        }
    }
    for(int i=1;i<=n;i++)cout<<die[i]<<'\n';
    for(int i=1;i<=m;i++)cout<<ans[i]<<'\n';
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}