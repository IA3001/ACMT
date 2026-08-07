#include<bits/stdc++.h>
using namespace std;
const int N=1e6+5;
namespace LTree{
    struct LeftListTree{
        int lc,rc,d=-1,up;// up 是直接上级 (可选)
        int val,id;// 携带信息
        bool rm;// 携带信息
        bool operator<(const LeftListTree& o)const {
            return val^o.val?val>o.val:id>o.id;
        }
    }tr[N];
    int f[N];// 内置并查集
    void init(int n){iota(f,f+1+n,0);}
    int fd(int x){if(f[x]!=x)f[x]=fd(f[x]);return f[x];}
    int merge(int x,int y){
        if(!x||!y)return x|y;
        if(tr[x]<tr[y])swap(x,y);// 默认大根堆的性质
        // x > y 
        tr[x].rc = merge(tr[x].rc,y);
        f[tr[x].rc]=x;
        // up (可选)
        tr[tr[x].rc].up = x;
        if(tr[tr[x].lc].d<tr[tr[x].rc].d)swap(tr[x].lc,tr[x].rc);
        tr[x].d = tr[tr[x].rc].d+1;
        return x;
    }
    // 仅 弹出 x 所在堆的 堆顶
    int pop(int x){
        x=fd(x);
        f[tr[x].lc]=tr[x].lc;
        f[tr[x].rc]=tr[x].rc;
        f[x]=merge(tr[x].lc,tr[x].rc);
        // up (可选)
        tr[f[x]].up=0;
        return f[x];
    }
    // 前置： up 
    int del(int x){
        int fx=fd(x);
        f[tr[x].lc]=tr[x].lc;
        f[tr[x].rc]=tr[x].rc;
        int y=merge(tr[x].lc,tr[x].rc);
        int z=tr[x].up;// 老 up
        f[x]=y;
        tr[y].up=z;// 继承上了 
        // 之前是 pop 作用
        if(fx!=x){
            tr[y].up=fx;
            (tr[z].lc==x?tr[z].lc:tr[z].rc)=y;
            for(int d=tr[y].d;tr[z].d>d+1;z=tr[z].up,d++){
                tr[z].d=d+1;
                if(tr[tr[z].lc].d<tr[tr[z].rc].d)
                    swap(tr[z].lc,tr[z].rc);
            }
        }
        tr[x].up=tr[x].lc=tr[x].rc=tr[x].d=0;
        return f[y];
    }
}using LTree::tr,LTree::f;
void solve(){
    int n,m;
    cin>>n>>m;
    LTree::init(n);// 并查集初始化
    for(int i=1;i<=n;i++)cin>>tr[i].val,tr[i].id=i;
    for(int i=1,op,x,y;i<=m;i++){
        cin>>op;
        if(op==1){
            cin>>x>>y;
            if(tr[x].rm||tr[y].rm)continue;
            int fx=LTree::fd(x),fy=LTree::fd(y);
            if(fx==fy)continue;// wc 写成 return 了 !!!
            int rt = LTree::merge(fx,fy);
            f[rt]=rt;
        }else if(op==2){
            cin>>x;
            if(tr[x].rm){
                cout<<-1<<'\n';
            }else {
                int fx=LTree::fd(x);
                cout<<tr[fx].val<<'\n';
                // pop(fx);
                LTree::del(fx);
                tr[fx].rm=true;
            }
        }else assert(0&&"INVALID OP");
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}