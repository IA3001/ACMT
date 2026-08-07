#include<bits/stdc++.h>
using namespace std;
mt19937_64 rng(chrono::steady_clock::now().time_since_epoch().count());
// mt19937_64 rng(time(0));// [禁] 同一秒 重复的数字 
int main(){
    int n=10;
    for(int i=0;i<n;i++){
        vector<int> a(10);
        iota(a.begin(),a.end(),0);
        shuffle(a.begin(),a.end(),rng);
        // random_shuffle(a.begin(),a.end());// [禁] 已经弃用了!!!
        for(auto i:a)cout<<i<<" ";
        cout<<"\n";
    }
}