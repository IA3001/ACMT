#import "../lib.typ": *

#set math.equation(numbering: "(1)")

= 数学

#note[数学这一块，其实可以参考外部资料]

== 符号

#note[略]

== 进制

#note[略]

== 位运算

=== 汉明权重

数位非 0 的个数 尤其是二进制 1 的个数

==== 构造汉明权重递增的序列

```cpp
for (int i = 0; (1<<i)-1 <= n; i++) {
    for (int x = (1<<i)-1, t; x <= n; t = x+(x&-x), x = x ? (t|((((t&-t)/(x&-x))>>1)-1)) : (n+1)) {
        // 写下需要完成的操作
    }
}
```

=== GCC 内建函数

```cpp
int __builtin_ffs(int x);// 返回 x?(ctz(x)+1):0
int __builtin_clz(unsigned int x);// 返回 二进制前导0的个数(x==0未定义)
int __builtin_ctz(unsigned int x);// 返回 二进制末尾0的个数(x==0未定义)
int __builtin_popcount(unsigned int x);// 返回 1的个数
int __builtin_parity(unsigned int x);// 返回 1的个数奇偶性
int __builtin_clrsb(unsigned int x);// 返回 x的前导补充符号位(不含)的个数
// 注：函数后加 ll 可改变参数 int 为 long long
```

== 二进制集合操作

=== 补充概念

#table(
  columns: (auto, auto),
  inset: 10pt,
  align: horizon,
  [$overline(a)$ or `~a`], [补集],
  [$a backslash b$ or `a&(~b)`], [差集],
  [$a triangle.t b$ or `a^b`], [对称差],
)

=== 按降序遍历大小为 $n$ 的集合的子集（含 0）

- $O(2^"popcount"(n))$

```cpp
for(int t=s;;t=(t-1)&s){
    // ...
    if(t==0)break;// 包含 0 的写法
}
```

=== 遍历大小为 $n$ 的集合的所有掩码的子掩码（含 0）

- $sum_(k=0)^n binom(n, k) 2^k = (1+2)^n = O(3^n)$

```cpp
for(int s=0;s<S;s++){
    for(int t=s;;t=(t-1)&s){
    	// ...    
      if(t==0)break;
    }
}
```

== 平衡三进制

#note[冷门]

== 高精度计算

```cpp
// 来自某不知名 ACM 集训队
struct BigInt {
    vector<int> num;  // 存储数字（低位在前，高位在后）
    bool neg = false; // 符号标记（true为负数）

    // 去除前导零并处理-0的情况
    void trim() {
        while (num.size() > 1 && num.back() == 0)
            num.pop_back();
        if (num.size() == 1 && num[0] == 0)
            neg = false;
    }

    // 绝对值
    BigInt _abs() const {
        BigInt res = *this;
        res.neg = false;
        return res;
    }

    // 比较绝对值大小（不考虑符号）
    // 返回1：|this| > |other|, 0：相等, -1：|this| < |other|
    int abs_compare(const BigInt& other) const {
        if (num.size() != other.num.size())
            return num.size() > other.num.size() ? 1 : -1;
        for (int i = num.size() - 1; i >= 0; i--) {
            if (num[i] != other.num[i])
                return num[i] > other.num[i] ? 1 : -1;
        }
        return 0;
    }

    // FFT实现（非递归）
    static void fft(vector<complex<double>>& a, bool invert) {
        int n = a.size();
        // 位逆置换
        for (int i = 1, j = 0; i < n; i++) {
            int bit = n >> 1;
            for (; j & bit; bit >>= 1)
                j ^= bit;
            j ^= bit;
            if (i < j)
                swap(a[i], a[j]);
        }

        for (int len = 2; len <= n; len <<= 1) {
            double ang = 2 * PI / len * (invert ? -1 : 1);
            complex<double> wlen(cos(ang), sin(ang));
            for (int i = 0; i < n; i += len) {
                complex<double> w(1);
                for (int j = 0; j < len / 2; j++) {
                    complex<double> u = a[i + j], v = a[i + j + len / 2] * w;
                    a[i + j] = u + v;
                    a[i + j + len / 2] = u - v;
                    w *= wlen;
                }
            }
        }

        if (invert) {
            for (complex<double>& x : a)
                x /= n;
        }
    }

    // 构造函数
    BigInt() : num({0}), neg(false) {}  // 默认构造为0
    BigInt(long long x) {
        *this = x;
    }
    BigInt(const string& s) {
        from_string(s);
    }

    // 从字符串初始化
    void from_string(const string& s) {
        num.clear();
        neg = false;
        int start = 0;
        if (s[0] == '-') {
            neg = true;
            start = 1;
        }
        for (int i = s.size() - 1; i >= start; i--) {
            if (isdigit(s[i]))
                num.push_back(s[i] - '0');
        }
        trim();
    }

    // 从整数赋值
    BigInt& operator=(long long x) {
        num.clear();
        neg = (x < 0);
        x = abs(x);
        if (x == 0) num.push_back(0);
        while (x) {
            num.push_back(x % 10);
            x /= 10;
        }
        return *this;
    }

    // 转换为字符串
    string to_string() const {
        if (num.empty()) return "0";
        string s;
        if (neg) s += '-';
        for (int i = num.size() - 1; i >= 0; i--)
            s += char(num[i] + '0');
        return s;
    }

    // 重载比较运算符
    bool operator<(const BigInt& other) const {
        if (neg != other.neg) 
            return neg;
        if (neg) 
            return abs_compare(other) > 0;
        return abs_compare(other) < 0;
    }

    bool operator>(const BigInt& other) const { return other < *this; }
    bool operator<=(const BigInt& other) const { return !(*this > other); }
    bool operator>=(const BigInt& other) const { return !(*this < other); }
    bool operator==(const BigInt& other) const {return neg == other.neg && num == other.num;}
    bool operator!=(const BigInt& other) const { return !(*this == other); }

    // 重载算术运算符
    BigInt operator-() const {
        BigInt res = *this;
        res.neg = !neg;
        res.trim();
        return res;
    }

    BigInt operator+(const BigInt& other) const {
        if (neg == other.neg) {
            BigInt res = *this;
            int carry = 0;
            int max_size = max(num.size(), other.num.size());
            res.num.resize(max_size, 0);
            for (int i = 0; i < max_size; i++) {
                if (i < other.num.size())
                    res.num[i] += other.num[i];
                res.num[i] += carry;
                carry = res.num[i] / 10;
                res.num[i] %= 10;
            }
            if (carry)
                res.num.push_back(carry);
            return res;
        } else {
            if (neg)
                return other - (-*this);
            else
                return *this - (-other);
        }
    }

    BigInt operator-(const BigInt& other) const {
        if (neg != other.neg) {
            return *this + (-other);
        }
        if (abs_compare(other) < 0) {
            BigInt res = other - *this;
            res.neg = !neg;
            return res;
        }
        BigInt res = *this;
        int borrow = 0;
        for (int i = 0; i < res.num.size(); i++) {
            if (i < other.num.size())
                res.num[i] -= other.num[i];
            res.num[i] -= borrow;
            borrow = 0;
            if (res.num[i] < 0) {
                res.num[i] += 10;
                borrow = 1;
            }
        }
        res.trim();
        return res;
    }
    

    // 大数乘较小数（int范围内）
    BigInt operator*(int x) const {
        if (x == 0) return BigInt(0);
    
        BigInt res;
        res.neg = neg ^ (x < 0);
        x = abs(x);
    
        res.num.resize(num.size() + 10, 0); // 预留足够空间
        long long carry = 0;
    
        for (int i = 0; i < num.size() || carry; i++) {
            if (i < num.size()) {
                carry += (long long)num[i] * x;
            }
            res.num[i] = carry % 10;
            carry /= 10;
        }
    
        res.trim();
        return res;
    }

    // 乘法（使用FFT优化）
    BigInt operator*(const BigInt& other) const {
        // 处理0或符号
        if (*this == 0 || other == 0) return BigInt(0);
        BigInt res;
        res.neg = neg ^ other.neg;

        // 将数字转换为复数向量
        vector<complex<double>> fa(num.begin(), num.end());
        vector<complex<double>> fb(other.num.begin(), other.num.end());
        
        // 扩展为2的幂
        int n = 1;
        while (n < fa.size() + fb.size()) 
            n <<= 1;
        fa.resize(n);
        fb.resize(n);

        // 执行FFT
        fft(fa, false);
        fft(fb, false);
        for (int i = 0; i < n; i++)
            fa[i] *= fb[i];
        fft(fa, true);

        // 处理进位
        res.num.resize(n);
        int carry = 0;
        for (int i = 0; i < n; i++) {
            int digit = int(fa[i].real() + 0.5) + carry;
            carry = digit / 10;
            res.num[i] = digit % 10;
        }

        // 处理剩余进位
        while (carry) {
            res.num.push_back(carry % 10);
            carry /= 10;
        }
        res.trim();
        return res;
    }

    // 除法（长除法）
    BigInt operator/(const BigInt& other) const {
        if (other == 0) throw runtime_error("Division by zero");
        if (abs_compare(other) < 0) return BigInt(0);
        BigInt res, cur;
        res.num.resize(num.size());
        res.neg = neg ^ other.neg;
        
        for (int i = num.size() - 1; i >= 0; i--) {
            cur.num.insert(cur.num.begin(), num[i]);
            cur.trim();
            int quotient = 0;
            while (cur >= other._abs()) {
                cur = cur - other._abs();
                quotient++;
            }
            res.num[i] = quotient;
        }
        res.trim();
        return res;
    }

    // 取模运算
    BigInt operator%(const BigInt& other) const {
        BigInt quotient = *this / other;
        return *this - quotient * other;
    }

    // 友元函数：输出流
    friend ostream& operator<<(ostream& os, const BigInt& n) {
        os << n.to_string();
        return os;
    }

    // 友元函数：输入流
    friend istream& operator>>(istream& is, BigInt& n) {
        string s;
        is >> s;
        n.from_string(s);
        return is;
    }
};
```

== 快速幂

=== 代码

```cpp
// 快速幂 1不是0
inline LL ksm(LL a,LL b,LL mod){
    LL r=1;
    for(;b;a=a*a%mod;b>>=1)if(b&1)r=r*a%mod;
    return r;
}
```

=== 快速幂思想

1. 矩阵快速幂
2. 龟速乘
3. 加速几何中对点集的操作 (变换矩阵)
4. 定长路径计数 (邻接矩阵)
5. 高精度快速幂 (其实就是快速幂)
6. 同一底数与模数的预处理快速幂 (根号分块预处理)

#note[
  PS: 广义矩阵乘法：
  $ C_(i,j) = max_(k=1)^n (A_(i,k) + B_(k,j)) $
  满足结合律，可以矩阵快速幂
]

== 置换和排列

=== 定义

- 置换：集合 X 到自身的双射（一一对应） $sigma$ 
- 排列：集合 X 上还有全序关系的置换 

=== 表示方法

1. 双行记号： 一个 `2*n` 的矩阵表示， 第一行是原始下标，第二行是对应下标
2. 单行记号：默认第一行为 `1,2,3,4,...,n`
3. 轮换表示：一行多个括号，同一个括号里是一个置换环，单独的可以不写出来

=== 复合

+ x o y 其实是 进行 y 置换再进行 x 置换

所以置换的符合的运算顺序是自右向左的，置换的乘法不满足交换律

> PS: 连续多个置换的乘积称为排列的幂，可以使用 *快速幂* 加速计算。

=== 逆置换

#note[倒过来即可]

=== 轮换

- 轮换是一种特殊的置换，从任意一点出发反复置换都能到达任意一点，长度为 k 的轮换称作 *k-轮换*

- 置换的轮换可以看作讲置换写成这些特殊置换（轮换的）的乘积

- 几何意义：置换的轮换分卸就是 认为置换是由 多个简单有向的环 构成的图

=== 性质

#note[需要关注单个置换的性质]

1. 奇偶性
    - 置换分解成一系列对换时，需要的对换的数目的奇偶性是固定的。一个置换的对换分解的数目的奇偶性也称作置换的 奇偶性（parity）。
    - 那是当然，因为你一旦偏离原点一步，就要花费相同的代价返回
    - 奇对换：即能够分解成奇数个对换的乘积的置换。
    - 偶对换：同理。
    - n>=2 时，大小为 n 的奇置换和偶置换的数目相同。
2. 符号
    - $"sgn"(pi o sigma)$
    - 奇：-1
    - 偶：1
    - 两个奇偶性相同的置换的复合是偶置换，两个奇偶性不同的置换的复合是奇置换。这一结论，从对换分解的角度看是显然的。
3. 置换的阶
    - 重复该置换 a 次后，所有元素都回到了原位。
4. 置换的型
    - 轮换分解中轮换长度的可重集合。
    - 给定置换的行，不同置换的数目如下
    - 首先把同大小的全排列除掉
    - 然后注意到环排列k有 k种等价的方式 故除掉
  
$ frac(n!,1^(alpha_1)2^(alpha_2)dots n^(alpha_n) dots alpha_1!alpha_2!dots alpha_k!) $

如果仅仅给定置换分解称的轮换个数$c(sigma)$，则不同的置换数目为 n 个元素排成 k 个环排列的方法数，第一类斯特林数：s1(n,k)。不同的型的个数为置换长度 n 的分拆数 $p_n$。

#note[
  从置换的型，可以方便的确定置换的阶和奇偶性等性质

  因为 K-轮换的阶是 k，不同的轮换不相交，所以置换 $sigma$ 的阶就是 $lcm(alpha_k)$

  同样地，因为 k-轮换的奇偶性与 k 的奇偶性相反，所以置换 $sigma$ 的奇偶性就是 
  $ sum_k (k-1)alpha_k = sum_k k alpha_k - sum_k alpha_k = n-c(sigma) $ 
  的奇偶性。这里 $c(sigma)$ 就是轮换的个数 （包括 1-轮换，即不动点）
  
  置换的型在 Polya 计数 中有重要作用
]

=== 排列相关

==== 逆序数

- 排列的逆序数是它恢复成正序序列所需要做相邻对换的最少次数。
- 排列的逆序数的奇偶性和相应的置换的奇偶性一致。
- 求解逆序数的算法，可以使用 `[归并排序]` 或 `[树状数组]` 时间复杂度 $O(n log n)$

==== 顺序

- 字典序顺序，`<algorithm>` 中 `prev_permutation` 和 `next_permutation`

==== 排名

- 按字典序从小到大列举出来，建立了排列和 *正整数* 的一一对应
- 这个排名又叫做 *康托展开* 对应排列的 *Lehmer Code*

==== Lehmer 码

- 序列 $L_sigma$ 第 $i$ 位是 (从高位到低位) 在排列中排在第 $i$ 位之后，比 $sigma(i)$ 小的元素个数
- 等于尚未使用的元素中给定元素的排名（减一）

$ "rank" sigma = 1 + L_sigma (1)(n-1)! + L_sigma (2)(n-2)! + dots + L_sigma (n)0! $

- 康托展开就是从 $n$ 到 1 加权计算
- 逆康托展开就是将数字从 1 到 $n$ 按权分解

==== 关系

$ "permutation" arrow.r^"get_lehmer" "lehmer" arrow.r^"get_rank" "rank" $
$ "permutation" arrow.l^"get_permutation" "lehmer" arrow.l^"get_lehmer_from_rank" "rank" $

```cpp
#include<bits/stdc++.h>
using namespace std;
const int mod=998244353;
struct BIT{
    int n;// 表示 [0,n] 映射到 [1,n+1]
    vector<int> tr;
    BIT(int _):n(_+1),tr(_+2){}
    void add(int i,int v){
      for(i++;i<=n;i+=i&-i)tr[i]+=v;
    }
    int query(int i){
        int res=0;
        for(i++;i;i-=i&-i)res+=tr[i];
        return res;
    }
    // 注意 填充的是映射的[1,n+1] 即原来的 [0,n] 如果略。 0 需要特殊处理 add(0,-v);
    void add_all(int v,bool zero){
        for(int i=0+1;i<=n;i++)tr[i]+=v*(i&-i);
        if(!zero)add(0,-v);
    }
    int lower_bound(int k){
        int sum=0,x=0;
        for(int i=log2(n);i>=0;i--){
            x+=1<<i;
            if(x>=n||sum+tr[x]>=k)
                x-=1<<i;
            else sum+=tr[x];
        }
        return x+1-1;
    }
};
// P5367 康托展开
// permutation -> lehmer
vector<int> get_lehmer_from_permutation(vector<int>& nums){
	int n=nums.size();
    vector<int> lehmer(n);
    BIT bit(n);
    for(int i=n-1;i>=0;i--){
        lehmer[i]=bit.query(nums[i]-1);
        bit.add(nums[i],1);
    }
    return move(lehmer);
}
// lehmer -> rank
int get_rank(vector<int>& lehmer){
    int n=lehmer.size(),fac=1,ans=0;
    for(int i=n-1;i>=0;i--){
        ans=(ans+1LL*lehmer[i]*fac)%mod;// 带入公式
        fac=1LL*fac*(n-i)%mod;// 为下一个fac做准备
    }
    return ans+1;// 变 rank,+ 1
}
// P1088 火星人(逆康托展开) 
// lehmer -> lehmer 
vector<int> add_lehmer(vector<int>lehmer,int k){
    int n=lehmer.size();
    lehmer[n-1]+=k;
    for(int i=n-1;i>=1;i--){
        lehmer[i-1]+=lehmer[i]/(n-i);
        lehmer[i]%=n-i;
    }
    return move(lehmer);
}
// lehmer -> permutation
vector<int> get_permutation(vector<int>& lehmer){
    int n=lehmer.size();
    vector<int> nums(n);
    BIT bit(n);
    bit.add_all(1,false);
    for(int i=0;i<n;i++){
        nums[i]=bit.lower_bound(lehmer[i]+1);
        bit.add(nums[i],-1);
    }
    return move(nums);
}
// rank -> lehmer 
vector<int> get_lehmer_from_rank(int n,int rank){
    vector<int> lehmer(n);
    return move(add_lehmer(lehmer,rank-1));
}
void solve(){
	// 康托展开
    // int n;cin>>n;
    // vector<int> nums(n);
    // for(auto& i:nums)cin>>i;
    // vector<int> lehmer=get_lehmer_from_permutation(nums);
    // cout<<get_rank(lehmer)<<'\n';
    
	// 逆康托展开 
    int n,m;cin>>n>>m;
    vector<int> nums(n);
    for(auto& i:nums)cin>>i;
    vector<int> lehmer=get_lehmer_from_permutation(nums);
    vector<int> lehmer2=add_lehmer(lehmer,m);
    vector<int> nums2=get_permutation(lehmer2);
    for(auto i:nums2)cout<<i<<' ';
}
signed main(){solve();return 0;}
```

== 弧度制&坐标系

=== 弧度制

$ |alpha| = l / r $

$ "k rad" = pi / 180^degree n^degree $

=== 平面坐标系

==== 平面直角坐标系

$ (x, y) $

==== 平面极坐标系

$ (rho, phi) $

===== 平面直角坐标系 $arrow.l.r$ 平面极坐标系

- *极坐标 $arrow.r$ 直角坐标*：
    $ cases(x = rho cos phi, y = rho sin phi) $

- *直角坐标 $arrow.r$ 极坐标*：
    $ cases(rho = sqrt(x^2 + y^2), phi = "atan2"(y, x)) $

=== 空间坐标系

==== 空间直角坐标系

$ (x, y, z) $

==== 空间柱坐标系

$ (rho, phi, z) $

===== 空间直角坐标系 $arrow.l.r$ 空间柱坐标系

- *柱坐标 $arrow.r$ 直角坐标*：
  $ cases(x = rho cos phi, y = rho sin phi, z = z) $

- *直角坐标 $arrow.r$ 柱坐标*：
  $ cases(rho = sqrt(x^2 + y^2), phi = "atan2"(y, x), z = z) $

==== 空间球坐标系

点 $P$ 用 $(r, theta, phi)$ 表示：
- $r >= 0$：点到原点的距离（径向距离）；
- $theta in [0, pi]$：*天顶角*（与 $z$ 轴正向的夹角）；
- $phi in [0, 2pi)$：*方位角*（在 $x y$-平面上的投影与 $x$ 轴的夹角）。

#note[注：OI Wiki 采用 $theta$ 为天顶角、$phi$ 为方位角的惯例。]

===== 空间直角坐标系 $arrow.l.r$ 空间球坐标系

- *球坐标 $arrow.r$ 直角坐标*：
  $ cases(x = r sin theta cos phi, y = r sin theta sin phi, z = r cos theta) $

- *直角坐标 $arrow.r$ 球坐标*：
  $ cases(r = sqrt(x^2 + y^2 + z^2), theta = arccos( z / r ) quad (r != 0), phi = "atan2"(y, x)) $

===== 空间柱坐标系 $arrow.l.r$ 空间球坐标系

- *柱坐标 $(rho, phi, z)$ $arrow.r$ 球坐标 $(r, theta, phi)$*：
  $ cases(r = sqrt(rho^2 + z^2), theta = arccos( z / r ) quad (r != 0), phi = phi) $

- *球坐标 $(r, theta, phi)$ $arrow.r$ 柱坐标 $(rho, phi, z)$*：
  $ cases(rho = r sin theta, phi = phi, z = r cos theta) $

== 复数

=== 复数的三种形式

1. 代数形式
  - $z = a + b i$
2. 三角形式/指数形式
  - $z = r(cos theta + i sin theta) = r exp(i theta)$

=== 单位根

$ omega_n = exp((2 pi i) / n) $
$ omega_n^n = 1 $
$ omega_n^k = omega_(2n)^(2k) $
$ omega_(2n)^(k+n) = - omega_(2n)^k $

=== 本原单位根

- $\{ omega_n^k | 0 <= k < n, "gcd"(n, k) = 1 \}$
- 全体 $n$ 次本原单位根有 $phi(n)$ 个

=== C++ 中的复数

- 成员函数 `real` 和 `imag`，可以访问实部和虚部。  
- 非成员函数 `real`、`imag`、`abs`、`arg`，返回实部、虚部、模和辐角。  
- 非成员函数：`norm` 为模的平方，`conj` 为共轭复数。
- 非成员函数 `exp`、`log`（底为 e 的对数主值）、`log10`（底为 10 的对数主值，C 中没有）、`pow`、`sqrt`、`sin`、`cos`、`tan`，含义与 C 中的含义相同。

== 数论


=== 数论基础

==== 整除 & 约数

#note[略]

==== 带余数除法

#note[略]

==== 最大公约数 (GCD) & 最小公倍数 (LCM)

- 性质：
  - $(b q + r, b) = (r, b)$
  - $(a, b)^n = (a^n, b^n)$
  - 若 $b | a c$ 且 $(a, b) = 1$ 则 $b | c$
  - 若 $b | c, a | c$ 且 $(a, b) = 1$ 则 $a b | c$
  - 若 $(a,b) = 1$ 则 $(a,b c) = (a,c)$ 
  - 若 $(a,b)= 1$ 则 $(a^n,b^m) = 1$ 
  - $[a,b,c][a b,b c,c a] = [a,b][b,c][c,a]$ 
  - $[a,b]^n = [a^n,b^n]$ 
  - $(a, b)[a, b] = |a b|$
  - $(a b, b c, c a)[a, b, c] = |a b c|$
  - $frac((a,b,c)^2,(a,b)(b,c)(c,a)) = frac([a,b,c]^2,[a,b][b,c][c,a])$ 

==== 互素（即约）

- $(a_1, a_2, dots, a_n) = 1$ 则称其互素

==== 素数 & 合数

#note[略]

==== 算术基本定理

#note[
  就是唯一分解定理
]

设正整数 $a$，那么必有表示：

$a = p_1 p_2 dots.c p_s$ 其中 $p_j(1 <= j <= s)$ 是素数。

并且在不计次序的意义下，该表示唯一。

==== 同余

- 设 $f(x) = sum_(i=0)^n a_i x^i$ 和 $g(x) = sum_(i=0)^n b_i x^i$，且 $a_i equiv b_i (mod m)$，则对于任意 $s equiv t (mod m)$，均有 $f(s) equiv g(t) (mod m)$
- 若 $a, b in ZZ, d, m in NN^*, d | a, d | b, d | m$ 则当 $a equiv b (mod m)$ 成立时 $a/d equiv b/d (mod m/d)$
- 若 $a, b in ZZ, d, m in NN^*, d | m$，则当 $a equiv b (mod m)$ 成立时 有 $a equiv b (mod d)$
- 若 $a, b in ZZ, d, m in NN^*$，则当 $a equiv b (mod m)$ 成立时, 有 $(a, m) = (b, m)$，若 $d$ 能整除 $m$ 及 $a, b$ 中的一个，那么 $d$ 必能整除 $a, b$ 中的另一个

==== C/C++中的取模运算

- `a = (a/b)*b + a%b`
- `a % b = a - (a/b)*b`

#note[
  从 *C99* 和 *C++11* 标准版本起，规定商 *向零取整*（舍弃小数部分）取模的 *符号* 仅 *与被除数相同*
]

==== 快速乘

#note[
  可以节省一次时间可观的 `__int128` 类型取模
]

```cpp
using LL = long long;
using LD = long double;
using ULL = unsigned LL;
inline LL mul(LL a, LL b,LL mod) {ULL c =(ULL)a*b-(ULL)((LD)a/mod*b+0.5L)*mod;return c<mod?c:c+mod;}
```

==== 同余类 & 剩余系

#note[略]

==== 数论函数（算术函数）

- 指定义域为正整数的函数，可视为一个数列

===== 积性函数

- 在数论中 $f(1) = 1$ 且 $f(x y) = f(x) f(y)$ 对于任意互质的 $x, y in NN^*$ 都成立
- 完全积性函数
  - 在数论中 $f(x) = 1$ 且 $f(x y) = f(x) f(y)$ 对于任意的 $x, y in NN^*$ 都成立

===== 积性函数性质

- 若 $f(x)$ 和 $g(x)$ 均为积性函数，则称以下函数也为积性函数：
  $ h(x) = f(x^p) $
  $ h(x) = f^p(x) $
  $ h(x) = f(x) g(x) $
  $ h(x) = sum_(d | x) f(d) g(x/d) $

- 对正整数 $x$，设其唯一质因数分解为 $x = product p_i^(k_i)$，其中 $p_i$ 为质数。
  - 若 $F(x)$ 为积性函数，则有 $F(x) = product F(p_i^(k_i))$
  - 若 $F(x)$ 为完全积性函数，则有 $F(x) = product F(p_i^(k_i)) = product F(p_i)^(k_i)$

===== 积性函数例子

- 单位函数：$epsilon(n) = [n=1]$ （完全积性）
- 恒等函数：$id_k(n) = n^k, id_1(n)$ 通常记作 $id(n)$ （完全积性）
- 常数函数：$1(n) = 1$ （完全积性）
- 除数函数：$sigma_k(n) = sum_(d | n) d^k, sigma_0(n)$ 通常记作 $d(n), tau(n), sigma_1(n)$ 通常记作 $sigma(n)$
- 欧拉函数：$phi(n) = sum_(i=1)^n [(i, n)=1]$
- 莫比乌斯函数：$mu(n) = cases(1 & n=1, 0 & exists d > 1, d^2 | n, (-1)^(omega(n)) & "otherwise")$ 其中 $omega(n)$ 表示 $n$ 的本质不同质因子个数

===== 加性函数

- 在数论中满足 $f(1) = 0$ 且 $f(x y) = f(x) + f(y)$ 对任意互质的 $x, y in NN^*$ 都成立
- 完全加性函数
  - 数论中满足 $f(1) = 0$ 且 $f(x y) = f(x) + f(y)$ 对任意的 $x, y in NN^*$ 都成立

===== 加性函数性质

- 对正整数 $x$ 设其唯一质因数分解为 $x = product p_i^(k_i)$，其中 $p_i$ 为质数
  - 若 $F(x)$ 为 加性函数，则有 $F(x) = sum F(p_i^(k_i))$
  - 若 $F(x)$ 为 完全加性函数，则有 $F(x) = sum F(p_i^(k_i)) = sum F(p_i) k_i$

===== 加性函数例子

- 令所有质数组成的集合为 $P$
- 所有质因子数目 $Omega(n) = sum_(p | n) [p in P] sum_(k=1)^(ceil(log_p n)) [p^k | n and p^(k+1) divides.not n] times k$
- 相异质因子数目 $omega(n) = sum_(p | n) [p in P]$
- 所有质因子之和 $a_0(n) = sum_(p | n) [p in P] sum_(k=1)^(ceil(log_p n)) [p^k | n and p^(k+1) divides.not n] times k p$
- 相异质因子之和 $a_1(n) = sum_(p | n) [p in P] times p$

=== 素数

==== 素性测试

===== Miller–Rabin 素性测试

```cpp
inline LL mul(LL a, LL b,LL mod) {ULL c =(ULL)a*b-(ULL)((LD)a/mod*b+0.5L)*mod;return c<mod?c:c+mod;}
inline LL ksm(LL a,LL b,LL mod){LL r=1;for(;b;a=mul(a,a,mod),b>>=1)if(b&1)r=mul(r,a,mod);return r;}
bool MR(LL n){
    if(n<3||n%2==0) return n==2;//特判
    LL u=n-1,t=0;
    while(u%2==0) u/=2,++t;
    // LL ud[]={2,3,5,7,11,13,17,19,23,29,31,37};
    LL ud[]={2,325,9375,28178,450775,9780504,1795265022};
    for(LL a:ud){
        LL v=ksm(a,u,n);
        if(v==1||v==n-1||v==0) continue;
        for(int j=1;j<=t;j++){
            v=mul(v,v,n);
            if(v==n-1&&j!=t){v=1;break;}//出现一个n-1，后面都是1，直接跳出
            if(v==1) return 0;//这里代表前面没有出现n-1这个解，二次检验失败
        }
        if(v!=1) return 0;//Fermat检验
    }
    return 1;
}// SP288
```

==== 反素数

#note[冷门]

=== 最大公约数

==== 欧几里得算法

- $O(log max(a, b))$ 取模运算

```cpp
// C++17 自带 <numeric> std::gcd std::lcm 
int gcd(int a, int b) { return b == 0 ? a : gcd(b, a % b); }
int gcd(int a, int b) {for(int tmp=a;b;a=b,b=tmp%b,tmp=a);return a;}
```

==== 更相减损术（Stein算法）

#note[冷门]

==== 扩展欧几里得算法

#note[
  若 `b!=0` 扩展欧几里得算法 求出的可行解 必有 $|x| <= b, |y| <= a$
]

```cpp
// 递归
LL exgcd(LL a,LL b,LL& x,LL& y){
    if(!b)return x=1,y=0,a;
    else {
        LL d=exgcd(b,a%b,y,x);
        return y-=a/b*x,d;
    }
}
// 迭代：矩阵版
LL exgcd(LL a,LL b,LL &x,LL &y){
  LL x1=1,x2=0,x3=0,x4=1;
  while(b){
    LL c=a/b;
    tie(x1,x2,x3,x4,a,b) =
    make_tuple(x3,x4, x1-x3*c,x2-x4*c,b,a-b*c);
  }
  x=x1,y=x2;
  return a;
}
```

==== 欧拉函数

#note[
  小于等于 $n$ 并与之互质的数的个数
]

- $phi(1) = 1$
- $phi(p) = p - 1$

- 欧拉函数是 *积性函数* 但 *不是* 完全积性函数
  - $forall a, b in NN, (a, b) = 1 arrow.r phi(a b) = phi(a) phi(b)$

- 欧拉反演
  - $n = sum_(d | n) phi(d)$
- $n = p^k$ 时 $phi(p^k) = p^k - p^k/p = p^k - p^(k-1) = p^(k-1) times (p-1)$

- $n = product_(i=1)^s p_i^(k_i)$ 则
  $ phi(n) &= product_(i=1)^s phi(p_i^(k_i)) \
  &= product_(i=1)^s p_i^(k_i) (1 - 1/p_i) \
  &= n times product_(i=1)^s (1 - 1/p_i) \
  &= n times product_(i=1)^s (p_i - 1)/p_i $

- 一般公式
  - 对于任意不全为 0 的整数 $n, m$， $phi(m n) phi(gcd(m, n)) = phi(m) phi(n) gcd(m, n)$

===== 代码

- $O(sqrt(n))$

```cpp
// 定义求法 拉完了
void phi(LL n){
  LL res=1;
  for(LL i=2;i*i<=n;i++){
    if(n%i) continue;
    res*=(i-1),n/=i;
    while(n%i==0)res*=i,n/=i;
  }
  return res;
}
```

===== 应用（最大公约数求和（欧拉反演））

由 $n = sum_(d | n) phi(d)$ 将 $gcd(a, b)$ 代入:

$ gcd(a, b) = sum_(d | gcd(a, b)) phi(d) = sum_d [d | a][d | b] phi(d) $

则有:

$ sum_(i=1)^n gcd(i, n) &= sum_(i=1)^n sum_d [d | i][d | n] phi(d) \
&= sum_d sum_(i=1)^n [d | i][d | n] phi(d) \
&= sum_d floor(n/d) [d | n] phi(d) \
&= sum_(d | n) floor(n/d) phi(d) $

$ sum_(i=1)^n sum_(j=1)^n gcd(i, j) &= sum_(i=1)^n sum_(j=1)^n sum_d [d | i][d | j] phi(d) \
&= sum_d sum_(i=1)^n sum_(j=1)^n [d | i][d | j] phi(d) \
&= sum_d floor(n/d)^2 phi(d) \
&= sum_(d=1)^n floor(n/d)^2 phi(d) $

=== 筛法

==== 埃氏筛

- $O(n log log n)$

```cpp
int factor[N],primes[N],cntp;
void seive(){
    // 只有 i<N 才能正确得到所有质数
    for(int i=2;i<N;i++){
        if(factor[i])continue;
        factor[i]=primes[++cntp]=i;
        for(LL j=(LL)i*i;j<N;j+=i)factor[j]=i;
    }
}
```

==== 线性筛（欧拉筛）

- $O(n)$

```cpp
int factor[N], primes[N], cntp;
int phi[N], mu[N], d[N], num[N], f[N], g[N];
void sieve() {
    // 初始化
    phi[1] = mu[1] = d[1] = f[1] = g[1] = 1;
    for (int i = 2; i < N; i++) {
        if (!factor[i]) { // 如果 i 是质数
            factor[i] = primes[++cntp] = i;
            phi[i] = i - 1; // 1欧拉函数
            mu[i] = -1;     // 2莫比乌斯函数
            d[i] = 2;       // 3约数个数
            num[i] = 1;     // 34最小质因子的幂次
            f[i] = i + 1;   // 4约数和
            g[i] = i + 1;   // 4最小质因子的等比数列和
        }
        for (int j = 1; j <= cntp ; j++) {
            int p = primes[j];
            int m = i * p;
            if(m>=N)break;
            factor[m] = p;
            if (i % p == 0) {
                // i 是 p 的倍数
                phi[m] = phi[i] * p;         // 1欧拉函数
                mu[m] = 0;                   // 2莫比乌斯函数
                num[m] = num[i] + 1;         // 34更新最小质因子的幂次
                d[m] = d[i] / num[m] * (num[m] + 1); // 3约数个数
                g[m] = g[i] * p + 1;         // 4更新最小质因子的等比数列和
                f[m] = f[i] / g[i] * g[m];   // 4约数和
                break;
            } else {
                // i 和 p 互质
                phi[m] = phi[i] * phi[p];    // 1欧拉函数
                mu[m] = -mu[i];              // 2莫比乌斯函数
                d[m] = d[i] * 2;             // 3约数个数
                num[m] = 1;                  // 34最小质因子的幂次
                f[m] = f[i] * f[p];          // 4约数和
                g[m] = 1 + p;                // 4最小质因子的等比数列和
            }
        }
    }
}
```

===== 筛法求欧拉函数

===== 筛法求莫比乌斯函数

- 设 $n$ 是一个合数，$p_1$ 是 $n$ 的最小质因子，$n' = n/p_1$ 有：
  $ mu(n) = cases(0 & n' mod p_1 = 0, -mu(n') & "otherwise") $
- 若 $n$ 是质数，有 $mu(n) = -1$

#note[
  理解：仅由 单质因数 组成的数字的质因数种类的奇偶性（奇：1，偶：-1）
]

===== 筛法求约数个数

- 用 $d_i$ 表示 $i$ 的约数的个数， $"num"_i$ 表示 $i$ 的最小质因子的出现次数
- 若 $n = product_(i=1)^m p_i^(c_i)$ 则 $d_n = product_(i=1)^m (c_i + 1)$
- 因为 $d_i$ 是 积性函数，所以可以使用线性筛

===== 筛法求约数和

- $f_i$ 表示 $i$ 的约数和，$g_i$ 表示 $i$ 的最小质因子的 $p^0 + p^1 + p^2 + dots + p^k$

===== 一般的积性函数

- 假如一个积性函数 $f$ 满足：对于任意质数 $p$ 和正整数 $k$，可以在关于 $k$ 的低次多项式内计算 $f(p^k)$，那么可以在 $O(n)$ 的时间内 筛出 $f(1), f(2), dots, f(n)$ 的值
- 设 合数 $n$ 的质因数分解是 $product_(i=1)^k p_i^(alpha_i)$，其中 $p_1 < p_2 < dots < p_k$ 为质数，我们在线性筛中记录 $g_n = p_1^(alpha_1)$，假如 $n$ 被 $x times p$ 筛掉（$p$ 是质数），那么 $g$ 满足如下递推式：
  $ g_n = cases(g_x times p & x mod p = 0, p & "otherwise") $
- 假如 $n = g_n$，说明 $n$ 就是某个质数的次幂，可以 $O(1)$ 计算 $f(n)$；否则 $f(n) = f(n/g_n) times f(g_n)$

=== 分解质因数

==== 质因数分解

- $O(log n)$

```cpp
vector<int> factors(int n){
    vector<int> res;
    while(n){
        int j=factor[n];
        res.push_back(j);
        while(n%j==0)n/=j;
    }
    return move(res);
}
```

==== 朴素算法

#note[略]

==== Pollard Rho算法

#note[得到一个因子]

- $O(n^(1/4))$

```cpp
// P4718
LL randint(LL l, LL r = 0LL) {
    static mt19937 eng(time(0));
    if (l > r)swap(l, r);
    uniform_int_distribution<LL> dis(l, r);
    return dis(eng);
}
LL pollard_rho(LL x) {
  LL s = 0, t = 0;
  LL c = randint(1,x);
  int step = 0, goal = 1;
  LL val = 1;
  for (goal = 1;; goal *= 2, s = t, val = 1) {  // 倍增优化
    for (step = 1; step <= goal; ++step) {
      t = (mul(t, t, x) + c) % x;
      val = mul(val, abs(t - s), x);
      if ((step % 127) == 0) {
        LL d = gcd(val, x);
        if (d > 1) return d;
      }
    }
    LL d = gcd(val, x);
    if (d > 1) return d;
  }
}
unordered_map<LL, LL> mf;
LL maxfac(LL x) {
    LL tmp=x;
    if(mf.count(x))return mf[x];
    if (x<2) return mf[x]=1;
    if (MR(x)) return mf[x]=x;
    LL p=x;
    while (p>=x) p=pollard_rho(x);  // 使用该算法
    while (x%p==0) x/=p;
    return mf[tmp]=max(maxfac(x), maxfac(p));  // 继续向下分解x和p
}
```

=== 裴蜀定理 & 一次不定方程

==== 内容

设 $a, b$ 是 不全为零的整数，那么，对于任意整数 $x, y$ 都有 $gcd(a, b) | a x + b y$ 成立，而且，存在正整数 $x, y$，使得 $a x + b y = gcd(a, b)$ 成立。

