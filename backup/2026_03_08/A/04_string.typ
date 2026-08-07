#import "../lib.typ": *


= 字符串

== 字符串基础

1. 字符串集 $Sigma$ 是全序集合，即大小关系形成链状
2. 长度： $|S|$ 
3. 字符： $S[i]$  $"0-base 或 1-base(题目表述)"$ 
4. 子串： $S[i..j]$ 当 $i>j$ 时为空串
5. 子序列： $S[p_1],S[p_2],S[p_3],...,S[p_k],1 <= p_1 < p_2 < ... < p_k <= |S| $  
6. 后缀：指从某个位置 $i$ 开始 到整个串末尾结束的一个特殊子串
7. 真后缀：除了 $S$ 本身的 $S$ 的后缀
8. 前缀：从串首开始，到某个位置 $i$ 结束的一个特殊子串
9. 真前缀：除了 $S$ 本身的 $S$ 的前缀
10. 字典序：以第 $i$ 个字符作为第 $i$ 关键字比较，空字符小于字符集内的任何字符
11. 回文串：正写倒写相同的字符串 $S[i]=S[|S|-i+1]$ 
12. 汉明距离：两个等长字符串之间的距离，对应位字符不同的数量
13. 字符串的存储：c风格 `'\0'` 结尾，c++风格 `string` 
14. 字符串周期：$0<p<|s|,若 s[i]==s[i+p]$ 对所有 $i in$ $[0,|s|-p-1]$ 成立,则称p是s的周期 
15. border：$0 <= r < |s|$ 若 $s$ 长度为 $r$ 的前缀和长度为 $r$ 的后缀相等,就称 $s$ 长度为 $r$ 的前缀是 $s$ 的 $"border"$ 
16. border与周期： $s$ 有长度为 $r$ 的 $"border"$ $->$ $|s|-r$ 是 $s$ 的周期 
17. border与最小周期： $|s|-\pi[n-1]$ 是 $s$ 的最小周期 

== 标准库

#note[
  感觉不如 `<algorithm>`
]

- `sscanf(char *str,"%d",&a)`：从字符串 `str` 里读取变量。
- `sprintf(char *str,"%d",i)`：将 `format` 字符串里的内容输出到 `str` 中。
- `strlen(char *str)`：返回从 `str[0]` 直到 `'\0'` 的字符数。未开启 *O2 优化* 时是 $Θ(N)$ 的。
- `strcmp(char *str1, char *str2)`：str1 - str2 的符号，但并非都是 `0`、`1`、`-1`。
- `strcpy(char *str, char *src)`: 把 `src` 复制到 `str` 中，返回值为 `str` 包含空终止符号 `'\0'`。
- `strncpy(char *str, char *src, int cnt)`：复制至多 `cnt` 个字符到 `str` 中，若 `src` 终止而数量未达 `cnt` 则写入空字符到 `str` 直至写入总共 `cnt` 个字符。
- `strcat(char *str1, char *str2)`: 将 `str2` 接到 `str1` 的结尾，用 `*str2` 替换 `str1` 末尾的 `'\0'` 返回 `str1`。
- `strstr(char *str1, char *str2)`：若 `str2` 是 `str1` 的子串，则返回 `str2` 在 `str1` 的首次出现的地址；如果 `str2` 不是 `str1` 的子串，则返回 `NULL` , 复杂度 $O(n m)$。
- `strchr(char *str, int c)`：找到在字符串 `str` 中第一次出现字符 `c` 的位置，并返回这个位置的地址。如果未找到该字符则返回 `NULL`。
- `strrchr(char *str, int c)`：找到在字符串 `str` 中最后一次出现字符 `c` 的位置，并返回这个位置的地址。如果未找到该字符则返回 `NULL`。

```cpp
// sstream:
string s;
getline(cin,s,',');// 第三个参数是可选的结束符
sstream ss(s);// 初始化
ss>>a;// 弹出
ss<<"\n";// 推入
// istream
cin.peek();// 探查字符
cin.(n);// 忽略 n 个字符
cin>>ws;// 忽略空字符
cin.get();// 相当于 getchar();
cin.getline(s,',');// 类似getline(cin,s,',');
cin.putback(c);// 放回之前“读取过”的一个字符 ???
cin.unget();// 放回读取过的上一个字符
```

== 字符串哈希

#note[
  卡 hash 没写
]

```cpp
const int N=2e5+5;
const LL mod = (int)1e9^20245991,base=233;
// 辅助
LL powb[N];
void init(){
    powb[0]=1;
    for(int i=1;i<N;i++)powb[i]=powb[i-1]*base%mod;
}
// 推荐1-base
struct HashString{
    int n;
    vector<LL> h;
    HashString(const string& s){
        n=s.size();
        h.resize(n+1);
    	for(int i=1;i<=n;i++)
    		h[i]=(h[i-1]*base+s[i-1])%mod;
    }
    // 简记：l=r时怎么算
    LL get(int l,int r){
        return (h[r]-h[l-1]*powb[r-l+1]%mod+mod)%mod;
    }
};
// 单次计算
LL getHash(const string& s){
    LL res=0;
    for(auto c:s)res=(res*base+c)%mod;
    return res;
}
```

== Trie

=== 基本Trie

+ 时间/空间 $O(|S|)$ 

```cpp
/* P8306 */
const int N=3e6+5,M=62;
struct Trie{
    inline static int tot=0,st=0; 
    int son[N][M];
    int pass[N];
    int cnt[N];
    void init(){
        st=++tot;
    }
    int path(char c){
        if(isdigit(c))return c-'0';
        if(islower(c))return c-'a'+10;
        if(isupper(c))return c-'A'+36;
		return -1;
    }
	int insert(const string& s){
        int cur=st;
        pass[cur]++;
        for(auto c:s){
            int to=path(c);
            if(!son[cur][to])son[cur][to]=++tot;
            cur=son[cur][to];
            pass[cur]++;
        }
        cnt[cur]++;
        return cur;
    }
    int count_prefix(const string& s){
        int cur=st;
        for(auto c:s){
            int to=path(c);
            if(!son[cur][to])return 0;
            cur=son[cur][to];
        }
        return pass[cur];
    }
    int count_string(const string& s){
        int cur=st;
        for(auto c:s){
            int to=path(c);
            if(!son[cur][to])return 0;
            cur=son[cur][to];
        }
        return cnt[cur];
    }
    int erase(const string& s){
        if(!count_string(s))return 0;
        int cur=st;
        pass[cur]--;
        for(auto c:s){
            int to=path(c);
           	if(!--pass[son[cur][to]]){
                son[cur][to]=0;
                return 1;
            }
            cur=son[cur][to];
        }
        cnt[cur]--;
        return 1;
    }
}T;
```

=== 01Trie维护最大异或

