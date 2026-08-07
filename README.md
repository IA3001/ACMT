# ACM-XCPC Notebook

基于 [Typst](https://typst.app/) 编写的 ACM / ICPC / CCPC（XCPC）算法竞赛个人模板库。
所有内容按章节以 `.typ` 源文件组织，编译后生成带目录、页眉、页码的精美 PDF，可直接作为赛场上翻阅的「笔记本」。

## 快速开始

需要 [Typst](https://github.com/typst/typst/releases)（0.14 及以上），并已安装 `@preview/codly:1.3.0`（首次编译自动下载）。

```bash
# 编译 A 卷（第 01–05 章：基础 / 搜索 / DP / 字符串 / 数学）
typst compile mainA.typ mainA.pdf

# 编译 B 卷（第 06–11 章：数据结构 / 图论 / 计算几何 / 杂项 / 专题 / 附录）
typst compile mainB.typ mainB.pdf

# 或预览（自动重编译）
typst watch mainA.typ
```

## 目录结构

```
├── mainA.typ                # A 卷入口：第 01–05 章
├── mainB.typ                # B 卷入口：第 06–11 章
├── notebook.typ             # 共享排版骨架：模板调用 + 目录样式 + TODO 约定
├── config.typ               # 页面布局 / 字体 / 标题样式 / codly 代码块配置
├── lib.typ                  # 通用工具：#note、#theorem、#definition 等块与数学辅助
├── chapters/                # 正文章节（见下方章节列表）
│   ├── 01_basic.typ         # 算法基础
│   ├── 02_search.typ        # 搜索
│   ├── 03_dp.typ            # 动态规划
│   ├── 04_string.typ        # 字符串
│   ├── 05_math.typ          # 数学
│   ├── 05_math_numeric_theory.typ  # 数论自学笔记
│   ├── 06_ds.typ            # 数据结构
│   ├── 07_graph.typ         # 图论
│   ├── 08_geometry.typ      # 计算几何
│   ├── 09_others.typ        # 杂项
│   ├── 10_topics.typ        # 专题
│   └── 11_appendix.typ      # 附录（DBG 等）
├── code/                    # 独立 C++ 代码片段（如二次剩余、单纯形法）
├── develop/                 # 开发 / 验证中的板子（按章节分目录，含 r.bat 一键编译运行）
├── assets/                  # 图片素材
├── idea/                    # 思路笔记（如 网络流 vs 线性规划）
├── backup/                  # 历史快照备份（按日期分目录）
├── typora.tmTheme           # 代码高亮主题
```

## 章节一览

| 编号 | 章节 | 主要内容 |
|------|------|----------|
| 01 | 算法基础 | 复杂度、枚举、模拟、递归分治、贪心、排序 |
| 02 | 搜索 | DFS / BFS、剪枝、启发式 |
| 03 | 动态规划 | DP 理论、记忆化搜索、各类经典模型 |
| 04 | 字符串 | 字符串基础、标准库、匹配算法 |
| 05 | 数学 | 进制、数论、组合数学等（另附数论自学笔记） |
| 06 | 数据结构 | 栈、队列、线段树、平衡树、可持久化结构等 |
| 07 | 图论 | 最短路、网络流、树论、连通性等 |
| 08 | 计算几何 | 二维 / 三维几何基础 |
| 09 | 杂项 | 离散化、双指针、莫队、CDQ 等 |
| 10 | 专题 | RMQ、单调栈等专题整理 |
| 11 | 附录 | DBG 调试脚本等 |

## 排版与样式

- 页面：A4，页眉为书名，页脚为 `当前页 / 总页数`
- 标题：多级编号（`I.A.1.a.i`），一级标题为绿色色块、自动分页
- 代码块：`codly` 行号 + 斑马纹背景，`Consolas / SimHei` 等宽字体，`typora.tmTheme` 高亮
- 正文块：`lib.typ` 提供 `#note`、`#theorem`、`#definition`、`#example`、`#exercise` 等带侧边栏的提示块

## TODO 标记约定

正文中的 `TODO` 按严重程度分级（详见 `notebook.typ` 注释）：

- `TODO !`  写个公式即可，不大篇幅展开
- `TODO !!` 临时写的，需要后续细化
- `TODO !!!` 必须写板子 + 例题
- `TODO ?`  太难，当作科普了解

## 其他说明

- 新板子先放 `develop/` 下用 `r.bat`（`g++ -std=c++17`）验证，AC 后再精简进 `chapters/`
- 依赖外部包仅 `@preview/codly:1.3.0`，字体建议安装「思源黑体（Source Han Sans SC）」

## License

本项目以 [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.zh-hans)（署名—非商业性使用—相同方式共享 4.0 国际）协议发布，完整法律文本见 [LICENSE](LICENSE)。

- **署名**：使用时须保留作者署名
- **非商业**：不得用于商业用途
- **相同方式共享**：修改/衍生作品须以相同协议发布
