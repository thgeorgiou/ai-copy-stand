// Copy stand — assembly guide. One page per build step: instructions on the
// left, an annotated render on the right.
//
//   python3 guide/build.py                       # renders img/*.png + *.json
//   typst compile guide/guide.typ guide/assembly_guide.pdf

#let accent = rgb("#e8730c")
#let ink = rgb("#222222")
#let muted = rgb("#6b6b6b")
#let panel = rgb("#f4f1ec")
#let imgbg = rgb(248, 248, 248)
#let font = ("Helvetica Neue", "Helvetica", "Arial", "Libertinus Serif")

#set page(width: 320mm, height: 180mm, margin: 0mm, fill: imgbg)
#set text(font: font, size: 12pt, fill: ink)
#set par(leading: 0.6em)

// ---------------------------------------------------------------- callouts
#let bubble(n) = box(baseline: 20%, circle(radius: 0.62em, fill: accent, stroke: none,
  align(center + horizon, text(fill: white, weight: "bold", size: 0.82em, n))))

#let label-box(t) = {
  let m = t.match(regex("^(\d+)(?:  (.*))?$"))
  let body = if m == none { text(size: 10.5pt, t) } else if m.captures.at(1) == none {
    bubble(m.captures.at(0))
  } else {
    bubble(m.captures.at(0)) + h(4pt) + text(size: 10.5pt, m.captures.at(1))
  }
  box(fill: white.transparentize(8%), stroke: accent + 0.7pt, radius: 4pt,
      inset: (x: 5pt, y: 4pt), body)
}

#let arrow(a, b, k) = {
  let (x1, y1) = (a.at(0) * k, a.at(1) * k)
  let (x2, y2) = (b.at(0) * k, b.at(1) * k)
  let ang = calc.atan2((x2 - x1) / 1pt, (y2 - y1) / 1pt)
  let hl = 9pt
  let p1 = (x2 - hl * calc.cos(ang + 25deg), y2 - hl * calc.sin(ang + 25deg))
  let p2 = (x2 - hl * calc.cos(ang - 25deg), y2 - hl * calc.sin(ang - 25deg))
  place(line(start: (x1, y1), end: (x2, y2), stroke: (paint: accent, thickness: 2.2pt, cap: "round")))
  place(polygon(fill: accent, (x2, y2), p1, p2))
}

#let figure-panel(id, size) = {
  let d = json("img/" + id + ".json")
  let k = size / d.w
  box(width: size, height: size, {
    place(image("img/" + id + ".png", width: size))
    for l in d.lines {
      place(line(start: (l.at(0).at(0) * k, l.at(0).at(1) * k),
                 end: (l.at(1).at(0) * k, l.at(1).at(1) * k),
                 stroke: (paint: muted, thickness: 0.7pt, dash: "dashed")))
    }
    for a in d.arrows { arrow(a.at(0), a.at(1), k) }
    for lb in d.labels {
      let (px, py) = (lb.p.at(0) * k, lb.p.at(1) * k)
      let (ex, ey) = (lb.end.at(0) * k, lb.end.at(1) * k)
      place(line(start: (px, py), end: (ex, ey), stroke: accent + 0.9pt))
      place(dx: px - 2.2pt, dy: py - 2.2pt, circle(radius: 2.2pt, fill: accent, stroke: white + 0.6pt))
    }
    for lb in d.labels {
      if lb.text != "" {
        let (ex, ey) = (lb.end.at(0) * k, lb.end.at(1) * k)
        context {
          let b = label-box(lb.text)
          let m = measure(b)
          place(dx: ex - m.width / 2, dy: ey - m.height / 2, b)
        }
      }
    }
  })
}

// ---------------------------------------------------------------- page types
#let step-counter = counter("step")

#let need-box(items) = block(width: 100%, fill: white, radius: 5pt, inset: 9pt,
  stroke: rgb("#ddd6cb") + 0.6pt, {
    text(size: 9.5pt, weight: "bold", fill: muted, tracking: 0.5pt, upper("You need"))
    v(3pt)
    set text(size: 10.5pt)
    grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 4pt,
      ..items.map(i => (text(weight: "bold", i.at(0)), i.at(1))).flatten())
  })

