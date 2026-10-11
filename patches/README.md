# ACMT 扩展卷

扩展卷把 Blog 内容整理成三册独立的 Typst 文档，原 ACMT A、B 册保持不变。当前发布版包含：

| 册 | 内容 | 页数 |
|---|---|---:|
| CONTEST | NC、HDU、NEU、VP、CF 等比赛记录与补题 | 263 |
| ALGO | 图论、数据结构与图上建模等手写算法笔记 | 199 |
| Notes / Others | 标签专题、算法专题集合及 FastIO | 235 |

Notes / Others 卷末尾含 8 页浅灰点阵补充页，便于打印后手写新结论。

## 编译

需要 Typst 0.14 及以上，并安装 `@preview/codly:1.3.0`。在仓库根目录执行：

```bash
typst compile mainPatchContest.typ mainPatchContest.pdf
typst compile mainPatchAlgo.typ mainPatchAlgo.pdf
typst compile mainPatchNotes.typ mainPatchNotes.pdf
```

三个 `mainPatch*.typ` 是各册入口；`patches/01_contest.typ`、`02_algo.typ`、`03_notes.typ`、`04_others.typ` 及其下级 include 文件记录最终章节顺序。请直接编辑这些 include 文件维护目录顺序。`build_extension.mjs` 是早期迁移工具，不应在发布稿上重新生成目录。

图片资源已复制到 `patches/assets/`，编译不依赖 Blog 工作区。

## 许可

本扩展卷遵循仓库的 [CC BY-NC-SA 4.0](../LICENSE) 许可。
