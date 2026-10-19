// Arca clamp for the Sirui TY-C10 — shared by P0c (test) and P1 (carriage).
//
// Local coordinates match the assembly, centred on the plate:
//   x across the jaws (fixed jaw -x, moving jaw +x)
//   y away from the clamp face (clamp face y = 0, plate y 0..plate_t)
//   z along the slide axis (vertical in use, plate drops in from +z)
// The jaw profile is constant along z, so parts print standing on their -z
// end: the 45° tips lie in the layer plane and need no supports.
include <../params.scad>

// Clamp parameters live in params.scad (other parts need them too).

// ---------------------------------------------------------------- 2D profiles
module fixed_jaw_2d() {
    c = face_c + jaw_fixed_off;
    wall = plate_w/2 + jaw_wall_clr;
    polygon([[-jaw_out_x, 0], [-wall, 0], [-wall, c - wall],
             [-(c - jaw_tip_y), jaw_tip_y], [-jaw_out_x, jaw_tip_y]]);
}

// Moving jaw drawn at its nominal closed position.
module moving_jaw_2d() {
    wall = plate_w/2 + jaw_wall_clr;
    foot = channel_x + foot_clr;
    polygon([[foot, channel_floor + foot_clr], [jaw_out_x, channel_floor + foot_clr],
             [jaw_out_x, jaw_tip_y], [face_c - jaw_tip_y, jaw_tip_y],
             [wall, face_c - wall], [wall, 0], [foot, 0]]);
}

module body_2d() {
    difference() {
        translate([-jaw_out_x, -clamp_back_t]) square([jaw_out_x + body_end_x, clamp_back_t]);
        translate([channel_x, channel_floor]) square([body_end_x, -channel_floor + 1]);
    }
    fixed_jaw_2d();
}

// Horizontal hole along +x from x = 0, with a teardrop point towards +z so
// it prints cleanly when the part stands on its z end.
module bolt_hole_x(d, len) {
    rotate([0, 90, 0]) linear_extrude(len)
        hull() { circle(d = d); translate([-d * 0.71, 0]) circle(d = 0.01); }
}

// ---------------------------------------------------------------- parts
// Clamp body of length len (z, centred). Stop pin at the -z end.
// nut_slot: "back" drops the nut in from the back face (free-standing clamp),
// "top" from the +z end (when the back face is built into the carriage).
module clamp_body(len = 40, nut_slot = "back") {
    nut_w = nut_af + clr_hole;
    difference() {
        union() {
            linear_extrude(len, center = true) body_2d();
            stop_pin();
        }
        // bolt bore, from the channel wall back past the nut
        translate([-12, bolt_y, 0]) bolt_hole_x(bolt_d, channel_x + 13);
        // captive nut, flats facing the slot walls
        translate([nut_x0, bolt_y, 0]) rotate([0, 90, 0]) linear_extrude(nut_h + 0.4)
            rotate(nut_slot == "back" ? 30 : 0) circle(d = nut_w / cos(30), $fn = 6);
        if (nut_slot == "back")
            translate([nut_x0, -clamp_back_t - 1, -nut_w/2])
                cube([nut_h + 0.4, -bolt_y + clamp_back_t + 1, nut_w]);
        else
            translate([nut_x0, bolt_y - nut_w/2, 0]) cube([nut_h + 0.4, nut_w, len/2 + 1]);
    }
}

// Seats in the plate's safety notch: its 45° top matches the notch ramp,
// so the plate's lower end comes to rest on it.
module stop_pin() {
    // Notch floor: y = notch_end_d - (z - z_end). The pin's top follows it, so
    // the plate comes to rest centred at z = 0. (Below y = 0.5 the line runs
    // inside the plate's full-length channel, so it never touches.)
    z_end = -plate_l/2;
    rotate([90, 0, 90]) linear_extrude(pin_w, center = true)
        polygon([[0, z_end - 2], [0, z_end + notch_end_d],
                 [pin_h, z_end + notch_end_d - pin_h], [pin_h, z_end - 2]]);
}

module clamp_moving_jaw(len = 40) {
    difference() {
        linear_extrude(len, center = true) moving_jaw_2d();
        translate([channel_x - 1, bolt_y, 0]) bolt_hole_x(bolt_d, jaw_out_x - channel_x + 2);
    }
}

// Thumb knob over an M5 socket head (press fit on crush ribs, 0.25 mm each:
// P0c's 0.5 mm ribs needed a hammer). Lies flat, knob face (which pushes the
// jaw) at z = 0. Head pocket opens on top. Sizes in params.scad.
module clamp_knob() {
    difference() {
        cylinder(d = knob_d, h = knob_h);
        for (a = [0:45:315]) rotate(a) translate([knob_d/2 + 1.2, 0, -1]) cylinder(d = 5, h = knob_h + 2);
        translate([0, 0, -1]) cylinder(d = bolt_d, h = knob_h + 2);
        translate([0, 0, knob_h - head_h - 0.2]) linear_extrude(head_h + 1) difference() {
            circle(d = head_d + 0.3);
            for (a = [0:60:300]) rotate(a) translate([(head_d + 0.3)/2 + 0.25, 0]) circle(d = 1, $fn = 12);
        }
    }
}

// Clamp parts in place, with the plate, for checking (closed position).
module clamp_preview(len = 40) {
    color([1, 0.55, 0.1]) clamp_body(len);
    color([0.9, 0.4, 0.05]) clamp_moving_jaw(len);
    color([0.5, 0.5, 0.5]) translate([jaw_out_x, bolt_y, 0]) rotate([0, 90, 0]) clamp_knob();
}