#let steps(..items) = {
  let xs = items.pos()
  for (i, x) in xs.enumerate() {
    grid(columns: (1.6em, 1fr), column-gutter: 4pt, bubble(str(i + 1)), x)
    v(5pt, weak: true)
  }
}

#let tip(body) = block(width: 100%, inset: (left: 9pt, y: 5pt), stroke: (left: accent + 2.5pt),
  text(size: 10.5pt, body))

#let check(body) = block(width: 100%, inset: (left: 9pt, y: 5pt), stroke: (left: rgb("#3c8d4f") + 2.5pt),
  text(size: 10.5pt, [*Check:* ] + body))

#let step(title, img, need: (), body) = {
  step-counter.step()
  grid(columns: (128mm, 1fr),
    block(width: 100%, height: 100%, fill: panel, inset: (x: 11mm, y: 10mm), {
      context text(size: 11pt, weight: "bold", fill: accent, tracking: 1pt,
        upper("Step " + str(step-counter.get().first())))
      v(-4pt)
      text(size: 21pt, weight: "bold", title)
      v(6pt)
      if need.len() > 0 { need-box(need); v(6pt) }
      body
    }),
    align(center + horizon, figure-panel(img, 172mm)))
  pagebreak(weak: true)
}

// ================================================================ content

// ---- cover
#grid(columns: (128mm, 1fr),
  block(width: 100%, height: 100%, fill: panel, inset: (x: 11mm, y: 12mm), {
    text(size: 11pt, weight: "bold", fill: accent, tracking: 1pt, upper("Assembly guide"))
    v(-2pt)
    text(size: 30pt, weight: "bold", [Film-scanning copy stand])
    v(4pt)
    text(fill: muted, [2040 V-slot column on an APTITLIG board, printed carriage on V-wheels, Tr8 leadscrew, Arca clamp for the Sirui TY-C10.])
    v(10pt)
    text(weight: "bold", [Tools])
    v(2pt)
    set text(size: 10.5pt)
    list(
      [Hex keys 2.5, 3 and 4 mm (M3 socket, M5 low-profile, M5 socket heads)],
      [8 mm spanner for M5 nuts, and one to fit the eccentric spacers' hex],
      [Drill with 5.5 mm and 2.5 mm bits for the board],
      [A vice or clamp and a socket of about 14 mm, to press the bearings],
      [Ruler or calipers, a small square, a marker],
    )
    v(6pt)
    tip[Hardware sizes are in the step that uses them. Pages show the new parts in *orange*; parts fitted earlier are beige.]
    v(4pt)
    tip[*Left and right* are as seen from the front, where you stand to use it. The carriage rides on the beam's left-hand face; the brackets and the clamp knob are on the right.]
  }),
  align(center + horizon, figure-panel("s00", 172mm)))
#pagebreak()

// ---- parts
#grid(columns: (128mm, 1fr),
  block(width: 100%, height: 100%, fill: panel, inset: (x: 11mm, y: 10mm), {
    text(size: 21pt, weight: "bold", [Parts and hardware])
    v(4pt)
    set text(size: 10pt)
    let row(a, b, c) = (a, b, c)
    table(columns: (auto, 1fr, auto), stroke: none, inset: (x: 3pt, y: 2.6pt),
      table.header(text(weight: "bold", [Qty]), text(weight: "bold", [Hardware]), text(weight: "bold", [Where])),
      table.hline(stroke: 0.5pt + muted),
      [5], [M5×30 socket head], [wheels, clamp],
      [4], [M5×25 socket head], [KFL08s],
      [3], [M5×60 socket head], [board, crank],
      [8], [M5×10 low-profile], [brackets],
      [5], [M5×12 low-profile], [foot],
      [13], [M5 drop-in T-nut], [foot, brackets],
      [10], [M5 nut], [KFL08s, board, clamp, crank],
      [10 + 2], [M5 washer + 2 large ones], [KFL08s, under the board],
      [4], [M3×12–16], [anti-backlash nut],
      [4], [M3×8–10], [brass nut],
      [1 + 1], [M3×10 + M3 nut], [handwheel lock],
      [4], [3.5×16 countersunk wood screw], [feet],
      table.hline(stroke: 0.5pt + muted),
      [4], [V-wheel kits: wheel, 2 bearings, shim, nylock], [],
      [2 + 2], [fixed + eccentric spacers], [],
      [2], [KFL08 pillow blocks], [],
      [1 + 1], [Tr8×2 screw + its brass nut, anti-backlash nut], [],
      [1], [2040 V-slot, 500 mm; APTITLIG board], [],
    )
    v(2pt)
    text(size: 10pt, fill: muted, [The wheel kits' M5×25 bolts are too short for the carriage; use M5×30.])
  }),
  align(center + horizon, figure-panel("s01", 172mm)))
#pagebreak()

#step([Press the bearings into the wheels], "s02",
  need: (([×4], [V-wheels, each with 2 bearings and 1 shim]),))[
  #steps(
    [Press a bearing into one face until it stops on the centre lip. Push on the *outer ring* only.],
    [Turn the wheel over and drop the shim in. It lies on the first bearing's inner ring, inside the lip.],
    [Press the second bearing in until it's flush with the face.],
  )
  #v(6pt)
  #tip[In a vice, with a socket just smaller than the bearing behind it. Or pull it in with an M5 bolt, a nut and a big washer over the outer ring. Never hammer on the seal.]
  #check[On a bolt with the nut done up hard, the wheel still spins freely. If it goes stiff, the shim is missing.]
]

#step([Fit the bolt into the knob], "s03",
  need: (([P4], [knob]), ([1×], [M5×30 socket head])))[
  #steps(
    [Push the M5×30 in from the pocket side of the knob.],
    [Press the head home in a vice, or tap it in on a hard surface. It sits flush, gripped by the ribs.],
  )
  #v(6pt)
  #check[The bolt doesn't turn in the knob when you twist it.]
]