==== 推论

$gcd(a, b) = 1$ 时有：
- 整数 $a, b$ 互素，当且仅当存在正整数 $x, y$，使得 $a x + b y = 1$ 成立。

#note[*多元*裴蜀定理依然成立]

==== 二元一次不定方程

$ a_1 x_1 + a_2 x_2 = b $

由 *扩展欧几里得* 算法得到一组整数解 $(x_1', x_2')$
要得到全部解，可以考虑将原方程与 $a_1 x_1' + a_2 x_2' = b$ 相减

$ a_1 (x_1 - x_1') + a_2 (x_2 - x_2') = 0 $

这是一个关于 $(x_1 - x_1', x_2 - x_2')$ 的齐次一次不定方程，有通解

$ (x_1 - x_1', x_2 - x_2') = t (a_2/d, -a_1/d) $

因此原方程的通解就是 $(x_1, x_2) = (x_1' + t a_2/d, x_2' - t a_1/d)$

==== Frobenius硬币问题

有 $a_1, a_2, dots, a_n$ 若干中面值的硬币，$gcd(a_1, a_2, dots, a_n) = 1$，不能由这些硬币组成的最大整数是多少。

===== Sylvester定理 ($n=2$)

- 互素的正整数 $a_1, a_2$ 不能写作 $a_1 x_1 + a_2 x_2 (x_1, x_2 in NN)$ 的最大整数是 $C = a_1 a_2 - a_1 - a_2$，且对于所有 $k in ZZ$，整数 $k$ 和 $C - k$ 中只有一个可以写作该形式。

===== 几何意义

将 方程 $a_1 x_1 + a_2 x_2 = k$ 看成一条直线，$k$ 可以被表示当且仅当 直线经过至少一个整点，当 $k < a_1 a_2$ 时，在第一象限至多只能通过一个整点，因此，对于 $0 <= k < a_1 a_2$，整数 $k$ 可以表示，当且仅当 $k$ 在第一象限通过恰好一个整点。因此，小于等于 $a_1 a_2$ 且可以表示的自然数的数量，恰好等于第一象限内直线 $a_1 x_1 + a_2 x_2 = k$ 下的整点个数（含边界），这一数量等于：

$ sum_(i=1)^(floor(k/a_1)) floor((k - i a_1)/a_2) $

#note[
  PS:这是经典的直线下整点问题，参见 *类欧几里得算法* $O(log min(a_1, a_2, k))$ 时间求解
]

=== 费马小定理 & 欧拉定理

==== 费马小定理

- 设 $p$ 是素数，对于任意整数 $a$ 且 $p divides.not a$ 都成立

$ a^(p-1) equiv 1 (mod p) $

==== 欧拉定理

#note[*费马小定理* 是 *欧拉定理* 的一个特例]

$ gcd(a, m) = 1 arrow.r a^(phi(m)) equiv 1 (mod m) $

==== 扩展欧拉定理

$ a^b equiv cases(a^(b mod phi(m)) & gcd(a, m) = 1, a^b & gcd(a, m) != 1, b < phi(m), a^(b mod phi(m) + phi(m)) & gcd(a, m) != 1, b >= phi(m)) (mod m) $

#note[
  PS：$phi(phi(n)) <= n/2, n >= 2$ 用于估算 $phi$ 递归的 $log$ 级别
]

```cpp
// P5091
int a,m,phi=1,flag,bm;
int main(){
    scanf("%d%d",&a,&m);
    a%=m;
    int x=m;
    // 欧拉函数
    for(int i=2;i*i<=x;i++){
      if(x%i) continue;
      phi*=(i-1),x/=i;
      while(x%i==0) phi*=i,x/=i;
    }
    if(x>1) phi=phi*(x-1);
    char ch;
    while((ch=getchar())<'0'||ch>'9');
	while(bm=bm*10LL+(ch^'0'),(ch=getchar())>='0'&&ch<='9')
		if(bm>=phi) flag=1,bm%=phi;// 处理高精度带模读入
	if(bm>=phi) flag=1,bm%=phi;
	if(flag) bm+=phi;
	printf("%d",ksm(a,bm));
    return 0;
}
```

=== 模逆元（数论倒数）

==== 定义

对于 非零整数 $a, b$，如果存在 $b$ 使得 $a b equiv 1 (mod m)$，就称 $b$ 是在模 $m$ 意义下的*逆元*

==== 单个逆元的求法

===== 扩展欧几里得

$ a x equiv 1 (mod m) \ a x + m y = 1 $
- $O(log min(a, m))$

```cpp
LL inv(LL a,LL m){LL x,y;exgcd(a,m,x,y);return (x%m+m)%m;}
```

===== 快速幂法

```cpp
LL inv(LL a,LL m){return ksm(a,m-2,m);}
```

==== 多个逆元的求法

===== 阶乘计算

```cpp
int fac[N],invfac[N],inv[N];
void init(){
    fac[0]=1;
    for(int i=1;i<N;i++)fac[i]=(LL)fac[i]*i%mod;
    invfac[N-1]=ksm(fac[N-1],mod-2);
    for(int i=N-1;i>=1;i--)invfac[i-1]=(LL)invfac[i]*i%mod;
    for(int i=1;i<N;i++)inv[i]=(LL)invfac[i]*fac[i-1]%mod;
}
```

===== 线性递推

#note[不推荐]

```cpp
int inv[N];
void linear(){inv[1]=1;for(int i=2;i<N;i++)inv[i]=(LL)(mod-mod/i)*inv[mod%i]%mod;}
```

=== 线性同余方程

==== 定义

$ a x equiv b (mod n) $

==== 用逆元求解

- $gcd(a, n) = 1$ 时
$ x equiv b a^(-1) (mod n) $

- $gcd(a, n) = d > 1$ 时
1. 当 $d divides.not b$ 时 方程无解
2. 当 $d | b$ 时 转化为
$ a' x equiv b' (mod n') \ x equiv (x' + k n') (mod n), k = 0, 1, dots, d-1 $

综上，解的数量等于 $d = gcd(a, n)$ 或 0

==== 用不定方程求解

原式等价于求解
$ a x + n y = b $

由 *一次不定方程* 可知该方程的一组通解是
$ cases(x = x_0 + t n/d, y = y_0 - t a/d) $

其中 $d = gcd(a, n)$ 进而线性同余方程组的通解就是
$ x equiv (x_0 + t n/d) (mod n) $

=== 中国剩余定理

==== 定义

求解一元线性同余方程组 其中 $n_1, n_2, dots, n_k$ 两两互质
$ cases(x equiv a_1 (mod n_1), x equiv a_2 (mod n_2), dots, x equiv a_k (mod n_k)) $

==== 过程

1. 计算所有模数的乘积 $n$
2. 对于第 $i$ 个方程：
   - 计算 $m_i = n/n_i$
   - 计算 $m_i$ 在模 $n_i$ 意义下的逆元 $m_i^(-1)$
   - 计算 $c_i = m_i m_i^(-1)$
3. 方程组在模 $n$ 意义下的唯一解为： $x = sum_(i=1)^k a_i c_i (mod n)$

==== Garner算法

#note[略]

==== 中国剩余定理应用

某些问题给出的模数：*不是质数*！但是没有平方因子，可以分别对这些模数进行计算，最后用 CRT 合并答案。
如在有关组合数的计算中： $m = 999'991'658 = 2 times 3 times 4679 times 35617$
而计算一个组合数对较小的质数取模后的结果，可以利用 *卢卡斯定理*

==== 扩展：模数不互质的情况

两个方程：
$ cases(x equiv r_1 (mod p_1), x equiv r_2 (mod p_2)) arrow.r x = p_1 x + r_1 = p_2 y + r_2 arrow.r p_1 x - p_2 y = r_2 - r_1 $

- 由*裴蜀定理*，$gcd(p_1, p_2) divides.not (r_2 - r_1)$ 时 无解
- 否则使用 *扩展欧几里得* 算法 解出一组可行解 $(x_0, y_0)$
- 则原来方程组的解为 $x equiv r' (mod p')$，其中 $r' = p_1 x_0 + r_1$，$p' = lcm(p_1, p_2)$


=== 升幂引理

#note[升幂引理（Lift the Exponent Lemma，简称 LTE）是初等数论中处理形如 $v_p (a^n plus.minus b^n)$ 的 $p$-进赋值（即素因数分解中质因数 $p$ 的指数）的重要工具。]

*定义*： 

设 $n$ 为非零整数，$p$ 为质数，则 $v_p (n)$ 表示 $n$ 的标准素因数分解中 $p$ 的幂次，即满足

#note[VPN 可还行 ， 使用 $v_p (n)$ 表示 n 中 p 的次幂数呗]

$ p^(v_p (n)) | n quad "且" quad p^(v_p (n)+1) divides.not n. $

以下内容中，设 $p$ 为质数，$x, y$ 为整数，满足
$ p | x - y, quad p divides.not x, quad p divides.not y, $
且 $n$ 为正整数。

#note[
  qwq 举个栗子: p = 5 , x=11, y=6 (就是说x-y与p有特殊关系)
]

==== 第一部分

对所有的素数 $p$ 和满足 $(n,p) = 1$ 的整数 n

1. 若 $p divides x-y$ 则

$ v_p (x^n - y^n) = v_p (x-y) $

2. 若 $p divides x + y$ 则 对于奇数 n 有 

$ v_p (x^n + y^n) = v_p (x+y) $ 

#note[
  第一个证明 用n次幂差的 因式分解即可证明\
  第二个直接用 -y 替换 y 即可得出 所以就知道为什么 n 是奇数

  第一个公式还好说，其实第二个公式的概括性太强了 针对 p=2 必然要求 n 是奇数 摆脱了偶数的情形
]

==== 第二部分

设 $p$ 为*奇素数*：

#note[
  事实上 第一部分是 第二部分的特殊情况 以第二部分为主记忆\
  第一部分无法升 第二部分能升

  qwq : 要注意这里和 第一部分的区别\
  除了 p=2 但解除了 (n,p) = 1 限制 (到头来原来是区分 升 还是 不升 啊($v_p (n)$ 是否为 0))
]

1. 若 $p | x - y$ 则
$ v_p (x^n - y^n) = v_p (x - y) + v_p (n) $

#note[
  举个栗子 
  
  p=5 a=11 b=6 a-b=5 是 p 的倍数 
  a+b = 17 不是 p 的倍数 所以 
  
  - 取 n=2 
  
  $a^2 - b^2 = 121 - 36 = 85 = 5 times 19 $ 有 1 个 5 
  同时右边 $a-b = 5 times 1$ 有 1 个 5 而 n=2 没有 5 所以 
  $1 = 1 + 0$ 成立 
  
  - 同样 n=3

  $11^3 - 6^3 = 1331 - 216 = 1115 = 5 times 223 $ 有 1 个 5
  
  右边 显然是 1+0 = 1
  所以 1=1+0
]

#note[
  我理解了为什么他叫升幂引理了 *升* 是指 在 a-b 中 p 的幂次 的基础上 由于 n 次幂 带来的 + "VPN" (然鹅对于 p=2 (n为奇数) 缺无能为力)
]

2. 若 $p | x + y$ 且 $n$ 为*奇数*，则：
$ v_p (x^n + y^n) = v_p (x + y) + v_p (n) $

#note[
  同样的证明方法啊 -y 代替 y
]

3. 若 $p divides x+y$ 且 $n$ 为 *偶数* 时 
$ v_p (x^n + y^n) = 0 $

#note[
  简单又复杂的公式 难以一眼看穿 事实上就是 $2y^2$
]

==== 第三部分

若 $p=2$ 且 $p divides x-y$ (也就是 x y 都是奇数呗)

1. 对奇数 n 有 (和第一部分的1相同)

$ v_p (x^n - y^n) = v_p (x-y) $

#note[
  当然 我认为 当 $p divides x+y$ 时\ 用 -y 代替 y 肯定可以 
]

2. 对偶数 n 有

$ v_p (x^n - y^n) = v_p (x-y) + v_p (x+y) + v_p (n) - 1 $

#note[
  我知道了！！！\
  当然 我认为 当 $p divides x+y$ 时\
  $v_p (x^n + y^n) = v_2 (2y^2) = 1$ 喽
]

#note[
  一大坨!
  看一下 它 更是一个融合怪 它把 x+y x-y 都用了\
  用中文说就是:

  两个奇数 的 偶数 n 次幂差 它的 2 的因子次数 等于\
  它们的 差的2因子个数 + 它们的和的2因子个数 + n 中 2 的因子次数 - 1   
]

特别地 若 n为偶数时 $x equiv y (mod 4)$（即 $4 | x - y$）
- 有规律公式\*
  $v_2 (x+y) = 1$
- 代入 2 式得出
  $v_2 (x^n - y^n) = v_2 (x-y) + v_2 (n)$\ 
  这里是 2 式 4 同余情形的化简 变得与 第二部分的 1 差不多了

#note[
  就这么定了
]

=== 阶乘取模

#note[
  为什么要学习阶乘取模？

  我认为可能的原因

  + 取的模不一定是素数 所以可能用到中国剩余定理组合求解，而中国剩余定义将 *模数* 分为了 若干个 *素数幂* 的乘积形式 故需要对 *素数幂* 取模
  + 当涉及分数时，由于不可以使用逆元，本质要对 素数的次数作加减运算，特别是阶乘相关，需要使用阶乘取模技术
  + 有时 模数并不是固定不变的 需要在线计算对给定模数取模的结果 
  $ n! = p^(v_p (n!)) (n!)_p $
  记住这个符号表示排除p因子: $(n!)_p$ 
]

==== Wilson 定理

#note[
  Wilson 定理给出了判断某个自然数 *是素数* 的一个 *充分必要* 条件
]

对于 $n>1$ ， 当且仅当 $n$ 是素数时， $(n-1)! equiv -1 pmod(n)$

可能 $(n-1)!$ 有点 难看 所以 可以写成 $(p!)_p equiv -1 pmod(p)$

===== 推广 (Gauss)

对于自然数 $m>1$ 有 

$ product_(1<=k<m,k perp m) k equiv plus.minus 1 pmod(m) $

而且，余数中的 $plus.minus 1$ 取值为 $-1$ 当且仅当 模 $m$ 的 *原根存在*，即 $m=2,4,p^alpha,2p^alpha$ 时， 其中 $p$ 是奇素数 且 $alpha$ 是正整数。 

在计算中 尤其重要的是模数为素数幂的情形

#note[
  这里与 Wilson 不同的是 Gauss 只对 与 m *互质* 的数进行了累乘\
  得到的结果由 是否 *原根存在* 决定 
]

对于素数 $p$ 和正整数 $alpha$ 有

$ product_(1<=k<p^alpha, k perp p) k equiv cases(
  1\, & p=2 "and" alpha >= 3,
  -1\, & "otherwise" 
) pmod(p^alpha)
$

#note[
  也许这个才是真正有用的公式\
  中文理解为:\
  除了 对 2的大于等于 3次幂 以内与2互质数字的乘积为 1 以外 其他的 $p^alpha$ 以内与 $p$ 互质的数的乘积 为 $-1$ ???\
  $2^3$ 绝对是一个神秘的东西
]

=== 阶乘余数的计算

讨论: $ (n!)_p mod p^alpha$

==== 素数模的情形

#note[
  设想一下计算 $(32!)_5 mod 5$\
  首先我们先把那些 5 的 倍数 去掉一层 5 它们构成的是 $(floor.l 32/5 floor.r!)_5$ (递归)\
  非 5 的倍数可以 直接模 5 得到 $floor.l 32/5 floor.r$ 个 (5-1)!\
  剩下的边角料是 $(32 mod 5)!$
]

==== 递推式

对于 素数 $p$ 正整数 $n$ 有: 

$ (n!)_p equiv (-1)^(floor.l n/p floor.r) dot (n mod p)! dot (floor.l n/p floor.r!)_p pmod(p) $

#note[
  递归深度是 $O(log_p n)$ 在线计算阶乘 每一层复杂度是 $O(p)$ 总复杂度是 $O(p log_p n)$\
  如果预处理了阶乘则 复杂度 $O(p + log_p n)$

  以下是代码实现 
]

```cpp
// Calculate (n!)_p mod p.
int factmod(int n, int p) {
  // Pretreatment. 预处理阶乘
  std::vector<int> f(p);
  f[0] = 1;
  for (int i = 1; i < p; ++i) {
    f[i] = (long long)f[i - 1] * i % p;
  }
  // Recursion. 迭代计算 f[n] 表示 (n!)_p mod p
  int res = 1;
  while (n > 1) {
    if ((n / p) & 1) res = p - res;
    res = (long long)res * f[n % p] % p;
    n /= p;
  }
  return res;
}
```

==== 素数幂模的情形

#note[
  可以仿照素数模的情形解决\
  只需要将 Wilson 定理替换成它的推广形式．本节两个结论中的 $plus.minus 1$\
  均特指这样的定义：当模数  $p=2 且 alpha >=3$ 时取 1 其余情形取 -1\
  (和我想的一样！)
]

定义式如下 

$ 
  (n!)_p equiv (plus.minus 1)^(floor.l n/(p^alpha )floor.r) dot ( product_(1<=j<=(n mod p^alpha),j perp p) j ) dot (floor.l n/p floor.r!)_p pmod(p^alpha)
$

不同的地方
+ $-1$ 替换为 $plus.minus 1$ 
+ 边角料阶乘变成了 *互质阶乘* (仅取所有互质的数相乘)

==== 递推式

如下

$
  (n!)_p equiv (plus.minus 1)^(sum_(j>=alpha) floor.l n/(p^j) floor.r) product_(j>=0) F(floor.l n/(p^j) floor.r mod p^alpha)
$

素数幂模的情形的实现和素数模的情形类似，只有一些细节上的区别．与上文类似，同样可以将预处理放到函数外进行．

#note[
  预处理的时间复杂度为 $O(p^alpha)$ ，单次询问的时间复杂度为 $O(log_p n)$
]

```cpp
// Calculate (n!)_p mod pa.
int factmod(int n, int p, int pa) {
  // Pretreatment.
  std::vector<int> f(pa);
  f[0] = 1;
  for (int i = 1; i < pa; ++i) {
    f[i] = i % p ? (long long)f[i - 1] * i % pa : f[i - 1];
  }
  // Recursion.
  bool neg = p != 2 || pa <= 4;
  int res = 1;
  while (n > 1) {
    if ((n / pa) & neg) res = pa - res;
    res = (long long)res * f[n % pa] % pa;
    n /= p;
  }
  return res;
}
```

=== 幂次的计算

#note[
  $v_p (n!)$ 的计算\
  它可以用于计算二项式系数的余数．因为二项式系数中，分子和分母都会出现阶乘
]

==== Legendre 公式

#note[
  阶乘 $n!$ 中素数 $p$ 的幂次可以通过 Legendre 公式计算，而且与 $n$ 在 $p$ 进制下的表示有关
]

$
  v_p (n!) = sum_(i=1)^infinity floor.l n/(p^i) floor.r = (n- S_p (n))/(p-1) 
$

#note[
  其中 $S_p (n)$ 为 $p$ 进制下， $n$ 的各个数位的和 
  
  特别地，$p=2$ 时，
  $v_2 (n!) = n - S_2(n) = n - "popcount"(n)$ 
  
  (看起来像 $O(1)$ 很 nb 其实还得是按照 `while` 循环)

  它的时间复杂度为 $O(log_p n)$
]

```cpp
// Obtain multiplicity of p in n!.
int multiplicity_factorial(int n, int p) {
  int count = 0;
  do {
    n /= p;
    count += n;
  } while (n);
  return count;
}
```

==== Kummer 定理

#note[
  WC 牛逼)\
  组合数对一个数取模的结果，往往构成分形结构，例如谢尔宾斯基三角形就可以通过组合数模 2 得到\
  如果仔细分析， $p$ 是否整除组合数其实和上下标在 $p$ 进制下减法是否需要借位有关．这就有了 Kummer 定理．
]

素数 $p$ 在 组合数 $binom(m,n)$ 中的幂次，恰好是 $p$ 进制下 $m$ 减掉 $n$ 需要借位的次数，亦即

$
  v_p (binom(m,n)) = (S_p (n) + S_p (m-n) - S_p (m))/(p-1)
$

特别地，组合数中 $2$ 的幂次是 $v_2 (binom(m,n)) = S_2 (n) + S_2(m-n) - S_2(m)$

#note[
  最后的例题真 nb\
  $ sum_(k=1)^n floor.l ((3k+6)!+1)/(3k+7) - floor.l (3k+6)!/(3k+7) floor.r floor.r $
  这倒是启发我了\
  原来 只有当 n 是质数的时候 
  $ (n-1)! equiv cases(
    -1\, n "is prime",
    0\, n eq.not 4 "and" n "is not prime",
    2\, n eq 4
  ) pmod(n) $
  是啊！如果不是质数的话，必然会被之前按的两个小因子给撑爆。（WC 除了4=2*2）
]

=== 卢卡斯定理

==== 内容

对于素数 $p$ 有

$ binom(n, k) equiv binom(floor(n/p), floor(k/p)) binom(n mod p, k mod p) pmod(p) $

- 复杂度 $O(p + T log_p n)$

```cpp
// 基础版本
LL Lucas(LL n,LL k,LL p) {
  if (k==0) return 1;
  return (C(n%p,k%p,p)*Lucas(n/p,k/p,p))%p;
}
// 带预处理版本
struct BinomModPrime {
  int p;
  std::vector<int> fa, ifa;

  // Calculate binom(n, k) mod p for n, k < p.
  int calc(int n, int k) {
    if (n < k) return 0;
    long long res = fa[n];
    res = (res * ifa[k]) % p;
    res = (res * ifa[n - k]) % p;
    return res;
  }

  BinomModPrime(int p) : p(p), fa(p), ifa(p) {
    // Factorials mod p till p.
    fa[0] = 1;
    for (int i = 1; i < p; ++i) {
      fa[i] = (long long)fa[i - 1] * i % p;
    }
    // Inverse of factorials mod p till p.
    ifa[p - 1] = p - 1;  // Wilson's theorem.
    for (int i = p - 1; i; --i) {
      ifa[i - 1] = (long long)ifa[i] * i % p;
    }
  }

  // Calculate binom(n, k) mod p.
  int binomial(long long n, long long k) {
    long long res = 1;
    while (n || k) {
      res = (res * calc(n % p, k % p)) % p;
      n /= p;
      k /= p;
    }
    return res;
  }
};
```

==== exLucas

#note[
  针对 $p$ 不是素数的情况\
  1. 先算素数幂
  2. 再通过 CRT 计算合数
]

===== 模素数幂的情况

#note[
  事实上，你这种方法你已经会了\
  其实就是直接算
]

$
  binom(n,k) = p^(v_p (n!)-v_p (k!)-v_p ((n-k)!)) (n!)_p / ((k!)_p ((n-k)!)_p )
$

#note[
  前者通过 Legendre 公式计算\
  后者通过 exgcd 计算逆元\
  有个小优化，就是 $"次幂数" >= alpha$ 一定为 0 了
]

===== 模一般数的情况

#note[
  使用中国剩余定理(CRT) 求解！\
  以下是封装好的计算器:
]

```cpp
// Extended Euclid.
void ex_gcd(int a, int b, int& x, int& y) {
  if (!b) {
    x = 1;
    y = 0;
  } else {
    ex_gcd(b, a % b, y, x);
    y -= a / b * x;
  }
}

// Inverse of a mod m.
int inverse(int a, int m) {
  int x, y;
  ex_gcd(a, m, x, y);
  return (x % m + m) % m;
}

// Coefficient in CRT.
int crt_coeff(int m_i, int m) {
  long long mm = m / m_i;
  mm *= inverse(mm, m_i);
  return mm % m;
}

// Binominal Coefficient Calculator Modulo Prime Power.
struct BinomModPrimePower {
  int p, a, pa;
  std::vector<int> f;

  // Obtain multiplicity of p in n!.
  long long nu(long long n) {
    long long count = 0;
    do {
      n /= p;
      count += n;
    } while (n);
    return count;
  }

  // Calculate (n!)_p mod pa.
  long long fact_mod(long long n) {
    bool neg = p != 2 || pa <= 4;
    long long res = 1;
    while (n > 1) {
      if ((n / pa) & neg) res = pa - res;
      res = res * f[n % pa] % pa;
      n /= p;
    }
    return res;
  }

  BinomModPrimePower(int p, int a, int pa) : p(p), a(a), pa(pa), f(pa) {
    // Pretreatment.
    f[0] = 1;
    for (int i = 1; i < pa; ++i) {
      f[i] = i % p ? (long long)f[i - 1] * i % pa : f[i - 1];
    }
  }

  // Calculate Binom(n, k) mod pa.
  int binomial(long long n, long long k) {
    long long v = nu(n) - nu(n - k) - nu(k);
    if (v >= a) return 0;
    auto res = fact_mod(n - k) * fact_mod(k) % pa;
    res = fact_mod(n) * inverse(res, pa) % pa;
    for (; v; --v) res *= p;
    return res % pa;
  }
};

// Binominal Coefficient Calculator.
struct BinomMod {
  int m;
  std::vector<BinomModPrimePower> bp;
  std::vector<long long> crt_m;

  BinomMod(int n) : m(n) {
    // Factorize.
    for (int p = 2; p * p <= n; ++p) {
      if (n % p == 0) {
        int a = 0, pa = 1;
        for (; n % p == 0; n /= p, ++a, pa *= p);
        bp.emplace_back(p, a, pa);
        crt_m.emplace_back(crt_coeff(pa, m));
      }
    }
    if (n > 1) {
      bp.emplace_back(n, 1, n);
      crt_m.emplace_back(crt_coeff(n, m));
    }
  }

  // Calculate Binom(n, k) mod m.
  int binomial(long long n, long long k) {
    long long res = 0;
    for (size_t i = 0; i != bp.size(); ++i) {
      res = (bp[i].binomial(n, k) * crt_m[i] + res) % m;
    }
    return res;
  }
};

int main() {
  int t, m;
  std::cin >> t >> m;
  BinomMod bm(m);
  for (; t; --t) {
    long long n, k;
    std::cin >> n >> k;
    std::cout << bm.binomial(n, k) << '\n';
  }
  return 0;
}
```

=== 同余方程（模合数同余方程 & 高次同余方程）

#note[
  解同余方程 $f(x) equiv 0 pmod(m)$ 的方法
]

==== 素数幂模同余方程

#note[
  形如 $f(x) equiv 0 pmod(p^e)$ 
]

===== Hensel 引理

若已知 $f(x) equiv 0 pmod(p^e)$ 的解 $x_e$，求模 $p^(e+1)$ 的解：

1. *分支一：唯一提升* (常见于 $p > 2$)

   若 $f'(x_e) equiv.not 0 pmod(p)$，则存在唯一解
   $ x_(e+1) = x_e - f(x_e) dot [f'(x_e)]^(-1) pmod(p^(e+1)) $
    #note[
  *公式来源与推导*：
  利用泰勒展开：$f(x_e + t p^e) approx f(x_e) + f'(x_e) t p^e pmod(p^(e+1))$。
  
  令 $f(x_e) + f'(x_e) t p^e equiv 0 pmod(p^(e+1))$：
  1. 两边除以 $p^e$：$f(x_e)/p^e + f'(x_e) t equiv 0 pmod(p)$。
  2. 解出 $t equiv - (f(x_e)/p^e) dot [f'(x_e)]^(-1) pmod(p)$。
  3. 代入 $x_(e+1) = x_e + t p^e$，合并即得牛顿迭代形式：
  $ x_(e+1) = x_e - f(x_e) dot [f'(x_e)]^(-1) pmod(p^(e+1)) $
  *注意*：此处的逆元是在模 $p$ 意义下计算，但乘法在模 $p^(e+1)$ 意义下执行。
  ]

2. *分支二：分裂提升*
   
   若 $f'(x_e) equiv 0 pmod(p)$ 且 $f(x_e) equiv 0 pmod(p^(e+1))$\  
   则 $x_e$ 产生 $p$ 个新解
   $ x_(e+1) = x_e + t dot p^e, quad t in {0, 1, dots, p-1} $

3. *分支三：无法提升*
   
   若 $f'(x_e) equiv 0 pmod(p)$ 且 $f(x_e) equiv.not 0 pmod(p^(e+1))$\
   则该解 $x_e$ 在模 $p^(e+1)$ 下无对应的解。

#example[
  求解：$x^2 equiv 1 pmod(144)$

  *1. 分解模数*
  
  $ 144 = 2^4 dot 3^2 = 16 dot 9 $
  方程组化为：
  $ cases(x^2 - 1 equiv 0 pmod(16), x^2 - 1 equiv 0 pmod(9)) $

  *2. 求解子方程 $f(x) = x^2 - 1 equiv 0 pmod(9)$*

  - *基础解*：模 3 时，$x^2 equiv 1 pmod(3) arrow.r x_1 equiv 1, 2 pmod(3)$。\
  - *Hensel 提升*（$f'(x) = 2x$）：\
    - 对于 $x_1 = 1$：$f'(1) = 2 equiv.not 0 pmod(3)$，存在唯一提升。\
      设 $x_2 = 1 + 3t$，代入 $x^2 equiv 1 pmod(9) arrow.r 1 + 6t equiv 1 pmod(9) arrow.r 6t equiv 0 pmod(9) arrow.r t=0$。\
      得到 $x equiv 1 pmod(9)$。\
    - 对于 $x_1 = 2$：$f'(2) = 4 equiv 1 equiv.not 0 pmod(3)$，存在唯一提升。\
      设 $x_2 = 2 + 3t$，代入 $(2+3t)^2 equiv 1 pmod(9) arrow.r 4 + 12t equiv 1 pmod(9) arrow.r 3 + 3t equiv 0 pmod(9) arrow.r t=2$。\
      得到 $x = 2 + 3(2) = 8 equiv -1 pmod(9)$。\
  - 得到 $x pmod(9) in {1, 8}$。\

*3. 求解子方程 $f(x) = x^2 - 1 equiv 0 pmod(16)$*

  由于 $f'(x) = 2x$，在 $p=2$ 时恒有 $f'(x) equiv 0 pmod(2)$。按 Hensel 引理的分支 2/3 递归提升：

  - *Step 1 ($2^1 arrow.r 2^2$)*: \
    模 2 底解为 $x_1 = 1$。\
    检查：$f(1) = 0 equiv 0 pmod(4)$。\
    触发 *分支 2*：解分裂为 $x_2 = 1 + t dot 2 arrow.r x in {1, 3} pmod(4)$。\

  - *Step 2 ($2^2 arrow.r 2^3$)*:\
    - 对 $x=1$：$f(1) = 0 equiv 0 pmod(8)$。触发 *分支 2* $arrow.r x in {1, 5} pmod(8)$。\
    - 对 $x=3$：$f(3) = 8 equiv 0 pmod(8)$。触发 *分支 2* $arrow.r x in {3, 7} pmod(8)$。\
    此时解为 $x in {1, 3, 5, 7} pmod(8)$。

  - *Step 3 ($2^3 arrow.r 2^4$)*:\
    - 对 $x=1$：$f(1) = 0 equiv 0 pmod(16)$。*分支 2* $arrow.r x in {1, 9}$。\
    - 对 $x=3$：$f(3) = 8 equiv.not 0 pmod(16)$。*分支 3* $arrow.r$ #underline[无解，舍弃]。\
    - 对 $x=5$：$f(5) = 24 equiv 8 equiv.not 0 pmod(16)$。*分支 3* $arrow.r$ #underline[无解，舍弃]。\
    - 对 $x=7$：$f(7) = 48 equiv 0 pmod(16)$。*分支 2* $arrow.r x in {7, 15}$。\

  得到 $x pmod(16) in {1, 7, 9, 15}$。

  *4. CRT 合并*

  解的组合共有 $2 times 4 = 8$ 个。设 $x equiv a_1 pmod(16), x equiv a_2 pmod(9)$。\
  使用 CRT 公式：$x = (a_1 dot 9 dot [9^(-1)]_16 + a_2 dot 16 dot [16^(-1)]_9) pmod(144)$\
  - $9^(-1) mod 16 = 9$ (因 $81 equiv 1$)\
  - $16^(-1) mod 9 = 4$ (因 $64 equiv 1$)\
  $ x = (81a_1 + 64a_2) pmod(144) $\

  代入组合 $(a_1, a_2)$ 计算：\
  #align(center, table(
    columns: (auto, auto, auto),
    [$(a_1, a_2)$], [$81a_1 + 64a_2$], [$x mod 144$],
    [(1, 1)], [$81+64$], [*1*],
    [(1, 8)], [$81+512$], [*17*],
    [(7, 1)], [$567+64$], [*55*],
    [(7, 8)], [$567+512$], [*71*],
    [(9, 1)], [$729+64$], [*73*],
    [(9, 8)], [$729+512$], [*89*],
    [(15, 1)], [$1215+64$], [*127*],
    [(15, 8)], [$1215+512$], [*143*],
  ))
  
  故原方程的解为 $x in {1, 17, 55, 71, 73, 89, 127, 143} pmod(144)$。
]

#note(title:text("推论：唯一提升的存在性"))[
  若 $s$ 是 $f(x) equiv 0 pmod(p)$ 的一个解，且满足非奇异条件 $f'(s) equiv.not 0 pmod(p)$，则：

  + 对于任何整数 $e >= 1$，在模 $p^e$ 意义下存在唯一的解 $x_e$ 使得 $x_e equiv s pmod(p)$。 
  + 换言之，只要底解的导数不为 0，该解在提升过程中*既不会分裂，也不会消失*。
]


#note(title:text("推论：解数守恒判定（解数判别准则）"))[
  若方程 $f(x) equiv 0 pmod(p)$ 与 $f'(x) equiv 0 pmod(p)$ *无公共解*（即所有模 $p$ 的基础解均为非奇异解），则：
  $ "方程 " f(x) equiv 0 pmod(p^e) " 的解数 " equiv " 方程 " f(x) equiv 0 pmod(p) " 的解数 " $

  用于快速排除不可能的情况或直接确定搜索范围。
]

#example[
  判断 $x^2 + x + 1 equiv 0 pmod(5^k)$ 的解数。
  - $f(x) = x^2 + x + 1$，模 5 时判别式 $Delta = 1^2 - 4(1)(1) = -3 equiv 2 pmod(5)$。
  - 由于 2 不是模 5 的二次剩余，故模 5 无解。
  - 根据推论，模 $5^k$ 亦无解。
]

==== 素数模同余方程

#note[
  令 $p$ 为素数，$f(x) = sum_(i=0)^n a_i x^i$ 为整系数多项式，且 $p thin divides.not a_n$。
]

===== 同余方程因式分解 定理

#note[
  *本质理解*：该定理说明在模素数 $p$ 下，同余方程的解与多项式的因式具有对应关系。这为 Lagrange 定理（解数不超过次数）提供了证明基础。
]

若方程 $f(x) equiv 0 pmod(p)$ 有 $k$ 个不同的解 $x_1, x_2, dots, x_k$ ($k <= n$)，则存在多项式 $g(x)$ 使得：
$ f(x) equiv g(x) product_(i=1)^k (x - x_i) pmod(p) $
其中满足：
- $deg g = n - k$
- $g(x)$ 的最高次项系数 $[x^(n-k)]g(x) = a_n$

#note(title:text("推论: 模 p 多项式的根与因式分解的关系"))[
  $ forall x in ZZ, x^(p-1) - 1 equiv product_(i=1)^(p-1)(x-i) pmod(p) $
]

#note(title:text("推论: Wilson 定理"))[
  对于素数 $p$，恒有：

  $ x^(p-1) - 1 equiv product_(i=1)^(p-1) (x - i) pmod(p) $

  由此可得常数项关系：$(p-1)! equiv -1 pmod(p)$。
]

===== Lagrange 定理

方程 $f(x) equiv 0 pmod(p)$ 在模 $p$ 下至多有 $n$ 个不同的解。

#note(title:text("推论： 同余多项式的零恒等式判定（或 Lagrange 定理的逆否定理）"))[
若 $n$ 次同余方程 $sum_(i=0)^n b_i x^i equiv 0 pmod(p)$ 的解数大于 $n$，则必有

$ (forall i=0,1,dots,n), quad p divides b_i $
]

=====  同余方程降次定理 / 基于费马小定理的次数约减

方程 $f(x) equiv 0 pmod(p)$ 若解的个数不为 $p$, 则必存在满足 $deg r < p$ 的整系数多项式 $r(x)$ 使得 $f(x) equiv 0 pmod(p)$ 和 $r(x) equiv 0 pmod(p)$ 的解集相同.

#note(title: "技巧：利用费马小定理降次")[
  若次数 $n >= p$，由于 $x^p equiv x pmod(p)$，可令 $f(x) = g(x)(x^p - x) + r(x)$。
  
  则 $f(x) equiv 0$ 与 $r(x) equiv 0$ 的解集完全相同，且 $deg r < p$。

  *应用：* 在模 $p$ 意义下，任何高次方程都可以降到 $p-1$ 次以下。
]

===== 满解判别准则 / 同余方程具有最大解数的充要条件

设 $n <= p$ 则方程 

$ x^n + sum_(i=0)^(n-1) a_i x_i equiv pmod(p) $

有 $n$ 个解当且仅当存在整系数多项式 $q(x),r(x) (deg r < n)$ 使得 

$ x^p - x equiv f(x)q(x) + p r(x)$

#note[
  对于非首一多项式，由于 $ZZ_p$ 是域，故可以将其化为首一多项式，从而适用该定理．
]

===== 判定与解数

设 $n divides p-1, p divides.not a$, 则方程

$ x^n equiv a pmod(p) $

有解当且仅当 $a^((p-1)/n) equiv 1 pmod(p)$

而且, 若方程有解, 则解数为 $n$.

#example[
  判断 $x^4 equiv 2 pmod(13)$ 的解数。
  - $n=4, p-1=12$, 故 $d = gcd(4, 12) = 4$。
  - 检查 $2^((13-1)/4) = 2^3 = 8 equiv.not 1 pmod(13)$。
  - 结论：该方程在模 13 下无解（解数为 0）。
]

==== 高次同余方程求解全路径

#note(title: "综合求解 Pipeline")[
  求解 $f(x) equiv 0 pmod(m)$ 的通用逻辑链：
  1. *分解模数*：利用 CRT 将 $m$ 分解为 $p_i^(e_i)$。
  2. *Hensel 提升*：将模 $p_i$ 的基础解提升到 $p_i^(e_i)$。
  3. *基础解求解*：
    - *线性 ($n=1$)*：使用 `exGCD`。
    - *二次 ($n=2$)*：使用 `Tonelli-Shanks`。
    - *纯幂式 ($x^n equiv a$)*：$n$-th Root 算法（BSGS + 线性同余）。
    - *一般高次*：
      - *降次*：若 $n >= p$，先用 $x^p-x$ 取模。
      - *消项*：通过代换 $x = y - a_(n-1)/(n a_n)$ 消去 $n-1$ 次项。
      - *搜索*：$p$ 较小时直接穷举；$p$ 较大时使用 `Cantor-Zassenhaus` 算法进行多项式因式分解。
]

=== 二次剩余与二次同余方程

#note[
  判断存在性与快速开方
  
  求解方程 $x^2 equiv a pmod(p)$，其中 $p$ 为奇素数且 $p thin divides.not a$。
]

==== 二次剩余定义

若方程 $x^2 equiv a pmod(p)$ 有解，则称 $a$ 是模 $p$ 的*二次剩余*；否则称为*二次非剩余*。

==== Euler 判别法

对于奇素数 $p$，有：
- 若 $a^((p-1)/2) equiv 1 pmod(p)$，则 $a$ 是模 $p$ 的二次剩余。
- 若 $a^((p-1)/2) equiv -1 pmod(p)$，则 $a$ 是模 $p$ 的二次非剩余。

