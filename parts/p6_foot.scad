// P6 — Foot: anchors the beam to the board.
//
// The beam stands directly on the board inside a collar. T-nuts lock the
// collar to the beam (left, right, back faces; the front stays clear for the
// film holder), and two ribbed wings bolt through the board.
// Board bolts go in from the top through tall bosses, so an M5x60 comes out
// just far enough under the 15 mm board for a washer and nut.
//
// Modelled in assembly coordinates (z = 0 board top). Prints as modelled.
// Hardware: 5x M5x12 low-profile + drop-in T-nuts, 2x M5x60 + 2x H4 nut +
// 4x washer (big ones under the board).
include <../params.scad>

base_t   = 5;
wall_t   = 6;         // collar wall; M5x12 low-profile leaves ~6 mm into the T-nut
collar_h = 28;        // stays under the bottom bracket's skirt
beam_clr = 0.3;
wing_x   = 62;        // half-span of the wings
rib_t    = 6;
board_bolt_len = 60;
boss_d   = 12;
boss_x   = 46;
// head on the boss, washer + nut + ~2 threads under the board
boss_h   = board_bolt_len - board_t - 1.5 - 4 - 2;
front_y  = beam_d/2 + wall_t;             // stays clear of the film holder
back_y   = -beam_d/2 - wall_t;            // 4 mm inside the board's back edge

cx = beam_w/2 + beam_clr;                  // collar inner half-widths
cy = beam_d/2 + beam_clr;

module foot() {
    difference() {
        union() {
            // base plate
            translate([-wing_x, back_y, 0]) cube([2 * wing_x, front_y - back_y, base_t]);
            // collar
            translate([-cx - wall_t, back_y, 0])
                cube([2 * (cx + wall_t), front_y - back_y, collar_h]);
            // ribs along the front and back edges, wing tips up to the collar
            // top; the side T-nut bolts stay reachable between them
            for (sx = [-1, 1], yy = [back_y, front_y - rib_t])
                translate([0, yy + rib_t, 0]) rotate([90, 0, 0]) linear_extrude(rib_t)
                    polygon([[sx * cx, 0], [sx * wing_x, 0], [sx * wing_x, base_t],
                             [sx * cx, collar_h]]);
            // bolt bosses, tied to the collar by a thin web on the centre line
            for (sx = [-1, 1]) {
                translate([sx * boss_x, 0, 0]) cylinder(d = boss_d, h = boss_h);
                translate([sx > 0 ? cx : -boss_x, -2, 0]) cube([boss_x - cx, 4, collar_h]);
            }
        }
        // the beam
        translate([-cx, -cy, -1]) cube([2 * cx, 2 * cy, collar_h + 2]);
        // T-nut bolts: two per side face (both slots), one in the back slot
        for (sx = [-1, 1], yy = [-10, 10])
            translate([sx * (cx + wall_t/2), yy, collar_h * 0.6]) rotate([0, 90, 0])
                cylinder(d = 5.5, h = wall_t + 2, center = true);
        translate([0, -cy - wall_t/2, collar_h * 0.6]) rotate([90, 0, 0])
            cylinder(d = 5.5, h = wall_t + 2, center = true);
        // board bolts
        for (sx = [-1, 1]) translate([sx * boss_x, 0, -1]) cylinder(d = 5.5, h = boss_h + 2);
    }
}

foot();
