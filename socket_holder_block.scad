module socket_holder(
  socket_diameter = 16.85, // Don't add tolerance here
  socket_tol = 0.3, // Adjust for fitment
  socket_bevel = 1.5,
  socket_fn = 50,
  side_pad = 1,
  rail_depth = 3.5,
  magnet_diameter = 20, // Want this to be press fit
  magnet_height = 3,
  magnet_fn = 25,
  block_depth = -1, // Auto-calc if negative
  label = "15/32",
  label_size = 6,
  label_margin = 2,
  label_depth = 1.0,
  label_on_rail = true,
  font = "Liberation Sans:style=Bold"
) {

  real_diam = socket_diameter + socket_tol;
  radius_diff = (magnet_diameter - real_diam) / 2;
  transition_h = (radius_diff > 0) ? radius_diff : 0;

  block_width = max(real_diam, magnet_diameter) + 2 * side_pad;
  block_height = 18; // socket_depth + magnet_height + transition_h);
  block_len = max(block_width, block_depth);
  echo("Block Length: ", block_len);
  echo("Block Width: ", block_width);
  echo("Block Height: ", block_height);
  socket_depth = block_height - (magnet_height + transition_h);

  label_face = label_size + label_margin;
  ledge_size = label_face * sin(45);

  difference() {
    union() {
      // The Main Block
      translate([0, 0, block_height / 2])
        cube([block_width, block_len, block_height], center=true);

      // Multiboard rail block
      translate([0, (block_len + rail_depth) / 2, block_height / 2])
        cube([block_width, rail_depth, block_height], center=true);

      // Label Ledge 
      translate([0, -(block_len + ledge_size) / 2, block_height / 2])
        cube([block_width, ledge_size, block_height], center=true);
    }

    // Magnet hole
    translate([0, 0, -0.01])
      cylinder(h=magnet_height + 0.01, d=magnet_diameter, $fn=magnet_fn);

    // Transition Cone 
    translate([0, 0, magnet_height])
      cylinder(h=transition_h, d1=magnet_diameter, d2=real_diam, $fn=magnet_fn);

    // Socket hole
    translate([0, 0, magnet_height + transition_h])
      cylinder(h=socket_depth - socket_bevel, d=real_diam, $fn=socket_fn);

    // Socket bevel
    translate([0, 0, magnet_height + transition_h + socket_depth - socket_bevel])
      cylinder(h=socket_bevel + 0.01, d1=real_diam, d2=real_diam + socket_bevel, $fn=socket_fn);

    // Rail slot
    rotate([0, -90, 90])
      translate([block_height / 2, block_width / 2, -block_len / 2 - rail_depth - 0.01])
        scale([1.035, 2, 1.035]) import("Multipoint Rail - Positive.stl");

    
    // Bevel Cut & Label
    translate([0, -block_len / 2 - ledge_size, block_height - ledge_size])
      rotate([45, 0, 0]) {
        // Cuts off the bottom-front corner of the ledge to make it 45 degrees
        translate([0, 0, ledge_size])
          cube([block_width + 1, ledge_size * 3, ledge_size * 2], center=true);

        // Engraved into the resulting face
        if (label != "") {
          translate([0, label_face / 2, -label_depth])
            linear_extrude(height=label_depth + 0.1)
              text(label, size=label_size, font=font, halign="center", valign="center");
        }
      }
    if (label_on_rail) {
      // Label on Rail
      translate([0, (block_len + rail_depth) / 2, block_height])
      // Engraved into the rail face
      if (label != "") {
        translate([0, -label_margin / 2, -label_depth])
          linear_extrude(height=label_depth + 0.1)
            text(label, size=4, font=font, halign="center", valign="center");
      }
    }
  }
}

socket_holder();