```cpp
void get(int x) {
  int res = 0;
  for (int i = 30, u = 1; i >= 0; --i) {
    int c = ((x >> i) & 1);
    if (ch[u][c ^ 1]) {  // 如果能向和当前位不同的子树走，就向那边走
      u = ch[u][c ^ 1];
      res |= (1 << i);
    } else
      u = ch[u][c];
  }
  ans = max(ans, res);  // 更新答案
}
```

=== 01Trie维护异或和

维护一些数字的异或和，支持修改（删除 + 重新插入），和全局加一（即：让其所维护所有数值递增 `1` ，本质上是一种特殊的修改操作）。

如果要维护异或和，需要按值从低位到高位建立 trie。

```cpp
namespace trie {
constexpr int MAXH = 21;
int ch[_ * (MAXH + 1)][2], w[_ * (MAXH + 1)], xorv[_ * (MAXH + 1)];
int tot = 0;
int mknode() {
  ++tot;
  ch[tot][1] = ch[tot][0] = w[tot] = xorv[tot] = 0;
  return tot;
}
void maintain(int o) {
  w[o] = xorv[o] = 0;
  if (ch[o][0]) {
    w[o] += w[ch[o][0]];
    xorv[o] ^= xorv[ch[o][0]] << 1;
  }
  if (ch[o][1]) {
    w[o] += w[ch[o][1]];
    xorv[o] ^= (xorv[ch[o][1]] << 1) | (w[ch[o][1]] & 1);
  }
  w[o] = w[o] & 1;
}
// 插入
void insert(int &o, int x, int dp) {
  if (!o) o = mknode();
  if (dp > MAXH) return (void)(w[o]++);
  insert(ch[o][x & 1], x >> 1, dp + 1);
  maintain(o);
}
// 删除
void erase(int o, int x, int dp) {
  if (dp > 20) return (void)(w[o]--);
  erase(ch[o][x & 1], x >> 1, dp + 1);
  maintain(o);
}
// 全局加一
void addall(int o) {
  swap(ch[o][0], ch[o][1]);
  if (ch[o][0]) addall(ch[o][0]);
  maintain(o);
}
}  // namespace trie
```

=== 01Trie合并

#note[
  其实 trie 都可以合并，换句话说，trie 合并不仅仅限于 01-trie。
]

```cpp
int merge(int a, int b) {
  if (!a||!b) return a|b;
  // 如果 a, b 都存在，那就把 b 的信息合并到 a 上
  w[a] = w[a] + w[b];
  xorv[a] ^= xorv[b];
  // 不要使用 maintain()，
  // maintain() 是合并a的两个儿子的信息
  // 而这里需要 a b 两个节点进行信息合并
  ch[a][0] = merge(ch[a][0], ch[b][0]);
  ch[a][1] = merge(ch[a][1], ch[b][1]);
  return a;
}
```

=== 可持久化字典树

#note[
  见【可持久化数据结构】
]

== KMP

=== 基本KMP

#note[
  $\pi[i]$ 原来叫前缀函数啊
]

+ 时间/空间 $O(n+m)$
+ 这是一个动态算法

```cpp
/* KMP P3375*/
vector<int> getNe(const string& s){
    int n=s.size();
    vector<int> ne(n);// 0-base
    for(int i=1,j=0;i<n;i++){
        while(j&&s[i]!=s[j])j=ne[j-1];
        if(s[i]==s[j])j++;
        ne[i]=j;
    }
    return move(ne);
}
vector<int> KMP(const string& s,const string& p){
    vector<int> pos;
    vector<int> ne=getNe(p);
    int n=s.size(),m=p.size();
    for(int i=0,j=0;i<n;){
        while(j&&s[i]!=p[j])j=ne[j-1];// 注意:不要都写成s了
        if(s[i]==p[j])i++,j++;
        else i++;
        if(j==m)pos.push_back(i-j),j=ne[j-1];
    }
    return move(pos);
}
// 2. Wiki版
vector<int> prefix_function(string s) {
  int n = (int)s.length();
  vector<int> pi(n);
  for (int i = 1; i < n; i++) {
    int j = pi[i - 1];
    while (j > 0 && s[i] != s[j]) j = pi[j - 1];
    if (s[i] == s[j]) j++;
    pi[i] = j;
  }
  return pi;
}
vector<int> find_occurrences(string text, string pattern) {
  string cur = pattern + '#' + text;
  int sz1 = text.size(), sz2 = pattern.size();
  vector<int> v;
  vector<int> lps = prefix_function(cur);
  for (int i = sz2 + 1; i <= sz1 + sz2; i++) {
    if (lps[i] == sz2) v.push_back(i - 2 * sz2);
  }
  return v;
}
```

=== KMP自动机

+ 时间/空间 $O(|Sigma|n)$ 

+ 该自动机在什么时候有用呢？首先，记得大部分时候我们为了一个目的使用字符串 $s + \# + t$ 的前缀函数：寻找字符串 s 在字符串 t 中的所有出现。

+ 因此使用该自动机的最直接的好处是 加速计算字符串 $s + \# + t$ 的前缀函数。

+ 通过构建 $s + \#$ 的自动机，我们不再需要存储字符串 s 以及其对应的前缀函数值。所有转移已经在表中计算过了。

+ 但除此以外，还有第二个不那么直接的应用。我们可以在字符串 t 是 某些通过一些规则构造的巨型字符串 时，使用该自动机加速计算。Gray 字符串，或者一个由一些短的输入串的递归组合所构造的字符串都是这种例子。

```cpp
/* KMP 自动机 p3375 KMP模板*/
const int N=2e6+5,M=26;
struct KMPAM{
	int ch[N][M];// ch[i][j] 表示s[i]匹配到j字符后转移方向 注意：1-base
   	int ne[N];// 真的ne数组 注意：此时是1-base了 相当于原来的下标+1即可
    // ne 和 ch 交集不多
    // 自动机真的要有一个0原点啊啊啊 想想AC自动机就知道了
	void init(const string& s){// 0-base
        int n=s.size();
        for(int i=1;i<=n;i++){
            // 注意：在写道这里时，我愣了一下，发现ne[i]确实是border长度,用来跳的是ne[i-1]
            // 设置自己的fail 注意：只有这里是i
            ne[i]=ch[ne[i-1]][s[i-1]-'a'];
            // 注意："最后"设置上一个可以继续的答案 必须是上一个了,因为需要衔接0且对于n没有下一个
            ch[i-1][s[i-1]-'a']=i;
            // 注意：然后才能设计当前的答案 因为ch[ne[i]]会依赖之前的ch!
            // 可以当前计算，因为0的fail先设必然都是0
            for(int c=0;c<M;c++)ch[i][c]=ch[ne[i]][c];
        }
    }
    // 用法：
    // 起始节点为j=0
    // 根据输入，假设s为1-base
    // 转移到下一个可以匹配的位置
    // 注：转移到的地方已经完成匹配
    // 故命中依据为j==n
    // 该自动机可以自适应多次匹配
    // 即j==n时自动跳fail
}kmpam;
// 2.Wiki版
void compute_automaton(string s, vector<vector<int>>& aut) {
  s += '#';
  int n = s.size();
  vector<int> pi = prefix_function(s);
  aut.assign(n, vector<int>(26));
  for (int i = 0; i < n; i++) {
    for (int c = 0; c < 26; c++) {
      if (i > 0 && 'a' + c != s[i])
        aut[i][c] = aut[pi[i - 1]][c];
      else
        aut[i][c] = i + ('a' + c == s[i]);
    }
  }
}
```

