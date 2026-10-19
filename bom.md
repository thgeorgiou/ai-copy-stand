# Copy Stand — Bill of Materials & Design Brief

A vertical copy stand for macro/repro photography: a V-Slot column on a bamboo
baseboard, a 3D-printed carriage riding the extrusion on V-wheels, raised and
held by a self-locking leadscrew turned by hand.

## Camera
- **Olympus OM-3** (Micro Four Thirds, light body).
- Mounted via an **Arca-type quick-release plate** (Sirui **TY-C10**) left on the
  camera permanently; the carriage grips the plate's dovetail. The dovetail
  resists rotation far better than a single bolt — anti-twist for free.
- "Arca-type" standardizes only the **dovetail cross-section** (~38 mm wide faces
  at **45°**); plate length and exact width are **not** standardized, so design to
  the **measured** TY-C10, with jaw travel to absorb variance.

### TY-C10 plate dimensions (measured)
- Overall: width **39 mm** · depth **30 mm** · height **9 mm**
- **Dovetails run along the two SHORT (30 mm) edges**, symmetric on both; the two
  **long (39 mm) edges are flat**. The plate slides into the clamp **along the
  30 mm axis** (parallel to the dovetailed edges); the two jaws close **across the
  39 mm width**, each seating into one short-edge dovetail.
- **True dovetail cross-section** (undercut, NOT an outward flare). Tracing one
  edge from the base up: 3 mm vertical outer wall → 3 mm inward ledge → 45° face
  rising *inward* (narrowing) → 1 mm vertical to the top face. Top and base faces
  are the **same width**; the waist is pinched, the 45° faces undercut
  down-and-inward. Total height 9 mm.

```
  ┌───────────────────────────────────────────┐  ← top face (= base width)
  │ 1mm                                   1mm  │
  │      ╲                               ╱     │  ← 45° undercut faces
  │       ╲                             ╱      │     (jaw-tips seat here)
  │    ┌───┘                           └───┐   │  ← 3 mm inward ledge
  │    │3mm                            3mm │   │  ← 3 mm vertical outer wall
  └────┘                                   └───┘  ← base (camera-side down)
       ◄──────── undercut recess ────────►
```

- **Clamp jaws:** two 45° tips seating into the undercut recesses, pressing
  down-and-inward on the angled faces. Each jaw must **clear the 3 mm base wall +
  3 mm ledge** below the 45° face and not bottom out on the base. Grip faces =
  the two 45° diagonals; clamping span = **39 mm** (across the plate width).
- Safety-stop notch present on the dovetails — clamp can ignore / leave clearance.
- **Orientation marker:** 1/4"-20 screw protrudes on the camera-side face; plate
  is symmetric, so either edge can lead in.
- **Layout reference = camera optical axis**, not the plate.
- One **fixed reference jaw + one M5-tightened moving jaw** with a few mm travel.

---

## Purchased — in hand (GRobotronics order #262673) + Amazon

| Part | Spec | Qty | Role in design |
|---|---|---|---|
| V-Slot extrusion | 2040, natural anodized, **500 mm** | 1 | Structural column / rail |
| Leadscrew + plain nut | **Tr8×2** (2 mm lead, single-start), 500 mm, w/ brass flange nut | 1 | Vertical drive (Amazon, ~€20) |
| Anti-backlash nut | T8, 2 mm lead, brass, spring-loaded | 1 | Nut that goes in the carriage (kills bob) |
| Pillow block, flanged | **KFL08**, 8 mm bore, self-aligning | 2 | Screw bearings, top + bottom |
| V-wheel kit | Solid Delrin, incl. 2×625RS, shims, 6 mm spacer, M5×25, nylock | 4 | Carriage running gear (M5 axles) |
| Eccentric spacer | 6 mm, M5 | 2 | Preload/tram one wheel column |
| Drop-in T-nut | 2020-series, M5 | 20 | Mounting into extrusion slots |
| Low-profile bolt | M5, black, 8 mm | 10 | Extrusion mounting |
| Low-profile bolt | M5, black, 10 mm | 10 | Extrusion mounting |
| Low-profile bolt | M5, black, 12 mm | 10 | Extrusion mounting |
| Socket bolt | M5, DIN912 stainless, 25 mm | 3 | Longer clamping (wheels, brackets) |
| Socket bolt | M5, DIN912 stainless, 40 mm | 5 | Longer clamping |
| Socket bolt | M5, DIN912 stainless, 60 mm | 5 | Long clamping / standoffs |
| Hex nut | M5, 4 mm (H4) | 20 | General fastening |
| Corner bracket, cast 90° | for 20×30 mm profile | 3 | Anchor column to baseboard (see note) |
| Bolt | M3, DIN7985, 50 mm | 10 | Small printed-part fastening |
| Timing pulley | GT2, 20T, 8 mm bore | 2 | *For the film-holder project, not this build* |
| O-ring kit | NBR assortment, 225 pcs | 1 | Friction detents / feet / vibration damping |
| Copper tape | 12 mm × 30 m | 1 | *For the film-holder / shutter-tester project* |
| Baseboard | IKEA bamboo cutting board, ~**18 mm** thick | 1 | Base / copy surface |

