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

// 【求直线交点】 要先保证 不平行 
Vec inter(Seg A,Seg B){
    Vec u = A.s-B.s;
    return A.s + A.v*((B.v%u)/(A.v%B.v));
}

bool right(Seg A,Vec b){
    // 位于右侧 叉积小于 0 是被排除 等于 0 表示重合可以进行 
    return sign(A.v%(b-A.s))==-1;// 很简单 非逆时针即可
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