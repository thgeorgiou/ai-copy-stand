// P0 — test coupons. Print these first to confirm the fits the real parts
// depend on. Unlike the real parts, coupons are modelled print-oriented.
//
//   part = "wheel" : P0a wheel spacing + M5 / eccentric hole fits
//   part = "slot"  : P0a2 wheel spacing measured with a slot instead of the eccentric
//   part = "bearing": P0b KFL08 hole pattern + anti-backlash nut pocket
include <../params.scad>

part = "all";

m3_nut_af = 5.5;    // [C]
m5_nut_af = 8;      // [C]

module hex(af, h) { cylinder(d = af / cos(30), h = h, $fn = 6); }

module label(t, size = 3.5) {
    linear_extrude(1)
        text(t, size = size, halign = "center", valign = "center",
             font = "Liberation Sans:style=Bold");
}

// ---------------------------------------------------------------- P0a
// Bolt a wheel on a fixed spacer in the 5.x hole at one end and a wheel on an
// eccentric spacer in the 7.x bore at the other, then fit it across the
// 40 mm side of the beam. Good spacing = snug with the eccentric near the
// middle of its throw. The middle row tries hole sizes for the real carriage.
module coupon_wheel() {
    len = 2 * wheel_y + 24;
    w = 26;
    test = [[5.2, "5.2"], [5.4, "5.4"], [7.2, "7.2"], [7.4, "7.4"]];
    difference() {
        translate([-len/2, -w/2, 0]) cube([len, w, carriage_plate_t]);
        translate([wheel_y, 0, -1]) cylinder(d = wheel_bore + clr_hole, h = carriage_plate_t + 2);
        translate([-wheel_y, 0, -1]) cylinder(d = ecc_bore_d + 0.2, h = carriage_plate_t + 2);
        // sunk heads, as on P1 (on the bed there too)
        for (x = [-wheel_y, wheel_y]) translate([x, 0, -1]) cylinder(d = wheel_cbore_d, h = wheel_cbore_h + 1);
        for (i = [0:3]) {
            x = -15 + i * 10;
            translate([x, 4, -1]) cylinder(d = test[i][0], h = carriage_plate_t + 2);
            translate([x, -7, carriage_plate_t - 0.6]) label(test[i][1], 2.6);
        }
        translate([wheel_y, -9, carriage_plate_t - 0.6]) label("F", 3);
        translate([-wheel_y, -9, carriage_plate_t - 0.6]) label("E", 3);
    }
}

// ---------------------------------------------------------------- P0a2
// Both wheels on fixed spacers: one in a hole, one in a slot along the bar.
// Fit on the beam, push the slot wheel in until snug (no rocking, wheels
// upright), tighten, then measure across the outside of the two spacers and
// subtract one spacer's diameter = wheel centre distance (caliper zero
// error cancels). Slot covers 59..63.5 centre to centre (design: 2*wheel_y).
module coupon_slot() {
    s0 = 59; s1 = 63.5;
    len = s1 + 24;
    w = 26;
    x_f = -len/2 + 12;
    difference() {
        translate([-len/2, -w/2, 0]) cube([len, w, carriage_plate_t]);
        translate([x_f, 0, 0]) {
            translate([0, 0, -1]) cylinder(d = wheel_bore + clr_hole, h = carriage_plate_t + 2);
            translate([0, 0, -1]) cylinder(d = wheel_cbore_d, h = 5.2 + 1);
        }
        hull() for (x = [s0, s1]) translate([x_f + x, 0, -1])
            cylinder(d = wheel_bore + clr_hole, h = carriage_plate_t + 2);
        hull() for (x = [s0, s1]) translate([x_f + x, 0, -1])
            cylinder(d = wheel_cbore_d, h = 5.2 + 1);
        translate([x_f, -9, carriage_plate_t - 0.6]) label("F", 3);
        translate([x_f + (s0 + s1)/2, -9, carriage_plate_t - 0.6]) label("59-63.5", 2.6);
    }
}

// ---------------------------------------------------------------- P0b
// Same thickness as the brackets. Check: KFL08 bolts drop into the slots,
// the race clears the 20 mm hole, the nut flange drops into its recess and
// its 4 holes line up with the M3 holes (nuts trapped underneath).
module coupon_bearing() {
    w = 60; d = 78;
    kfl_y = 20; nut_y = 58;
    flange_recess = 2;
    difference() {
        translate([-w/2, 0, 0]) cube([w, d, bracket_t]);

        // KFL08: clearance hole + bolt slots (±2 mm, for truing the screw)
        translate([0, kfl_y, -1]) cylinder(d = kfl_clear_hole, h = bracket_t + 2);
        for (sx = [-1, 1]) translate([sx * kfl_pitch/2, kfl_y, 0]) {
            hull() for (dy = [-2, 2]) translate([0, dy, -1]) cylinder(d = 5.5, h = bracket_t + 2);
            hull() for (dy = [-2, 2]) translate([0, dy, -1]) hex(m5_nut_af + clr_hole, 4.2 + 1);
        }

        // Anti-backlash nut: flange recess with float, body hole, M3 + traps
        translate([0, nut_y, bracket_t - flange_recess])
            cylinder(d = abn_flange_d + 0.6, h = flange_recess + 1);
        translate([0, nut_y, -1]) cylinder(d = abn_body_d + 2, h = bracket_t + 2);
        for (a = [0:90:270])
            translate([0, nut_y, 0]) rotate(a) translate([abn_bcd/2, 0, 0]) {
                translate([0, 0, -1]) cylinder(d = 3.4, h = bracket_t + 2);
                translate([0, 0, -1]) hex(m3_nut_af + clr_hole, 3 + 1);
            }

        translate([w/2 - 6, 4, bracket_t - 0.6]) label("P0b", 3);
    }
}

if (part == "wheel") coupon_wheel();
else if (part == "slot") coupon_slot();
else if (part == "bearing") coupon_bearing();
else {
    coupon_wheel();
    translate([0, 40, 0]) coupon_bearing();
}
