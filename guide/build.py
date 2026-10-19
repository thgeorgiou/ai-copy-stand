#!/usr/bin/env python3
"""Renders the assembly guide's pictures and their callout positions.

For every step: writes build/<id>.scad, renders img/<id>.png with OpenSCAD
(ortho camera), and writes img/<id>.json with the callouts projected to
pixel coordinates for guide.typ to draw on top.

    python3 guide/build.py            # all steps
    python3 guide/build.py s04 s05    # just these
"""
import json, math, os, re, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
BUILD = os.path.join(HERE, "build")
IMG = os.path.join(HERE, "img")
W = H = 1400
FOV = 22.5

# ---------------------------------------------------------------- params
def load_params():
    out = os.path.join(BUILD, "p.echo")
    subprocess.run(["openscad", "-o", out, os.path.join(BUILD, "params_echo.scad")],
                   capture_output=True, check=True)
    return json.loads(re.search(r"PARAMS(\{.*\})PARAMS", open(out).read()).group(1))

P = load_params()

# ---------------------------------------------------------------- projection
def _rot(axis, a):
    a = math.radians(a); c, s = math.cos(a), math.sin(a)
    return {"x": [[1, 0, 0], [0, c, -s], [0, s, c]],
            "y": [[c, 0, s], [0, 1, 0], [-s, 0, c]],
            "z": [[c, -s, 0], [s, c, 0], [0, 0, 1]]}[axis]

def _mul(m, v): return [sum(m[i][j] * v[j] for j in range(3)) for i in range(3)]

def cam(center, az, el, half):
    """Eye at azimuth az (deg from +x, in plan) and elevation el, looking at
    center; half = half the visible height in mm."""
    return [*center, 90 - el, 0, az + 90, half / math.tan(math.radians(FOV / 2))]

def project(p, c, W=W, H=H):
    cx, cy, cz, rx, ry, rz, dist = c
    q = [p[0] - cx, p[1] - cy, p[2] - cz]
    q = _mul(_rot("z", -rz), q); q = _mul(_rot("y", -ry), q); q = _mul(_rot("x", 90 - rx), q)
    h = dist * math.tan(math.radians(FOV / 2))
    return [round(W / 2 + q[0] / h * H / 2, 1), round(H / 2 - q[2] / h * H / 2, 1)]

# ---------------------------------------------------------------- scene building
AX = {"+x": (1, 0, 0), "-x": (-1, 0, 0), "+y": (0, 1, 0), "-y": (0, -1, 0),
      "+z": (0, 0, 1), "-z": (0, 0, -1)}
NEW = "[1.0, 0.50, 0.05]"      # printed part added in this step
OLD = "[0.86, 0.80, 0.72]"     # printed part already fitted

def add(a, b, k=1): return [a[i] + k * b[i] for i in range(3)]

