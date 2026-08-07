
#import "../lib.typ": *

= 附录\*

== DBG

=== Script

- 日常使用 

```bat
g++ %1.cpp -std=c++23 -Wall -o %1.exe
%1.exe
del %1.exe
```

```sh
g++ -std=c++23 -Wall -DDBG $1.cpp -o $1.o
./$1.o < $1.in > $1.out
cat $1.out
rm ./$1.o
# chmod +x r.sh
# ./r.sh A
```

=== Basic Template

```cpp
#include<bits/stdc++.h>
using namespace std;
using LL = long long;

#ifdef DBG
#define dbg(x) cout<<#x<<" -> "<<x<<"\n";
#else
#define dbg(...)
#endif

void solve(){
    
}

int main(){
    cin.tie(0)->sync_with_stdio(0);
    int t=1;
    cin>>t;
    while(t--)solve();
}
```

=== Plus Template

```cpp
#ifdef DBG
#define cout<<""<<#x<<" = ";err(x);
void err(){cout<<"\n";}
template<class A,class... B>
void err(A a,B... b){cout<<a<<" ";err(b...);}
#else
#define dbg(...)
#endif
```

== pb_ds

=== 平衡树

==== ordered_set基本使用

```cpp
#include <bits/stdc++.h>
#include <ext/pb_ds/assoc_container.hpp>
#include <ext/pb_ds/tree_policy.hpp>
using namespace std;
using namespace __gnu_pbds;
// 定义一个有序集合 (前两个参数是给你定义类似pair的 k v 此时 cmp<>只需填k的 但是没有[]方法)
typedef tree<int, null_type, less<int>, rb_tree_tag, tree_order_statistics_node_update> ordered_set;
void solve() {
    ordered_set s;
    s.insert(10);s.insert(30);s.insert(20);
    for(auto i:s)cout<<i<<",";cout<<"\n";
    // auto it = s.find(10);// 好！
    auto it = s.lower_bound(-1);// 爽！
    cout<<*it<<"!!!\n";
    cout<<*next(it)<<"!!!\n";
    cout<<*it++<<"!!!\n";
    cout<<*it++<<"!!!\n";
    // 查找某个值是否存在 (可惜没有 contains)
    cout << (s.find(20) != s.end()) << "\n"; // 输出 1（存在）
    // 查询某个值的排名（从 0 开始）
    cout << s.order_of_key(20) << "\n"; // 输出 1（20 的排名是 1）
    // 查询第 k 小的值 (从0开始)
    cout << *s.find_by_order(1) << "\n"; // 输出 20（第 1 小的值）
    // 删除某个值
    s.erase(20);
    cout << (s.find(20) == s.end()) << "\n"; // 输出 1（不存在）
}
int main() {
    cout<<boolalpha;
    solve();
    return 0;
}
```

==== ordered_multiset实现(比较麻烦)

```cpp
#include <bits/stdc++.h>
#include <ext/pb_ds/assoc_container.hpp>
#include <ext/pb_ds/tree_policy.hpp>
using namespace std;
using namespace __gnu_pbds;
// 自定义比较函数
struct custom_cmp {
    bool operator()(const pair<int, int> &a, const pair<int, int> &b) const {
        if (a.first != b.first) return a.first < b.first;
        return a.second < b.second; // 确保相同值的元素按 second 排序
    }
};
// 定义一个支持多重集的 tree
typedef tree<pair<int, int>, null_type, custom_cmp, rb_tree_tag, tree_order_statistics_node_update> ordered_multiset;
int main() {
    ordered_multiset s;
    int cnt = 0; // 计数器，确保唯一性
    // 插入元素
    s.insert({10, cnt++});
    s.insert({20, cnt++});
    s.insert({10, cnt++}); // 插入重复的 10
    s.insert({10, cnt++}); // 插入重复的 10
    // 查询某个值的排名（从 0 开始）
    cout << s.order_of_key({10, 0}) << "\n"; // 输出 0（第一个 10 的排名）
    // 查询第 k 小的值
    cout << s.find_by_order(1)->first << "\n"; // 输出 10（第二个 10）
    // 删除某个值
    s.erase(s.lower_bound({10, 0})); // 删除第一个 10
    // 遍历多重集
    for (auto &[key, id] : s) cout << key << " ";cout << "\n";
    return 0;
}
```

=== 优先队列

==== 基本使用

