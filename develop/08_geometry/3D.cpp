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