class Step:
    def __init__(self, sid, camera, size=(W, H)):
        self.id, self.cam = sid, camera
        self.w, self.h = size
        self.scad, self.labels, self.lines, self.arrows = [], [], [], []

    def s(self, code):
        self.scad.append(code); return self

    def part(self, code, new=True, at=(0, 0, 0)):
        return self.s(f"color({NEW if new else OLD}) translate({list(at)}) {code}")

    def hw(self, code, pos, axis, explode=0, guide=True):
        """Fastener `code` (modelled on -z) at pos, going in along axis,
        drawn pulled back by explode with a dashed guide back to its place."""
        d = AX[axis]
        at = add(pos, d, -explode)
        self.s(f"translate({at}) along(\"{axis}\") {code}")
        if explode and guide:
            self.lines.append((at, pos))
        return at

    def label(self, p, text, dx, dy):
        self.labels.append((p, text, dx, dy)); return self

    def arrow(self, a, b):
        self.arrows.append((a, b)); return self

    def line(self, a, b):
        self.lines.append((a, b)); return self

    def _labels(self):
        """Label boxes sit at point + (dx, dy) px. A label with empty text
        is an extra leader to the previous label's box."""
        out, last = [], None
        for p, t, dx, dy in self.labels:
            px = project(p, self.cam, self.w, self.h)
            if t == "" and last:
                out.append({"p": px, "end": last, "text": ""})
                continue
            end = [round(px[0] + dx, 1), round(px[1] + dy, 1)]
            out.append({"p": px, "end": end, "text": t})
            last = end
        return out

    def render(self):
        src = os.path.join(BUILD, self.id + ".scad")
        with open(src, "w") as f:
            f.write("include <../../params.scad>\n"
                    "use <../../vitamins.scad>\n"
                    "use <../../parts/arca_clamp.scad>\n"
                    "use <../../parts/p1_carriage.scad>\n"
                    "use <../../parts/p5_bearing_bracket.scad>\n"
                    "use <../../parts/p6_foot.scad>\n"
                    "use <../../parts/p7_handwheel.scad>\n"
                    "include <../hardware.scad>\n$fn = 48;\n")
            f.write(";\n".join(self.scad) + ";\n")
        png = os.path.join(IMG, self.id + ".png")
        camera = ",".join(f"{v:.4f}" for v in self.cam)
        r = subprocess.run(["openscad", "--projection=ortho", f"--camera={camera}",
                            f"--imgsize={self.w},{self.h}", "--colorscheme=Tomorrow",
                            "-o", png, src], capture_output=True, text=True)
        if r.returncode or not os.path.exists(png):
            sys.exit(f"{self.id}: openscad failed\n{r.stderr}")
        data = {
            "w": self.w, "h": self.h,
            "labels": self._labels(),
            "lines": [[project(a, self.cam, self.w, self.h), project(b, self.cam, self.w, self.h)] for a, b in self.lines],
            "arrows": [[project(a, self.cam, self.w, self.h), project(b, self.cam, self.w, self.h)] for a, b in self.arrows],
        }
        json.dump(data, open(os.path.join(IMG, self.id + ".json"), "w"), indent=1)
        print("rendered", self.id)

# ---------------------------------------------------------------- shared bits
wy, sy = P["wheel_y"], P["screw_y"]
cfy = P["clamp_face_y"]
wz = P["wheelbase"] / 2
bz, tz, bt = P["bottom_z"], P["top_z"], P["bracket_t"]
kp = P["kfl_pitch"] / 2
plate_x1 = P["plate_x0"] + P["plate_t"]
race_top = tz + bt + P["kfl_housing_h"] + P["kfl_race_proud"]
hw_z = race_top + P["pn_ring_h"]          # handwheel z = 0 (nut flange underside)
CZ = 284                                  # carriage centre for the scanning height
foot_tz = 0.6 * 28                        # foot T-nut bolt height

def beam(length=P["beam_len"]):
    return f"vslot_2040({length})"

def carriage_full(cz, new=False, wheels=True):
    """The finished carriage at centre height cz."""
    c = f"""translate([0, 0, {cz}]) {{
        color({NEW if new else OLD}) carriage();
        translate([0, {cfy}, 0]) {{
            color({NEW if new else OLD}) mirror([1, 0, 0]) clamp_moving_jaw(carriage_clamp_len);
            color([0.5, 0.5, 0.5]) translate([-jaw_out_x, bolt_y, 0]) rotate([0, -90, 0]) clamp_knob();
        }}
        translate([0, screw_y, nut_seat_z + abn_flange_t]) mirror([0, 0, 1]) ab_nut();"""
    if wheels:
        c += """
        for (dz = [-1, 1], sy = [-1, 1]) translate([0, sy * wheel_y, dz * carriage_wheelbase/2]) {
            vwheel(); translate([wheel_w/2, 0, 0]) wheel_spacer(eccentric = sy < 0);
        }"""
    return c + "}"

def bracket_with_kfl(z, new=False):
    return (f"color({NEW if new else OLD}) translate([0, 0, {z}]) bearing_bracket();"
            f"translate([0, screw_y, {z + bt}]) kfl08()")

def tnut_bolts(st, z0, rows, explode, side_x=-1):
    """Bracket T-nuts + low-profile M5x10 into the beam's left face."""
    for yy in (-10, 10):
        for zz in rows:
            st.hw("tnut()", [side_x * 5.5, yy, z0 + zz], "-x" if side_x < 0 else "+x")
            st.hw("bolt(10, head=\"low\")", [-15.3, yy, z0 + zz], "+x", explode)

