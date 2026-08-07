#include<bits/stdc++.h>
using namespace std;
using ULL = unsigned long long; // 使用无符号长整型自然溢出
const int N=1e5+5;
const int mod=998244353;
// 生成一个随机掩码，防止被针对性卡哈希
const ULL mask = mt19937_64(time(0))();
// 快速幂求逆元：ksm(a) 默认求 a 的 mod-2 次方，即 1/a (mod p)
ULL ksm(ULL a,ULL b=mod-2){
    ULL res=1;
    for(;b;b>>=1,a=a*a%mod)if(b&1)res=res*a%mod;
    return res;
}
// 哈希扰动函数：类似于 XorShift 随机数生成器
// 作用是将子树的哈希值打乱，防止 sum 哈希冲突（例如 1+3 和 2+2）
ULL shift(ULL x){
    x^=mask;
    x^=x<<13;
    x^=x>>7;
    x^=x<<17;
    x^=mask;
    return x;
}
struct Tree{
    ULL hash; // 子树的哈希值
    ULL deg;  // 当前节点的度数（子节点个数）
    ULL ans;  // 当前子树产生的本质不同括号序列方案数
    map<ULL,ULL> son; // 记录每种哈希值的子节点出现了多少次，用于处理多重集排列
    Tree(){clear();}
    // 初始化
    void clear(){
        hash=1; // 哈希初值设为 1
        deg=0;
        ans=1;  // 方案数初值设为 1（空树只有一种方案）
        son.clear();
    }
    // 【核心】加入一个子树 o 到当前节点
    void add(Tree& o){
        ULL tmp=shift(o.hash); // 获取子树扰动后的哈希值
        hash+=tmp;             // 累加哈希（Sum Hash）
        // 更新方案数：
        // 1. ans * ++deg: 原本是 deg!，现在变成 (deg+1)!，所以乘上 (deg+1)
        // 2. ksm(++son[tmp]): 处理同构子树。假设该哈希原有 c 个，现在 c+1 个。
        //    分母需要从 c! 变为 (c+1)!，所以需要除以 (c+1)，即乘上 inv(c+1)
        // 3. * o.ans: 乘上子树内部的方案数
        ans = ans * ++deg % mod * ksm(++son[tmp]) % mod * o.ans % mod;
    }
    // 【核心】从当前节点移除一个子树 o（用于换根和回溯）
    void remove(Tree& o){
        ULL tmp=shift(o.hash);
        hash-=tmp; // 减去哈希
        // 更新方案数（add 的逆运算）：
        // 1. ksm(deg--): 原本是 deg!，移除一个变成 (deg-1)!，所以除以 deg
        // 2. son[tmp]--: 该哈希子树数量从 c 变 c-1。
        //    分母从 c! 变为 (c-1)!，相当于分子乘了 c。注意这里 son[tmp]-- 返回的是减之前的值 c
        // 3. ksm(o.ans): 除以该子树内部的方案数
        ans = ans * ksm(deg--) % mod * son[tmp]-- % mod * ksm(o.ans) % mod;
    }
} sub[N], root[N]; // sub[i]存以1为根时的子树信息，root[i]存以i为根时的全树信息
vector<int> e[N];
map<ULL,ULL> trees; // 记录最终每种本质不同的树的方案数，key是树哈希，val是方案数
// 第一次 DFS：自底向上计算，默认 1 为根
void get_sub(int u,int fa){
    for(auto v:e[u]) if(v!=fa){
        get_sub(v,u);
        sub[u].add(sub[v]); // 将子节点 v 合并到 u
    }
}
// 第二次 DFS：自顶向下换根
// u 是当前的根（父节点），我们现在要处理 u 的子节点 v，尝试让 v 成为整棵树的根
void get_root(int u,int fa){
    for(auto v:e[u]) if(v!=fa){
        // --- 换根步骤 ---
        // 1. 从 u 中移除 v 的贡献
        // 此时 root[u] 变成了 "除去 v 子树之外，树的其他部分"
        root[u].remove(sub[v]);
        // 2. 初始化 root[v]
        // root[v] 目前只包含 v 的下层子树信息（和 sub[v] 一样）
        root[v] = sub[v];
        // 3. 将 u 合并到 v 上
        // 此时 u 已经变成了 v 的一个子节点（包含了树的上半部分）
        root[v].add(root[u]);
        // 4. 回溯恢复 u 的状态
        // 这一步非常重要！如果不恢复，u 的信息就丢失了，
        // 处理 u 的下一个兄弟节点时，需要用到完整的 u。
        // 注意：这里恢复 root[u] 是为了下一次循环或者回溯给 u 的父亲用，
        // 而不是给下面的 get_root(v, u) 用，因为递归下去用的是 root[v]。
        root[u].add(sub[v]);
        // 5. 递归处理 v
        get_root(v,u);
    }
    // 记录以 u 为根时的哈希值和方案数
    // map 会自动去重：如果两个根产生了相同的哈希（同构），只记录一次（或覆盖，值是一样的）
    trees[root[u].hash] = root[u].ans;
}
void solve(){
    int n; cin>>n;
    for(int i=1;i<=n;i++){
        e[i].clear();
        sub[i].clear();
        root[i].clear();
    }
    trees.clear();
    for(int u,v,i=1;i<n;i++){
        cin>>u>>v;
        e[u].push_back(v);
        e[v].push_back(u);
    }
    // 步骤 1: 以 1 为根计算所有子树信息
    get_sub(1,0);
    // 步骤 2: 准备换根，root[1] 初始状态就是 sub[1]
    root[1] = sub[1];
    // 步骤 3: 换根 DP 遍历所有节点作为根的情况
    get_root(1,0);
    // 步骤 4: 统计答案
    // 题目要求本质不同的树的方案数之和
    // trees map 中 key 是哈希值，value 是方案数。
    // 遍历 map 累加 value 即可。
    ULL ans=0;
    for(auto [k,v]:trees) ans=(ans+v)%mod;
    cout<<ans<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    int T; cin>>T;while(T--) solve();
}