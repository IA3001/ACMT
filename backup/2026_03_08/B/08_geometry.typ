
#import "../lib.typ": *

= 计算几何

#note[同样可以借助外部资料]

== 二维计算几何基础

#note[
    TO DO !! 2D板子
]

```cpp
#include<bits/stdc++.h>
using namespace std;
using DB = double;

DB eps = 1e-12,PI=acos(-1);
const DB inf=1e12;

// 【必备】符号函数
inline int sign(DB x){
    if(x>eps)return 1;
    else if(x<-eps)return -1;
    else return 0;
}

// 【必备】向量/点
struct Vec{// 向量/坐标
    DB x,y;
    Vec(DB xx=0,DB yy=0):x(xx),y(yy){}
    Vec operator+(Vec o)const {return Vec(x+o.x,y+o.y);}
    Vec operator-(Vec o)const {return Vec(x-o.x,y-o.y);}
    Vec operator*(DB k){return Vec(x*k,y*k);}
    DB operator%(Vec o)const {return x*o.y-y*o.x;}
    friend ostream& operator<<(ostream& os,Vec o){
        return os<<"Vec("<<o.x<<","<<o.y<<")";
    }   
};

// 【常用】（在线计算）两点距离
DB dist(Vec A,Vec B){
    return sqrt(pow(A.x-B.x,2)+pow(A.y-B.y,2));
}

//  【】旋转向量 WC 旋转矩阵是左乘的啊
Vec rotate(Vec A,DB t){
    DB S = sin(t),C=cos(t);
    return Vec(A.x*C-A.y*S,A.x*S+A.y*C);
}

// 【常用】有向线段/有向直线
struct Seg{// 有向线段/有向直线
    Vec s,t,v;
    Seg(){}
    Seg(Vec ss,Vec tt):s(ss),t(tt),v(tt-ss){}// 两点式
    friend ostream& operator<<(ostream& os,Seg o){
        return os<<"["<<o.s<<" -> "<<o.t<<"]";
    }
};

// 【常用】求直线交点 要先保证 不平行 
Vec inter(Seg A,Seg B){
    Vec u = A.s-B.s;
    return A.s + A.v*((B.v%u)/(A.v%B.v));
}

// 【】圆
struct Circle{
    Vec o;
    DB r;
    Circle(){}
    Circle(Vec oo,DB rr):o(oo),r(rr){}
    Circle(Vec A,Vec B){
        // 两点确定一个直径
        o = (A+B)*0.5;
        r = dist(A,B)*0.5;
    }
    Circle(Vec A,Vec B,Vec C){
        // 三点确定一个圆
        Vec m_AB = (A+B)*0.5;
        Seg v_AB(m_AB,m_AB+rotate(B-A,PI/2));
        Vec m_AC = (A+C)*0.5;
        Seg v_AC(m_AC,m_AC+rotate(C-A,PI/2));
        o = inter(v_AB,v_AC);
        r = dist(o,A);
    }
};

// 【】圆-点关系 (距离-半径 的符号)
int circle_point(Circle O,Vec A){
    return sign(dist(O.o,A)-O.r);
}

// 一些扩展:

/* 1.缺失的向量运算（补在 Vec 结构体外或内均可）*/

// 【必备】点积
DB dot(Vec A, Vec B) {
    return A.x * B.x + A.y * B.y;
}

// 【必备】向量模长/模长平方
DB len(Vec A) { return sqrt(dot(A, A)); }
DB len2(Vec A) { return dot(A, A); }

// 【常用】向量夹角 (rad)
DB angle(Vec A, Vec B) {
    return acos(dot(A, B) / len(A) / len(B));
}

/* 2.点与线的位置关系 */

// 【常用】判断点 P 是否在线段 L 上 (含端点)
// 1. 叉积为0 (共线) 2. 点积<=0 (夹在中间)
bool on_seg(Vec P, Seg L) {
    Vec u = L.s - P, v = L.t - P;
    return sign(u % v) == 0 && sign(dot(u, v)) <= 0;
}

// 【常用】点 P 到直线 L 的距离 (利用叉积=面积=底*高)
DB dist_to_line(Vec P, Seg L) {
    return fabs((P - L.s) % L.v) / len(L.v);
}

// 【常用】点 P 到线段 L 的距离
DB dist_to_seg(Vec P, Seg L) {
    if (L.s.x == L.t.x && L.s.y == L.t.y) return dist(P, L.s); // 端点重合
    // 利用点积判断投影点是否在线段外
    // 向量 L.v 与 P-L.s 的夹角 > 90度 -> 距离为 P 到起点
    if (sign(dot(P - L.s, L.v)) < 0) return dist(P, L.s);
    // 向量 -L.v 与 P-L.t 的夹角 > 90度 -> 距离为 P 到终点
    if (sign(dot(P - L.t, L.s - L.t)) < 0) return dist(P, L.t);
    // 否则为点到直线的距离
    return dist_to_line(P, L);
}

// 【常用】点 P 在直线 L 上的投影点
Vec project(Vec P, Seg L) {
    return L.s + L.v * (dot(P - L.s, L.v) / len2(L.v));
}

/* 3. 多边形相关 */

// 【常用】多边形面积 (有向面积，逆时针为正)
// 传入点集 p，需要保证 p[0] == p[n] 或者循环处理
DB polygon_area(const vector<Vec>& p) {
    DB res = 0;
    for (int i = 0; i < p.size() - 1; ++i) {
        res += p[i] % p[i+1];
    }
    return res * 0.5;
}

// 【必备】求凸包 (Andrew 算法)
// 需要先重载 Vec 的 operator<
bool operator<(const Vec& a, const Vec& b) {
    return sign(a.x - b.x) == 0 ? a.y < b.y : a.x < b.x;
}

// 输入点集 p，返回凸包点集 (按逆时针顺序)
vector<Vec> convex_hull(vector<Vec> p) {
    int n = p.size(), k = 0;
    if (n <= 2) return p;
    sort(p.begin(), p.end());
    vector<Vec> ch(2 * n);
    // 下凸壳
    for (int i = 0; i < n; ++i) {
        while (k > 1 && sign((ch[k-1] - ch[k-2]) % (p[i] - ch[k-1])) <= 0) k--;
        ch[k++] = p[i];
    }
    // 上凸壳
    for (int i = n - 2, t = k; i >= 0; --i) {
        while (k > t && sign((ch[k-1] - ch[k-2]) % (p[i] - ch[k-1])) <= 0) k--;
        ch[k++] = p[i];
    }
    ch.resize(k - 1); // 移除重复的起点
    return ch;
}
```

