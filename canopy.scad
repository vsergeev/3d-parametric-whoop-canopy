/********************************************************
 * Parametric Whoop Canopy - vsergeev
 * https://github.com/vsergeev/3d-parametric-whoop-canopy
 * CC-BY-4.0
 * v1.0
 ********************************************************/

/* [General] */

canopy_z_height = 15;
canopy_top_x_width = 10;
canopy_front_z_height = 3;
canopy_rear_z_height = 3;
canopy_xyz_thickness = 2;

/* [Mounting Holes] */

canopy_mounting_hole_xy_pitch = 26;
canopy_mounting_hole_xy_diameter = 2;
canopy_mounting_ring_xy_diameter = 5.5;
canopy_mounting_nut_xy_width = 3.75;
canopy_mounting_nut_z_depth = 1.25;
canopy_antenna_hole_xy_diameter = 2;

/* [Hidden] */

camera_xyz_segments = [[0, 0, 0], [0, 0, 0], [0, 0, 0]];

overlap_epsilon = 0.01;

$fn = $preview ? 50 : 100;

/******************************************************************************/
/* Derived Parameters */
/******************************************************************************/

canopy_xy_width = canopy_mounting_hole_xy_pitch / sin(45);

harness_dimensions = [max(camera_xyz_segments[0].x, camera_xyz_segments[1].x, camera_xyz_segments[2].x),
                      camera_xyz_segments[0].y + camera_xyz_segments[1].y + camera_xyz_segments[2].y,
                      max(camera_xyz_segments[0].z, camera_xyz_segments[1].z, camera_xyz_segments[2].z)];

/******************************************************************************/
/* 2D Profiles */
/******************************************************************************/

module mounting_ring_xy_footprint() {
    circle(d=canopy_mounting_ring_xy_diameter);
}

module mounting_hole_xy_footprint() {
    circle(d=canopy_mounting_hole_xy_diameter);
}

module mounting_nut_xy_footprint() {
    circle(d=canopy_mounting_nut_xy_width, $fn=6);
}

module canopy_xy_footprint() {
    polygon([
        [-canopy_mounting_ring_xy_diameter / 2, canopy_xy_width / 2],
        [canopy_mounting_ring_xy_diameter / 2, canopy_xy_width / 2],
        [canopy_xy_width / 2, canopy_mounting_ring_xy_diameter / 2],
        [canopy_xy_width / 2, -canopy_mounting_ring_xy_diameter / 2],
        [canopy_mounting_ring_xy_diameter / 2, -canopy_xy_width / 2],
        [-canopy_mounting_ring_xy_diameter / 2, -canopy_xy_width / 2],
        [-canopy_xy_width / 2, -canopy_mounting_ring_xy_diameter / 2],
        [-canopy_xy_width / 2, canopy_mounting_ring_xy_diameter / 2]
    ]);
}

/******************************************************************************/
/* Helpers */
/******************************************************************************/

module harness_orient(camera_angle, camera_z_offset) {
    translate([0, 0, canopy_front_z_height - harness_dimensions.y * sin(camera_angle) + camera_z_offset])
        rotate([camera_angle, 0, 0])
            children();
}

/******************************************************************************/
/* 3D Extrusions */
/******************************************************************************/

module shell() {
    hull() {
        linear_extrude(canopy_xyz_thickness)
            canopy_xy_footprint();

        translate([0, 0, canopy_z_height])
            resize([canopy_top_x_width, canopy_top_x_width, canopy_xyz_thickness])
                sphere(d=1);
    }
}

module mounting_ring() {
    linear_extrude(canopy_xyz_thickness)
        mounting_ring_xy_footprint();
}

module mounting_hole() {
    translate([0, 0, -overlap_epsilon])
        linear_extrude(canopy_xyz_thickness + 2 * overlap_epsilon)
            mounting_hole_xy_footprint();
}

module mounting_nut() {
    translate([0, 0, canopy_xyz_thickness - canopy_mounting_nut_z_depth])
        linear_extrude(canopy_xyz_thickness * 2)
            mounting_nut_xy_footprint();
}

