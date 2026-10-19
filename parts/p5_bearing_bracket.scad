// P5 — Bearing bracket, print 2 (top and bottom are the same part).
//
// A plate carrying a KFL08 over the screw, hung off the beam's left face by
// a skirt with 4 T-nuts. The left face is the only one with no wheels or
// carriage on it, so the carriage can run right up to either bracket.
//   bottom: plate underside at z = bottom_bracket_z (film holder slides under)
//   top:    plate resting on the beam's top end (the screw hangs from it)
// The skirt wraps the beam's back-left and front-left corners (stopping short
// of the wheel grooves) and runs on forward under the overhang as a deep web.
// Everything below the plate stays in space no carriage position, wheel or
// film holder ever reaches — re-check with the assembly after changes.
// KFL08 holes are oversized (±1.5 mm) to true the screw parallel to the beam:
// washers both sides, nuts underneath.
//
// Modelled in assembly x/y with z = 0 at the plate underside. Prints upside
// down (plate on the bed, skirt up).
// Hardware per bracket: 4x M5x10 low-profile + drop-in T-nuts,
// 2x M5x25 + 2x H4 nut + 4x washer for the KFL08.
include <../params.scad>

part = "print";

skirt_t   = 7;
skirt_h   = 30;       // bottom bracket: stops above the foot's collar
cbore_d   = 10.5;     // low-profile M5 head, sunk 2 mm -> 5 mm into the T-nut
cbore_h   = 2;
beam_clr  = 0.3;
kfl_adj   = 1.5;      // [D] ± adjustment on the KFL08 bolts
groove_x  = -5.5;     // corner wraps stop here; wheels run in x -5..5
web_y1    = holder_y_min() - 0.01;   // full-depth web stops where the holder starts
web_y2    = screw_y - 10;            // shallow tail, clear of the KFL08 washer
web_tail_h = bottom_bracket_z - holder_h - 2;

x0 = -beam_w/2 - beam_clr - skirt_t;
x1 = kfl_l/2 + 3;     // past the KFL08 ears
y0 = -beam_d/2 - beam_clr - skirt_t;
y1 = screw_y + kfl_w/2 + 3;

function holder_y_min() = axis_y - holder_film_from_back;

module bearing_bracket() {
    difference() {
        union() {
            // left strip + front plate carrying the KFL08
            translate([x0, y0, 0]) cube([-x0 - beam_w/2 - beam_clr, y1 - y0, bracket_t]);
            translate([-x1, beam_d/2 + beam_clr, 0]) cube([2 * x1, y1 - beam_d/2 - beam_clr, bracket_t]);
            // skirt: left face, wrapping both left corners up to the grooves,
            // and on forward under the overhang
            translate([x0, y0, -skirt_h]) cube([skirt_t, web_y1 - y0, skirt_h + bracket_t]);
            for (y = [y0, beam_d/2 + beam_clr])
                translate([x0, y, -skirt_h]) cube([groove_x - x0, skirt_t, skirt_h + bracket_t]);
            // front gusset in the corner, against the beam's front face
            translate([x0, beam_d/2 + beam_clr, -skirt_h])
                cube([groove_x - x0, web_y1 - beam_d/2 - beam_clr, skirt_h + bracket_t]);
            // shallow tail of the web over the film holder
            translate([x0, web_y1 - 0.01, -web_tail_h]) cube([skirt_t, web_y2 - web_y1, web_tail_h + bracket_t]);
        }
        // the beam, and nothing beside its right face (carriage side)
        translate([-beam_w/2 - beam_clr, -beam_d/2 - beam_clr, -skirt_h - 1])
            cube([x1 + beam_w, beam_d + 2 * beam_clr, skirt_h + bracket_t + 2]);
        // T-nut bolts into the left face's two slots, heads sunk
        for (yy = [-10, 10], zz = [-8, -22])
            translate([x0 - 1, yy, zz]) rotate([0, 90, 0]) {
                cylinder(d = 5.5, h = skirt_t + 2);
                cylinder(d = cbore_d, h = cbore_h + 1);
            }
        // KFL08: race clearance + oversized bolt holes
        translate([0, screw_y, -skirt_h - 1]) cylinder(d = kfl_clear_hole, h = skirt_h + bracket_t + 2);
        for (sx = [-1, 1]) translate([sx * kfl_pitch/2, screw_y, -1])
            cylinder(d = 5.5 + 2 * kfl_adj, h = bracket_t + 2);
    }
}

if (part == "print") rotate([180, 0, 0]) translate([0, 0, -bracket_t]) bearing_bracket();
else bearing_bracket();
