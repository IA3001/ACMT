== #text("FastIO 模板")
#text(size: 0.72em, fill: gray)[来源：`Blog/src/content/posts/板子/FastIO.md`]

==== FastIO 模板（洛谷的某道势能分析暴力题）

===== 函数说明

- `gc()` 缓冲队列读入
- `read<T>()` 有符号读
- `write<T>()` 无符号写
- `print<T>(T x)` 有符号写
- `print<T>(T x, char c)` 有符号写 + 单字符

===== 注意

- 请特别处理 `INT_MIN` 和 `LLONG_MIN`，否则会发生有符号溢出。
- 使用 FastIO 时，建议彻底放弃 `cin`/`cout` 以及 `scanf`/`printf`。
- 若需输出字符串，用 `fwrite` 或 `putchar` 循环

===== Code

```cpp
namespace FastIO {
#define BUF (1 << 21)
char B[BUF], *l = B, *r = B;
#define gc() \
  (l == r && (l = B, r = (l + fread(B, 1, BUF, stdin))) == l ? EOF: *l++)
template <class  T> inline T read() {
  T x = 0;
  int f = 0;
  char c = gc();
  for (;c < '0' || c > '9'; c = gc()) f |= (c == '-');
  for (;'0' <= c && c <= '9'; c = gc()) x = x * 10 + (c ^ '0');
  return f ? -x : x;
}
char S[64], *p = S;
template <class T> inline void write(T x) {
  do {
    *++p = (x % 10) | '0';
    x /= 10;
  } while (x);
  while (p != S) putchar(*p--);
}
template <class T> inline void print(T x) {
  if (x < 0) {
    putchar('-');
    x = -x;
  }
  write<T>(x);
}
template <typename T> inline void print(T x, char c) {
  print<T>(x), putchar(c);
}
inline void swrite(const char* s, size_t len) {
    fwrite(s, 1, len, stdout);
}
}; // namespace FastIO
using namespace FastIO;
#undef gc()
```

