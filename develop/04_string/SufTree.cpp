#include<bits/stdc++.h>
using namespace std;
const int N=8e5+5;
void decode(string& s,int len,int mask){
    for(int i=0;i<len;i++){
        mask=(mask*131+i)%len;
        swap(s[i],s[mask]);
    }
}
int q;
string type;
// 尾增删 的 后缀平衡树 （所以需要维护反串的后缀数组） 
struct SufTreeSGT{
    int n;
    char t[N];// t 是 1-base 的正串 （正串是为了方便尾插）
    // 下文中的 p 代表后缀的编号 
    // 因为是 维护反串 所以它表示的串为 t 的 下标从 p 到 1 的反串
    inline static const double INF = 1e18;
    inline static const double alpha = 0.75;
    inline static int buf[N], buf_sz;
    int root=0,sz[N],lc[N],rc[N];
    double tag[N];
    // 后缀平衡树初始化
    void init(){
        n=root=0;
    }
    // 第 x 个 和第 y 个后缀比较
    bool cmp(int x,int y){
        if(t[x]!=t[y])return t[x]<t[y];
        return tag[x-1]<tag[y-1];
    }
    /*以下是平衡树操作*/
    void init(int &i,int p,double lv,double rv){
        i=p;
        sz[i]=1;
        tag[i]=(lv+rv)/2;
        lc[i]=rc[i]=0;
    }
    void up(int i){
        if(!i)return;
        sz[i]=sz[lc[i]] + 1 + sz[rc[i]];// RE 就是源于这里啊！
    }
    bool balance(int i){
        return alpha*sz[i]>max(sz[lc[i]],sz[rc[i]]);
    }
    void flatten(int i){
        if(!i)return;
        flatten(lc[i]);
        buf[++buf_sz]=i;
        flatten(rc[i]);
    }
    void build(int& i,int l,int r,double lv,double rv){
        if(l>r){
            i=0;
            return;
        }
        int mid=(l+r)/2;
        double mv=(lv+rv)/2;
        i = buf[mid];
        tag[i] = mv;
        build(lc[i],l,mid-1,lv,mv);
        build(rc[i],mid+1,r,mv,rv);
        up(i);
    }
    void rebuild(int& i,double lv,double rv){
        buf_sz = 0;
        flatten(i);
        build(i,1,buf_sz,lv,rv);
    }
    void insert(int& i,int p,double lv,double rv){
        if(!i)return void(init(i,p,lv,rv));
        if(cmp(p,i))
            insert(lc[i],p,lv,tag[i]);
        else 
            insert(rc[i],p,tag[i],rv);
        up(i);
        if(!balance(i))rebuild(i,lv,rv);
    }
    void remove(int& i,int p,double lv,double rv){
        if(!i)return ;
        if(i==p){
            if(!lc[i]||!rc[i]){
                i=lc[i]|rc[i];
                rebuild(i,lv,rv);
            }else {
                int ni = lc[i];
                while(rc[ni])ni=rc[ni];
                remove(lc[i],ni,lv,tag[i]);
                lc[ni]=lc[i];
                rc[ni]=rc[i];
                i=ni;
                tag[i]=(lv+rv)/2;
            }
        }else {
            double mv=(lv+rv)/2;
            if(cmp(p,i))
                remove(lc[i],p,lv,mv);
            else 
                remove(rc[i],p,mv,rv);
        }

        up(i);
        if(!balance(i))rebuild(i,lv,rv);
    }
    // 后缀平衡树 相关操作 ：
    // 比较外部 s 与第 p 个后缀  
    bool cmp1(const string& s,int len,int p){
        for(int i=1;i<=len;i++,p--)// s 已经是反串了 仅 p 需要--
            if(s[i]!=t[p])return s[i]<t[p];
        return false;
    }
    // 查询 s 在 len 中的排名 字典序小于等于 s 的后缀的数量 
    int query(int i,const string& s,int len){
        if(!i)return 0;
        if(cmp1(s,len,i))
            return query(lc[i],s,len);
        else 
            return sz[lc[i]] + 1 + query(rc[i],s,len);
    }
    // 后缀平衡树仅支持在 头部添加 删除 字符 
    void push(char c){
        t[++n]=c;
        insert(root,n,0,INF);
    }
    void pop(){
        remove(root,n,0,INF);
        n--;
    }
    int count(string s) {
        // 给定一个 0-base 的串 s 
        // 要求 统计 s 出现的次数
        // 只需要计算 (s+'{') - (s_back-1 + '{') 这个差值
        int res = 0;
        int len = s.size();
        s = " " + s;
        s.push_back(127);
        res += query(root, s, len + 1);
        s[len]--;
        res -= query(root, s, len + 1);
        return res;
    }
}T;
void solve(){
    cin>>q;
    T.init();
    string a;
    cin>>a;
    for(auto c:a)T.push(c);
    int mask=0;
    while(q--){
        cin>>type;
        if(type=="ADD"){
            cin>>a;
            int na = a.size();
            decode(a,a.size(),mask);
            for(auto c:a)T.push(c);
        }else if(type=="DEL"){
            int x;
            cin>>x;
            while(x--)T.pop();
        }else if(type=="QUERY"){
            cin>>a;
            int na=a.size();
            decode(a,na,mask);
            reverse(a.begin(),a.end());
            int ans = T.count(a);
            cout<<ans<<"\n";
            mask^=ans;
        }
    }
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    int t=1;
    while(t--)solve();
}