== BM

#note[
  略
]

== 扩展KMP

#note[
  时间/空间 $O(n+m)$ \
  在模式串匹配方面 原来 exKMP *可以代替* KMP    \
  因为` lcp[i]==m` 即为KMP的匹配
]

+ 时间/空间 $O(n+m)$

```cpp
/* P5410 exKMP模板 */
vector<int> getZ(const string& s){
    int n=s.size();
    vector<int> z(n);
    z[0]=n;// wiki上说要设为0?
    // 注意 r 为首个未知领域开区间)
    // 注意 len 因r的开区间而计算准确
    // 注意没有任何+-1
    for(int i=1,r=1,c,len;i<n;i++){
        // 非未知 则len 直达 r or z[i-c]  
        len=i<r?min(r-i,z[i-c]):0;
        while(i+len<n&&s[len]==s[i+len])len++;
        if(r<i+len){
            c=i;
            r=i+len;
        }
        z[i]=len;
    }
    return move(z);
}
// s的各种后缀与 p前缀的公共串长
// 注意：我看到这里又想起来了，扩展kmp比kmp更强！
vector<int> exKMP(const string& s,const string& p){
    int n=s.size(),m=p.size();
    vector<int> z=getZ(p);
    vector<int> lcp(n);
    for(int i=0,r=0,c,len;i<n;i++){
        // 注意 不会用到z[0]
        len=i<r?min(r-i,z[i-c]):0;
        while(len<m&&i+len<n&&p[len]==s[i+len])len++;
        if(r<i+len){
            c=i;
            r=i+len;
        }
        lcp[i]=len;
    }
    return move(lcp);
}
// 2.Wiki版
vector<int> z_function(string s) {
  int n = (int)s.length();
  vector<int> z(n);
  for (int i = 1, l = 0, r = 0; i < n; ++i) {
    if (i <= r && z[i - l] < r - i + 1) {
      z[i] = z[i - l];
    } else {
      z[i] = max(0, r - i + 1);
      while (i + z[i] < n && s[z[i]] == s[i + z[i]]) ++z[i];
    }
    if (i + z[i] - 1 > r) l = i, r = i + z[i] - 1;
  }
  return z;
}
```

== AC自动机（ACAM）

=== 基础AC自动机

+ 时间/空间 $|S|+|T|$

```cpp
/* P5357 AC自动机模板 */
const int N=2e6+5,M=26;
struct ACAM{
	inline static int tot;
    int son[N][M];// 基本的Trie结构
    int fa[N];// fail 树 收集词频是 什么情况来着
    int pass[N];// read时++
    int du[N];// 收集词频专用 在build时++ collect时--
    /*
    AC自动机收集词频方法:
    插入时尾端cnt++(略。！)
    只需要读入文本时pass[cur]++
    然后 按照fail自下而上收集词频即可
    */
    void init(){
        // 照顾 AC自动机 默认取0的原则
        memset(son,0,sizeof(son[0])*(tot+1));
        memset(fa,0,sizeof(int)*(tot+1));
        memset(pass,0,sizeof(int)*(tot+1));
        memset(du,0,sizeof(int)*(tot+1));
        tot=0;
    }
    int path(char c){
        return c-'a';
    }
    int insert(const string& s){
        int cur=0;
        for(auto c:s){
            int to=path(c);
            if(!son[cur][to])son[cur][to]=++tot;
            cur=son[cur][to];
        }
        return cur;
    }
    /* 建立fail树方法:BFS */
	void build(){
        queue<int>Q;
        for(int i=0;i<M;i++)
            if(son[0][i])Q.push(son[0][i]);
        while(Q.size()){
            int u=Q.front();Q.pop();
            for(int i=0;i<M;i++){
                if(!son[u][i]){
                    son[u][i]=son[fa[u]][i];
                }else {
                    fa[son[u][i]]=son[fa[u]][i];
                    du[son[fa[u]][i]]++;// 注意个fa
                    Q.push(son[u][i]);// 注意别忘了入队
                }
            }
        }
    }
    void read(const string& s){
        int cur=0;
        for(auto c:s){
            int to=path(c);
            cur=son[cur][to];
            pass[cur]++;
        }
    }
    void collect(){
        queue<int> Q;
        for(int i=1;i<=tot;i++){
            if(!du[i])Q.push(i);
        }
        while(Q.size()){
            int u=Q.front();Q.pop();
            pass[fa[u]]+=pass[u];
            if(!--du[fa[u]])Q.push(fa[u]);
        }
    }
}acam;
```

=== AC自动机与上DP

#note[
  大意：第 `i` 个字符，枚举 ACAM `tot` 个节点, 然后枚举 后继做转移
]

== 后缀数组（SA）

+ 时间 $O(n)$ 常数大  
+ 空间 $O(n)$  