#note(title:text("推论: 二次剩余的数量"))[
  对于奇素数 $p$, 模 $p$ 意义下二次剩余和二次非剩余均有 $(p-1)/2$ 个．
]

==== 勒让德符号 (Legendre Symbol)

定义
$ lr((a/p)) = cases(1 & a "是模 " p " 的二次剩余", -1 & a "是模 " p " 的二次非剩余", 0 & p divides a) $

===== 性质

+ 对任意整数 $a$ 
  $ lr((a/p)) equiv a^((p-1)/2) pmod(p) $
  推论
  + $ lr((1/p)) = 1. $
  + $ lr(((-1)/p)) = (-1)^((p-1)/2) = cases(1\, &p equiv 1 pmod(4)., -1\, &p equiv 3 pmod(4)). $
+ $ a_1 equiv a_2 pmod(p) ==> lr((a_1/p)) = lr((a_2/p)).$
+ 完全积性
  $ lr((a/p)) dot lr((b/p)) = lr(((a b)/p)) $
  推论
  + 对于整数 $a,b, p divides.not b$
    $ lr(((a b^2)/p) = lr((a/p))). $
  + $ lr((2/p)) = (-1)^((p^2-1)/8) = cases(1\, & p equiv plus.minus 1 pmod(8), -1\,& p equiv plus.minus 3 pmod(8)) $

===== 二次互反律

设 $p,q$ 是两个不同的奇素数, 则

$ lr((p/q))lr((q/p)) = (-1)^((p-1)/2 dot (q-1)/2) $

#note(title:text("Gauss 引理"))[
  设 $p$ 是奇素数, $(n,p) = 1$, 对整数 $k (1<=k<=(p-1)/2)$, 令 $r_k = n k mod p$, 设 $A = {r_k:r_k < p/2}, B= {r_k,r_k>p/2}$, 则 

  $ lr((n/p)) = (-1)^(|B|) $
]

#note(title:text("推论"))[
  $ lr((n/p)) = (-1)^(sum_(i=1)^((p-1)/2)floor.l (n i)/p floor.r). $
]

==== 雅可比符号 (Jacobi Symbol)

#note[
  雅可比符号是勒让德符号的推广，将其底数从素数推广至任意奇正整数。
]

#note(title: text("定义"))[
  设 $n$ 为大于 1 的奇数，其素因子分解为 $n = p_1^(e_1) p_2^(e_2) dots p_k^(e_k)$。对于任意整数 $a$，定义雅可比符号为：
  $ lr((a/n)) = product_(i=1)^k lr((a/p_i))^(e_i) $
]

#note(title: text("性质与判定"))[
  + *判定必要性*：若 $x^2 equiv a pmod(n)$ 有解，则必有 $lr((a/n)) = 1$。
  + *不充分性*：$lr((a/n)) = 1$ 并不意味着方程一定有解。
    - 例如 $lr((2/9)) = lr((2/3))^2 = (-1)^2 = 1$，但 $x^2 equiv 2 pmod(9)$ 无解。
  + *计算优势*：计算雅可比符号无需分解 $n$，可直接利用二次互反律：
    $ lr((m/n)) lr((n/m)) = (-1)^((m-1)/2 dot (n-1)/2) quad (m, n "为奇正整数") $
]

==== 二次同余方程求解 $x^2 equiv a pmod(p)$

#note[
    焯就完了
]

```cpp
#include <bits/stdc++.h>

using namespace std;

#define LL long long
#define LLL __int128

namespace Math {
    inline LL mul(LL a, LL b, LL m) { return (LL)((LLL)a * b % m); }
    inline LL ksm(LL a, LL b, LL m) {
        LL res = 1; a %= m;
        for (; b; b >>= 1, a = mul(a, a, m)) if (b & 1) res = mul(res, a, m);
        return res;
    }
    inline LL inv(LL a, LL m) {
        LL b = m, u = 1, v = 0;
        while (b) { LL t = a / b; a -= t * b; swap(a, b); u -= t * v; swap(u, v); }
        return (u % m + m) % m;
    }
}

namespace Rho {
    using namespace Math;
    inline bool miLLer_rabin(LL n) {
        if (n < 2) return 0;
        if (n == 2 || n == 3) return 1;
        if (!(n & 1)) return 0;
        LL d = n - 1; int s = __builtin_ctzll(d); d >>= s;
        static const  LL test[] = {2, 3, 5, 7, 11, 13, 17, 19, 23};
        for (LL a : test) {
            if (n <= a) break;
            LL x = ksm(a, d, n);
            if (x == 1 || x == n - 1) continue;
            bool ok = 0;
            for (int r = 1; r < s; ++r) {
                x = mul(x, x, n);
                if (x == n - 1) { ok = 1; break; }
            }
            if (!ok) return 0;
        }
        return 1;
    }
    inline LL poLLard_rho(LL n) {
        if (!(n & 1)) return 2;
        static mt19937_64 rng(time(0));
        LL x = rng() % n, y = x, c = rng() % n, d = 1;
        auto f = [&](LL x) { return (mul(x, x, n) + c) % n; };
        while (1) {
            x = f(x), y = f(f(y)), d = gcd(abs(x - y), n);
            if (d == n) return poLLard_rho(n);
            if (d > 1) return d;
        }
    }
    void factorize(LL n, map<LL, int> &f) {
        if (n < 2) return;
        if (miLLer_rabin(n)) { f[n]++; return; }
        LL d = poLLard_rho(n);
        factorize(d, f), factorize(n / d, f);
    }
}

namespace Find_root {
    using namespace Math;
    LL W2, Mod;
    struct complex {
        LL x, y;
        complex(LL _x = 0, LL _y = 0) : x(_x), y(_y) {}
        inline friend complex operator * (const  complex &a, const  complex &b) {
            return complex((mul(a.x, b.x, Mod) + mul(mul(a.y, b.y, Mod), W2, Mod)) % Mod,
                           (mul(a.x, b.y, Mod) + mul(a.y, b.x, Mod)) % Mod);
        }
    };
    inline complex cpow(complex a, LL b) {
        complex res(1, 0);
        for (; b; b >>= 1, a = a * a) if (b & 1) res = res * a;
        return res;
    }
    inline LL solve_p(LL a, LL p) {
        a %= p; if (!a) return 0;
        if (p == 2) return a & 1;
        if (ksm(a, (p - 1) >> 1, p) == p - 1) return -1;
        LL b; static mt19937_64 rng(19260817);
        while (1) {
            b = rng() % p; W2 = (mul(b, b, p) - a + p) % p;
            if (ksm(W2, (p - 1) >> 1, p) == p - 1) break;
        }
        Mod = p;
        LL res = cpow(complex(b, 1), (p + 1) >> 1).x;
        return min(res, p - res);
    }
    inline LL solve_2k(LL a, int k) {
        LL m = 1LL << k; a %= m; if (!a) return 0;
        int v = __builtin_ctzll(a); if (v & 1) return -1;
        LL a1 = a >> v, m1 = 1LL << (k - v), res = 1;
        if (m1 > 1 && (a1 & 3) != 1) return -1;
        if (m1 > 4 && (a1 & 7) != 1) return -1;
        if (m1 > 4) {
            res = 1;
            for (int i = 3; i < k - v; ++i)
                if (((LLL)res * res % (2LL << i)) != a1 % (2LL << i)) res += (1LL << (i - 1));
        }
        return res << (v >> 1);
    }
    inline LL solve_pk(LL a, LL p, int k) {
        if (p == 2) return solve_2k(a, k);
        LL pk = 1; for (int i = 0; i < k; ++pk *= p, ++i);
        a %= pk; if (!a) return 0;
        int v = 0; LL tmp = a; while (tmp % p == 0) tmp /= p, v++;
        if (v & 1) return -1;
        LL a1 = a, pv = 1; for (int i = 0; i < v; ++i) a1 /= p, pv *= (i < (v >> 1) ? p : 1);
        int k1 = k - v; if (k1 <= 0) return pv;
        LL res = solve_p(a1 % p, p); if (res == -1) return -1;
        LL cur = p;
        for (int i = 1; i < k1; ++i) {
            LL f = ((LLL)res * res - a1) % (cur * p); if (f < 0) f += cur * p;
            LL t = mul(f / cur, p - inv(2 * res, p), p);
            res = (res + (LLL)t * cur) % (cur * p), cur *= p;
        }
        return res * pv;
    }
    inline LL solve_any(LL a, LL m) {
        if (m == 1) return 0;
        map<LL, int> f; Rho::factorize(m, f);
        LL ans = 0, cur_m = 1;
        for (auto &it : f) {
            LL p = it.first, pk = 1; for (int i = 0; i < it.second; ++i, pk *= p);
            LL r = solve_pk(a, p, it.second); if (r == -1) return -1;
            LL vM = inv(cur_m, pk);
            ans = ans + (LLL)(r - ans % pk + pk) % pk * vM % pk * cur_m;
            cur_m *= pk;
        }
        return ans;
    }
}

int main() {
    ios::sync_with_stdio(0); cin.tie(0); cout.tie(0);
    int T; 
    cin>>T;
    while (T--) {
        LL a, m; cin >> a >> m;
        LL res = Find_root::solve_any(a, m);
        LL res2=m-res;
        if(res>res2)swap(res,res2);
        if (res == -1) cout << "Hola!" << "\n";
        else if(res==0) cout << res << "\n";
        else cout<<res<<" "<<res2<<"\n";
    }
    return 0;
}
```

// 阶 & 原根 笔记整理

=== 阶 & 原根

// 前置知识：费马小定理、欧拉定理、拉格朗日定理
#note[
  阶和原根是理解模 $m$ 既约剩余系 $bold(Z)_m^*$ 乘法结构的重要工具。
]

==== 阶 (Order)

#note[
  对于 $a in ZZ, m in NN_+$ 且 $a perp m$，满足 $a^n equiv 1 pmod(m)$ 的最小正整数 $n$ 称为 $a$ 模 $m$ 的 *阶*，记作 $delta_m (a)$ 或 $"ord"_m (a)$。
]

可能的求法？

```cpp
/*
 * @brief 求 a 模 m 的阶 ord_m(a)
 * @param a 底数
 * @param m 模数
 * @param phi_m 预计算好的 phi(m)
 * @return long long 阶
 */
long long get_order(long long a, long long m, long long phi_m) {
    if (__gcd(a, m) != 1) return -1; // 阶不存在
    
    long long res = phi_m;
    long long temp = phi_m;
    
    // 对 phi(m) 进行质因数分解
    for (long long i = 2; i * i <= temp; i++) {
        if (temp % i == 0) {
            // 找到一个质因子 i，尝试缩小 res
            while (res % i == 0 && ksm(a, res / i, m) == 1) {
                res /= i;
            }
            while (temp % i == 0) temp /= i;
        }
    }
    // 处理最后的较大质因子
    if (temp > 1) {
        if (res % temp == 0 && ksm(a, res / temp, m) == 1) {
            res /= temp;
        }
    }
    return res;
}
```

#note(title: "注：半阶")[
  满足 $a^n equiv -1 pmod(m)$ 的最小正整数称为“半阶”，记作 $delta_m^- (a)$。阶一定存在，半阶不一定。
]

===== 幂的循环结构

#note[
  利用阶可刻画幂的循环结构：对于 $n = delta_m (a)q + r$，有 $a^n equiv a^r pmod(m)$。
]

#note(title: "性质 1：不同余性")[
  $a^0, a^1, dots, a^(delta_m (a)-1) pmod(m)$ 两两不同余。
]

#note(title: "性质 2：阶的整除性")[
  $a^n equiv 1 pmod(m) <==> delta_m (a) divides n$。
  由此推论：对于所有 $a perp m$，有 $delta_m (a) divides phi(m)$。
]

#note(title: "性质 3：幂的阶")[
  $delta_m (a^k) = frac(delta_m (a), gcd(delta_m (a), k))$
]

#note(title: "性质 4：乘积的阶")[
  $frac([delta_m (a), delta_m (b)], (delta_m (a), delta_m (b))) divides delta_m (a b) divides [delta_m (a), delta_m (b)]$

  *性质 4'*：$delta_m (a b) = delta_m (a) delta_m (b) <==> delta_m (a) perp delta_m (b)$
]

#note(title: "性质 5：构造指定阶")[
  对于 $a, b perp m$，总是存在 $c perp m$ 使得 $delta_m (c) = [delta_m (a), delta_m (b)]$。
]

==== 原根 (Primitive Root)

#note[
  如果存在 $g perp m$ 使得 $delta_m (g) = phi(m)$，则称 $g$ 为模 $m$ 的 *原根*。
  此时 $g$ 的幂次构成模 $m$ 的既约剩余系。原根即为循环群的生成元。
]

===== 原根判定定理

#note[
  对于 $m >= 3$ 和 $g perp m$，$g$ 是模 $m$ 的原根，当且仅当对于 $phi(m)$ 的每个素因子 $p$，都有：
  $ g^(phi(m)/p) equiv.not 1 pmod(m) $
]

===== 原根个数

#note[
  若模 $m$ 有原根，则模 $m$ 的 $d$ 阶元素存在当且仅当 $d divides phi(m)$，且恰有 $phi(d)$ 个。
  特别地，模 $m$ 的原根个数为 $phi(phi(m))$。
]

===== 原根存在定理

#note[
  模 $m$ 的原根存在，当且仅当：
  $ m = 1, 2, 4, p^e, 2p^e quad (p "为奇素数") $
]

==== 求原根的算法

#note(title: "实践")[
  1. *枚举*：从小到大枚举 $g$，配合判定定理。
  2. *复杂度*：最小原根 $g_m$ 极小（$O(m^0.25)$ 级别），枚举开销可接受。
  3. *瓶颈*：判定原根需对 $phi(m)$ 分解质因数（Pollard-Rho）。
]

==== Carmichael 函数 ($lambda(m)$)

#note[
  $lambda(m)$ 是使得 $a^n equiv 1 pmod(m)$ 对所有 $a perp m$ 均成立的最小正整数 $n$。
  $lambda(m) = lcm {delta_m (a) : a perp m} = max {delta_m (a) : a perp m}$
]

===== 递推公式
#note[
  1. $lambda(m_1 m_2) = [lambda(m_1), lambda(m_2)]$ 对 $m_1 perp m_2$ 成立。
  2. 素数幂取值：
     - $lambda(2) = 1, lambda(4) = 2$
     - $lambda(2^e) = 2^(e-2)$ (对于 $e >= 3$)
     - $lambda(p^e) = phi(p^e) = p^(e-1)(p-1)$ (对于奇素数 $p$)
]

#note(title: "推论")[
  模 $m$ 的原根存在 $<==> lambda(m) = phi(m)$。
]

==== Carmichael 数

#note[
  若合数 $n$ 满足：对于所有 $a perp n$ 都有 $a^(n-1) equiv 1 pmod(n)$，则称 $n$ 为 Carmichael 数。
]

#note(title: "Korselt 判别法")[
  合数 $n$ 是 Carmichael 数 $<==> n$ 无平方因子，且对于 $n$ 的任意质因子 $p$，均有 $(p-1) divides (n-1)$。
]

#note(title: "性质")[
  1. Carmichael 数必为奇数。
  2. 至少有 3 个不同的素因子。
  3. 分布极其稀疏，但有无穷多个。
]

// 离散对数章节

=== 离散对数 (Discrete Logarithm)

#note[
  处理幂次方程 $a^x equiv b pmod(m)$ 的核心工具
  
  *前置知识*：阶与原根。
  离散对数的定义方式与对数类似。取有原根的正整数模数 $m$，设其一个原根为 $g$。对满足 $(a, m) = 1$ 的整数 $a$，必存在唯一的整数 $0 <= k < phi(m)$ 使得：
  $ g^k equiv a pmod(m) $
  称此 $k$ 为以 $g$ 为底，模 $m$ 的离散对数，记作 $k = "ind"_g a$。

  PS:没学
]

==== 性质

#note[
  设 $g$ 是模 $m$ 的原根，$(a, m) = (b, m) = 1$：
  1. $"ind"_g (a b) equiv "ind"_g a + "ind"_g b pmod(phi(m))$
  2. $forall n in NN, "ind"_g a^n equiv n "ind"_g a pmod(phi(m))$
  3. 若 $g_1$ 亦为模 $m$ 原根，则 $"ind"_g a equiv "ind"_(g_1) a dot "ind"_g g_1 pmod(phi(m))$
  4. $a equiv b pmod(m) <==> "ind"_g a = "ind"_g b$
]

==== 大步小步算法 (BSGS)

#note[
  用于在 $O(sqrt(m))$ 时间内求解 $a^x equiv b pmod(m)$，其中需满足 $a perp m$。
]

===== 算法描述
#note(color: luma(240))[
  令 $x = A ceil(sqrt(m)) - B$，其中 $0 <= A, B <= ceil(sqrt(m))$。
  原方程化为：$a^(A ceil(sqrt(m)) - B) equiv b pmod(m)$。
  移项得：$a^(A ceil(sqrt(m))) equiv b a^B pmod(m)$。
]

1. *Baby-steps*：枚举 $B$，计算 $b a^B pmod(m)$ 并存入 Hash Table。
2. *Giant-steps*：枚举 $A$，计算 $a^(A ceil(sqrt(m))) pmod(m)$，在表中查找是否存在匹配。
3. *注意*：必须满足 $a perp m$ 才能通过除以 $a^B$ 推回原方程。

==== 扩展 BSGS 算法

#note[
  求解 $a^x equiv b pmod(m)$，其中 $a, m$ 不一定互质。
]

===== 算法流程
#note(title: "消因子法")[
  1. 设 $d_1 = gcd(a, m)$。若 $d_1 divides.not b$ 且 $b != 1$，则无解。
  2. 否则方程两边除以 $d_1$：
     $ frac(a, d_1) dot a^(x-1) equiv frac(b, d_1) pmod(frac(m, d_1)) $
  3. 重复此过程 $k$ 次，直到 $a perp frac(m, d_1 d_2 dots d_k)$。
  4. 最终方程形如：
     $ frac(a^k, D) dot a^(x-k) equiv frac(b, D) pmod(frac(m, D)) $
     其中 $D = product d_i$。此时 $frac(a^k, D)$ 存在逆元，转化为标准 BSGS 求解 $x-k$。
]

#note(title: "特判小解")[
  不排除解 $x <= k$ 的情况。在消因子之前，需先 $Theta(k)$ 枚举验证 $a^i equiv b pmod(m)$。
]

==== 代码模板 (exBSGS)

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;
LL ksm(LL a,LL b,LL m){
    LL res=1;
    for(;b;b>>=1,a=a*a%m)if(b&1)res=res*a%m;
    return res;
}
LL exbsgs(LL a, LL b, LL m) {
    a %= m; b %= m;
    if (b == 1 || m == 1) return 0;
    LL g, k = 0, na = 1;
    while ((g = __gcd(a, m)) > 1) {
        if (b % g) return -1;
        k++; b /= g; m /= g;
        na = (LL)((__int128)na * (a / g) % m);
        if (na == b) return k;
    }
    unordered_map<LL, LL> mp;
    LL B = ceil(sqrt(m)), cur = b;
    for (int j = 0; j < B; ++j) {
        mp[cur] = j;
        cur = (LL)((__int128)cur * a % m);
    }
    LL step = ksm(a, B, m);
    cur = na;
    for (int i = 1; i <= B; ++i) {
        cur = (LL)((__int128)cur * step % m);
        if (mp.count(cur)) return i * B - mp[cur] + k;
    }
    return -1;
}
int main(){
     cin.tie(0)->sync_with_stdio(0);
    LL a,b,m;
    while(cin>>a>>m>>b,a||b||m){
        LL res=exbsgs(a,b,m);
        if(res==-1)cout<<"No Solution\n";
        else cout<<res<<"\n";
    }
}
```

=== 高次剩余 & 单位根

#note[
  *前置知识*：离散对数。
  本文讨论 $x^k equiv a pmod(m)$ 的可行性（高次剩余）与单位根，并介绍求方根的算法。
  
  PS:没学
]

==== 高次剩余

#note[
  *定义*：令整数 $k >= 2$，$a perp m$。若存在 $x$ 使得 $x^k equiv a pmod(m)$，称 $a$ 为模 $m$ 的 *$k$ 次剩余*（$k$-th residue），$x$ 为 $a$ 的 *$k$ 次方根*。
]

===== 性质：原根存在的情形

#note(title: "判定与根的个数")[
  设 $m$ 存在原根，$g$ 是模 $m$ 的一个原根。记 $d = gcd(k, phi(m))$ 且 $d' = phi(m)/d$。
  1. *判定*：$a$ 为模 $m$ 的 $k$ 次剩余 $<==> a^(d') equiv 1 pmod(m)$。
  2. *根的个数*：若 $a$ 为 $k$ 次剩余，则同余意义下恰有 $d$ 个互不相同的 $k$ 次方根。
  3. *根的结构*：形式为 $x equiv g^(y_0 + i d') pmod(m)$，其中 $0 <= y_0 < d'$，$i = 0, 1, dots, d-1$。
]

===== 性质：模 $2^e$ 的情形 ($e >= 2$)
#note[
  借助奇数 $a$ 的分解形式 $a equiv (-1)^s 5^r pmod(2^e)$：
  1. *若 $k$ 是奇数*：$a$ 恒为 $k$ 次剩余，且方根唯一。
  2. *若 $k$ 是偶数*：记 $d = gcd(k, 2^(e-2))$，$d' = 2^(e-2)/d$。
     - $a$ 是 $k$ 次剩余 $<==> a equiv 1 pmod(4)$ 且 $a^(d') equiv 1 pmod(2^e)$。
     - 若有解，恰有 $2d$ 个互不相同的方根，形式为 $x equiv plus.minus 5^(y_0 + i d') pmod(2^(e-1))$。
]

==== 单位根

#note[
  *定义*：$1$ 的 $k$ 次方根称为模 $m$ 的 *$k$ 次单位根*。若 $x$ 是 $k$ 次单位根且不是任何更小的 $k' < k$ 次单位根，则称其为 *$k$ 次本原单位根*。
  *注*：原根 $g$ 就是模 $m$ 的 $phi(m)$ 次本原单位根。
]

===== 性质

#note[
  1. 元素 $a$ 是 $k$ 次本原单位根 $<==> a^k equiv 1 pmod(m)$ 且对任意素因子 $p divides k$ 都有 $a^(k/p) equiv.not 1 pmod(m)$。
  2. *存在性*：模 $m$ 的 $k$ 次本原单位根存在 $<==> k divides lambda(m)$。其中 $lambda(m)$ 为 Carmichael 函数。
  3. *方根生成*：若 $x$ 是 $a$ 的一个 $k$ 次方根，$r$ 遍历模 $m$ 的全体 $k$ 次单位根，则 $x r$ 遍历 $a$ 的全部 $k$ 次方根。
]

==== 模意义下开方算法

===== 1. 朴素算法

#note(title: "基于离散对数的求解流程")[
  1. *奇素数幂 $m = p^e$*：设原根为 $g$，方程转化为线性同余方程：
     $ k y equiv "ind"_g a pmod(phi(m)) $
     利用 BSGS 求出 $"ind"_g a$，再解线性同余方程得 $y$，最后 $x equiv g^y pmod(m)$。
  2. *模 $2^e$*：求解线性同余方程组：
     $ cases(k z equiv s pmod(2), k y equiv r pmod(2^(e-2))) $
     其中 $a equiv (-1)^s 5^r pmod(2^e)$。解出 $(z, y)$ 后 $x = (-1)^z 5^y$。
  3. 复杂度：取决于 BSGS，通常为 $O(sqrt(m))$。
]

===== 2. 改良 Tonelli-Shanks 算法

#note(title: "核心思想")[
  通过降低离散对数所在的群阶来优化复杂度。
  1. 转化：利用 $d = gcd(k, phi(m))$，将方程转化为 $x^d equiv b pmod(m)$。
  2. 分解：对 $d = product p_i^(e_i)$ 依次求 $p_i^(e_i)$ 次方根。
  3. 迭代：通过随机找到 $p$ 次非剩余构造本原单位根，逐位确定 $p$ 进制下的指数 $h$。
  4. 复杂度：$O(m^(1/4+epsilon))$。
]

==== 一般情形的处理 (非互素 $gcd(a, m) > 1$)

#note[
  设 $m = p^e$，$a = p^s a'$ ($p perp a'$)：
  1. 若 $a equiv 0 pmod(m)$，解为 $x equiv p^(ceil(e/k)) l pmod(p^e)$。
  2. 若 $a != 0$：设 $x = p^z x'$ ($p perp x'$)，成立条件：
     - $k z = s$（即 $k divides s$）。
     - $(x')^k equiv a' pmod(p^(e-s))$。
  3. 回代：第二个方程的解 $x'$ 对应原方程的解：
     $ x equiv p^(s/k)(x' + l p^(e-s)) pmod(p^e), quad l = 0, 1, dots, p^(s-s/k)-1 $
]

求解任一模数下全体 $k$ 次方根的参考实现如下：

```cpp
#include<bits/stdc++.h>

std::mt19937 rng(std::random_device{}());

struct PrimePower {
  int p, e, pe;

  PrimePower(int p, int e, int pe) : p(p), e(e), pe(pe) {}
};

// Factorization.
auto factorize(int n) {
  std::vector<PrimePower> ans;
  for (int x = 2; x * x <= n; ++x) {
    int e = 0, pe = 1;
    for (; n % x == 0; n /= x, ++e, pe *= x);
    if (e) ans.emplace_back(x, e, pe);
  }
  if (n > 1) ans.emplace_back(n, 1, n);
  return ans;
}

// Binary exponentiation.
int pow(int a, int b, int m = 0) {
  int res = 1;
  for (; b; b >>= 1) {
    if (b & 1) res = m ? (long long)res * a % m : res * a;
    a = m ? (long long)a * a % m : a * a;
  }
  return res;
}

// Find a primitive root modulo odd prime power.
int primitive_root(PrimePower pp) {
  std::vector<int> exp;
  int phi = pp.pe / pp.p * (pp.p - 1);
  for (auto factor : factorize(pp.p - 1)) {
    exp.push_back(phi / factor.p);
  }
  if (pp.e != 1) exp.push_back(phi / pp.p);
  int ans = 0;
  bool succ = false;
  while (!succ) {
    ++ans;
    succ = true;
    for (int b : exp) {
      if (pow(ans, b, pp.pe) == 1) {
        succ = false;
        break;
      }
    }
  }
  return ans;
}

// Euclidean Algorithm.
int gcd(int a, int b) { return b ? gcd(b, a % b) : a; }

// Extended Euclidean Algorithm.
int ex_gcd(int a, int b, int& x, int& y) {
  if (!b) {
    x = 1;
    y = 0;
    return a;
  } else {
    int d = ex_gcd(b, a % b, y, x);
    y -= a / b * x;
    return d;
  }
}

// Returns the modular inverse of A modulo M.
// Assumes that gcd(A, M) = 1, so the inverse exists.
int inv(int a, int m) {
  int x, y;
  ex_gcd(a, m, x, y);
  return (x % m + m) % m;
}

// Find a P-th non-residue mod M.
int non_residue(int p, int m, int phi) {
  std::uniform_int_distribution<int> dis(1, m - 1);
  while (true) {
    int c = dis(rng);
    if (gcd(c, m) == 1 && pow(c, phi / p, m) != 1) return c;
  }
  return -1;
}

// Subroutine: Find a P^E-th root of A mod M.
int peth_root_mod_m(int p, int e, int a, int m, int phi) {
  if (m == 2) return 1;
  int s = 0, r = phi, pe = pow(p, e);
  for (; r % p == 0; r /= p, ++s);
  int q = pe - inv(r, pe);
  int ans = pow(a, ((long long)q * r + 1) / pe % phi, m);
  int eta = non_residue(p, m, phi);
  std::unordered_map<int, int> mp;
  int zeta = pow(eta, r, m);
  int xi = pow(eta, phi / p, m);
  // Precompute powers for BSGS.
  int B = std::sqrt((s - e) * p + 0.25l) + 1;
  int pB = pe / B + 1;
  int po0 = pow(xi, pB, m);
  for (int j = 1, po1 = 1; j <= B; ++j) {
    po1 = (long long)po1 * po0 % m;
    mp[po1] = j;
  }
  // Compute p-adic digits of h.
  for (int j = 0; j < s - e; ++j) {
    int err = (long long)pow(ans, pe, m) * inv(a, m) % m;
    int xi_hj = pow(err, pow(p, s - e - j - 1), m);
    long long hj = 0;
    // BSGS query.
    for (int i = 1; i <= pB; ++i) {
      xi_hj = (long long)xi_hj * xi % m;
      if (mp.count(xi_hj)) {
        hj = mp[xi_hj] * pB - i;
        break;
      }
    }
    ans = (long long)ans * pow(zeta, phi - hj * pow(p, j) % phi, m) % m;
  }
  return ans;
}

// Find a K-th root of A modulo prime P^E.
int kth_root_mod_pe(int k, int a, int pe, int phi) {
  a %= pe;
  if (k == 0) return a == 1 ? 0 : -1;
  if (a == 0) return 0;
  int d = gcd(k, phi);
  if (pow(a, phi / d, pe) != 1) return -1;
  a = pow(a, inv(k / d, phi / d), pe);
  for (int dp = 2; dp * dp <= d && dp * dp * dp * dp < pe; ++dp) {
    if (d % dp == 0) {
      int de = 0;
      for (; d % dp == 0; d /= dp, ++de);
      a = peth_root_mod_m(dp, de, a, pe, phi);
    }
  }
  if (d != 1) {
    int dp = gcd(d, phi / d), de = 0;
    if (dp != 1) {
      for (; d % dp == 0; d /= dp, ++de);
      a = peth_root_mod_m(dp, de, a, pe, phi);
    }
    if (d != 1) a = peth_root_mod_m(d, 1, a, pe, phi);
  }
  return a;
}

// Subroutine: Find all the K-th roots with a primitive root G known.
std::vector<int> calc(int g, int k, int a, int p, int pe) {
  int mm = p == 2 ? pe / 4 : pe / p * (p - 1);
  int ans = kth_root_mod_pe(k, a, pe, mm);
  if (ans == -1) return {};
  int d = mm / gcd(k, mm);
  int po = pow(g, d, pe);
  std::vector<int> res(mm / d);
  for (auto& x : res) {
    x = ans;
    ans = (long long)ans * po % pe;
  }
  return res;
}

// Find all the K-th roots of A modulo prime power P^E.
std::vector<int> kth_roots_mod_pe(int k, int a, PrimePower pp) {
  int p = pp.p, e = pp.e, pe = pp.pe;
  a %= pe;
  if (a == 0) {
    int d = pow(p, (e - 1) / k + 1);
    std::vector<int> res(pe / d);
    for (int i = 0; i < pe / d; ++i) {
      res[i] = i * d;
    }
    return res;
  }
  int s = 0;
  for (; a % p == 0; a /= p, ++s);
  if (s % k) return {};
  int psk = pow(p, s / k), pss = pow(p, s - s / k), pes = pow(p, e - s);
  std::vector<int> res;
  if (p != 2) {
    int g = primitive_root(PrimePower(p, e - s, pes));
    res = calc(g, k, a, p, pes);
  } else if (pes == 2) {
    res.push_back(a);
  } else if (k & 1) {
    int z = a % 4 == 3;
    a = z ? pes - a : a;
    res = calc(5, k, a, p, pes);
    if (z) {
      for (auto& x : res) x = pes - x;
    }
  } else {
    if (a % 4 == 3) return {};
    res = calc(5, k, a, p, pes);
    int m = res.size();
    res.reserve(m * 2);
    for (int i = 0; i < m; ++i) {
      res.push_back(pes - res[i]);
    }
  }
  int m = res.size();
  res.reserve(m * pss);
  for (int j = 1; j < pss; ++j) {
    for (int i = 0; i < m; ++i) {
      res.push_back(res.end()[-m] + pes);
    }
  }
  for (auto& x : res) x *= psk;
  return res;
}

// Find all the K-th roots of A modulo positive integer M.
std::vector<int> kth_roots_mod_m(int k, int a, int m) {
  auto factors = factorize(m);
  int m0 = 0;
  std::vector<std::vector<int>> sols;
  for (const auto& pp : factors) {
    sols.push_back(kth_roots_mod_pe(k, a, pp));
    if (sols.back().empty()) return {};
  }
  std::vector<int> ans;
  for (int i = 0; i < (int)factors.size(); ++i) {
    auto pp = factors[i];
    if (!i) {
      m0 = pp.pe;
      ans = sols[i];
    } else {
      long long m1 = pp.pe * inv(pp.pe, m0);
      long long m2 = m0 * inv(m0, pp.pe);
      m0 *= pp.pe;
      std::vector<int> _ans;
      _ans.reserve(ans.size() * sols[i].size());
      for (auto x : ans) {
        for (auto y : sols[i]) {
          _ans.push_back((m1 * x + m2 * y) % m0);
        }
      }
      ans.swap(_ans);
    }
  }
  return ans;
}

void solve() {
  int n, m, k;
  std::cin >> n >> m >> k;
  auto ans = kth_roots_mod_m(n, k, m);
  if (ans.empty()) {
    std::cout << 0 << '\n';
    return;
  }
  std::cout << ans.size() << '\n';
  std::sort(ans.begin(), ans.end());
  for (auto x : ans) std::cout << x << ' ';
  std::cout << '\n';
}

int main() {
  int t;
  std::cin >> t;
  for (; t; --t) {
    solve();
  }
}
```

=== 数论分块

==== 定义

$ sum_(i=1)^n f(i) g(floor(n/i)) $

如果 可以 $O(1)$ 的时间计算 $sum_(i=l)^r f(i)$ 数论分块可以在 $O(sqrt(n))$ 的时间内计算出值

#note[PS：数论分块常与 *莫比乌斯反演* 等技巧结合时使用]

==== 思路

$ |D_n| = { floor(n/i) : 1 <= i <= n, i in NN_+ } $

===== 性质

1. $|D_n| <= 2 sqrt(n)$
2. 所有满足 $floor(n/i) = d$ 的整数 $i$ 的取值范围为：
   $ floor(n / (d+1)) + 1 <= i <= floor(n/d) $
3. 对于 $m in D_n$ 有 $D_m subset.eq D_n$
4. $D_n$ 中既是每块的取值集合，又是右端点的集合

===== 过程

$ "原式" = (sum_(i=l)^r f(i)) times g(floor(n/l)) $

```cpp
LL cal(LL n){
	LL res=0;
    for(LL l=1,r;l<=n;l=r+1){
        r=n/(n/l);
        res+=(pre[r]-pre[l-1])*g[n/l];
    }
    return res;
}
```

==== 扩展

===== 向上取整的数论分块

$ sum_(i=1)^n f(i) g(ceil(n/i)) = f(n) g(1) + sum_(i=1)^(n-1) f(i) g(floor((n-1)/i) + 1) $

#note[CF1058div2G1:记住了， 对于向上取整的除法，使得 `d = a/b` 取得 下一个较小值的 `b` 为 `a/(d-1)`]

===== 多维数论分块

$ sum_(i=1)^n f(i) g(floor(n_1/i), floor(n_2/i), dots, floor(n_m/i)) $

也就是说在计算右端点时：
$ r = min(floor(n_1/l), floor(n_2/l), dots, floor(n_m/l)) $

===== 任意指数数论分块

$ sum_(i=1)^(floor(alpha/beta)) f(i) g(floor(n^alpha / i^beta)) $

1. $|D_(n, alpha, beta)| <= 2 n^(alpha / beta)$
2. 使得 $floor(n^alpha / i^beta) = d$ 成立的 $i$ 的取值范围为：
   $ floor( n^(alpha/beta) / (d+1)^(1/beta) ) + 1 <= i <= floor( n^(alpha/beta) / d^(1/beta) ) arrow.r.double.long floor( n^alpha / (d+1) ) <= (i-1)^beta "且" i^beta <= floor( n^alpha / d ) $

可以在 $O(n^(alpha / (1+beta)))$ 的复杂度完成任意指数的数论分块


=== 狄利克雷卷积 (Dirichlet Convolution)

#note[
  *定义*：数论函数 $f(n)$ 和 $g(n)$ 的 Dirichlet 卷积记作 $f * g$，其定义为：
  $ (f * g)(n) = sum_(k divides n) f(k) g(n/k) = sum_(k l = n) f(k) g(l) $
]

==== 常见例子  
#note[
  1. *单位函数(莫比乌斯反演)*：$epsilon = mu * 1 <==> epsilon(n) = sum_(d divides n) mu(d)$
  2. *除数个数函数*：$tau = 1 * 1 <==> tau(n) = sum_(d divides n) 1$
  3. *除数和函数*：$sigma = id * 1 <==> sigma(n) = sum_(d divides n) d$
  4. *欧拉函数*：$phi = id * mu <==> phi(n) = sum_(d divides n) d dot mu(n/d)$
]

==== 代数性质
#note(title: "基本运算律")[
  - *交换律*：$f * g = g * f$
  - *结合律*：$(f * g) * h = f * (g * h)$
  - *分配律*：$(f + g) * h = f * h + g * h$
  - *单位元*：$f * epsilon = f$，其中 $epsilon(n) = [n=1]$。
  - *逆元*：当 $f(1) != 0$ 时，存在 $g$ 使得 $f * g = epsilon$。
    递推式：$g(n) = frac(epsilon(n) - sum_(k l = n, k != 1) f(k) g(l), f(1))$
]

#note(title: "积性函数的封闭性")[
  + 若 $f, g$ 为积性函数，$f * g$ 也是积性函数。
  + 若 $f$ 为积性函数，其逆元一定存在， $f^(-1)$ 也是积性函数。
]

#note(title:text("完全积性函数的情况"))[
  设 $alpha$ 是完全积性函数, $f,g$ 是数论函数. 
  + 分配律: $(alpha f)*(alpha g) = alpha dot (f * g)$.
  + 逆元: $(alpha f)^(-1) = alpha f^(-1)$ 只要 $f^(-1)$ 存在.
  + 积性函数 $f$ 是完全积性函数, 当且仅当 $f^(-1) = mu f$, 其中, $mu$ 是莫比乌斯函数. 
]

==== Dirichlet 生成函数 (DGF)

#note(title:text("定义"))[
  数论函数 $f(n)$ 对应的 Dirichlet 生成函数定义为形式级数：
  $ F(s) = sum_(n=1)^oo frac(f(n), n^s) $
]

#note(title:text("核心定理"))[
  $f * g$ 的生成函数等于 $F(s) dot G(s)$。
]

===== Euler 乘积 (Euler Product)
#note[
  对于积性函数 $f$，其生成函数可写为素数幂处的乘积：
  $ F(s) 
    & = sum_(n=1)^infinity (f(n))/n^s \
    & = sum_(n=1)^infinity product_(p in bold(P)) (f(p^e))/p^(e s) \
   & = product_(p in bold(P)) (1 + frac(f(p), p^s) + frac(f(p^2), p^(2s)) + dots) $
  *完全积性函数*简化为：$F(s) = product_(p in bold(P)) (1 - frac(f(p), p^s))^(-1)$。
]

===== 常用 DGF 对应关系
#note[
  1. *单位函数 $epsilon(n)$* 是完全积性函数, 它的 Dirichlet 生成函数是关于不定元 $s$ 的常值函数: 
  $ 
    E(s)=sum_(n=1)^infinity (epsilon(n)/n^s) = 1. 
  $  
  2. *常数函数 $I(n)$* 是完全积性函数, 它的 Dirichlet 生成函数是 Riemann 函数
  $ 
    I(s) 
    &= sum_(n=1)^infinity 1/n^s \
    &= product_(p in bold(P)) 1/(1 - p^(-s))\ 
    &= zeta(s) 
  $ 
  3. *莫比乌斯函数 $mu(n)$* 它的 Dirichlet 生成函数是 $zeta(s)$ 的倒数
  $ 
    Mu(s) 
    &= sum_(n=1)^infinity mu(n)/n^s \ 
    &= product_(p in bold(P))(1-p^(-s))\ 
    &= 1/zeta(s) 
  $
  4. *幂函数 $id_k(n) = n^k$* 是完全积性函数 特别地,当 $k=0$ 时是常数函数, $k=1$ 时是恒等函数 
  $ 
    I_k(s) 
    &= sum_(n=1)^infinity n^k/n^s \ 
    &= product_(p in bold(P)) 1/(1-p^(-(s-k))) \ 
    &= zeta(s-k) 
  $
  5. *欧拉函数 $phi$* 是积性函数. (结合幂函数的 Dirichlet 函数表达式，就得到 $id = phi * 1$)
  $ 
    Phi(s) 
    &= product_(p in bold(P)) (1+ (p-1)/p^s + (p(p-1))/p^(2s) + (p^2(p-1))/p^(3s) + dots.c ) \
    &= product_(p in bold(P)) (1-p^(-s))/(1-p^(-(s-1))) \
    &= frac(zeta(s-1), zeta(s)) 
  $
  6. *约数函数 $sigma_k(n) = sum_(d divides n) d^k$* 是积性函数. (结合幂函数的 Dirichlet 表达式，就得到 $sigma_k = id_k * 1$, 这是 $sigma_k$ 的定义式)
  $ 
    Sigma_k (s)
    &= product_(p in bold(P)) (1+ (1+p^k)/p^s + (1+p^k+p^(2k))/p^(2s) + (1+p^k+p^(2k)+p^(3k))/p^(3s) + dots.c ) \  
    &= product_(p in bold(P)) 1/((1-p^(-s))(1-p(-(s-k))))  \
    &= zeta(s-k) zeta(s) 
  $
  + *无平方因子指示函数 $u(n) = |mu(n)|$* 是积性函数.
  $
    U(s)
    &= product_(p in bold(P)) (1+p^(-s)) \
    &= product_(p in bold(P)) (1-p^(-2s))/(1-p^(-s))\  
    &= frac(zeta(s), zeta(2s))
  $
]


==== 应用：杜教筛构造
#note[
  杜教筛需要找 $g$ 使得 $f * g$ 和 $g$ 易求前缀和。
  *例*：$f(n) = n^2 phi(n)$。
  其 DGF 为 $F(s) = frac(zeta(s-3), zeta(s-2))$。
  取 $g = id_2$，则其 DGF 为 $G(s) = zeta(s-2)$。
  则 $f * g$ 对应的 DGF 为 $F(s)G(s) = zeta(s-3)$，即 $f * g = id_3$。
]

#note(title:text("使用方式"))[
  观察要求的前缀和是否是积性函数 求它的生成函数 观察它的右侧的形式 对应乘以一个积性函数 得到一个简单的积性函数 
  #image("/assets/05_狄利克雷卷积_狄利克雷卷积切入点.png")
]

==== Dirichlet 卷积的计算

#note[
  本节讨论 Dirichlet 卷积的计算问题，即给定序列 $f(k)_(k=1)^n$ 和 $g(k)_(k=1)^n$，求解 Dirichlet 卷积 $h=f ast g$ 的前若干项 $h(k)_(k=1)^n$ 的问题
]

===== 一般情形

#note[

  如果 $f,g,h$ 都没有特殊性质 那么 Dirichlet 卷积的计算只能利用其定义：

  $ 
    h(n) = sum_(k l = n) f(k)g(l) 
  $

  直接枚举倍数累加贡献。

  复杂度为 $O(sum_(k=1)^n n/k ) = O(n log n)$
]

```cpp
for (int k = 1; k <= n; ++k)
    for (int d = 1; k * d <= n; ++d)
        h[k * d] += f[k] * g[d];
