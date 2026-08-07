#include<bits/stdc++.h>
using namespace std;

using LL = long long;
const int N = 63;
struct LB{
    LL B[N];
    int sz;
    bool zero;

    void init(){
        memset(B,0,sizeof B);
        sz=zero=0;
    }

    bool insert(LL x){
        for(int i=N-1;i>=0;i--){
            if(x>>i&1){
                if(B[i]>>i&1){
                    x^=B[i];
                }else {
                    // gauss 新增操作:
                    // 1 清除 x 的低位
                    for(int j=i-1;j>=0;j--)
                        if(x>>j&1&&B[j]>>j&1)x^=B[j];
                    // 2 用 x 清除高位
                    for(int j=i+1;j<N;j++)
                        if(B[j]>>i&1)B[j]^=x;
                    B[i]=x;
                    sz++;
                    return true;
                }
            }
        }
        zero=true;
        return false;
    }

    // 计算线性基得到的第 k 小(k>=1)的数字
    // 前提: 使用 gauss 优化
    LL get_kth(LL k){
        if(k<=0)return -1;
        LL res=0;
        if(zero)k--;
        for(int i=0;k&&i<N;i++){
            if(B[i]>>i&1){
                if(k&1)res^=B[i];
                k>>=1;
            }
        }
        if(k)return -1;
        return res;
    }

    // gauss 消元后 直接异或全部即可
    LL get_max(){
        if(!sz&&!zero)return -1;
        LL res=0;
        for(int i=0;i<N;i++)res^=B[i];
        return res;
    }
}B;
// TO DO Zassenhaus 算法求线性基交集
// 记得 bitset 开二倍长度 
LB merge(LB A,LB B){
    // ??? 
}
void solve(){
    int n,q;LL v;
    cin>>n;
    B.init();
    while(n--)cin>>v,B.insert(v);
    cout<<B.get_max()<<"\n";
    // cin>>q;
    // while(q--)cin>>v,cout<<B.get_kth(v)<<"\n";
}

int main(){
    cin.tie(0)->sync_with_stdio(0);
    int T=1,t=0;
    // cin>>T;
    while(T--){
        // cout<<"Case #"<<++t<<":\n";
        solve();
    }
}