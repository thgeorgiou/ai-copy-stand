// Copy stand — full assembly for layout and clearance checks.
include <params.scad>
use <vitamins.scad>
use <parts/arca_clamp.scad>
use <parts/p1_carriage.scad>
use <parts/p5_bearing_bracket.scad>
use <parts/p6_foot.scad>
use <parts/p7_handwheel.scad>

// Camera height: by default, set for the film-scanning magnification.
// Override carriage_z with -D to look at other heights.
mount_z_default = sensor_z - mft_flange;            // camera lens-mount face
carriage_z = mount_z_default + cam_socket_from_mount;   // clamp centred on carriage
mount_z    = carriage_z - cam_socket_from_mount;

show_camera = true;
show_holder = true;

c_print  = [1.0, 0.55, 0.1];
c_print2 = [0.95, 0.45, 0.05];

// ---------------------------------------------------------------- derived
top_race_top = top_bracket_z + bracket_t + kfl_housing_h + kfl_race_proud;
holder_y0  = axis_y - holder_film_from_back;
lens_rear_clr = axis_y - lens_d/2 - clamp_face_y;

echo(str("\n",
  "--- layout ------------------------------------------------\n",
  "wheel centres y          = ±", wheel_y, "\n",
  "screw axis y             = ", screw_y, "\n",
  "clamp face y             = ", clamp_face_y, "\n",
  "optical axis y           = ", axis_y, "  (", axis_y - beam_d/2, " ahead of beam front face)\n",
  "--- optics ------------------------------------------------\n",
  "magnification            = ", mag, "  (field ", sensor_w / mag, " mm wide)\n",
  "film -> sensor           = ", film_to_sensor, "\n",
  "sensor z                 = ", sensor_z, "\n",
  "carriage centre z        = ", carriage_z, "\n",
  "--- other -------------------------------------------------\n",
  "screw above top race     = ", screw_z1 - top_race_top, "  (handwheel hub top at ", pn_ring_h + 32, ")\n",
  "holder back edge y       = ", holder_y0, "  (", holder_y0 - beam_d/2, " from beam)\n",
  "holder top -> bracket    = ", bottom_bracket_z - holder_h, "\n",
  "lens rear -> clamp face  = ", lens_rear_clr, "\n"
));

// ---------------------------------------------------------------- groups
// Everything bolted to the board.
module fixed_parts() {
    color(c_print) foot();
    for (z = [bottom_bracket_z, top_bracket_z]) {
        color(c_print) translate([0, 0, z]) bearing_bracket();
        translate([0, screw_y, z + bracket_t]) kfl08();
    }
}

// Everything that rides on the carriage, at carriage centre cz.
module moving_parts(cz = carriage_z, camera = true) {
    translate([0, 0, cz]) {
        color(c_print) carriage();
        translate([0, clamp_face_y, 0]) {
            color(c_print2) mirror([1, 0, 0]) clamp_moving_jaw(carriage_clamp_len);
            color([0.5, 0.5, 0.5]) translate([-jaw_out_x, bolt_y, 0]) rotate([0, -90, 0]) clamp_knob();
            arca_plate();
        }
        // anti-backlash nut: flange on the seat, spring end down in the bore
        translate([0, screw_y, nut_seat_z + abn_flange_t]) mirror([0, 0, 1]) ab_nut();
        // running gear: front pair fixed, back pair eccentric
        for (dz = [-1, 1], sy = [-1, 1])
            translate([0, sy * wheel_y, dz * carriage_wheelbase/2]) {
                vwheel();
                translate([wheel_w/2, 0, 0]) wheel_spacer(eccentric = sy < 0);
            }
    }
    if (camera) translate([0, axis_y, cz - cam_socket_from_mount]) {
        camera_dummy();
        lens_dummy();
        translate([0, 0, mft_flange]) sensor_mark();
    }
}

// ---------------------------------------------------------------- scene
board();
vslot_2040();
translate([0, screw_y, screw_z0]) tr8();
fixed_parts();
color(c_print) translate([0, screw_y, top_race_top + pn_ring_h]) handwheel();
moving_parts(carriage_z, show_camera);
if (show_holder) translate([0, holder_y0, 0]) film_holder();
