//   show raw.where(block: true): it => {
//     block(
//       width: 100%,
//       fill: luma(253),
//       inset: (x: 3pt, y: 5pt), // 调整左右内边距
//       radius: 2pt,
//       stroke: 1pt + luma(220),
//       breakable: true, // 建议保留，防止长代码截断
//     )[
//       #set text(font: ("Consolas","SimHei"), size: 12pt)
//       #grid(
//         columns: (auto, 1fr), // 第一列行号自适应，第二列代码占满
//         column-gutter: 0.5em, // 行号和代码之间的间距
//         row-gutter: 0.5em, 
//         // 遍历每一行
//         ..it.lines.enumerate().map(((i, line)) => (
//           // 行号部分：右对齐，灰色显示
//           align(right, text(fill: luma(150), [#raw(str(i + 1))])),
//           // 代码内容部分
//           line,
//         )).flatten()
//       )
//     ]
//   }
