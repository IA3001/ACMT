#include<bits/stdc++.h>
using namespace std;
using LL = long long;

const int N = 1<<21;

// WC 沟槽 的递归复用空间 我发现好像 不能做到优雅的不现开空间
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
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // 草了 这个问题太 TMD 隐蔽了!!!!!!!!!!!!!!!!!!!
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // 草了 这个问题太 TMD 隐蔽了!!!!!!!!!!!!!!!!!!!
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // 草了 这个问题太 TMD 隐蔽了!!!!!!!!!!!!!!!!!!!
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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
    // WC 果然 刚才多这3个数组 TMD mle 了
    // 唉? 事实上 我可以 写一个 inv_n[N] 因为知二求一嘛!!! 
    LL fac[N],invfac[N];// 线性预处理 逆元 方便多次积分 !!!
    // 唉!! 我又忘了 事实上时 抛弃了 线性逆元的好 占用空间少哇
    // LL inv_n[N];
    
    // 初始化
    void init(){
        
        // 阶乘求逆元
        // 这里 赛场上可以加 (影响我 AC 成绩 bushi)
        // 我是 SB 正反颠倒 还不如不写
        fac[0]=1;
        for(int i=1;i<N;i++)fac[i]=fac[i-1]*i%mod;
        invfac[N-1]=ksm(fac[N-1],mod-2);
        for(int i=N-1;i>=1;i--)invfac[i-1]=invfac[i]*i%mod;
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
        // 最后才能直接使用硬截取 lim !!!!!!!!!!! 说是 
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
            // 我 真 tmd SB 这里刚才果然 i 重命名了 CaO
            b2=(b2*10+b[i]-'0')%(mod-1);// 注意这里 减一 
        }
        // 我们可以 一切从简计算 :
        LL base = B[0]*len;
        // WC tmd 我这里 A 会改变, 之前放在后面了 !!!
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
        // 注意取 min !!!!!!!!!!!!
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

    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // Poly prod[N*4]; // 调试减负
    Poly prod[1];
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

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

    // WC 现在才发现 快速阶乘算法给的模数是质数 只是不一定是 NTT 模数啊啊啊
    // WC 现在才发现 快速阶乘算法给的模数是质数 只是不一定是 NTT 模数啊啊啊
    // WC 现在才发现 快速阶乘算法给的模数是质数 只是不一定是 NTT 模数啊啊啊
    // 2 多项式点值平移 
    // （这下是从 FFT_ez 那里传过来的了）
    // g(c) = f(m+c) = A_c sum B_i C_(c-i)
    // A_c = (m+c)!/(m+c-n-1)! 
    // B_i = (f(i) (-1)^(n-i))/((n-i)!(i-1)!)
    // C_i = 1/(m+i)
    // C'_i = C_(i-n) 
    vector<LL> shift_points(vector<LL> F,LL m){
        m%=mod;
        int n=F.size();// 0 到 n-1 啊
        // 上文说的 n 其实是这里的 n-1 
        n--;// 方便起见 提前 -- 
        vector<LL> A(n+1),B(n+1),C(n*2+1),pre(n*2+1);
        pre[0]=m;
        for(int i=1;i<=n;i++)pre[i]=pre[i-1]*(m-i+mod)%mod;
        LL pro = 1;
        for(int i=0;i<=n;i++){
            A[i]=pro*pre[n-i]%mod;
            tim(pro,m+i+1);
        }
        for(int i=0;i<=n;i++){
            LL sign = ((n-i)&1?mod-1:1);
            B[i]=F[i]*sign%mod*invfac[n-i]%mod*invfac[i]%mod;
        }
        LL base = (m-n+mod)%mod;
        pre[0]=base;
        for(int i=1;i<=n*2;i++)pre[i]=pre[i-1]*(base+i)%mod;
        C[n*2]=ksm(pre[n*2],mod-2);
        for(int i=n*2;i>=1;i--)C[i-1]=C[i]*(base+i)%mod;
        for(int i=1;i<=n*2;i++)C[i]=C[i]*pre[i-1]%mod;
        // 注意这里全部都要计算 并没有出界 
        mul_to(B,C,n*2+1);
        for(int i=0;i<=n;i++)tim(A[i],B[i+n]);
        return A;
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

// 沟槽模板出题人 没有人类了
void test_shift_coef(){
    NTT::init();
    int n; LL c; cin>>n>>c;
    Poly F(n);
    for(int i=0;i<n;i++)cin>>F[i];
    Poly G = NTT::shift_coef(F,c);
    for(int i=0;i<n;i++)cout<<G[i]<<" ";
    cout<<"\n";
}

// 沟槽模板出题人 没有人类了
void test_shift_points(){
    NTT::init();
    // 没有人类了 
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
    // test_shift_coef();// 
    // test_shift_points();// 
    // 持续更新中...
}