```cpp
/* 基数排序没学会 P3809 P10469 */
const int N=1e6+5,M=1<<8;
string s;
struct SA{
    // a[i]:排序后 排名第i个后缀的编号
    // ta[]:辅助 a
    // rk[i]:i号后缀在排序后的位置
    // trk[]:辅助rk 单换
    // cnt[]:特别注意: 桶rk种类会增加 注意开到和数组长度相同！！
    int a[N*2],ta[N],rk[N*2],trk[N*2],cnt[N],n,m,p;
	  int height[N];
    string s;
    void init(const string& _){
        s=_;
        n=s.size();
        m=M-1;
        p=0;
        // 这里已经由字符串信息转为rk信息了
        for(int i=1;i<=n;i++)cnt[rk[i]=s[i-1]]++;
        // rk累计起来
        for(int i=1;i<=m;i++)cnt[i]+=cnt[i-1];
        // 根据cnt大到小 倒序根据大rk范围倒序插入
        for(int i=n;i>=1;i--)a[cnt[rk[i]]--]=i;
        
        // 只对 +w个字符 排序
        for(int w=1;w<=n;w<<=1,m=p){
            int cur=0;
            
            // 这里我们排序只看+的w个字符 由于均为空 所以这里正序倒序均可
            for(int i=n;i>n-w;i--)ta[++cur]=i;
            // 是在正序枚举+w的字符然后倒推对应的原串 将原串加入
            for(int i=1;i<=n;i++)if(a[i]>w)ta[++cur]=a[i]-w;

            // 类似于将本次排序信息合并上来
            memset(cnt,0,sizeof cnt);
            for(int i=1;i<=n;i++)cnt[rk[i]]++;
            for(int i=1;i<=m;i++)cnt[i]+=cnt[i-1];
            for(int i=n;i>=1;i--)a[cnt[rk[ta[i]]]--]=ta[i];

            p=0;// 重新统计rk量(区分度)
            memcpy(trk,rk,sizeof rk);
            // 容错:rk[0]=0 rk[i]>0 
            for(int i=1;i<=n;i++){
                if(trk[a[i]]!=trk[a[i-1]]||trk[a[i]+w]!=trk[a[i-1]+w])p++;
                rk[a[i]]=p;
            }
            if(p==n)break;
        }
    }
    /* height 与 h */
    // height[i]=lcp(sa[i],sa[i-1])
    // h[i] = height[rk[i]] = lcp(sa[rk[i]],sa[rk[i]-1]) = lcp(i,sa[rk[i]-1])
    // h[i] 有性质 h[i]>=h[i-1]-1 可以快速暴力递推
    // 快速求得 h[i] 即可快速求得 height[i]
    // 对于 rk[i]=1 h[i]=lcp(i,sa[0])=0 特判h=0
    // h[i-1] = height[rk[i-1]] ???
    void get_height(){
        for(int i=1,h=0;i<=n;i++){
            if(rk[i]==1)h=0;
            else {
                // 这里表示继承 h[i]=h[i-1]-1 始终 h>=0
                if(h)h--;
                // 暴力求解
                int j=a[rk[i]-1];
                while(i+h<=n&&j+h<=n&&s[i+h-1]==s[j+h-1])h++;
            }
            height[rk[i]]=h;
        }
    }
    /* 食用方法 */
    // 排名i与j的lcp
    // func(i,j) = lcp(sa[i],sa[j]) = min(height[i<k<=j]) = RMQ[i+1,j]
    // 编号a与b的lcp
    // LCP(a,b) = func(rk[a],rk[b])  
    
    int st[N][__lg(N)+2];
    int P;
    void build(){
        P=__lg(n)+1;
        for(int i=1;i<=n;i++)st[i][0]=height[i];
        for(int p=1;p<=P;p++)
          for(int i=1;i<=n;i++){
            int mid=min(n,i+(1<<(p-1)));
            st[i][p]=min(st[i][p-1],st[mid][p-1]);
          }
    }
    int lcp(int a,int b){
        if(a==b)return n+1-a;// 我认为相同的串 lcp 应该是 len
        int l=rk[a],r=rk[b];
        if(l>r)swap(l,r);
        l++;
        int p=__lg(r-l+1);// 倍增覆盖
        return min(st[l][p],st[r-(1<<p)+1][p]);
    }
}sa;
```

== 后缀自动机（SAM）

+ 时间/空间 $O(|S|)$

