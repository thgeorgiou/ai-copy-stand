// README banner, from the b1/b2 renders of guide/build.py.
//   typst compile --root . --ppi 150 guide/banner.typ renders/banner.png

#let accent = rgb("#e8730c")
#let ink = rgb("#222222")
#let muted = rgb("#6b6b6b")
#set page(width: 320mm, height: 120mm, margin: 0mm, fill: rgb(248, 248, 248))
#set text(font: ("Helvetica Neue", "Helvetica", "Arial"), fill: ink)

#grid(columns: (128mm, 1fr, 1fr), column-gutter: 0mm,
  block(width: 100%, height: 100%, fill: rgb("#f4f1ec"), inset: (x: 14mm, y: 16mm), {
    text(size: 11pt, weight: "bold", fill: accent, tracking: 1.2pt, upper("OpenSCAD · 3D printed"))
    v(2pt)
    text(size: 34pt, weight: "bold", [Film-scanning\ copy stand])
    v(8pt)
    text(size: 12.5pt, fill: muted,
      [A 2040 V-slot column on a bamboo board, a printed carriage on V-wheels, a Tr8 leadscrew and an Arca clamp. Sized for 35 mm frames on Micro Four Thirds at 1:2.2.])
    v(10pt)
    set text(size: 11pt)
    let chip(t) = box(fill: white, stroke: accent + 0.7pt, radius: 3pt, inset: (x: 6pt, y: 4pt), t)
    chip[7 printed parts] + h(5pt) + chip[260 mm of travel] + h(5pt) + chip[2 mm per turn]
  }),
  align(center + bottom, image("img/b1.png", height: 100%)),
  align(center + horizon, image("img/b2.png", height: 100%)),
)