== 三维计算几何基础

#note[
    TO DO !! 3D板子 

    1.  *叉积方向*：3D 叉积 `A % B` 服从右手定则，大拇指指向结果向量方向。
    2.  *点法式平面*：平面的法向量 `n` 通常在构造时归一化（模长为1），这样计算点到平面距离时，分母可以直接省略。
    3.  *三点定面*：`Plane(A, B, C)` 中点的顺序决定了法向量的朝向（正面/反面），顺序反了法向量会反向。
]

```cpp
#include<bits/stdc++.h>
using namespace std;
using DB = double;
DB eps = 1e-12,PI=acos(-1);
const DB inf=1e12;

// 【必备】符号函数
inline int sign(DB x){
    if(x>eps)return 1;
    else if(x<-eps)return -1;
    else return 0;
}

// *****************

// 放在 2D 板子后面，部分常量公用
struct Vec3 {
    DB x, y, z;
    Vec3(DB xx=0, DB yy=0, DB zz=0) : x(xx), y(yy), z(zz) {}
    Vec3 operator+(Vec3 o) const { return Vec3(x+o.x, y+o.y, z+o.z); }
    Vec3 operator-(Vec3 o) const { return Vec3(x-o.x, y-o.y, z-o.z); }
    Vec3 operator*(DB k) const { return Vec3(x*k, y*k, z*k); }
    Vec3 operator/(DB k) const { return Vec3(x/k, y/k, z/k); }
    
    // 【区别】3D 叉积返回向量 (法向量)
    Vec3 operator%(Vec3 o) const {
        return Vec3(y*o.z - z*o.y, z*o.x - x*o.z, x*o.y - y*o.x);
    }
    DB len2() const { return x*x + y*y + z*z; }
    DB len() const { return sqrt(len2()); }
    // 归一化
    Vec3 unit() const { return *this / len(); }
    
    friend ostream& operator<<(ostream& os, Vec3 o) {
        return os << "Vec3(" << o.x << "," << o.y << "," << o.z << ")";
    }
};

// 【必备】点积 (3D中求投影、夹角必备)
DB dot(Vec3 A, Vec3 B) {
    return A.x*B.x + A.y*B.y + A.z*B.z;
}

// 【常用】两点距离
DB dist(Vec3 A, Vec3 B) {
    return (A-B).len();
}

// 【常用】3D 空间直线
struct Line3 {
    Vec3 s, t, v; // 起点, 终点, 方向向量
    Line3() {}
    Line3(Vec3 ss, Vec3 tt) : s(ss), t(tt), v(tt-ss) {}
};

// 【常用】平面 (点法式：经过点 p，法向量 n)
struct Plane {
    Vec3 p, n; 
    Plane() {}
    Plane(Vec3 pp, Vec3 nn) : p(pp), n(nn.unit()) {} // 构造时自动归一化法向量
    
    // 【构造】三点确定平面 (右手定则决定法向量方向)
    Plane(Vec3 A, Vec3 B, Vec3 C) {
        p = A;
        n = ((B-A) % (C-A)).unit();
    }
};

// 【算法】点到平面的距离 (有向距离，根据正负判断在平面哪一侧)
DB dist_point_plane(Vec3 A, Plane P) {
    // 投影公式: (A-P.p) 在 n 上的投影
    return dot(A - P.p, P.n); 
}

// 【算法】点到平面的投影点
Vec3 proj_point_plane(Vec3 A, Plane P) {
    return A - P.n * dist_point_plane(A, P);
}

// 【算法】直线与平面交点
// 前置条件：直线与平面不平行 (dot(L.v, P.n) != 0)
Vec3 inter_line_plane(Line3 L, Plane P) {
    DB d1 = dot(P.n, P.p - L.s);
    DB d2 = dot(P.n, L.v);
    if (sign(d2) == 0) return Vec3(inf, inf, inf); // 平行
    return L.s + L.v * (d1 / d2);
}

// 【算法】点到直线的距离
DB dist_point_line(Vec3 A, Line3 L) {
    return ((A - L.s) % L.v).len() / L.v.len();
}

// 【进阶】罗德里格斯旋转公式
// 将向量 A 绕轴 axis (单位向量) 旋转 angle 弧度 (右手螺旋)
Vec3 rotate_axis(Vec3 A, Vec3 axis, DB angle) {
    DB C = cos(angle), S = sin(angle);
    return A * C + axis * (dot(axis, A) * (1 - C)) + (axis % A) * S;
}

// 扩展 扩展 扩展

/* 1. 混合积与体积（3D 几何的核心） */

// 【必备】混合积 (A x B) · C
// 几何意义：以 A, B, C 为三条邻边的平行六面体的 有向体积
DB mix(Vec3 A, Vec3 B, Vec3 C) {
    return dot(A % B, C);
}

// 【必备】四面体体积 (四个点 A,B,C,D)
// 也就是 1/6 的平行六面体体积
DB volume(Vec3 A, Vec3 B, Vec3 C, Vec3 D) {
    return abs(mix(B-A, C-A, D-A)) / 6.0;
}

// 【常用】空间三角形面积 (三个点 A,B,C)
// 叉积模长的一半
DB area(Vec3 A, Vec3 B, Vec3 C) {
    return ((B - A) % (C - A)).len() * 0.5;
}

/* 2. 异面直线距离（线与线的关系） */

// 【进阶】两异面直线距离
// L1: s1->t1, L2: s2->t2
DB dist_line_line(Line3 L1, Line3 L2) {
    Vec3 n = L1.v % L2.v; // 公垂向量
    if (sign(n.len()) == 0) {
        // 平行线，转化为点到直线距离
        return dist_point_line(L1.s, L2); 
    }
    // 投影公式：连线向量在公垂向量上的投影
    return abs(dot(L1.s - L2.s, n)) / n.len();
}

/* 3. 点关于平面的对称点 / 投影点 */

// 【常用】点 A 在平面 P 上的投影点
Vec3 project_on_plane(Vec3 A, Plane P) {
    // P.n 必须已经归一化
    return A - P.n * dot(A - P.p, P.n);
}

// 【常用】点 A 关于平面 P 的对称点 (镜像点)
Vec3 reflect_by_plane(Vec3 A, Plane P) {
    // 距离平面 double 的距离
    return A - P.n * (dot(A - P.p, P.n) * 2.0);
}

/* 4. 球与直线的交点（3D 碰撞检测基础） */

// 【进阶】直线与球的交点
// 球心 O, 半径 r, 直线 L
// 返回交点个数, 交点存在 res 数组中
int inter_line_sphere(Vec3 O, DB r, Line3 L, vector<Vec3>& res) {
    // 转化为解一元二次方程 at^2 + bt + c = 0
    // 设点 P = L.s + t * L.v
    // |P - O|^2 = r^2
    DB a = L.v.len2();
    DB b = 2 * dot(L.v, L.s - O);
    DB c = (L.s - O).len2() - r * r;
    DB delta = b * b - 4 * a * c;
    
    if (sign(delta) < 0) return 0;
    if (sign(delta) == 0) {
        DB t = -b / (2 * a);
        res.push_back(L.s + L.v * t);
        return 1;
    }
    DB t1 = (-b - sqrt(delta)) / (2 * a);
    DB t2 = (-b + sqrt(delta)) / (2 * a);
    res.push_back(L.s + L.v * t1);
    res.push_back(L.s + L.v * t2);
    return 2;
}
```