```

===== 与积性函数卷积的情形

#note[
  若 $g$ 是积性函数，利用 Euler 乘积逐个素数更新。类似埃氏筛或 FWT。

  $ 
    H(s) = F(s)G(s) = F(s)product_(p in bold(P)) G_p (s)
  $

  其中 
  $
    G_p(s) = sum_(p^k <= n) (f(p^k))/p^(k s) = 1 + (f(p))/p^s + (f(p^2))/ p^(2s) + dots.c
  $

  本算法的时间复杂度为 $O(n log log n)$
]

```cpp
// Compute the Dirichlet convolution h = f * g.
// Assume that g is multiplicative.
auto dirichlet_convolute(const std::vector<int>& f, const std::vector<int>& g) {
  int n = f.size() - 1;
  std::vector<int> h(f);
  std::vector<bool> vis(n + 1);
  for (int i = 2; i <= n; ++i) {
    if (vis[i]) continue;
    // Reverse the order for in-place computation.
    for (int k = n / i * i; k; k -= i) {
      vis[k] = true;
      int d = k;
      while (true) {
        d /= i;
        h[k] += h[d] * g[k / d];
        if (d % i) break;
      }
    }
  }
  return h;
}
// or
for (int p : primes)
    for (int k = n / p; k >= 1; --k)
        for (int cur = p, pe = 1; k * cur <= n; cur *= p)
            h[k * cur] += h[k] * g[cur];
```

#note(title:text("进一步常数优化"))[
  当积性函数 $g$ 是 完全积性函数 或 其Dirichilet逆 时, 例如当 $g=1$ 或 $g = mu$ 时, 算法可以进一步简化, 此时 Dirichilet卷积 $h=f ast g$ 的计算可以使用*常数更小*的 *Dirichilet 前缀和/差分* 算法.
]

===== 结果为积性函数的情形

#note[
  若 $f, g$ 均为积性函数，则 $h = f * g$ 为积性函数。只需计算素数幂处的取值.\
  可以通过 *线性筛* 在 $O(n)$ 时间内计算. 而对于素数 $p^e$ 处的取值 $h(p^e)$ 直接暴力计算即可. 依然  $O(n)$ 
  $
   h(p^e) = sum_(i=0)^e f(p^i) g(p^(e-i))
  $
]

```cpp
// Compute the Dirichlet convolution h = f * g.
// Assume that h is multiplicative.
auto dirichlet_convolute(const std::vector<int>& f, const std::vector<int>& g) {
  int n = f.size() - 1;
  std::vector<int> h(n + 1), primes, rem(n + 1), lpf(n + 1);
  std::vector<bool> vis(n + 1);
  h[1] = 1;
  for (int x = 2; x <= n; ++x) {
    if (!vis[x]) {
      primes.push_back(x);
      rem[x] = 1;
      lpf[x] = x;
    }
    for (int p : primes) {
      if (x * p > n) break;
      vis[x * p] = true;
      rem[x * p] = x % p ? x : rem[x];
      lpf[x * p] = p;
      if (x % p == 0) break;
    }
    if (rem[x] == 1) {  // prime powers.
      for (int k = x; k; k /= lpf[x]) {
        h[x] += f[k] * g[x / k];
      }
    } else {  // other cases.
      h[x] = h[rem[x]] * h[x / rem[x]];
    }
  }
  return h;
}
```
=== 莫比乌斯反演

$f(n)$ 如果很难直接求出它的值，而容易求出其倍数和或约数和 $g(n)$ ，那么可以通过莫比乌斯反演简化运算。

==== 定义

$ mu(n) = cases(
  1\, &n=1,
  0\, &n "含有平方因子",
  (-1)^k\, space &n "是" k "个不同质数的乘积"
) $

==== 性质

莫比乌斯函数是 *积性函数* ，但 *不是* *完全积性函数* ，最重要的是以下恒等式：

$ sum_(d | n) mu(d) = [n=1] $

#note[
  利用 Dirichlet 卷积，该表达式可以写作 $epsilon = 1 * mu$ ．也就是说，莫比乌斯函数是常值函数 $1$ 的 Dirichlet 逆．
]

一个很常见的应用：

$ [i perp j] = [gcd(i, j) = 1] = sum_(d | gcd(i, j)) mu(d) = sum_d [d | i][d | j] mu(d) $

将互素的条件转化为莫比乌斯函数的求和公式。

==== 求法

1. 直接模拟求解 $O(sqrt(n))$

```cpp
int mu(int n) {
  int res = 1;
  for (int i = 2; i * i <= n; ++i) {
    if (n % i == 0) {
      n /= i;
      if (n % i == 0) return 0;
      res = -res;
    }
  }
  if (n > 1) res = -res;
  return res;
}
```

2. 线性筛法 $O(n)$
  
```cpp
std::vector<int> get_mu(int n) {
  std::vector<int> mu(n + 1), primes;
  std::vector<bool> not_prime(n + 1);
  primes.reserve(n);
  mu[1] = 1;
  for (int x = 2; x <= n; ++x) {
    if (!not_prime[x]) {
      primes.push_back(x);
      mu[x] = -1;
    }
    for (int p : primes) {
      if (x * p > n) break;
      not_prime[x * p] = true;
      if (x % p == 0) {
        mu[x * p] = 0;
        break;
      } else {
        mu[x * p] = -mu[x];
      }
    }
  }
  return mu;
}
```

==== 莫比乌斯反演

设 $f(n), g(n)$ 是两个数论函数，则有：

$ f(n) = sum_(d | n) g(d) <==> g(n) = sum_(d | n) mu(n/d) f(d) $

===== 常见例子

- *欧拉函数*：因 $n = sum_(d | n) phi(d)$，反演得 
  $
    phi(n) = sum_(d|n) d mu(n/d)
  $
  即 $phi = mu * "id"$．
- *除数函数*：因 $sigma_k(n) = sum_(d | n) d^k$，反演得 
  $
    n^k = sum_(d | n) mu(n/d) sigma_k(d)
  $
- *互异素因子个数*：设 $omega(n) = sum_(d | n) [d in bold(P)]$，反演得 
  $
    [n in bold(P)] = sum_(d | n) mu(n/d) omega(d)
  $
- *von Mangoldt 函数*：
  $ Lambda(n) = sum_(d | n) mu(n/d) log d = cases(
    log p\, space &n = p^e,
    0\, &"otherwise"
  ) $

===== 拓展形式

1. *倍数和形式*

$ 
  f(n) = sum_(n | d) g(d) <==> g(n) = sum_(n | d) mu(d/n) f(d) 
$

2. *乘法形式（Abel 群）*

$ 
  f(n) = product_(d | n) g(d) <==> g(n) = product_(d | n) f(d)^(mu(n/d)) 
$

3. *一般 Dirichlet 逆形式*

设 $alpha^(-1)$ 是 $alpha$ 的 Dirichlet 逆，即

$
  [n=1] = sum_(d divides n) alpha(n/d)alpha^(-1)(d)
$

则：
$ 
  f(n) = sum_(d | n) alpha(n/d) g(d) <==> g(n) = sum_(d | n) alpha^(-1)(n/d) f(d) 
$

#note(title: "推论")[
  若 $t(n)$ 是完全积性函数，其 Dirichlet 逆为 $mu(n)t(n)$，则：
  
  $ 
    f(n) = sum_(d|n) t(n/d) g(d) <==> g(n) = sum_(d|n) mu(n/d) t(n/d) f(d) 
  $
]

4. *复值函数连续形式*

设 $F(x), G(x)$ 是 $[1, +oo)$ 上的复值函数：
$ 
  F(x) = sum_(n=1)^floor(x) G(x/n) <==> G(x) = sum_(n=1)^floor(x) mu(n) F(x/n) 
$

==== Dirichlet 前缀和/差分

对于 $f(n) = sum_(d | n) g(d)$，由 $g$ 求 $f$ 的过程称为 *Dirichlet 前缀和*，反之称为 *Dirichlet 差分*．

利用高维前缀和的思想，将每个质数视为一个维度，可以在 $O(n log log n)$ 时间内完成计算．

#note(title:text("我的两种理解方式"))[
  + 类似拓扑 从小到大一个数 n 由 质数 p 与 np 建立连边传送贡献, 这里的贡献时机非常精妙.
  + 唉 只能抽象理解 p 维度了 好难想
]
```cpp
// Dirichlet 前缀和
std::vector<int> dirichlet_presum(const std::vector<int>& g) {
  int n = g.size() - 1;
  std::vector<int> f(g);
  std::vector<bool> vis(n + 1);
  for (int x = 2; x <= n; ++x) {
    if (vis[x]) continue;
    for (int y = 1, xy = x; xy <= n; ++y, xy += x) {
      vis[xy] = true;
      f[xy] += f[y];
    }
  }
  return f;
}

// Dirichlet 差分
std::vector<int> dirichlet_diff(const std::vector<int>& f) {
  int n = f.size() - 1;
  std::vector<int> g(f);
  std::vector<int> vis(n + 1);
  for (int x = 2; x <= n; ++x) {
    if (vis[x]) continue;
    for (int y = n / x, xy = x * y; y; --y, xy -= x) {
      vis[xy] = true;
      g[xy] -= g[y];
    }
  }
  return g;
}
```

=== 杜教筛

杜教筛用于在低于线性时间复杂度下计算数论函数 $f$ 的前缀和 $S(n) = sum_(i=1)^n f(i)$．

==== 核心原理

构造一个辅助函数 $g$ ，根据 Dirichlet 卷积的性质：
$ sum_(i=1)^n (f * g)(i) = sum_(i=1)^n sum_(d|i) g(d) f(i/d) = sum_(i=1)^n g(i) S(floor(n/i)) $

由此可以导出杜教筛的 *核心递推式*：

$ g(1)S(n) = sum_(i=1)^n (f * g)(i) - sum_(i=2)^n g(i) S(floor(n/i)) $

#note(title: "构造条件")[
  为了使上式能够快速求解，构造的 $g$ 必须满足：
  1. $f * g$ 的前缀和容易计算；
  2. $g$ 本身的前缀和容易计算（用于对第二项进行数论分块）．
]

==== 算法实现

1. *预处理*：利用线性筛预处理出 $f$ 的前 $m$ 项前缀和（通常取 $m = n^(2/3)$）．
2. *记忆化*：由于 $floor(n/i)$ 的取值只有 $O(sqrt(n))$ 种，使用 `std::map` 或哈希表存储已计算过的 $S(x)$ 值．
3. *复杂度*：在预处理前 $n^(2/3)$ 项的情况下，计算 $S(n)$ 的时间复杂度为 $O(n^(2/3))$．
+ *(WC) 我一直没有弄懂的怎么实现 $O(n^(2/3))$*: 原来是 使用分治思想使用*线性筛*处理前 $n^(2/3)$ 项 
  后面的 $n$ 递归搜索时 的复杂度就平衡了 

==== 常用构造方案

===== 1. 莫比乌斯函数 $mu$ 的前缀和
取 $g = 1$，则 $f * g = mu * 1 = epsilon$．
$ S(n) = 1 - sum_(i=2)^n S(floor(n/i)) $

===== 2. 欧拉函数 $phi$ 的前缀和
取 $g = 1$，则 $f * g = phi * 1 = "id"$．
$ S(n) = (n(n+1))/2 - sum_(i=2)^n S(floor(n/i)) $

===== 3. 复合函数 $f(n) = n^2 phi(n)$ 
为了消去 $n^2$，取 $g = "id"^2$（即 $g(n) = n^2$），则：
$ (f * g)(i) = sum_(d|i) (d^2 phi(d)) dot (i/d)^2 = sum_(d|i) i^2 phi(d) = i^2 sum_(d|i) phi(d) = i^3 $

故 $(f * g)$ 的前缀和为 $sum i^3 = (frac(1, 2) n(n+1))^2$，递推式为：
$ S(n) = (frac(1, 2) n(n+1))^2 - sum_(i=2)^n i^2 S(floor(n/i)) $

#note[
  *技巧总结*：
  - 如果 $f = h phi$，通常取 $g = h$ 使得 $f * g = h dot "id"$．
  - 如果 $f = h mu$，通常取 $g = h$ 使得 $f * g = h dot epsilon$．
  其中 $h$ 往往是完全积性函数（如 $n^k$）．
]

#note(title: "为什么可以取 g = h ?")[
  若 $h$ 是 *完全积性函数*（如 $n^k$），对于任意数论函数 $A, B$ 满足：
  $ (h dot A) * (h dot B) = h dot (A * B) $
  
  在杜教筛中，我们利用该性质“提取”公因子 $h$：
  - 若 $f = h phi$，取 $g = h$，则 $f * g = h dot (phi * 1) = h dot "id"$．
  - 若 $f = h mu$，取 $g = h$，则 $f * g = h dot (mu * 1) = h dot epsilon = epsilon$．
  
  这种构造方式使得原本复杂的卷积简化为基础的 $phi * 1$ 或 $mu * 1$ 的形式．
]

==== 模板示例
```cpp
// P4213【模板】杜教筛（Sum）
#include <cstring>
#include <iostream>
#include <map>
using namespace std;
constexpr int MAXN = 2000010;
long long T, n, pri[MAXN], cur, mu[MAXN], sum_mu[MAXN];
bool vis[MAXN];
map<long long, long long> mp_mu;

long long S_mu(long long x) {  // 求mu的前缀和
  if (x < MAXN) return sum_mu[x];
  if (mp_mu[x]) return mp_mu[x];  // 如果map中已有该大小的mu值，则可直接返回
  long long ret = (long long)1;
  for (long long i = 2, j; i <= x; i = j + 1) {
    j = x / (x / i);
    ret -= S_mu(x / i) * (j - i + 1);
  }
  return mp_mu[x] = ret;  // 路径压缩，方便下次计算
}

long long S_phi(long long x) {  // 求phi的前缀和
  long long ret = (long long)0;
  long long j;
  for (long long i = 1; i <= x; i = j + 1) {
    j = x / (x / i);
    ret += (S_mu(j) - S_mu(i - 1)) * (x / i) * (x / i);
  }
  return (ret - 1) / 2 + 1;
}

int main() {
  cin.tie(nullptr)->sync_with_stdio(false);
  cin >> T;
  mu[1] = 1;
  for (int i = 2; i < MAXN; i++) {  // 线性筛预处理mu数组
    if (!vis[i]) {
      pri[++cur] = i;
      mu[i] = -1;
    }
    for (int j = 1; j <= cur && i * pri[j] < MAXN; j++) {
      vis[i * pri[j]] = true;
      if (i % pri[j])
        mu[i * pri[j]] = -mu[i];
      else {
        mu[i * pri[j]] = 0;
        break;
      }
    }
  }
  for (int i = 1; i < MAXN; i++)
    sum_mu[i] = sum_mu[i - 1] + mu[i];  // 求mu数组前缀和
  while (T--) {
    cin >> n;
    cout << S_phi(n) << ' ' << S_mu(n) << '\n';
  }
  return 0;
}
```


=== Powerful Number 筛

#note[
  发明 PN 筛的人真是个天才

  它 把 一个前缀和 求成了另一个前缀和 而另一个前缀和 还有可能依然不能求 还需要一个筛

  记 $F(n) = sum_(i=1)^n f(i)$

  使用的前提只有   

  + $f$ 是积性函数

  而构造函数 $g$ 的要求是 

  + $g$ 是积性函数 
  + $g(p)=f(p)$
  + $g$ 容易求前缀和 (可能还需要一个筛...)
]

==== 一些定义和性质

+ *Powerful Number(PN)* 是指所有质因子的次数 $>= 2$ 的数
+ *PN* 可以表示为 $a^2b^3$ 的形式
+ $n$ 以内的 *PN* 有 $O(sqrt(n))$ 个

==== 构造过程

+ *首先构造一个 $g$*

  + $g$ 是积性函数 
  + $g(p)=f(p)$
  + $g$ 容易求前缀和 (可能还需要一个筛...)

  记 $G(n) = sum_(i=1)^n g(i)$

  + 请求解 $G(n)$... 

+ *然后构造一个 $h$*

  + 满足 $h=f\/g$ 即 $f=h ast g$, 这里 $ast$ 代表狄利克雷卷积
  + 显然 $h$ 是积性函数 $h(1)=1$
  + 故 
    $
      f(p) = g(p)h(1) + g(1)h(p) = g(p) + h(p) ==> h(p)=0
    $
  + 故 只要某个数字 $n$ 出现单个因子 $p$ 则 $h(p)=0$, 即 $h$ 只在 *PN* 处取值

+ *核心公式*

  $
    F(n)&= sum_(i=1)^n f(i) \
        &= sum_(i=1)^n sum_(d divides i)h(d)g(i/d)\
        &= sum_(d=1)^n sum_(i=1)^(floor.l n/d floor.r) h(d)g(i)\
        &= sum_(d=1)^n h(d) sum_(i=1)^(floor.l n/d floor.r) g(i)\
        &= sum_(d=1)^n h(d) G(floor.l n/d floor.r)\
        &= sum_(d=1 \ d "is PN")^n h(d) G(floor.l n/d floor.r)
  $

  + $O(sqrt(n))$ 找 PN
  + 计算 $h(p^c)$ 在这之后 即可求出任意 $h("PN")$

    计算方法有 2 种

    + 直接求得 $h(p^c)$ 的表达式了 直接算
    + 根据卷积公式 $f=g*h$ 递推计算, 即
      $
        h(p^c) = f(p^c) - sum_(i=1)^(c) g(p^(i))h(p^(c-i)) 
      $
      只需要 *先枚举素数 $p$ 再枚举指数 $c$* 即可求解所有 $h(p^c)$.

+ *复杂度相关*

  + 第一部分 计算 $h(p^c)$

    巧妙的地方: 由于 *PN* 自带平方因子 所以 $"涉及到的质数" <= sqrt(n)$ 

    + 素数个数 $O(P) = O(sqrt(n)/(log n))$
    + 质数 $O(C) = O(log n)$ 

    *第一部分 复杂度* $O(P C^2) = O(sqrt(n) log n)$

  + 第二部分 搜索 PN

    + PN 最多搜索 $O(sqrt(n))$ 次 
    + $G(n)$ 的计算复杂度未知
  
  + 总体复杂度

    + 如果 $G(n)$ 是用 $O(1)$ 计算 那么总复杂度瓶颈是 $O(sqrt(n) log n)$
    + 如果 $G(n)$ 用 *杜教筛* 计算 那么总复杂度瓶颈是 $O(n^(2/3))$

    #note(title: [深度理解：为什么配合杜教筛不是 $O(n^(1/2) dot n^(2/3))$ ？])[
      + *值域贴合性* 
        杜教筛在计算 $G(n)$ 时，为了填满递归树，会强制计算并*记忆化*所有 $G(floor(n/k))$ 的值。
      
      + *生产者-消费者模型*
        - 杜教筛是 *生产者*：运行一次耗时 $O(n^(2/3))$，预热了所有可能的 $floor(n/d)$ 处的 $G$ 值。
        - PN 筛是 *消费者*：在 DFS 中将 $G$ 视为一个 *O(1) 接口* 直接从缓存拿数据。
      
      + *结论*：总复杂度 = $O(n^(2/3)) + O(sqrt(n) times 1) = O(n^(2/3))$。
    ]

==== 模板示例

```cpp
// Luogu P5325【模板】Min_25 筛
#include <iostream>
#include <map>
using namespace std;

constexpr int MOD = 1e9 + 7;

template <typename T>
int mint(T x) {
  x %= MOD;
  if (x < 0) x += MOD;
  return x;
}

int add(int x, int y) { return x + y >= MOD ? x + y - MOD : x + y; }

int mul(int x, int y) { return (long long)1 * x * y % MOD; }

int sub(int x, int y) {
  return x < y ? x - y + MOD : x - y;  // 防止负数
}

int qp(int x, int y) {
  int r = 1;
  for (; y; y >>= 1) {
    if (y & 1) r = mul(r, x);
    x = mul(x, x);
  }
  return r;
}

int inv(int x) { return qp(x, MOD - 2); }

namespace PNS {
constexpr int N = 2e6 + 5;
constexpr int M = 35;

long long global_n;

int g[N], sg[N];

int h[N][M];
bool vis_h[N][M];

int ans;

int pcnt, prime[N], phi[N];
bool isp[N];

void sieve(int n) {
  pcnt = 0;
  for (int i = 2; i <= n; ++i) isp[i] = true;  // 判断质数数组
  phi[1] = 1;
  for (int i = 2; i <= n; ++i) {
    if (isp[i]) {
      ++pcnt;
      prime[pcnt] = i;
      phi[i] = i - 1;
    }
    for (int j = 1; j <= pcnt; ++j) {  // 筛去非质数
      long long nxt = (long long)1 * i * prime[j];
      if (nxt > n) break;
      isp[nxt] = false;
      if (i % prime[j] == 0) {  // i是非质数的情况
        phi[nxt] = phi[i] * prime[j];
        break;
      }
      phi[nxt] = phi[i] * phi[prime[j]];
    }
  }

  for (int i = 1; i <= n; ++i) g[i] = mul(i, phi[i]);

  sg[0] = 0;
  for (int i = 1; i <= n; ++i) sg[i] = add(sg[i - 1], g[i]);  // g函数的前缀和
}

int inv2, inv6;

void init() {
  sieve(N - 1);
  for (int i = 1; i <= pcnt; ++i) h[i][0] = 1, h[i][1] = 0;
  for (int i = 1; i <= pcnt; ++i) vis_h[i][0] = vis_h[i][1] = true;
  inv2 = inv(2);
  inv6 = inv(6);
}

int S1(long long n) { return mul(mul(mint(n), mint(n + 1)), inv2); }

int S2(long long n) {
  return mul(mul(mint(n), mul(mint(n + 1), mint(n * 2 + 1))), inv6);
}

map<long long, int> mp_g;

int G(long long n) {
  if (n < N) return sg[n];
  if (mp_g.count(n)) return mp_g[n];

  int ret = S2(n);
  for (long long i = 2, j; i <= n; i = j + 1) {
    j = n / (n / i);
    ret = sub(ret, mul(sub(S1(j), S1(i - 1)), G(n / i)));
  }
  mp_g[n] = ret;
  return ret;
}

void dfs(long long d, int hd, int pid) {
  ans = add(ans, mul(hd, G(global_n / d)));

  for (int i = pid; i <= pcnt; ++i) {
    if (i > 1 && d > global_n / prime[i] / prime[i]) break;  // 剪枝

    int c = 2;
    for (long long x = d * prime[i] * prime[i]; x <= global_n;
         x *= prime[i], ++c) {  // 计算f.g函数
      if (!vis_h[i][c]) {
        int f = qp(prime[i], c);
        f = mul(f, sub(f, 1));
        int g = mul(prime[i], prime[i] - 1);
        int t = mul(prime[i], prime[i]);

        for (int j = 1; j <= c; ++j) {
          f = sub(f, mul(g, h[i][c - j]));
          g = mul(g, t);
        }
        h[i][c] = f;
        vis_h[i][c] = true;
      }

      if (h[i][c]) dfs(x, mul(hd, h[i][c]), i + 1);
    }
  }
}

int solve(long long n) {
  global_n = n;
  ans = 0;
  dfs(1, 1, 1);
  return ans;
}
}  // namespace PNS

int main() {
  PNS::init();
  long long n;
  cin >> n;
  cout << PNS::solve(n) << '\n';
  return 0;
}
```


=== Min-25 筛 (Extended Eratosthenes Sieve)

#note[
  从此种筛法的思想方法来说，其又被称为「Extended Eratosthenes Sieve」．
  由于其由 Min_25 发明并最早开始使用，故称「Min_25 筛」．

  *性质*：其可以在 $O(n^(3/4) / log n)$ 或 $Theta(n^(1-epsilon))$ 的时间复杂度下解决一类积性函数的前缀和问题．

  *要求*：$f(p)$ 是一个关于 $p$ 可以快速求值的完全积性函数之和；$f(p^c)$ 可以快速求值．
]

==== 记号

- $x/y := floor.l x/y floor.r$
- $op("isprime")(n) := [ |{d : d divides n}| = 2 ]$，即 $n$ 为质数时其值为 1，否则为 0．
- $p_k$：全体质数中第 $k$ 小的质数．特别地，令 $p_0 = 1$．
- $op("lpf")(n) := [1 < n] min {p : p divides n} + [1 = n]$，即 $n$ 的最小质因数．
- $F_op("prime")(n) := sum_(2 <= p <= n) f(p)$
- $F_k (n) := sum_(i = 2)^n [p_k <= op("lpf")(i)] f(i)$

==== 解释

答案即为 $F_1(n) + f(1) = F_1(n) + 1$．
通过枚举每个 $i$ 的最小质因子及其次数可以得到递推式：

$
F_k (n) &= sum_(i = 2)^n [p_k <= op("lpf")(i)] f(i) \
&= sum_(k <= i \ p_i^2 <= n) sum_(c >= 1 \ p_i^c <= n) f(p_i^c) ([c > 1] + F_(i+1)(n/p_i^c)) + sum_(k <= i \ p_i <= n) f(p_i) \
&= sum_(k <= i \ p_i^2 <= n) sum_(c >= 1 \ p_i^c <= n) f(p_i^c) ([c > 1] + F_(i+1)(n/p_i^c)) + F_op("prime")(n) - F_op("prime")(p_(k-1)) \
&= sum_(k <= i \ p_i^2 <= n) sum_(c >= 1 \ p_i^(c+1) <= n) (f(p_i^c) F_(i+1)(n/p_i^c) + f(p_i^(c+1))) + F_op("prime")(n) - F_op("prime")(p_(k-1))
$

最后一步基于：对于 $p_i^c <= n < p_i^(c+1)$，有 $n/p_i^c < p_i < p_(i+1)$，故 $F_(i+1)(n/p_i^c) = 0$．

==== 计算质数贡献 ($G$ 函数)

若 $f(p) = sum a_i p^(c_i)$，对每个项 $g(p) = p^s$，设 $G_k(n)$ 为埃筛第 $k$ 轮筛完后剩下的数的 $g$ 值之和：
$ G_k(n) = G_(k-1)(n) - [p_k^2 <= n] g(p_k) (G_(k-1)(n/p_k) - G_(k-1)(p_(k-1))) $

==== 示例代码 (LOJ 6053 简单的函数)

```cpp
#include <cmath>
#include <iostream>
#include <algorithm>

using std::cin;
using std::cout;

const int MAXS = 200005;
const int mod = 1000000007;

inline void inc(int &x, int y) {x += y;if (mod <= x) x -= mod;}

inline void dec(int &x, int y) {x -= y;if (x < 0) x += mod;}

inline int sum(int x, int y) {return x + y < mod ? x + y : (x + y - mod);}

inline int sub(int x, int y) {return x < y ? x - y + mod : (x - y);}

inline int div2(long long x) {return ((x & 1) ? x + (long long)mod : x) >> 1;}

inline long long sqrll(long long x) {return x * x;}

int pri[MAXS], lpf[MAXS], spri[MAXS], pcnt;

void sieve(int n) {
    for (int i = 2; i <= n; ++i) {
        if (lpf[i] == 0) {
            lpf[i] = ++pcnt;
            pri[lpf[i]] = i;
            spri[pcnt] = sum(spri[pcnt - 1], i);
        }
        for (int j = 1, v; j <= lpf[i] && (long long)i * pri[j] <= n; ++j) {
            v = i * pri[j];
            lpf[v] = j;
        }
    }
}

long long global_n;
int lim;
int le[MAXS], ge[MAXS];
int G[MAXS][2], Fprime[MAXS];
long long lis[MAXS];
int cnt;

#define idx(v) (v <= lim ? le[v] : ge[global_n / v])

void init(long long n) {
    cnt = 0;
    for (long long i = 1, j; i <= n; i = n / j + 1) {
        j = n / i;
        long long v = j % mod;
        lis[++cnt] = j;
        if (j <= lim) le[j] = cnt;
        else ge[global_n / j] = cnt;
        G[cnt][0] = sub((int)v, 1);
        G[cnt][1] = div2((v + 2) * (v - 1) % mod);
    }
}

void calcFprime() {
    for (int k = 1; k <= pcnt; ++k) {
        int p = pri[k];
        long long sqrp = sqrll(p);
        for (int i = 1; lis[i] >= sqrp; ++i) {
            long long v = lis[i] / p;
            int id = idx(v);
            dec(G[i][0], sub(G[id][0], k - 1));
            dec(G[i][1], (long long)p * sub(G[id][1], spri[k - 1]) % mod);
        }
    }
    for (int i = 1; i <= cnt; ++i) {
        Fprime[i] = sub(G[i][1], G[i][0]);
    }
}

inline int f_p(int p, int c) {
    return p ^ c;
}

int F(int k, long long n) {
    if (n < pri[k] || n <= 1) return 0;
    int id = idx(n);
    long long ans = sub(Fprime[id], sub(spri[k - 1], k - 1));
    if (k == 1) ans = sum((int)ans, 2);
    for (int i = k; i <= pcnt && sqrll(pri[i]) <= n; ++i) {
        long long pw = pri[i], pw2 = sqrll(pw);
        for (int c = 1; pw2 <= n; ++c, pw = pw2, pw2 *= pri[i]) {
            ans = (ans + (long long)f_p(pri[i], c) * F(i + 1, n / pw) + f_p(pri[i], c + 1)) % mod;
        }
    }
    return (int)(ans % mod);
}

int main() {
    cin.tie(nullptr)->sync_with_stdio(false);
    cin >> global_n;
    if (global_n == 1) {
        cout << 1 << "\n";
        return 0;
    }
    lim = (int)sqrt(global_n);
    sieve(lim + 1000);
    init(global_n);
    calcFprime();
    cout << sum(F(1, global_n), 1) << "\n";
    return 0;
}
```

=== 洲阁筛

#note[
  略 一个代码例题都没有
]


=== 类欧几里得算法 (Euclidean-like Algorithm)

#note[
  好难懂 处理直线下整点计数及其加权和相关问题的强力工具 
  
  类欧几里得算法主要用于解决形如 $f(a,b,c,n) = sum_(i=0)^n floor.l frac(a i + b, c) floor.r$ 的求和问题。其核心思想是利用分数的递归结构，将问题转化为更小规模的子问题，复杂度与欧几里得算法一致，为 $O(log min(a, c))$。
]

==== 普通类欧几里得算法

我们需要计算：
$ 
  f(a, b, c, n) = sum_(i=0)^n floor.l frac(a i + b, c) floor.r \
  g(a, b, c, n) = sum_(i=0)^n i floor.l frac(a i + b, c) floor.r \
  h(a, b, c, n) = sum_(i=0)^n floor.l frac(a i + b, c) floor.r^2 \
$

其中 $a, b, c, n$ 均为正整数。

===== 代数推导

1. *修正参数范围*：
   若 $a >= c$ 或 $b >= c$，利用 $floor.l x + k floor.r = floor.l x floor.r + k$：
   $
     f(a, b, c, n) &= sum_(i=0)^n floor.l frac((floor.l a/c floor.r c + a mod c) i + (floor.l b/c floor.r c + b mod c), c) floor.r \
     &= frac(n(n+1), 2) floor.l a/c floor.r + (n+1) floor.l b/c floor.r + f(a mod c, b mod c, c, n)\

     g(a,b,c,n) & = g(a',b',c,n) + (n(n+1)(2n+1))/6 floor.l a/c floor.r + (n(n+1))/2 floor.l b/c floor.r\ 

     h(a,b,c,n) & = 2 floor.l b/c floor.r f(a',b',c,n)  + 2 floor.l a/c floor.r g(a',b',c,n) + h(a',b',c,n) \ 
     
     & + (n(n+1)(2n+1))/6 floor.l a/c floor.r^2  + (n+1) floor.l b/c floor.r^2 + n(n+1)floor.l a/c floor.r floor.l b/c floor.r
   $

2. *递归转化*：
   当 $0 <= a < c, 0 <= b < c$ 时，令 $m = floor.l (a n + b) / c floor.r$。利用 "指示函数" 交换求和次序：
   $
     f(a, b, c, n) &= sum_(i=0)^n sum_(j=0)^(m-1) [j < floor.l frac(a i + b, c) floor.r] 
     = sum_(j=0)^(m-1) sum_(i=0)^n [i > floor.l frac(c j + c - b - 1, a) floor.r] \
     &= sum_(j=0)^(m-1) (n - floor.l frac(c j + c - b - 1, a) floor.r) 
     = n m - f(c, c - b - 1, a, m - 1)\
   
     g(a,b,c,n) &= (m n(n+1) - f(c,c-b-1,a,m-1) - h(c,c-b-1,a,m-1))/2\

     h(a,b,c,n) &= n m^2 - f(c,c-b-1,a,m-1) - 2g(c,c-b-1,a,m-1)\
   $

===== 代码模板 (Standard)

```cpp
/*
 * @brief 基础类欧几里得算法
 * @return sum_{i=0}^n floor((ai+b)/c)
 */
int floor_sum(int a, int b, int c, int n){
	int res = 0;
	if(a >= c){
		res += n * (n + 1) * (a / c) / 2;
		a %= c;
	}
	if(b >= c){
		res += (n + 1) * (b / c);
		b %= c;
	}
	int m = (a * n + b) / c;
	if(m == 0) return res;
	res += n * m - floor_sum(c, c - b - 1, a, m - 1);
	return res;
}

// 用法示例:
// 计算 sum_{i=0}^2 floor((3i+2)/4)
// res = floor(2/4) + floor(5/4) + floor(8/4) = 0 + 1 + 2 = 3
int res = floor_sum(3, 2, 4, 2);
```

==== 万能欧几里得算法 (Universal Euclidean Algorithm)

#note[
  万能欧几里得算法是对上述过程的进一步抽象。它将直线 $y = frac(a x + b, c)$ 穿过网格线的几何路径看作由 $U$ (向上) 和 $R$ (向右) 构成的 "操作序列"。通过维护一个支持结合律的 "幺半群" (Monoid) 乘法，可以一并解决平方和、加权和等复杂问题。
]

===== 算法原理

- *序列构造*：对于 $x in (0, n]$，每当直线横跨 $x=i$ 时执行 $R$，横跨 $y=j$ 时执行 $U$。
- *递归逻辑*：
  1. $b >= c$：起始先执行 $floor.l b/c floor.r$ 次 $U$。
  2. $a >= c$：每一个 $R$ 变为执行 $U^(floor.l a/c floor.r) R$。
  3. $a < c$：翻转坐标轴，将 $U$ 视为 $R$，将 $R$ 视为 $U$，进入递归。

===== 代码模板 (Universal)

```cpp
#include <array>
#include <iostream>

// Switch between matrix and info merging approaches.
#define MATRIX 1

// Class T implements the monoid.
// Assume that it provides a multiplication operator
//     and a default constructor returning the unity in the monoid.

// Binary exponentiation.
template <typename T>
T pow(T a, int b) {
  T res;
  for (; b; b >>= 1) {
    if (b & 1) res = res * a;
    a = a * a;
  }
  return res;
}

// Universal Euclidean algorithm.
template <typename T>
T euclid(int a, int b, int c, int n, T U, T R) {
  if (b >= c) return pow(U, b / c) * euclid(a, b % c, c, n, U, R);
  if (a >= c) return euclid(a % c, b, c, n, U, pow(U, a / c) * R);
  auto m = ((long long)a * n + b) / c;
  if (!m) return pow(R, n);
  return pow(R, (c - b - 1) / a) * U *
         euclid(c, (c - b - 1) % a, a, m - 1, R, U) *
         pow(R, n - (c * m - b - 1) / a);
}

// 上方是 模板外壳
// 下方有 矩阵 / 贡献结构体 两种实现方式(需自定义) 
#if MATRIX

template <size_t N>
struct Matrix {
  std::array<long long, N * N> mat;

  auto loc(size_t i, size_t j) const { return mat[i * N + j]; }