def kfl_bolts(st, z, explode_up, explode_down):
    for sx in (-1, 1):
        x = sx * kp
        top = z + bt + P["kfl_flange_t"]
        st.hw("washer()", [x, sy, top + 0.5], "-z", explode_up)
        st.hw("bolt(25)", [x, sy, top + 1], "-z", explode_up, guide=False)
        st.hw("washer()", [x, sy, z - 0.5], "+z", explode_down)
        st.hw("nut()", [x, sy, z - 3], "+z", explode_down)

# ---------------------------------------------------------------- steps
def steps():
    S = {}

    # ---- title: the whole stand
    def whole(st):
        st.s("board()").s(beam()).s(f"translate([0, screw_y, {bz}]) tr8()")
        st.s("color(" + NEW + ") foot()")
        st.s(bracket_with_kfl(bz, True)).s(bracket_with_kfl(tz, True))
        st.s(f"color({NEW}) translate([0, screw_y, {hw_z}]) handwheel()")
        st.s(carriage_full(CZ, True))
        st.s(f"translate([0, {cfy}, {CZ}]) arca_plate()")
        st.s(f"translate([0, axis_y, {CZ} - cam_socket_from_mount]) {{ camera_dummy(); lens_dummy(); }}")
        st.s(f"translate([0, axis_y - holder_film_from_back, 0]) film_holder()")
        return st
    # README banner: the whole stand, and a close-up of the carriage
    S["b1"] = whole(Step("b1", cam([10, 70, 275], 125, 18, 300), (1000, 1400)))
    st = Step("b2", cam([0, 45, 300], 112, 28, 120), (1100, 1400))
    st.s(beam()).s(bracket_with_kfl(tz, True)).s(f"translate([0, screw_y, {bz}]) tr8()")
    st.s(f"color({NEW}) translate([0, screw_y, {hw_z}]) handwheel()")
    st.s(carriage_full(CZ, True)).s(f"translate([0, {cfy}, {CZ}]) arca_plate()")
    S["b2"] = st
    st = whole(Step("s00", cam([0, 60, 280], 125, 22, 330)))
    st.label([0, sy, hw_z + 20], "P7 handwheel", 170, -40)
    st.label([-20, 20, tz + 5], "P5 top bracket", -260, -60)
    st.label([0, sy, 420], "Tr8 leadscrew", 210, 0)
    st.label([-15, 0, CZ + 40], "P1 carriage", -280, -40)
    st.label([-20, 20, bz + 5], "P5 bottom bracket", -300, 40)
    st.label([-56, -20, 4], "P6 foot", 120, 70)
    st.label([60, 140, 30], "film holder", 160, 120)
    S[st.id] = st

    # ---- printed parts overview, on a grid laid out across the view
    az = 120
    rv = (-math.sin(math.radians(az)), math.cos(math.radians(az)))   # screen right
    bv = (-math.cos(math.radians(az)), -math.sin(math.radians(az)))  # away from the eye
    def g(a, b, z=0): return [a * rv[0] + b * bv[0], a * rv[1] + b * bv[1], z]
    st = Step("s01", cam(g(25, 20, 55), az, 28, 205))
    layout = [  # code, (a, b, z), label point offset, label, label dx, dy
        ("carriage()", (-110, 90, 80), (0, 0, 80), "P1 carriage", -150, -60),
        ("foot()", (70, 110, 0), (0, 0, 30), "P6 foot", 90, -120),
        ("bearing_bracket()", (-150, -60, 0), (-14, 0, 5), "P5 bracket ×2", -40, 150),
        ("bearing_bracket()", (-40, -60, 0), (-14, 0, 5), "", 0, 0),
        ("mirror([1, 0, 0]) clamp_moving_jaw(40)", (60, -40, 20), (-24, 67.6 - 67.6, 20), "P3 moving jaw", 40, 150),
        ("clamp_knob()", (120, -40, 0), (0, 0, 10), "P4 knob", 30, 120),
        ("handwheel()", (160, 40, 0), (0, 0, 32), "P7 handwheel", 20, -150),
        ("crank_sleeve()", (190, -60, 0), (0, 0, 34), "P7 crank sleeve", -40, 140),
    ]
    for code, (a, b, z), lp, text, dx, dy in layout:
        at = g(a, b, z)
        st.part(code, at=tuple(at))
        st.label(add(at, lp), text, dx, dy)
    S[st.id] = st

    # ---- wheels: bearings + shim
    st = Step("s02", cam([-14, 0, 0], -70, 20, 46))
    st.s("wheel_seats(cut = true)")
    st.hw("bearing()", [2.5, 0, 0], "-x", 22)
    st.hw("washer(5, od = 10, t = 1)", [0, 0, 0], "+x", 30)
    st.hw("bearing()", [-2.5, 0, 0], "+x", 50)
    st.line([-60, 0, 0], [-2.5, 0, 0])
    st.label([24.5, 0, 6], "1", 60, -90)
    st.label([-30, 0, 4], "2", -20, -110)
    st.label([-52.5, 0, 6], "3", -70, -90)
    st.label([0, -6, 8], "centre lip", 40, -200)
    S[st.id] = st

    # ---- knob
    st = Step("s03", cam([0, 0, 20], 60, 30, 42))
    st.part("clamp_knob()")
    st.hw("bolt(30)", [0, 0, P["knob_h"] - P["head_h"] - 0.2], "-z", 45)
    st.label([0, 0, 45 + 5], "1  M5×30", 140, -40)
    st.label([-12, 0, 5], "2  P4 knob, ribs up", -120, 120)
    S[st.id] = st

    # ---- foot onto the beam
    st = Step("s04", cam([0, 0, 0], 225, 22, 88))
    st.s(beam(110))
    fe = 45
    st.part("foot()", at=(0, 0, -fe))
    st.arrow([62, 30, -fe + 5], [62, 30, -8])
    for sx in (-1, 1):
        for yy in (-10, 10):
            st.hw("tnut()", [sx * 5.5, yy, foot_tz], "-x" if sx < 0 else "+x")
            st.hw("bolt(12, head=\"low\")", [sx * 16.3, yy, foot_tz], "+x" if sx < 0 else "-x", 30)
    st.hw("tnut()", [0, -14.5, foot_tz], "-y")
    st.hw("bolt(12, head=\"low\")", [0, -26.3, foot_tz], "+y", 30)
    st.label([-10, -10, foot_tz + 4], "1", -150, -200)
    st.label([0, -20, foot_tz + 4], "", -60, -200)
    st.label([-30, -26, -fe + 10], "2", -180, 60)
    st.label([-46.3, 10, foot_tz], "3", -150, -60)
    st.label([0, -56.3, foot_tz], "", 80, -100)
    S[st.id] = st

    # ---- foot to the board
    st = Step("s05", cam([0, 30, 10], 125, 30, 95))
    st.s("color([0.82, 0.68, 0.45, 0.5]) translate([-225, -30, -15]) cube([450, 280, 15])").s(beam(110)).s(f"color({OLD}) foot()")
    for sx in (-1, 1):
        st.hw("bolt(60)", [sx * 46, 0, 37.5], "-z", 45)
        st.hw("washer(5, od = 15, t = 1.5)", [sx * 46, 0, -15.75], "+z", 25)
        st.hw("nut()", [sx * 46, 0, -18.5], "+z", 25, guide=False)
    st.line([-225, -30, 0.2], [-46, -30, 0.2])
    st.line([-46, -30, 0.2], [-46, 0, 0.2])
    st.label([-46, 0, 82.5 + 5], "1  M5×60", -60, -120)
    st.label([46, 0, -40], "2  big washer + nut", 160, 80)
    st.label([-46, -15, 0], "30 mm from the back", -260, 30)
    S[st.id] = st

    # ---- bottom bracket
    st = Step("s06", cam([-10, 20, 40], 200, 18, 80))
    st.s("color([0.82, 0.68, 0.45]) translate([-60, -30, -15]) cube([120, 120, 15])")
    st.s(beam(130)).s(f"color({OLD}) foot()")
    st.part("bearing_bracket()", at=(0, 0, bz))
    tnut_bolts(st, bz, (-8, -22), 30)
    st.line([-60, 75, 0], [-60, 75, bz])
    st.label([-5.5, -10, bz - 8], "1", -120, -230)
    st.label([-45.3, 10, bz - 22], "2", -170, 100)
    st.label([-20, 60, bz + 10], "3  P5", -60, -150)
    st.label([-60, 75, bz / 2], "60 mm", -150, 0)
    S[st.id] = st

    # ---- bottom KFL08
    st = Step("s07", cam([0, 30, bz + 5], 135, 30, 65))
    st.s(beam(130)).s(f"color({OLD}) foot()")
    st.part("bearing_bracket()", new=False, at=(0, 0, bz))
    st.s(f"translate([0, screw_y, {bz + bt}]) kfl08()")
    kfl_bolts(st, bz, 30, 25)
    st.label([0, sy + 13, bz + bt + 9], "1  KFL08", 150, -150)
    st.label([-kp, sy, bz + bt + 40], "2  M5×25 + washer", -200, -80)
    st.label([kp, sy, bz - 30], "3  washer + nut", 160, 60)
    S[st.id] = st

    # ---- anti-backlash nut on the carriage
    st = Step("s08", cam([0, 30, 25], 140, 38, 88))
    st.part("carriage()", new=False)
    ne = 30
    top = P["nut_seat_z"] + P["abn_flange_t"]
    st.s(f"translate([0, screw_y, {top + ne}]) mirror([0, 0, 1]) ab_nut()")
    st.line([0, sy, top + ne + 5], [0, sy, top])
    r = P["abn_bcd"] / 2
    for a in (45, 135, 225, 315):
        x, y = r * math.cos(math.radians(a)), sy + r * math.sin(math.radians(a))
        st.hw("bolt(14, d = 3)", [x, y, top], "-z", 70)
    st.label([0, sy + 13, top + ne + 2], "1  anti-backlash nut, flange up", 150, -180)
    st.label([-6, sy + 6, top + 70 + 3], "2  M3 ×4", -180, -60)
    st.label([0, sy, top], "spring end hangs in here", 200, 130)
    S[st.id] = st

    # ---- clamp: nut, jaw, knob
    st = Step("s09", cam([-25, 40, 5], 130, 30, 72))
    st.part("carriage()", new=False)
    by = cfy + P["bolt_y"]
    nx = -(P["nut_x0"] + 2.2)
    st.hw("rotate([0, 0, 30]) nut()", [nx, by, 0], "-z", 40)
    je, ke = 14, 32
    st.part(f"translate([0, {cfy}, 0]) mirror([1, 0, 0]) clamp_moving_jaw(40)", at=(-je, 0, 0))
    kx = -P["jaw_out_x"] - ke
    st.part(f"translate([{kx}, {by}, 0]) rotate([0, -90, 0]) clamp_knob()")
    st.hw("bolt(30)", [kx - (P["knob_h"] - P["head_h"] - 0.2), by, 0], "+x")
    st.line([kx, by, 0], [-P["jaw_out_x"] - je, by, 0])
    st.arrow([kx - 15, by, 18], [-P["jaw_out_x"] - je - 3, by, 18])
    st.label([nx, by, 40 + 3], "1  M5 nut, from the top", 60, -150)
    st.label([-24 - je, cfy + 2, 20], "2  P3 moving jaw", -40, -160)
    st.label([kx - 5, by, 12], "3  knob + bolt", -170, -40)
    S[st.id] = st

    # ---- wheels onto the carriage
    st = Step("s10", cam([-30, 0, 0], 125, 22, 115))
    st.part("carriage()", new=False)
    hx = plate_x1 - P["wheel_cbore_h"]
    for dz in (-1, 1):
        for syy in (-1, 1):
            y, z = syy * wy, dz * wz
            ecc = "true" if syy < 0 else "false"
            ex = 38 if dz > 0 else 0
            st.hw("bolt(30)", [hx, y, z], "-x")
            st.s(f"translate([{-ex}, {y}, {z}]) vwheel()")
            st.s(f"translate([{5 - ex * 0.5}, {y}, {z}]) wheel_spacer(eccentric = {ecc})")
            st.hw("washer(5, od = 10, t = 1)", [-5.5, y, z], "+x", ex * 1.5, guide=False)
            st.hw("nut(nylock = true)", [-8.5, y, z], "+x", ex * 1.9, guide=False)
            if ex:
                st.line([-8.5 - ex * 1.9, y, z], [hx, y, z])
    st.label([-8.5 - 38 * 1.9, wy, wz + 4], "4  shim + nylock", 200, 140)
    st.label([-38, wy, wz + 12], "3  wheel", -300, -140)
    st.label([-14, wy, wz + 5], "2  fixed spacer (front)", -300, 90)
    st.label([-14, -wy, wz + 5], "2  eccentric (back)", 200, -150)
    st.label([plate_x1, wy, -wz], "1  M5×30 from the outside, head in the recess", 0, 200)
    S[st.id] = st

    # ---- slide onto the beam
    st = Step("s11", cam([0, 10, 520], 200, 20, 175))
    st.s(beam())
    up = 420 + 140
    st.s(carriage_full(up, False))
    st.arrow([-40, 0, up - 60], [-40, 0, up - 130])
    for dz in (-1, 1):
        st.label([11, -wy, up + dz * wz], "1" if dz > 0 else "", -230, -60 if dz > 0 else 40)
    st.label([0, 0, tz], "2  top end of the beam", 180, 100)
    S[st.id] = st

    # ---- top bracket
    st = Step("s12", cam([0, 25, tz + 10], 200, 25, 98))
    st.s(beam()).s(carriage_full(400, False))
    st.part("bearing_bracket()", at=(0, 0, tz))
    tnut_bolts(st, tz, (-8, -22), 30)
    st.s(f"translate([0, screw_y, {tz + bt + 30}]) kfl08()")
    st.line([0, sy, tz + bt + 30], [0, sy, tz + bt])
    kfl_bolts(st, tz, 60, 25)
    st.label([-20, 0, tz + bt], "1  P5 sits on the beam end", -150, -200)
    st.label([-45.3, -10, tz - 8], "2", -120, 40)
    st.label([0, sy + 13, tz + bt + 39], "3  KFL08 + bolts as before", 120, -150)
    S[st.id] = st

    # ---- leadscrew
    st = Step("s13", cam([0, 30, 390], 140, 12, 400))
    st.s("board()").s(beam()).s(f"color({OLD}) foot()")
    st.s(bracket_with_kfl(bz)).s(bracket_with_kfl(tz))
    st.s(carriage_full(330, False))
    se = 220
    st.s(f"translate([0, screw_y, {bz + se}]) tr8()")
    st.arrow([30, sy, bz + se + 480], [30, sy, bz + se + 400])
    st.label([0, sy, bz + se + 470], "1  Tr8 leadscrew, from the top", 150, -20)
    st.label([0, sy, 330 + 40], "2  turn to thread it through", 230, 40)
    st.label([0, sy, bz], "3  end flush with the bracket underside", 200, 80)
    S[st.id] = st

    # ---- handwheel: brass nut (from below)
    st = Step("s14", cam([0, 0, -25], 120, -30, 72))
    st.part("handwheel()")
    ne = 30
    st.s(f"translate([0, 0, {-ne}]) brass_nut()")
    st.line([0, 0, -ne - 1], [0, 0, 0])
    r = P["abn_bcd"] / 2
    for a in (45, 135, 225, 315):
        x, y = r * math.cos(math.radians(a)), r * math.sin(math.radians(a))
        st.hw("bolt(10, d = 3)", [x, y, -1], "+z", 55)
    st.label([0, 13, -ne + 2], "1  brass nut, ring facing out", 160, 120)
    st.label([6, 6, -56 - 3], "2  M3×8–10 ×4", -160, 120)
    st.label([20, 0, 0], "P7, upside down", -60, -200)
    S[st.id] = st

    # ---- handwheel: radial lock + crank
    st = Step("s15", cam([0, 0, 32], -100, 25, 62))
    st.part("handwheel()")
    lz = P["pn_len"] + 7
    st.hw("nut(3)", [-7.9, 0, lz], "-z", 25)
    st.hw("bolt(10, d = 3)", [-13, 0, lz], "+x", 20)
    cr = 23
    st.hw("bolt(60)", [cr, 0, 3], "+z", 0)
    st.hw("nut()", [cr, 0, 9], "-z", 10)
    st.part("crank_sleeve()", at=(cr, 0, 30))
    st.hw("nut()", [cr, 0, 70], "-z", 0)
    st.hw("nut()", [cr, 0, 74.5], "-z", 0)
    st.label([-7.9, 0, lz + 27], "1  M3 nut into its slot", -150, -80)
    st.label([-33, 0, lz], "2  M3×10, stops on the thread", -120, 120)
    st.label([cr, 0, -5], "3  M5×60 up from below", 170, 100)
    st.label([cr, 7, 50], "4  sleeve", 140, -20)
    st.label([cr, 4, 74], "5  two nuts locked together", 140, -120)
    S[st.id] = st

    # ---- handwheel onto the screw
    st = Step("s16", cam([0, 30, tz + 48], 140, 22, 72))
    st.s(beam()).s(bracket_with_kfl(tz)).s(f"translate([0, screw_y, {bz}]) tr8()")
    he = 35
    st.part(f"translate([0, screw_y, {hw_z + he}]) handwheel()", new=False)
    st.s(f"translate([0, screw_y, {hw_z + he}]) brass_nut()")
    st.arrow([-35, sy, hw_z + he + 10], [-35, sy, hw_z + 12])
    st.label([0, sy + 7, race_top], "1  inner race", 220, 60)
    st.label([30, sy, hw_z + he + 4], "2  thread it down", 170, -90)
    st.label([-13, sy, hw_z + he + 22], "3  then lock", -150, -60)
    S[st.id] = st

    # ---- truing
    st = Step("s17", cam([0, 30, 290], 55, 10, 320))
    st.s("board()").s(beam()).s(f"color({OLD}) foot()")
    st.s(bracket_with_kfl(bz)).s(bracket_with_kfl(tz)).s(f"translate([0, screw_y, {bz}]) tr8()")
    st.s(f"color({OLD}) translate([0, screw_y, {hw_z}]) handwheel()")
    st.s(carriage_full(CZ, False))
    st.arrow([70, 20, CZ + 60], [70, 20, CZ + 140])
    st.arrow([70, 20, CZ - 60], [70, 20, CZ - 140])
    st.label([kp, sy, tz + bt + 4], "1  top KFL08 bolts", 180, -40)
    st.label([kp, sy, bz + bt + 4], "2  bottom KFL08 bolts", 180, 40)
    st.label([-20, 0, CZ], "carriage", -200, 0)
    S[st.id] = st

    # ---- camera + film
    st = Step("s18", cam([0, 90, 210], 160, 15, 240))
    st.s("board()").s(beam()).s(f"color({OLD}) foot()")
    st.s(bracket_with_kfl(bz)).s(bracket_with_kfl(tz)).s(f"translate([0, screw_y, {bz}]) tr8()")
    st.s(f"color({OLD}) translate([0, screw_y, {hw_z}]) handwheel()")
    st.s(carriage_full(CZ, False))
    pe = 60
    st.s(f"translate([0, {cfy}, {CZ + pe}]) arca_plate()")
    st.s(f"translate([0, axis_y, {CZ + pe} - cam_socket_from_mount]) {{ camera_dummy(); lens_dummy(); }}")
    st.arrow([-90, cfy + 40, CZ + pe + 90], [-90, cfy + 40, CZ + 90])
    he = 80
    st.s(f"translate([0, axis_y - holder_film_from_back + {he}, 0]) film_holder()")
    st.arrow([95, 200, 30], [95, 200 - he + 20, 30])
    st.label([-P["jaw_out_x"] - 10, cfy - 5.5, CZ], "1  knob", -150, 60)
    st.label([0, cfy, CZ + pe + 15], "2  plate in from the top", -250, -120)
    st.label([0, 220, 50], "3  film holder under the bracket", 120, 140)
    S[st.id] = st
    return S

if __name__ == "__main__":
    os.makedirs(IMG, exist_ok=True)
    allsteps = steps()
    for sid in sys.argv[1:] or allsteps:
        allsteps[sid].render()
