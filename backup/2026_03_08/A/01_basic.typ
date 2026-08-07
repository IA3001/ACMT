#import "../lib.typ": *

= 算法基础

== 复杂度

#note[势能分析 均摊复杂度 主定理。]

== 枚举

#note[暴力 打表 找规律 诈骗]

== 模拟

#note[读题要细]

== 递归&分治

#note[模拟 博弈 搜索 DP]

== 贪心

#note[排序 优先队列 反悔]

== 排序（P1177）

=== 三傻（选择/冒泡/插入）

#note[真的傻]

=== 计数

- *stable*
- *时间* $O(n w)$
- *空间* $O(n + w)$

```cpp
constexpr int MAXN = 1010;
constexpr int MAXW = 100010;

int cnt[MAXW], b[MAXN];

// 纯纯的计数 
int* counting_sort(int* a, int n, int w) {
  memset(cnt, 0, sizeof(cnt));
  for (int i = 1; i <= n; ++i) ++cnt[a[i]];
  for (int i = 1; i <= w; ++i) cnt[i] += cnt[i - 1];
  for (int i = n; i >= 1; --i) b[cnt[a[i]]--] = a[i];
  return b;
}
```

=== 基数

- *stable*
- *时间* $O(k(n+w))$
- *空间* $O(n+w)$
- *k* 关键字个数 *w* 关键字大小
- *思想*：把值转化为串多级比较计数

```cpp
// LSD 基数排序
constexpr int N = 100010;
constexpr int W = 100010;
constexpr int K = 100;

int n, w, k, cnt[W];

struct Element {
  int key[K];
} a[N], b[N];

void counting_sort(int p) {
  memset(cnt, 0, sizeof(cnt));
  for (int i = 1; i <= n; ++i) ++cnt[a[i].key[p]];
  for (int i = 1; i <= w; ++i) cnt[i] += cnt[i - 1];
  // 为保证排序的稳定性，此处循环i应从n到1
  // 即当两元素关键字的值相同时，原先排在后面的元素在排序后仍应排在后面
  for (int i = n; i >= 1; --i) b[cnt[a[i].key[p]]--] = a[i];
  memcpy(a, b, sizeof(a));
}

void radix_sort() {
  for (int i = k; i >= 1; --i) {
    // 借助计数排序完成对关键字的排序
    counting_sort(i);
  }
}
```

=== 随机快排

- *unstable*
- *时间* $O(n log n)$
- *空间* $O(log n)$ (栈空间)

```cpp
const int N=2e6+5;// N:长度
int n,a[N];// n:长度 a[]:数组 (N 长度)
void quick_sort(int l,int r){
    if(l>=r)return;// Case0: 长度 <=1
    int x=a[l+rand()%(r-l+1)];// 随机选择一个中间是数作为中间段的值
    int cur=l,left=l-1,right=r+1;// cur:当前考虑 left:已知<x区(含) right:已知>x区(含)
    // 当 cur) 没有遇到 [right 时
    while(cur<right){ 
        if(a[cur]<x)// 小的数放在左边
            swap(a[cur++],a[++left]);
        else if(a[cur]>x)// 大的数放右边
            swap(a[cur],a[--right]);
        else cur++;// 等于的跳过，我只关心不等于的
    }
    quick_sort(l,left);
    quick_sort(right,r);
}
```

=== 归并

- *stable*
- *时间* $O(n log n)$
- *空间* $O(n)$

```cpp
const int N=2e6+5;// N:长度
int n,a[N],tmp[N];// n:长度 a[]:数组 tmp[]:缓存排序后的数组
void merge_sort(int l,int r){
    if(l>=r)return;// Case0:长度<=1
    int mid=(l+r)/2;// 二分
    merge_sort(l,mid);// 左边先有序
    merge_sort(mid+1,r);// 右边先有序
    int i=l,j=mid+1,k=0;// 原来是有序数组的合并！
    while(i<=mid&&j<=r){// 在均非空之前
        if(a[i]<=a[j])tmp[k++]=a[i++];// 小的先放
        else tmp[k++]=a[j++];// 小的先放
    }
    while(i<=mid)tmp[k++]=a[i++];// 剩余的
    while(j<=r)tmp[k++]=a[j++];// 剩余的
    memcpy(a+l,tmp,sizeof(a[0])*k);// 把这些都倒回 a 数组 l 位置开始
}
```

=== 堆排

- *unstable*
- *时间* $O(n log n)$
- *空间* $O(1)$