  auto& loc(size_t i, size_t j) { return mat[i * N + j]; }

  Matrix() : mat{} {
    for (size_t i = 0; i != N; ++i) {
      loc(i, i) = 1;
    }
  }

  Matrix operator*(const Matrix& rhs) const {
    Matrix res;
    res.mat.fill(0);
    for (size_t i = 0; i != N; ++i) {
      for (size_t k = 0; k != N; ++k) {
        for (size_t j = 0; j != N; ++j) {
          res.loc(i, j) += loc(i, k) * rhs.loc(k, j);
        }
      }
    }
    return res;
  }
};

long long solve(int a, int b, int c, int n) {
  if (!n) return 0;
  Matrix<3> U, R;
  U.loc(0, 1) = R.loc(1, 2) = 1;
  auto res = euclid(a, b, c, n, U, R);
  return res.loc(0, 2);
}

#else

struct Info {
  long long x, y, s;

  Info() : x(0), y(0), s(0) {}

  Info operator*(const Info& rhs) const {
    Info res;
    res.x = x + rhs.x;
    res.y = y + rhs.y;
    res.s = s + rhs.s + rhs.x * y;
    return res;
  }
};

long long solve(int a, int b, int c, int n) {
  if (!n) return 0;
  Info U, R;
  U.y = 1;
  R.x = 1;
  auto res = euclid(a, b, c, n, U, R);
  return res.s;
}

#endif

int main() {
  int t;
  std::cin >> t;
  for (; t; --t) {
    int a, b, c, n;
    std::cin >> n >> c >> a >> b;
    std::cout << solve(a, b, c, n - 1) << '\n';
  }
  return 0;
}
```

=== Meissel–Lehmer 算法

#note[略]

=== 连分数

#note[略]

=== Stern–Brocot 树与 Farey 序列

#note[略]

=== 二次域（抽象代数）

#note[略]

=== Pell方程

#note[略]

== 多项式与生成函数

=== 代数基本定理

#note[略 没什么好看的 还没什么用]

=== 快速傅里叶变换 (FFT)

==== 算法思考

#note(title: "核心直觉：坐标系大搬家")[
  - *系数表示法* ${a_0, a_1, dots, a_(n-1)}$ 是多项式的 *DNA*（内部构造）。
  - *点值表示法* ${y_0, y_1, dots, y_(n-1)}$ 是多项式的 *全身照*（外部表现）。
  
  多项式乘法在系数表示法下需要 $O(n^2)$ 的分配律运算；但在点值表示法下，只需 $O(n)$ 的点对点乘法。FFT 的本质是利用 *单位复根* $omega$ 的对称性，在 $O(n log n)$ 时间内完成 DNA 与照片的相互转换。
]

#note(title: [关于 $n$ 的迷思：为什么是 $n$ 个点？])[
  1. *阶与点的关系*：数学上 $n-1$ 阶多项式（最高次项 $x^(n-1)$）由 $n$ 个点唯一确定。在代码实现中，我们习惯处理长度为 $n$（2 的幂）的数组，它对应 $n-1$ 阶方程，因此用 $n$ 个点恰好平衡。
  2. *为什么非要用单位根 $omega$？*：
    - *折半性*：$(omega_n^k)^2 = (omega_n^(k+n/2))^2 = omega_(n/2)^k$。这使得递归进下一层时，子问题的规模（点数）直接减半。
    - *对称性*：$omega_n^(k+n/2) = -omega_n^k$。计算出前一半结果，后一半可以 "买一送一"（蝴蝶操作）。
]

#note(title:"复杂度分析")[
  如果直接暴力计算的话 一共有 n 个点, n 个系数。 复杂度是 $O(n^2)$ 

  FFT 采用分治策略：$A(x) = A_"even"(x^2) + x dot A_"odd"(x^2)$ 对于每一个点 只需计算 这一个短式子即可

  - *层数*：每次对半拆分，直到 $n=1$，共有 $log n$ 层。
  - *每层工作量*：在合并时，需要对 $n$ 个点进行蝴蝶操作，工作量为 $n$。
  - *总复杂度*：$n times log n = O(n log n)$。
]

==== 模板

===== 普通多项式乘法 (FFT)(普通版)

```cpp
// P3803 【模板】多项式乘法 (FFT) 
// 迭代版
#include <bits/stdc++.h>
using namespace std;
using CP=complex<double>;
const int N=4e6+5;
const double PI=acos(-1);

CP A[N],B[N];

int R[N]; // 位逆序置换数组，用于将递归的底层顺序提前排列好

void FFT(CP A[], int n, int type) {
    // 1. 根据位逆序置换进行重排 (Bit-reversal Permutation)
    for(int i=0; i<n; ++i)
        R[i] = (R[i>>1]>>1) | ((i&1) ? n/2 : 0);
    for(int i=0; i<n; ++i)
        if(i < R[i]) swap(A[i], A[R[i]]);  

    // 2. 迭代合并：从底层 2 个点开始，向上合并到 n 个点
    for(int i=1; i<n; i<<=1) { // i 为当前合并半块的长度 
        // 为什么现在没 2 了? 因为现在的 i 指的是半长 恢复到原来要乘以2约掉了
        CP w1({cos(PI/i), sin(PI/i)*type}); // 单位根步长
        for(int j=0; j<n; j+=i<<1) { // j 为块的起始位置
            CP wk({1, 0});// 单位 
            for(int k=j; k<j+i; ++k) { // 蝴蝶操作：利用对称性白嫖计算结果
                CP x = A[k], y = A[k+i] * wk;
                A[k] = x + y;            // A(w^k) = A_e + w*A_o
                A[k+i] = x - y;        // A(w^{k+n/2}) = A_e - w*A_o
                wk = wk * w1;
            }
        }
    }
}

int main() {
    int n, m;  
    double v;
    scanf("%d%d", &n, &m); // 输入两个多项式的次数
    for(int i=0; i<=n; i++) cin>>v,A[i].real(v);
    for(int i=0; i<=m; i++) cin>>v,B[i].real(v);
    
    // n 阶 + m 阶 = n+m 阶，需要准备 n+m+1 个点
    int total_len = n + m; 
    for(n=1; n <= total_len; n <<= 1); // 凑齐 2 的幂次长度

    FFT(A, n, 1); FFT(B, n, 1); // 系数 -> 点值
    for(int i=0; i<n; ++i) A[i] = A[i] * B[i]; // 点值直接相乘 O(n)
    FFT(A, n, -1); // 点值 -> 系数 (逆变换)

    for(int i=0; i<=total_len; ++i) 
        printf("%d ", (int)(A[i].real() / n + 0.5)); // 别忘了最后除以 n 并四舍五入
}
```

===== 普通多项式乘法 (FFT)(DIF-DIT版)

```cpp
// P3803 【模板】多项式乘法 (FFT) 
#include <bits/stdc++.h>
using namespace std;
using CP = complex<double>;

const int N = 1 << 21;
const double PI = acos(-1.0);

CP w[N],inv_w[N], A[N], B[N];

// 预计算单位根，减少循环内的 sin/cos 调用
void precompute(int n) {
    for (int i = 1; i < n; i <<= 1) {
        for (int j = 0; j < i; j++) {
            w[i + j] = {cos(PI * j / i), sin(PI * j / i)};
            // inv_w[i + j] = {cos(PI * j / i), -sin(PI * j / i)};
            inv_w[i+j]=conj(w[i+j]);// 哦 
            // inv_w[i+j] = w[i+j];
            // inv_w[i+j].imag(-inv_w[i+j].imag());// 说实话有点烦
        }
    }
}

// DIF - 频率抽取 DFT (正常入，位逆序出)
// 枚举顺序: 大小块 块编号 块乘积
// 乘积计算: w[l+k] 位于 A_1 (下边)
void DIF(CP *a, int n) {
    for (int l = n >> 1; l >= 1; l >>= 1) {
        for (int j = 0; j < n; j += (l << 1)) {
            for (int k = 0; k < l; k++) {
                CP x = a[j + k], y = a[j + k + l];
                a[j + k] = x + y;
                a[j + k + l] = (x - y) * w[l + k];
            }
        }
    }
}

// DIT - 时间抽取 IDFT (位逆序入，正常出)
// 枚举顺序: 小大块 块编号 块乘积
// 乘积计算: inv_w[l+k] 位于 y (上边)
void DIT(CP *a, int n) {
    for (int l = 1; l < n; l <<= 1) {
        for (int j = 0; j < n; j += (l << 1)) {
            for (int k = 0; k < l; k++) {
                CP x = a[j + k], y = a[j + k + l] * inv_w[l + k];
                a[j + k] = x + y;
                a[j + k + l] = x - y;
            }
        }
    }
}

int main() {
    int n, m;
    double v;
    cin>>n>>m;
    for (int i = 0; i <= n; i++) cin>>v,A[i].real(v);
    for (int i = 0; i <= m; i++) cin>>v,B[i].real(v);

    int tot = n + m, len = 1;
    while (len <= tot) len <<= 1;
    
    precompute(len);
    DIF(A, len); DIF(B, len);
    for (int i = 0; i < len; i++) A[i] *= B[i];
    
    // IDFT 需要共轭单位根
    DIT(A, len);

    for (int i = 0; i <= tot; i++) 
        cout<<(int)(A[i].real() / len + 0.5)<<" ";
    return 0;
}
```

===== 任意模数大全(乘法/逆元/阶乘) (MTT:FFT)(DIF-DIT版) 

```cpp
// FFT_ez.cpp
#include <bits/stdc++.h>
using namespace std;
using LL = long long;
using DB = double;

namespace FFT {
    struct CP {
        DB x, y;
        CP(DB X = 0, DB Y = 0) : x(X), y(Y) {}
        CP operator + (const CP &a) const { return {x + a.x, y + a.y}; }
        CP operator - (const CP &a) const { return {x - a.x, y - a.y}; }
        CP operator * (const CP &a) const { return {x * a.x - y * a.y, x * a.y + y * a.x}; }
        CP conj() const { return {x, -y}; }
    };
    using Poly = vector<LL>;
    const DB PI = acos(-1.0);
    const int LEN = 19; 
    const int N = 1 << LEN; 
    vector<CP> w[LEN], iw[LEN];
    vector<int> rev[LEN];
    LL fac[N], ifac[N], inv[N];
    LL mod;

    LL ksm(LL a, LL b) {
        LL res = 1;
        for (; b; b >>= 1, a = a * a % mod) if (b & 1) res = res * a % mod;
        return res;
    }

    LL add(LL a, LL b){
        return (a + b) % mod;
    }
    
    LL sub(LL a, LL b){
        return (a - b + mod) % mod;
    }

    LL mul(LL a, LL b){
        return a * b % mod;
    }

    void init(LL mo) {
        mod=mo;
        inv[0] = inv[1] = ifac[0] = ifac[1] = 1;
        for(int i = 2; i < N; i++){
            inv[i] = mul(mod - mod / i, inv[mod % i]);
            ifac[i] = mul(ifac[i-1], inv[i]);
        }        
        for(int len = 0; len < LEN; len++){
            int n = 1 << len;
            w[len].resize(n);
            iw[len].resize(n);
            rev[len].resize(n);
            for (int i = 0; i < n; i++)
                rev[len][i] = (rev[len][i >> 1] >> 1) | ((i & 1) ? (n >> 1) : 0);
            for (int i = 1; i < n; i <<= 1)
                for (int j = 0; j < i; j++){
                    w[len][i + j] = CP(cos(PI * j / i), sin(PI * j / i));
                    iw[len][i + j] = w[len][i + j].conj();
                }
        }
    }

    void DIF(vector<CP>& a, int n) {
        for (int l = n >> 1; l >= 1; l >>= 1) {
            int len = __lg(l) + 1;
            for (int j = 0; j < n; j += (l << 1)) {
                for (int k = 0; k < l; k++) {
                    CP x = a[j + k], y = a[j + k + l];
                    a[j + k] = x + y;
                    a[j + k + l] = (x - y) * w[len][l + k];
                }
            }
        }
    }

    void DIT(vector<CP>& a, int n) {
        for (int l = 1; l < n; l <<= 1) {
            int len = __lg(l) + 1;
            for (int j = 0; j < n; j += (l << 1)) {
                for (int k = 0; k < l; k++) {
                    CP x = a[j + k], y = a[j + k + l] * iw[len][l + k];
                    a[j + k] = x + y;
                    a[j + k + l] = x - y;
                }
            }
        }
    }
    
    Poly norm_mul(Poly A, Poly B, int lim){
        int n = A.size(), m = B.size(), L = 1;
        while (L < n + m - 1) L <<= 1;
        static vector<CP> F(N), G(N), H1(N), H2(N);
        fill(F.begin(), F.begin() + L, CP{0, 0});
        fill(G.begin(), G.begin() + L, CP{0, 0});
        // 使用拆分技巧处理大数
        for (int i = 0; i < n; i++) {
            LL val = (A[i] % mod + mod) % mod;
            F[i] = CP{(DB)(val & 32767), (DB)(val >> 15)};
        }
        for (int i = 0; i < m; i++) {
            LL val = (B[i] % mod + mod) % mod;
            G[i] = CP{(DB)(val & 32767), (DB)(val >> 15)};
        }
        DIF(F, L); 
        DIF(G, L);
        int len = __lg(L);
        for (int i = 0; i < L; i++) {
            int j = rev[len][(L - rev[len][i]) & (L - 1)]; 
            CP a = (F[i] + F[j].conj()) * CP{0.5, 0};
            CP b = (F[i] - F[j].conj()) * CP{0, -0.5};
            H1[i] = a * G[i]; 
            H2[i] = b * G[i]; 
        }
        DIT(H1, L); 
        DIT(H2, L);
        A.resize(lim);
        int len_C = min(lim, n + m - 1);
        for (int i = 0; i < len_C; i++) {
            LL ll = (LL)(H1[i].x / L + 0.5) % mod;
            LL lh = (LL)(H1[i].y / L + 0.5) % mod;
            LL hl = (LL)(H2[i].x / L + 0.5) % mod;
            LL hh = (LL)(H2[i].y / L + 0.5) % mod;
            LL ans = (hh << 30) % mod;
            ans = (ans + ((lh + hl) << 15)) % mod;
            ans = (ans + ll) % mod;
            A[i] = ans;
        }
        for (int i = len_C; i < lim; ++i) A[i] = 0; 
        return A;
    }

    inline Poly norm_inv(Poly F,int n){
        if (n == 0) return {};
        // 1. 计算大于等于 n 的最小 2 的幂次 len
        int len = 1;
        while(len < n) len <<= 1;
        // 2. 将 F 扩展到 len，方便切片，不足部分自动补 0
        F.resize(len); 
        Poly G(1);
        G[0] = ksm(F[0], mod - 2);
        // 3. 牛顿迭代，每次长度翻倍，直到 len
        for (int i = 2; i <= len; i <<= 1){ 
            // 取 F 的前 i 项 (即 H = F mod x^i)
            Poly H(F.begin(), F.begin() + i); 
            // P = G * H mod x^i
            // 此时 G 的大小为 i/2，计算结果需要保留 i 项
            Poly P = norm_mul(G, H, i); 
            // 计算 2 - P
            for(LL& val : P) val = (mod - val) % mod; // 取反
            P[0] = (P[0] + 2) % mod; // +2
            // G_new = G * (2 - PH) mod x^i
            G = norm_mul(G, P, i);
        }
        // 4. 最后截断回 n 项
        G.resize(n);
        return G;
    }

    void calc_fac(Poly& a, Poly& b, int n, int k){
        Poly F(n+1), G(n*2+1), H, sum(n*2+1), isum(n*2+1);
        int L = 1;
        while(L <= n * 2) L <<= 1;
        
        // 计算F
        for(int i = 0; i <= n; i++)F[i] = mul(a[i], mul(ifac[i], ifac[n - i]));
        for(int i = n - 1; i >= 0; i -= 2)F[i] = mod - F[i];
        
        // 计算G
        int t = sub(k, n); 
        for(int i = 0; i <= 2 * n; i++)G[i] = add(i, t);
        sum[0] = G[0];
        for(int i = 1; i <= n * 2; i++)sum[i] = mul(sum[i - 1], G[i]);
        isum[n * 2] = ksm(sum[n * 2], mod - 2);
        for(int i = n * 2; i >= 1; i--)isum[i - 1] = mul(isum[i], G[i]);
        for(int i = 1; i <= n * 2; i++)G[i] = mul(isum[i], sum[i - 1]);
        G[0] = isum[0];
        
        // 使用MTT计算卷积
        H = norm_mul(F, G, L);
        
        // 计算结果b
        LL res = 1;
        int p1 = k - n, p2 = k;
        for(int i = p1; i <= p2; i++)res = mul(res, i);
        res=sub(res,0);
        
        // 重新计算G用于后续计算
        for(int i = 0; i <= n; i++)G[i] = (mod + p1 + i) % mod;
        sum[0] = G[0];
        for(int i = 1; i <= n; i++)sum[i] = mul(sum[i - 1], G[i]);
        isum[n] = ksm(sum[n], mod - 2);
        for(int i = n; i >= 1; i--)isum[i - 1] = mul(isum[i], G[i]);
        for(int i = 1; i <= n; i++)G[i] = mul(isum[i], sum[i - 1]);
        G[0] = isum[0];

        // 计算b
        for(int i = 0; i <= n; i++, p2=add(p2,1)){
            b[i] = mul(H[i + n], res);
            res = mul(res, mul(G[i], add(p2,1)));
        }
    }

    LL fac_work(LL bl){
        static Poly a(N), b(N), c(N);
        LL s = 0;
        for(LL p = bl; p; p >>= 1) ++s;
        a[0] = 1;
        --s;
        LL qwq = ksm(bl, mod - 2);
        LL p = 0;
        
        for(; s >= 0; s--){
            if(p){
                calc_fac(a, b, p, p + 1);
                for(int i = 0; i <= p; i++) a[p + i + 1] = b[i];
                a[p << 1 | 1] = 0;
                calc_fac(a, b, p << 1, mul(p, qwq));
                p <<= 1;
                for(int i = 0; i <= p; i++) a[i] = mul(a[i], b[i]);
            }
            if(bl >> s & 1){
                for(int i = 0; i <= p; i++)a[i] = mul(a[i],bl*i%mod + p + 1);
                p |= 1;
                a[p] = 1;
                for(int i = 1; i <= p; i++)a[p] = mul(a[p],bl*p%mod + i);
            }
        }
        LL res = 1;
        for(int i = 0; i < bl; i++)res = mul(res, a[i]);
        return res;
    }

    LL get_fac(int n){
        LL s = sqrt(n);
        LL res = fac_work(s);
        for(LL i = s * s + 1; i <= n; i++)res = mul(res, i);
        return res;
    }

    LL norm_fac(int n){
        if(n > mod - 1 - n){
            LL res = ksm(get_fac(mod - 1 - n), mod - 2);
            return ((mod - 1 - n) & 1) ? res : mod - res;
        }
        return get_fac(n);
    }
}

using FFT::Poly;


void solve_norm_mul(){
    int n,m;LL mod; cin>>n>>m>>mod;n++,m++;
    FFT::init(mod);
    Poly A(n),B(m); 
    for(int i=0;i<n;i++)cin>>A[i];
    for(int i=0;i<m;i++)cin>>B[i];
    // 正确地将结果长度 n+m-1 传给 lim
    Poly C = FFT::norm_mul(A,B,n+m-1); 
    for(int i=0;i<n+m-1;i++)cout<<C[i]<<" ";
    cout<<"\n";
}

void solve_norm_inv(){
    int n; LL mod=1e9+7; 
    cin >> n ; // 读取 n 和 mod
    FFT::init(mod);
    Poly F(n); 
    for(int i=0;i<n;i++)cin>>F[i];
    Poly G = FFT::norm_inv(F,n);
    for(int i=0;i<n;i++)cout<<G[i]<<" ";
    cout<<"\n";
}

void solve_norm_fac(){
    int T;
    cin>>T;
    while(T--){
        int n; 
        LL mod; 
        cin >> n >> mod;
        FFT::init(mod);
        cout << FFT::norm_fac(n) << "\n";
    }
}

int main() {
    cin.tie(0)->sync_with_stdio(0);
    // solve_norm_mul();// AC 1520 ms
    // solve_norm_inv();// AC 2190 ms
    solve_norm_fac();// AC 4820 ms
    return 0;
}
```

=== 快速数论变换 (NTT)

==== 算法思考

#note[
  看来很简单，就是 使用的是原根的次幂的周期循环特性 把除了 $2$ 的次幂的幂 都绑成一个类似 $omega$ 的 $g$ 

  但是不知道它的这个递归层数对 周期长度有要求吗？？？ 答案会怎么样？
]

#note(title: "核心原理：模意义下的单位根存在性")[
  在 NTT 中，我们需要找到 $n$ 阶单位根 $g_n equiv g^((P-1)/n) pmod(P)$。为了让分治算法（蝴蝶变换）能递归到最底层，必须满足：
  1. *分治要求*：变换长度 $n$ 必须是 $2$ 的幂次（即 $n = 2^k$）。
  2. *存在性要求*：$n$ 阶单位根存在的充要条件是 $n$ 整除 $P-1$（即 $n divides (P-1)$）。
  
  因此，*素数 $P-1$ 包含 $2$ 的因子个数，直接决定了 NTT 能够处理的最大序列长度。*
]

#note(title:"常用素数与最大长度限制")[
  以最常用的 NTT 素数 $P = 998244353$ 为例：
  $ P - 1 = 998244352 = 119 times 2^23 $
  这说明该素数支持的最大分治深度为 $23$ 层，即支持的最大序列长度为 $n_"max" = 2^23 approx 8.38 times 10^6$。
  
  如果题目要求的序列长度超过 $2^23$，或者使用了 $P-1$ 不包含足够多 $2$ 因子的素数，NTT 变换将无法进行。

  常用素数:
  
  + $167772161 = 5 times 2^(25) + 1, g=3$
  + $469762049 = 7 times 2^(26) + 1, g=3$
  + $754974721 = 3^2 times 5 times 2^(24) + 1,g=3$
  + $998244353 = 7 times 17 times 2^(23) + 1, g=3$
  + $1004535809 = 479 times 2^21 + 1, g=3$
]

#note(title: "答案的取模与精度问题")[
  1. *绝对精度*：与 FFT 的浮点数误差不同，NTT 的计算在模意义下是绝对精确的。
  2. *数值范围限制*：卷积后的真实系数 $C_i$ 如果超过了 $P$，结果会变成 $C_i mod P$。
  
  *应对方案*：
  - 如果真实结果 $C_i$ 很大，需选取更大的素数（如 $P approx 10^18$ 的素数，需手工实现 `__int128` 乘法）。
  - 或者使用 *任意模数 NTT*：选取 3 个不同的常用 NTT 素数分别计算，最后利用 *中国剩余定理 (CRT)* 合并结果。
]

==== 模板

===== 普通多项式乘法 (NTT)(普通版)

```cpp
// P3803 【模板】多项式乘法 (FFT) 
#include <bits/stdc++.h>
using LL = long long;

using namespace std;

const int N = 2097200;
const LL mod = 998244353, g = 3, invg = 332748118;

inline LL ksm(LL A, LL P) {
	LL res = 1;
	while(P) {
		if(P & 1) res = res * A % mod;
		A = A * A % mod;
		P >>= 1;
	}
	return res;
}

int R[N];
void Init(int n) {
	for(int i = 1; i < n; ++i) {
		R[i] = R[i >> 1] >> 1;
		if(i & 1) R[i] |= n >> 1;
	}
}

void NTT(LL A[], int n, int type) {
  // 1.重排
	for(int i = 0; i < n; ++i) if(i < R[i]) swap(A[i], A[R[i]]);
	// 2.迭代合并
  for(int i = 2; i <= n; i <<= 1) {// 合并块的长度
		LL gn = ksm(type == 1 ? g : invg , ((mod - 1) / (LL)i));// 单位根步长
		for(int j = 0; j < n; j += i) {// 枚举起始块的位置
			LL gk = 1;// 单位
			for(int k = j; k < j + i / 2; ++k) {// 蝴蝶操作
				LL x = A[k], y = gk * A[k + i / 2] % mod;// 
				A[k] = (x + y) % mod; A[k + i / 2] = ((x - y) % mod + mod) % mod;
				gk = gk * gn % mod;
			}
		}
	}
	if(type == -1) {
		LL inv = ksm(n, mod - 2);
		for(int i = 0; i < n; ++i) A[i] = A[i] * inv % mod;
	}
}

void polymul(LL A[], LL B[], int lenA, int lenB) {
	int L = lenA + lenB, len = 1; 
  while(L) {len <<= 1; L >>= 1;}
	Init(len); 
  NTT(A, len, 1); NTT(B, len, 1);
	for(int i = 0; i < len; ++i) A[i] = A[i] * B[i];
	NTT(A, len, -1);
}

int n, m;
LL A[N], B[N];

signed main() {
	cin >> n >> m;
	for(int i = 0; i <= n; ++i) cin >> A[i];
	for(int i = 0; i <= m; ++i) cin >> B[i];
	polymul(A, B, n, m);
	for(int i = 0; i <= n + m; ++i) cout << A[i] << " ";
	return 0;
}
```

===== NTT模数大全 (NTT)(DIF-DIT版)

#note[
  其实是(自己手搓的)NTT面向对象版本 夹带私货(大乘法 求逆 没有MTT 带了个分治题)
]

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;

const int N = 1<<21;

// WC 递归复用空间 我发现好像 不能做到优雅的不现开空间
namespace NTT{
    using Poly = vector<LL>;
    // iu = sqrt(-1)
    const LL mod = 998244353,g = 3,iu = 86583718,inv2=(mod+1)/2;
    
    inline LL ksm(LL a,LL b){
        LL res=1;
        for(;b;b>>=1,a=a*a%mod)if(b&1)res=res*a%mod;
        return res;
    }

    LL _w;

    // 补充 Cipolla 
    struct CP {
        LL real, imag; // real + imag * i, where i^2 = _w
        CP(LL r = 0, LL i = 0) : real(r), imag(i) {}
        // 自动切换乘法计算的 广义复数?????
        CP operator*(const CP& o)const {
            return CP(
                (real * o.real % mod + imag * o.imag % mod * _w % mod) % mod,
                (real * o.imag % mod + imag * o.real % mod) % mod
            );

        }
    };

    CP ksm(CP a, LL b) {
        CP res(1, 0);
        for(;b;b>>=1,a=a*a)if(b&1)res=res*a;
        return res;
    }

    // WC 想象力太丰富了 
    inline void inc(LL& a,LL b){
        a+=b;if(a>=mod)a-=mod;
    }
    
    inline LL add(LL a,LL b){
        a+=b;return a>=mod?a-mod:a;
    }
    
    // 自减 加入祖训 !!!
    // 这个问题太 隐蔽了!!!
    inline void dec(LL& a,LL b){
        a-=b;
        if(a<0)a+=mod;
    }
    
    inline LL sub(LL a,LL b){
        a-=b;
        return a<0?a+mod:a;
    }
    
    // 这个最常用 
    inline void tim(LL& a,LL b){
        (a*=b)%=mod;
    }
    
    // 预处理单位根/逆
    LL w[N],iw[N];
    // WC 果然 刚才多这3个数组 mle 了
    // 唉? 事实上 我可以 写一个 inv_n[N] 因为知二求一嘛!!! 
    // LL fac[N],invfac[N];// 线性预处理 逆元 方便多次积分 !!!
    // 唉!! 我又忘了 事实上时 抛弃了 线性逆元的好 占用空间少哇
    // LL inv_n[N];
    
    // 初始化
    void init(){
        
        // 阶乘求逆元
        // 这里 赛场上可以加 (影响我 AC 成绩 bushi)
        // 我是 SB 正反颠倒 还不如不写
        // fac[0]=1;
        // for(int i=1;i<N;i++)fac[i]=fac[i-1]*i%mod;
        // invfac[N-1]=ksm(fac[N-1],mod-2);
        // for(int i=N-1;i>=1;i--)invfac[i-1]=invfac[i]*i%mod;
        // for(int i=1;i<N;i++)inv_n[i]=invfac[i]*fac[i-1]%mod;
        
        // or 直接线性递推
        // 线性预处理逆元 (只需要这一个数组)
        // inv_n[1] = 1;
        // for (int i = 2; i < N; i++) {
        //     inv_n[i] = (mod - mod / i) * inv_n[mod % i] % mod;
        // }

        for(int i=1;i<N;i<<=1){
            LL wn = ksm(g,(mod-1)/(i<<1));
            LL iwn = ksm(wn,mod-2);
            w[i]=iw[i]=1;
            for(int j=1;j<i;j++){
                w[i+j]=w[i+j-1]*wn%mod;
                iw[i+j]=iw[i+j-1]*iwn%mod;
            }
        }
    }

    // 正变换 是大到小 !!!
    void DIF(Poly& A,int n){
        for(int l=n>>1;l>=1;l>>=1){
            for(int i=0;i<n;i+=l<<1){
                for(int j=0;j<l;j++){
                    LL x=A[i+j],y=A[i+j+l];
                    A[i+j]=add(x,y);
                    A[i+j+l]=sub(x,y)*w[j+l]%mod;
                }
            }
        }
    }

    // 逆变换 是小到大!!
    void DIT(Poly& A,int n){
        for(int l=1;l<n;l<<=1){
            for(int i=0;i<n;i+=l<<1){
                for(int j=0;j<l;j++){
                    LL x=A[i+j],y=A[i+j+l]*iw[j+l]%mod;
                    A[i+j]=add(x,y);
                    A[i+j+l]=sub(x,y);
                }
            }
        }
        // 你的 DIT 函数末尾缺少：
        LL invn = ksm(n, mod - 2);
        for(int i=0; i<n; i++)tim(A[i],invn);
    }

    // 快速加
    void add_to(Poly& A,Poly& B){
        int n=A.size(),m=B.size(),L=max(n,m);
        A.resize(L);
        for(int i=0;i<m;i++)inc(A[i],B[i]);
    }

    // 加
    Poly add(Poly A,Poly B){
        add_to(A,B);
        return A;
    }

    // 快速减
    void sub_to(Poly& A,Poly& B){
        int n=A.size(),m=B.size(),L=max(n,m);
        A.resize(L);
        for(int i=0;i<m;i++)dec(A[i],B[i]);
    }

    // 减
    Poly sub(Poly A,Poly B){
        sub_to(A,B);
        return A;
    }

    // 快速导
    // PS 不会改变大小
    void dev_to(Poly& A){
        int n=A.size();
        for(int i=1;i<n;i++)A[i-1]=A[i]*i%mod;
        A.back()=0;// 不能没有 !!! 
    }

    // 导
    Poly dev(Poly A){
        dev_to(A);
        return A;
    }

    // 快速积
    // PS 大小+1
    void inv_dev_to(Poly& A){
        int n=A.size();
        A.push_back(0);
        for(int i=n;i>=1;i--)A[i]=A[i-1]*ksm(i,mod-2)%mod;
        // for(int i=n;i>=1;i--)A[i]=A[i-1]*inv_n[i]%mod;
        A[0]=0;
    }

    // 积
    Poly inv_dev(Poly A){
        inv_dev_to(A);
        return A;
    }

    // 666
    // 我突然发现 这样的 *=  函数更加的普适啊

    // WC??? 要长脑子了??? 这里想要模 lim 的话 必须使用硬截取, 
    // 否则的话 !!!!!
    // 乘积 大于 lim 小于 2lim 的都 对 lim 取模 掺杂在 前 lim 个了
    void mul_to(Poly& A,Poly& B,int lim){
        // 一键对齐
        int n=A.size(),m=B.size(),L=1;
        while(L<n+m-1)L<<=1;
        A.resize(L);B.resize(L);
        // 开卷 
        DIF(A,L);DIF(B,L);
        for(int i=0;i<L;i++)A[i]=A[i]*B[i]%mod;
        DIT(A,L);
        // 最后才能直接使用硬截取 lim !!! 说是 
        A.resize(lim);
    }
    
    // 【普通多项式乘法 O(nlogn)】 
    // PS: 自动返回大小为 lim
    Poly mul(Poly A,Poly B,int lim){
        mul_to(A,B,lim);
        return A;
    }

    // 【普通多项式逆元 O(nlogn)】
    // f_2n = 2f_n - f_n^2 h
    Poly inv(Poly F,int n){
        // 奥 要先 resize(n)
        F.resize(n);
        // Base Case
        if(n==1){
            F[0]=ksm(F[0],mod-2);
            return F;
        }
        // 准备子问题
        int m=(n+1)/2;
        Poly G = inv(Poly(F.begin(), F.begin() + m), m);

        // PS: 以下为 手搓
        // 扩充
        int L=1;
        while(L<n*2)L<<=1;
        F.resize(L);G.resize(L);
        // 卷积
        DIF(F,L);DIF(G,L);
        for(int i=0;i<L;i++)F[i]=sub(2*G[i]%mod,G[i]*G[i]%mod*F[i]%mod);
        DIT(F,L);
        // 注意奥 这里 也要 resize(n)
        F.resize(n);
        
        return F;
    }

    // 【工具：模意义开根 O(1)】
    pair<LL, LL> sqrt_mod(LL x) {
        x = (x%mod+mod)%mod;
        if (x == 0) return {0, 0};
        // 检查是否存在解
        if (ksm(x, (mod - 1) / 2) == mod - 1) 
            return {-1, -1}; // 无解
        // 特殊情况
        if (x == 1) return {1, mod - 1};
        // 随机选取 s 使得 w = s^2 - x 是二次非剩余
        mt19937 rng(chrono::steady_clock::now().time_since_epoch().count());
        uniform_int_distribution<LL> dist(1, mod - 1);
        LL s;
        do {
            s = dist(rng);
            _w = (s * s % mod - x + mod) % mod;
        } while (ksm(_w, (mod - 1) / 2) != mod - 1);
        // 在扩域中计算 (s + i)^((mod+1)/2)
        CP res = ksm(CP(s, 1), (mod + 1) / 2);
        LL root1 = res.real;
        LL root2 = (mod - root1) % mod;
        if(root1>root2)swap(root1,root2);
        return {root1, root2};
    }

    // 【多项式开根（任意a_0）O(nlogn)】
    // f_2n = (f_n + h/f_n)/2 
    Poly sqrt(Poly F,int n){
        // 奥 要先 resize(n)
        F.resize(n);
        // base case: 常数项
        if(n==1){
            /*求根？？我不会啊*/
            // 但是 题目 给定了 a0 = 1 
            // 记得学
            auto [a,b] = sqrt_mod(F[0]); 
            F[0]=min(a,b);
            return F;
        }
        // 先求 (n+1)/2
        int m=(n+1)/2;
        Poly G = sqrt(Poly(F.begin(), F.begin() + m), m);
        // 这里还需要求 G 的逆
        // WTF ???? 这里需要 对 G resize(n) !!!
        G.resize(n);
        Poly iG=inv(G,n);

        // PS 以下为 手搓
        // 扩充
        int L=1;
        while(L<n*2)L<<=1;
        F.resize(L);G.resize(L);iG.resize(L);
        // 再卷积 
        DIF(F,L);DIF(G,L);DIF(iG,L);
        LL inv2=(1+mod)/2;
        for(int i=0;i<L;i++)F[i]=inv2*add(G[i],F[i]*iG[i]%mod)%mod;
        DIT(F,L);
        // 注意奥 这里 也要 resize(n)
        F.resize(n);

        return F;
    }

    // 【多项式ln O(nlogn)】
    // 什么??? 当且仅当常数项系数为 1 时才有对数多项式??? 
    // 为了节约 我们 发现了 xxx_to 这类函数
    Poly ln(Poly A,int n){
        // 1.求 逆 和 自导
        Poly A_inv = inv(A,n);
        dev_to(A);// 节约了一个 变量!!!
        // 2.将 逆 卷到自己上面  
        mul_to(A,A_inv,n);
        // 3.最后 自积
        inv_dev_to(A);
        A.resize(n);// 再取个模
        return A;
    }

    // 【多项式指数 O(nlogn)】
    Poly exp(Poly F,int n){
        // Base Case 题目保证 a0=0 所以 exp=1
        F.resize(n);
        if(n==1){
            F[0]=1;
            return F;
        }
        // 递归
        int m=(n+1)/2;
        Poly G = exp(Poly(F.begin(),F.begin()+m),m);
        G.resize(n);
        Poly ln_G = ln(G,n);

        // PS 以下非手搓! 当然 你也可以 坚持 手搓 
        inc(F[0],1);// 简单加个 1 
        sub_to(F,ln_G);// 减去 ln_G
        // 因为我看有个乘积 就尝试直接 调用乘法 和 G 卷积
        mul_to(F,G,n);

        return F;
    }

    // 【多项式幂 O(nlogn)】
    // 这个可以算是快速幂
    // 计算 C = A^B = exp(B* ln(A))
    Poly pow(Poly A,Poly B,int n){
        Poly ln_A = ln(A,n);
        mul_to(B,ln_A,n);
        return exp(B,n);
    }

    // 【普通多项式快速幂 (nlogn)】
    // A_0 = 1 注意这里的 b 表示顺序是阅读顺序
    Poly ksm(Poly A,string b,int n){
        Poly B(1,0);
        for(int i=0;i<b.size();i++)B[0]=(B[0]*10+b[i]-'0')%mod;
        return pow(A,B,n);
    }
    
    // 【任意A_0多项式快速幂(nlogn)】
    // A_0 不一定为 1 
    Poly exksm(Poly A,string b,int n){
        // 判定 A
        int len;
        for(len=0;len<A.size()&&!A[len];len++);
        if(len==A.size())return Poly(n,0);// A = 0 
        // 判定 b
        Poly B(1,0);
        // 细节: 这里的模循环节和 多项式的模循环节不一样!!! 
        // 是模 phi(mod)
        LL b2=0;
        for(int i=0;i<b.size();i++){
            B[0]=B[0]*10+b[i]-'0';
            // 我 思路炸了 ??? 
            if(B[0]*len>=n)return Poly(n,0);// base >= n 
            B[0]%=mod;// 怎么现在才想到取模 ??!!!
            // 我 真 SB 这里刚才果然 i 重命名了 CaO
            b2=(b2*10+b[i]-'0')%(mod-1);// 注意这里 减一 
        }
        // 我们可以 一切从简计算 :
        LL base = B[0]*len;
        // WC 我这里 A 会改变, 之前放在后面了 !!!
        // 1. 系数/幂次 标准化
        LL inv_A_len = ksm(A[len],mod-2);
        LL ksm_A_len=ksm(A[len],b2);
        // 注意: 这里的次幂位移没有 B[0] 倍!!!
        // 就是 /= A_len x^len
        for(int i=len;i<n;i++)A[i-len]=A[i]*inv_A_len%mod;
        for(int i=n-len;i<n;i++)A[i]=0;
        // 2. 标准化快速幂
        Poly res = pow(A,B,n);
        // 3. 计算 x^ib 幂的位移 并乘以回复系数
        // 就是 *= A_len^(b%phi(mod)) x^b 
        // 这里倒序
        // WC 我又 SB 了一直用的变量 A
        for(int i=n-1;i>=base;i--)res[i]=res[i-base]*ksm_A_len%mod;
        for(int i=0;i<base;i++)res[i]=0;
        return res;
    }

    // 【多项式带余除法 O(nlogn)】
    pair<Poly,Poly> div(Poly A,Poly B){
        int n=A.size(),m=B.size();
        if(n<m)return {Poly(1,0),A};
        pair<Poly,Poly> res;
        auto& [C,R] = res;
        int k=n-m+1;
        // A_r = B_r * C_r + R_r * x^(n-m+1)
        // A_r equiv B_r * C_r mod x^(n-m+1)
        // C_r equiv A_r * A_r^(-1) mod x^(n-m+1)
        // 第一部分 计算 C
        // 注意取 min !!!
        Poly A_r(A.end()-min(k,n),A.end()),B_r(B.end()-min(k,m),B.end());
        reverse(A_r.begin(),A_r.end());
        reverse(B_r.begin(),B_r.end());
        Poly inv_B_r = inv(B_r,k);
        C = mul(A_r,inv_B_r,k);
        reverse(C.begin(),C.end());
        // 取余数
        R = sub(A,mul(B,C,n));
        R.resize(m-1);
        return res;
    }

    // !!!
    // Poly prod[N*4]; 调试减负
    Poly prod[1];


    // 【多项式多点求值 O(nlog^2n)】
    void points_init(int i,int l,int r,const vector<LL>& A){
        // cout<<"init "<<l<<" "<<r<<"\n";
        if(l==r){
            prod[i].resize(2);
            // WC 这里不要值直接取负号啊啊啊啊 !!!!!!
            prod[i][0]=(mod-A[l]%mod)%mod;
            prod[i][1]=1;
        }else {
            int mid=(l+r)/2;
            points_init(i*2,l,mid,A);
            points_init(i*2+1,mid+1,r,A);
            // 这里确实要 保留最高项 + 1
            prod[i]=mul(prod[i*2],prod[i*2+1],r-l+2);
        }
    }
    
    void points_work(int i,int l,int r,Poly F,vector<LL>& B){
        // cout<<"work:"<<l<<" "<<r<<"\n";
        F = div(F,prod[i]).second;
        if(l==r){
            B[l]=F[0];
        }else {
            int mid=(l+r)/2;
            points_work(i*2,l,mid,F,B);
            points_work(i*2+1,mid+1,r,F,B);
        }
    }   
    
    vector<LL> points(const Poly& F,const vector<LL>& A){
        int n=F.size(),m=A.size();
        vector<LL> B(m);
        points_init(1,0,m-1,A);
        points_work(1,0,m-1,F,B);
        return B;
    }
    
    // 【多项式快速插值 O(nlog^2n)】
    Poly inter_work(int i,int l,int r,const vector<LL>& V){
        if(l==r){
            return Poly(1,V[l]);
        }else {
            int mid=(l+r)/2;
            Poly L = inter_work(i*2,l,mid,V);
            Poly R = inter_work(i*2+1,mid+1,r,V);
            mul_to(L,prod[i*2+1],r-l+1);
            mul_to(R,prod[i*2],r-l+1);
            return add(L,R);
        }
    }

    Poly inter(const vector<LL>& A,const vector<LL>& B){
        int n=A.size();
        points_init(1,0,n-1,A);
        Poly M = prod[1];
        dev_to(M);
        vector<LL> V = points(M,A);
        // 艹 这里没加 %mod 
        for(int i=0;i<n;i++)V[i]=(B[i]*ksm(V[i],mod-2))%mod;
        return inter_work(1,0,n-1,V);
    }

    // 【多项式三角函数 O(nlogn)】
    // sin x = (exp(ix) - exp(-ix))/(2i)
    // 题目保证 a_0 = 0
    Poly sin(Poly F,int n){
        F.resize(n);
        for(int i=0;i<n;i++)F[i]=F[i]*iu%mod;
        Poly G = F;
        for(int i=0;i<n;i++)G[i]=sub(0,G[i]);
        F=exp(F,n);
        G=exp(G,n);
        sub_to(F,G);
        LL inv_2iu = ksm(iu*2,mod-2);
        for(int i=0;i<n;i++)F[i]=F[i]*inv_2iu%mod;
        return F;        
    }
    
    // 【多项式三角函数 O(nlogn)】
    // cos x = (exp(ix) + exp(-ix))/2 
    // 题目保证 a_0 = 0
    Poly cos(Poly F,int n){
        F.resize(n);
        for(int i=0;i<n;i++)F[i]=F[i]*iu%mod;
        Poly G = F;
        for(int i=0;i<n;i++)G[i]=sub(0,G[i]);
        F = exp(F,n);
        G = exp(G,n);
        add_to(F,G);
        for(int i=0;i<n;i++)F[i]=F[i]*inv2%mod;
        return F;
    }
    // PS: tan x 其实求法可以化简 此处省略 
    
    // 【多项式反三角函数 O(nlogn)】
    // arcsin x = inv_dev( 1/ sqrt(1-x^2) )
    // arcsin f = inv_dev( f'/ sqrt(1 - f^2) )
    // 题目保证 a_0 = 0
    Poly asin(Poly F,int n){
        F.resize(n);
        
        Poly G=mul(F,F,n);
        for(int i=0;i<n;i++)G[i]=sub(0,G[i]);
        inc(G[0],1);
        G = sqrt(G,n);
        G = inv(G,n);
        
        dev_to(F);
        mul_to(F,G,n);
        inv_dev_to(F);
        F.resize(n);
        
        return F;
    }
    
    // 【多项式反三角函数 O(nlogn)】
    // arctan x = inv_dev( 1 /( 1 + x^2 ) )
    // arctan f = inv_dev( f'/( 1+ f^2 ) )
    Poly atan(Poly F,int n){
        F.resize(n);

        Poly G = mul(F,F,n);
        inc(G[0],1);
        G = inv(G,n);
        
        dev_to(F);
        mul_to(F,G,n);
        inv_dev_to(F);
        F.resize(n);

        return F;
    }

    // 【常系数齐次线性递推 O(k log k log n)】
    // F: 递推系数 F_1, F_2, ..., F_k
    // A: 初始项 A_0, A_1, ..., A_{k-1}
    // n: 求第 n 项
    LL linear_recurrence(Poly F, Poly A, LL n) {
        int k = F.size();
        if (n < k) return (A[n] % mod + mod) % mod;

        // 1. 构造特征多项式 P(x) = x^k - \sum F_i * x^{k-i}
        // 即 P(x) = x^k - F_1*x^{k-1} - F_2*x^{k-2} ... - F_k*x^0
        Poly P(k + 1);
        P[k] = 1;
        for (int i = 0; i < k; i++) P[k - 1 - i] = sub(0, (F[i] % mod + mod) % mod);

        // 2. 预计算用于快速取模的 P_inv_rev
        // 根据带余除法原理，我们需要 P 翻转后的逆元
        Poly P_rev = P; 
        reverse(P_rev.begin(), P_rev.end());
        Poly P_inv_rev = inv(P_rev, k + 1); 

        // 3. 定义专门的取模函数，避免重复求逆
        auto poly_mod = [&](Poly A) {
            int len_A = A.size();
            if (len_A <= k) return A;
            
            int len_Q = len_A - k; // 商的长度
            Poly A_rev = A;
            reverse(A_rev.begin(), A_rev.end());
            
            Poly Q = mul(A_rev, P_inv_rev, len_Q);
            reverse(Q.begin(), Q.end());
            
            Poly T = mul(P, Q, len_A); // T = P * Q
            A = sub(A, T);
            A.resize(k);
            return A;
        };

        // 4. 多项式快速幂计算 x^n mod P(x)
        Poly res = {1}, base = {0, 1}; // res = 1, base = x
        while (n) {
            if (n & 1) res = poly_mod(mul(res, base, res.size() + base.size() - 1));
            if (n > 1) base = poly_mod(mul(base, base, base.size() + base.size() - 1));
            n >>= 1;
        }

        // 5. 最终答案 ans = \sum res_i * A_i
        LL ans = 0;
        for (int i = 0; i < k; i++) {
            ans = (ans + res[i] * ((A[i] % mod + mod) % mod)) % mod;
        }
        return ans;
    }
}

using NTT::Poly;

void solve_mul(){
    NTT::init();
    int n,m; cin>>n>>m;
    Poly A(n+1),B(m+1);
    for(int i=0;i<n+1;i++)cin>>A[i];
    for(int i=0;i<m+1;i++)cin>>B[i];
    Poly C = NTT::mul(A,B,m+n+1);// 大数乘法 模 m+n+1 管够 
    for(int i=0;i<m+n+1;i++)cout<<C[i]<<" ";
    cout<<"\n";
}

void solve_inv(){
    NTT::init();
    int n; cin>>n;
    Poly F(n);
    for(int i=0;i<n;i++)cin>>F[i];
    Poly G = NTT::inv(F,n);
    for(int i=0;i<n;i++)cout<<G[i]<<" ";
    cout<<"\n";
}

void solve_sqrt(){
    NTT::init();
    int n; cin>>n;
    Poly F(n);
    for(int i=0;i<n;i++)cin>>F[i];
    Poly G = NTT::sqrt(F,n);
    for(int i=0;i<n;i++)cout<<G[i]<<" ";
    cout<<"\n";
}

void solve_ln(){
    NTT::init();
    int n; cin>>n;
    Poly F(n);
    for(int i=0;i<n;i++)cin>>F[i];
    Poly G = NTT::ln(F,n);
    for(int i=0;i<n;i++)cout<<G[i]<<" ";
    cout<<"\n";
}

void solve_exp(){
    NTT::init();
    int n; cin>>n;
    Poly F(n);
    for(int i=0;i<n;i++)cin>>F[i];
    Poly G = NTT::exp(F,n);
    for(int i=0;i<n;i++)cout<<G[i]<<" ";
    cout<<"\n";
}

void solve_ksm(){
    NTT::init();
    int n; cin>>n;
    string b; cin>>b;
    Poly A(n);
    // 【虽然题目给的 k 是 10的100000次方 但是有个性质 A_0 = 1】
    // 只有在 A_0 = 1 的时候 指数 K 才能对 mod 取模 
    // f^p(x) equiv (1 mod p)
    for(int i=0;i<n;i++)cin>>A[i];
    Poly C = NTT::ksm(A,b,n);
    for(int i=0;i<n;i++)cout<<C[i]<<" ";
    cout<<"\n";
}

void solve_exksm(){
    NTT::init();
    int n; cin>>n;
    string b; cin>>b;
    Poly A(n),B(1,0);
    // 这里题目给的 A_0 不一定等于 1 了 所以我们需要
    // 1 找到非 0系数 的最小项 
    // 2 所有数 同时处于 最小项 同时补偿
    for(int i=0;i<n;i++)cin>>A[i];
    Poly C = NTT::exksm(A,b,n);
    for(int i=0;i<n;i++)cout<<C[i]<<" ";
    cout<<"\n";
}

void solve_div(){
    NTT::init();
    int n,m; cin>>n>>m;n++,m++;
    Poly A(n),B(m);
    for(int i=0;i<n;i++)cin>>A[i];
    for(int i=0;i<m;i++)cin>>B[i];
    auto [C,R] = NTT::div(A,B);
    for(int i=0;i<n-m+1;i++)cout<<C[i]<<" ";cout<<"\n";
    for(int i=0;i<m-1;i++)cout<<R[i]<<" ";cout<<"\n";
}

// 多项式 多点求值
void solve_points(){
    NTT::init();
    int n,m; cin>>n>>m; n++;
    Poly F(n);
    for(int i=0;i<n;i++)cin>>F[i];
    vector<LL> A(m);
    for(int i=0;i<m;i++)cin>>A[i];
    vector<LL> B = NTT::points(F,A);
    for(int i=0;i<m;i++)cout<<B[i]<<"\n";
}

// 多项式 快速插值
void solve_inter(){
    NTT::init();
    int n; cin>>n;
    vector<LL> A(n),B(n);
    for(int i=0;i<n;i++)cin>>A[i]>>B[i];
    Poly F = NTT::inter(A,B);
    for(int i=0;i<n;i++)cout<<F[i]<<" ";
    cout<<"\n";
}

// 三角函数
void solve_triangle(){
    NTT::init();
    int n,type; cin>>n>>type;
    Poly F(n);
    for(int i=0;i<n;i++)cin>>F[i];
    Poly G = (type==0?NTT::sin(F,n):NTT::cos(F,n));
    for(int i=0;i<n;i++)cout<<G[i]<<" ";
    cout<<"\n";
}

void solve_inv_triangle(){
    NTT::init();
    int n,type; cin>>n>>type;
    Poly F(n);
    for(int i=0;i<n;i++)cin>>F[i];
    Poly G = (type==0?NTT::asin(F,n):NTT::atan(F,n));
    for(int i=0;i<n;i++)cout<<G[i]<<" ";
    cout<<"\n";
}

// P4723 【模板】常系数齐次线性递推
void solve_linear_recurrence() {
    NTT::init();
    LL n;
    int k;cin >> n >> k;
    Poly F(k), A(k);
    for (int i = 0; i < k; i++) cin >> F[i];
    for (int i = 0; i < k; i++) cin >> A[i];
    cout << NTT::linear_recurrence(F, A, n) << endl;
}

int main(){
    cin.tie(0)->sync_with_stdio(0);
    // solve_mul();// AC 1170 ms (WC 986 ms!) 
    // solve_inv();// AC 958 ms (WC 650 ms! 一定是我优化的好!)
    // solve_sqrt();// AC 2190 ms (WC 又一发 1880 ms!) // 加强版 1310 ms 
    // solve_ln();// AC 709 ms (线性预处理(1080 ms)
    // solve_exp();// AC 917 ms(ksm在线) 1240 ms(fac)  1390 ms(线性tmd常数大)
    // solve_ksm();// AC 3230 ms 
    // solve_exksm();// AC 2090 ms 蠢死了
    // solve_div();// AC 462 ms
    // solve_points();// AC 5020 ms 
    // solve_inter();// AC 9070 ms
    // solve_triangle();// AC 1790 ms
    // solve_inv_triangle();// AC 938 ms
    // solve_linear_recurrence();// AC 2330 ms
    // 持续更新中...
}
```