== 距离

=== 曼哈顿 & 切比雪夫

- 将一个点 $ (x, y) $ 的坐标变为 $ (x+y, x-y) $ 后
  - 原曼哈顿距离 = 新切比雪夫距离

- 将一个点 $ (x, y) $ 的坐标变为 $ ( (x+y)/2, (x-y)/2 ) $ 后
  - 原切比雪夫距离 = 新曼哈顿距离

== Pick定理

对于一个顶点都是整点的简单多边形：

- 令 $I$ 为多边形内部的整点数量，$B$ 为多边形形上的整点数量，$A$ 为多边形面积。有公式：

$ A = I + B/2 - 1 $

- 取格点的组成图形的面积为一单位。在平行四边形格点，皮克定理依然成立。套用于任意三角形格点，皮克定理则是

$ A = 2i + B - 2 $

== 三角剖分

#note[
    TO DO ? 三角剖分
]

== 凸包

#note[
    TO DO !! 凸包
    
    + 安卓算法
    + 闵可夫斯基和
    + 三维凸包 吓哭了
]

=== Andrew

```cpp
#include<bits/stdc++.h>
using namespace std;
struct Point{
    double x,y;
    Point(double x=0,double y=0):x(x),y(y){}
    bool operator<(const Point& o)const {return x!=o.x?x<o.x:y<o.y;}
    double operator^(const Point o)const {return x*o.y-y*o.x;}
    Point operator-(const Point o)const {return Point(x-o.x,y-o.y);}
};
double cross(Point a,Point b,Point c){
    return (b-a)^(c-a);
}
double dist(Point a,Point b){
    return sqrt(pow(a.x-b.x,2)+pow(a.y-b.y,2));
}
const int N=1e5+5;
int n;
Point p[N];
int s[N];
int tp;
void solve(){
    cin>>n;
    for(int i=1;i<=n;i++)cin>>p[i].x>>p[i].y;
    sort(p+1,p+1+n);
    // [1,n] 维持左转 
    for(int i=1;i<=n;i++){
        while(tp>1&&cross(p[s[tp-1]],p[s[tp]],p[i])<=0)tp--;
        s[++tp]=i;
    }
    int t=tp;
    // [n-1..1] 维持左转
    for(int i=n-1;i>=1;i--){
        while(tp>t&&cross(p[s[tp-1]],p[s[tp]],p[i])<=0)tp--;
        s[++tp]=i;
    }
    double res=0;
    for(int i=1;i<tp;i++)res+=dist(p[s[i]],p[s[i+1]]);
    cout<<res<<'\n';
}
signed main(){
    cout<<setprecision(2)<<fixed;
    solve();
    return 0;
}
```

