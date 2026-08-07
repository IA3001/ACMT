#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=1e6+5;
const int B=1e3+100;

/* 这是一个区间增加 区间查询个数的 code */
/* 
还有一种 code(未给出) 是解决 区间设置 区间查询个数的 code 同样需要sort_block
只需要定义 d[] 为块区间设置标记即可
*/
struct BArray{
    int n,len,bn;// 参数
    LL a[N],t[N];// a原数组 辅助数组
    int id[N];// 所属块编号
    int st[B],ed[B],sz[B];// 块基本信息
    LL tag[B];// 块附加信息
    void build(int n){
        this->n=n;// n
        len=sqrt(n);// len
        bn=(n+len-1)/len;// bn 向上取整
        // B 规模
        for(int i=1;i<=bn;i++){
            // 基本信息初始化
            st[i]=(i-1)*len+1;// st
            ed[i]=min(n,i*len);// ed
            sz[i]=ed[i]-st[i]+1;// sz
            fill(id+st[i],id+ed[i]+1,i);// 批量赋值 id
            _sort(st[i],ed[i]);// 【警告】build 的时候也要sort啊啊啊
            // 附加信息初始化
            tag[i]=0;// tag 
        }
    }
    // 暴力排序
    void _sort(int l,int r){
        memcpy(t+l,a+l,sizeof(a[0])*(r-l+1));
        sort(t+l,t+r+1);
    }
    // 暴力增加
    void _add(int l,int r,LL v){
        for(int i=l;i<=r;i++)a[i]+=v;
    }
    // 暴力查询
    int _ge(int l,int r,LL v){
        int res=0;
        for(int i=l;i<=r;i++)res+=(a[i]>=v);
        return res;
    }
    void add(int l,int r,LL v){
        int L=id[l],R=id[r];
        if(L==R){
            _add(l,r,v);_sort(st[L],ed[L]);// 
        }else {
            for(int I=L+1;I<R;I++)
                tag[I]+=v;
            _add(l,ed[L],v);_sort(st[L],ed[L]);// 
            _add(st[R],r,v);_sort(st[R],ed[R]);// 
        }
    }
    int ge(int l,int r,LL v){
        int res=0,L=id[l],R=id[r];
        if(L==R){
            res+=_ge(l,r,v-tag[L]);
        }else {
            for(int I=L+1;I<R;I++)
                res+=sz[I]-(lower_bound(t+st[I],t+ed[I]+1,v-tag[I])-t-st[I]);
            res+=_ge(l,ed[L],v-tag[L]);
            res+=_ge(st[R],r,v-tag[R]);
        }
        return res;
    }
}A;
void solve(){
    int n,q,l,r,v;cin>>n>>q;char op;
    for(int i=1;i<=n;i++)cin>>A.a[i];
    A.build(n);
    while(q--){
        cin>>op>>l>>r>>v;
        if(op=='M')A.add(l,r,v);
        else cout<<A.ge(l,r,v)<<"\n";
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}