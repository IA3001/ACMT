// main.typ 

#import "config.typ": *
#import "lib.typ": *


#show: template.with(
  title: text(
    size:1em
    )[ACM-XCPC Notebook]
)

// 目录样式定制
// 1级目录：加粗蓝色 1/2
#show outline.entry.where(level: 1): it =>{
  strong(
    text(
      // font:"Arial",
      blue.darken(100%),
      size:1.2em, 
      it
    )
  )
}

// 2级目录：无缩进 蓝色 1
#show outline.entry.where(level: 2): it => {
  strong(
    text(
      // font:"Times New Roman",
      gray.darken(80%),
      size:1em,
      it
    )
  )
}

// 3级目录：无缩进 0.8
#show outline.entry.where(level:3): it => {
  text(
    // font:"Times New Roman",
    gray.darken(70%),
    size:0.8em,
    it
  )
}

// 4级目录：无缩进 1
// #show outline.entry.where(level:4): it => {
//   text(
//     // font:"Times New Roman",
//     gray.darken(60%),
//     size:1em,
//     it
//   )
// }

// 目录调用 缩进 2 层级 3
#outline(
  indent: 2em,
   depth: 3,
   title:text(
    font:"Times New Roman",
    size:1.5em
    )[Content]
  )

#pagebreak(weak: true)

// 按大类包含子文件
// #include "chapters/test.typ"

// #include "chapters/01_basic.typ"
// #include "chapters/02_search.typ"
// #include "chapters/03_dp.typ"
// #include "chapters/04_string.typ"
// // #include "chapters/05_math_numeric_theory.typ"
// #include "chapters/05_math.typ"

#include "chapters/06_ds.typ"
#include "chapters/07_graph.typ"
#include "chapters/08_geometry.typ"
#include "chapters/09_others.typ"
#include "chapters/10_topics.typ"
#include "chapters/11_appendix.typ"

// #pagebreak(weak:true)
// #note(title:"PS")[
//   - TODO ! 是写个公式 不大篇幅展开
//   - TODO !! 是临时写的 需要后续细化
//   - TODO !!! 是 必须 写个板子 写点题目
//   - TO DO ? 是 太难当作科普
//   - TO DO 是个累赘 考虑当前暂时不想写了 放这里
// ]