=== 凸包 的 闵可夫斯基和

#note[
    点集 $P$ 和点集 $Q$ 的闵可夫斯基和 $P+Q$ 定义为 $P+Q=\{a+b|a in P,b in Q\}$，即把点集 $Q$ 中的每个点看做一个向量，将点集 $P$ 中每个点沿这些向量平移，最终得到的结果的集合
]

```cpp
template <class T>
struct Point {
  T x, y;

  Point(T x = 0, T y = 0) : x(x), y(y) {}

  friend Point operator+(const Point &a, const Point &b) {
    return {a.x + b.x, a.y + b.y};
  }

  friend Point operator-(const Point &a, const Point &b) {
    return {a.x - b.x, a.y - b.y};
  }

  // 点乘
  friend T operator*(const Point &a, const Point &b) {
    return a.x * b.x + a.y * b.y;
  }

  // 叉乘
  friend T operator^(const Point &a, const Point &b) {
    return a.x * b.y - a.y * b.x;
  }
};

template <class T>
vector<Point<T>> minkowski_sum(vector<Point<T>> a, vector<Point<T>> b) {
  vector<Point<T>> c{a[0] + b[0]};
  for (usz i = 0; i + 1 < a.size(); ++i) a[i] = a[i + 1] - a[i];
  for (usz i = 0; i + 1 < b.size(); ++i) b[i] = b[i + 1] - b[i];
  a.pop_back(), b.pop_back();
  c.resize(a.size() + b.size() + 1);
  merge(a.begin(), a.end(), b.begin(), b.end(), c.begin() + 1,
        [](const Point<i64> &a, const Point<i64> &b) { return (a ^ b) < 0; });
  for (usz i = 1; i < c.size(); ++i) c[i] = c[i] + c[i - 1];
  return c;
}
```


#note(title:"例题 战争")[
    + 有两个凸包 `P,Q`, 平移 `q` 次 `Q`, 问每次移动后是否有交点
]

