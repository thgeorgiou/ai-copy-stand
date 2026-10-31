// P8 — Board feet (x4): lift the board clear of the P6 bolt tails.
//
// P6's two M5x60s come out board_bolt_tail (7.5) under the board with their
// washers and nuts, so the board would rock on them. One foot near each
// corner holds it board_foot_h (12) off the table instead.
// Each foot takes a countersunk wood screw, 3.5x16: the head sits 5 mm into
// the foot and the screw reaches 11 mm into the 15 mm board. The top is flat,
// so glue or VHB tape works too if you'd rather not drill.
//
// Local coordinates: z = 0 is the face against the board, the foot hangs to
// +z. Prints that face down, no supports. This file lays out all four.
// Hardware: 4x wood screw 3.5x16, countersunk.
include <../params.scad>

screw_d  = 3.5 + clr_hole;
head_d   = 7.5;     // [C] 3.5 countersunk head ~7; counterbore takes a pan head too
seat_z   = 5;       // under-head face, from the board face
chamfer  = 1;       // floor edge
bed_ch   = 0.5;     // board edge, against elephant foot

module board_foot() {
    r = board_foot_d / 2;
    h = board_foot_h;
    difference() {
        rotate_extrude() polygon([[0, 0], [r - bed_ch, 0], [r, bed_ch],
                                  [r, h - chamfer], [r - chamfer, h], [0, h]]);
        translate([0, 0, -1]) cylinder(d = screw_d, h = h + 2, $fn = 24);
        // 90° countersink, then a counterbore down to the floor
        translate([0, 0, seat_z - (head_d - screw_d) / 2])
            cylinder(d1 = screw_d, d2 = head_d, h = (head_d - screw_d) / 2 + 0.01, $fn = 32);
        translate([0, 0, seat_z]) cylinder(d = head_d, h = h, $fn = 32);
    }
}

// Foot centres in assembly coordinates (see board() in vitamins.scad).
function board_foot_xy() = let(
    x0 = -board_w/2 + board_foot_inset, x1 = board_w/2 - board_foot_inset,
    y0 = -beam_d/2 - board_back_margin + board_foot_inset,
    y1 = -beam_d/2 - board_back_margin + board_d - board_foot_inset)
    [[x0, y0], [x1, y0], [x0, y1], [x1, y1]];

// All four under the board, in assembly coordinates.
module board_feet() {
    for (p = board_foot_xy())
        translate([p[0], p[1], -board_t]) mirror([0, 0, 1]) board_foot();
}

// Print layout: 2x2
for (i = [0, 1], j = [0, 1])
    translate([i * (board_foot_d + 5), j * (board_foot_d + 5), 0]) board_foot();
