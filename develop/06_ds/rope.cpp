#include<bits/stdc++.h>
#include<ext/rope>
using namespace std;
using namespace __gnu_cxx;
int main(){
    // freopen("rope.in","r",stdin);
    int q,n,k,pos=0;
    rope<char> S;
    string op,s;
    cin>>q;
    while(q--){
        cin>>op;
        if(op=="Move"){
            cin>>k;
            pos=k;
        }else if(op=="Insert"){
            cin>>n;
            s.clear();
            while(n--){
                char c;
                while((c=getchar())=='\n');
                s+=c;
            }
            S.insert(pos,s.data());
        }else if(op=="Delete"){
            cin>>n;
            S.erase(pos,n);
        }else if(op=="Get"){
            cin>>n;
            cout<<S.substr(pos,n)<<"\n";
        }else if(op=="Prev"){
            pos--;
        }else if(op=="Next"){
            pos++;
        }else if(op=="At"){
            cin>>k;
            cout<<S.at(k)<<"\n";
        }else if(op=="Replace"){
            cin>>k>>n>>s;
            S.copy(pos,k,s.data());
        }
    }
}