```cpp
#include <algorithm>
#include <cassert>
#include <cstdint>
#include <iostream>
#include <vector>
using namespace std;
using i64 = int64_t;
using isz = ptrdiff_t;
using usz = size_t;

template <class T>
struct Point {
  T x, y;

  Point(T x = 0, T y = 0) : x(x), y(y) {}

  friend Point operator+(const Point &a, const Point &b) {
    return {a.x + b.x, a.y + b.y};
  }

  friend Point operator-(const Point &a, const Point &b) {
    return {a.x - b.x, a.y - b.y};
  }

  // 点乘
  friend T operator*(const Point &a, const Point &b) {
    return a.x * b.x + a.y * b.y;
  }

  // 叉乘
  friend T operator^(const Point &a, const Point &b) {
    return a.x * b.y - a.y * b.x;
  }

  friend istream &operator>>(istream &is, Point &p) { return is >> p.x >> p.y; }
};

template <class T>
vector<Point<T>> convex_hull(vector<Point<T>> p) {
  assert(!p.empty());
  sort(p.begin(), p.end(),
       [](const Point<i64> &a, const Point<i64> &b) { return a.x < b.x; });
  vector<Point<T>> u{p[0]}, d{p.back()};
  for (usz i = 1; i < p.size(); ++i) {
    while (u.size() >= 2 &&
           ((u.back() - u[u.size() - 2]) ^ (p[i] - u.back())) > 0)
      u.pop_back();
    u.push_back(p[i]);
  }
  for (usz i = p.size() - 2; (isz)i >= 0; --i) {
    while (d.size() >= 2 &&
           ((d.back() - d[d.size() - 2]) ^ (p[i] - d.back())) > 0)
      d.pop_back();
    d.push_back(p[i]);
  }
  u.insert(u.end(), d.begin() + 1, d.end());
  return u;
}

template <class T>
vector<Point<T>> minkowski_sum(vector<Point<T>> a, vector<Point<T>> b) {
  vector<Point<T>> c{a[0] + b[0]};
  for (usz i = 0; i + 1 < a.size(); ++i) a[i] = a[i + 1] - a[i];
  for (usz i = 0; i + 1 < b.size(); ++i) b[i] = b[i + 1] - b[i];
  a.pop_back(), b.pop_back();
  c.resize(a.size() + b.size() + 1);
  merge(a.begin(), a.end(), b.begin(), b.end(), c.begin() + 1,
        [](const Point<i64> &a, const Point<i64> &b) { return (a ^ b) < 0; });
  for (usz i = 1; i < c.size(); ++i) c[i] = c[i] + c[i - 1];
  return c;
}

int main() {
  cin.tie(nullptr)->sync_with_stdio(false);
  uint32_t n, m, q;
  vector<Point<i64>> a, b;
  cin >> n >> m >> q;
  a.resize(n), b.resize(m);
  for (auto &p : a) cin >> p;
  for (auto &p : b) cin >> p, p = 0 - p;
  a = convex_hull(a), b = convex_hull(b);
  a = minkowski_sum(a, b);
  a.pop_back();
  for (usz i = 1; i < a.size(); ++i) a[i] = a[i] - a[0];
  while (q--) {
    Point<i64> v;
    cin >> v;
    v = v - a[0];
    if (v.x < 0) {
      cout << "0\n";
      continue;
    }
    auto it = upper_bound(
        a.begin() + 1, a.end(), v,
        [](const Point<i64> &a, const Point<i64> &b) { return (a ^ b) < 0; });
    if (it == a.begin() + 1 || it == a.end()) {
      cout << "0\n";
      continue;
    }
    i64 s0 = *it ^ *prev(it), s1 = v ^ *prev(it), s2 = *it ^ v;
    cout << (s1 >= 0 && s2 >= 0 && s1 + s2 <= s0) << '\n';
  }
  return 0;
}
```

== 扫描线

#note[
    最最最常见的题目了吧 我觉得
]

=== 二维矩形面积并

