// Copy stand — shared parameters. Every part and the assembly include this.
//
// Coordinate system (all parts are designed in it, then laid flat for print):
//   origin = top surface of the board, on the column's centre axis
//   +x, +y = towards the front/user, +z = up
//   Careful: "left"/"right" in the part comments mean -x/+x, i.e. as seen
//   from BEHIND the stand. Seen from the front (where you stand) the carriage
//   plate (+x) is on the LEFT of the beam and the clamp knob on the right.
//
// Tags:  [M] measured   [C] catalogue/typical — verify   [D] design choice
//        [?] guess, needs measuring

$fn = 64;

// ---------------------------------------------------------------- print / fit
clr      = 0.2;     // [D] general sliding clearance per side (PLA, A1 mini)
clr_hole = 0.3;     // [D] extra on hole diameters for bolts / vitamins

// ---------------------------------------------------------------- board
// IKEA APTITLIG bamboo board
board_w = 450;      // [M] x
board_d = 280;      // [M] y
board_t = 15;       // [M]
board_back_margin = 10;   // [D] beam back face to board back edge

// ---------------------------------------------------------------- beam
// V-Slot 2040, 40 mm front-to-back (y), 20 mm left-right (x)
beam_w   = 20;      // [C] x
beam_d   = 40;      // [C] y
beam_len = 500;     // [M]
vslot_bore_d = 4.2; // [C] end bores, M5 tap drill

// ---------------------------------------------------------------- V-wheels
wheel_od     = 24;  // [M]
wheel_w      = 10;  // [M]
wheel_bore   = 5;   // [C] 2x 625 bearings pressed in from both faces
wheel_spacer = 6;   // [C] fixed & eccentric spacer height
ecc_bore_d   = 7.4; // [M] P0a: a 7.4 hole only just takes the boss; holes print at +0.2
ecc_throw    = 0.8; // [C] eccentric offset (± adjustment)
// Wheel centre to the extrusion face it rides on. OpenBuilds convention:
// opposite wheels sit (profile width + 19.6) apart -> 9.8 per side.
wheel_face_off = 9.6;     // [M] P0a2: snug at 59.0-59.3 centre to centre
wheel_y = beam_d/2 + wheel_face_off;   // front wheels +y, back (eccentric) -y

// ---------------------------------------------------------------- carriage
carriage_wheelbase = 130; // [D] vertical wheel-centre spread (nose-dive couple)
carriage_h         = 160; // [D] overall height, must fit 180 bed
carriage_plate_t   = 12;  // [D] wheel-boss plate thickness
// Wheel bolt heads sink into the plate's outer face, so M5x30 reaches through
// a nylock + shim: 5 plate + 6 spacer + 10 wheel + 1 shim + 5 nylock = 27
// (P0a at 6.8 under the head: plain nuts only)
wheel_cbore_d      = 9.2; // [M] P0a: heads drop in
wheel_cbore_h      = 7;   // [D]
// plate inner face: beam right face + 1 mm, i.e. wheel face + spacer
carriage_plate_x0  = wheel_w/2 + wheel_spacer;
nut_seat_z         = 40;  // [D] anti-backlash flange seat, above carriage centre
carriage_clamp_len = 40;  // [D]

// ---------------------------------------------------------------- leadscrew
screw_d   = 8;      // [C] Tr8x2
screw_len = 500;    // [M] threaded to the end, no stub
screw_wheel_clr = 2;      // [D] screw to front-wheel rim
// Screw sits in front of the beam on its centre plane (x = 0), just clear
// of the front wheels.
screw_clear_r = screw_d/2 + screw_wheel_clr;
screw_y = wheel_y + wheel_od/2 + screw_clear_r;

// ---------------------------------------------------------------- KFL08
kfl_l        = 46;  // [M] long side
kfl_w        = 27;  // [M] short side
kfl_pitch    = 35;  // [M] hole centre-to-centre
kfl_hole_d   = 6;   // [M]
kfl_flange_t = 4;   // [M] thickness at the bolt ears
kfl_housing_d = 27; // [M]
kfl_housing_h = 9;  // [M] thickness around the bearing
kfl_race_proud = 4; // [M] inner race stands proud of the housing
kfl_race_d   = 15;  // [?] inner race OD — not measured, bracket clears 20
kfl_bore     = 8;
kfl_clear_hole = 20;      // [D] bracket hole clearing the race either side

// ---------------------------------------------------------------- anti-backlash nut
abn_flange_d = 26;  // [M]
abn_flange_t = 4;   // [M]
abn_bcd      = 17;  // [M] opposite-hole centre distance (re-check: edge method)
abn_hole_d   = 4;   // [M] 4 holes, cross pattern, M3 -> ~0.5 mm float
// Flange at one end, flat outer face. Everything else is on the other side:
// the body (a column the spring sits on), the spring, then the end piece,
// keyed to the body by teeth, with a wide collar at its far end.
abn_body_d   = 10;  // [M] column under the flange
abn_spring_d = 11;  // [M] spring OD
abn_end_l    = 15;  // [M] end piece, collar included
abn_collar_d = 14;  // [M]
abn_collar_l = 4;   // [M]
abn_len      = 27;  // [M] flange face to collar end, keyed, on the screw (26 fully pushed in)

// ---------------------------------------------------------------- plain Tr8 nut
// The brass nut that came with the screw, reused as the handwheel's thrust
// collar. Same footprint as the anti-backlash nut, plus a ring under the
// flange (opposite the body) that bears on the KFL08's inner race.
pn_flange_d = abn_flange_d;   // [M]
pn_flange_t = abn_flange_t;   // [M]
pn_body_d   = abn_body_d;     // [M]
pn_len      = 15;             // [M] flange + body, ring not included
pn_bcd      = abn_bcd;        // [M]
pn_hole_d   = abn_hole_d;     // [M]
pn_ring_h   = 1;              // [M]
pn_ring_d   = 26;             // [M] the race stands 4 mm proud, so only it touches

