require 'sketchup.rb'

require 'Phlatboyz/Constants.rb'

require 'Phlatboyz/PhlatOffset.rb'

require 'Phlatboyz/Dialogs.rb'
require 'Phlatboyz/PhlatboyzMethods.rb'

require 'Phlatboyz/PhlatCncMill.rb'
require 'Phlatboyz/PhlatMill.rb'
require 'Phlatboyz/GcodeUtil.rb'

require 'Phlatboyz/EdgeUtil.rb'

require 'Phlatboyz/TabTool.rb'
require 'Phlatboyz/CutTool.rb'
require 'Phlatboyz/FoldTool.rb'
require 'Phlatboyz/CenterLineTool.rb'
require 'Phlatboyz/SafeTool.rb'

require 'Phlatboyz/EdgeHolder.rb'
require 'Phlatboyz/Observers.rb'

# Create the Command Toolbar
commandToolbar = UI::Toolbar.new($phlatboyzStrings.GetString("Phlatboyz"))

if not $phlatboyz_tools_submenu_loaded
    add_separator_to_menu("Tools")
    $phlatboyz_tools_submenu = UI.menu("Tools").add_submenu($phlatboyzStrings.GetString("Phlatboyz"))
    $phlatboyz_tools_submenu_loaded = true
end

if not $enter_paramters_loaded
	cmd = UI::Command.new($phlatboyzStrings.GetString("CutTool Inside")) { enter_set_parameters_dialog }
	cmd.large_icon = "images/parameters_large.png"
	cmd.small_icon = "images/parameters_small.png"
	cmd.tooltip = $phlatboyzStrings.GetString("Enter Phlatboyz Parameters")
	cmd.status_bar_text = $phlatboyzStrings.GetString("Enter Phlatboyz Parameters")
	cmd.menu_text = $phlatboyzStrings.GetString("Enter Parameters")
	$phlatboyz_tools_submenu.add_item(cmd)
	$phlatboyz_tools_submenu.add_separator
	commandToolbar.add_item(cmd)

	#$phlatboyz_tools_submenu.add_item($phlatboyzStrings.GetString("Enter Parameters")) { enter_set_parameters_dialog }
	$enter_paramters_loaded = true
end

if not $cuttool_inside_loaded
	cmd = UI::Command.new($phlatboyzStrings.GetString("CutTool Inside")) { Sketchup::active_model.select_tool CutTool.new(true) }
	cmd.large_icon = "images/cuttool_inside_large.png"
	cmd.small_icon = "images/cuttool_inside_small.png"
	cmd.tooltip = $phlatboyzStrings.GetString("Phlatboyz CutTool Inside")
	cmd.status_bar_text = $phlatboyzStrings.GetString("Phlatboyz CutTool Inside")
	cmd.menu_text = $phlatboyzStrings.GetString("CutTool Inside")
	$phlatboyz_tools_submenu.add_item(cmd)
	commandToolbar.add_item(cmd)
	$cuttool_inside_loaded = true
end

if not $cuttool_outside_loaded
	cmd = UI::Command.new($phlatboyzStrings.GetString("CutTool Outside")) { Sketchup::active_model.select_tool CutTool.new(false) }
	cmd.large_icon = "images/cuttool_outside_large.png"
	cmd.small_icon = "images/cuttool_outside_small.png"
	cmd.tooltip = $phlatboyzStrings.GetString("Phlatboyz CutTool Outside")
	cmd.status_bar_text = $phlatboyzStrings.GetString("Phlatboyz CutTool Outside")
	cmd.menu_text = $phlatboyzStrings.GetString("CutTool Outside")
	$phlatboyz_tools_submenu.add_item(cmd)
	commandToolbar.add_item(cmd)
	$cuttool_outside_loaded = true
end

