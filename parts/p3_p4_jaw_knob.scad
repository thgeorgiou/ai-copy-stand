// P3 moving jaw + P4 clamp knob for the carriage (P1). Same as P0c's, but
// the jaw is mirrored: on the carriage the moving jaw is on the left.
// Hardware: 1x M5x30 DIN912 (pressed into the knob), 1x M5 H4 nut (drops in
// from the top of the carriage's clamp body).
include <../params.scad>
use <arca_clamp.scad>

clamp_len = carriage_clamp_len;

translate([0, 0, clamp_len/2]) mirror([1, 0, 0]) clamp_moving_jaw(clamp_len);
translate([0, 30, 0]) clamp_knob();
