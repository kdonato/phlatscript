

def enter_set_parameters_dialog
	model = Sketchup.active_model
	current_thickness = model.get_attribute $dict_name, $dict_material_thickness, $default_material_thickness
	current_bit_diameter = model.get_attribute $dict_name, $dict_bit_diameter, $default_bit_diameter
	current_tab_width = model.get_attribute $dict_name, $dict_tab_width, $default_tab_width
	current_tab_depth = get_tab_depth_factor(model)
	
	safe_area_array = get_safe_array(model)

	prompts = [
		$phlatboyzStrings.GetString("Material Thickness"), 
		$phlatboyzStrings.GetString("Bit Diameter"),
		$phlatboyzStrings.GetString("Tab Width"),
		$phlatboyzStrings.GetString("Tab Depth Factor"), 
		$phlatboyzStrings.GetString("Safe x0"),
		$phlatboyzStrings.GetString("Safe y0"),
		$phlatboyzStrings.GetString("Safe width"),
		$phlatboyzStrings.GetString("Safe height"),
		]
	values = [
		current_thickness, 
		current_bit_diameter,
		current_tab_width, 
		current_tab_depth, 
		safe_area_array[0],
		safe_area_array[1],
		safe_area_array[2],
		safe_area_array[3],
		]
	results = UI.inputbox prompts, values, $phlatboyzStrings.GetString("Parameters")
	if(results)
		model.set_attribute $dict_name, $dict_material_thickness, results[0].to_f
		model.set_attribute $dict_name, $dict_bit_diameter, results[1].to_f
		model.set_attribute $dict_name, $dict_tab_width, results[2].to_f
		set_tab_depth_factor(results[3].to_i, model)
		
		set_safe_array(results[4].to_f, results[5].to_f, results[6].to_f, results[7].to_f, model)
		draw_safe_area(model)
	end
end

def enter_file_dialog(model=Sketchup.active_model)
	output_directory_name = model.get_attribute $dict_name, $dict_output_directory_name, $default_directory_name
	output_filename = get_model_filename_or_default(model)
	status = false
	result_array = validate_output_file(UI.savepanel($phlatboyzStrings.GetString("Save CNC File"), output_directory_name, output_filename))
	if(result_array != nil)
		model.set_attribute $dict_name, $dict_output_directory_name, result_array[0]
		model.set_attribute $dict_name, $dict_output_file_name, result_array[1]
		status = true
	end
	status
end

def enter_set_fold_depth_dialog
	model = Sketchup.active_model
	
	prompts = [$phlatboyzStrings.GetString("Depth Factor")]
	values = [get_fold_depth_factor()]
	results = UI.inputbox prompts, values, $phlatboyzStrings.GetString("Fold Parameters")
	if(results)
		set_fold_depth_factor(results[0].to_i)
		display_fold_depth_factor()
	end
	return results
end