if not $tabtool_loaded
	cmd = UI::Command.new($phlatboyzStrings.GetString("TabTool")) { Sketchup::active_model.select_tool TabTool.new }
	cmd.large_icon = "images/tabtool_large.png"
	cmd.small_icon = "images/tabtool_small.png"
	cmd.tooltip = $phlatboyzStrings.GetString("Phlatboyz TabTool")
	cmd.status_bar_text = $phlatboyzStrings.GetString("Phlatboyz TabTool")
	cmd.menu_text = $phlatboyzStrings.GetString("TabTool")
	$phlatboyz_tools_submenu.add_item(cmd)
	commandToolbar.add_item(cmd)
	$tabtool_loaded = true
end

if not $foldtool_loaded
	cmd = UI::Command.new($phlatboyzStrings.GetString("FoldTool")) { Sketchup::active_model.select_tool FoldTool.new }
	cmd.large_icon = "images/foldtool_large.png"
	cmd.small_icon = "images/foldtool_small.png"
	cmd.tooltip = $phlatboyzStrings.GetString("Phlatboyz FoldTool")
	cmd.status_bar_text = $phlatboyzStrings.GetString("Phlatboyz FoldTool")
	cmd.menu_text = $phlatboyzStrings.GetString("FoldTool")
	$phlatboyz_tools_submenu.add_item(cmd)
	commandToolbar.add_item(cmd)
	$foldtool_loaded = true
end

if not $centerlinetool_loaded
	cmd = UI::Command.new($phlatboyzStrings.GetString("CenterLineTool")) { Sketchup::active_model.select_tool CenterLineTool.new }
	cmd.large_icon = "images/centerlinetool_large.png"
	cmd.small_icon = "images/centerlinetool_small.png"
	cmd.tooltip = $phlatboyzStrings.GetString("Phlatboyz CenterLineTool")
	cmd.status_bar_text = $phlatboyzStrings.GetString("Phlatboyz CenterLineTool")
	cmd.menu_text = $phlatboyzStrings.GetString("CenterLineTool")
	$phlatboyz_tools_submenu.add_item(cmd)
	commandToolbar.add_item(cmd)
	$centerlinetool_loaded = true
end

if not $safetool_loaded
	cmd = UI::Command.new($phlatboyzStrings.GetString("SafeTool")) { Sketchup::active_model.select_tool SafeTool.new }
	cmd.large_icon = "images/safetool_large.png"
	cmd.small_icon = "images/safetool_small.png"
	cmd.tooltip = $phlatboyzStrings.GetString("Phlatboyz SafeTool")
	cmd.status_bar_text = $phlatboyzStrings.GetString("Phlatboyz SafeTool")
	cmd.menu_text = $phlatboyzStrings.GetString("SafeTool")
	$phlatboyz_tools_submenu.add_item(cmd)
	commandToolbar.add_item(cmd)
	$safetool_loaded = true
end

if not $generate_gcode_loaded
	cmd = UI::Command.new($phlatboyzStrings.GetString("TabTool")) { GcodeUtil.generate_gcode }
	cmd.large_icon = "images/gcode_large.png"
	cmd.small_icon = "images/gcode_small.png"
	cmd.tooltip = $phlatboyzStrings.GetString("Phlatboyz GCode")
	cmd.status_bar_text = $phlatboyzStrings.GetString("Phlatboyz GCode")
	cmd.menu_text = $phlatboyzStrings.GetString("GCode")
	$phlatboyz_tools_submenu.add_separator
	$phlatboyz_tools_submenu.add_item(cmd)
	commandToolbar.add_item(cmd)
	$generate_gcode_loaded = true
end

if not $phlatboyz_homepage_tool_loaded
	cmd = UI::Command.new($phlatboyzStrings.GetString("Phlatboyz Homepage")) { UI.openURL "http://phlatboyz.com" }
	cmd.large_icon = "images/phlatboyz_homepage_large.png"
	cmd.small_icon = "images/phlatboyz_homepage_small.png"
	cmd.tooltip = $phlatboyzStrings.GetString("Go To Phlatboyz Homepage")
	cmd.status_bar_text = $phlatboyzStrings.GetString("Go To Phlatboyz Homepage")
	cmd.menu_text = $phlatboyzStrings.GetString("Homepage")
	$phlatboyz_tools_submenu.add_separator
	$phlatboyz_tools_submenu.add_item(cmd)
	commandToolbar.add_item(cmd)
	$phlatboyz_homepage_tool_loaded = true