module canopy_base() {
    difference() {
        union() {
            /* Outer Shell */
            shell();

            /* Mounting Rings */
            for (i = [0:3]) {
                rotate(90 * i)
                    translate([0, canopy_xy_width / 2])
                        mounting_ring();
            }
        }

        /* Mounting Holes and Nuts */
        for (i = [0:3]) {
            rotate(90 * i) {
                translate([0, canopy_xy_width / 2]) {
                    mounting_hole();
                    mounting_nut();
                }
            }
        }

        /* Inner Shell */
        translate([0, 0, -overlap_epsilon])
            resize([canopy_xy_width - canopy_xyz_thickness * 2, canopy_xy_width - canopy_xyz_thickness * 2, canopy_z_height - canopy_xyz_thickness])
                shell();

        /* Front Camera Relief */
        translate([0, canopy_xy_width / 4, canopy_front_z_height])
            linear_extrude(canopy_z_height)
                square([canopy_top_x_width + overlap_epsilon, canopy_xy_width / 2], center=true);

        /* Rear Camera Relief */
        translate([0, -canopy_xy_width / 4, canopy_rear_z_height])
            linear_extrude(canopy_z_height)
                square([canopy_top_x_width + overlap_epsilon, canopy_xy_width / 2 + overlap_epsilon], center=true);

        /* Right Antenna Hole */
        translate([(canopy_top_x_width / 2 + canopy_xy_width / 2) / 2, -canopy_xy_width / 8, -overlap_epsilon])
            cylinder(d=canopy_antenna_hole_xy_diameter, h=canopy_z_height);

        /* Left Antenna Hole */
        translate([-(canopy_top_x_width / 2 + canopy_xy_width / 2) / 2, -canopy_xy_width / 8, -overlap_epsilon])
            cylinder(d=canopy_antenna_hole_xy_diameter, h=canopy_z_height);
    }
}

module harness_support() {
    translate([-(canopy_xy_width - canopy_xyz_thickness * 2) / 2, 0])
        cube([canopy_xy_width - canopy_xyz_thickness * 2, harness_dimensions.y, canopy_xyz_thickness]);
}

module harness_base() {
    /* Base */
    translate([-harness_dimensions.x / 2, 0])
        cube(harness_dimensions);
}

module harness_slots() {
    /* Camera Slot Offsets */
    camera_segments_y_offsets = [ for (i = 0, o = 0; i < len(camera_xyz_segments); i = i + 1,  o = o + camera_xyz_segments[i - 1].y) o];

    /* Camera Segments */
    union() {
        for (i = [0:len(camera_xyz_segments) - 1]) {
            translate([-camera_xyz_segments[i].x / 2 - overlap_epsilon, camera_segments_y_offsets[i] - overlap_epsilon, harness_dimensions.z - camera_xyz_segments[i].z - overlap_epsilon])
                 cube([camera_xyz_segments[i].x + 2 * overlap_epsilon, camera_xyz_segments[i].y + 2 * overlap_epsilon, camera_xyz_segments[i].z + 2 * overlap_epsilon]);
        }
    }
}

module canopy(camera_angle, camera_z_offset) {
    difference() {
        union() {
            /* Canopy Base */
            canopy_base();

            /* Harness Support */
            intersection() {
                harness_orient(camera_angle, camera_z_offset)
                    harness_support();

                shell();
            }

            /* Harness Base */
            intersection() {
                harness_orient(camera_angle, camera_z_offset)
                    harness_base();

                translate([(harness_dimensions.x) / 2, 0])
                    rotate([90, 0, -90])
                        linear_extrude(harness_dimensions.x)
                            translate([0, 0])
                                resize([canopy_xy_width, canopy_z_height * 2])
                                    circle(d=1);

                cylinder(d=canopy_xy_width, h=canopy_z_height);
            }
        }

        /* Harness Slots */
        harness_orient(camera_angle, camera_z_offset)
            harness_slots();
    }
}