```cpp
// (1-base)的大根堆 排序时倒序输出 (<和STL的pq一致 可以封装一个手搓堆? 以后再说!)
const int N=2e6+5;// N:堆式数组的长度
int n,a[N];// n:元素个数 a[]:堆式数组 (N 长度) ()
void heapify(int i){
    int son=i,ls=2*i,rs=2*i+1;// son:下一个儿子(方便起见初始化为自己),ls:左儿子,rs:右儿子
    if(ls<=n&&a[son]<a[ls])son=ls;// 左儿子存在且 更大 
    if(rs<=n&&a[son]<a[rs])son=rs;// 又儿子存在且 更大 
    if(son!=i){// 真的有下一个儿子
        swap(a[i],a[son]);// 交换值
        heapify(son);// 败者受到重力而下去
    }
}
int pop(){
    swap(a[1],a[n--]);// 放到队尾丢弃掉即可
    heapify(1);// 相当于同时删掉首尾后插入尾
    return a[n+1];// 可以返回一下pop值
}
void heap_sort(){
    for(int i=n/2;i>=1;i--)heapify(i);// 从一半进行倒序插入即可 因为后一半未交换无意义
    while(n)pop();// 倒序输出
}
```

=== 桶排/希尔/锦标赛/Tim

#note[略。]

== 前缀和与差分

#note[
    *可以复原*：`+` `*` `^` \
    *不可以复原*：`|` `&` `gcd` `lcm`
]

=== 前缀和

==== 一维前缀和

- C++ 标准库中实现了前缀和函数 `std::partial_sum`，定义于头文件 `<numeric>` 中。

- 从 C++17 开始，标准库还提供了一个功能相同的前缀和函数 `std::inclusive_scan`，同样定义于头文件 `<numeric>` 中。

```cpp
int n;                // Array size.
std::vector<int> a;   // Array. (indexed from 1)
std::vector<int> ps;  // Prefix sum array.

// Calculate prefix sum.
void prefix_sum() {
    // 首元素原封不动
    std::partial_sum(a.begin(), a.end(), ps.begin(),[](int sum,int nxt){
        return sum+nxt;
    });
    
    // Or simply:
    ps = a;
    // for (int i = 1; i <= n; ++i) {
    //     ps[i] += ps[i - 1];
    // }
}

// Query sum of elements in [l, r].
int query(int l, int r) { return ps[r] - ps[l - 1]; }
```

==== 二维/多维前缀和

#note[有两种计算方式]

===== 基于容斥原理

```cpp
int n, m;
std::vector<std::vector<int>> a, ps;  // (n + 1) x (m + 1).

// Calculate the prefix sum of 2-d array.
void prefix_sum() {
  ps = a;
  for (int i = 1; i <= n; ++i)
    for (int j = 1; j <= m; ++j)
      ps[i][j] += ps[i - 1][j] + ps[i][j - 1] - ps[i - 1][j - 1] ;
}

// Find the sum of elements in submatrix [x1, y1] to [x2, y2].
int query(int x1, int y1, int x2, int y2) {
  return ps[x2][y2] - ps[x1 - 1][y2] - ps[x2][y1 - 1] + ps[x1 - 1][y1 - 1];
}
```

==== 逐维前缀和

- 类比积分理解

```cpp
// 二维前缀和
for(int i = 1; i <= n; i++)
    for(int j = 1; j <= n; j++)
        a[i][j] += a[i - 1][j];
for(int i = 1; i <= n; i++)
    for(int j = 1; j <= n; j++)
        a[i][j] += a[i][j - 1];
// 三维前缀和
for(int i = 1; i <= n; i++)
    for(int j = 1; j <= n; j++)
        for(int k = 1; k <= n; k++) 
            a[i][j][k] += a[i - 1][j][k];
for(int i = 1; i <= n; i++)
    for(int j = 1; j <= n; j++)
        for(int k = 1; k <= n; k++)
            a[i][j][k] += a[i][j - 1][k];
for(int i = 1; i <= n; i++)
    for(int j = 1; j <= n; j++)
        for(int k = 1; k <= n; k++)
            a[i][j][k] += a[i][j][k - 1];
```

===== 子集前缀和

+ 每一维的长度为 2   
+ 维数为 `n` ( `20` 左右) 就是 $O(n 2^n)$   
+ 前缀状态数(值域)为 `n` ( `1e6` 左右) 就是 $O(n log n)$  

在子集前缀和中，我们从一个集合出发，逐步“拆分”它的二进制位，找到所有可能的子集，并累加这些子集的值。换句话说，我们是从“完整集合”向“更小的子集”扩展。

```cpp
for (int j = 0; j < n; j++) 
    for (int i = 0; i < (1 << n); i++) 
        if (i >> j & 1) 
            f[i] += f[i ^ (1 << j)];
```

===== 超集前缀和