// ---------------------------------------------------------------- Arca plate
// Sirui TY-C10. Mounted vertically: 39 across x (jaws close in x),
// 30 along z (slides in from the top), 9 thick in y.
// Profile from samples/quickrelease.stl. Clamp face = the face with the 45°
// dovetail; the camera screw head sits in a pocket on that side.
plate_w = 39;       // [M] across the dovetails, at the clamp face and camera face
plate_l = 30;       // [M]
plate_t = 8;        // [M] (STL; earlier hand measurement said 9)
dt_flat     = 1.2;  // [M] vertical flat at the clamp face (0.6 chamfer included)
dt_undercut = 3;    // [M] 45° face runs 3 in / 3 up, from z 1.2 to 4.2
dt_ledge_z  = 4.2;  // [M] ledge back out to full width; camera-side wall above
plate_waist_w = plate_w - 2 * dt_undercut;   // 33
// Safety channel down the middle of the clamp face, both ends
notch_w        = 8;     // [M] x 15.5..23.5
notch_end_d    = 3.5;   // [M] depth at the very end, ramps 45° up to...
notch_channel_d = 0.5;  // [M] ...this, 3 mm in from the end
plate_pocket = [31, 22, 5.5];   // [M] screw-head pocket on the clamp face

// ---------------------------------------------------------------- camera
// Olympus OM-3, hanging lens-down, base facing the column.
cam_base_to_axis = 35;    // [M]
cam_w = 139.3;      // [C] spec sheet, x
cam_h = 88.9;       // [C] base-to-top, along y here
cam_d = 45.8;       // [C] depth, along z here
mft_flange = 19.25; // [C] sensor behind mount face
cam_socket_from_mount = 22; // [?] mount face to tripod-socket centre

// Minolta A -> MFT adapter, Minolta AF 50/2.8 Macro
a_flange   = 44.5;  // [C]
adapter_l  = a_flange - mft_flange;
adapter_d  = 66;    // [M] ~same as lens, has an aperture ring
lens_d     = 66;    // [M]
lens_l     = 60;    // [C] at infinity
lens_f     = 50;

// ---------------------------------------------------------------- film / optics
film_z      = 50;   // [M] film plane above board (holder + light)
holder_w    = 170;  // [M] x
holder_d    = 120;  // [M] y
holder_h    = 50;   // [M] approx = film_z
holder_film_from_back = 75;  // [M] 60 mm margin + half the strip
sensor_w    = 17.3; // [C] MFT
film_frame_w = 36;
mag         = 0.46; // [D] 36 mm frame onto the sensor with ~4 % margin
// Thin-lens total conjugate; real lens adds a few mm (principal planes).
film_to_sensor = lens_f * (2 + mag + 1/mag);
sensor_z    = film_z + film_to_sensor;

// ---------------------------------------------------------------- clamp / arm
clamp_back_t = 14;  // [D] clamp body behind the clamp face (houses the M5 drive)
clamp_face_y = screw_y + screw_clear_r + clamp_back_t;
axis_y       = clamp_face_y + plate_t + cam_base_to_axis;   // optical axis

// Clamp geometry, in clamp-local coordinates (see parts/arca_clamp.scad)
jaw_wall_clr  = 0.5;   // [D] jaw wall to the plate's vertical flat (no contact)
jaw_tip_y     = dt_ledge_z - 0.4;   // tip stays under the plate's ledge
jaw_fixed_off = 0.1;   // [D] fixed-jaw face set back from nominal (print growth)
jaw_out_x     = 30;    // [D] outer face of either jaw
channel_x     = 18.5;  // [D] inner wall of the moving-jaw channel (~2 mm close margin)
channel_floor = -11;   // [D]
foot_clr      = 0.2;   // [D] moving jaw foot to channel wall / floor
body_end_x    = jaw_out_x - 2;   // [D] floor stops short of the knob (it dips below the floor)
bolt_y        = channel_floor / 2;
bolt_d        = 5 + clr_hole;
nut_af        = 8;     // [C] M5 H4 nut
nut_h         = 4;     // [M]
knob_d        = 24;
knob_h        = 10;
head_d        = 8.5;   // [C] DIN912 M5
head_h        = 5;     // [C]
knob_bolt_len = 30;    // [M] what's in the bolt box (M5x40 also works)
jaw_open      = 4;     // [D] jaw travel to drop the plate in (tips need ~3)
// Trap start: closed, the bolt is fully through the nut; opened by jaw_open,
// 2 mm of thread is still engaged.
nut_x0 = jaw_out_x + (knob_h - head_h - 0.2) - knob_bolt_len + jaw_open - 2;
pin_w         = 5;     // [D] stop pin, sits in the 8 mm safety channel
pin_h         = 2;     // [D] between channel (0.5) and notch-end (3.5) depth
face_c = plate_w/2 + dt_flat;   // plate's 45° face, right side: x = face_c - y

// ---------------------------------------------------------------- brackets
bracket_t  = 10;    // [D] bearing-bracket plate thickness
bottom_bracket_z = 60;    // [D] underside; film holder slides in below
top_bracket_z    = beam_len;   // [D] underside; cap sits on the beam top

// Derived screw position
screw_z0 = bottom_bracket_z;           // bottom end in the lower bracket
screw_z1 = screw_z0 + screw_len;
