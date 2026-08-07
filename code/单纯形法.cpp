#include <bits/stdc++.h>
using namespace std;
using LD = long double;

// eps 用于处理浮点误差。如果遇到精度导致的 Constraint violated，
// 可以尝试微调此值（如 1e-10 或 1e-9）。
const LD eps = 1e-12;

int n, m; // n: 原始变量数, m: 约束条件数

/* 
 * tab 矩阵的特殊结构 (Transposed & Compressed):
 * - 行索引 0 到 n-1: 对应当前的非基变量 (Non-basic variables)
 * - 行索引 n: 存储当前的常数项 b 或目标函数值
 * - 列索引 0 到 m-1: 对应当前的基变量 (Basic variables)
 * - 列索引 m: 存储目标函数的系数 (Reduced costs)
 * - 列索引 m+1: 专门用于第一阶段 (Phase 1) 寻找可行解的辅助目标函数
 */
vector<vector<LD>> tab; 
vector<int> B, N; // B: 基变量集合, N: 非基变量集合

/**
 * 旋转操作 (Pivot): 核心变换
 * 将非基变量 N[x] 与基变量 B[y] 进行互换，并更新单纯形表。
 * @param x 进基变量在 N 中的索引 (行)
 * @param y 出基变量在 B 中的索引 (列)
 */
void pivot(int x, int y) {
    swap(N[x], B[y]);
    // 计算主元倒数，用于更新整行
    LD v = -1.0 / tab[x][y];
    for (int j = 0; j <= m + 1; j++) {
        tab[x][j] = (j == y ? -v : v * tab[x][j]);
    }
    // 更新除主元行以外的所有行
    for (int i = 0; i <= n; i++) {
        if (i == x) continue;
        v = tab[i][y];
        tab[i][y] = 0; // 这里的 0 是因为原位置会变为空白，后面更新会处理
        for (int j = 0; j <= m + 1; j++) {
            tab[i][j] += v * tab[x][j];
        }
    }
}

/**
 * 第一阶段 (Phase 1): 寻找初始基可行解 (BFS)
 * 如果约束条件的常数项 b_i 有负数，直接运行单纯形会报错。
 * 这里采用辅助目标函数（存储在 tab[i][m+1]）来通过旋转消除负的常数项。
 * @return 是否存在可行解
 */
bool initialize() {
    int neg_count = 0;
    // 检查是否有 b_j < 0 的约束
    for (int j = 0; j < m; j++) {
        if (tab[n][j] < -eps) {
            // 将所有负约束累加到辅助目标函数列
            for (int i = 0; i <= n; i++) tab[i][m + 1] += tab[i][j];
            B[j] = ~B[j]; // 标记该变量当前不可行
            neg_count++;
        }
    }
    
    // 当存在不可行约束时循环
    while (neg_count) {
        int x = -1;
        LD mi = -eps;
        // 寻找辅助目标函数中减少最快的列
        for (int i = 0; i < n; i++) {
            if (tab[i][m + 1] < mi) {
                x = i;
                mi = tab[i][m + 1];
            }
        }
        if (x == -1) return false; // 无法进一步优化辅助目标，说明无可行解

        int y = -1;
        mi = INFINITY;
        // Ratio Test: 寻找最紧的约束行进行旋转
        for (int j = 0; j < m; j++) {
            if ((B[j] < 0 && tab[x][j] < -eps) || (B[j] >= 0 && tab[x][j] > eps)) {
                // 这里的 tmp 包含了一个微小的偏移量以保证数值稳定
                LD tmp = tab[n][j] / tab[x][j] + (B[j] < 0 ? -eps : eps);
                if (tmp < mi) {
                    y = j;
                    mi = tmp;
                }
            }
        }
        
        if (B[y] < 0) { // 如果选中的是被标记的负约束
            neg_count--;
            B[y] = ~B[y]; // 恢复标记
            pivot(x, y);
            tab[x][m + 1] += 1.0; // 修正辅助目标函数
        } else {
            pivot(x, y);
        }
    }
    return true;
}

/**
 * 第二阶段 (Phase 2): 寻找最优解
 * 标准单纯形过程，不断通过旋转增加目标函数的值。
 * @return 是否有界 (Unbounded)
 */
bool simplex() {
    while (true) {
        int x = -1;
        LD mi = -eps;
        // 寻找 Reduced Cost 为负的列 (进基变量)
        for (int i = 0; i < n; i++) {
            if (tab[i][m] < mi) {
                x = i;
                mi = tab[i][m];
            }
        }
        // 如果所有系数都 >= 0，说明已达到最大值
        if (x == -1) break; 

        int y = -1;
        mi = INFINITY;
        // Ratio Test: 寻找出基变量
        for (int j = 0; j < m; j++) {
            if (tab[x][j] <= eps) continue;
            if (tab[n][j] / tab[x][j] < mi) {
                y = j;
                mi = tab[n][j] / tab[x][j];
            }
        }
        // 如果进基变量在所有约束下都可以无限增加，说明问题无界
        if (y == -1) return false; 
        pivot(x, y);
    }
    return true;
}

int solve() {
    B.resize(m);
    N.resize(n);
    // 初始化变量编号：0..n-1 是原始变量，n..n+m-1 是松弛变量
    iota(B.begin(), B.end(), n);
    iota(N.begin(), N.end(), 0);
    
    if (!initialize()) return -1; // Infeasible: 无可行解
    if (!simplex()) return 1;    // Unbounded: 目标函数可至无穷大
    return 0;                    // Optimal: 找到最优解
}

int main() {
    // 高速 IO
    cin.tie(0)->sync_with_stdio(0);
    cout << fixed << setprecision(12);
    
    // 分配空间：n+1 行 (变量+常数行), m+2 列 (约束+目标+辅助)
    tab.assign(n + 1, vector<LD>(m + 2, 0));

    // 读入目标函数系数 (Maximize Σ c_i * x_i)
    for (int i = 0; i < n; i++) {
        cin >> tab[i][m];
        tab[i][m] = -tab[i][m]; // 算法内部实现通常是最小化形式或特定的正负约定
    }

    // 读入约束矩阵 A 和常数项 b
    // 格式：Σ A_ij * x_j <= b_i
    for (int j = 0; j < m; j++) {
        for (int i = 0; i <= n; i++) {
            // 注意这里是转置读入：tab[i][j]
            // 当 i=n 时读入的是 b_j
            cin >> tab[i][j];
        }
    }

    int res = solve();
    if (res == -1) {
        cout << "Infeasible" << endl;
    } else if (res == 1) {
        cout << "Unbounded" << endl;
    } else {
        // tab[n][m] 存储的是最终的最优解目标函数值
        cout << tab[n][m] << endl;
        
        // 解析变量 x_i 的取值
        vector<LD> x_val(n, 0);
        for (int j = 0; j < m; j++) {
            // 如果基变量编号小于 n，说明原始变量 x_i 在基中，有非零解
            if (B[j] < n) x_val[B[j]] = tab[n][j];
        }
        for (int i = 0; i < n; i++) {
            cout << x_val[i] << (i == n - 1 ? "" : " ");
        }
        cout << endl;
    }
    return 0;
}