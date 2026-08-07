#include<bits/stdc++.h>
using namespace std;
const int N=4e4+5;
const int B=2e2+100;
struct BArray{
    int n,len,bn;
    int a[N];
    int id[N];
    int st[N],ed[N];
    int freq[B][N],mode[B][B],cnt[N];
    void build(int n){
        this->n=n;
        len=sqrt(n);
        bn=(n+len-1)/len;
        for(int i=1;i<=bn;i++){
            st[i]=(i-1)*len+1;
            ed[i]=min(n,st[i]+len-1);
            fill(id+st[i],id+ed[i]+1,i);// 
        }
        // DIY...
        fill(freq[0],freq[0]+n+1,0);
        for(int i=1;i<=bn;i++){// O(sqrt(n))
            memcpy(freq[i],freq[i-1],sizeof(freq[i][0])*(n+1));// O(n)
            for(int j=st[i];j<=ed[i];j++)freq[i][a[j]]++;// O(sqrt(n))
        }// 共 O(n sqrt(n))
        int best;
        for(int i=1;i<=bn;i++){// O(sqrt(n))
            best=0;
            for(int j=i;j<=bn;j++){// O(sqrt(n))
                mode[i][j]=mode[i][j-1];// [!!!] !!! 
                for(int k=st[j];k<=ed[j];k++){// O(sqrt(n))
                    ++cnt[a[k]];
                    if(cnt[a[k]]>cnt[best]||cnt[a[k]]==cnt[best]&&a[k]<best)
                    best=a[k];
                }
                mode[i][j]=best;
            }// 共 O(n)
            fill(cnt,cnt+1+n,0);// O(n) clear !!!
        }// 共 O(n sqrt(n))
    }
    int query(int l,int r){
        int L=id[l],R=id[r];
        if(L==R){
            int best=0;
            for(int i=l;i<=r;i++){
                cnt[a[i]]++;
                if(cnt[a[i]]>cnt[best]||cnt[a[i]]==cnt[best]&&a[i]<best)
                best=a[i];
            }
            for(int i=l;i<=r;i++)cnt[a[i]]--;// !!!
            return best;
        }else {
            #define total(x) (cnt[x]+freq[R-1][x]-freq[L][x])
            int best=mode[L+1][R-1];
            for(int i=l;i<=ed[L];i++){
                cnt[a[i]]++;
                if(total(a[i])>total(best)||total(a[i])==total(best)&&a[i]<best)
                    best=a[i];
            }
            for(int i=st[R];i<=r;i++){
                cnt[a[i]]++;
                if(total(a[i])>total(best)||total(a[i])==total(best)&&a[i]<best)
                    best=a[i];
            }
            for(int i=l;i<=ed[L];i++)cnt[a[i]]--;// !!!
            for(int i=st[R];i<=r;i++)cnt[a[i]]--;// !!!
            #undef total
            return best;
        }
    }
}A;
int n,m,l,r,lst;
int a[N],b[N],cntA;
void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>a[i],b[++cntA]=a[i];
    sort(b+1,b+1+cntA);
    cntA=unique(b+1,b+1+cntA)-b-1;
    for(int i=1;i<=n;i++)A.a[i]=lower_bound(b+1,b+1+cntA,a[i])-b;
    A.build(n);
    while(m--){
        cin>>l>>r;
        l=(l+lst-1)%n+1;
        r=(r+lst-1)%n+1;
        if(l>r)swap(l,r);
        cout<<(lst=b[A.query(l,r)])<<"\n";
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
