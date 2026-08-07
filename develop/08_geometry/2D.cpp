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

/* 例题 例题 例题 */

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

int main(){
    cout<<setprecision(4)<<fixed;
    cin.tie(0)->sync_with_stdio(0);
    // solve_min_circle_cover();
    solve_nearest_points();
}