```cpp
/* SAM P3804*/
const int N=2e6+5,M=26,inf=1e9+7;
struct SAM{
    // 基础部分
    int tot,np,p,ch[N*2][M],fa[N*2],cnt[N*2],len[N*2];
    vector<int> e[N*2];
    // [扩展部分]
    int num[N*2];// 1.[parent树等价类的出现次数]
    LL sum[N*2];// 2/[DAG图节点及其后继包含的子串数量]
    bool vis[N*2];// 3.[DAG图遍历的记忆化]
    int cntP,fpos[N*2];// 4.[计数器 与 parent树等价类最左位置,第i个后缀为i,其余为inf]
    int status[N*2];// 5.[状压记录所含串]

    // 初始化
    void init(){
        #define mst(arr) memset(arr,0,sizeof(arr[0])*(tot+1));
        for(int i=0;i<=tot;i++)e[i].clear();// 清树
        mst(ch);mst(fa);mst(cnt);mst(len);// 基础
        mst(num);mst(sum);mst(vis);mst(fpos);mst(status);// 1-5[扩展部分]
        tot=np=1;// 最后更新 tot
        cntP=0;// 4.[计数器清零]
        #undef mst(arr)
    }
    
    int path(char _){return _-'a';}// 映射

    // 加入字符 5.[扩展参数id:标记所属模串的status]
    void extend(char _,int id=0){
        int c=path(_);p=np;np=++tot;
        cnt[np]=1;
        len[np]=len[p]+1;
        fpos[np]=++cntP;// 4.[等价类最左位置]
        status[np]=1<<id;// 5.[多模串标记]
        for(;p&&!ch[p][c];p=fa[p])ch[p][c]=np;
        if(!p)fa[np]=1;
        else {
            int q=ch[p][c];
            if(len[q]==len[p]+1)fa[np]=q;
            else {
                int nq=++tot;
                len[nq]=len[p]+1;
                fa[nq]=fa[q];
                fa[np]=fa[q]=nq;
                memcpy(ch[nq],ch[q],sizeof(ch[q]));
                for(;p&&ch[p][c]==q;p=fa[p])ch[p][c]=nq;
                fpos[nq]=inf;// 4.[等价类最左位置标记inf]
            }
        }
    }
    
    // 加入字符串 5.[扩展参数id:标记该模串的status]
    void insert(const string& s,int id=0){for(auto c:s)extend(c,id);}
    
    // 建parent树 e
    void build(){for(int i=2;i<=tot;i++)e[fa[i]].push_back(i);}
    
    // 1.匹配子串
    bool contains(const string& s){
        int cur=1;
        for(auto _:s){
            cur=ch[cur][path(_)];
            if(!cur)return false;
        }return true;
    }
    
    // 2.去重子串个数
    int substr_count(){
        int res=0;
        for(int i=2;i<=tot;i++)res+=len[i]-len[fa[i]];
        return res;
    }
    
    // 3.获取去重子串(1-base区间)
    pair<int,int> substrs(int u,vector<pair<int,int>>& res){
        pair<int,int> lr;
        int n=len[u]-len[fa[u]];
        for(auto v:e[u])lr=substrs(v,res);
        auto[l,r]=lr;
        if(e[u].empty())l=1,r=len[u];
        for(int i=0;i<n;i++)res.push_back({l+i,r});
        return {l+len[u]-len[fa[u]],r};
    }
    
    // 4.去重子串总长度
    int substrs_length(){
        int res=0;
        for(int i=2;i<=tot;i++)res+=1LL*len[i]*(len[i]+1)/2;
        return res;
    }
    
    // 5.[去重/可重第 k 小非空子串][需要扩展1.2.3.] [P3975 弦论]
    // 去重：直接将所有的 num 改为 1 即可 (除了num[1]=0)
    void set_num(){
        fill(num+1,num+1+tot,1);
        num[1]=0;
    }
    // 可重：dfs 遍历 parent 树, num 初始为 cnt 并累加子 num (除了num[1]=0)
    void dfs_num(int u=1){
        num[u]=cnt[u];
        for(auto v:e[u]){
            dfs_num(v);num[u]+=num[v];
        }num[1]=0;
    }
    // 正序收集子“树”的出现次数
	void dfs_sum(int u=1){
        if(vis[u])return;// 注意：DAG记忆化
        vis[u]=true;
        sum[u]=num[u];
        for(int c=0;c<M;c++)if(ch[u][c]){
            dfs_sum(ch[u][c]);
            sum[u]+=sum[ch[u][c]];
        }
    }
    // 第 k 大真子串 (0为空串)(1-base)
    void find_kth(int u,int k,string& res){
        if(k<=num[u])return;
        k-=num[u];
        for(int c=0;c<M;c++){
            if(!ch[u][c])continue;
            if(k<=sum[ch[u][c]]){
                res+=char('a'+c);
                find_kth(ch[u][c],k,res);
            	return;
            }else k-=sum[ch[u][c]];
        }
    }
    
    // 6.最小循环移位(或最小n长度循环子串)(循环移位等价类字典序最小)
    // 注意：需要插入两次 s
    void min_cicle(int n,string& res){
        int cur=1;
        while(n--)for(int c=0;c<M;c++)if(ch[cur][c]){
            res+=char('a'+c);
            cur=ch[cur][c];
            break;
        }
    }
    
    // 7.[出现次数(contains升级版)][需要扩展1.3.和 dfs_num]
    int count(const string& s){
        int cur=1;
        for(auto _:s){
            cur=ch[cur][path(_)];
            if(!cur)return 0;
        }return num[cur];
    }
    
    // 8.[最早出现位置(1-base)][需要扩展4.]
    // 预处理 fpos
    void dfs_fpos(int u=1){
        for(auto v:e[u]){
            dfs_fpos(v);
            fpos[u]=min(fpos[u],fpos[v]);
        }
    }
    // 读串, 找到答案
    int first_pos(const string& s){
        int cur=1;
        for(auto c:s){
            cur=ch[cur][path(c)];
            if(!cur)return -1;
        }
        return fpos[cur]-(int)s.size()+1;
    }
    
    // 9.[所有出现的位置][需要扩展4.和 dfs_pos]
    // 向所有的父串递归
    void dfs_all_pos(int u,int n,vector<int>& res){
        if(cnt[u])res.push_back(fpos[u]-n+1);
        for(auto v:e[u])dfs_all_pos(v,n,res);
    }
    void all_pos(const string& s,vector<int>& res){
        int cur=1;
        for(auto c:s){
            cur=ch[cur][path(c)];
            if(!cur)return;
        }
        dfs_all_pos(cur,s.size(),res);
    }
    
    // 10.最短的没有出现过的字符串(略)(选最小高度)
    
    // 11.最长公共子串(LCS)
    string LCS(const string& p){
        // 注意：l 匹配的可能不是等价类中的最长子串 不能用len 只能自己算
        int cur=1,l=0,pos=0,maxl=0,n=p.size();
        for(int i=0;i<n;i++){
            int c=path(p[i]);
            while(cur&&!ch[cur][c])cur=fa[cur],l=len[cur];
            if(cur)l++,cur=ch[cur][c];
            else l=0,cur=1;
            if(l>maxl)maxl=l,pos=i;
        }
        return p.substr(pos-maxl+1,maxl);
    }

    // 12.[多模最长公共子串(mLCS)(单独使用)][需要扩展5.和 dfs_status]
    // 求可达性
    void dfs_status(int u=1){
        for(auto v:e[u]){
            dfs_status(v);
            status[u]|=status[v];
        }
    }
    string multi_LCS(vector<string>& strs){
        init();
        // 注意：每次都要移回原位置
        for(int i=0;i<strs.size();i++)np=1,insert(strc[i],i);
        build();
        dfs_status(1);
        string& s=strs.front();
        int pos=0,l=0,lmax=0,cur=1,n=s.size(),m=(1<<strs.size())-1;
        for(int i=0;i<n;i++){
            int c=path(s[i]);
            if(status[ch[cur][c]]==m)l++,cur=ch[cur][c];
            else {
                while(cur&&status[ch[cur][c]]!=m)cur=fa[cur];
                if(cur)l=len[cur]+1,cur=ch[cur][c];
                else l=0,cur=1;
            }
            if(l>lmax)lmax=l,pos=i;
        }
        return s.substr(pos-lmax+1,lmax);
    }
}sam;
```

== 后缀平衡树

+ 后缀平衡树的优点
    + 后缀平衡树的思路比较清晰，相比后缀自动机等后缀结构更好理解，会写平衡树就能写。
    + 后缀平衡树的复杂度不依赖于字符集的大小
    + 后缀平衡树支持在字符串开头删除一个字符
    + 如果使用支持可持久化的平衡树，那么后缀平衡树也能可持久化

#note[
【模板】后缀平衡树：\
+ 给定初始字符串 `s` 和 `q` 个操作： \
+ 在当前字符串的后面插入若干个字符。 \
+ 在当前字符串的后面删除若干个字符。 \
+ 询问字符串 `t` 作为连续子串在当前字符串中出现了几次？ \
+ 题目 *强制在线*，$"字符串变化长度,初始长度"$ $<= 8 times 10^5$，$q <= 10^5$，$"询问的总长度"$ $<= 3 times 10^6$ 。
]

```cpp
//【模板】后缀平衡树
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
            a=" "+a;
            a.push_back('Z'+1);
            int ans=T.query(T.root,a,na+1);
            --a[na];
            ans -= T.query(T.root,a,na+1);
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
```

== 广义后缀自动机（GSAM）

- 性质：
    + 广义后缀自动机与后缀自动机的结构一致，在后缀自动机上的性质绝大部分均可在广义后缀自动机上生效（后缀自动机的性质）
    + 当广义后缀自动机建立后，通常字典树结构将会被破坏，即通常不可以用广义后缀自动机来解决字典树问题。当然也可以选择准备双倍的空间，将后缀自动机建立在另外一个空间上。

- 时间/空间 $O(|S|)$