#note[子集和的 *逆操作* 需要通过 *容斥原理* 进行。子集和问题也是快速莫比乌斯变换的必要步骤之一。]

在超集前缀和中，我们从一个集合出发，逐步“添加”它的二进制位，找到所有可能的超集，并累加这些超集的值。换句话说，我们是从“较小集合”向“更大的超集”扩展。

```cpp
for (int j = 0; j < n; j++) 
    for (int i = 0; i < (1 << n); i++) 
        if (!(i >> j & 1)) 
            f[i] += f[i | (1 << j)];
```

==== 树上前缀和

===== 点权情形

- 自上而下的累积

$ S_x = S_("fa"[x]) + a_x $

$ S_(a b) = S_a + S_b - S_("lca"(a,b)) - S_("fa"["lca"(a,b)]) $

===== 边权情形

- 自上而下的累积

$ S_x = S_("fa"[x]) + a_x $

$ S_(a b) = S_a + S_b - 2 S_("lca"(a,b)) $

===== 子树和（默认是点权）

+ 自 *下* 而 *上* 计算的前缀和

$ T_x = a_x + sum_(y in "sons"(x))T_y $

=== 差分

==== 等差数列差分

```cpp
// 在 [l, r] 区间 添加首项为 s 末项为 e 公差为 d 的等差数列 
void add_arith(int l,int r,int s,int e,int d){
  a[l]+=s;
  a[l+1]+=d-s;
  a[r+1]+=-d-e;
  a[r+2]+=e;
}
// 最后查询：求两次前缀和即可 O(n)
```

==== a.一维差分 

+ C++ 标准库中实现了差分函数 `std::adjacent_difference`，定义于头文件 `<numeric>` 中。

```cpp
int a[] = {2,2,3,4,5};
int* b = new int[5];

// 首元素原封不动，不会作为cur 
adjacent_difference(a,a+5,b,[](int cur,int pre){
    return cur-pre;
});

for(int i=0;i<5;i++)cout<<b[i]<<", ";
// print: 2, 0, 1, 1, 1, 
```

==== 二维/多维差分

#note[基于容斥原理？？？]


#note[在子集前缀和代码中：只需将循环全部反向、加号变减号，即可做到高维差分。]

在子集和的 *逆操作* 中，我们也可以通过容斥公式来还原

$ a[i] = sum_(j subset.eq i) (-1)^(|i| - |j|) f[j] $

这里的  $|i|$ 和 $|j|$ 分别表示集合 $i$ 和 $j$ 的二进制表示中 1 的个数。

==== c.树上差分

准则：

+ *树操作*
    + 点 用 *链点* 差分 树头+=v 
    + 边 用 *链边* 差分 树头+=v （存子边，注意边的信息在父）
    + 最后求一次 *前缀和*

+ *链操作*
    + 链点 用 *树点* 差分 链端+=v fa[lca]-=2v
    + 链边 用 *树边* 差分 链端+=v lca-=2v （存父边，注意边的信息在子）
    + 最后求一次 *子树和*


== 二分

=== 二分（二分查找 & 二分答案）

#note[二分一般用 `lower_bound` 和 `upper_bound` ，除非 check(m) ]

=== 三分

- 用于单峰函数求极值  
- 时间 $O(log n)$



```cpp
/* 基础三分 */
const double eps=1e-10;
double cal(double l,double r){
    // 注意这里l r 范围要大于 lm rm 范围
    while(r-l>eps){
        double mid=(l+r)/2;
        double lm=mid-eps,rm=mid+eps;
        if(f(lm)>f(rm)){// 找峰用< 谷用 > 总结：这一点的导数是风向标
            l=mid;// 注意这里用mid
        }else {
            r=mid;// 注意这里用mid
        }
    }
    return (l+r)/2;
}
/* 优化黄金三分 0.618 lm,rm两点比较靠中间 */
const double gd=(sqrt(5)-1)/2;
double gold_cal(double l,double r){
    double lm=l*gd+r*(1-gd),rm=l*(1-gd)+r*gd;
    double lv=f(lm),rv=f(rm);
    while(r-l>eps){
        if(lv>rv){// 峰用< 谷用 > 总结：这一点的导数是风向标
            l=lm;lm=rm;lv=rv;
            rm=l*(1-gd)+r*gd;
            rv=f(rm);
        }else {
            r=rm;rm=lm;rv=lv;
           	lm=l*gd+r*(1-gd);
            lv=f(lm);
        }
    }
    return (l+r)/2;
}
```

== 倍增

- 倍增应用
    1. RMQ : 见【ST表】
    2. 树上倍增 : 见【最近公共祖先】

== 构造

#note[无通法  ]

*思想* 见附录