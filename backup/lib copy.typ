// lib.typ

// 导入 codly 
// #import "@preview/codly:1.3.0": *

#let pmod(x) = $quad (mod #x)$
// #let St2(i,j) = $"St"_2(#i,#j)$
// #let St1(i,j) = $"St"_1(#i,#j)$
// 第一类斯特林数 (Square brackets)
#let St1(n, k) = $vec(delim: "[", #n, #k)$

// 第二类斯特林数 (Curly braces)
#let St2(n, k) = $vec(delim: "{", #n, #k)$

#let note(body, title: "", color: luma(200)) = block(
  fill: luma(252),
  inset: (x: 10pt, y: 8pt),
  radius: 3pt, 
  stroke: (left: 3pt + color), 
  width: 100%,
  breakable: true, // 允许跨页
  [
    #if title != "" [ 
      *#box(
      // stroke: 0.5pt,
      fill:gray.lighten(80%),
      inset: (x: 0.8em, y: 0.3em), // x 是左右，y 是上下
    )[#title]*

      #body
    ] else [
      #body
    ]
  ]
)

// 基于 note 扩展出特定类型的块
#let theorem(body) = note(body, title: "Theorem.", color: blue)
#let definition(body) = note(body, title: "Definition.", color: orange)
#let example(body) = note(body, title: "Example.", color: green)
#let exercise(body) = note(body, title: "Exercise.", color: gray)

#let template(title: "", doc) = {

  // 正文文本 字体 和 大小
  set text(font: ("Source Han Sans SC", "SimHei"), size: 10pt)
  // 所有的代码，包括 block 和 非 block
  show raw : set text(font: ("Consolas","SimHei"), size: 10pt)

  // 代码块重写 
  // 
  // 1. codly 配置版 但是很遗憾 好像性能弱 并不能防止选行号
  // show: codly-init.with()
  // codly(
  //   number-format: n => text(fill: gray, size: 8.5pt, str(n)),
  //   zebra-fill: luma(250),
  //   stroke: 0.5pt + luma(220),
  //   radius: 4pt,
  //   display-icon: false,
  //   display-name: false,
  //   smart-indent: true,
  // )
  // 
  // 
  
  // 2. codly 平替
  show raw.where(block: true): it => {
  block(
    width: 100%,// 占满宽度
    fill: luma(253),// 填充淡白色
    radius: 2pt,// 四角圆滑
    stroke: 1pt + luma(220),// 轮廓线灰色
    breakable: true,// 代码块可以跨页
    clip: true, // 防止背景超出圆角
  )[
    // #show raw : set text(font: ("Consolas","SimHei"), size: 10pt)
    #grid(
      columns: (auto, 1fr),// 自动两列
      // 通过 row 索引设置背景色
      fill: (col, row) => if calc.even(row) {
        none // 偶数行（第一行 row=0）透明
      } else {
        luma(245) // 奇数行（第二行 row=1）浅灰色
      },
      inset: (x: 3pt, y: 3pt), // 将内边距 grid 中，确保填充色覆盖完整
      // 遍历每一行
      ..it.lines.enumerate().map(((i, line)) => (
        // 行号列：右对齐，带右边距
        align(right, text(fill: luma(150), [#raw(str(i + 1))])),
        // 代码列
        line,
      )).flatten()
    )
  ]
}

  // 页眉配置
  set page(
    paper: "a4", 
    margin: (x: 1cm, y: 1cm), 
    header: context {
    align(center,text(8pt, gray)[#title])
    },
    footer: context {
      // 获取当前页码
      let current = counter(page).display()
      // 获取总页数 (final() 返回一个数组，at(0) 取第一个元素)
      let total = counter(page).final().at(0)
      align(center, text(8pt, black)[#current / #total])
    }
  )

  // 设置标题的级别编号
  set heading(numbering: "I.A.1.a.i")

  // 设置标题具体级别的 外观
  show heading: it => {
    if it.numbering == none { return it }
    context {
      let nums = counter(heading).at(it.location())
      let prefix = if nums.len() > 0 { numbering(it.numbering, ..nums) } else { "" }
      
      if it.level == 1 {
        // 另起一页
        pagebreak(weak: true)
        // 15
        set text(size: 15pt)
        // 居中
        set align(center+horizon)
        box(
          fill:green.lighten(60%),
          width:100%,
          height:2em,
          stroke: 1.5pt+gray,
          radius: 2pt,
          clip:true
        )[
          // 展示文字
          #prefix 
          #it.body
        ]
      } else if it.level == 2 {
        // 二级标题逻辑：外加 【 】
        // 黑色 14
        set text(size: 14pt)
        [#prefix 【#it.body】]
      } else {
        // 黑色 11
        set text(size: 11pt,black.lighten(10%))
        // 三级及以后标题逻辑
        [#prefix #it.body]
      }
    }
  }

  // 显示正文(前面是配置)
  doc
}