===== 任意模数多项式乘法 (MTT:三模NTT)(DIF-DIT版)

#note[
  再次复习 DIF - DIT 的流程罢了 

  跑的比 一般的 FFT 拆系数法还快 !!!
  
  说是用的Garner 算法求解真值
]

```cpp
// P4245 【模板】任意模数多项式乘法
#include <bits/stdc++.h>
using namespace std;
using LL = long long;
#define Big __int128

const int N = 1 << 19; // 调整为2的幂次
const LL mo1 = 998244353, mo2 = 1004535809, mo3 = 469762049, G = 3;

inline LL Ksm(LL x, LL y, LL mo) {
    LL res = 1; x %= mo;
    for (; y; y >>= 1, x = (LL)x * x % mo) if (y & 1) res = (LL)res * x % mo;
    return res;
}

LL MOD;
const LL inv1 = Ksm(mo1, mo2 - 2, mo2);
const LL inv2 = Ksm((Big)mo1 * mo2 % mo3, mo3 - 2, mo3);

struct Int {
    LL a, b, c;
    Int(LL _x = 0) : a(_x % mo1), b(_x % mo2), c(_x % mo3) {}
    Int(LL _a, LL _b, LL _c) : a(_a), b(_b), c(_c) {}
    inline Int operator + (const Int &x) const { return {(a + x.a) % mo1, (b + x.b) % mo2, (c + x.c) % mo3}; }
    inline Int operator - (const Int &x) const { return {(a - x.a + mo1) % mo1, (b - x.b + mo2) % mo2, (c - x.c + mo3) % mo3}; }
    inline Int operator * (const Int &x) const { return {(LL)a * x.a % mo1, (LL)b * x.b % mo2, (LL)c * x.c % mo3}; }
    
    LL gettrue() const {
        Big x = (Big)(b - a + mo2) % mo2 * inv1 % mo2 * mo1 + a;
        LL m12 = (LL)(mo1 % MOD * (mo2 % MOD) % MOD);
        return (LL)(((Big)(c - (LL)(x % mo3) + mo3) % mo3 * inv2 % mo3 * m12 + (LL)(x % MOD)) % MOD);
    }
};

// DIF-DFT
void DIF(Int *A, int n) {
    for (int len = n >> 1; len >= 1; len >>= 1) {
        Int gn(Ksm(G, (mo1 - 1) / (len << 1), mo1), 
               Ksm(G, (mo2 - 1) / (len << 1), mo2), 
               Ksm(G, (mo3 - 1) / (len << 1), mo3));
        for (int i = 0; i < n; i += (len << 1)) {
            Int gk(1);
            for (int j = 0; j < len; ++j) {
                Int x = A[i + j], y = A[i + j + len];
                A[i + j] = x + y;
                A[i + j + len] = (x - y) * gk;
                gk = gk * gn;
            }
        }
    }
}

// DIT-IDFT
void DIT(Int *A, int n) {
    for (int len = 1; len < n; len <<= 1) {
        Int gn(Ksm(Ksm(G, mo1 - 2, mo1), (mo1 - 1) / (len << 1), mo1),
               Ksm(Ksm(G, mo2 - 2, mo2), (mo2 - 1) / (len << 1), mo2),
               Ksm(Ksm(G, mo3 - 2, mo3), (mo3 - 1) / (len << 1), mo3));
        for (int i = 0; i < n; i += (len << 1)) {
            Int gk(1);
            for (int j = 0; j < len; ++j) {
                Int x = A[i + j], y = A[i + j + len] * gk;
                A[i + j] = x + y;
                A[i + j + len] = x - y;
                gk = gk * gn;
            }
        }
    }
    Int invN(Ksm(n, mo1 - 2, mo1), Ksm(n, mo2 - 2, mo2), Ksm(n, mo3 - 2, mo3));
    for (int i = 0; i < n; i++) A[i] = A[i] * invN;
}

Int f[N], g[N];

int main() {
    ios::sync_with_stdio(false); cin.tie(0);
    int n, m;
    cin >> n >> m >> MOD;
    for (int i = 0, x; i <= n; i++) cin >> x, f[i] = Int(x);
    for (int i = 0, x; i <= m; i++) cin >> x, g[i] = Int(x);
    
    int len = 1; while (len <= n + m) len <<= 1;
    
    DIF(f, len); DIF(g, len);
    for (int i = 0; i < len; i++) f[i] = f[i] * g[i];
    DIT(f, len);
    
    for (int i = 0; i <= n + m; i++) cout << f[i].gettrue() << ' ';
    return 0;
}
```

=== 快速沃尔什变换 (FWT)

#note[
  用于求解那种集合性质转移 主要是 后面的矩阵难懂
]

#note[

  P4717 【模板】快速莫比乌斯 / 沃尔什变换 (FMT / FWT)

  题目描述

  给定长度为 $2^n$ 两个序列 $A,B$，设 

  $ C_i=sum_(j "op" k = i)A_j times B_k $

  分别当 "op" 是 or, and, xor 时求出 $C$。

]

==== Or 运算

#note[
  或运算 需要设计 一种适合卷积的函数映射

  - 观察
    + or 运算的结合性: $i subset.eq S and j subset.eq S <==> (i union j) in S$ 
    + 因此 设计 
      $
        "FWT"[A]_i = A_i '  = sum_(j subset.eq i) A_i 
      $
    + 故有 
      $
        "FWT"[C]_k 
        &= ("FWT"[A] times "FWT"[B])_k \
        &= (sum_(i subset.eq k) A_i) (sum_(j subset.eq k) B_j)\
        &= sum_( (i union j) subset.eq k) A_i B_j   
      $
      恰好符合 $"FWT"[C]$ 的定义 
    + PS: Or 运算的 $"FWT"[A]$ 其实就是 高维前缀和(SOS)
    + 仍然考虑分治做法 二进制标准化后 根据 最高位的维度 0 1 分治 $A_0, A_1$ 区
      - 左右边的 k-1 维自然算出来了 
      - 由于高维屏蔽性 左右边的计算结果此时无关 
      - 右边还没有左边对应元素的信息 注意到此时结果为*局部SOS* 我们只需要抓重点 
      - 右边对应着+=左边的答案即可 
    + $
        "FWT"[A] = "merge"("FWT"[A_0],"FWT"[A_0]+"FWT"[A_1])\

        "UFWT"[A'] = "merge"("UFWT"[A_0 '],"UFWT"[A_1 ']-"UFWT"[A_0 '])\
      $
]

```cpp
// type: 1 是正变换 -1 equiv mod-1 是 逆变换 
void Or(ll *a, ll type) {  // 迭代实现，常数更小
  for (ll x = 2; x <= n; x <<= 1) {       // (1) 控制当前的“块”大小
    ll k = x >> 1;                        // k 是半块的长度
    for (ll i = 0; i < n; i += x) {       // (2) 遍历每一个独立的“块”
      for (ll j = 0; j < k; j++) {        // (3) 遍历块内的前半部分
        // (a[i + j + k] += a[i + j] * type) %= P;// (4) 核心操作
        a[i|j|k]=(a[i|j|k]+a[i|j]*type%mod)%mod;
      }
    }
  }
}
```

==== And 运算

#note[
  同样的道理 

  这里不是子集和了 这里是*超集和*

  $
    "FWT"[A] = "merge"("FWT"[A_0]+"FWT"[A_1],"FWT"[A_1])\

    "UFWT"[A'] = "merge"("UFWT"[A_0 ']-"UFWT"[A_1 '],"UFWT"[A_1 '])\
  $
]

```cpp
// type: 1 正变换 -1 equiv mod-1 逆变换
void And(ll *a, ll type) {
  for (ll x = 2; x <= n; x <<= 1) {
    ll k = x >> 1;
    for (ll i = 0; i < n; i += x) {
      for (ll j = 0; j < k; j++) {
        a[i|j]=(a[i|j]+a[i|j|k]*type%mod)%mod;
      }
    }
  }
}
```

==== Xor 运算 

#note[
  设 $x compose y = "popcount"(x inter y) mod 2$\
  那么有 $(x compose y) plus.o (x compose z) = x compose (y plus.o z) $
  $
    "FWT"[A] = sum_(i compose j = 0) A_j - sum_(i compose j = 1) A_j 
  $  
  这个变换满足要求 
  
  这么理解:
    + 还是分为两半 $A_0 A_1$
    + 对于 $A_0$ 这一部分 $i_b=0$ 那么加上这一位, 奇偶性必然不变\
    + 对于 $A_1$ 这一部分 $i_b=1$ 加上这一位, 对于 $j_b=0$ 的因为交运算结果还是 $0$ 奇偶性不变, 而 $j_b=1$(右侧$A_1$) 的奇偶性切换,所以取负号
    故
    $
      "FWT"[A] = "merge"("FWT"[A_0]+"FWT"[A_1],"FWT"[A_0]-"FWT"[A_1])\
      "UFWT"[A'] = "merge"(("UFWT"[A_0 ']+"UFWT"[A_1 '])/2,("UFWT"[A_0 ']-"UFWT"[A_1 '])/1)
    $
]

```cpp
// type: 1 正变换 1/2 equiv (mod+1)/2 逆变换
void Xor(ll *a, ll type) {
  for (ll x = 2; x <= n; x <<= 1) {
    ll k = x >> 1;
    for (ll i = 0; i < n; i += x) {
      for (ll j = 0; j < k; j++) {
        a[i|j]=(a[i|j]+a[i|j|k])%mod;
        a[i|j|k]=(a[i|j]-a[i|j|k]*2%mod+mod)%mod;
        a[i|j]=a[i|j]*type%mod;
        a[i|j|k]=a[i|j|k]*type%mod;
      }
    }
  }
}
```

==== Xnor (同或)运算

#note[
  类比异或
  设 $x "op" y = "popcount"(x union y) mod 2 $\ 
  $
    "FWT"[A]_i = sum_(i "op" j = 0) A_j - sum_(i "op" j = 1) A_j  
  $

  推导:
    + 对于 $i_b=0$ 这里的奇偶性 对于 $A_0$ 是不变的 对于 $A_1$ 要取负号
    + 对于 $i_b=1$ 这里的奇偶性 对于 $A_0$ 必须取负号, 对于 $A_0$ 也要取负号 

  $
    "FWT"[A] = "merge"(-"FWT"[A_1]+"FWT"[A_0],-"FWT"[A_1]-"FWT"[A_0])\
    "UFWT"[A'] = "merge"((-"UFWT"[A_1 ']+"UFWT"[A_0 '])/2,(-"UFWT"[A_1]-"UFWT"[A_0])/2)\
  $

  代码不保对
]

```cpp
// type: 1 正变换 1/2 逆变换
void Xnor(LL *a,LL type){
    for (ll x = 2; x <= n; x <<= 1) {
    ll k = x >> 1;
    for (ll i = 0; i < n; i += x) {
      for (ll j = 0; j < k; j++) {
        (a[i + j] += P - a[i + j + k]) %= P;
        (a[i + j + k] = P - a[i + j] + (P - a[i + j + k]) * 2 ) %= P;
        (a[i + j] *= type) %= P;
        (a[i + j + k] *= type) %= P;
      }
    }
  }
}

```

==== 另一个角度的 FWT 

#note[
  略
]

==== FWT 是线性变换

$
  "FWT"[A+B] = "FWT"[A] + "FWT"[B]\
  "FWT"[c dot A] = c dot "FWT"[A]
$

==== K 维 FWT

#note[
  略
]

=== Chirp Z变换

#note[
  解决多项式在几何级数点集 $x_k = c^k$ 处的快速求值问题
  
  PS:没学
]

==== Chirp Z 变换 (CZT)

#note(title:"定义")[
  给定 $n-1$ 次多项式 $P(x) = sum_(i=0)^(n-1) a_i x^i$，计算其在 $c^0, c^1, dots, c^(m-1)$ 共 $m$ 个点处的取值。
  当 $c$ 是单位根时，这是 DFT；当 $c$ 是任意常数时，需使用 Bluestein 算法转化为卷积处理。

  我们就是要在一个多项式上求一个等比数列点对应的函数值。
]

===== Bluestein 算法推导

我们需要计算：
$ y_k = P(c^k) = sum_(i=0)^(n-1) a_i (c^k)^i = sum_(i=0)^(n-1) a_i c^(k i), quad (0 <= k < m) $

利用数学恒等式 $k i = binom(k+i, 2) - binom(k, 2) - binom(i, 2)$，代入上式：
$ y_k = sum_(i=0)^(n-1) a_i c^(binom(k+i, 2) - binom(k, 2) - binom(i, 2)) $

将与 $i$ 无关的项提出来：
$ y_k = c^(-binom(k, 2)) sum_(i=0)^(n-1) (a_i c^(-binom(i, 2))) dot c^(binom(k+i, 2)) $

令：
- $f_i = a_i c^(-binom(i, 2))$
- $g_t = c^(binom(t, 2))$

则 $y_k = g_k^(-1) sum_(i=0)^(n-1) f_i g_(k+i)$。
这是一个典型的 *减法卷积*（或称翻转卷积）形式，可以通过多项式乘法在 $O((n+m) log (n+m))$ 时间内解决。

#note(title:"细节")[

