#include<bits/stdc++.h>
using namespace std;
const int N=1e5+5;
const int B=405;
struct B2Array{
    int n,len,bn,vn;
    int a[N];
    int id[N];
    int st[B],ed[B];
    // 前 i 个序列块中 处于第 j 个值域块的 个数
    // 前 i 个序列块中 值 j 的个数
    int sumB[B][B],sumV[B][N];
    // 临时散块计数
    int cntB[B],cntV[N];
    // [位置-集合-值 三位一体]
    // 第 i 个位置 所属集合 
    // 第 i 块值 j 所属集合
    // 第 i 块集合 j 所对应的值
    // 为什么这么搞 因为每次修改都是重新编号的 保证空间复用 
    int set_id[N];
    int val_set[B][N],set_val[B][B];
    void build(int n){
        this->n=n;
        // len=sqrt(max(n,*max_element(a+1,a+1+n)));
        len=400;
        bn=(n+len-1)/len;
        vn=(N-1+len-1)/len;
        for(int i=1;i<N;i++)id[i]=(i-1)/len+1;// 为了 val 分块
        for(int i=1;i<=bn;i++){
            st[i]=(i-1)*len+1;
            ed[i]=min(n,st[i]+len-1);
            // fill(id+st[i],id+ed[i]+1,i); // 有 val 分块
        }
        // DIY...
        for(int i=1;i<=bn;i++){
            memcpy(sumB[i],sumB[i-1],sizeof(sumB[i]));
            memcpy(sumV[i],sumV[i-1],sizeof(sumV[i]));
            for(int k=st[i];k<=ed[i];k++){
                sumB[i][id[a[k]]]++;
                sumV[i][a[k]]++;
            }
            rebuild(i);
        }
    }
    // 暴力
    void rebuild(int I){
        for(int i=1;i<=len;i++)val_set[I][set_val[I][i]]=0;// 把所有涉及到的集合 清空 
        for(int i=st[I],s=0;i<=ed[I];i++){
            int v=a[i];
            if(!val_set[I][v]){
                val_set[I][v]=++s;
                set_val[I][s]=v;
            }
            set_id[i]=val_set[I][v];
        }
    }
    // 暴力
    void down(int I){
        for(int i=st[I];i<=ed[I];i++)
            a[i]=set_val[I][set_id[i]];// 我这个位置对应的集合的值是什么
    }
    // 暴力 change
    void change(int I,int l,int r,int x,int y){
        // 既然都 暴力了 我暴力一个 down 没什么吧
        down(I);
        int X=(x-1)/len+1,Y=(y-1)/len+1;
        for(int i=l;i<=r;i++){
            if(a[i]==x){
                sumB[I][X]--;sumB[I][Y]++;
                sumV[I][x]--;sumV[I][y]++;
                a[i]=y;
            }
        }
        // 既然都 暴力了 我暴力一个 rebuild 没什么吧
        rebuild(I);
    }
    // 有 x 无 y 懒住 
    void lazy(int I,int x,int y){
        val_set[I][y]=val_set[I][x];// fa[y]=fa[x] 顶替 x, 值对应的集合发生移动
        val_set[I][x]=0;// 本质上是 位置-集合-值 的三级关系
        set_val[I][val_set[I][y]]=y;// fa[y] 的值设置为 y
    }
    // 修改 l r 范围内的 x 变为 y
    void modify(int l,int r,int x,int y){
        int L=id[l],R=id[r];
        // 粗略剪枝
        if(x==y||sumV[R][x]-sumV[L-1][x]==0)return;
        int X=id[x],Y=id[y];
        // 前缀差分
        for(int i=vn;i>=L;i--){
            sumB[i][X]-=sumB[i-1][X];
            sumB[i][Y]-=sumB[i-1][Y];
            sumV[i][x]-=sumV[i-1][x];
            sumV[i][y]-=sumV[i-1][y];
        }
        if(L==R){
            // 需要更新的信息:
            // 1 sumB sumV x 变成 y 的块变动 值变动
            // 2 val_set set_val 这是整块的信息 不需要变动
            change(L,l,r,x,y);
        }else {
            // 左右散块仍然是 暴力
            change(L,l,ed[L],x,y);
            change(R,st[R],r,x,y);
            // 中间的块看是否有 y 
            for(int i=L+1;i<=R-1;i++){
                if(!sumV[i][x])continue;// 必然无更改
                if(!sumV[i][y]){// 注意这里已经差分完成了
                    // sum 信息快速维护
                    sumB[i][X]-=sumV[i][x];
                    sumB[i][Y]+=sumV[i][x];
                    sumV[i][y]+=sumV[i][x];
                    sumV[i][x]=0;
                    // 懒住了
                    lazy(i,x,y);
                }else change(i,st[i],ed[i],x,y);
            }
        }
        // 前缀和
        for(int i=L;i<=vn;i++){
            sumB[i][X]+=sumB[i-1][X];
            sumB[i][Y]+=sumB[i-1][Y];
            sumV[i][x]+=sumV[i-1][x];
            sumV[i][y]+=sumV[i-1][y];
        }
    }
    void add(int l,int r){
        for(int i=l;i<=r;i++)cntB[id[a[i]]]++;
        for(int i=l;i<=r;i++)cntV[a[i]]++;
    }
    void del(int l,int r){
        for(int i=l;i<=r;i++)cntB[id[a[i]]]--;
        for(int i=l;i<=r;i++)cntV[a[i]]--;
    }
    // 查询 l r 范围内的第 k 小
    int kth(int l,int r,int k){
        int L=id[l],R=id[r];
        bool inner=L==R;
        if(inner){
            down(L);add(l,r);
        }else {
            down(L);add(l,ed[L]);
            down(R);add(st[R],r);
        }
        int b,v;
        for(b=1;b<=vn;b++){
            int tk=cntB[b]+(inner?0:sumB[R-1][b]-sumB[L][b]);
            if(k<=tk)break;
            k-=tk;
        }
        // 第 b 块的第几个值?
        for(v=(b-1)*len+1;v<=b*len;v++){
            int tk=cntV[v]+(inner?0:sumV[R-1][v]-sumV[L][v]);
            if(k<=tk)break;
            k-=tk;
        }
        if(inner){
            del(l,r);
        }else{
            del(l,ed[L]);
            del(st[R],r);
        }
        return v;
    }
}A;
int n,m,op,l,r,x,y,k;
void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>A.a[i];
    A.build(n);
    while(m--){
        cin>>op;
        if(op==1){
            cin>>l>>r>>x>>y;
            A.modify(l,r,x,y);
        }else {
            cin>>l>>r>>k;
            cout<<A.kth(l,r,k)<<"\n";
        }
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}