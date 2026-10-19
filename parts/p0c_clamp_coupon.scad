// P0c — Arca clamp test: a 40 mm slice of the real clamp (parts/arca_clamp.scad).
// Hardware: 1x M5x30 DIN912 (press into the knob), 1x M5 H4 nut (drop into
// the slot in the body's back).
//
// Check:
//   - plate drops in from the top with the jaw open and comes to rest on the
//     stop pin, not on the jaw tips
//   - closing the knob pulls the plate flat onto the clamp face, with no
//     rocking; the fixed jaw sets the position
//   - the jaw tips don't bottom out under the plate's ledge
//   - roughly 2 mm of jaw travel is left when closed
//
//   part = "print"   : all three parts laid out for one A1 mini bed
//   part = "preview" : assembled with the plate, clamp face up
include <../params.scad>
use <arca_clamp.scad>
use <../vitamins.scad>

part = "print";
len = 40;

if (part == "preview") {
    clamp_preview(len);
    translate([0, 0, 0]) arca_plate();
} else {
    // Body and jaw stand on their -z end (slide axis vertical), knob flat.
    translate([0, 0, len/2]) clamp_body(len);
    translate([-24, 22, len/2]) clamp_moving_jaw(len);
    translate([30, 30, 0]) clamp_knob();
}