```cpp
/* 洛谷 P5490【模板】扫描线 & 矩形面积并 */
#include <algorithm>
#include <iostream>
using LL = long long;
constexpr int N = 1e5 + 1;
int n, a[N * 2], tot;   // a[] 和 tot 用于把 x 离散化
LL v[N * 8], w[N * 8];  // 完全覆盖区间的次数、已覆盖的长度
struct St {
  LL x1, x2, y, o;
} b[N * 2];  // 矩形上下边缘
int f(int y) {  // 离散化，把坐标映射到 a 中的下标
  return std::lower_bound(a, a + tot, y) - a;
}
void up(int u, int ul, int ur) {  // pushup
  if (v[u]) w[u] = a[ur] - a[ul];
  // 如果对叶子节点调用 w[u*2+1]，那么线段树需要开 8 倍空间
  // 乘上矩形上下两边就是 16 倍
  else if (ul + 1 == ur)
    w[u] = 0;
  else
    w[u] = w[u * 2 + 1] + w[u * 2 + 2];
}
void add(int lf, int rg, LL o, int u = 0, int ul = 0, int ur = tot - 1) {
  // 区间加
  if (lf == ul && rg == ur) return v[u] += o, up(u, ul, ur), void();
  int um = (ul + ur) / 2;
  if (lf < um) add(lf, std::min(rg, um), o, u * 2 + 1, ul, um);
  if (um < rg) add(std::max(lf, um), rg, o, u * 2 + 2, um, ur);
  up(u, ul, ur);
}
int main() {
  std::cin >> n;
  for (int i = 0, x1, x2, y1, y2; i < n; i++) {
    // y1 是局部变量不会重名
    std::cin >> x1 >> y1 >> x2 >> y2;
    b[i] = {x1, x2, y1, 1};
    b[i + n] = {x1, x2, y2, -1};
    a[i] = x1, a[i + n] = x2;
  }
  std::sort(a, a + n * 2), tot = 1;
  for (int i = 1; i < n * 2; i++)
    if (a[i] != a[tot - 1]) a[tot++] = a[i];  // 离散化
  std::sort(b, b + n * 2,[](St &i, St &j) -> bool { return i.y < j.y; });  // 操作排序
  LL sum = 0;
  add(f(b[0].x1), f(b[0].x2), 1);
  for (int i = 1; i < n * 2; i++) {
    int x1 = f(b[i].x1), x2 = f(b[i].x2);
    sum += (b[i].y - b[i - 1].y) * w[0];  // 对每个小矩形面积求和
    add(x1, x2, b[i].o);
  }
  std::cout << sum << '\n';
}
```

=== B维正交范围

#note[
    其实就是告诉你 元素的 B 维分布处理思路:
]

B 维正交范围指在一个 B 维直角坐标系下，第 $i$ 维坐标在一个整数范围 $[l_i,r_i]$ 间，内部的点集．

一般来说，一维正交范围简称区间，二维正交范围简称矩形，三维正交范围简称立方体（我们常说的二维数点就是二维正交范围）．

对于一个静态的二维问题，我们可以使用扫描线扫一维，数据结构维护另一维． 在扫描线从左到右扫的过程中，会在数据结构维护的那一维上产生一些修改与查询． 如果查询的信息可差分的话直接使用差分，否则需要使用分治．差分一般用树状数组和线段树维护，但因为树状数组好写而且常数小，所以大部分人会选择用树状数组来维护．分治一般是 CDQ 分治（但是这里不涉及分治）．

另一种比较容易理解的看待问题的角度是站在序列角度，而不站在二维平面角度．如果我们这样看待问题，则扫描线实际上是枚举了右端点 $r=1 dots.c n$，维护一个数据结构，支持查询对于当前的 $r$，给定一个值 $l$，$l$ 到 $r$ 的答案是什么．即扫描线扫询问右端点，数据结构维护所有左端点的答案，或者说遍历一维，数据结果维护另一维．

复杂度一般为 $O((n+m)log n)$

=== 二维数点

给一个长为 $n$ 的序列，有 $m$ 次查询，每次查区间 $[l, r]$ 中值在 $[x, y]$ 内的元素个数。

等价于我们要查询一个二维平面上矩形内的点的数量和。(*扫描线* + *树状数组*)

很显然，这个问题是一个静态的二维问题，我们通过扫描线可以将静态的二维问题转换为动态的一维问题．维护动态的一维问题就使用数据结构维护序列，这里可以使用树状数组．

先将所有的询问离散化，用树状数组维护权值，对于每次询问的 $l$ 和 $r$，我们在枚举到 $l-1$ 时统计当前位于区间 $[x,y]$ 内的数的数量 $a$，继续向后枚举，枚举到 $r$ 时统计当前位于区间 $[x,y]$ 内的数的数量 $b$，$b-a$ 即为该次询问的答案．

== 旋转卡壳

#note[
    TO DO !! 典 旋转卡壳 

    在凸包算法的基础上，通过枚举凸包上某一条边的同时维护其他需要的点，能够在线性时间内求解如凸包直径、最小矩形覆盖等和凸包性质相关的问题．
]

=== 求凸包直径

