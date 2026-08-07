// lib.typ

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