#step([Fit the foot to the beam], "s04",
  need: (([P6], [foot]), ([5×], [M5 drop-in T-nuts]), ([5×], [M5×12 low-profile])))[
  #steps(
    [Drop a T-nut into each slot near the bottom of the beam: both slots on each side face, and the one on the *back*. Twist each one so it locks across the slot.],
    [Slide the foot up over the bottom end of the beam. The beam's end sits flush with the foot's base, so both stand on the board.],
    [Bolt through the collar into each T-nut, sliding the T-nut under its hole first. Snug only for now.],
  )
  #v(6pt)
  #tip[The front face (the one with a single slot, facing you) stays clear: the leadscrew and film holder are on that side.]
  #check[Stand it on a flat table while you tighten, so the beam end and the foot's base both touch.]
]

#step([Bolt the foot to the board], "s05",
  need: (([2×], [M5×60 socket head]), ([2×], [M5 nuts + large washers]), ([], [5.5 mm drill])))[
  #steps(
    [Stand the foot on the board, centred left–right, back edge 4 mm from the board's back edge. Mark through the two bosses and drill 5.5 mm. The holes end up 30 mm from the back edge and 179 mm from each side.],
    [M5×60 down through each boss, then a large washer and a nut underneath.],
  )
  #v(6pt)
  #tip[Drill from the top with a scrap block under the board, so the bamboo doesn't split out on the underside.]
  #check[The beam stands square to the board in both directions. If not, shim under the foot.]
]

#step([Fit the feet], "s05b",
  need: (([P8], [4× foot]), ([4×], [3.5×16 countersunk wood screws]), ([], [2.5 mm drill])))[
  #steps(
    [Lay the stand on its side. Mark a foot centre 25 mm in from both edges at each corner.],
    [Drill 2.5 mm pilot holes, about 11 mm deep. Tape on the bit as a depth stop: the board is only 15 mm thick.],
    [Screw each foot on, counterbore facing the floor.],
  )
  #v(6pt)
  #tip[No drill? The top of each foot is flat, so glue or VHB tape works too.]
  #check[Stood up, the board sits on all four feet without rocking, and the board-bolt nuts don't touch the table (4.5 mm clear).]
]