```cpp
int sta[N], top;  // 将凸包上的节点编号存在栈里，第一个和最后一个节点编号相同

ll pf(ll x) { return x * x; }

ll dis(int p, int q) { return pf(a[p].x - a[q].x) + pf(a[p].y - a[q].y); }

ll sqr(int p, int q, int y) { return abs((a[q] - a[p]) * (a[y] - a[q])); }

ll mx;

void get_longest() {  // 求凸包直径
  int j = 3;
  if (top < 4) {
    mx = dis(sta[1], sta[2]);
    return;
  }
  for (int i = 1; i < top; ++i) {
    while (sqr(sta[i], sta[i + 1], sta[j]) <=
           sqr(sta[i], sta[i + 1], sta[j % top + 1]))
      j = j % top + 1;
    mx = max(mx, max(dis(sta[i + 1], sta[j]), dis(sta[i], sta[j])));
  }
}
```

=== 求最小矩形覆盖

```cpp
void get_biggest() {
  int j = 3, l = 2, r = 2;
  double t1, t2, t3, ans = 2e10;
  for (int i = 1; i < top; ++i) {
    while (sqr(sta[i], sta[i + 1], sta[j]) <=
           sqr(sta[i], sta[i + 1], sta[j % top + 1]))
      j = j % top + 1;
    while (dot(sta[i + 1], sta[r % top + 1], sta[i]) >=
           dot(sta[i + 1], sta[r], sta[i]))
      r = r % top + 1;
    if (i == 1) l = r;
    while (dot(sta[i + 1], sta[l % top + 1], sta[i]) <=
           dot(sta[i + 1], sta[l], sta[i]))
      l = l % top + 1;
    t1 = sqr(sta[i], sta[i + 1], sta[j]);
    t2 = dot(sta[i + 1], sta[r], sta[i]) + dot(sta[i + 1], sta[l], sta[i]);
    t3 = dot(sta[i + 1], sta[i + 1], sta[i]);
    ans = min(ans, t1 * t2 / t3);
  }
}
```

== 半平面交

#note[
    卡卡卡
]

```cpp
#include<bits/stdc++.h>
using namespace std;
using DB = long double;

const int N=2e5+5;
const DB eps = 1e-18,PI=acos(-1);
const DB inf=1e12;

int sign(DB x){
    if(x>eps)return 1;
    else if(x<-eps)return -1;
    else return 0;
}

struct Vec{// 向量/坐标
    DB x,y;
    Vec(DB xx=0,DB yy=0):x(xx),y(yy){}
    Vec operator+(Vec o)const {return Vec(x+o.x,y+o.y);}
    Vec operator-(Vec o)const {return Vec(x-o.x,y-o.y);}
    Vec operator*(DB k){return Vec(x*k,y*k);}
    DB operator%(Vec o)const {return x*o.y-y*o.x;}
    friend ostream& operator<<(ostream& os,Vec o){
        return os<<"Vec("<<o.x<<","<<o.y<<")";
    }   
};
struct Seg{// 有向线段/有向直线
    Vec s,t,v;
    DB angle;
    int id;
    Seg(){}
    Seg(Vec ss,Vec tt):s(ss),t(tt),v(tt-ss){angle=atan2(v.y,v.x);}
    friend ostream& operator<<(ostream& os,Seg o){
        return os<<"("<<o.angle<<")["<<o.s<<" -> "<<o.t<<"]";
    }
}s[N],q[N];

bool right(Seg A,Vec b){
    // 位于右侧 叉积小于 0 是被排除 等于 0 表示重合可以进行 
    return sign(A.v%(b-A.s))==-1;// 很简单 非逆时针即可
}

// 【求直线交点】 要先保证 不平行 
Vec inter(Seg A,Seg B){
    Vec u = A.s-B.s;
    return A.s + A.v*((B.v%u)/(A.v%B.v));
}

bool cmp(Seg A,Seg B){ 
    if(!sign(A.angle-B.angle))return right(A,B.s);// B在右侧没有贡献
    else return sign(A.angle-B.angle)==-1;// 返回差值
}

int n,cnt;

// 【计算前 m 个半平面交是否有解】
bool test(int m){
    int l=1,r=0;
    for(int i=1;i<=cnt;i++){
        if(s[i].id>m)continue;
        if(l<=r&&sign(s[i].angle-q[r].angle)==0)continue;// 我只要第一个 在最左侧的
        while(l<r&&right(s[i],inter(q[r],q[r-1])))--r;// 队尾出界
        while(l<r&&right(s[i],inter(q[l],q[l+1])))++l;// 队头出界 
        q[++r]=s[i];
    }
    // 你的代码原有的：用队头检查队尾
    while(l < r && right(q[l], inter(q[r], q[r-1]))) --r;
    // 必须增加：用队尾检查队头
    while(l < r && right(q[r], inter(q[l], q[l+1]))) ++l;
    return r-l+1>=3;// 凭什么是 3???
}

void solve(){
    cin>>n;
    // a b 不能取 0 啊啊啊啊啊啊啊啊啊啊 
    s[++cnt]=Seg{Vec{-inf,eps},Vec{-eps,eps}};
    s[++cnt]=Seg{Vec{-eps,eps},Vec{-eps,inf}};
    s[++cnt]=Seg{Vec{-eps,inf},Vec{-inf,inf}};
    s[++cnt]=Seg{Vec{-inf,inf},Vec{-inf,eps}};
    for(int i=1;i<=n;i++){
        double x,y1,y2;
        cin>>x>>y1>>y2;
        Seg s1 = Seg{
            Vec{0,y1/x},// 选取 (0,f(0)) (1,f(1))  啊 
            Vec{1,y1/x-x},
        };
        Seg s2 = Seg{
            Vec{1,y2/x-x},
            Vec{0,y2/x},
        };
        s[++cnt]=s1;
        s[cnt].id=i;
        s[++cnt]=s2;
        s[cnt].id=i;
    }
    sort(s+1,s+cnt+1,cmp);
    int l=0,r=n,ans=0;
    while(l<=r){
        int mid=(l+r)/2;
        if(test(mid)){
            ans=mid;
            l=mid+1;
        }else {
            r=mid-1;
        }
    }
    cout<<ans<<"\n";
}

int main(){
    cout<<fixed<<setprecision(1);
    cin.tie(0)->sync_with_stdio(0);
    solve();
}
```

