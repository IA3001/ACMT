#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=2e5+5;
const int K=2;
namespace KDT{
    int collect[N],ci;
    array<int,K> a,b;// a 为较小者 b 为较大者
    struct Node{
        int lc,rc;// 左右孩子
        array<int,K> p,L,R;// 当前点的坐标 最小坐标集 最大坐标集
        int v;// 值
        LL sum;// 子树值的和
    }tr[N];
    int tot,rt[__lg(N)+2];
    // 新建节点
    int new_node(array<int,K> p,int v){
        int i=++tot;
        tr[i].lc=tr[i].rc=0;
        tr[i].p=tr[i].L=tr[i].R=p;// 
        tr[i].v=tr[i].sum=v;// 
        return i;
    }
    // 上传信息
    void up(int i){
        tr[i].sum=tr[i].v+tr[tr[i].lc].sum+tr[tr[i].rc].sum;
        tr[i].L=tr[i].R=tr[i].p;// 初始化 p -> L R 
        for(int k=0;k<K;k++){
            if(tr[i].lc){// 左 Lmin Rmax
                tr[i].L[k]=min(tr[i].L[k],tr[tr[i].lc].L[k]);
                tr[i].R[k]=max(tr[i].R[k],tr[tr[i].lc].R[k]);
            }
            if(tr[i].rc){// 右 Lmin Rmax
                tr[i].L[k]=min(tr[i].L[k],tr[tr[i].rc].L[k]);
                tr[i].R[k]=max(tr[i].R[k],tr[tr[i].rc].R[k]);
            }
        }
    }
    // 收集节点 任意顺序皆可 因为有 nth_element
    void inorder(int i){
        if(!i)return;
        inorder(tr[i].lc);
        collect[++ci]=i;
        inorder(tr[i].rc);
        // i=0;// 更加方便 不用考虑悬空了 
    }
    // 构建/重构
    void build(int& i,int l,int r,int k=0){
        if(l>r)return void(i=0);// 空 更加显式
        int mid=(l+r)/2;// mid 
        nth_element(collect+l,collect+mid,collect+r+1,[k](int a,int b){
            return tr[a].p[k]<tr[b].p[k];
        });
        i=collect[mid];// [] 必须设置
        k=(k+1)%K;// 下一层
        build(tr[i].lc,l,mid-1,k);// [] 啊啊啊 这里 挖掉 mid
        build(tr[i].rc,mid+1,r,k);
        up(i);// 上传
    }
    // 查询一个子树的和 (已有全局ab构成的超长方体) 
    LL query_sum(int i){
        if(!i)return 0;
        bool f=0;
        for(int k=0;k<K;k++)f|=a[k]>tr[i].L[k]||b[k]<tr[i].R[k];// LR 查看是否存在冗余越界
        if(!f)return tr[i].sum;// 没有冗余 直接懒住
        for(int k=0;k<K;k++)if(a[k]>tr[i].R[k]||b[k]<tr[i].L[k])return 0;// 有一个全额越界
        LL ans=0;// 注意 此时 f=true
        for(int k=0;k<K;k++)f&=tr[i].p[k]>=a[k]&&tr[i].p[k]<=b[k];// x 查看是否都在界内
        if(f)ans=tr[i].v;// yes
        return ans+query_sum(tr[i].lc)+query_sum(tr[i].rc);// 递归
    }
    // 插入一个 p 点 v 值
    void insert(array<int,K> p,int v){
        collect[++ci]=new_node(p,v);// 等待构建
        for(int i=0;i<__lg(N)+2;i++){
            if(!rt[i]){// 终于找到了第一个 0
                build(rt[i],1,ci);
                ci=0;
                break;// [] 必须跳出
            }else {// 收集一路上的所有 1 
                inorder(rt[i]);
                rt[i]=0;
            }
        }
    }
    // 对于每个二进制子树都查询累加
    LL query(array<int,K> aa,array<int,K> bb){
        a=aa;b=bb;// kb
        LL res=0;
        for(int i=0;i<__lg(N)+2;i++)res+=query_sum(rt[i]);
        return res;
    }
}
void solve(){
    int n,op,x1,y1,x2,y2,a,lst=0;// 这里的的 y1 !!!!
    cin>>n;
    while(cin>>op,op!=3){
        if(op==1){
            cin>>x1>>y1>>a;x1^=lst;y1^=lst;a^=lst;
            KDT::insert({x1,y1},a);
        }else {
            cin>>x1>>y1>>x2>>y2;x1^=lst;y1^=lst;x2^=lst;y2^=lst;
            cout<<(lst=KDT::query({x1,y1},{x2,y2}))<<"\n";
        }
    }

}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}