/********************************************************
 * BETAFPV C03 Parametric Whoop Canopy - vsergeev
 * https://github.com/vsergeev/3d-parametric-whoop-canopy
 * CC-BY-4.0
 * v1.0
 ********************************************************/

include <canopy.scad>;

// Dimensional changes
canopy_z_height = 16.5;
canopy_top_x_width = 11.8;
camera_xyz_segments = [[5, 2.5, 11], [11.8, 3.2, 14], [8.2, 7, 11.5]];

// Camera parameters
camera_angle = 5;
camera_z_offset = 0;

canopy(camera_angle, camera_z_offset);
