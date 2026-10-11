=== #text("VP：Autumn（1）2026上海市赛")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/VP/Autumn（1）.md`]

===== A. 序列【爆搜】

#quote(block: true)[
样例诈骗我 让我以为全部都是 Yes
]

- 一开始用的 `vector<int>` 存方案，
- 然后用的 string 还是 tle，
- 最终用链表代替拷贝，
- 发现一个细节：
  - 把原来的 `int val;`
  - 改成 `char val;`
  - 由于内存对齐，其实占用空间没有减少

```cpp
void init() {
//  auto st = clock();
    mp[0][0] = 0;
    for (int i = 1; i < 61;i++) {
        for (int j = 0; j + i < 61; j++) {
            int nj = j + i;
            for(auto& [x, id]: mp[j]) {
                __int128 nx = ((__int128)x << i) + (((1ll << i) - 1) <<  j);
                if(nx < inf && !mp[nj].count(nx)) {
                    int& tmp = mp[nj][nx]; 
                    tmp = ++cnt;
                    p[tmp] = {i, id};
                }
            }           
        }
    }
//  cout << clock() - st << "\n";
}
```

