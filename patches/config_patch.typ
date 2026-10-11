#import "@preview/codly:1.3.0": *

#let template(title: "", compact: false, doc) = {
  let body-size = if compact { 9.2pt } else { 10pt }
  let code-size = if compact { 8.6pt } else { 10pt }
  let page-margin = if compact { (x: 0.7cm, y: 0.7cm) } else { (x: 1cm, y: 1cm) }

  // 1. 应用高亮主题 (对应文档中的 Path 字符串用法)
  set raw(theme: "../typora.tmTheme")
  
  // 所有的代码，包括 block 和 非 block
  show raw: set text(font: ("Consolas", "SimHei"), size: code-size)

  // 1. 设置基础字体
  set text(font: ("Source Han Sans SC", "SimHei"), size: body-size)

  // 2. Codly 布局配置 (负责行号、背景、边框)
  show: codly-init.with()
  codly(
    number-format: n => text(fill: luma(150), size: 8.5pt, str(n)),
    zebra-fill: luma(245),
    stroke: 1pt + luma(220),
    radius: 2pt,
    inset: (x: if compact { 2pt } else { 2.5pt }, y: if compact { 0.8pt } else { 2.3pt }),
    display-icon: false,
  )

  // 页眉配置
  set page(
    paper: "a4", 
    margin: page-margin, 
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
        set text(size: if compact { 13pt } else { 15pt })
        // 居中
        box(
          fill:green.lighten(60%),
          width:100%,
          height:2em,
          stroke: 1.5pt+gray,
          radius: 2pt,
          clip:true
        )[
          // 展示文字
          #align(center + horizon)[
            #prefix
            #it.body
          ]
        ]
      } else if it.level == 2 {
        // 二级标题逻辑：外加 【 】
        // 黑色 14
        set text(size: if compact { 12pt } else { 14pt })
        [#prefix 【#it.body】]
      } else {
        // 黑色 11
        set text(size: if compact { 10pt } else { 11pt },black.lighten(10%))
        // 三级及以后标题逻辑
        [#prefix #it.body]
      }
    }
  }

  // 显示正文(前面是配置)
  doc
}