---

## To PRINT (no purchase)

| Part | Key features |
|---|---|
| Camera carriage | 4× M5 wheel bosses (**back pair sized for eccentric spacers**); **tall wheelbase** for anti-nose-dive; floating pocket for anti-backlash nut flange; forward camera arm terminating in a **printed Arca clamp** (one fixed 45° reference face + one M5-tightened moving jaw), sized to the measured TY-C10 |
| Top bearing mount | Caps extrusion; holds KFL08; **slotted holes** to align screw parallel to beam |
| Bottom bearing mount + foot | Holds lower KFL08; clamps column to bamboo board; print high-infill |
| Knob / handwheel | Fits screw end (geometry TBD until screw inspected — see open items) |

---

## Open items / to verify

1. **Screw-to-knob interface (coupler?).** Inspect the top end of the Amazon
   spindle. Smooth 8 mm stub → knob/KFL08 ride it directly, no coupler. Fully
   threaded to the tip → print a knob that grips the Tr8 thread (or a T8 nut
   captured in the knob). Decide after it arrives.
2. **Anti-backlash nut flange pattern.** Design the carriage pocket to *this*
   nut's bolt circle, not the plain Amazon nut's.
3. **Threaded inserts (optional).** Heat-set M3/M5 brass inserts give durable
   threads in printed parts vs. tapping plastic. Not in order — nice to have.
4. **Travel check.** 500 mm screw gives full-column travel; confirm your min/max
   camera heights on the ~18 mm board sit within it.
5. **Corner brackets mismatch.** The 3× cast brackets are for **20×30**, not 2040.
   Don't rely on them for the main column anchor — prefer a printed foot gusset
   with a wide bolt footprint into the bamboo.

---

## Design constraints (hard-won — for the design agent)

- **Beam orientation:** 2040 with the **40 mm dimension front-to-back** (into the
  camera cantilever) for maximum bending stiffness where the load acts. Wheels
  ride the two 20 mm faces.
- **Wheel layout:** 4 wheels in a rectangle; **maximize vertical spread** (tall,
  narrow carriage) — the top/bottom wheel pairs form the couple that resists
  camera nose-dive. One vertical column of wheels on **eccentric spacers** for
  preload/tramming; the other on fixed spacers.
- **Leadscrew is a lifter only.** It carries vertical load and sets height; the
  extrusion + wheels carry all bending/twist. Keep the screw **as close to the
  beam** as the wheels allow to minimize the off-axis lifting moment.
- **Self-locking:** Tr8×2 lead angle ≈ 4.5° < friction angle → holds position
  hands-off. No brake needed.
- **Floating nut:** mount the anti-backlash nut to the carriage with a few tenths
  of lateral float (slightly oversized holes / compliant seat) so it self-centers
  on the screw rather than binding if the screw is slightly skewed.
- **Screw-parallel alignment:** the one precision job. Slot the top/bottom bearing
  mount holes so the screw can be trued parallel to the beam; KFL08 self-aligning
  inserts forgive the rest.
- **Arca clamp:** one fixed 45° reference face, one M5-tightened moving jaw with a
  few mm travel. Design to measured TY-C10, not to a spec number.
- **Cantilever:** camera arm short and deep, not long and thin. Consider a
  diagonal brace from the arm back to the carriage body.
