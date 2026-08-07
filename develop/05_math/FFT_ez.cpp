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
    const int LEN = 20; 
    const int N = 1 << LEN; 
    vector<CP> w[LEN], iw[LEN];
    vector<int> rev[LEN];
    LL fac[N], invfac[N], inv[N];
    LL mod;

    LL ksm(LL a, LL b) {
        LL res = 1;
        for (; b; b >>= 1, a = a * a % mod) if (b & 1) res = res * a % mod;
        return res;
    }

    LL add(LL a, LL b){
        return a+b>=mod?a+b-mod:a+b;
    }
    
    LL sub(LL a, LL b){
        return a-b<0?a-b+mod:a-b;
    }

    void tim(LL& a,LL b){
        a=a*b%mod;
    }

    LL mul(LL a, LL b){
        return a * b % mod;
    }

    void init(LL mo) {
        mod=mo;

        // 【新增】初始化 fac 数组
        fac[0] = 1;
        for(int i = 1; i < N; i++) fac[i] = mul(fac[i-1], i);

        inv[0] = inv[1] = invfac[0] = invfac[1] = 1;
        for(int i = 2; i < N; i++){
            inv[i] = mul(mod - mod / i, inv[mod % i]);
            invfac[i] = mul(invfac[i-1], inv[i]);
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
    
    void norm_mul_to(Poly& A,Poly& B,int lim){
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
            LL ans = (1LL << 30) % mod * hh%mod;
            ans = (ans + ((lh + hl) << 15)) % mod;
            ans = (ans + ll) % mod;
            A[i] = ans;
        }
        for (int i = len_C; i < lim; ++i) A[i] = 0; 
    }

    Poly norm_mul(Poly A, Poly B, int lim){
        norm_mul_to(A,B,lim);
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

    // WC 现在才发现 快速阶乘算法给的模数是质数 只是不一定是 NTT 模数啊啊啊
    // WC 现在才发现 快速阶乘算法给的模数是质数 只是不一定是 NTT 模数啊啊啊
    // WC 现在才发现 快速阶乘算法给的模数是质数 只是不一定是 NTT 模数啊啊啊
    // 2 多项式点值平移 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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
        norm_mul_to(B,C,n*2+1);
        for(int i=0;i<=n;i++)tim(A[i],B[i+n]);
        return A;
    }

    // void calc_fac(Poly& a, Poly& b, int n, int k){
    //     Poly F(n+1), G(n*2+1), H, sum(n*2+1), isum(n*2+1);
    //     int L = 1;
    //     while(L <= n * 2) L <<= 1;
        
    //     // 计算F
    //     for(int i = 0; i <= n; i++)F[i] = mul(a[i], mul(invfac[i], invfac[n - i]));
    //     for(int i = n - 1; i >= 0; i -= 2)F[i] = mod - F[i];
        
    //     // 计算G
    //     int t = sub(k, n); 
    //     for(int i = 0; i <= 2 * n; i++)G[i] = add(i, t);
    //     sum[0] = G[0];
    //     for(int i = 1; i <= n * 2; i++)sum[i] = mul(sum[i - 1], G[i]);
    //     isum[n * 2] = ksm(sum[n * 2], mod - 2);
    //     for(int i = n * 2; i >= 1; i--)isum[i - 1] = mul(isum[i], G[i]);
    //     for(int i = 1; i <= n * 2; i++)G[i] = mul(isum[i], sum[i - 1]);
    //     G[0] = isum[0];
        
    //     // 使用MTT计算卷积
    //     H = norm_mul(F, G, L);
        
    //     // 计算结果b
    //     LL res = 1;
    //     int p1 = k - n, p2 = k;
    //     for(int i = p1; i <= p2; i++)res = mul(res, i);
    //     res=sub(res,0);
        
    //     // 重新计算G用于后续计算
    //     for(int i = 0; i <= n; i++)G[i] = (mod + p1 + i) % mod;
    //     sum[0] = G[0];
    //     for(int i = 1; i <= n; i++)sum[i] = mul(sum[i - 1], G[i]);
    //     isum[n] = ksm(sum[n], mod - 2);
    //     for(int i = n; i >= 1; i--)isum[i - 1] = mul(isum[i], G[i]);
    //     for(int i = 1; i <= n; i++)G[i] = mul(isum[i], sum[i - 1]);
    //     G[0] = isum[0];

    //     // 计算b
    //     for(int i = 0; i <= n; i++, p2=add(p2,1)){
    //         b[i] = mul(H[i + n], res);
    //         res = mul(res, mul(G[i], add(p2,1)));
    //     }
    // }

    // (上面下面 二选一)
    // 修改后的 calc_fac：直接调用 shift_points
    void calc_fac(Poly& a, Poly& b, int n, int k){
        // 将 a 的前 n+1 项封装为 vector
        Poly input(n + 1);
        for(int i = 0; i <= n; i++) input[i] = a[i];
        // 调用 shift_points 获取从 k 开始的 n+1 个点值
        Poly res = shift_points(input, k);
        // 将结果写回 b
        for(int i = 0; i <= n; i++) b[i] = res[i];
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
        norm_mul_to(F,B,n);
        reverse(F.begin(),F.end());
        // 别忘了除以阶乘
        for(int i=0;i<n;i++)tim(F[i],invfac[i]);
        return F;
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

// 沟槽模板出题人 没有人类了
void test_shift_coef(){
    int n;LL mod=998244353; LL c; cin>>n>>c;
    FFT::init(mod);
    Poly F(n);
    for(int i=0;i<n;i++)cin>>F[i];
    Poly G = FFT::shift_coef(F,c);
    for(int i=0;i<n;i++)cout<<G[i]<<" ";
    cout<<"\n";
}

// 沟槽模板出题人 没有人类了
void test_shift_points(){
    int n;LL mod; LL c; cin>>n>>c>>mod;n++;
    FFT::init(mod);
    vector<LL> F(n);
    for(int i=0;i<n;i++)cin>>F[i];
    vector<LL> G = FFT::shift_points(F,c);
    for(int i=0;i<n;i++)cout<<G[i]<<" ";
    cout<<"\n";
}

int main() {
    cin.tie(0)->sync_with_stdio(0);
    // solve_norm_mul();// AC 1520 ms
    // solve_norm_inv();// AC 2190 ms
    solve_norm_fac();// AC 4820 ms
    // test_shift_coef();
    // test_shift_points();
    return 0;
}