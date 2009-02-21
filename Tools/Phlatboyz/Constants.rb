require 'sketchup.rb'

# Ruby essentials
# http://www.techotopia.com/index.php/Ruby_Essentials
# http://www.zenspider.com/Languages/Ruby/QuickRef.html
# http://www.regular-expressions.info/ruby.html

# SketchUp
# http://sketchup.google.com
# http://www.suwiki.org
# http://www.sketchucation.com/forums/scf/viewforum.php?f=15

# SketchUp Ruby API
# http://download.sketchup.com/OnlineDoc/gsu6_ruby/Docs/index.html
# http://code.google.com/apis/sketchup/docs/developers_guide/index.html
# http://www.crai.archi.fr/rubylibrarydepot/ruby/offset.rb
# http://www.smustard.com/script/Offset
# http://www.sketchucation.com/forums/scf/

# G-Code
# http://en.wikipedia.org/wiki/G-code

# RC Group
# http://www.rcgroups.com/forums/showthread.php?t=888387   Introducing The Phlatprinter * Available for Purchase *
# http://www.rcgroups.com/forums/showthread.php?t=888387   Phlatprinter - PhlatCodeZ - Phlatprinter codes for you to cutout :)
# http://www.rcgroups.com/forums/showthread.php?t=925370   PHLATPRINTER BUILD THREAD – The Scratchbuilder’s New Best Friend!
# http://www.vimeo.com/user945475/videos   Michael Hancock's videos
# http://crash-hancock.blogspot.com/
# http://www.thecrashcast.com/
# http://www.rcflightcast.com/
# http://allthingsthatfly.com/

# Name Begins With Variable Scope 
# $  A global variable  
# @  An instance variable  
# [a-z] or _  A local variable  
# [A-Z]  A constant 
# @@ A class variable 

# - - - - - - - - - - - - - - - - -
#           Default Values
# - - - - - - - - - - - - - - - - -
$default_file_name = "gcode_out.cnc"
$default_directory_name = Dir.pwd + "/"
$default_material_thickness = 0.25.inch
$default_tab_width = 0.25.inch
$default_bit_diameter = 0.125.inch
$default_fold_depth_factor = 50
$default_tab_depth_factor = 50

$default_safe_origin_x = 0.0.inch
$default_safe_origin_y = 0.0.inch
$default_safe_width = 42.0.inch
$default_safe_height = 22.0.inch

# - - - - - - - - - - - - - - - - -
#           Cursor image files
# - - - - - - - - - - - - - - - - -
$cursor_directory = "Tools/Phlatboyz"
$cursor_tab_tool = "images/cursor_tabtool.png"
$cursor_inside_cuttool_filename = "images/cursor_cuttool_inside.png"
$cursor_outside_cuttool_filename = "images/cursor_cuttool_outside.png"
$cursor_fold_tool = "images/cursor_foldtool.png"
$cursor_safe_tool = "images/cursor_safetool.png"
$cursor_centerline_tool = "images/cursor_centerlinetool.png"


# - - - - - - - - - - - - - - - - -
#           Dictionary Keys
# - - - - - - - - - - - - - - - - -
$dict_name = "phlatboyzdictionary"
$dict_material_thickness = "material_thickness"
$dict_output_file_name = "output_file_name"
$dict_output_directory_name = "output_directory_name"
$dict_cut_depth_factor = "cut_depth_factor"
$dict_edge_type = "edge_type"
$dict_object_mark = "object_mark"
$dict_tab_width = "tab_width"
$dict_bit_diameter = "bit_diameter"
$dict_fold_depth_factor = "fold_depth_factor"
$dict_edge_count = "edge_count"
$dict_tab_depth_factor = "tab_depth_factor"

$dict_safe_origin_x = "safe_origin_x"
$dict_safe_origin_y = "safe_origin_y"
$dict_safe_width = "safe_width"
$dict_safe_height = "safe_height"

$dict_construction_mark = "construction_mark"

# - - - - - - - - - - - - - - - - -
#           Cut Keys
# - - - - - - - - - - - - - - - - -

$key_inside_cut = "inside_cut"
$key_outside_cut = "outside_cut"
$key_fold_cut = "fold_cut"
$key_tab_cut = "tab_cut"


# - - - - - - - - - - - - - - - - -
#           Parameters
# - - - - - - - - - - - - - - - - -
$construction_font_height = 0.6.inch
$min_z = -1.4
$max_z = 1.4

$cut_depth_factor_inside = 1.4
$cut_depth_factor_outside = 1.4
$cut_depth_factor_tab = 0.8

$tab_width = 0.125.inch
$fold_shorten_width = 0.0625.inch
$fold_depth_factor_array = [25, 50, 75, 100]

$reverse_loop_direction = false
$reflection_output = false

# http://download.sketchup.com/OnlineDoc/gsu6_ruby/Docs/ruby-color.html
$color_inside_cut = "DeepSkyBlue"
$color_outside_cut = "Orange"
$color_cut_drawing = "red"


$color_fold_cut = "Fuchsia"
$color_fold_wide_cut = "MediumVioletRed"
$color_tab_cut = "DarkMagenta"
$color_tab_drawing = "red"
$color_safe_drawing = "blue"
#$color_centerline_cut = "Aqua"
$color_centerline_cut = "DarkSeaGreen"

$rendering_edge_color_mode = 3

