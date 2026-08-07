// notebook.typ — A/B 卷共享的排版骨架：模板、目录样式、TODO 约定
#import "config.typ": *
#import "lib.typ": *

#let notebook(title: "", body) = {
  show: template.with(
    title: text(size: 1em)[#title]
  )

  // 目录样式定制
  // 1级目录：加粗蓝色 1/2
  show outline.entry.where(level: 1): it => {
    strong(
      text(
        blue.darken(100%),
        size: 1.2em,
        it
      )
    )
  }

  // 2级目录：无缩进 蓝色 1
  show outline.entry.where(level: 2): it => {
    strong(
      text(
        gray.darken(80%),
        size: 1em,
        it
      )
    )
  }

  // 3级目录：无缩进 0.8
  show outline.entry.where(level: 3): it => {
    text(
      gray.darken(70%),
      size: 0.8em,
      it
    )
  }

  // 4级目录：无缩进 1（默认样式，需要时取消注释）
  // show outline.entry.where(level: 4): it => {
  //   text(
  //     gray.darken(60%),
  //     size: 1em,
  //     it
  //   )
  // }

  // 目录调用 缩进 2 层级 3
  outline(
    indent: 2em,
    depth: 3,
    title: text(
      font: "Times New Roman",
      size: 1.5em
    )[Content]
  )

  pagebreak(weak: true)

  body
}

// TODO 标记约定（正文中的 TODO 按严重程度分级）
// TODO !   写个公式即可，不大篇幅展开
// TODO !!  临时写的，需要后续细化
// TODO !!! 必须写板子 + 例题
// TODO ?   太难，当作科普了解