```cpp
/* 广义后缀自动机 GSAM 处理多串匹配 */
const int N=2e6+5,M=26;
struct GSAM{
    // [基础] 
    int tot,p,np,c,ch[N*2][M],fa[N*2],len[N*2],cnt[N*2];
    int pre[N*2][2];// 求原Trie的父节点与边
    vector<int> e[N*2];
    // [扩展]
    int status[N*2],cntString;//

    void init(){
        #define mst(arr) memset(arr,0,sizeof(arr[0])*(tot+1));
        for(int i=0;i<=tot;i++)e[i].clear();
        mst(ch);mst(fa);mst(len);mst(cnt);mst(pre);// 基础
        mst(status);// [扩展]
        np=tot=1;
        cntString=0;// [扩展]
        #undef mst
    }

    int path(char c){
        return c-'a';
    }

    // [扩展id:多串LCS]
    int insert(const string& s,int id=0){
        int cur=1;
        for(auto _:s){
            c=path(_);
            if(!ch[cur][c])ch[cur][c]=++tot,pre[tot][0]=cur,pre[tot][1]=c;
            cur=ch[cur][c];
            status[cur]|=1<<id;// [扩展]
        }
        return c;
    }

    int extend(int p,int c){
        np=ch[p][c];
        len[np]=len[p]+1;
        p=fa[p];// 必须跳一格 因为之前已经有了
        for(;p&&!ch[p][c];p=fa[p])ch[p][c]=np;
        if(!p)fa[np]=1;
        else {
            int q=ch[p][c];
            if(len[q]==len[p]+1)fa[np]=q;
            else {
                int nq=++tot;
                len[nq]=len[p]+1;
                fa[nq]=fa[q];
                fa[np]=fa[q]=nq;
                memcpy(pre[nq],pre[q],sizeof(pre[nq]));// 
                for(;p&&ch[p][c]==q;p=fa[p])ch[p][c]=nq;
                for(int i=0;i<M;i++)if(len[ch[q][i]])ch[nq][i]=ch[q][i];
            }
        }
        return np;
    }

    // bfs 建立自动机
    void build(){
        queue<int> Q;
        Q.push(1);
        while(Q.size()){
            int u=Q.front();Q.pop();
            for(int i=0;i<M;i++)if(ch[u][i]){
                extend(u,i);
                Q.push(ch[u][i]);
            }
        }
        // 别忘了还有 parent树 
        for(int i=2;i<=tot;i++)e[fa[i]].push_back(i);
    }
    
    // 去重子串个数 
    LL substr_count(){
        LL res=0;
        for(int i=2;i<=tot;i++)res+=len[i]-len[fa[i]];
        return res;
    }

    // [多串LCS(单独使用)]
    string multi_LCS(vector<string>& strs){
        init();
        for(auto &s:strs)insert(s,cntString),cntString++;
        build();
        dfs_status(1);
        int pos=0,maxl=0,m=(1<<cntString)-1;
        for(int i=2;i<=tot;i++)
            if(status[i]==m&&len[i]>maxl)maxl=len[i],pos=i;
        string res;
        while(maxl--){
            res+=char(pre[pos][1]+'a');
            pos=pre[pos][0];
            assert(pos);
        }
        reverse(res.begin(),res.end());
        return res;
    }

    // parent树dfs就是len的倒序遍历
    void dfs_status(int u){
        for(auto v:e[u]){
            dfs_status(v);
            status[u]|=status[v];
        }
    }

}gsam;
void solve(){
    // 去重子串数量
    // int n;
    // string s;
    // cin>>n;
    // gsam.init();
    // while(n--)cin>>s,gsam.insert(s);
    // gsam.build();
    // cout<<gsam.substr_count()<<'\n';
    // cout<<gsam.tot<<'\n';
    
    // 多模公共子串
    string s;
    vector<string> strs;
    while(cin>>s)strs.emplace_back(s);
    for(auto& s:strs)cin>>s;
    cout<<gsam.multi_LCS(strs).size()<<'\n';
}
signed main(){solve();return 0;}
```

== 后缀树

=== 前端动态添加字符-SAM反串

#note[
  见【SAM】
]

=== 后端动态添加字符-Ukkonen

```cpp
const int N=1e6+5,inf=1e9+7,M=27;
// Ukkonen 算法支持后端动态添加字符
struct SufTree{
    // 主要懒信息： now懒后缀节点 rem懒边长度 
    // 注意：fa和parent树差不多但不是后缀树，因为后缀树是ch表示的
    // 既然这么说的话，SAM反串不就是后缀图吗，怎么就是后缀树呢？
    // 原来 反串SAM 的parent树 才是后缀树 （确实）
    // 那这么看的话，在那个parent树仪式性的加上边的首字符，不就是ch了吗（确实）
    int tot,now,rem,n,ch[N*2][M],st[N*2],len[N*2],fa[N*2];
    int s[N];
    int cnt[N*2];// 扩展：该串作为后缀的前缀的次数(子串出现次数)
    int dep[N*2];// 扩展：该串长度
    int vis[N*2];// 扩展：时间戳版vis 记录不同串的访问
    void init(){
        #define mst(arr) memset(arr,0,sizeof(arr[0])*(tot+1));
        mst(ch);mst(st);mst(len);mst(fa);// 基础
        mst(cnt);mst(dep);mst(vis);// 扩展
        now=tot=1;rem=n=0;
        len[0]=inf;
        #undef mst
    }
    int path(char c){
        return c-'a';// 'z'后是'{'
    }
    // 创建 sta出发le长度的边 为父边的儿子
    int new_node(int sta,int le){
        st[++tot]=sta;
        len[tot]=le;
        return tot;
    }
    // 加入字符
    void extend(int x){
        s[++n]=x;// 添加字符
        ++rem;// 增加隐式后缀的长度
        for(int lst=1;rem;){
            // 其实就是找到对应的节点now和隐式后缀余量rem
            while(rem>len[ch[now][s[n-rem+1]]])
                rem-=len[now=ch[now][s[n-rem+1]]];
            int &v=ch[now][s[n-rem+1]],c=s[st[v]+rem-1];
            if(!v||x==c){
                // 不存在出边或者存在出边且字符匹配：跳到该边
                lst=fa[lst]=now;// 来到这里说明上一个节点的后缀链接就是它 
                if(!v)v=new_node(n,inf);// 新建一个出边
                else break;// x==c已存在
            }else {
                // v && x!=c 存在出边且字符串不匹配：分裂边
                int u=new_node(st[v],rem-1);// 截取rem-1
                ch[u][x]=new_node(n,inf);// u新加x出边
                ch[u][c]=v;// v新儿子
                st[v]+=rem-1;// 父边起始位置延后
                len[v]-=rem-1;// 父边长度减少
                lst=fa[lst]=v=u;// lst的新链接是now的新儿子v=u
            }
            if(now==1)--rem;// 减一个后缀长度 
            else now=fa[now];// 跳一个子后缀 
        }
    }
    // 加入字符串
    void insert(const string& s){
        for(auto c:s)extend(path(c));
    }
    void finish(){
        extend(path('{'));
    }
    // 扩展：建立串信息(次数+长度)
    void build(int u=1,int f=0){
        dep[u]=dep[f]+len[u];
        // 注意：此处不能用 == inf
        if(len[u]>1e8)return cnt[u]=1,void();
        for(int i=0;i<M;i++)if(ch[u][i]){
            build(ch[u][i],u);
            cnt[u]+=cnt[ch[u][i]];
        }
    }
    // 扩展：查询子串及其循环同构串在文本串中的出现次数
    LL count(const string& _){
        string t=" ";LL res=0;
        for(auto c:_)t+=path(c);
        for(auto c:_)t+=path(c);
        now=1,rem=0;
        int m=_.size(),j=0;// j是 0-base 是个谜
        static int time=0;
        ++time;
        for(int i=1;i<=m;i++){// rem 不++是个谜 
            while(j<i+m-1){
                while(rem>=len[ch[now][t[j-rem+1]]])// ???
                    rem-=len[now=ch[now][t[j-rem+1]]];
                int v=ch[now][t[j-rem+1]],c=s[st[v]+rem];// rem 不 -1 是个谜 
                if(v&&c==t[j+1])++j,++rem;
                else break;
            }
            if(j==i+m-1&&vis[ch[now][t[j-rem+1]]]!=time)
                res+=cnt[ch[now][t[j-rem+1]]],vis[ch[now][t[j-rem+1]]]=time;
            if(now==1)rem--;
            else now=fa[now];
        }
        return res;
    }
}stree;
void solve(){
    // SAM模板 P3804
    // string s;LL ans=0;
    // cin>>s;stree.init();stree.insert(s);
    // stree.finish();stree.build(1);
    // for(int i=1;i<=stree.tot;i++)if(stree.cnt[i]>1)ans=max(ans,1LL*stree.cnt[i]*stree.dep[i]);
    // cout<<ans<<'\n';

    // 循环等价类计数 CF235
    string s,p;int t;
    cin>>s>>t;stree.init();stree.insert(s);stree.finish();stree.build();
    while(t--)cin>>p,cout<<stree.count(p)<<'\n';
}
signed main(){solve();return 0;}
```

