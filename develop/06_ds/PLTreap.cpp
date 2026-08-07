#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N = 2e5+5;
const int M = 2e5+5;
// 注意：文艺平衡树并不是 key 有序
namespace PLTreap{
    struct PersistentLiteraryTree{
        int lc,rc,sz,val;
        int key;
        LL sum;
        bool rev;
    }tr[N*(5+5*__lg(M))];
    int tot;
    #define lc(i) tr[i].lc
    #define rc(i) tr[i].rc
    #define sz(i) tr[i].sz
    #define val(i) tr[i].val
    #define key(i) tr[i].key
    #define sum(i) tr[i].sum
    #define rev(i) tr[i].rev
    // 【注】拷贝
    int copy(int i){
        tr[++tot]=tr[i];
        return tot;
    }
    int new_node(int k){
        int i=++tot;
        sum(i)=key(i)=k;sz(i)=1;// 【】sum(i)=key(i)!!!
        rev(i)=lc(i)=rc(i)=0;
        val(i)=rand()^(rand()<<15);
        return i;
    }
    void up(int i){
        sz(i)=1+sz(lc(i))+sz(rc(i));
        sum(i)=key(i)+sum(lc(i))+sum(rc(i));
    }
    // 【注】儿子要判空 
    void down(int i){
        if(rev(i)){
            if(lc(i))lc(i)=copy(lc(i)),rev(lc(i))^=1;//【注】
            if(rc(i))rc(i)= copy(rc(i)),rev(rc(i))^=1;// 【注】
            swap(lc(i),rc(i));
            rev(i)=0;
        }
    }
    // 【注】
    void split(int i,int l,int r,int x){
        if(!i)rc(l)=lc(r)=0;
        else {
            i=copy(i);// 【注】拷贝
            down(i);
            if(x<=sz(lc(i))){
                lc(r)=i;
                split(lc(i),l,i,x);
            }else {
                rc(l)=i;
                split(rc(i),i,r,x-sz(lc(i))-1);
            }
            up(i);
        }
    }
    // 【注】
    int merge(int l,int r){
        if(!l||!r)return l|r;
        if(val(l)>=val(r)){
            l=copy(l);// 【注】拷贝
            down(l);
            rc(l)=merge(rc(l),r);
            up(l);
            return l;
        }else {
            r=copy(r);// 【注】拷贝
            down(r);
            lc(r)=merge(l,lc(r));
            up(r);
            return r;
        }
    }
    // 【注】有修改操作
    int insert(int i,int x,int k){
        split(i,0,0,x-1);
        int l=rc(0),r=lc(0);
        lc(0)=rc(0)=0;// 【注】
        return merge(merge(l,new_node(k)),r);
    }
    // 【注】有修改操作
    int erase(int i,int x){
        split(i,0,0,x);
        int lm=rc(0),r=lc(0);
        split(lm,0,0,x-1);
        int l=rc(0),m=lc(0);
        lc(0)=rc(0)=0;// 【注】
        return merge(l,r);
    }
    // 【注】有修改操作
    int reverse(int i,int L,int R){
        split(i,0,0,R);
        int lm=rc(0),r=lc(0);
        split(lm,0,0,L-1);
        int l=rc(0),m=lc(0);
        lc(0)=rc(0)=0;// 【注】
        rev(m)^=1;
        return merge(merge(l,m),r);
    }
    // 【注】这里的 query 仍会产生修改 !!! 没办法的
    pair<int,LL> query(int i,int L,int R){
        split(i,0,0,R);
        int lm=rc(0),r=lc(0);
        split(lm,0,0,L-1);
        int l=rc(0),m=lc(0);
        lc(0)=rc(0)=0;// 【注】
        LL tmp=sum(m);
        return {merge(merge(l,m),r),tmp};
    }
}
int rt[N];
void solve(){
    int n;LL lastans=0,v,op,x,l,r,p;cin>>n;
    for(int i=1;i<=n;i++){
        cin>>v>>op;
        if(op==1){
            cin>>p>>x;p^=lastans,x^=lastans;
            rt[i]=PLTreap::insert(rt[v],p+1,x);
        }else if(op==2){
            cin>>p;p^=lastans;
            rt[i]=PLTreap::erase(rt[v],p);
        }else if(op==3){
            cin>>l>>r;l^=lastans,r^=lastans;
            rt[i]=PLTreap::reverse(rt[v],l,r);
        }else if(op==4){
            cin>>l>>r;l^=lastans,r^=lastans;
            tie(rt[i],lastans)=PLTreap::query(rt[v],l,r);
            cout<<lastans<<'\n';
        }
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}