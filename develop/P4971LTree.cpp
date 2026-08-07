
/* P4971 */
#include<bits/stdc++.h>
using namespace std;
using LL = long long;

const int N=2e6+5;

struct LeftListTree{
    int lc,rc,d=-1,up;// up 是直接上级 (可选)
    LL val;// 携带信息
    int id;// 携带信息
    bool rm;// 携带信息
    void clear(){
        lc=rc=up=val=id=rm=0;
        d=-1;
    }
    bool operator<(const LeftListTree& o)const {
        return val^o.val?val<o.val:id>o.id;
    }
}tr[N];

LL T,W,K;
int n,m;
int f[N];

void init(){
    iota(f,f+1+n,0);
}

int fnd(int x){
    if(f[x]!=x)f[x]=fnd(f[x]);
    return f[x];
}

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
    x=fnd(x);
    f[tr[x].lc]=tr[x].lc;
    f[tr[x].rc]=tr[x].rc;
    f[x]=merge(tr[x].lc,tr[x].rc);
    // up (可选)
    tr[f[x]].up=0;
    return f[x];
}

// 前置： up 
// 弹出任意节点 x
int del(int x){
    int fx=fnd(x);
    f[tr[x].lc]=tr[x].lc;
    f[tr[x].rc]=tr[x].rc;
    int y=merge(tr[x].lc,tr[x].rc);
    int z=tr[x].up;// 老 up
    f[x]=y;
    tr[y].up=z;// 继承上了 
    // 之前是 pop 作用
    if(fx!=x){
        f[y]=fx;// 这里是 让 y 突破原先的限制
        (tr[z].lc==x?tr[z].lc:tr[z].rc)=y;
        for(int d=tr[y].d;tr[z].d>d+1;z=tr[z].up,d++){
            tr[z].d=d+1;
            if(tr[tr[z].lc].d<tr[tr[z].rc].d)
                swap(tr[z].lc,tr[z].rc);
        }
    }
    tr[x].up=tr[x].lc=tr[x].rc=tr[x].d=0;
    return f[y];// 返回的是根节点！
}

void modify(int x,LL v){
    int fx=del(x);
    tr[x].val=v;
    f[fx]=f[x]=merge(fx,x);// 注意 根部 merge 设置 f
}

void solve(){
    cin>>n>>m;
    init();
    for(int i=1;i<=n;i++)tr[i].clear(),cin>>tr[i].val,tr[i].id=i;
    LL A,B,ans=0;
    for(int i=1,op;i<=m;i++){
        cin>>op;
        if(op==2){
            cin>>A;
            modify(A,0);
        }else if(op==3){
           cin>>A>>B;
           int fA=fnd(A);
           modify(fA,max(tr[fA].val-B,0LL));
        }else if(op==4){
            cin>>A>>B;
            A=fnd(A),B=fnd(B);
            if(A==B)continue;
            f[A]=f[B]=merge(A,B);// 注意这里 merge 要设置 f
        }else assert(0&&"INVALID OP");
    }
    LL mx=0,cnt=0;
    for(int i=1;i<=n;i++){
        int f=fnd(i);
        if(f!=i)continue;
        ans+=tr[f].val;
        if(tr[f].val>mx){
            mx=tr[f].val;
            cnt=1;
        }else if(tr[f].val==mx){
            cnt++;
        }
    }

    if(W==2)ans-=mx;
    else if(W==3)ans+=mx;
    if(ans==0)cout<<"Gensokyo ";
    else if(ans>K)cout<<"Hell ";
    else cout<<"Heaven ";
    cout<<ans<<'\n';
}

int main(){
    cin.tie(0)->sync_with_stdio(0);
    // int t=1;
    cin>>T>>W>>K;
    while(T--)solve();
    return 0;
}