1. *指数计算*：$binom(x, 2) = frac(x(x-1), 2)$。由于是在指数位置，计算时应对 $P-1$ 取模（由欧拉定理），但在本题中 $c$ 可能与 $P$ 不互质（如 $c=0$），通常直接计算 $x(x-1)/2$ 序列即可。
2. *卷积转化*：为了变为加法卷积，令 $f'_i = f_(n-1-i)$，则：
   $ sum f_i g_(k+i) = [x^(n-1+k)] ( (sum f' x^i) * (sum g x^i) ) $
3. *特判*：若 $c=0$ 或 $c=1$，虽然算法通解有效，但需注意 $0$ 的逆元不存在。但在 $binom(x, 2)$ 的公式中，若 $c != 0$，逆元始终存在；若 $c=0$，则除 $P(c^0)$ 外其余点值均为 $a_0$。

]


===== 代码模板 (Standard NTT-based CZT)
====== 普通 CZT (NTT:CZT)

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

typedef long long ll;
const int MOD = 998244353;

// 基础工具：快速幂
ll ksm(ll a, ll b) {
    ll res = 1; a %= MOD;
    while (b) {
        if (b & 1) res = res * a % MOD;
        a = a * a % MOD;
        b >>= 1;
    }
    return res;
}

// NTT 模板开始
void ntt(vector<int>& a, bool invert) {
    int n = a.size();
    for (int i = 1, j = 0; i < n; i++) {
        int bit = n >> 1;
        for (; j & bit; bit >>= 1) j ^= bit;
        j ^= bit;
        if (i < j) swap(a[i], a[j]);
    }
    for (int len = 2; len <= n; len <<= 1) {
        ll wlen = ksm(3, (MOD - 1) / len);
        if (invert) wlen = ksm(wlen, MOD - 2);
        for (int i = 0; i < n; i += len) {
            ll w = 1;
            for (int j = 0; j < len / 2; j++) {
                int u = a[i + j], v = (int)(1LL * a[i + j + len / 2] * w % MOD);
                a[i + j] = (u + v) % MOD;
                a[i + j + len / 2] = (u - v + MOD) % MOD;
                w = w * wlen % MOD;
            }
        }
    }
    if (invert) {
        ll n_inv = ksm(n, MOD - 2);
        for (int& x : a) x = (int)(1LL * x * n_inv % MOD);
    }
}

// CZT 实现函数
vector<int> CZT(vector<int>& a, int c, int m) {
    int n = a.size();
    vector<int> res(m);
    if (c == 0) { // 特判 c=0
        ll sum_a = 0;
        for (int x : a) sum_a = (sum_a + x) % MOD;
        res[0] = sum_a;
        for (int i = 1; i < m; i++) res[i] = a[0];
        return res;
    }

    int L = 1;
    while (L < n + m) L <<= 1;

    vector<int> f(L, 0), g(L, 0);
    ll inv_c = ksm(c, MOD - 2);

    // f_i = a_i * c^(-i(i-1)/2)
    // g_i = c^(i(i-1)/2)
    for (int i = 0; i < n + m; i++) {
        ll idx_val = 1LL * i * (i - 1) / 2 % (MOD - 1);
        ll gc = ksm(c, idx_val);
        if (i < n) f[n - 1 - i] = 1LL * a[i] * ksm(gc, MOD - 2) % MOD;
        g[i] = gc;
    }

    ntt(f, false); ntt(g, false);
    for (int i = 0; i < L; i++) f[i] = 1LL * f[i] * g[i] % MOD;
    ntt(f, true);

    for (int k = 0; k < m; k++) {
        ll idx_val = 1LL * k * (k - 1) / 2 % (MOD - 1);
        ll inv_gk = ksm(ksm(c, idx_val), MOD - 2);
        res[k] = 1LL * f[n - 1 + k] * inv_gk % MOD;
    }
    return res;
}

int main() {
    ios::sync_with_stdio(false); cin.tie(0);
    int n, c, m;
    cin >> n >> c >> m;
    vector<int> a(n);
    for (int i = 0; i < n; i++) cin >> a[i];

    vector<int> ans = CZT(a, c, m);
    for (int i = 0; i < m; i++) cout << ans[i] << (i == m - 1 ? "" : " ");
    return 0;
}
```

#note(title: "使用说明")[
  1. 调用 `CZT(a, c, m)`。
  2. `a` 为多项式系数（低次到高次）。
  3. `c` 为几何级数公比。
  4. `m` 为输出的点数。
  5. 复杂度：$O((n+m) log (n+m))$。
]

#note(title: "对比点值表示法")[
  - *FFT*：点集必须是 $n$ 次单位根的幂，限制较大。
  - *CZT*：点集可以是任意几何级数，适用于更广的采样场景。
]

====== 任意模数 CZT (直接使用 DIT-DIF优化) (MTT:CZT)

#note(title:"感悟")[
  遇到任意模数 其实就是套了个3模 Garner 其他的没啥了 
]

```cpp
#include<bits/stdc++.h>
using namespace std;

#define int long long
#define MAXN 2100005

const int mod = 1000000007;

typedef vector<int> poly;

int n,c,m;

inline int fp( int x , int p , int mod ){ int res = 1; while( p ){ if( p & 1 ) res = res * x % mod; x = x * x % mod; p >>= 1; } return res; }
inline int inv( int x , int mod ){ return fp( x , mod - 2 , mod ); }

const int mod1 = 998244353,mod2 = 469762049,mod3 = 167772161; 
const int inv1 = inv( mod1 , mod2 ),mul = mod1 * mod2,inv2 = inv( mul % mod3 , mod3 );

struct Int{
	int x,y,z;
	Int( int num = 0 ): x(num),y(num),z(num){}
	Int( int a , int b , int c ): x(a),y(b),z(c){}
	inline Int reduce( Int A ){ return Int( A.x + ( A.x >> 63 & mod1 ) , A.y + ( A.y >> 63 & mod2 ) , A.z + ( A.z >> 63 & mod3 ) ); }
	inline Int operator +( Int A ){ return reduce( Int( x + A.x - mod1 , y + A.y - mod2 , z + A.z - mod3 ) ); }
	inline Int operator -( Int A ){ return reduce( Int( x - A.x , y - A.y , z - A.z ) ); }
	inline Int operator *( Int A ){ return Int( x * A.x % mod1 , y * A.y % mod2 , z * A.z % mod3 ); }
	inline int val(){
		int tmp = ( y - x + mod2 ) % mod2 * inv1 % mod2 * mod1 + x;
		return ( ( z - tmp % mod3 + mod3 ) % mod3 * inv2 % mod3 * ( mul % mod ) % mod + tmp ) % mod;
	}
};

namespace polybase{
	Int gw[MAXN],tmp[MAXN];
	inline void polypre( int T = 21 ){
		gw[0] = Int( 1 );
		gw[1 << T] = Int( fp( fp( 3 , 119 , mod1 ) , 1 << ( 21 - T ) , mod1 ) , fp( fp( 3 , 7 , mod2 ) , 1 << ( 24 - T ) , mod2 ) , fp( fp( 3 , 5 , mod3 ) , 1 << ( 23 - T ) , mod3 ) );
		for( int i = T ; i ; i -- ) gw[1 << ( i - 1 )] = gw[1 << i] * gw[1 << i];
		for( int i = 1 ; i < ( 1 << T ) ; i ++ ) gw[i] = gw[i & ( i - 1 )] * gw[i & -i];
	}
	inline void DIT( Int *A , int len ){
		for( int i = 0 ; i < len ; i ++ ) tmp[i] = A[i];
		for( int i = 1 ; i < len ; i <<= 1 ){
			Int *k = tmp;
			for( Int *g = gw ; k < tmp + len ; k += i << 1 , g ++ ){
				for( Int *x = k ; x < k + i ; x ++ ){
					Int o = x[i];
					x[i] = ( *x - o ) * *g,*x = *x + o;
				}
			}
		}
		Int iv( inv( len , mod1 ) , inv( len , mod2 ) , inv( len , mod3 ) );
		for( int i = 0 ; i < len ; i ++ ) A[i] = tmp[i] * iv;
		reverse( A + 1 , A + len );
	}
	inline void DIF( Int *A , int len ){
		for( int i = 0 ; i < len ; i ++ ) tmp[i] = A[i];
		for( int i = len / 2 ; i ; i >>= 1 ){
			Int *k = tmp;
			for( Int *g = gw ; k < tmp + len ; k += i << 1 , g ++ ){
				for( Int *x = k ; x < k + i ; x ++ ){
					Int o = x[i] * *g;
					x[i] = *x - o,*x = *x + o;
				}
			}
		}
		for( int i = 0 ; i < len ; i ++ ) A[i] = tmp[i];
	}
	inline poly polymul( poly A , poly B ){
		int n = A.size(),m = B.size(),L = n + m - 1,len = 1;
		while( len < L ) len <<= 1;
		static Int tA[MAXN],tB[MAXN];
		for( int i = 0 ; i < n ; i ++ ) tA[i] = Int( A[i] );
		for( int i = n ; i < len ; i ++ ) tA[i] = Int( 0 );
		for( int i = 0 ; i < m ; i ++ ) tB[i] = Int( B[i] );
		for( int i = m ; i < len ; i ++ ) tB[i] = Int( 0 );
		DIF( tA , len ),DIF( tB , len );
		for( int i = 0 ; i < len ; i ++ ) tA[i] = tA[i] * tB[i];
		DIT( tA , len );
		poly Ans( L ); for( int i = 0 ; i < L ; i ++ ) Ans[i] = ( tA[i].val() + mod ) % mod;
		return Ans;
	}
	inline poly polyTmul( poly A , poly B ){
		int n = A.size(),m = B.size();
		reverse( B.begin() , B.end() );
		B = polymul( A , B );
		for( int i = 0 ; i < n ; i ++ ) A[i] = B[i + m - 1];
		return A;
	}
}

using namespace polybase;

int base[MAXN] = {0},pbase[MAXN] = {0};

inline int Rpow( int X ){ return pbase[X / ( 2 * n )] * base[X % ( 2 * n )] % mod; }

poly C,D,E,P;

signed main(){
	ios::sync_with_stdio(false);
	cin.tie(0);
	polypre();
	if(!(cin >> n >> c >> m)) return 0;
	base[0] = 1;
	for( int i = 1 ; i <= MAXN - 5 ; i ++ ) base[i] = base[i - 1] * c % mod;
	pbase[0] = 1;
	for( int i = 1 ; i <= MAXN - 5 ; i ++ ) pbase[i] = pbase[i - 1] * base[2 * n] % mod;
	P.resize( n ),C.resize( n + m ),D.resize( n ),E.resize( n );
	for( int i = 0 ; i < n ; i ++ ) cin >> P[i];
	for( int i = 0 ; i < n + m ; i ++ ) C[i] = Rpow( i * ( i - 1 ) / 2 );
	for( int i = 0 ; i < n ; i ++ ) D[i] = inv( Rpow( i * ( i - 1 ) / 2 ) , mod );
	for( int i = 0 ; i < n ; i ++ ) E[i] = P[i] * inv( Rpow( i * ( i - 1 ) / 2 ) , mod ) % mod;
	C = polyTmul( C , E );
	for( int i = 0 ; i < m ; i ++ ) C[i] = C[i] * inv( Rpow( i * ( i - 1 ) / 2 ) , mod ) % mod;
	for( int i = 0 ; i < m ; i ++ ) cout << ( C[i] + mod ) % mod << " ";
	cout << endl;
	return 0;
}
```

==== 逆 Chirp-Z 变换

#note[
  给定整数 $N,a,r$ 以及整数序列 $y_0,y_1,dots,y_(N-1)$。保证对于 $0 <= i<j <= N-1$，有 $a r^i equiv.not a r^j pmod(998244353)$。

  求出一个多项式 $f(x)=sum_(i=0)^(N-1) c_i x^i in  ZZ [x]$，使得对于每个 $i$，均满足 $f(a r^i) equiv y_i pmod(998244353)$。

  同时，必须满足 $0 <= c_i<998244353$。

  PS:没学
]

#note[
  倒是没有逆天的任意模数 Chirp-Z 了 
]

```cpp
// P14993 【模板】Inverse Chirp Z-Transform
#include <bits/stdc++.h>
using namespace std;

typedef unsigned int uint;
typedef unsigned long long ull;

const uint MOD = 998244353;

uint PowMod(uint a, uint b) {
    uint res = 1;
    a %= MOD;
    while (b) {
        if (b & 1) res = (ull)res * a % MOD;
        a = (ull)a * a % MOD;
        b >>= 1;
    }
    return res;
}

uint InvMod(uint n) {
    return PowMod(n, MOD - 2);
}

// NTT Implementation
void NTT(vector<uint>& a, bool inv) {
    int n = a.size();
    for (int i = 1, j = 0; i < n; i++) {
        int bit = n >> 1;
        for (; j & bit; bit >>= 1) j ^= bit;
        j ^= bit;
        if (i < j) swap(a[i], a[j]);
    }
    for (int len = 2; len <= n; len <<= 1) {
        uint wlen = PowMod(3, (MOD - 1) / len);
        if (inv) wlen = InvMod(wlen);
        for (int i = 0; i < n; i += len) {
            uint w = 1;
            for (int j = 0; j < len / 2; j++) {
                uint u = a[i + j], v = (ull)a[i + j + len / 2] * w % MOD;
                a[i + j] = (u + v) % MOD;
                a[i + j + len / 2] = (u + MOD - v) % MOD;
                w = (ull)w * wlen % MOD;
            }
        }
    }
    if (inv) {
        uint n_inv = InvMod(n);
        for (uint& x : a) x = (ull)x * n_inv % MOD;
    }
}

vector<uint> Product(vector<uint> a, vector<uint> b) {
    if (a.empty() || b.empty()) return {};
    int target = a.size() + b.size() - 1;
    int n = 1;
    while (n < target) n <<= 1;
    a.resize(n);
    b.resize(n);
    NTT(a, false);
    NTT(b, false);
    for (int i = 0; i < n; i++) a[i] = (ull)a[i] * b[i] % MOD;
    NTT(a, true);
    a.resize(target);
    return a;
}

vector<uint> Deriv(vector<uint> a) {
    if (a.size() <= 1) return {0};
    vector<uint> res(a.size() - 1);
    for (int i = 1; i < (int)a.size(); i++) {
        res[i - 1] = (ull)a[i] * i % MOD;
    }
    return res;
}

vector<uint> InvModBatch(vector<uint> a) {
    int n = a.size();
    if (n == 0) return {};
    vector<uint> res(n);
    vector<uint> pre(n + 1, 1);
    for (int i = 0; i < n; i++) pre[i + 1] = (ull)pre[i] * a[i] % MOD;
    uint invAll = InvMod(pre[n]);
    for (int i = n - 1; i >= 0; i--) {
        res[i] = (ull)invAll * pre[i] % MOD;
        invAll = (ull)invAll * a[i] % MOD;
    }
    return res;
}

// Chirp Z-Transform using Bluestein's Algorithm
vector<uint> CZT(vector<uint> f, uint q, int m) {
    int n = f.size();
    if (n == 0) return vector<uint>(m, 0);
    if (q == 0) {
        vector<uint> res(m, f[0]);
        for (int i = 1; i < n; i++) res[0] = (res[0] + f[i]) % MOD;
        return res;
    }

    int max_idx = max(n, m) + n;
    vector<uint> g(max_idx), inv_g(max_idx);
    uint iq = InvMod(q);
    
    g[0] = 1; inv_g[0] = 1;
    uint cur_q = 1, cur_iq = 1;
    for (int i = 1; i < max_idx; i++) {
        g[i] = (ull)g[i - 1] * cur_q % MOD;
        inv_g[i] = (ull)inv_g[i - 1] * cur_iq % MOD;
        cur_q = (ull)cur_q * q % MOD;
        cur_iq = (ull)cur_iq * iq % MOD;
    }

    vector<uint> A(n);
    for (int i = 0; i < n; i++) A[i] = (ull)f[i] * inv_g[i] % MOD;
    reverse(A.begin(), A.end());

    vector<uint> B(n + m);
    for (int i = 0; i < n + m; i++) B[i] = g[i];

    vector<uint> C = Product(A, B);
    
    vector<uint> res(m);
    for (int k = 0; k < m; k++) {
        res[k] = (ull)C[n - 1 + k] * inv_g[k] % MOD;
    }
    return res;
}

// Provided Function Logic
std::vector<uint> InvCZT(const std::vector<uint>& f, uint q) {
    if (f.empty()) return {};
    const int n = f.size();
    if (q == 0) {
        assert(n <= 2);
        if (n == 1) return {f[0]};                 
        return {f[1], (f[0] + MOD - f[1]) % MOD};  
    }
    const auto DaC = [q](auto&& DaC, int n) -> std::vector<uint> {
        if (n == 1) return {MOD - 1, 1u};
        const std::vector<uint> H = DaC(DaC, n / 2);
        std::vector<uint> HH = H;
        const uint iqn = InvMod(PowMod(q, n / 2));
        uint qq = PowMod(q, (ull)(n / 2) * (n / 2) % (MOD - 1));
        for (int i = 0; i <= (int)n / 2; ++i)
            HH[i] = (ull)HH[i] * qq % MOD, qq = (ull)qq * iqn % MOD;
        std::vector<uint> res = Product(H, HH);
        if (n & 1) {
            res.resize(n + 1);
            const uint qnm1 = MOD - PowMod(q, n - 1);
            for (int i = n; i > 0; --i) {
                res[i] = (res[i] + res[i - 1]);
                if (res[i] >= MOD) res[i] -= MOD;
                res[i - 1] = (ull)res[i - 1] * qnm1 % MOD;
            }
        }
        return res;
    };
    const std::vector<uint> M = DaC(DaC, n);
    std::vector<uint> C = InvModBatch(CZT(Deriv(M), q, n));
    for (int i = 0; i < n; ++i) C[i] = (ull)f[i] * C[i] % MOD;
    const uint iq = InvMod(q);
    uint qmi = 1;
    for (int i = 0; i < n; ++i)
        C[i] = (ull)C[i] * qmi % MOD, qmi = (ull)qmi * iq % MOD;
    C = CZT(C, iq, n);
    for (int i = 0; i < n; ++i)
        if (C[i] != 0) C[i] = MOD - C[i];
    std::vector<uint> res = Product(M, C);
    res.resize(n);
    return res;
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(NULL);

    int n;
    uint a, r;
    cin >> n >> a >> r;

    vector<uint> y(n);
    for (int i = 0; i < n; i++) cin >> y[i];

    if (n == 0) return 0;
    
    // Distinct constraint ar^i implies if N > 1, a cannot be 0.
    // If a = 0, N must be 1.
    if (a == 0) {
        cout << y[0] << endl;
        return 0;
    }

    // Solve g(r^i) = y_i where f(ax) = g(x)
    vector<uint> g_coeffs = InvCZT(y, r);
    
    // f_j = g_j * (a^j)^-1
    uint invA = InvMod(a);
    uint curInvA = 1;
    for (int i = 0; i < n; i++) {
        uint ci = (ull)g_coeffs[i] * curInvA % MOD;
        cout << ci << (i == n - 1 ? "" : " ");
        curInvA = (ull)curInvA * invA % MOD;
    }
    cout << endl;

    return 0;
}
```

=== 多项式牛顿迭代
 
#note[
  多项式牛顿迭代是一种 计算思想
]

==== 描述

#note[
  多项式 $G(x,y), f(x)$ 满足
  $
    G(x,f(x)) equiv pmod(x^n) 
  $
  且 $exists f_1$ 使得  
  + $G(0,f_1) = 0$
  + $(partial G)/(partial y) (0,f_1) != 0 $

  求解模 $x^n$ 意义下的 $f(x)$
]

#note(title:"推导方式")[

  注意: 一下的 $n$ 和 $2n$ 的关系是 上取整关系哈

  令初始给定的函数为 $G(x,n) equiv 0 pmod(x^n)$, 目标模 $x^n$ 意义下的解 $y = f_n (x)$\
  求得模 $x^n$ 意义下的解为 $f_n (x)$, $f_1(x) = a_0^(-1)$\ 
  令 $G$ 在 $y=f_n (x)$ 处展开 
  (注意 $f_(2n) (x)-f_n (x)$ 中 已去除 0 -- n-1 项)
  $
    & G(x,f_(2n) (x)) = sum_(i=0)^infinity (G_y^((i)) (x,f_n (x)))/(i!) (f (x)-f_n (x)) equiv 0 pmod(x^n)\
    & => G (x,f_n (x)) + G_y^((1)) (x,f_n (x)) dot (f_(2n) (x) - f_n (x)) equiv 0 pmod(x^(2n))\ 
    & => f_(2n) (x) equiv f_n (x) - (G(x,f_n (x)))/(G_y^((1)) (x,f_n (x))) pmod(x^(2n)) 
  $
]

==== 例题

===== 多项式求逆

#note[
  就是多项式关于模 $x^p$ 的"逆元"\
  
  假设要求 $h(x)$ 的逆 $f(x)$ 故 $h(x) f(x) equiv 0 pmod(x^n)$ \
  在公式中
  $ 
    & G(x,f(x)) = 1/f(x) - h(x) \
    & => G_y (x,f(x)) = - 1 /(f^2 (x))
  $
  即
  $
    f_(2n) (x) &= f_n (x) - (1/(f_n (x)) - h(x))/( - 1/(f_n^2 (x)) ) pmod(x^(2n))\ 
    & = 2 f_n (x) - f_n^2 (x) h(x) pmod(x^(2n))
  $
]

===== 多项式开方 

#note[
  开根号

  假设要求 $h(x)$ 的开方 $f(x)$ 即 $f^2(x) equiv h(x) pmod(x^n)$\
  在公式中 
  $
    &G(x,f(x)) = f^2(x) - h(x) \
    &=> G_y (x,f(x)) = 2f(x) 
  $
  即
  $
    f_(2n) (x) = f_n (x) - (f_n^2 (x) - h(x))/( 2f_n (x)) pmod(x^(2n))
  $
]

===== 临时补充:多项式 ln

#note[
  导一下 在积回来

  $
    G(x) = ln(F(x)) =   integral ln(F(x))' d x = integral (F'(x))/F(x) d x 
  $

  需要实现 求导 `dev` 求积分 `inv_dev`
]

===== 多项式 exp

#note[

  前置知识其实是 求 $ln$ ... 有关 *导* 和 *积* 在多项式的简单应用...

  求 exp

  假设要求 $h(x)$ 的 exp $f(x)$ 即 $ln(f(x)) equiv h(x) pmod(x^n)$
  在公式中 
  $
    &G(x,f(x)) = ln(f(x))-h(x) \
    &=> G_y (x,f(x)) = 1/(f(x)) 
  $
  即 
  $
    f_(2n) (x)& = f_n (x) - (ln(f_n (x)) - h(x))/( 1/(f_n (x))) pmod(x^(2n))\
    & = f_n (x) (1- ln(f_n (x)) + h(x)) pmod(x^(2n))
  $
]

==== 手写 NTT 板子

#note[
  大道至简 
  
  + 使用 ```cpp Poly = vector<LL>``` 
  + 使用 DIF - DIT 计算 NTT
  
  实现的功能

  + 普通多项式乘法
  + *多项式求逆*
  + *多项式开根(未接入二次剩余)*
  + ...
  + 常系数齐次线性递推

  代码见上面的 *NTT模数大全*
]

=== 多项式多点求值|牛顿插值

#note[
  代码见上面的 *NTT模数大全*
]

=== 多项式初等函数

#note[
  代码见上面的 *NTT模数大全*
]

=== 常系数齐次线性递推

#note[
  代码见上面的 *NTT模数大全*
]

=== 多项式平移|连续点值平移

#note[
  平移有两种
  + 系数平移: 顾名思义
  + (连续)点值平移: 拉格朗日插值公式维护连续 y 值
]

==== 多项式系数平移

#note[
  二项式定义为例进行证明 方便阐述
]

设 已知 $f(x)$ 的 $n+1$ 个系数 $(0,f_0), (1,f_1), (2,f_2)... (n,f_n)$ 

则 平移 $c$ 单位后

$ 
  f(x+c) 
  &= sum_(i=0)^n f_i (x+c)^i\
  &= sum_(i=0)^n f_i sum_(j=0)^i binom(i,j)x^j c^(i-j)\
  &= sum_(i=0)^n sum_(j=i)^n f_j binom(j,i) x^i c^(j-i)
$

用贡献法理解 

$
  [x^i] f(x+c) = sum_(j=i)^n f_j binom(j,i) c^(j-i)\
  ==>^"二项式展开"\
  [x^i] f(x+c) = sum_(j=0)^n f_j j! 1/(i!) (c^(j-i))/((j-i)!)\ 
  ==>^(x^i "只是个标识")\
  [x^i] f(x+c) i! = sum_(j=0)^n f_j j! (c^(j-i))/((j-i)!) 
$

设 $A_i = f_i i!, B_i = (c^i)/(i!), C_i = [x^i]f(x+c) i!$ 

则 
$
  C_i = sum A_j B_(j-i)  
$
这是 *减法卷积*

设 $A'_i = A_(n-i), H_i = sum A_j B_(i-j)$ 

则 

$
  C_i = sum A'_(n-j) B_(j-i) = sum A'_j B_((n-i)-j) = H_(n-i)
$

所以 

$
  C' = A' * B
$

代码实现如下(具体实现见 NTT模数大全):

```cpp
// 没有专业的测试
// 1 多项式 系数平移
// A_i = f_i * i! B_i = c^i/ i!
// C' = A' * B
// 我犯了两个错误:
// 1 把 f_i 系数当作点值了 
// 2 B_i 把除法fac写成乘法fac了 
Poly shift_coef(Poly F,LL c){
    c=(mod+c%mod)%mod;
    int n=F.size();
    vector<LL> B(n);
    LL pc = 1;
    for(int i=0;i<n;i++){
        F[i]=F[i]*fac[i]%mod;
        B[i]=pc*invfac[i]%mod;
        pc=pc*c%mod;
    }
    reverse(F.begin(),F.end());
    mul_to(F,B,n);
    reverse(F.begin(),F.end());
    // 别忘了除以阶乘
    for(int i=0;i<n;i++)tim(F[i],invfac[i]);
    return F;
}
```

==== 多项式连续点值平移 

#note[
  唯一定理: 拉格朗日插值公式
]

设 $f(x)$ 已知 $n+1$ 个连续点值为 $f(0), f(1), f(2), ... f(n)$ 

由拉格朗日插值公式 

平移 $m$ 个单位后, 第 $c$ 个点值为: 

$
  g(c) = f(m+c)
  & = sum_(i=0)^n f(i) product_(j!=i) (m+c-j)/(i-j)\
  & = sum_(i=0)^n f(i) ((m+c)!)/((m+c-i) (m+c-n-1)!) product_(j!=i) 1/(i-j)\
  & = sum_(i=0)^n f(i) ((m+c)!)/((m+c-i) (m+c-n-1)!) dot (-1)^(n-i)/((i-1)! (n-i)!)\
  & = ((m+c)!)/((m+c-n-1)!) sum_(i=0)^n (f(i) (-1)^(n-i))/((i-1)!(n-i)!) dot 1/(m+c-i)  
$

此时 $m$ 可以看作常量 真正的自变量为 $c$, 辅助变量为 $i$ 

设 $A_c = ((m+c)!)/((m+c-n-1)!), B_i = (f(i) (-1)^(n-i))/((i-1)!(n-i)!), C_i = 1/(m+i)$ 则上式可写为

$
  g_c = A_c sum B_i C_(c-i) 
$

可以看到 这里正是卷积形式

但是有一点

这里的 *下标问题*: $A_c, c in [0,n], B_i, i in [0,n], C_(c-i), c-i in [-n,n]$ 

$C$ 的下标为负数了 ! 

我们希望 使用 $C'_x$ 表示 $C_(x-n)$ 即设 $C'_i = C_(i-n) <=> C_i = C'_(i+n)$

故 

$
  g_c = A_c sum B_i C'_(c-i+n) 
$

设 $H_i = sum B_i C'_(i-j)$ 则 

$
  g_c = A_c H_(c+n) 
$

即将 $H$ 的下标 自减 $n$ 即可得到 $A$

最后考虑 $A,B,C$ 的计算复杂度 

+ $A_c$: $O(n)$ 的区间乘积 
+ $B_i$: $O(n)$ 的 $f(i)$ 映射
+ $C_i$: $O(n)$ 的线性逆元 

代码实现如下:

```cpp

```

=== 符号化方法

#note[
  神奇的生成函数递推 从现在开始
]

==== 一些定义

+ 中性类: 大小为 0 $E(z)=1$
+ 原子类: 大小为 1 $E(z)=z$

==== 集合的(不相交)并构造

$ A+B $

==== 集合的笛卡尔积构造

$ A times B $

==== 集合的 Seq 构造

$ "SEQ"(A) = 1/(1-A) $
$  Q(A(z)) = 1/(1-A(z)) $

==== 集合的 Mutiset 构造

$ "MSET"(A) $
$ "Ans"(x) = exp( sum_(i=1) A(x^i)/i) $

==== 集合的 Powerset 构造

$ "PSET"(A) $
$ "Ans"(x) = exp( sum_(i=1) (-1)^(i-1) A(x^i)/i) $

==== 集合的 Cycle 构造

$ "CYC"(A) $
$ "Ans"(A) = ln(1/(1-A)) $ 

==== 无序 构造 (Multiset 仅 $i=1$)

$ "SET"(A) $
$ "Ans"(A) = exp(A) $

==== 有限制的构造

$ "SEQ"_k : A(x)^k $
$ "SET"_k : A(x)^k $

=== Lagrange反演

#note[
  这是一种根据生成函数的性质 求解生成函数 第 $n$ 项或其经过某一函数得到的结果

  证明太繁琐，直接上小抄
]

==== 说结论

+ 列出 *DP/生成函数方案*

  - 努力变形为 $F(x) = x dot H(F(x))$ 形式 
  - 需要常数项为 $0$, 如果不为 $0$ 可以换元 $G(x) = F(x) - a_0$
+ *计算*

  + 如果求 $[x^n]F(x)$, 计算 $1/n [x^(n-1)]H(x)^n$
  + 如果求 $[x^n]A(F(x))$, 计算 $1/n [x^(n-1)](A'(x) dot H(x)^n)$
  
  - 计算 $H(x)^n$ 尝试使用多项式快速幂 (exp/ln)
  - 如果 $H(x)$ 是形如 $(1+x)^k,e^x$ 等简单函数, 直接使用数学推导 

  - 栗子($k$叉树计数/广义卡特兰数)
    $
      F(x) = x(1+F(x))^k ==> 1/n binom(k n,n-1)
    $ 
+ *提一嘴*

  事实上 
  $
    G(x) = x/H(x)\
    G(F(x)) = x \
    H(x) = x/G(x)\ 
    [x^n] F(x)^k = k/n [x^(n-k)] H(x)^n\ 
    [x^n] F(x)^k = k/n [x^(n-k)] (x/G(x))^n\ 
  $

==== 另类拉格朗日反演???

- $F(x)$ 中 $n_0=1$ 且 $G(F(x))=x$ 那么对于 $n,k in ZZ$

  $
    [x^n]F^k = [x^(-k-1)]G'G^(-n-1)\
    [x^n]H(F) = [x^n]H G' dot (x/G)^(n+1)
  $

=== 形式幂级复合|复合逆

#note[
  TO DO ! 形式幂集复合

  感觉没什么人写这个高效的板子，

  提示 F G 复合逆是相互的

  在实际应用中，你只需要记住这个“孤立 $x$”的过程：

  1.  *写出方程*
    
    比如 $A = x dot.c H(A)$。
  2.  *孤立 $x$*
     
    $x = A/H(A)$。
  3.  *确定“已知函数”*
  
    令 $F(t) = t/H(t)$。此时 $F$ 是 $A$ 的复合逆。
  4.  *开始推导*
  
    用 $F$ 的结构去算 $A$ 的系数。

]

=== 普通生成函数

普通生成函数（Ordinary Generating Function, OGF）是一种将无穷数列与形式幂级数关联起来的工具。它在组合数学、递推关系、概率论等领域有广泛应用。

==== 常见生成函数

以下是一些常见的数列及其对应的生成函数：

1. *单位序列*
   $ a = chevron.l 1, 1, 1, 1, dots chevron.r $
   $ F(x) = sum_(n >= 0) x^n = 1 / (1-x) $

2. *偶数索引序列*
   $ a = chevron.l 1, 0, 1, 0, dots chevron.r $
   $ F(x) = sum_(n >= 0) x^(2n) = 1 / (1-x^2) $

3. *等差数列*
   $ a = chevron.l a_0, a_0+d, a_0+2d, a_0+3d, dots chevron.r $
   $ F(x) = a_0 F{1} + d F{n} = a_0/(1-x) + d x/(1-x)^2  $

4. *二次函数*
   $ a = chevron.l 0, 1, 4, 9, dots chevron.r $
   $ F(x) = F{n^2} = (x(x+1))/(1-x)^2  $

5. *二项式系数序列*
  - (下增长二项式系数) 当 $a_n = binom(m, n)$ 时：
    $ F(x) = sum_(n >= 0) binom(m, n) x^n = (1+x)^m $
  - (双增长二项式系数) 当 $a_n = binom(m+n, n) = binom(m+n,m)$ 时：
    $ F(x) = sum_(n >= 0) binom(m+n, n) x^n = 1 / (1-x)^(m+1) $
  - (上增长二项式系数)
    $
      F{binom(n,k)} = x^k/(1-x)^(k+1) 
    $

==== 牛顿二项式定理

牛顿二项式定理是普通生成函数的重要理论基础之一，其形式如下：

$ (x+y)^alpha = sum_(n=0)^infinity binom(alpha, n) x^n y^(alpha-n) $

其中：
- $x$, $y$, $alpha$ 为实数；
- 要求满足 $|x/y| < 1$。

#note[
  其实就是 牛顿二项式把 二项式强行拆成的 阶乘 之后强行拆成了 下降幂 
]

#note(title:"trick!")[
  上指标反转

  这里的 $-x$ 自带的 $i$ 个 $-1$ 把 $-n$ 的长 $i$ 下降幂 改成了 $n$ 的长 $i$ 上升幂  
  $
    (1-x)^(-n)
     &= sum_(i=0)^inf binom(-n,i) (-x)^i \
     &= sum_(i=0)^inf binom(n+i-1,i) x^i 
  $
  这也揭示了 隔板法(n个无序元素分为i个可空有序集合)对应的生成函数
]

=== 指数生成函数 EGF

#note[
  TO DO !! 指数生成函数
  
  区别于 普通生成函数!!! 这个是针对有标号的 普通生成函数是无标号的 !!!

  这么理解 获取答案时假设 $h_i = sum binom(i,j) f_j * g_(i-j)$

  $
    f(j) = exp(dots.c) = dots.c 1/j! x^j dots.c \
    g(i-j) = exp(dots.c) = dots.c 1/(i-j)! x^(i-j) dots.c 
  $

  则 

  $
    Delta h(i) = Delta exp(dots.c) = dots.c Delta 1/i! x^i dots.c = 1/j! dot 1/(i-j)! x^(j+(i-j)) 
    \
    =>\
    Delta x^i = binom(i,j) f_j g_(i-j) x^i 
  $
]

== 组合数学

=== 排列组合

==== 加法 & 乘法原理

#note[略]

==== 排列数

$n$ 个元素选 $m$ 个 按照一定顺序排列
$ A_n^m = P_n^m = (n!) / ((n-m)!) $

==== 组合数

$ binom(n, m) = C_n^m = (A_n^m) / (m!) = (n!) / (m!(n-m)!) $

#note[PS: $A_n^m = binom(n, m) = 0, (m > n)$]

==== 隔板法

===== 正整数和的数目

#note[把 $n$ 个相同元素分为*非空* 的 $k$ 组的方案数]

$ binom(n-1, k-1) $

===== 非负整数和的数目

#note[把 $n$ 个相同元素分为*可空* 的 $k$ 组的方案数]

$ cases(n' = n+k, k' = k) arrow.r.double binom(n+k-1, k-1) = binom(n+k-1, n) $

===== 带限制的方程求解

#note[求解 $x_1 + x_2 + dots + x_k = n, (x_i >= a_i)$ （限制下限）]
$ binom(n - sum a_i + k - 1, k - 1) $

===== 不相邻的排列

#note[$[1, n]$ 的自然数种选择 $k$ 个，$k$ 个数两两不相邻的组合有：]

$ binom(n-k+1, k) $

==== 二项式定理

$ (a+b)^n = sum_(i=0)^n binom(n, i) a^(n-i) b^i $

===== 扩展

$ (x_1 + x_2 + dots + x_t)^n = sum_(n_1 + dots + n_t = n) binom(n, n_1, n_2, dots, n_t) x_1^(n_1) x_2^(n_2) dots x_t^(n_t) $

===== 性质

$ sum binom(n, n_1, n_2, dots, n_t) = t^n $

==== 进阶篇

===== 多重集的排列数/组合数
在元素种类数为 $k$ 的多重集 $S$ 中 $a_i$ 有 $n_i$ 个，多重集 $S$ 的全排列（*多重组合数*）个数为：

$ binom(n, n_1, n_2, dots, n_k) = (n!) / (product_(i=1)^k n_i!) = (n!) / (n_1! n_2! dots n_k!) $

===== 多重集的组合数 1
在元素种类数为 $k$ 的多重集 $S$ 中选择 $n, (n <= min(n_i))$ 个元素 作为新的多重集，不同的多重集种类数（*隔板法*）：

$ binom(n+k-1, k-1) $

===== 多重集的组合数 2

在元素种类数为 $k$ 的多重集 $S$ 中选择 $n, (n > min(n_i))$ 个元素 作为新的多重集，不同的多重集种类数（*隔板法+容斥原理*）

===== 圆排列

$ Q_n^n = (A_n^n) / n = (n-1)! $

===== 部分圆排列公式

$ Q_n^r = (A_n^r) / r = (n!) / (r times (n-r)!) $

==== 组合数性质 & 二项式推论

- $binom(n, m) = binom(n, n-m)$
- $binom(n, k) = n/k binom(n-1, k-1)$
- $binom(n, m) = binom(n-1, m) + binom(n-1, m-1)$
- $sum_(i=0)^n binom(n, i) = 2^n$
- $sum_(i=0)^n (-1)^i binom(n, i) = [n=0]$
- 范德蒙恒等式：$sum_(i=0)^k binom(n, i) binom(m, k-i) = binom(m+n, k)$
- $sum_(i=0)^n binom(n, i)^2 = binom(2n, n)$
- $sum_(i=0)^n i binom(n, i) = n 2^(n-1)$
- $sum_(i=0)^n i^2 binom(n, i) = n(n+1) 2^(n-2)$
- 朱世杰恒等式：$sum_(l=0)^n binom(l, k) = binom(n+1, k+1)$
- $binom(n, r) binom(r, k) = binom(n, k) binom(n-k, r-k)$
- $sum_(i=0)^n binom(n-i, i) = F_(i+1)$
- 李善兰恒等式：$binom(n+k, k)^2 = sum_(j=0)^k binom(k, j)^2 binom(n+2k-j, 2k)$

==== 二项式反演

$f_n$ 表示 恰好使用 $n$ 个不同元素形成特定结构的方案数，
$g_n$ 表示从 $n$ 个不同元素中选择 $i >= 0$ 个元素形成特定结构的总方案数。

===== 形式1

$f_n$ 表示 *恰好* $n$ 个/种的方案数量
$g_n$ 表示 *至多* $n$ 个/种的方案数量
$ g_n = sum_(i=0)^n binom(n, i) f_i arrow.r.double.long f_n = sum_(i=0)^n (-1)^(n-i) binom(n, i) g_i $

#note[
  例：*错排数* \
  $f_n$ 表示*恰好*有 $n$ 个位置错开 \
  $g_n$ 表示*至多*有 $n$ 个位置错开 \
  容易发现，$g_n$ 不就是长度为的排列任意打乱都符合约束吗？
]

===== 形式2

$f_k$ 表示 *恰好* $k$ 个/种的方案数量
$g_k$ 表示 *至少* $k$ 个/种的方案数量

$ g_k = sum_(i=k)^n binom(i, k) f_i arrow.r.double.long f_k = sum_(i=k)^n (-1)^(i-k) binom(i, k) g_i $

#note[
  *例*：设 $f_k$ 表示 $n$ 元排列中*恰好有 $k$ 个不动点*的方案数，$g_k$ 表示*至少有 $k$ 个不动点*（即存在某个大小为 $k$ 的不动点子集）的方案数。 则有 \
  $ g_k = binom(n, k)(n - k)! = sum_(i=k)^n binom(i, k) f_i $ \
  由二项式反演得 \
  $ f_k = sum_(i=k)^n (-1)^(i-k) binom(i, k) g_i = binom(n, k) D_(n-k) $ \
  其中 $D_m$ 是 $m$ 个元素的错排数。
]

=== 抽屉原理（鸽巢原理）

$n$ 个元素划分为 $k$ 个组那么至少有一个分组含有 $>= ceil(n/k)$ 个物品

#note[常被用于证明存在性证明和求最坏情况下的解。]

=== 容斥原理

==== 内容

求并集：奇加偶减

$ |union_(i=1)^n S_i| = sum_(m=1)^n (-1)^(m-1) sum_(a_i < a_(i+1)) |inter_(i=1)^m S_(a_i)| $

求交集：全集减去 补集的并

$ |inter_(i=1)^n S_i| = |U| - |union_(i=1)^n overline(S_i)| $

==== 用法

===== 例题0：带限制的不定方程非负整数解的计数：

#note[
  求解 $x_1 + x_2 + dots + x_k = n, (x_i <= b_i)$ （限制上限） \
  目标：所有变量满足限制的集合的大小 \
  $ |inter_(i=1)^n S_i| $ \
  对于每一种大小为 $k$ 的不合法集合并集 $S S_p = { overline(S_i) }, 1 <= p <= 2^n$ 情形 $a_(p, i) = { i | overline(S_i) in S S_p }$ ，的值为： \
  $ sum_(i=1)^n x_i = n - sum_(i=1)^k (b_(a_(p, i)) + 1) $ \
  答案为： \
  $ binom(n+k-1, k-1) - sum_(p=1)^(2^n-1) (-1)^("popcount"(p)+1) binom(n - sum_(i=1)^(|S S_p|) (b_(a_(p, i)) + 1) + k - 1, k - 1) $
]

===== 例题1：硬币购物

#note[
  $ sum_(i=1)^4 C_i x_i = S - sum_(i=1)^k C_(a_i) (D_(a_i) + 1) $ \
  套用完全背包的 $f_i$，每次计算不合法的情况即：使 $S$ 算上不合法的选择（减去），之后的方案数即为 $f_S$
]

===== 例题2：完全子图染色问题

#note[我们首先抽象出题目数学形式（新集合的定义，由非数集向数集的编号映射），然后从题目中信息量最大的条件，$F(S)$ 函数的定义入手，将其转化为集合的交并补。然后将式子转化为容斥原理的形式，并 *逆向推导* 出最终的结果。这道题体现的正是容斥原理的逆用。]

==== 数论中的容斥

1. 快速求解 $f(1), f(2), dots, f(N)$， $f(k) = sum_(1 <= x, y <= N) [(x, y) = k]$ \
容斥：$k$ 的所有倍数 - $i k$ 的解的个数，注意到 $k > N/2$ 时可以直接得到答案，故倒序递推，$O(N log N)$

$ f(k) = floor(N/k)^2 - sum_(i=2)^(i k <= N) f(i k) $

2. 推导欧拉函数

#note[见【筛法】]

==== 容斥原理一般化

对于两个集合的函数 $f(S), g(S)$ 若

$ f(S) = sum_(T subset.eq S) g(T) arrow.r.double g(S) = sum_(T subset.eq S) (-1)^(|S|-|T|) f(T) $

推论（补集形式）：

$ f(S) = sum_(S subset.eq T) g(T) arrow.r.double g(S) = sum_(S subset.eq T) (-1)^(|T|-|S|) f(T) $

#note[
  例题：DAG计数 \
  有 $n$ 个节点的 DAG 图 的数量 \
  计算复杂度 $O(n^3)$ \
  $ f[i] = sum_(j=1)^i (-1)^(j-1) binom(i, j) 2^((i-j)j) f[i-j] $
]

==== Min-Max 容斥

$ max_(i in S) x_i = sum_(T subset.eq S) (-1)^(|T|-1) min_(j in T) x_j $
$ min_(i in S) x_i = sum_(T subset.eq S) (-1)^(|T|-1) max_(j in T) x_j $

但是你可能觉得这个式子非常蠢，最大值明明可以直接求。之所以 min-max 容斥这么重要，是因为它在期望上也是成立的，即：

$ E(max_(i in S) x_i) = sum_(T subset.eq S) (-1)^(|T|-1) E(min_(j in T) x_j) $
$ E(min_(i in S) x_i) = sum_(T subset.eq S) (-1)^(|T|-1) E(max_(j in T) x_j) $

还有更强的：

$ "kthmax"_(i in S) x_i = sum_(T subset.eq S) (-1)^(|T|-k) binom(|T|-1, k-1) min_(j in T) x_j $
$ "kthmin"_(i in S) x_i = sum_(T subset.eq S) (-1)^(|T|-k) binom(|T|-1, k-1) max_(j in T) x_j $
$ E("kthmax"_(i in S) x_i) = sum_(T subset.eq S) (-1)^(|T|-k) binom(|T|-1, k-1) E(min_(j in T) x_j) $
$ E("kthmin"_(i in S) x_i) = sum_(T subset.eq S) (-1)^(|T|-k) binom(|T|-1, k-1) E(max_(j in T) x_j) $

根据 Min-Max 容斥可以得到：

#note[不明觉厉]

$ "lcm"_(i in S) x_i = product_(T subset.eq S) (gcd_(j in T) x_j)^((-1)^(|T|-1)) $

#note[例题：随机游走]

=== 斐波那契数列

==== 斐波那契数列

===== 递推

$ F_0 = 0, F_1 = 1, F_n = F_(n-1) + F_(n-2) $

===== 开首

$ 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, dots $

==== 卢卡斯数列

===== 递推

$ L_0 = 2, L_1 = 1, L_n = L_(n-1) + L_(n-2) $

===== 开首

$ 2, 1, 3, 4, 7, 11, 18, 29, 47, 76, 123, 199, dots $

==== 斐波那契通项公式

#note[
  $ F_n = ( ((1+sqrt(5))/2)^n - ((1-sqrt(5))/2)^n ) / sqrt(5) $ \
  $ F_n = [ ((1+sqrt(5))/2)^n / sqrt(5) ] $ \
  这里的中括号表示取离它最近的整数。结合模意义下二次剩余和逆元的概念，在 OI 中使用这个公式仍是有用的。
]

==== 卢卡斯数列通项公式

$ L_n = ((1+sqrt(5))/2)^n + ((1-sqrt(5))/2)^n $

$ L_n^2 - 5 F_n^2 = -4 $

==== 求法

===== 矩阵快速幂

$ mat(F_(n-1), F_n) = mat(F_(n-2), F_(n-1)) mat(0, 1; 1, 1) $

$ mat(F_n, F_(n+1)) = mat(0, 1) mat(0, 1; 1, 1)^n $

===== 快速倍增法

```cpp
pair<int, int> fib(int n) {// 返回 (F_n,F_{n+1})
  if (n == 0) return {0, 1};
  auto p = fib(n >> 1);
  int c = p.first * (2 * p.second - p.first);
  int d = p.first * p.first + p.second * p.second;
  if (n & 1)
    return {d, c + d};
  else
    return {c, d};
}
```

==== 性质

- $F_(n-1) F_(n+1) - F_n^2 = (-1)^n$
- $F_(n+k) = F_k F_(n+1) + F_(k-1) F_n$
- $F_(2n) = F_n (F_(n+1) + F_(n-1))$
- $F_k | F_(n k)$
- $F_a | F_b arrow.r.double.long a | b$
- $gcd(F_m, F_n) = F_(gcd(m, n))$
- 以斐波那契数列相邻两项作为输入会使欧几里德算法达到最坏复杂度

==== 斐波那契编码

#note[冷门]

==== 皮萨诺周期

#note[冷门]

=== 错位排列

错位排列（derangement）是没有任何元素出现在其有序位置的排列。

==== 开首

$ 0, 1, 2, 9, 44, 265, dots $

==== 递推

$ D_n = (n-1)(D_(n-1) + D_(n-2)) $

$ D_n = n D_(n-1) + (-1)^n $

==== 通项

$ D_n = n! sum_(k=0)^n ((-1)^k) / (k!) $

#note[PS：随着元素数量的增加，形成错位排列的概率 P 接近 $1/e$]

=== 卡特兰数

==== 开首

$ 1, 1, 2, 5, 14, 42, 132, 429, 1430, dots $

==== 递推

$ C_n = cases(1 & n=0, sum_(i=0)^(n-1) C_i C_(n-1-i) & n > 0) $

==== 通项

$ C_n = 1/(n+1) binom(2n, n) = ((2n)!) / (n! (n+1)!), n >= 0 $
$ C_n = binom(2n, n) - binom(2n, n+1), n >= 0 $
$ C_n = (4n-2)/(n+1) C_(n-1), n > 0, C_0 = 1 $

==== 应用

===== 路径计数问题

#note[从左下角开始，每次都只能向右或者向上走一单位，不走到对角线上方（但可以触碰）的情况下，到达右上角的路径总数为 $C_n$]

===== 圆内不相交弦计数问题

#note[圆上有个 $2n$ 点，将这些点成对连接起来且使得所得到的 $n$ 条线段两两不交的方案数是 $C_n$]

===== 三角剖分计数问题

#note[对角线不相交的情况下，将一个凸 $(n+2)$ 边形区域分成三角形区域的方法数为 $C_n$]

===== 二叉树计数问题

#note[含有 $n$ 个结点的形态不同的二叉树数目为 $C_n$ ，等价地，含有 $n$ 个非叶结点的形态不同的满二叉树数目为 $C_n$]

===== 括号序列计数问题

#note[由 $n$ 对括号构成的合法括号序列数为 $C_n$]

===== 出栈序列计数问题

#note[一个栈（无穷大）的进栈序列为 $1, 2, 3, dots, n$，合法出栈序列的数目为 $C_n$]

===== 数列计数问题

#note[由 $n$ 个 $+1$ 和 $n$ 个 $-1$ 组成的数列 $a_1, a_2, dots, a_(2n)$ 中，部分和满足 $a_1 + a_2 + dots + a_k >= 0$ $(k = 1, 2, 3, dots, 2n)$ 的数列数目为 $C_n$]

=== 斯特林数

==== 第二类斯特林数（斯特林子集数）

将 $n$ 个两两不同的元素，划分为 $k$ 个互不区分的非空子集的方案数。表示为 $St2(n,k)$

===== 递推

$ St2(n,k) = St2(n-1,k-1) + k St2(n-1,k), space St2(n,0) = [n=0] $

===== 通项

推导式:

$n$ 个不同的元素放在 $m$ 个不同的集合中的方案数 (这个公式非常重要)

$
  m^n = sum_(i=0)^m binom(m,i)  St2(n,i) i! 
$

二项式反演 $g_i = i^n , f_i = St2(n,i) i!$ :

$ 
  St2(n,m) m! =  sum_(i=0)^m binom(m,i) (-1)^(m-i) i^n \
$

故 

$
  St2(n,m) =  1/m!sum_(i=0)^m binom(m,i) (-1)^(m-i) i^n   
$

===== 同一行第二类斯特林数的计算

#note[
  TO DO !! 同一行第二类斯特林数的计算
]

===== 同一列第二类斯特林数的计算

#note[
  TO DO !! 同一列第二类斯特林数的计算
]

==== b.第一类斯特林数（斯特林轮换数）

将 $n$ 个两两不同的元素，划分为 $k$ 个互不区分的非空轮换的方案数。表示为 $St1(n,k)$ 

===== 递推

$ St1(n,k) = St1(n-1,k-1) + (n-1) St1(n-1,k), space St1(n,0) = [n=0] $

===== 通项

第一类斯特林数没有实用的通项公式。

===== 同一行第一类斯特林数的计算

#note[
  TO DO ! 同一行第一类斯特林数的计算
]

设 $F_n (x) = sum_(i=0)^n St1(n,i) x^i$

$ 
  F_n (x) = x^overline(n) = (x+n-1)!/(x-1)!
$

即 第二类斯特林数 同一行的生成函数 是 上升幂 

===== 同一列第一类斯特林数的计算

#note[
  TO DO ! 同一列第一类斯特林数的计算
]

$ 
  F(x) = sum_(i=1)^n ((i-1)!x^i)/i! = sum_(i=1)^n x^i/i  
$

$ 
  St1(i,k) = F(x)^k
$

===== 上升幂/下降幂 与 普通幂的转化

#note[
  TO DO ? 上升幂/下降幂 与 普通幂的转化

  记忆方法:

  + 升级的时候 带符号 (-1) 
  + 降级的时候 先一后二
]

上升幂 $=>$ 普通幂

$
  x^overline(n) = sum_k St1(n,k) x^k 
$

普通幂 $=>$ 上升幂

$
  x^n = sum_k St2(n,k) (-1)^(n-k) x^overline(k) 
$

下降幂 $=>$ 普通幂

$
  x^underline(n) = sum_k St1(n,k) (-1)^(n-k) x^k
$

普通幂 $=>$ 下降幂

$
  x^n = sum_k St2(n,k) x^underline(k)
$


===== 多项式下降阶乘幂表示与多项式点值表示的关系

#note[
  TO DO ? 多项式下降阶乘幂表示与多项式点值表示的关系
  
  多项式的另一种表示形式: 下降幂 

  好像听说
  
  + 普通多项式 与 连续点值之间的转换 是 $O(n log^2 n)$
  + 下降幂多项式 与 连续点值之间的转换是 $O(n log n)$ 的!

  这个骨头以后再啃
]

=== 贝尔数

$B_n$ 是基数为 $n$ 的集合的划分方法数目，集合 $S$ 的一个划分是定义为 $S$ 的两两不相交的非空子集的族，它们的并是 $S$ 。（人话：$n$ 个不同元素的所有分组方式）

==== 开首（$B_0=1$）

$ 1, 1, 2, 5, 15, 52, 203, dots $

==== 递推

$ B_(n+1) = sum_(k=0)^n binom(n, k) B_k $

==== 通项 (第二类斯特林数第 $n$ 行的和)

$ B_n = sum_(k=0)^n lr({ n; k }) $

==== 贝尔三角形

用以下方法构造一个三角矩阵（形式类似杨辉三角形）

```cpp
constexpr int MAXN = 2000 + 5;
int bell[MAXN][MAXN];
// B[i] = bell[i][0]
void f(int n) {
  bell[0][0] = 1;
  for (int i = 1; i <= n; i++) {
    bell[i][0] = bell[i - 1][i - 1];
    for (int j = 1; j <= i; j++)
      bell[i][j] = bell[i - 1][j - 1] + bell[i][j - 1];
  }
}
```

==== 贝尔数的指数生成函数

#note[
  TO DO ! 贝尔数的指数生成函数
]

$
  "EGF"(B(x)) = exp(e^x - 1)
$

即 

$
  B_n = n! [x^n] exp(e^x - 1)
$

=== 伯努利数

#note[略]

=== 恩特林格数

#note[略]

=== 欧拉数

#note[
  只有递推 简单的实现
]

==== 定义

表示 长度为 $n$ 的恰好有 $m$ 个 *相邻* *上升*对 的排列个数: $A(n,m)$ 

==== 公式

$ 
  A(n,m) = cases(
    0\,& m>n "or" n=0,
    1\,& m=0,
    (n-m)dot A(n-1,m-1) + (m+1) dot A(n-1,m)\, & "otherwise"
  )
$

==== 代码实现

```cpp
int eulerianNumber(int n, int m) {
  if (m >= n || n == 0) return 0;
  if (m == 0) return 1;
  return (((n - m) * eulerianNumber(n - 1, m - 1)) +
          ((m + 1) * eulerianNumber(n - 1, m)));
}
```

$$

=== 分拆数

==== 定义

$p_n$ 自然数 $n$ 的分拆方法数。

#note[
  将自然数 $n$ 写成递降正整数和的表示。 \
  $ n = r_1 + r_2 + dots + r_k, r_1 >= r_2 >= dots >= r_k >= 1 $ \
  和式中每个正整数称为一个部分。
]

==== 开首(自 0 开始)

$ 1, 1, 2, 3, 5, 7, 11, 15, 22, dots $

==== 生成函数

#note[
  没什么好看的
]

$
  P(x) = product_(i=1) 1/(1-x^i)
$

==== k 部分拆数

将 $n$ 分成恰有 $k$ 个部分的分拆，称为 $k$ 部分拆数，记作 $p(n, k)$ 

#note[
  显然，$k$ 部分拆数同时 也是 下面方程的解： \
  $ n - k = y_1 + y_2 + dots + y_k, y_1 >= y_2 >= dots >= y_k >= 0 $ \
  如果这个方程里面恰有 $j$ 个部分非 0 ，则恰有 $p(n-k, j)$ 个解，因此有： \
  $ p(n, k) = sum_(j=0)^k p(n-k, j) $ \
  相邻两个和式做差得： \
  $ p(n, k) = p(n-1, k-1) + p(n-k, k) $

  求解时 $p(0,0)=0$
]

===== Ferrers图

#note[得到结论]

显然，共轭是对称的关系．

最大 $k$ 分拆数：自然数 $n$ 的最大部分为 $k$ 的分拆个数

最大 $k$ 分拆数与 $k$ 部分拆数相同

==== 互异分拆数

自然数 $n$ 的各部分互不相同的分拆方法数（ $p d_n$ ）。

===== 开首（从 0 开始）

$ 1, 1, 1, 2, 2, 3, 4, 5, 6 $

==== 互异 k 部分拆数

将 $n$ 最大拆出 $k$ 个部分的互异分拆，记作 $p d(n, k)$

#note[
  表示是这个方程的解数： \
  $ n = r_1 + r_2 + dots + r_k, r_1 > r_2 > dots > r_k >= 1 $ \
  完全同上，也是这个方程的解数： \
  $ n - k = y_1 + y_2 + dots + y_k, y_1 > y_2 > dots > y_k >= 0 $ \
  这里与上面不同的是 由于互异，新方程中至多只有一个部分为零。有不变的结论： \
  恰有 $j$ 个部分非 0 ，则 恰有 $p d(n-k, j)$ 个解，这里 $j$ 只取 $k$ 或 $k-1$ ，因此直接得到递推：

  $ "pd"(n, k) = "pd"(n-k, k-1) + "pd"(n-k, k) $

  求解时 $"pd"(0,0)=1$
]

==== 奇分拆数

自然数 $n$ 的各个部分都是奇数的分拆方法数（ $"po"_n$ ）。

#note[奇分拆数和互异分拆数相同]

$ "po"_n = "pd"_n $

但显然 $k$ 部奇分拆数和互异 $k$ 部分拆数*不是一个概念*，这里就不列出了。

==== 五边形数定理

#note[
  说是彼欧拉函数的指数是五边形数 所以得到的 分拆数的递推长度是 $O(sqrt(n))$ 级别的 优化到了 $O(n sqrt(n))$ 
]

```cpp
// 五边形数定理计算 分拆数 p[i] 
long long a[100010];
long long p[50005];
void init() {
  	p[0] = 1;
  	p[1] = 1;
  	p[2] = 2;
  	int i;
	/*递推式系数1,2,5,7,12,15,22,26...i*(3*i-1)/2,i*(3*i+1)/2*/
    for (i = 1; i < 50005;i++) {
        a[2 * i] = i * (i * 3 - 1) / 2; /*五边形数为1,5,12,22...i*(3*i-1)/2*/
        a[2 * i + 1] = i * (i * 3 + 1) / 2;
    }
  	/*p[n]=p[n-1]+p[n-2]-p[n-5]-p[n-7]+p[12]+p[15]-...+p[n-i*[3i-1]/2]+p[n-i*[3i+1]/2]*/
    for (i = 3; i < 50005;i++){
        p[i] = 0;
        int j;
        for (j = 2; a[j] <= i; j++){
            if (j & 2) {
                p[i] = (p[i] + p[i - a[j]] + mod) % mod;
            } else {
                p[i] = (p[i] - p[i - a[j]] + mod) % mod;
            }
        }
    }
}
```

=== 范德蒙德卷积

==== 范德蒙德卷积公式

#note[
  很好理解 一共就选 $k$ 个, 你直接放一起选呗
]

$ sum_(i=0)^k binom(n, i) binom(m, k-i) = binom(n+m, k) $

==== 推论

#note[没得说, 硬换元]
$ sum_(i=-r)^s binom(n, r+i) binom(m, s-i) = binom(n+m, r+s) $
#note[卡特兰数, 快捷应用是吧]
$ sum_(i=1)^n binom(n, i) binom(n, i-1) = binom(2n, n-1) $
#note[越是简单, 越难记住]
$ sum_(i=0)^n binom(n, i)^2 = binom(2n, n) $
#note[给我整晕了, 其实 $n,m$ 轮换对称]
$ sum_(i=0)^m binom(n, i) binom(m, i) = binom(n+m, n) $

=== Pólya 计数

#note[
  TO DO ! Pólya 计数
  
  有两个定理

  需要详细的手动注释才能强行理解明白吧

  提到的概念:
  - 元素(单个排列)
  - 置换(对排列的一个操作, 单个为 $g$ 总数为 $|G|$) 
  - 方案(等价的排列, 这是计数的目标)
]

#note(title:"伯恩赛德引理 (Burnside's Lemma) —— 万能公式")[

- *公式*  
  
  $ N = 1/(|G|) sum_(g in G) |X^g| $

- *$|X^g|$ 的含义*
  
  在动作 $g$ 下，保持不变的*完整图案*有多少个？ (未显示乘法原理)

- *怎么用*
  
  你要盯着整个图案看。如果执行了动作 $g$，图案还是原来那个样子，它就是一个“不动点”。

- *缺点*
  
  当颜色多了、位置多了，你很难脑补出有多少个图案是不动的。

]
#note(title:"波利亚定理 (Polya Enumeration Theorem) —— 涂色快捷键")[
- *公式：* 
  
  $ N = 1/(|G|) sum_(g in G) m^(c(g)) $

- *$m$*
  
  颜色的种类数。

- *$c(g)$*
  
  动作 $g$ 作用在位置上时，形成的*循环（轮换）个数*。(同一轮换内的颜色一定相同)

- *怎么用*
  
  你不需要看图案，只需要看*位置的编号*是怎么变的。

- *优点*
  
  极其机械化，只要会数数就能算对。*（推荐初学者永远优先考虑这个）*
]

模板都要求会莫反 还是不会 QAQ

```cpp
// 模板 Polya 计数 
int phi(int n){
    int res=n;
    for(int i=2;i*i<=n;i++){
        if(n%i==0){
            res=res-res/i;
            while(n%i==0)n/=i;
        }
    }
    if(n>1)res=res-res/n;
    return res;
}
void solve(){
    int n;
    cin>>n;
    int ans=0;
    for(int i=1;i*i<=n;i++){
        if(n%i==0){
            ans=(ans+(LL)ksm(n,i)*phi(n/i))%mod;
            if(i!=n/i)
            ans=(ans+(LL)ksm(n,n/i)*phi(i))%mod;
        }
    }
    ans=(LL)ans*ksm(n,mod-2)%mod;
    cout<<ans<<"\n";
}
```

#note[
  后边的东西 硬骨头
]

=== 图论计数

#note[
  TO DO ? 图论计数
]

=== 有标号图计数（最常考）

*前提条件*：$n$ 个点互不相同（编号为 $1, 2, 3, dots, n$）。

==== 有标号的“任意图”

*问题*：$n$ 个点的有标号无向图有多少种？

*答案*：$2^((n(n-1))/2)$

*直观理解*：$n$ 个点之间总共有 $(n(n-1))/2$ 条潜在的边。每条边只有“有”或“没有”两种状态。

==== 有标号的“连通图”

*问题*：$n$ 个点组成的连通无向图有多少种？

*答案（递推式）*：
    设 $f(n)$ 是答案，$g(n) = 2^(n(n-1))/2)$（即上面的总数）。
    $ f(n) = g(n) - sum_(i=1)^(n-1) binom(n-1,i-1) f(i) g(n-i) $

*直观理解*：总数 - 不连通的数。不连通的情况通过“固定一个点所在的连通块大小为 $i$”来容斥。

==== 有标号的“树”（Cayley 公式）

*问题*：$n$ 个点的有标号树有多少种？

*答案*：$n^{n-2}$

*扩展*：如果问 $n$ 个点组成的*森林*（若干棵树），答案通常涉及 Prufer 序列。

==== 有标号的“有向无环图”（DAG）

*问题*：$n$ 个点的有标号 DAG 有多少种？

*答案（递推式）*：
    $ f(n) = sum_(i=1)^n (-1)^(i-1) binom(n,i) 2^(i(n-i)) f(n-i) $

*直观理解*：利用容斥原理，枚举有 $i$ 个点的入度为 0。

=== 给定一个具体的图，求生成树数量

*场景*：题目给你一张确定的图（有 $n$ 个点，$m$ 条边），求它的生成树个数。

==== 矩阵树定理 (Matrix Tree Theorem) —— 唯一的暴力工具

*步骤*：
    1.  写出*度数矩阵 $D$*：对角线上是每个点的度数，其余为 0。
    2.  写出*邻接矩阵 $A$*：$A_(i j)$ 是 $i$ 和 $j$ 之间的边数。
    3.  计算 *拉普拉斯矩阵 $L = D - A$*。
    4.  *最终答案*：去掉 $L$ 的任意一行和一列，剩下的 $(n-1) times (n-1)$ 矩阵的*行列式*。

*怎么算*：代码里跑一遍“高斯消元求行列式”模板。

=== 无标号图计数（最难，Polya 定理的应用）

*前提条件*：点和点之间没有编号，长得一样的图（同构）算同一种。

==== 无标号的“任意图”

*问题*：$n$ 个点的无标号图有多少种？

*答案*：需要使用*波利亚定理*。

*操作流程*：
    1.  找到点置换群（对称性）。
    2.  把点置换诱导成“边置换”。
    3.  公式：$1/n! sum_(p in S_n) 2^(c(e(p)))$。

*初学者注意*：这类题通常 $n$ 很小（比如 $n <= 60$），代码实现需要搜索“整数拆分”。

=== 总结——我该用哪个公式？

#table(columns:(auto,auto),
[*有标号、点不同*、任意连接 ],[$2^(binom(n,2))$ ],
[*有标号*、必须*连通* ],[容斥递推 或 多项式 $ln$ ],
[*有标号*、*树*],[$n^(n-2)$ ],
[*有标号*、*有向无环 (DAG)*  ],[容斥递推 ],
[*给了一张特定的图*、求生成树  ],[*矩阵树定理* (高斯消元) ],
[*无标号、点相同、旋转/翻转后相同*  ],[*波利亚定理 (Polya)* ],
)

=== 给初学者的特别建议：

1.  *先背 Cayley 公式* 
  
  ($n^(n-2)$)，这是最常考的结论。

2.  *学会矩阵树定理*
  
  因为它的代码实现最死板（就是高斯消元），只要模板写对就能得分。

3.  *不要纠结指数型生成函数 (EGF)*
  
  除非你已经熟练掌握了多项式求逆和多项式 $ln$。初学者用上面那个*递推式*写 $O(n^2)$ 的 DP 就能解决大部分有标号计数问题。

== 线性代数

=== 简介

#note[无]

=== 向量

==== 向量与矩阵

对 $n$ 维 *列向量* $x$ 定义变换 $T$ ，其中 $A$ 为 $m times n$ 阶矩阵

$ T(x) = A x $

===== 放缩变换 S

$ S = "diag"{v_1, v_2, dots, v_n} $

===== 旋转变换 R

1. 绕点（原点）（逆时针 $alpha$）（二维）：

$ R = mat(cos alpha, -sin alpha; sin alpha, cos alpha) $

2. 绕直线（$u = (u_x, u_y, u_z)$）（逆时针 $theta$）（过原点）（三维）

$ R = mat(
  u_x^2 (1 - cos theta) + cos theta, u_x u_y (1 - cos theta) - u_z sin theta, u_x u_z (1 - cos theta) + u_y sin theta;
  u_x u_y (1 - cos theta) + u_z sin theta, u_y^2 (1 - cos theta) + cos theta, u_y u_z (1 - cos theta) - u_x sin theta;
  u_x u_z (1 - cos theta) - u_y sin theta, u_y u_z (1 - cos theta) + u_x sin theta, u_z^2 (1 - cos theta) + cos theta
) $

===== 平移变换 T

#note[平移变换并非线性变换，而是仿射变换。但 $RR^n$ 下的仿射变换仍可以用 $RR^(n+1)$ 下的线性变换表示。]

考虑 $n$ 维向量 $alpha = (a_1, a_2, dots, a_n)$，现在要将其沿向量 $t = (t_1, t_2, dots, t_n)$ 平移，对 $alpha$ 添加一维并置为 $1$ ，得到新列向量 $alpha' = (a_1, a_2, dots, a_n, 1)$ 则变换矩阵可以 写作

$ T = mat(
  1, 0, dots, 0, t_1;
  0, 1, dots, 0, t_2;
  dots, dots, dots, dots, dots;
  0, 0, dots, 1, t_n;
  0, 0, dots, 0, 1
) $

对于其他线性变换矩阵，在矩阵中增加一列与一行，除右下角的元素为 1 外其它部分填充为 0 ，通过这种方法，所有的线性变换矩阵都可以转换为 *仿射变换矩阵* 。例如，对于二维向量旋转，变换矩阵可以变为

$ R' = mat(cos alpha, -sin alpha, 0; sin alpha, cos alpha, 0; 0, 0, 1) $

=== 内积外积

==== 混合积

$ V_("四面体"A B C D) = 1/6 |det(arrow(A B), arrow(A C), arrow(A D))| $

$ bold(a) bold(b) bold(c) "共面" quad arrow.l.r.double quad det(bold(a), bold(b), bold(c)) = 0 $

$ det(bold(a), bold(b), bold(c)) < 0 $ 等价于 $vec(a), vec(b), vec(c)$ 依序构成左手系。

$ det(bold(a), bold(b), bold(c)) > 0 $ 等价于 $vec(a), vec(b), vec(c)$ 依序构成右手系。

==== 二重外积

$ (bold(a) times bold(b)) dot (bold(a) times bold(b)) = |bold(a)|^2 |bold(b)|^2 - (bold(a) bold(b))^2 $

$ (bold(a) times bold(b)) times bold(c) = (bold(a) dot bold(c)) bold(b) - (bold(b) dot bold(c)) bold(a) $
$ bold(a) times (bold(b) times bold(c)) = (bold(a) dot bold(c)) bold(b) - (bold(a) dot bold(b)) bold(c) $

==== 拉格朗日的恒等式

$ (bold(a) times bold(b)) dot (bold(c) times bold(d)) = (bold(a) dot bold(c))(bold(b) dot bold(d)) - (bold(a) dot bold(d))(bold(b) dot bold(c)) $

=== 矩阵

==== 代码

```cpp
struct mat {
  LL a[sz][sz];
  mat() { memset(a, 0, sizeof a); }
  mat operator-(const mat& T) const {
    mat res;
    for (int i = 0; i < sz; ++i)
      for (int j = 0; j < sz; ++j) {
        res.a[i][j] = (a[i][j] - T.a[i][j]) % MOD;
      }
    return res;
  }
  mat operator+(const mat& T) const {
    mat res;
    for (int i = 0; i < sz; ++i)
      for (int j = 0; j < sz; ++j) {
        res.a[i][j] = (a[i][j] + T.a[i][j]) % MOD;
      }
    return res;
  }
  // 矩阵乘法优化
  mat operator*(const mat& T) const {
    mat res;
    int r;
    for (int i = 0; i < sz; ++i)
      for (int k = 0; k < sz; ++k) {
        r = a[i][k];
        for (int j = 0; j < sz; ++j)
          res.a[i][j] += T.a[k][j] * r, res.a[i][j] %= MOD;
      }
    return res;
  }
  mat operator^(LL x) const {
    mat res, bas;
    for (int i = 0; i < sz; ++i) res.a[i][i] = 1;
    for (int i = 0; i < sz; ++i)
      for (int j = 0; j < sz; ++j) bas.a[i][j] = a[i][j] % MOD;
    while (x) {
      if (x & 1) res = res * bas;
      bas = bas * bas;
      x >>= 1;
    }
    return res;
  }
};
```

==== 应用

- *矩阵加速递推*

#note[例子：斐波那契数列]

- *矩阵表达修改*

#note[例子：线段树维护叶子节点多个关联值]

$ mat(A, B, C, 1) mat(1, 0, 1, 0; 0, k, 0, 0; 0, 0, 1, 0; v, 0, 0, 1) = mat(A + v, B dot k, A + C, 1) $

- *定长路径统计*

- *定长最短路*

#note[路径数乘积 *改为* 边权加法取 min]

- *限长路径计数/最短路*

1. 求 边数 $<= k$ 的路径计数。
对于每一个点 $v$ 创建 *虚点* $v'$ ，并在图中加入 $(v, v')$ 和 $(v', v')$ 两条边。那么答案 $(u, v)$ 的答案就等于 $(u, v')$ 的长度为 $k+1$ 的答案。

2. 求 边数 $<= k$ 的最短路。
对于求边数小于等于 $k$ 的最短路，只需对每个点加一个边权为 0 的自环即可。

=== 初等变换

==== 倍加矩阵

#note[左乘：行 $k$，右乘：列 $k$]

=== 行列式

#note[
  使用高斯消元法求解 $O(n^3)$
]

=== 线性空间

#note[
  科普
]

==== 1. 数学定义

一个 *向量空间* $V$ 是关于标量域 $F$ 的集合，需满足：
- *加法封闭性*：$u, v in V => u + v in V$
- *数乘封闭性*：$a in F, v in V => a v in V$
- *八条公理*：交换律、结合律、单位元、逆元等。

==== 2. 核心概念

- *线性组合*：$v = sum a_i v_i$
- *线性相关*：存在不全为 0 的 $a_i$ 使得 $sum a_i v_i = bold(0)$。反之则为 *线性无关*。
- *生成子空间 (Span)*：向量组所有线性组合构成的集合。
- *基 (Basis)*：若 $B$ 线性无关且 $v p a n(B) = V$，则 $B$ 是 $V$ 的一个基。
- *维数 (Dimension)*：基中向量的个数，记作 $dim(V)$。

=== 线性基

#note[
  线性基分为两种构造方法

  - *贪心法* 构造的线性基具有如下性质：
    
    + 线性基没有异或和为 $0$ 的子集．
    + 线性基中各数二进制最高位不同．
  
  - *高斯消元法* 构造出的线性基满足如下性质：
    
    高斯消元后的矩阵是一个行简化阶梯形矩阵．
]

```cpp
#include<bits/stdc++.h>
using namespace std;

using LL = long long;
const int N = 63;
struct LB{
    LL B[N];
    int sz;
    bool zero;

    void init(){
        memset(B,0,sizeof B);
        sz=zero=0;
    }

    bool insert(LL x){
        for(int i=N-1;i>=0;i--){
            if(x>>i&1){
                if(B[i]>>i&1){
                    x^=B[i];
                }else {
                    // gauss 新增操作:
                    // 1 清除 x 的低位
                    for(int j=i-1;j>=0;j--)
                        if(x>>j&1&&B[j]>>j&1)x^=B[j];
                    // 2 用 x 清除高位
                    for(int j=i+1;j<N;j++)
                        if(B[j]>>i&1)B[j]^=x;
                    B[i]=x;
                    sz++;
                    return true;
                }
            }
        }
        zero=true;
        return false;
    }

    // 计算线性基得到的第 k 小(k>=1)的数字
    // 前提: 使用 gauss 优化
    LL get_kth(LL k){// AC
        if(k<=0)return -1;
        LL res=0;
        if(zero)k--;
        for(int i=0;k&&i<N;i++){
            if(B[i]>>i&1){
                if(k&1)res^=B[i];
                k>>=1;
            }
        }
        if(k)return -1;
        return res;
    }

    // gauss 消元后 直接异或全部即可
    LL get_max(){// AC
        if(!sz&&!zero)return -1;
        LL res=0;
        for(int i=0;i<N;i++)res^=B[i];
        return res;
    }
}B;
void solve(){
    int n,q;LL v;
    cin>>n;
    B.init();
    while(n--)cin>>v,B.insert(v);
    cout<<B.get_max()<<"\n";
    // cin>>q;
    // while(q--)cin>>v,cout<<B.get_kth(v)<<"\n";
}
int main(){
    cin.tie(0)->sync_with_stdio(0);
    int T=1,t=0;
    // cin>>T;
    while(T--){
        // cout<<"Case #"<<++t<<":\n";
        solve();
    }
}
```


==== 线性基求并集/交集

#note[
    复杂度都是 $O(n^2)$ (异或线性基) $O(n^3)$ (实数线性基) 

    + 求交集好说 一组线性基插入另一组线性基

    + 求并集的话 我找到了两种算法!
]

===== Fennec's Algorithm (异或线性基)

#note[
    Sooke!!!

    正交线性基(取反)算法 $O(n^2)$

    $overline(A)$
]

```cpp
// 线性基取反 
// Fennec's Algorithm
for (int i = n - 1; i >= 0; i--) {
    for (int j = i - 1; j >= 0; j--) {
        if (A[i] >> j & 1) { A[i] ^= A[j]; }
    }
}
for (int i = n - 1; i >= 0; i--) {
    if (A[i] == 0) {
        B[i] = 1 << i;
        for (int j = n - 1; j > i; j--) {
            if (A[j] >> i & 1) { B[i] |= 1 << j; }
        }
    }
}
```

可以用集合方式求解线性基的交集了!!!

$
  A inter B = overline(A union B)
$

===== Zassenhaus 算法

- 初始化一个向量长度为 $2n$ 的线性基 $gamma$ 为 空，其中的向量写成 $(a, b)$ 的形式，且 $a$ 和 $b$ 长度均为 $n$
- 将 $alpha$ 中的元素 $alpha_i$ 以 $(alpha_i, alpha_i)$ 的形式插入 $gamma$ 中；
- 将 $beta$ 中的元素 $beta_i$ 以 $(beta_i, 0)$ 的形式插入 $gamma$ 中；
- 最后得到的线性基 $gamma$ 中的所有非零元素 $(c_k, d_k)$ 中，$c_k$ 中的非零项构成并集，$c_k$ 为零项的 $d_k$ 构成了交集。

```cpp
#include <iostream>
#include <vector>

class LinearBasis {
  int K;
  std::vector<long long> a;

 public:
  LinearBasis(int K) : K(K), a(K) {}

  // Insert vector x.
  void insert(long long x) {
    for (int k = K - 1; ~k && x; --k) {
      if ((x >> k) & 1) {
        if (!a[k]) {
          a[k] = x;
        }
        x ^= a[k];
      }
    }
  }

  // Output those not exceeding 2^k.
  void print(int k) const {
    int sz = 0;
    for (int i = 0; i < k; ++i) {
      if (a[i]) {
        ++sz;
      }
    }
    std::cout << sz;
    for (int i = 0; i < k; ++i) {
      if (a[i]) {
        std::cout << ' ' << a[i];
      }
    }
    std::cout << '\n';
  }
};

int main() {
  constexpr int K = 30;
  int t;
  std::cin >> t;
  for (; t; --t) {
    LinearBasis c(K << 1);
    int n;
    std::cin >> n;
    for (; n; --n) {
      int x;
      std::cin >> x;
      c.insert(((long long)x << K) | x);
    }
    int m;
    std::cin >> m;
    for (; m; --m) {
      int x;
      std::cin >> x;
      c.insert((long long)x << K);
    }
    c.print(K);
  }
  return 0;
}
```

=== 线性映射

#note[
    略
]

=== 特征多项式

#note[
    TO DO ? 特征多项式

    估计还有 上海森堡矩阵 什么的
]

=== 对角化

#note[
    无人区
]

=== Jordan标准型

#note[
    无人区
]

== 线性规划 (Linear Programming)

#note[
    算法竞赛很少会出现只能用线性规划算法解决的问题，
    绝大多数这类问题可以通过网络流建模等方法更高效地解决．

    略
]

== 抽象代数

#note[
    略
]

== 概率论

=== 基本概念 / 条件概率与独立性 / 随机变量

#note[略]

=== 随机变量的数字特征

==== 条件期望

$E[X|Y]$ 一般是随机变量 $Y$ 的函数，且这个函数通常不是线性的。但实际上有 *全期望公式*：
$ E[E[X|Y]] = E X $

==== 方差

设随机变量 $X$ 的期望 $E X$ 存在且期望
$ E(X - E X)^2 $
也存在，则称上式的值为随机变量 $X$ 的方差，记作 $D X$ 或 $"Var"(X)$ ，方差的算术平方根称为 *标准差* ，记作 $sigma(X) = sqrt(D X)$

===== 性质

$ D(a X + b) = a^2 D(X) $
$ D X = E(X^2) - (E X)^2 $

=== 概率不等式

#note[
    扩展阅读
]

== 博弈论

=== 博弈论简介

#note[
    略
]

=== 公平组合游戏

==== SG理论

#note[
    TO DO ! 有时间可以想想SG
    
    + 如何快速打表 sg 值 
    + 如何在打表时快速求 mex 
    + 以及 正式代码中 mex 的求解方式 
]

==== 常见的公平游戏

#note[记点结论]

===== Bash

#note[
一堆石子, $n$ 个, 一次最多取 $k$ 个, 不能取者败
]

$ "sg"[n] = n mod (k+1) $

===== Nim

#note[
$n$ 堆石子, 每堆 $a_i$ 个, 一次从一堆中取任意个, 不能取者败
]

$ "sg" = sum_(xor) a[i] $

===== Nim-k

#note[允许一次性从 $k$ 个石子堆中取石子]

- 将原来的 2 进制 2 异或（无进位加法）变为 2 进制 $k+1$ 异或（无进位加法）

===== 阶梯Nim

#note[取走第 1 堆任意枚，或移动第 $i$ 堆的任意枚石子到第 $i-1$ 堆]

可能 

$ "sg"[i] = sum_(xor) a["奇数"] $

===== Fibonacci Nim

#note[第一个人不能取完，第二个人可以取不超过上一次的二倍]

- 斐波那契数必败

===== Wythoff

#note[从 $a_1, a_2$ 两堆中，选择一堆或两堆取相同数量的石子，不能取者败]

- 设 $a_1 <= a_2$，先手必败，当且仅当 $a_1 = floor((a_2 - a_1) phi)$，其中 $phi = (sqrt(5) + 1) / 2$

===== 翻硬币

#note[
硬币博弈最神奇的结论是：一个翻硬币游戏的总 SG 值，等于所有“背面朝上”的硬币单独存在时的 SG 值的异或和。

*硬币博弈学的是“拆解”：* 它告诉我们，看似互相干扰的多个硬币，其实可以拆成一个个独立的子游戏，用异或（Nim-sum）来解决。
]

===== 二分图博弈

#note[

这个博弈通常是这样的：两人轮流移动一个棋子，棋子不能经过重复的点，谁没地方走谁输。如果这个图是*二分图*

*二分图博弈学的是“结构”：* 它告诉我们，某些移动博弈的胜负不取决于你怎么走，而取决于这个图本身的数学结构（匹配）。

游戏先手必胜，当且仅当顶点 $v$ 是图 $G$ 的最大匹配关键点

求出二分图最大匹配关键点的算法详见 *二分图最大匹配页面*
]

===== 二分图博弈变体

#note[
  显然，这个变体相当于在前文所述二分图博弈中，让先手玩家选择初始局面，然后从后手玩家开始二分图博弈．因此，这个变体中，先手玩家必败，当且仅当每个顶点都是最大匹配关键点，亦即图 $G$ 存在 *完美匹配*．
]

==== 反常Nim

难道说??? 你要收集各种博弈题目???  

#note[共有 $n$ 堆石子，第 $i$ 堆有 $a_i$ 枚石子。两名玩家轮流取走任意一堆中的任意多枚石子，但不能不取。取走最后一枚石子的玩家失败。]

- 反常 Nim 游戏中，状态 $(a_1, a_2, dots, a_n)$ 是必败状态 $P$ ，当且仅当
  1. 存在 $i$ 使得 $a_i > 1$，且 $"Nim和" = 0$
  2. 对于所有 $i$ 都有 $a_i <= 1$ ，且剩余的非空石子堆数是奇数。

==== 有向图游戏

#note[
  有向图游戏的规则和其他的公平组合游戏大体一致：从起始状态出发，轮流沿着有向图的边移动一步，直到无路可走．根据游戏是正常规则还是反常规则，最后一个不能移动的玩家分别是败者和胜者．

  只需要采用类似 *拓扑排序* 的思路： $O(|V|+|E|)$
]

#note[
  后面给了好多习题 可以啃啃
]

=== 零和游戏

#note[
    新内容?
]

=== 非公平组合游戏

#note[
    空空如也
]

== 数值算法

=== 插值

==== Lagrange 插值法

===== 一般情况

$ f (x) = sum_(i=0)^(n) y_i product_(j != i) (x - x_j) / (x_i - x_j) $

- 时间 $O(n^2)$

#note[PS:可优化到 $O(n log n)$ 参见 *多项式快速插值*]

===== 横坐标是连续整数

对于 $f(0), f(1), dots, f(n)$

$ 
  f(x) &= sum_(i=0)^n y_i product_(j != i) (x - j) / (i - j) \
  &= sum_(i=0)^n (-1)^(n-i) y_i (product_(j=0)^n (x - j)) / (i! (n-i)! (x-i))\
  &= x!/(x-n-1)! sum_(i=0)^n  y_i dot ((-1)^(n-i))/(i! (n-i)!) dot 1/(x-i) \
  "or"\
  &= sum_(i=0)^n y_i (-1)^(n-i)/(i! (n-i)!) (product_(j=0)^(i-1) (x-j) product_(j=i+1)^n (x-j))\
  &= sum_(i=0)^n y_i (-1)^(n-i)/(i! (n-i)!) ("pre"_(i-1) dot "suf"_(i+1))
$

#note[
  求一个新点值的复杂度为 $O(n)$

  预处理
  
  + $A(x) = x!/(x-n-1)!$ $O(n)$ 
  + $B_i = y_i ((-1)^(n-i))/(i! (n-i)!)$ $O(n)$
  + $C_i = 1/i$ $O(n)$

  多个连续点值的复杂度为 $O(n log n)$ (多项式快速插值)

  + 首先观察到 $ f_x = A_x sum B_i C_(x-i) $ 
  + $B C$ 是一个和卷积 (注意换元防止负下标) $O(n log n)$ 得到所有
  + $A$ 是一个点值乘积 $O(n)$ 转移得到所有值

  PS: 最好还是使用 *or* 中的  pre - suf 方法 (什么??? 但是我没有想到一个用它来卷积的方法啊)
]

```cpp
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
```

==== Newton 插值法

#note[
    TO DO Newton 插值法

    大概就是 使用高阶差分 增量构造的多项式
]

=== 数值积分

==== 自适应辛普森

```cpp
double a,b,c,d,L,R;
double f(double x){
    return (c*x+d)/(a*x+b);// 实现函数
}
double simpson(double l, double r) {
  double mid = (l + r) / 2;
  return (r - l) * (f(l) + 4 * f(mid) + f(r)) / 6;  // 辛普森公式
}
double asr(double l, double r, double eps, double ans, int step) {
  double mid = (l + r) / 2;
  double fl = simpson(l, mid), fr = simpson(mid, r);
  if (abs(fl + fr - ans) <= 15 * eps && step < 0)
    return fl + fr + (fl + fr - ans) / 15;  // 足够相似的话就直接返回
  return asr(l, mid, eps / 2, fl, step - 1) +
         asr(mid, r, eps / 2, fr, step - 1);  // 否则分割成两段递归求解
}
double calc(double l, double r, double eps) {
  return asr(l, r, eps, simpson(l, r), 12);
}
int main(){
    cin>>a>>b>>c>>d>>L>>R;
    cout<<fixed<<setprecision(6)<<calc(L,R,1e-7);
}
```

=== 高斯消元

==== 高斯消元五步

1. 增广矩阵行初等行变换为行最简形；
2. 还原线性方程组；
3. 求解第一个变量；
4. 补充自由未知量；
5. 列表示方程组通解。

==== 高斯消元求行列式 det

#note[
  当前我实现了两种数值域的 det
]

```cpp
#define double long double
constexpr double EPS = 1E-12;
using LL = long long;
LL mod;
double calc_det(vector<vector<double>>& a){
    int n=a.size();
    double det = 1;
    for (int i = 0; i < n; ++i) {
        int k = i;
        for (int j = i + 1; j < n; ++j)
            if (abs(a[j][i]) > abs(a[k][i])) k = j;
        if (abs(a[k][i]) < EPS) {
            det = 0;
            break;
        }
        swap(a[i], a[k]);
        if (i != k) det = -det;
        det *= a[i][i];
        for (int j = i + 1; j < n; ++j) a[i][j] /= a[i][i];
        for (int j = 0; j < n; ++j)
            if (j != i && abs(a[j][i]) > EPS)
                for (int k = i + 1; k < n; ++k) a[j][k] -= a[i][k] * a[j][i];
    }
    return det;
}
// 使用辗转相减法 求任意模数行列式 
LL calc_det(vector<vector<LL>>& a){
    int n=a.size();
    LL det=1%mod;
    for(int i=0;i<n;i++){
        int k;
        for(k=i;k<n;k++)if(a[k][i])break;
        if(k==n)return 0;
        swap(a[k],a[i]);
        if(i!=k)det=(mod-det)%mod;
        for(int j=i+1;j<n;j++)
            // 辗转相减法!!!! 简单的加减不会引起行列式系数的变化!!!
            while(a[j][i]){
                LL t=a[i][i]/a[j][i];
                for(int k=i;k<n;k++)a[i][k]=(a[i][k]-a[j][k]*t%mod+mod)%mod;
                swap(a[i],a[j]);
                det=(mod-det)%mod;// 交换
            }
        det=det*a[i][i]%mod;// 最后得到特征值
    }
    return det;
}
int main(){
    int n;cin>>n>>mod;
    vector<vector<LL>> a(n,vector<LL>(n));
    for(int i=0;i<n;i++)for(int j=0;j<n;j++)cin>>a[i][j],a[i][j]%=mod;
    cout<<calc_det(a);// AC
}
```

==== 矩阵求逆

#note[
    求逆方法差点要忘了
]

给出 $n$ 阶方阵 $A$ ，求解其逆矩阵的方法如下：

1. 构造 $n times 2n$ 的矩阵 $(A, I_n)$
2. 用高斯消元法将其化简为最简形 $(I_n, A^(-1))$ ，即可得到 $A$ 的逆矩阵 $A^(-1)$ 。如果最终最简形的左半部分不是单位矩阵 $I_n$ ，则矩阵 $A$ 不可逆。

==== 高斯消元求解异或方程组

```cpp
std::bitset<1010> matrix[2010];  
// matrix[1~n]：增广矩阵，0 位置为常数
// n 为未知数个数，m 为方程个数，返回方程组的解
// （多解 / 无解返回一个空的 vector）
std::vector<bool> GaussElimination(int n, int m)  {
    for (int i = 1; i <= n; i++) {
        int cur = i;
        while (cur <= m && !matrix[cur].test(i)) cur++;
        if (cur > m) return std::vector<bool>(0);
        if (cur != i) swap(matrix[cur], matrix[i]);
        for (int j = 1; j <= m; j++)
            if (i != j && matrix[j].test(i)) matrix[j] ^= matrix[i];
    }
    std::vector<bool> ans(n + 1);
    for (int i = 1; i <= n; i++) ans[i] = matrix[i].test(0);
    return ans;
}
```

=== 牛顿迭代法

#note[
    就一个求根算法，没什么用
]

== 序理论

#note[
    TO DO ? 序理论
    
    只记住了
    - 最小链覆盖 等于 最长反链的长度
]

== 杨氏矩阵

#note[
    天书
]

== 拟阵

#note[
    跟抽象代数一桌
]

== Berlekamp-Massey 算法

#note[
    科普文章
]