#include<bits/stdc++.h>
using namespace std;
const int N=5e5+5;
const int B=8e2+5;
struct BArray{
    int n,len,bn;
    int a[N];
    array<int,2> sort_list[N];
    int pos[N];
    int id[N];
    int st[B],ed[B];
    int mode_cnt[B][B],cnt[N];
    void build(int n){
        this->n=n;
        len=sqrt(n);
        bn=(n+len-1)/len;
        for(int i=1;i<=bn;i++){
            st[i]=i*len-len+1;
            ed[i]=min(n,st[i]+len-1);
            fill(id+st[i],id+ed[i]+1,i);
        }
        // DIY...
        for(int i=1;i<=bn;i++){
            int best_cnt=0;
            for(int j=i;j<=bn;j++){
                for(int k=st[j];k<=ed[j];k++){
                    ++cnt[a[k]];
                    if(cnt[a[k]]>best_cnt)best_cnt=cnt[a[k]];
                }
                mode_cnt[i][j]=best_cnt;
            }
            fill(cnt,cnt+1+n,0);
        }
        // sort_list pos
        for(int i=1;i<=n;i++)sort_list[i]={a[i],i};
        sort(sort_list+1,sort_list+1+n);
        for(int i=1;i<=n;i++)pos[sort_list[i][1]]=i;
    }
    int query(int l,int r){
        int L=id[l],R=id[r];
        if(L==R){
            int best_cnt=0;
            for(int i=l;i<=r;i++)if(++cnt[a[i]]>best_cnt)best_cnt=cnt[a[i]];
            for(int i=l;i<=r;i++)cnt[a[i]]--;
            return best_cnt;
        }else {
            int best_cnt=mode_cnt[L+1][R-1];
            for(int i=l;i<=ed[L];i++){
                int p=pos[i];// pos[i] !!!!!!!!
                while(p+best_cnt<=n&&sort_list[p+best_cnt][0]==a[i]&&sort_list[p+best_cnt][1]<=r)
                    best_cnt++;
            }
            for(int i=st[R];i<=r;i++){
                int p=pos[i];// pos[i] !!!!!!!!
                while(p-best_cnt>=1&&sort_list[p-best_cnt][0]==a[i]&&sort_list[p-best_cnt][1]>=l)
                    best_cnt++;
            }
            return best_cnt;
        }
    }
}A;
int n,m,lst,l,r;
void solve(){
    cin>>n>>m;
    for(int i=1;i<=n;i++)cin>>A.a[i];
    A.build(n);// [!!!] CD
    while(m--){
        cin>>l>>r;l^=lst;r^=lst;
        if(l>r)swap(l,r);
        cout<<(lst=A.query(l,r))<<"\n";
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    solve();
}