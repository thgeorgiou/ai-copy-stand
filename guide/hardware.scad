// Fasteners and small bought parts, for the assembly guide's pictures only.
// Each is modelled on the z axis; build.py rotates it onto its insertion axis
// (shank pointing -z = the direction it goes in).

c_steel = [0.55, 0.56, 0.60];
c_black = [0.15, 0.15, 0.17];
c_zinc  = [0.70, 0.70, 0.62];
c_brass = [0.80, 0.65, 0.30];

// Head on top (z 0..), shank down to -l.
module bolt(l, d = 5, head = "socket") {
    hd = head == "low" ? d * 1.9 : d * 1.7;
    hh = head == "low" ? d * 0.55 : d;
    color(c_black) difference() {
        union() {
            cylinder(d = hd, h = hh, $fn = 32);
            translate([0, 0, -l]) cylinder(d = d, h = l, $fn = 24);
        }
        translate([0, 0, hh - d * 0.45]) cylinder(d = d * 0.55, h = d, $fn = 6);
    }
}

// Centred on the origin.
module nut(d = 5, nylock = false) {
    af = d * 1.6; h = d * 0.8;
    color(c_zinc) difference() {
        union() {
            translate([0, 0, -h/2]) cylinder(d = af / cos(30), h = h, $fn = 6);
            if (nylock) color([0.2, 0.3, 0.8]) translate([0, 0, h/2]) cylinder(d = af * 0.9, h = d * 0.35, $fn = 24);
        }
        cylinder(d = d, h = 4 * d, center = true, $fn = 20);
    }
}

module washer(d = 5, od = 0, t = 1) {
    color(c_zinc) difference() {
        cylinder(d = od > 0 ? od : d * 2, h = t, center = true, $fn = 32);
        cylinder(d = d + 0.3, h = t + 1, center = true, $fn = 20);
    }
}

// Drop-in T-nut for a V-slot side slot: bolt axis z, long side along x.
module tnut() {
    color(c_zinc) difference() {
        hull() {
            translate([-5, -3, -1]) cube([10, 6, 1]);
            translate([-4, -1.5, -3.5]) cube([8, 3, 1]);
        }
        cylinder(d = 5, h = 10, center = true, $fn = 20);
    }
}

// 625 bearing, centred.
module bearing() {
    color(c_steel) difference() {
        cylinder(d = 16, h = 5, center = true, $fn = 40);
        cylinder(d = 5, h = 6, center = true, $fn = 20);
    }
    color(c_black) difference() {
        cylinder(d = 13.5, h = 5.1, center = true, $fn = 40);
        cylinder(d = 8, h = 6, center = true, $fn = 30);
    }
}

// Plain Tr8 brass nut: ring on the flat side at z < 0, flange z 0..4, body above.
module brass_nut(fd = 26, ft = 4, bd = 10, len = 15, bcd = 17, hole = 4, ring = 1) {
    color(c_brass) difference() {
        union() {
            cylinder(d = fd, h = ft, $fn = 48);
            cylinder(d = bd, h = len, $fn = 32);
            translate([0, 0, -ring]) cylinder(d = fd - 2, h = ring, $fn = 48);
        }
        translate([0, 0, -2]) cylinder(d = 8, h = len + 4, $fn = 24);
        for (a = [45:90:315]) rotate(a) translate([bcd/2, 0, -2]) cylinder(d = hole, h = ft + 4, $fn = 16);
    }
}

// Rotate so local -z points along an axis name.
module along(axis) {
    if (axis == "-z") children();
    else if (axis == "+z") rotate([180, 0, 0]) children();
    else if (axis == "+x") rotate([0, -90, 0]) children();
    else if (axis == "-x") rotate([0, 90, 0]) children();
    else if (axis == "+y") rotate([90, 0, 0]) children();
    else if (axis == "-y") rotate([-90, 0, 0]) children();
}

// V-wheel with its two bearing seats, for the bearing-pressing picture.
// Axis along x, centred. cut = remove a quarter to show the inside.
module wheel_seats(cut = false) {
    r_hub = 12 - 2.8;
    color([0.12, 0.12, 0.12]) difference() {
        rotate([0, 90, 0]) rotate_extrude($fn = 64)
            polygon([[8, -5], [r_hub, -5], [r_hub, -2.8], [12, 0], [r_hub, 2.8], [r_hub, 5],
                     [8, 5], [8, 0.5], [6, 0.5], [6, -0.5], [8, -0.5]]);
        if (cut) translate([-6, -13, 0]) cube([12, 13, 13]);
    }
}
