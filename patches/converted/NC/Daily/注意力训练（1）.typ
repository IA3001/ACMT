=== #text("Attention is all you need(1)")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/NC/Daily/注意力训练（1）.md`]

#quote(block: true)[
2026年9月20日
]

====== 阶乘正向平移

似乎有

$ n ! divides frac(\( n + k \) !, k !) $

卧槽这不就是组合数的整数证明吗：

$ 1 divides binom(n + k, k) arrow.l.r.double 1 divides frac(\( n + k \) !, n ! k !) arrow.l.r.double n ! divides frac(\( n + k \) !, k !) $

====== 最小/大生成树的定义

在无向图 $G$ 中 $upright("dis") \( u \, v \)$ 表示 $u \, v$ 之间所有可能的路径中 最大的 路径上最小边权，则给定一个排列 $a_i$ 使得 $sum_(i = 2)^n upright("dis") \( u \, v \)$ 取得最大时的结果等于 最大生成树的权值！

#quote(block: true)[
粗略证明：

选取最大的那个边，从他开始，为了连通，必然选取当前连通分量中，尽可能大的有效连接边，由于边权从大到小，所以dis始终等于新边的边权（类似以 prim 的方式求最大生成树），故为最大生成树
]

- 新领悟：Prim 最小生成树其实本质和 Dijkstra 是同源的因为：
  - Prim 是在 op=path\_min\_edge 下的算法
  - Dijkstra 是在 op=path\_min\_sum 下的算法
  - 都可以保证无后效性

===== 【高中复习】三维空间 四面体体积

```cpp
struct Vec3 {
    ll x,y,z;
    Vec3 operator%(Vec3 o) const {
        return {y*o.z-z*o.y,z*o.x-x*o.z,x*o.y-y*o.x};
    }
    ll operator*(Vec3 o) const {
        return x*o.x + y*o.y + z*o.z;
    }
    Vec3 operator-(Vec3 o) const {
        return {x-o.x,y-o.y,z-o.z};
    }
}p[4];

Vec3 OA = p[1] - p[0];
Vec3 OB = p[2] - p[0];
Vec3 OC = p[3] - p[0];
cout << abs((OA%OB)*OC) / 6 << "\n";
```

