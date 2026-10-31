// P1 — Carriage, with the Arca clamp built in.
//
// Modelled in assembly coordinates with z = 0 at the carriage centre (the
// clamp/plate centre). Prints lying on the plate's outer face (x = max):
// wheel holes come out vertical like P0a, the plate bends within its layers,
// and the fixed jaw's 45° tip is a plain overhang pressed into the layers
// below it. Holes along z become horizontal, so they get teardrops.
//
//   - side plate on the beam's right face carrying the 4 wheels
//     (front pair fixed spacers, back pair eccentric)
//   - nut tower in front of the beam: the anti-backlash nut's flange sits
//     on top, the rest of the nut hanging down in a stepped bore
//   - clamp in front of the tower, mirrored: fixed jaw on the right (merged
//     into the plate), moving jaw + knob on the free left side
//
// Hardware: 4x M5x30 DIN912 + kit nylocks/spacers, 2x eccentric spacers,
// 4x M3x12-16 (self-tapping into the tower top), clamp: see P0c.
include <../params.scad>
use <arca_clamp.scad>

part = "print";

// ---------------------------------------------------------------- local params
plate_y0 = -wheel_y - 10;          // back edge
plate_y1 = clamp_face_y;           // front edge, flush with the clamp face
plate_x1 = carriage_plate_x0 + carriage_plate_t;
wheel_z  = carriage_wheelbase / 2;

tower_x0 = -14;
tower_y0 = 35;
tower_z0 = -48;                    // clears the lower front wheel (top at -53)
tower_z1 = nut_seat_z;             // nut flange seat
// The nut hangs from its flange into a stepped bore. The top step is just
// wide enough for the collar to pass and keeps the M3 pilots walled in (they
// sit 7.25 mm off the axis): both are plain round holes there, since a
// teardrop on either would cut one into the other. Below the screw tips it
// opens up so the collar floats.
neck_bore_d   = abn_collar_d + 0.6;
neck_bore_l   = 13;
spring_bore_d = abn_collar_d + 2;
nut_bore_l    = abn_len - abn_flange_t + 2;   // flange underside to bore floor
// Runs on past the clamp body's back face to wall in the spring bore, but
// stops short of the clamp's nut slot (it opens upwards in front of here).
tower_y1 = screw_y + spring_bore_d/2 + 2;
nut_slot_y0 = clamp_face_y + bolt_y - (nut_af + clr_hole)/2;
assert(tower_y1 < nut_slot_y0, "nut tower covers the clamp nut slot");
assert(tower_y1 > clamp_face_y - clamp_back_t, "nut tower must meet the clamp body");
screw_bore_d  = screw_d + 3;
m3_pilot_d = 2.5;                  // [D] self-tapping M3 in PLA
m3_pilot_l = neck_bore_l;          // M3x12-16 tips stop in the narrow step
abn_angle  = 45;                   // flange holes on the diagonals, clear of the plate

clamp_len = carriage_clamp_len;

// ---------------------------------------------------------------- helpers
// Hole along x through [x0, x1] (vertical when printed).
module hole_x(d, x0, x1, y, z) {
    translate([x0, y, z]) rotate([0, 90, 0]) cylinder(d = d, h = x1 - x0);
}

// Hole along z from z0, length h, teardrop point towards -x (up when printed).
module hole_z(d, z0, h) {
    translate([0, 0, z0]) linear_extrude(h)
        hull() { circle(d = d); translate([-d * 0.71, 0]) circle(d = 0.01); }
}

// ---------------------------------------------------------------- body
module side_plate() {
    translate([carriage_plate_x0, plate_y0, -carriage_h/2])
        cube([carriage_plate_t, plate_y1 - plate_y0, carriage_h]);
}

module nut_tower() {
    translate([tower_x0, tower_y0, tower_z0])
        cube([carriage_plate_x0 - tower_x0 + 1, tower_y1 - tower_y0, tower_z1 - tower_z0]);
}

module carriage() {
    difference() {
        union() {
            side_plate();
            nut_tower();
            // backs the thin channel floor under the moving jaw; stops short
            // of the clamp knob's sweep (x < -jaw_out_x)
            translate([-jaw_out_x + 2, tower_y0 + 9, -clamp_len/2])
                cube([tower_x0 + jaw_out_x - 1, clamp_face_y - clamp_back_t + 1 - (tower_y0 + 9), clamp_len]);
            // fixed jaw trimmed flush with the plate's outer face (print bed)
            intersection() {
                translate([0, clamp_face_y, 0]) mirror([1, 0, 0])
                    clamp_body(clamp_len, nut_slot = "top");
                translate([-100, 0, -100]) cube([100 + plate_x1, 200, 200]);
            }
        }

        // wheel axles: front fixed (bolt), back eccentric (spacer boss)
        for (sz = [-1, 1]) {
            hole_x(wheel_bore + clr_hole, carriage_plate_x0 - 1, plate_x1 + 1, wheel_y, sz * wheel_z);
            hole_x(ecc_bore_d + 0.2, carriage_plate_x0 - 1, plate_x1 + 1, -wheel_y, sz * wheel_z);
            for (sy = [-1, 1])   // sunk heads (on the bed: short bridge over the bolt hole)
                hole_x(wheel_cbore_d, plate_x1 - wheel_cbore_h, plate_x1 + 1, sy * wheel_y, sz * wheel_z);
        }

        translate([0, screw_y, 0]) {
            // screw clearance, full height
            hole_z(screw_bore_d, -carriage_h, 2 * carriage_h);
            // the nut's body, spring and end piece hang into this
            translate([0, 0, tower_z1 - neck_bore_l]) cylinder(d = neck_bore_d, h = neck_bore_l + 1);
            hole_z(spring_bore_d, tower_z1 - nut_bore_l, nut_bore_l - neck_bore_l);
            // flange seat: relieve the side plate where the flange overlaps it
            translate([0, 0, tower_z1]) cylinder(d = abn_flange_d + 1, h = abn_flange_t + 1.5);
            // M3 pilots (insert the nut before fitting the upper front wheel)
            for (a = [0:90:270]) rotate(a + abn_angle) translate([abn_bcd/2, 0, 0])
                translate([0, 0, tower_z1 - m3_pilot_l]) {
                    cylinder(d = m3_pilot_d, h = m3_pilot_l + 1, $fn = 24);
                    // lead-in so the screw tip finds the hole
                    translate([0, 0, m3_pilot_l - 1]) cylinder(d1 = m3_pilot_d, d2 = 3.6, h = 1.01, $fn = 24);
                }
        }
    }
}

// print: outer face of the plate down, assembly -x pointing up
if (part == "print") translate([0, 0, plate_x1]) rotate([0, 90, 0]) carriage();
else carriage();