end

if not $help_tool_loaded
	cmd = UI::Command.new($phlatboyzStrings.GetString("PhlatScript Help")) { open_help_file() }
	cmd.large_icon = "images/help_large.png"
	cmd.small_icon = "images/help_small.png"
	cmd.tooltip = $phlatboyzStrings.GetString("Open PhlatScript Help")
	cmd.status_bar_text = $phlatboyzStrings.GetString("Open PhlatScript Help")
	cmd.menu_text = $phlatboyzStrings.GetString("Help")
	#$phlatboyz_tools_submenu.add_separator
	$phlatboyz_tools_submenu.add_item(cmd)
	commandToolbar.add_item(cmd)
	$help_tool_loaded = true
end

def add_edge_sub_menu(menu_to_add_to)
	edge_sub_menu = menu_to_add_to.add_submenu($phlatboyzStrings.GetString("Phlat Edge"))
	edge_sub_menu.add_item($phlatboyzStrings.GetString("Inside Edge")) { set_edges_inside }
	edge_sub_menu.add_item($phlatboyzStrings.GetString("Outside Edge")) { set_edges_outside }
	edge_sub_menu.add_item($phlatboyzStrings.GetString("Fold Edge")) { set_edges_fold }
	edge_sub_menu.add_item($phlatboyzStrings.GetString("Centerline Edge")) { set_edges_centerline }
	edge_sub_menu.add_separator
	edge_sub_menu.add_item($phlatboyzStrings.GetString("Clear Selected Edges")) { clear_selected_edges }
	edge_sub_menu.add_item($phlatboyzStrings.GetString("Clear All Edges")) { clear_all_edges }
	edge_sub_menu.add_item($phlatboyzStrings.GetString("Erase Phlatboyz Edges")) { erase_phlatboyz_edges }
	edge_sub_menu.add_item($phlatboyzStrings.GetString("Set Z=0 Selected Edges")) { set_z_zero_selected_faces_and_edges }
	edge_sub_menu.add_item("Test") {_test_order_edges}
end

def add_face_sub_menu(menu_to_add_to)
	face_sub_menu = menu_to_add_to.add_submenu($phlatboyzStrings.GetString("Face"))
	face_sub_menu.add_item($phlatboyzStrings.GetString("Set Z=0 Selected Edges")) { set_z_zero_selected_faces }
end

if not $context_menu_loaded
	UI.add_context_menu_handler do | menu |
		if(selected_edges().length > 0)
			menu.add_separator
			# Edge selected context menu
			add_edge_sub_menu(menu)
		end
		#if(selected_faces().length > 0)
		#	menu.add_separator
			# Face selected context menu
		#	add_face_sub_menu(menu)
		#end
	end
	$context_menu_loaded = true
end

if not $phlatboyz_initialized
	# Define items to be saved with the sketchup file
	model = Sketchup.active_model

	set_model_options(model)
	Sketchup.add_observer(AppChangeObserver.new)
	model.add_observer(ModelChangeObserver.new)
	#UI.messagebox("adding model observer")

	model.set_attribute $dict_name, $dict_material_thickness, $default_material_thickness
	model.set_attribute $dict_name, $dict_output_file_name, $default_file_name
	model.set_attribute $dict_name, $dict_tab_width, $default_tab_width
	set_tab_depth_factor($default_tab_depth_factor, model)
	#model.set_attribute $dict_name, $dict_tab_depth_factor, $default_tab_depth_factor
	model.set_attribute $dict_name, $dict_bit_diameter, $default_bit_diameter

	get_and_verify_directory()

	#draw_safe_area(model)
	$phlatboyz_initialized = true
end

