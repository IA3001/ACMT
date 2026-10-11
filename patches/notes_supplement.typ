= Notes 补充结论

#image("assets/notes_writing_grid.svg", width: 100%, height: 258mm)

#let supplement-page(number) = {
  pagebreak()
  place(top + left, dx: 0pt, dy: 0pt)[
    #text(size: 8pt, fill: gray)[Notes 补充结论 #number]
  ]
  image("assets/notes_writing_grid.svg", width: 100%, height: 100%)
}

#for number in range(2, 9) {
  supplement-page(number)
}
