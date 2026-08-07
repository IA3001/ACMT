#include<bits/stdc++.h>
using namespace std;
const int N = 5e5 + 5;
const int inf = INT_MAX;
/*
【另类】 使用 cnt 计数 
性质: merge 时不再需要 copy() (避免了冗余拷贝)
*/
namespace PTreap {
    struct Node {
        int lc, rc, sz, cnt, val, key;
    } tr[N*50]; // 空间通常开 N * 40~50 即可
    int tot;
    #define lc(i) tr[i].lc
    #define rc(i) tr[i].rc
    #define sz(i) tr[i].sz
    #define cnt(i) tr[i].cnt
    #define val(i) tr[i].val
    #define key(i) tr[i].key
    int copy(int i) {
        if (!i) return 0;
        tr[++tot] = tr[i];
        return tot;
    }
    int new_node(int k) {
        int i = ++tot;
        key(i) = k; sz(i) = 1; cnt(i) = 1;
        lc(i) = rc(i) = 0;
        val(i) = rand();
        return i;
    }
    void up(int i) {
        if (!i) return;
        sz(i) = cnt(i) + sz(lc(i)) + sz(rc(i));
    }
    // 标准的可持久化 Split，必须 copy
    void split(int i, int x, int &l, int &r) {
        if (!i) {
            l = r = 0;
            return;
        }
        i = copy(i); // 路径克隆
        if (key(i) <= x) {
            l = i;
            split(rc(i), x, rc(l), r);
        } else {
            r = i;
            split(lc(i), x, l, lc(r));
        }
        up(i);
    }
    // 【关键修改】不再需要 copy
    int merge(int l, int r) {
        if (!l || !r) return l | r;
        // 因为 l 和 r 的祖先路径在 split 时已经 copy 过了
        // 这里直接修改不会破坏历史版本
        if (val(l) > val(r)) {
            rc(l) = merge(rc(l), r);
            up(l);
            return l;
        } else {
            lc(r) = merge(l, lc(r));
            up(r);
            return r;
        }
    }
    int insert(int rt, int k) {
        int l, r, m;
        split(rt, k, l, r);
        split(l, k - 1, l, m);
        if (m) {
            m = copy(m); // 发现已有该键，克隆并增加计数
            cnt(m)++;
            up(m);
        } else m = new_node(k);
        return merge(merge(l, m), r);
    }
    int erase(int rt, int k) {
        int l, r, m;
        split(rt, k, l, r);
        split(l, k - 1, l, m);
        if (m) {
            m = copy(m);
            if (cnt(m) > 1) {
                cnt(m)--;
                up(m);
                l = merge(l, m);
            }// else // cnt 为 1，直接丢弃 m 节点，l 保持原样
        }
        return merge(l, r);
    }
    int rank(int i, int k) {
        int res = 1;
        while (i) {
            if (k < key(i)) i = lc(i);
            else if (k == key(i)) return res + sz(lc(i));
            else res += sz(lc(i)) + cnt(i),i = rc(i);
        }
        return res;
    }
    int at(int i, int x) {
        while (i) {
            if (x <= sz(lc(i))) i = lc(i);
            else if (x <= sz(lc(i)) + cnt(i)) return key(i);
            else x -= (sz(lc(i)) + cnt(i)),i = rc(i);
        }
        return 0;
    }
    int prev(int i, int k) {return at(i,rank(i,k)-1);}
    int next(int i, int k) {return at(i,rank(i,k+1));}
}

int rt[N];
int main() {
    ios::sync_with_stdio(0); cin.tie(0);
    int n; cin >> n;
    for (int i = 1; i <= n; i++) {
        int v, op, x;
        cin >> v >> op >> x;
        if (op == 1) rt[i] = PTreap::insert(rt[v], x);
        else if (op == 2) rt[i] = PTreap::erase(rt[v], x);
        else {
            rt[i] = rt[v];
            if (op == 3) cout << PTreap::rank(rt[i], x) << "\n";
            else if (op == 4) cout << PTreap::at(rt[i], x) << "\n";
            else if (op == 5) cout << PTreap::prev(rt[i], x) << "\n";
            else if (op == 6) cout << PTreap::next(rt[i], x) << "\n";
        }
    }
    return 0;
}