#step([Fit the bottom bearing bracket], "s06",
  need: (([P5], [bearing bracket]), ([4×], [M5 drop-in T-nuts]), ([4×], [M5×10 low-profile])))[
  #steps(
    [Put two T-nuts into each slot on the beam's *right-hand* face (seen from the front), about 40–55 mm up.],
    [Bolt through the skirt's four recessed holes into the T-nuts, loosely.],
    [The bracket hooks round the beam's two right-hand corners. Slide it until the plate's underside is *60 mm* above the board and level, then tighten.],
  )
  #v(6pt)
  #tip[Cut a 60 mm block, or stack something that height, to rest the bracket on while you tighten. The film holder (50 mm) slides in under it later.]
]

#step([Fit the bottom KFL08], "s07",
  need: (([1×], [KFL08]), ([2×], [M5×25 socket head]), ([2×], [M5 nuts]), ([4×], [M5 washers])))[
  #steps(
    [Set the KFL08 on the bracket's front plate, housing up, over the big hole.],
    [M5×25 with a washer down through each ear.],
    [Washer and nut underneath. Only *finger tight*: the holes are oversized so the bearing can line itself up with the screw in step 16.],
  )
  #v(6pt)
  #tip[If the bearing collar has set screws, back them out. They'd chew the leadscrew's thread.]
]

#step([Fit the anti-backlash nut], "s08",
  need: (([P1], [carriage]), ([1×], [anti-backlash nut]), ([4×], [M3×12–16])))[
  #steps(
    [Nut *flange up*, with everything else (body, spring and end piece) hanging down into the bore in the tower.],
    [Press the flange down onto its seat against the spring and turn it so its holes line up with the four pilot holes.],
    [Start two opposite M3s first while holding the flange down, then the other two. They cut their own thread in the plastic: drive slowly and stop as soon as the flange is clamped.],
  )
  #v(6pt)
  #tip[Do this before fitting the wheels. The upper front wheel covers the two back screws.]
]

#step([Assemble the clamp], "s09",
  need: (([P3], [moving jaw]), ([P4], [knob with its bolt]), ([1×], [M5 nut])))[
  #steps(
    [Drop the M5 nut into the slot in the top of the clamp body, in front of the nut tower. Push it down until it lines up with the bolt hole.],
    [Slide the moving jaw into its channel, tip facing the clamp face.],
    [Screw the knob's bolt through the jaw into the nut. A few turns is enough for now.],
  )
  #v(6pt)
  #check[The jaw slides freely in its channel and the knob pushes it in smoothly.]
]

#step([Fit the wheels to the carriage], "s10",
  need: (([4×], [wheels from step 1]), ([4×], [M5×30 socket head]), ([2 + 2], [fixed + eccentric spacers]), ([4×], [shims + nylocks])))[
  #steps(
    [Bolts in from the plate's outer face. The heads drop into the recesses.],
    [*Front* holes (next to the leadscrew): fixed spacers. *Back* holes (the larger ones): eccentric spacers, round boss into the hole.],
    [Wheel on each bolt.],
    [Shim, then nylock. Tighten the front pair. Leave the back pair just snug, so a spanner still turns the eccentric.],
  )
  #v(6pt)
  #tip[Start both eccentrics with their thick side pointing at the front wheel: that's the widest setting, so the carriage goes on easily.]
]

#step([Put the carriage on the beam], "s11",
  need: (([], [carriage from steps 7–10]), ([], [spanner for the eccentric hex])))[
  #steps(
    [Turn both eccentrics by the same amount until the carriage doesn't rock when you twist it, the wheels stand upright, and it still rolls freely. You can just stop a wheel with a finger.],
    [Slide the carriage on from the *top* end: clamp facing the front, wheel plate on the left-hand face, knob on the right. It rolls down until it stops on the bottom bracket.],
  )
  #v(6pt)
  #tip[Hold the eccentric with the spanner while you tighten its nylock, then check the feel again.]
  #check[Too tight: wheels tilt outward, rolling drags. Too loose: it clicks or rocks.]
]

