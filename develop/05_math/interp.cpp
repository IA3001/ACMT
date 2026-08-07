#include<bits/stdc++.h>
using namespace std;
using LL = long long;
const int mod = 1e9+7,N=1e6+5;
LL ksm(LL a,LL b){
    LL res=1;
    for(;b;b>>=1,a=a*a%mod)if(b&1)res=res*a%mod;
    return res;
}
int n,k;
LL f[N];
LL fac[N],invfac[N];
LL Fac[N],invFac[N];
void init(){
    fac[0]=1;
    for(int i=1;i<N;i++)fac[i]=fac[i-1]*i%mod;
    invfac[N-1]=ksm(fac[N-1],mod-2);
    for(int i=N-1;i>=1;i--)invfac[i-1]=invfac[i]*i%mod;
}
void solve(){
    cin>>n>>k;
    for(int i=1;i<=k+1;i++)f[i]=(f[i-1]+ksm(i,k))%mod;
    if(n<=k+1){
        cout<<f[n]<<"\n";
        return;
    }
    LL ans=0;
    Fac[0]=n;
    for(int i=1;i<=k+1;i++)Fac[i]=Fac[i-1]*(n-i)%mod;
    invFac[k+1]=ksm(Fac[k+1],mod-2);
    for(int i=k+1;i>=1;i--)invFac[i-1]=invFac[i]*(n-i)%mod;
    for(int i=1;i<=k+1;i++)invFac[i]=invFac[i]*Fac[i-1]%mod;
    for(int i=0;i<=k+1;i++){
        LL B = invfac[i]*invfac[k+1-i]%mod;
        if((k+1-i)&1)B=(mod-B)%mod;
        LL C = invFac[i];
        ans=(ans+f[i]*B%mod*C%mod)%mod;
    }
    for(int i=0;i<=k+1;i++)ans=ans*(n-i)%mod;
    cout<<ans<<"\n";
}

int main(){
    init();
    cin.tie(0)->sync_with_stdio(0);
    int T=1;
    // cin>>T;
    while(T--)solve();
}