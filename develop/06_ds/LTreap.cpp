#include<bits/stdc++.h>
using namespace std;
const int N=2e6+5;
const int inf = INT_MAX;
// 所有适合可持久化的东西都这么写
/*
你现在的代码其实是一个 “超级动态数组”。
如果你需要处理的题目只涉及区间加减和求和，且序列长度固定，线段树更快；
但如果题目涉及 翻转、移动区间、在中间插入删除
那么你这段代码就是唯一正确的选择（或者用 Splay 树，但 FHQ Treap 更好写）。
*/
namespace LTreap{
    struct FHQLTree{
        int lc,rc,sz,val;
        int key;
        bool rev;
    }tr[N];
    int rt,tot;
    #define lc(i) tr[i].lc
    #define rc(i) tr[i].rc
    #define sz(i) tr[i].sz
    #define val(i) tr[i].val
    #define key(i) tr[i].key
    #define rev(i) tr[i].rev
    // 【必备】初始化
    void clear(){rt=tot=0;}
    // 【必备】创建节点
    int new_node(int k){
        ++tot;
        key(tot)=k;
        sz(tot)=1;
        val(tot)=rand()^(rand()<<15);
        rev(tot)=0;// 【新增】
        return tot;
    }
    // 【必备】整合信息
    void up(int i){
        sz(i)=1+sz(lc(i))+sz(rc(i));
    }
    // 【新增】下传信息
    void down(int i){
        if(rev(i)){
            rev(lc(i))^=1;
            rev(rc(i))^=1;
            swap(lc(i),rc(i));
            rev(i)=0;
        }
    }
    // 【孪生】按索引分裂  
    // <=x 个放在左树 其余放在右树
    void split(int i,int l,int r,int x){
        if(!i)rc(l)=lc(r)=0;
        else {// 关键看 i 属于谁
            down(i);// 【新增】
            if(sz(lc(i))+1<=x){
                rc(l)=i;
                split(rc(i),i,r,x-sz(lc(i))-1);
            }else {
                lc(r)=i;
                split(lc(i),l,i,x);
            }
            up(i);
        }
    }
    // 【必备】按val合并
    // 合并 l r 树
    int merge(int l,int r){
        if(!l||!r)return l|r;// 某一个空
        if(val(l)>=val(r)){// 左边大
            down(l);// 【新增】
            rc(l)=merge(rc(l),r);// 左边的右树递归
            up(l);// 整合到左边
            return l;
        }else {// 右边大
            down(r);// 【新增】
            lc(r)=merge(l,lc(r));// 右边的左树递归
            up(r);// 整合到右边
            return r;
        }
    }
    // 【必备】【修改】"定点"插入 (3log)
    void insert(int x,int k){
        split(rt,0,0,x-1);// 0 节点作为辅助
        // 注意这里是的顺序左右是反过来的
        rt=merge(merge(rc(0),new_node(k)),lc(0));
    }
    // 【必备】【修改】"定点"删除 (5log)
    void erase(int x){
        split(rt,0,0,x);
        int lm=rc(0),r=lc(0);// 同样反过来
        split(lm,0,0,x-1);
        int l=rc(0),m=lc(0);// 同样反过来
        rt=merge(merge(l,merge(lc(m),rc(m))),r);// 不是 0 不反
    }
    // 【新增】 区间翻转 (4log)
    void reverse(int x,int y){
        split(rt,0,0,y);
        int lm=rc(0),r=lc(0);
        split(lm,0,0,x-1);
        int l=rc(0),m=lc(0);
        rev(m)^=1;
        rt=merge(merge(l,m),r);
    }
    // 【删除】【rank】按key查找
    // 【必备】按索引查找 (迭代)
    int at(int x){
        if(x<1)return -inf;
        if(x>sz(rt))return inf;
        int i=rt;
        while(i){
            down(i);// 【新增】
            if(x<=sz(lc(i)))i=lc(i);
            else if(x==sz(lc(i))+1)return key(i);
            else x-=sz(lc(i))+1,i=rc(i);
        }
        assert(0&&"EMPTY");
    }
}
void solve(){
    LTreap::clear();
    int n,m,op,a,x,l,r;
    cin>>n>>m;
    for(int i=1;i<=n;i++)LTreap::insert(i,i);
    while(m--)cin>>l>>r,LTreap::reverse(l,r);
    for(int i=1;i<=n;i++)cout<<LTreap::at(i)<<" ";
    cout<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}