#include<bits/stdc++.h>
using namespace std;
using LL=long long;
const int N =1E5+5,B=4e2+5;
LL f[N][B],g[N][B];
int n,q,sn,s,d,k;
int a[N];
void solve(){
    cin>>n>>q;sn=sqrt(n);
    for(int i=1;i<=n;i++)cin>>a[i];
    for(int i=n;i>=1;i--){
        for(int j=1;j<sn;j++){
            f[i][j]=a[i];
            if(i+j<=n)f[i][j]+=f[i+j][j];
        }
    }
    for(int i=n;i>=1;i--){
        for(int j=1;j<sn;j++){
            g[i][j]=f[i][j];
            if(i+j<=n)g[i][j]+=g[i+j][j];
        }
    }
    while(q--){
        cin>>s>>d>>k;
        LL ans=0;
        if(d<sn)ans=(g[s][d]-(s+k*d<=n?(g[s+k*d][d]+f[s+k*d][d]*k):0));
        else for(int i=s,j=1;i<=n&&j<=k;i+=d,j++)ans+=(LL)a[i]*j;
        cout<<ans<<" ";
    }cout<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    int T;cin>>T;while(T--)solve();
}