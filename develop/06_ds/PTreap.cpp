#include<bits/stdc++.h>
using namespace std;
const int N=5e5+5;
const int M =5e5+5;
const int inf=INT_MAX;
namespace PTreap{
    struct PersistentFHQTreap{
        int lc,rc,sz,val;
        int key;
    }tr[N*(5+5*__lg(M))];
    int tot;
    #define lc(i) tr[i].lc
    #define rc(i) tr[i].rc
    #define sz(i) tr[i].sz
    #define val(i) tr[i].val
    #define key(i) tr[i].key
    // 【注】可持久化操作
    int copy(int i){
        tr[++tot]=tr[i];
        return tot;
    }
    int new_node(int k){
        int i=++tot;
        key(i)=k;sz(i)=1;
        lc(i)=rc(i)=0;
        val(i)=rand()^(rand()<<15);
        return i;
    }
    void up(int i){
        sz(i)=1+sz(lc(i))+sz(rc(i));
    }
    void split(int i,int l,int r,int k){
        if(!i)rc(l)=lc(r)=0;// 这里不是 i 是 l r
        else {
            i = copy(i);// 【注】拷贝
            if(key(i)<=k){
                rc(l)=i;
                split(rc(i),i,r,k);
            }else {
                lc(r)=i;
                split(lc(i),l,i,k);
            }
            up(i);
        }
    }
    int merge(int l,int r){
        if(!l||!r)return l|r;
        if(val(l)>=val(r)){
            l = copy(l);// 【注】拷贝(可能冗余)
            rc(l)=merge(rc(l),r);
            up(l);
            return l;
        }else {
            r=copy(r);// 【注】拷贝(可能冗余)
            lc(r)= merge(l,lc(r));
            up(r);
            return r;
        }
    }
    // 基于 i 版本(树头), 插入键为 k 的元素, 返回新的版本(树头) 
    int insert(int i,int k){
        split(i,0,0,k);
        int l=rc(0),r=lc(0);
        // 【注】后续可能基于0版本生成新版本的树 一定要清空
        lc(0)=rc(0)=0;
        // 【注】修改操作返回版本号(根)
        return merge(merge(l,new_node(k)),r);
    }
    // 基于 i 版本(树头), 删除一个键为 k 的元素, 返回新的版本(树头) 
    int erase(int i,int k){
        split(i,0,0,k);
        int lm=rc(0),r=lc(0);
        split(lm,0,0,k-1);
        int l=rc(0),m=lc(0);
        // 【注】后续可能基于0版本生成新版本的树 一定要清空
        lc(0)=rc(0)=0;
        // 【注】修改操作返回版本号(根)
        return merge(merge(l,merge(lc(m),rc(m))),r);
    }
    // 【注】直接用 i
    int rank(int i,int k){
        if(!i)return 0;// 按照题目尿性 并没有限制 res>=1
        int res=1;
        while(i){
            if(k<=key(i))i=lc(i);
            else res+=sz(lc(i))+1,i=rc(i);
        }
        return res;
    }
    // 【注】直接用 i
    int at(int i,int x){
        if(x<1)return -inf;
        if(x>sz(i))return inf;
        while(i){
            if(x<=sz(lc(i)))i=lc(i);
            else if(x==sz(lc(i))+1)return key(i);
            else x-=sz(lc(i))+1,i=rc(i);     
        }
        assert(0&&"EMPTY");
    }
    // 【注】直接用 i
    int prev(int i,int k){return at(i,rank(i,k)-1);}
    // 【注】直接用 i
    int next(int i,int k){return at(i,rank(i,k+1));}
}
int rt[N];
void solve(){
    int n,v,op,x;
    cin>>n;
    for(int i=1;i<=n;i++){
        cin>>v>>op>>x;
        if(op==1)rt[i]=PTreap::insert(rt[v],x);
        else if(op==2)rt[i]=PTreap::erase(rt[v],x);
        else if(op==3)rt[i]=rt[v],cout<<PTreap::rank(rt[i],x)<<'\n';
        else if(op==4)rt[i]=rt[v],cout<<PTreap::at(rt[i],x)<<'\n';
        else if(op==5)rt[i]=rt[v],cout<<PTreap::prev(rt[i],x)<<'\n';
        else if(op==6)rt[i]=rt[v],cout<<PTreap::next(rt[i],x)<<'\n';
        else assert(0&&"INVALIT OP");
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}