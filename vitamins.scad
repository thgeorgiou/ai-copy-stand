// Copy stand — dummies of the bought parts, for the assembly and clearance checks.
// Visual approximations: only the dimensions in params.scad are authoritative.
include <params.scad>

c_alu    = [0.78, 0.80, 0.82];
c_steel  = [0.55, 0.56, 0.60];
c_brass  = [0.80, 0.65, 0.30];
c_delrin = [0.12, 0.12, 0.12];
c_zinc   = [0.62, 0.63, 0.58];
c_dark   = [0.18, 0.18, 0.20];
c_wood   = [0.82, 0.68, 0.45];

// ---------------------------------------------------------------- V-slot 2040
// One V-slot opening, 2D, on a face at y = 0, cutting into -y.
module vslot_cut_2d() {
    polygon([[-4.6, 0.1], [4.6, 0.1], [3.1, -1.5], [3.1, -2.0],
             [5.6, -4.5], [5.6, -6.2], [-5.6, -6.2], [-5.6, -4.5],
             [-3.1, -2.0], [-3.1, -1.5]]);
}

module vslot_2040_2d() {
    difference() {
        offset(r = 1) offset(delta = -1) square([beam_w, beam_d], center = true);
        // front / back faces: one slot each
        for (s = [1, -1]) rotate(s > 0 ? 0 : 180) translate([0, beam_d/2]) vslot_cut_2d();
        // side faces: two slots each
        for (sx = [1, -1], yy = [-10, 10])
            translate([sx * beam_w/2, yy]) rotate(sx > 0 ? -90 : 90) vslot_cut_2d();
        for (yy = [-10, 10]) translate([0, yy]) circle(d = vslot_bore_d);
        square([4, 6], center = true);
    }
}

// Centred in x/y, from z = 0 up.
module vslot_2040(len = beam_len) {
    color(c_alu) linear_extrude(len) vslot_2040_2d();
}

// ---------------------------------------------------------------- V-wheel
// Axis along x, centred on the wheel.
module vwheel() {
    r_hub = wheel_od/2 - 2.8;
    color(c_delrin) rotate([0, 90, 0]) rotate_extrude()
        polygon([[wheel_bore/2, -wheel_w/2], [r_hub, -wheel_w/2], [r_hub, -2.8],
                 [wheel_od/2, 0], [r_hub, 2.8], [r_hub, wheel_w/2],
                 [wheel_bore/2, wheel_w/2]]);
}

// Spacer along +x from x = 0.
module wheel_spacer(eccentric = false) {
    color(eccentric ? c_steel : c_alu) rotate([0, 90, 0])
        difference() {
            cylinder(d = eccentric ? 10 : 8, h = wheel_spacer, $fn = eccentric ? 6 : 32);
            translate([0, 0, -1]) cylinder(d = 5, h = wheel_spacer + 2);
        }
}

// ---------------------------------------------------------------- KFL08
// Mounting face at z = 0, housing rises to +z, long axis along x.
module kfl08_2d() {
    ear_r = kfl_l/2 - kfl_pitch/2;
    hull() {
        circle(d = kfl_w);
        for (sx = [-1, 1]) translate([sx * kfl_pitch/2, 0]) circle(r = ear_r);
    }
}

module kfl08() {
    color(c_zinc) difference() {
        union() {
            linear_extrude(kfl_flange_t) kfl08_2d();
            cylinder(d = kfl_housing_d, h = kfl_housing_h);
        }
        for (sx = [-1, 1]) translate([sx * kfl_pitch/2, 0, -1])
            cylinder(d = kfl_hole_d, h = kfl_flange_t + 2);
        translate([0, 0, -1]) cylinder(d = kfl_race_d + 1, h = kfl_housing_h + 2);
    }
    // Inner race: assumed proud on the housing side (which side is unconfirmed;
    // brackets clear both).
    color(c_steel) difference() {
        cylinder(d = kfl_race_d, h = kfl_housing_h + kfl_race_proud);
        translate([0, 0, -1]) cylinder(d = kfl_bore, h = kfl_housing_h + kfl_race_proud + 2);
    }
}

// ---------------------------------------------------------------- Tr8 screw
module tr8(len = screw_len) {
    color(c_steel) cylinder(d = screw_d, h = len, $fn = 32);
}

// ---------------------------------------------------------------- anti-backlash nut
// Flange underside at z = 0. Main nut body hangs below, spring side above.
module ab_nut() {
    color(c_brass) difference() {
        union() {
            cylinder(d = abn_flange_d, h = abn_flange_t);
            translate([0, 0, -abn_body_l]) cylinder(d = abn_body_d, h = abn_body_l);
            // spring section, then spring-end nut
            translate([0, 0, abn_flange_t])
                cylinder(d = abn_spring_d_min, h = abn_spring_l - 4);
            translate([0, 0, abn_flange_t + abn_spring_l - 4])
                cylinder(d = abn_spring_d_max, h = 4);
        }
        for (a = [0:90:270]) rotate(a) translate([abn_bcd/2, 0, -1])
            cylinder(d = abn_hole_d, h = abn_flange_t + 2);
        translate([0, 0, -abn_body_l - 1])
            cylinder(d = screw_d, h = abn_body_l + abn_flange_t + abn_spring_l + 2);
    }
}

// ---------------------------------------------------------------- Arca plate
// Clamp-side face at y = 0, camera side at y = plate_t; centred in x and z.
// The real plate, from its STL (STL: x across, y along the slide, z = 0 clamp face).
// STL: "Tripod quick release plate" by unwohlpol, Printables #204259, CC BY-NC-SA 4.0.
module arca_plate() {
    color(c_dark) translate([0, 0, -plate_l/2]) rotate([0, 0, 180]) rotate([90, 0, 0])
        translate([-plate_w/2, 0, 0]) import("samples/quickrelease.stl");
}

// ---------------------------------------------------------------- camera
// Origin on the optical axis at the lens mount face; lens points -z,
// the camera's base faces -y (towards the column).
module camera_dummy() {
    color(c_dark)
        translate([-cam_w/2, -cam_base_to_axis, 0]) cube([cam_w, cam_h, cam_d]);
}

// Below the mount face (-z): adapter, then lens, extended for focus.
module lens_dummy(ext = lens_f * mag) {
    color([0.25, 0.25, 0.27]) translate([0, 0, -adapter_l])
        cylinder(d = adapter_d, h = adapter_l);
    color(c_dark) translate([0, 0, -adapter_l - lens_l])
        cylinder(d = lens_d, h = lens_l);
    color(c_dark) translate([0, 0, -adapter_l - lens_l - ext])
        cylinder(d = 50, h = ext);
}

// Sensor outline, for checking height.
module sensor_mark() {
    color("red") translate([-sensor_w/2, -6.5, 0]) cube([sensor_w, 13, 0.3]);
}

// ---------------------------------------------------------------- film holder
// Back edge at y = 0, centred in x, standing on z = 0.
module film_holder() {
    color([0.35, 0.35, 0.38]) translate([-holder_w/2, 0, 0])
        cube([holder_w, holder_d, holder_h - 0.5]);
    // film strip, frame centred on holder_film_from_back
    color([1, 0.85, 0.5]) translate([-holder_w/2, holder_film_from_back - 35/2, holder_h - 0.5])
        cube([holder_w, 35, 0.5]);
}

// ---------------------------------------------------------------- board
module board() {
    color(c_wood)
        translate([-board_w/2, -beam_d/2 - board_back_margin, -board_t])
            cube([board_w, board_d, board_t]);
}
