/**
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
            while (res % i == 0 && qpow(a, res / i, m) == 1) {
                res /= i;
            }
            while (temp % i == 0) temp /= i;
        }
    }
    // 处理最后的较大质因子
    if (temp > 1) {
        if (res % temp == 0 && qpow(a, res / temp, m) == 1) {
            res /= temp;
        }
    }
    return res;
}