== Manacher

+ 时间/空间 $O(n)$

```cpp
/* Mancher P3805 */
vector<int> Manacher(const string& _){
	string s="#";
    for(auto c:_)s+=c,s+='#';    
    int n=s.size();
    vector<int> R(n);
    for(int i=0,r=0,c=0,len;i<n;i++){
        len=i<r?min(r-i,R[c*2-i]):0;
        while(i-len>=0&&i+len<n&&s[i-len]==s[i+len])len++;
        if(r<i+len)c=i,r=i+len;
        R[i]=len-1;// 我忘了是len-1了？
    }
    return move(R);
}
```

== 回文自动机（PAM）

+ 时间/空间 $O(n)$

```cpp
const int N=1e6+5,M=26,mod=1e9+7;
struct PAM{
    int tot,lst,n,s[N],ch[N][M],fa[N],len[N];
    int cnt[N];// 子串出现次数(拓扑收集以计算正确)
    int sfa[N],dif[N];// 扩展：最小回文划分的 等差数列fail 和 falen差
    int f[N],g[N];// 扩展：最小回文划分相关dp
    
    void init(){
        #define mst(arr) memset(arr,0,sizeof(arr[0])*(tot+1))
        // #define mst(arr) memset(arr,0,sizeof(arr))
        mst(ch);mst(fa);mst(len);mst(cnt);
        mst(sfa);mst(dif);mst(f);mst(g);// 扩展
        tot=1;lst=n=0;// 注意：lst,n赋值0
        fa[0]=1;len[1]=-1;s[0]=M;// 赋值为非法值
        #undef mst
    }
    int path(char _){return _-'a';}
    int getFail(int p){for(;s[n-1-len[p]]!=s[n];p=fa[p]);return p;}
    void extend(int c){
        s[++n]=c;
        int p=getFail(lst);
        if(!ch[p][c]){
            len[++tot]=len[p]+2;
            fa[tot]=ch[getFail(fa[p])][c];// 注意：fa[p]
            ch[p][c]=tot;// 注意：必须最后赋值tot 
            // assert(fa[tot]!=tot);// 否则 fa[tot] = ch[1][c] = tot

            // 扩展：最小回文划分相关题目(分解为 log级别个 等差数列的原理) 
            dif[tot]=len[tot]-len[fa[tot]];
            if(dif[tot]==dif[fa[tot]])sfa[tot]=sfa[fa[tot]];
            else sfa[tot]=fa[tot];
        }
        lst=ch[p][c];
        cnt[lst]++;
    }
    void insert(const string& s){for(auto c:s)extend(path(c));}
    void collect(){
        for(int i=tot;i>=0;i--)cnt[fa[i]]+=cnt[i];// 回文串出现次数：拓扑序赋值 
    }
    LL count(){
        return tot-1;// 本质不同回文子串个数等于节点数减去一个 奇点 
    }
    // 扩展：最小回文划分相关题目 f**k (单独使用)
    int palindrome_paration(const string& _){
        init();// 注意第一步 init!!!!! 
        int m=_.size();
        string t=" ";
        for(int i=1;i<=m/2;i++)t+=_[i-1],t+=_[m+1-i-1];
        f[0]=1;// init 后再设置啊
        for(int i=1;i<=m;i++){
            extend(path(t[i]));
            for(int x=lst;x>1;x=sfa[x]){
                g[x] = f[i-len[sfa[x]]-dif[x]];
                if(dif[x] == dif[fa[x]])g[x]=(g[x]+g[fa[x]])%mod;
                if(i%2==0)f[i]=(f[i]+g[x])%mod;
            }
        }
        return f[m];
    }
}pam;
void solve(){
    // P3649 回文串存在值
    // string s;LL ans=0;
    // cin>>s;pam.init();pam.insert(s);pam.collect();
    // for(int i=2;i<=pam.tot;i++)ans=max(ans,1LL*pam.cnt[i]*pam.len[i]);
    // cout<<ans<<'\n';
    
    // CF923G 最小回文划分
    string s;
    cin>>s;
    cout<<pam.palindrome_paration(s)<<'\n';
}
signed main(){solve();return 0;}
```

== 序列自动机

#note[
  时间/空间 $O(|S||Sigma|)$  
]

