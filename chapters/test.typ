#import "../lib.typ": *

// 应用模板
#show: template.with(
  title: "Codly 完美代码块测试",
)

= 代码块功能演示

== 1. 基础 C++ 代码 (测试行号与高亮)
这里应该显示基础的行号、蓝色标题背景（如果识别了 cpp）以及斑马纹。

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

int main() {
    std::vector<int> v = {3, 1, 4, 1, 5, 9};
    std::sort(v.begin(), v.end());
    for (int x : v) {
        std::cout << x << " ";
    }
    return 0;
    // 12 3123 123 23 123 123 123 123 123 24 124234 23w545345 34234234 234 2342 3e42 341 323 234 
  cout<<"\n";
  cout<<"\n";
  cout<<"\n";
  cout<<"\n";
}
```

