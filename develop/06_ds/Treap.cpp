#include<bits/stdc++.h>
using namespace std;
const int N=2e6+5;
const int inf = INT_MAX;
// 所有适合可持久化的东西都这么写
namespace Treap{
    struct FHQTreap{
        int lc,rc,sz,val;
        int key;
    }tr[N];
    int rt,tot;
    #define lc(i) tr[i].lc
    #define rc(i) tr[i].rc
    #define sz(i) tr[i].sz
    #define val(i) tr[i].val
    #define key(i) tr[i].key
    // 【必备】初始化
    void clear(){rt=tot=0;}
    // 【必备】创建节点
    int new_node(int k){
        ++tot;
        key(tot)=k;
        sz(tot)=1;
        val(tot)=rand()^(rand()<<15);
        return tot;
    }
    // 【必备】整合信息
    void up(int i){
        sz(i)=1+sz(lc(i))+sz(rc(i));
    }
    // 【必备】按key分裂
    // <=x 放在左树 >x 的放在右树
    void split(int i,int l,int r,int k){
        if(!i)rc(l)=lc(r)=0;// 空节点
        else {
            if(key(i)<=k){// 小于等于
                rc(l)=i;// 放在左树的右边 
                // 自己的右树递归 自己作为左
                split(rc(i),i,r,k);
            }else {
                lc(r)=i;// 放在右树的左边
                // 自己的左树递归 自己作为右
                split(lc(i),l,i,k);
            }
            up(i);
        }
    }
    // 【必备】按val合并
    // 合并 l r 树
    int merge(int l,int r){
        if(!l||!r)return l|r;// 某一个空
        if(val(l)>=val(r)){// 左边大
            rc(l)=merge(rc(l),r);// 左边的右树递归
            up(l);// 整合到左边
            return l;
        }else {// 右边大
            lc(r)=merge(l,lc(r));// 右边的左树递归
            up(r);// 整合到右边
            return r;
        }
    }
    // 【必备】插入 (3log)
    void insert(int k){
        split(rt,0,0,k);// 0 节点作为辅助
        // 注意这里是的顺序左右是反过来的
        rt=merge(merge(rc(0),new_node(k)),lc(0));
    }
    // 【必备】删除 (5log)
    void erase(int k){
        split(rt,0,0,k);
        int lm=rc(0),r=lc(0);// 同样反过来
        split(lm,0,0,k-1);
        int l=rc(0),m=lc(0);// 同样反过来
        rt=merge(merge(l,merge(lc(m),rc(m))),r);// 不是 0 不反
    }
    // 【必备】按key查找 (迭代)
    int rank(int k){
        // if(!rt)return 0;// WA 按照题目尿性 res>=1
        int i=rt,res=1;  
        while(i){
            if(k<=key(i))i=lc(i);
            else res+=sz(lc(i))+1,i=rc(i);
        }
        return res;
    }
    // 【必备】按索引查找 (迭代)
    int at(int x){
        if(x<1)return -inf;
        if(x>sz(rt))return inf;
        int i=rt;
        while(i){
            if(x<=sz(lc(i)))i=lc(i);
            else if(x==sz(lc(i))+1)return key(i);
            else x-=sz(lc(i))+1,i=rc(i);
        }
        assert(0&&"EMPTY");
    }
    // 【重要】 key前驱 (2迭代)
    int prev(int k){return at(rank(k)-1);}
    // // 【重要】 key后继 (2迭代)
    int next(int k){return at(rank(k+1));}
}
void solve2(){
    Treap::clear();
    int n,m,op,a,x,lst=0,ans=0;
    cin>>n>>m;
    while(n--)cin>>a,Treap::insert(a);
    while(m--){
        cin>>op>>x;x^=lst;
        if(op==1)Treap::insert(x);
        else if(op==2)Treap::erase(x);
        else if(op==3)ans^=lst=Treap::rank(x);
        else if(op==4)ans^=lst=Treap::at(x);
        else if(op==5)ans^=lst=Treap::prev(x);
        else if(op==6)ans^=lst=Treap::next(x);
        else assert(0&&"ERROR");
    }
    cout<<ans<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve2();
}