#step([Fit the top bracket], "s12",
  need: (([P5], [second bearing bracket]), ([4×], [T-nuts + M5×10 low-profile]), ([1×], [KFL08 + 2× M5×25, nuts, washers])))[
  #steps(
    [Rest the bracket's plate on the top end of the beam, hooked round the same two right-hand corners.],
    [T-nuts into the right-hand face's slots and bolts through the skirt, as in step 5. Tighten.],
    [KFL08 on top, bolts as in step 6, finger tight.],
  )
  #v(6pt)
  #tip[Slide the carriage up and down once more. It must not touch either bracket within the range you'll use.]
]

#step([Feed in the leadscrew], "s13",
  need: (([1×], [Tr8×2 leadscrew, 500 mm]),))[
  #steps(
    [Feed the screw down through the top KFL08 and the bracket.],
    [Lift the carriage until its nut meets the screw. Turn the screw clockwise (seen from above) to thread it through the nut.],
    [Carry on down into the bottom KFL08 until the screw's end is flush with the bracket's underside.],
  )
  #v(6pt)
  #tip[About 37 mm stands above the top bearing. That's for the handwheel.]
]

#step([Fit the brass nut into the handwheel], "s14",
  need: (([P7], [handwheel]), ([1×], [the screw's brass nut]), ([4×], [M3×8–10])))[
  #steps(
    [Turn the handwheel over. Push the brass nut, body first, into the hub pocket. Its ring faces out: it's what rests on the bearing.],
    [Four M3s through the flange into the hub, snug.],
  )
  #v(6pt)
  #check[The flange sits flat in its pocket and the ring stands 1 mm proud of the wheel.]
]

#step([Fit the lock screw and crank], "s15",
  need: (([1×], [M3×10 + M3 nut]), ([1×], [M5×60]), ([3×], [M5 nuts]), ([1×], [crank sleeve])))[
  #steps(
    [Drop the M3 nut into the slot in the top of the hub.],
    [Start the M3×10 from the outside, through the nut. Stop before it reaches the bore.],
    [M5×60 up through the rim from below, head in the recess.],
    [Nut on top of the rim, tight: the bolt mustn't turn. Then slide the sleeve on.],
    [Two nuts above the sleeve, locked against each other. Leave a little play so the sleeve spins.],
  )
]

#step([Fit the handwheel], "s16",
  need: (([], [handwheel from steps 13–14]), ([], [2.5 mm hex key])))[
  #steps(
    [The brass nut's ring rests on the KFL08's inner ring.],
    [Hold the screw and turn the handwheel to thread it down, until the ring sits on the inner ring.],
    [Tighten the M3 lock screw against the thread. The wheel now turns the screw.],
  )
  #v(6pt)
  #check[Turning the handwheel moves the carriage 2 mm per turn, and the carriage stays where you leave it.]
]

#step([Line up and tighten the bearings], "s17",
  need: (([], [4 mm hex key, 8 mm spanner]),))[
  #steps(
    [Wind the carriage near the top. Tighten the top KFL08's bolts where the bearing has settled.],
    [Wind it near the bottom. Tighten the bottom KFL08's bolts the same way.],
  )
  #v(6pt)
  #check[Run the full travel: no tight spots and the screw doesn't whip. If one end binds, loosen that bearing, let it settle, and retighten.]
  #tip[Carriage centre travels from about 160 to 420 mm. The brackets are the end stops, so don't wind hard into them. An O-ring on the screw at each end makes a good bumper.]
]

#step([Camera and film holder], "s18",
  need: (([], [camera with the TY-C10 plate]), ([], [film holder]),))[
  #steps(
    [Open the knob about four turns.],
    [Lower the plate in from the top, lens down, until it rests on the stop pin. Close the knob firmly.],
    [Slide the film holder in under the bottom bracket. The frame goes under the lens, with the holder's back edge about 15 mm in front of the beam.],
  )
  #v(6pt)
  #tip[For a full 35 mm frame on Micro Four Thirds (about 1:2.2), the carriage centre sits near 284 mm above the board. Focus with the handwheel: 2 mm per turn.]
]