```cpp
#include <bits/stdc++.h>
#include <ext/pb_ds/priority_queue.hpp>
using namespace std;
using namespace __gnu_pbds;
// 定义一个最大堆（配对堆）
typedef __gnu_pbds::priority_queue<int, less<int>, pairing_heap_tag> pq_max;
int main() {
    pq_max pq;
    // 插入元素
    auto it1 = pq.push(10);
    auto it2 = pq.push(30);
    auto it3 = pq.push(20);
    cout << "Top element: " << pq.top() << "\n"; // 输出 30
    // 修改优先级
    pq.modify(it2, 5); // 将 30 修改为 5
    cout << "Top element after modify: " << pq.top() << "\n"; // 输出 20
    // 删除堆顶
    pq.pop();
    cout << "Top element after pop: " << pq.top() << "\n"; // 输出 10
    // 合并两个堆
    pq_max pq2;
    pq2.push(50);
    pq2.push(40);
    pq.join(pq2);
    cout << "Top element after join: " << pq.top() << "\n"; // 输出 50
    while(pq.size())cout<<pq.top()<<", ",pq.pop();cout<<'\n';// {50 40 10 5}
    return 0;
}
```

==== 反向堆优化 dijk (用于稀疏图)

```cpp
#include <bits/stdc++.h>
#include <ext/pb_ds/priority_queue.hpp>
using namespace std;
using namespace __gnu_pbds;
// 定义一个最小堆（配对堆）
typedef __gnu_pbds::priority_queue<pair<int, int>, greater<pair<int, int>>, pairing_heap_tag> pq_type;
const int INF = 1e9;
void dijkstra(int start, vector<int> &dist, const vector<vector<pair<int, int>>> &adj) {
    int n = adj.size(); // 节点数量
    dist.assign(n, INF); // 初始化距离数组
    dist[start] = 0;
    // 定义优先队列
    pq_type pq;
    vector<pq_type::point_iterator> heap_pos(n, nullptr); // 记录每个节点在堆中的迭代器位置
    // 将起点插入堆
    heap_pos[start] = pq.push({0, start});
    while (!pq.empty()) {
        auto [d, u] = pq.top(); // 取出当前距离最小的节点
        pq.pop();

        if (d > dist[u]) continue; // 如果当前距离不是最新的，跳过

        // 更新邻居节点的距离
        for (auto &[v, w] : adj[u]) {
            if (dist[v] > dist[u] + w) {
                dist[v] = dist[u] + w;
                if (heap_pos[v] != nullptr) {
                    // 如果节点已经在堆中，更新其距离值
                    pq.modify(heap_pos[v], {dist[v], v});
                } else {
                    // 如果节点不在堆中，插入堆
                    heap_pos[v] = pq.push({dist[v], v});
                }
            }
        }
    }
}
int main() {
    // 示例图：邻接表表示
    int n = 5; // 节点数
    vector<vector<pair<int, int>>> adj(n);
    adj[0].emplace_back(1, 10);
    adj[0].emplace_back(2, 5);
    adj[1].emplace_back(3, 1);
    adj[2].emplace_back(1, 3);
    adj[2].emplace_back(3, 8);
    adj[3].emplace_back(4, 4);
    int start = 0; // 起点
    vector<int> dist; // 存储最短距离
    dijkstra(start, dist, adj);
    // 输出结果
    for (int i = 0; i < n; ++i) {
        cout << "Distance to node " << i << ": " << dist[i] << "\n";
    }
    return 0;
}
```

=== 哈希表

```cpp
#include <bits/stdc++.h>
#include <ext/pb_ds/assoc_container.hpp>
#include <ext/pb_ds/hash_policy.hpp>
using namespace std;
using namespace __gnu_pbds;
// 定义一个哈希表
// typedef gp_hash_table<int, int> hash_table;// 数据小用 gp
typedef cc_hash_table<int, int> hash_table;// 数据大用 cc
int main() {
    hash_table ht;
    // 插入键值对
    ht[1] = 10;
    ht[2] = 20;
    ht.insert({3, 30});
    // 查找键值对
    auto it = ht.find(2);
    if (it != ht.end())
        cout << "Key 2 found, value: " << it->second << "\n";
    else cout << "Key 2 not found.\n";
    // 删除键值对
    ht.erase(1);
    // 遍历哈希表
    for (auto &[key, value] : ht) cout << key << " -> " << value << "\n";
    // 获取大小
    cout << "Size of hash table: " << ht.size() << "\n";
    return 0;
}
```

== Notes

- 时间倒流（逆序加点） + 普通 DSU
