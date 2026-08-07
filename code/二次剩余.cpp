#include <bits/stdc++.h>

using namespace std;

#define LL long long
#define LLL __int128

namespace Math {
    inline LL mul(LL a, LL b, LL m) { return (LL)((LLL)a * b % m); }
    inline LL qpow(LL a, LL b, LL m) {
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
            LL x = qpow(a, d, n);
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
        if (qpow(a, (p - 1) >> 1, p) == p - 1) return -1;
        LL b; static mt19937_64 rng(19260817);
        while (1) {
            b = rng() % p; W2 = (mul(b, b, p) - a + p) % p;
            if (qpow(W2, (p - 1) >> 1, p) == p - 1) break;
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