```cpp
const int N=2e3+5,M=26;
int f[N][N*2];
struct SQAM{
    int ch[N][M];
    int nxt[M];
    int s[N];// 1-base
    int n;
    int path(char c){return c-'a';}
    // 直接 build 一次性不可变
    // PS:我想到了并查集式懒更新法实现动态序列自动机
    void build(const string& _){
        n=0;
        for(auto c:_)s[++n]=path(c);
        fill(nxt,nxt+M,n+1);
        for(int i=n;i>=0;i--){
            memcpy(ch[i],nxt,sizeof nxt);
            nxt[s[i]]=i;
        }
    }
    bool contains(const string& _){
        int cur=0;
        for(auto c:_){
            cur=ch[cur][path(c)];
            if(cur==n+1)return false;
        }
        return true;
    }
}sqam1,sqam2;
struct SAM{
    int p,np,tot,ch[N*2][M],fa[N*2],len[N*2],cnt[N*2];
    void init(){
        #define mst(arr) memset(arr,0,sizeof(arr[0])*(tot+1))
        mst(ch);mst(fa);mst(len);mst(cnt);
        tot=np=1;
        #undef mst
    }
    int path(char c){return c-'a';}
    void extend(int c){
        p=np,np=++tot;
        len[np]=len[p]+1;
        cnt[np]=1;
        for(;p&&!ch[p][c];p=fa[p])ch[p][c]=np;
        if(!p)fa[np]=1;
        else {
            int q=ch[p][c];
            if(len[q]==len[p]+1)fa[np]=q;
            else {
                int nq=++tot;
                len[nq]=len[p]+1;
                fa[nq]=fa[q];
                fa[np]=fa[q]=nq;// 注意：这里错了 fa[np]=fa[q]=nq
                memcpy(ch[nq],ch[q],sizeof(ch[nq]));
                for(;p&&ch[p][c]==q;p=fa[p])ch[p][c]=nq;
            }
        }
    }
    void insert(const string& _){
        for(auto c:_)extend(path(c));
    }
}sam;

void solve(){
    // P4112 最短不公共子串
    // 计算以下长度
    // 1. a 的子串，不是 b 的子串 
    // 2. a 的子串，不是 b 的子序列
    // 3. a 的子序列，不是 b 的子串
    // 4. a 的子序列，不是 b 的子序列

    string a,b;
    cin>>a>>b;
    int n=a.size(),m=b.size();
    sam.init();sam.insert(b);
    sqam1.build(a);
    sqam2.build(b);

    // 1. a 的子串，不是 b 的子串 
    // b 建立 sam 逐个枚举a的开头直到到达 b 的空
    int ans=N;
    for(int l=1;l<=n;l++){
        for(int r=l,cur=1;r<=n;r++){
            cur=sam.ch[cur][sam.path(a[r-1])];// 注意：1-base 转 0-base
            if(!cur){
                ans=min(ans,r-l+1);
                break;
            }
        }
    }
    if(ans==N)ans=-1;
    cout<<ans<<'\n';
    
    // 2. a 的子串，不是 b 的子序列
    // 枚举 a 的各个开头子串， 直到 b 到达空状态
    ans=N;
    for(int l=1;l<=n;l++){
        for(int r=l,cur=0;r<=n;r++){
            cur=sqam2.ch[cur][sqam2.path(a[r-1])];
            if(cur==m+1){
                ans=min(ans,r-l+1);
                break;
            }
        }
    }
    if(ans==N)ans=-1;
    cout<<ans<<'\n';

    // 3. a 的子序列，不是 b 的子串
    // "子序列" "不是子串" 无法直接枚举子串 需要建立状态dp
    // 注意：f[i][j] i,j 只要有一个是后继是子状态，f[i][j] 就是子状态
    // 只需对最外围循环进行倒序枚举 
    // 为什么对最外围倒序，而不是第二维，因为第一维位于循环最外侧管辖范围最大
    // 最外围倒序了，整体就倒序了，否则如果第二位倒序，第一维正序就不对
    ans=N;
    for(int i=n;i>=0;i--){
        for(int j=1;j<=sam.tot;j++){
            f[i][j]=N;
            for(int c=0;c<M;c++){
                int u=sqam1.ch[i][c];
                int v=sam.ch[j][c];
                if(u<=n)f[i][j]=min(f[i][j],f[u][v]+1);
            }
        }
    }
    if(f[0][1]==N)f[0][1]=-1;
    cout<<f[0][1]<<'\n';

    // 4. a 的子序列，不是 b 的子序列
    // 同理根据递推顺序，最外围一层倒序 
    ans=N;
    memset(f,0,sizeof f);
    for(int i=n;i>=0;i--){
        for(int j=0;j<=m;j++){
            f[i][j]=N;
            for(int c=0;c<M;c++){
                int u=sqam1.ch[i][c];
                int v=sqam2.ch[j][c];
                // 注意：sqam的空状态还是 n+1 比较好 能绕开
                // 但是 n+1 不适合动态插入？ -1 也做不到
                if(u<=n)f[i][j]=min(f[i][j],f[u][v]+1);
            }
        }
    }
    if(f[0][0]==N)f[0][0]=-1;
    cout<<f[0][0]<<'\n';
}
```

== 最小表示法

+ 时间 $O(n)$

```cpp
/* 最小表示法 P13270 */
// (循环同构串中的字典序最小的串)(返回起始下标) 
int min_string(const string& s){
    int k=0,i=0,j=1,n=s.size();
    while(i<n&&j<n&&k<n){
        if(s[(i+k)%n]==s[(j+k)%n])k++;
        else if(s[(i+k)%n]>s[(j+k)%n])i+=k+1,k=0;
        else j+=k+1,k=0;
        if(i==j)i++;// 注意 i==j 处理 
    }
    return min(i,j);
}
// 2.Wiki Lyndon分解解法
// smallest_cyclic_string
string min_cyclic_string(string s) {
  s += s;
  int n = s.size();
  int i = 0, ans = 0;
  while (i < n / 2) {
    ans = i;
    int j = i + 1, k = i;
    while (j < n && s[k] <= s[j]) {
      if (s[k] < s[j])
        k = i;
      else
        k++;
      j++;
    }
    while (i <= k) i += j - k;
  }
  return s.substr(ans, n / 2);
}
```

== Lyndon分解

#note[
  分解为若干个最小表示法
]

- 时间 $(n)$

```cpp
/* Lyndon分解 P6114 */
vector<int> Lyndon(const string& s){
    int i=0,j=0,k=1,n=s.size();
    vector<int> res;
    // i 是新的开始 j 是当前的Lyndon匹配位置 k是下一个插入位置
    for(int i=0,j,k;i<n;){
        j=i,k=i+1;
        while(s[j]<=s[k]&&k<n){
            if(s[j]==s[k])j++,k++;// 周期匹配成功
            if(s[j]<s[k])j=i,k++;// 更快 
        }
        while(i<=j)i+=k-j,res.push_back(i);// 截断处 
    }
    return res;
}
```

== Main-Lorentz算法

#note[
  冷门
]