== 平面最近点对

#note[
    到头来不如期望线性? 但是没有人写这个 都在炫技随机旋转

    正解是*分治*算法 合并的时候 根据鸽巢原理其实只需暴力枚举最近的 6 个即可
]

```cpp
DB cdq_nearst_points(vector<Vec>& p,vector<Vec>& tmp,int l,int r){
    if(l>=r)return 1e18;
        int mid=(l+r)/2;
        double res = min(cdq_nearst_points(p,tmp,l,mid),cdq_nearst_points(p,tmp,mid+1,r));
        for(int i=l,j=mid+1;i<=mid;i++){
            while(j+1<=r&&p[j].y<p[i].y)j++;
            for(int k=max(j-5,mid+1);k<=min(j+5,r);k++)
                res=min(res,dist(p[i],p[k]));
        }
        tmp.clear();
        int a=l,b=mid+1;
        while(a<=mid&&b<=r)tmp.push_back(p[a].y<p[b].y?p[a++]:p[b++]);
        while(a<=mid)tmp.push_back(p[a++]);
        while(b<=r)tmp.push_back(p[b++]);
        for(int i=0;i<r-l+1;i++)p[l+i]=tmp[i];
        return res;
}
// 【例题】 平面最近点对
void solve_nearest_points(){
    int n;
    cin>>n;
    vector<Vec> p(n),tmp;
    for(auto& [x,y]:p)cin>>x>>y;
    sort(p.begin(),p.end(),[](const Vec& a,const Vec& b){
        return sign(a.x-b.x)?a.x<b.x:a.y<b.y;
    });
    cout<<cdq_nearst_points(p,tmp,0,n-1)<<"\n";
}
```

== 随机增量法

#note[
    难受 
]

```cpp
// 【例题】 最小圆覆盖 (随机增量算法)
void solve_min_circle_cover(){
    mt19937 rng(chrono::steady_clock::now().time_since_epoch().count());
    int n;cin>>n;
    vector<Vec> p(n);for(auto& [x,y]:p)cin>>x>>y;
    shuffle(p.begin(),p.end(),rng);
    // 【懂了】 这玩意就像 两次 dfs 求解直径 寻找关键点!!! 
    Circle cur(p[0],0);
    for(int i=0;i<n;i++){// 现在已经计算出了 i-1 个的最小覆盖
        if(circle_point(cur,p[i])==1){// 前 i 个最小覆盖一定过 i 点
            cur = Circle(p[i],0);// 必选第 i 你一定可以计算出 最小覆盖!!!
            for(int j=0;j<i;j++)// 现在已经计算出了 i + j-1 个的最小覆盖
                if(circle_point(cur,p[j])==1){// 前 j 个最小覆盖一定过 j 点
                    cur = Circle(p[i],p[j]);// 必选 i j 你一定可以计算出 最小覆盖!!! 
                    for(int k=0;k<j;k++)// 现在已经计算出了 i + j +  k-1 个的最小覆盖 
                        if(circle_point(cur,p[k])==1)// 前 k 个最小覆盖一定过 k 点
                            cur=Circle(p[i],p[j],p[k]);// 三点确定一个圆 
                }
        }
    }
    cout<<cur.r<<"\n"<<cur.o.x<<" "<<cur.o.y<<"\n";
}
```

== 反演变换

#note[
    TO DO ? XCPC 考的挺多
]