#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int N=15e4+5;
const int sN=4e2+5;
int n,x,y,q,sn;char op;
int a[N];
LL sum[sN][sN];
void solve(){
    cin>>n>>q;
    sn=sqrt(n);
    for(int i=1;i<=n;i++){
        cin>>a[i];
        for(int j=1;j<sn;j++)sum[j][i%j]+=a[i];
    }
    while(q--){
        cin>>op>>x>>y;
        if(op=='A'){
            if(x<sn){
                cout<<sum[x][y]<<"\n";
            }else {
                LL res=0;
                for(int i=y;i<=n;i+=x)res+=a[i];
                cout<<res<<"\n";
            }
        }else{
            y-=a[x];
            a[x]+=y;
            for(int j=1;j<sn;j++)sum[j][x%j]+=y;
        }
    }
}
int main(){
    solve();
}