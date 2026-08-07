
#include<bits/stdc++.h>
using namespace std;
const int N=2e6+5;
const int inf=INT_MAX;
bool ok=false;

namespace STree{
    struct SplayTree{
        int ch[2],fa,sz;
        int key;
    }tr[N];
    int tot,rt;
    #define ch(i,y) tr[i].ch[y]
    #define lc(i) tr[i].ch[0]
    #define rc(i) tr[i].ch[1]
    #define key(i) tr[i].key
    #define sz(i) tr[i].sz
    #define fa(i) tr[i].fa
    // 【继悬挂else后的第二大语法杀手】加括号套住!!!!!
    // 【继悬挂else后的第二大语法杀手】加括号套住!!!!!
    #define dir(i) (i==ch(fa(i),1)) 
    // 【继悬挂else后的第二大语法杀手】加括号套住!!!!!
    // 【继悬挂else后的第二大语法杀手】加括号套住!!!!!
    // 【必备】 初始化
    void clear(){rt=tot=0;}
    // 【必备】 new_node
    int new_node(int k){
        int i=++tot;
        lc(i)=rc(i)=fa(i)=0;
        sz(i)=1;
        key(i)=k;
        return i;
    }
    // 【必备】 上传
    void up(int i){
        sz(i)=1+sz(lc(i))+sz(rc(i));
    }
    // 【必备】旋转
    void rotate(int i){
        int f=fa(i),g=fa(f);
        bool r=dir(i);
        ch(f,r)=ch(i,!r);// f 的新儿子
        ch(i,!r)=f;// i 的新儿子
        if(g)ch(g,dir(f))=i;// g 的新儿子 (此时没有变 fa(f)) 
        if(ch(f,r))fa(ch(f,r))=f;// f 的儿子认亲
        fa(f)=i;// i 的儿子认亲
        fa(i)=g;// g 的儿子认亲
        up(f);
        up(i);
    }
    // 【必备】伸展
    // 节点 i 通过上升的方式 变成节点 g(即该树的根节点)
    void splay(int i,int goal){
        int f=fa(i),g=fa(f);
        for(;f!=goal;rotate(i),g=fa(f=fa(i)))// [1]for zig-zag
            if(g!=goal)rotate(dir(i)==dir(f)?f:i);
        if(!goal)rt=i;
    }
    // 【必备】插入 (迭代+log)
    void insert(int k){
        if(!rt)rt=new_node(k);
        else {
            int i=rt,f=0;
            // 往下扎 等号处理 无讲究
            for(;i;i=ch(f=i,key(i)<k));// [2]for 往下扎
            i=new_node(k);
            ch(f,key(f)<k)=i;// 但是一定要相同
            fa(i)=f;
            splay(i,0);
        }
    }
    // 【必备】按 key 查询 (迭代+log)
    int rank(int k){
        int i=rt,f=i,res=1;
        for(;i;i=ch(f=i,key(i)<k))// [3]for rank
            if(key(i)<k)res+=sz(lc(i))+1;
        splay(f,0);// f 不一定是 key=k 的
        return res;
    }
    // 【必备】定位索引 x 的节点 (迭代(禁止单用))
    // 不能 splay因为 erase 需要 
    int locate(int x){
        if(x<1||x>sz(rt))return 0;
        int i=rt;
        while(x!=sz(lc(i))+1)// [4]独 while 条件挺奇葩 
            if(x<=sz(lc(i)))i=lc(i);
            else x-=sz(lc(i))+1,i=rc(i);
        return i;
    }
    // 【必备】删除一个 key=k 的元素
    void erase(int k){
        int x = rank(k);// 找到一个排名
        if(x!=rank(k+1)){// 如果有
            int i=locate(x);// 这里寻找不会超过 rank(k) 的深度
            splay(i,0);
            if(!lc(i)||!rc(i))rt=lc(i)|rc(i);
            else {
                int j=locate(x+1);
                splay(j,i);
                lc(j)=lc(i);
                fa(lc(j))=j;
                up(j);
                rt=j;
            }
            fa(rt)=0;
        }
    }
    // 【必备】按索引访问 (迭代+log)
    int at(int x){
        int i=locate(x);
        splay(i,0);
        return key(i);
    }
    // 【必备】前驱 (迭代+log)
    int prev(int k){
        int i=rt,f=i,res=-inf;
        for(;i;i=ch(f=i,key(i)<k))// [5]for = 归左边<
            if(key(i)<k)res=max(res,key(i));// 记忆: <k最大的
        splay(f,0);
        return res;
    }
    // 【必备】后继 (迭代+log)
    int next(int k){
        int i=rt,f=i,res=inf;
        for(;i;i=ch(f=i,key(i)<=k))// [6]for = 归右边<=
            if(key(i)>k)res=min(res,key(i));// 记忆: >k最小的
        splay(f,0);
        return res;
    }
}
int n;
void solve2(){
    STree::clear();
    int n,m,op,a,x,lst=0,ans=0;
    cin>>n>>m;
    while(n--)cin>>a,STree::insert(a);
    while(m--){
        cin>>op>>x;x^=lst;
        if(op==1)STree::insert(x);
        else if(op==2)STree::erase(x);
        else if(op==3)ans^=lst=STree::rank(x);
        else if(op==4)ans^=lst=STree::at(x);
        else if(op==5)ans^=lst=STree::prev(x);
        else if(op==6)ans^=lst=STree::next(x);
        else assert(0&&"ERROR");
    }
    cout<<ans<<"\n";
}
int main(){
	cin.tie(0)->sync_with_stdio(0);
	solve2();
}