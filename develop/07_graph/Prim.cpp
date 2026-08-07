// 使用二叉堆优化的 Prim 算法．
#include <bits/stdc++.h>
using namespace std;
constexpr int N = 5e3+5, M = 2e5 + 5;
struct Edge {
  int to,nxt,w;
}e[M*2];
int n, m, hd[N], cntE;
void add_edge(int u, int v, int w) { 
  e[++cntE] = {v, hd[u], w};
  hd[u] = cntE; 
}
struct Node{
  int u, d;
  bool operator<(const Node &o)const { return d > o.d; }
};
int dis[N];
bool vis[N];
int res = 0, cnt = 0;
void Prim() {
  priority_queue<Node> Q;
  memset(dis, 0x3f, sizeof dis);
  dis[1] = 0;
  Q.push({1, 0});
  while (Q.size()) {
    if (cnt >= n) break;
    auto [u,d]= Q.top();Q.pop();
    if (vis[u]) continue;
    vis[u] = true;
    ++cnt;
    res += d;
    for (int i = hd[u]; i; i = e[i].nxt) {
      int v = e[i].to, w = e[i].w;
      if (w < dis[v]) {
        dis[v] = w;
        Q.push({v, w});
      }
    }
  }
}
int main() {
  cin >> n >> m;
  for (int i = 1, u, v, w; i <= m; ++i) {
    cin >> u >> v >> w;
    add_edge(u, v, w), add_edge(v, u, w);
  }
  Prim();
  if (cnt == n)cout << res;
  else cout << "orz";
  return 0;
}