// P7 — Handwheel on top of the leadscrew, plus an optional crank handle.
//
// The screw hangs from the top KFL08. The screw's plain brass nut sits in the
// hub, flange down, its 1 mm ring bearing on the KFL08's inner race: it
// carries the screw's axial load. Four M3 screws hold it to the hub, and a radial M3
// through the hub locks the wheel to the thread so it turns the screw.
// The race sits 4 mm proud of its housing, plus the 1 mm ring, so the M3
// heads under the flange clear the housing.
//
// Tr8x2 = 2 mm per turn, so a spinning crank handle is on the rim.
//
// Modelled with z = 0 at the bottom of the nut flange (1 mm above the inner
// race), axis on the screw. Prints as modelled, flange pocket on the bed.
// Hardware: plain Tr8 brass nut, 4x M3x8-10 (self-tapping into PLA), 1x M3x10-12
// + M3 nut (radial lock), crank: 1x M5x60 + 3x H4 nut.
include <../params.scad>

part = "wheel";       // "wheel" | "crank_sleeve"

wheel_d = 60;
rim_t   = 7;
hub_d   = 26;
hub_h   = 32;
lock_z  = pn_len + 7;           // radial lock, above the nut
crank_r = wheel_d/2 - 7;
sleeve_l = 34;
sleeve_d = 14;

module handwheel() {
    difference() {
        union() {
            cylinder(d = hub_d, h = hub_h);
            // rim + 6 spokes as a single dished disk with cut-outs
            difference() {
                cylinder(d = wheel_d, h = rim_t);
                for (a = [30:60:330]) rotate(a) translate([20, 0, -1])
                    cylinder(d = 8, h = rim_t + 2);
            }
            translate([crank_r, 0, 0]) cylinder(d = 14, h = rim_t);
        }
        // grip scallops round the rim
        for (a = [0:20:340]) rotate(a + 10) translate([wheel_d/2 + 2.2, 0, -1])
            cylinder(d = 6, h = rim_t + 2);
        // screw
        translate([0, 0, -1]) cylinder(d = screw_d + 0.6, h = hub_h + 2);
        // brass nut: flange pocket + body
        translate([0, 0, -0.01]) cylinder(d = pn_flange_d + 0.4, h = pn_flange_t);
        cylinder(d = pn_body_d + 0.4, h = pn_len + 0.3);
        // M3 pilots through the flange holes, up into the hub
        for (a = [45:90:315]) rotate(a) translate([pn_bcd/2, 0, 0])
            cylinder(d = 2.6, h = pn_flange_t + 10, $fn = 16);
        // radial lock: M3 through the hub, nut dropped in from the top; on
        // the side away from the crank so a hex key can reach it
        rotate([0, 0, 180]) {
            translate([0, 0, lock_z]) rotate([0, 90, 0]) cylinder(d = 3.4, h = hub_d, $fn = 16);
            translate([screw_d/2 + 2.5, -5.8/2, lock_z - 3.3])
                cube([2.8, 5.8, hub_h]);
        }
        // crank axle: M5x60 up from below, head sunk into the rim (a bolt
        // tail hanging below would hit the top KFL08's ears)
        translate([crank_r, 0, -1]) cylinder(d = 5.5, h = rim_t + 2);
        translate([crank_r, 0, -0.01]) cylinder(d = 9.2, h = 3);
    }
}

// Spins on the M5x60: head sunk in the rim's underside, a nut on top clamps
// the bolt to the rim, then the sleeve, then two nuts jammed together.
module crank_sleeve() {
    difference() {
        cylinder(d = sleeve_d, h = sleeve_l);
        translate([0, 0, -1]) cylinder(d = 5.8, h = sleeve_l + 2);
    }
}

if (part == "crank_sleeve") crank_sleeve();
else handwheel();
