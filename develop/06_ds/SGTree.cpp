#include<bits/stdc++.h>
using namespace std;
const double ALPHA = 0.75;
const int N=2e6+5;
const int inf = INT_MAX;

// 我的替罪羊树是不是很优雅，是不是史上最简洁的
struct SGTree{
    // tp:最上方的不平衡节点
    inline static int collect[N],ci,*tp;
    int key[N],cnt[N],lc[N],rc[N],sz[N],diff[N];
    int rt,tot;
    // 【必备】初始化
    void clear(){rt=tot=0;}
    // 【必备】新建节点
    int new_node(int k){
        key[++tot]=k;
        lc[tot]=rc[tot]=0;
        cnt[tot]=sz[tot]=diff[tot]=1;
        return tot;
    }
    // 【必备】更新
    void up(int i){
        sz[i]=cnt[i]+sz[lc[i]]+sz[rc[i]];
        diff[i]=(cnt[i]>0)+diff[lc[i]]+diff[rc[i]];
    }
    // 【必备】中序遍历
    void inorder(int i){
        if(!i)return;
        inorder(lc[i]);
        if(cnt[i])collect[++ci]=i;
        inorder(rc[i]);
    }
    // 【必备】重建递归函数
    int build(int l,int r){
        if(l>r)return 0;
        int mid=(l+r)/2;
        int i=collect[mid];
        lc[i]=build(l,mid-1);
        rc[i]=build(mid+1,r);
        up(i);
        return i;
    }
    // 【必备】重建主函数
    void rebuild(){
        if(!tp)return;
        ci=0;
        inorder(*tp);
        *tp = build(1,ci);       
    }
    // 【必备】判断平衡
    bool imbalance(int i){
        return max(diff[lc[i]],diff[rc[i]])>ALPHA*diff[i];
    }
    // insert 入口
    void insert(int k){
        tp=0;
        _insert(rt,k);
        rebuild();
    }
    // 【必备】内部 insert (log)
    void _insert(int& i,int k){
        if(!i)i=new_node(k);
        else {
            if(k==key[i])cnt[i]++;
            else if(k<key[i])_insert(lc[i],k);
            else _insert(rc[i],k);
            up(i);
            if(imbalance(i))tp=&i;
        }
    }
    // erase 的入口
    void erase(int k){
        // if(rank(k)==rank(k+1))return;// 【RE】前提有数 
        tp=0;
        _erase(rt,k);
        rebuild();
    }
    // 【必备】内部 erase (log)
    void _erase(int& i,int k){
        if(!i)return;// 【RE】method
        // 艹艹艹艹艹艹艹艹艹艹艹艹艹悬挂 else艹艹艹艹艹艹艹艹艹艹艹艹艹艹艹艹艹
        // if(k==key[i])if(cnt[i])cnt[i]--;// 【RE】method
        if(k==key[i])cnt[i]?cnt[i]--:0;// 【RE】method
        else if(k<key[i])_erase(lc[i],k);
        else _erase(rc[i],k);
        up(i);
        if(imbalance(i))tp=&i;
    }
    // 【必备】查询排名 (迭代)
    int rank(int k){
        int i=rt,res=1;
        while(i){
            if(k<key[i])i=lc[i];
            else if(k>key[i])res+=sz[lc[i]]+cnt[i],i=rc[i];
            else return res+sz[lc[i]];
        }
        return res;
    }
    // 【必备】查询排名为 x 的数 (迭代)
    int at(int x){
        if(x<1)return -inf;
        if(x>sz[rt])return inf;
        int i=rt;
        while(i){
            if(x<=sz[lc[i]])i=lc[i];
            else if(x>sz[lc[i]]+cnt[i])x-=sz[lc[i]]+cnt[i],i=rc[i];
            else return key[i];
        }
        assert(0&&"EMPTY");
    }
    // 【重要】< k 的最大值 (2迭代)
    int prev(int k){return at(rank(k)-1);}
    // 【重要】> k 的最小值 (2迭代)
    int next(int k){return at(rank(k+1));}
}T;
void solve2(){
    T.clear();
    int n,m,op,a,x,lst=0,ans=0;
    cin>>n>>m;
    while(n--)cin>>a,T.insert(a);
    while(m--){
        cin>>op>>x;x^=lst;
        if(op==1)T.insert(x);
        else if(op==2)T.erase(x);
        else if(op==3)ans^=lst=T.rank(x);
        else if(op==4)ans^=lst=T.at(x);
        else if(op==5)ans^=lst=T.prev(x);
        else if(op==6)ans^=lst=T.next(x);
        else assert(0&&"ERROR");
    }
    cout<<ans<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve2();
}