/********************************************************
 * HDZero Lux Parametric Whoop Canopy - vsergeev
 * https://github.com/vsergeev/3d-parametric-whoop-canopy
 * CC-BY-4.0
 * v1.0
 ********************************************************/

include <canopy.scad>;

// Dimensional changes
canopy_z_height = 18.5;
canopy_top_x_width = 14.5;
camera_xyz_segments = [[6, 2.5, 14], [14.5, 4.6, 16], [10, 7.5, 14]];

// Camera parameters
camera_angle = 5;
camera_z_offset = 0;

canopy(camera_angle, camera_z_offset);
