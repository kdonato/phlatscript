require 'sketchup.rb'
require 'Phlatboyz/Constants.rb'

require 'Phlatboyz/PhlatboyzMethods.rb'
require 'Phlatboyz/PhlatOffset.rb'

require 'Phlatboyz/PhlatCncMill.rb'
require 'Phlatboyz/PhlatMill.rb'

class GcodeUtil

	def GcodeUtil.generate_gcode
		model = Sketchup.active_model
		if enter_file_dialog(model)
			# first get the material thickness from the model dictionary
			material_thickness = Sketchup.active_model.get_attribute $dict_name, $dict_material_thickness, nil 
			if(material_thickness)

				output_directory_name = model.get_attribute $dict_name, $dict_output_directory_name, $default_directory_name
				
				output_file_name = model.get_attribute $dict_name, $dict_output_file_name, $default_file_name
				
				
				current_bit_diameter = model.get_attribute $dict_name, $dict_bit_diameter, $default_bit_diameter

				# TODO check for existing / on the end of output_directory_name
				absolute_File_name = output_directory_name + output_file_name
				
				safe_array = get_safe_array()
				min_x = 0.0
				min_y = 0.0
				max_x = safe_array[2]
				max_y = safe_array[3]

				min_max_array = [min_x, max_x, min_y, max_y, $min_z, $max_z]
				#aMill = CNCMill.new(nil, nil, absolute_File_name, min_max_array)
				aMill = PhlatMill.new(absolute_File_name, min_max_array)
				
				aMill.set_bit_diam(current_bit_diameter)
				
				#UI.messagebox("starting aMill absolute_File_name="+absolute_File_name)
				aMill.job_start()
				#UI.messagebox("aMill started")
			
				edges = Sketchup.active_model.active_entities.find_all { |e| e.kind_of?(Sketchup::Edge) }
				faces = Sketchup.active_model.active_entities.find_all { |e| e.kind_of?(Sketchup::Face) }
				groups = Sketchup.active_model.active_entities.find_all { |e| e.kind_of?(Sketchup::Group) }

				components = Sketchup.active_model.active_entities.find_all { |e| e.kind_of?(Sketchup::ComponentInstance) }

				# remove all marks (edges are marked as they are processed for milling)
				clear_edges_and_faces(edges, faces)
				clear_groups(groups)
				#clear_groups(components)

				
				mill_groups(aMill, material_thickness, groups)
				#mill_groups(aMill, material_thickness, components)
				mill_faces_and_edges(aMill, material_thickness, faces, edges)
				
				aMill.home()
				# retracts the milling head and
				# and then moves it home.  This
				# prevents accidental milling 
				# through your work piece when 
				# moving home.

				aMill.job_finish() # output housekeeping code
			else
				UI.messagebox($phlatboyzStrings.GetString("You must define the material thickness."))
			end
		end

	end
	
	private
	
	# mill groups
	def GcodeUtil.mill_groups(in_mill, in_thick, in_groups)
		model = Sketchup.active_model

		#UI.messagebox("groups:"+groups.size().to_s)
		in_groups.each do | group |
			# start operation to explode the group
			model.start_operation "Exploding Group"
			group_entities = group.explode
			group_edges = group_entities.find_all { |e| e.kind_of?(Sketchup::Edge) }
			group_faces = group_entities.find_all { |e| e.kind_of?(Sketchup::Face) }
			mill_faces_and_edges(in_mill, in_thick, group_faces, group_edges)
			# commit the operation
			model.commit_operation
			# undo the last transaction
			Sketchup.undo
		end
	end

	def GcodeUtil.mill_faces_and_edges(in_mill, in_thick, in_faces, in_edges)
		# collect all fold edges first
		millEdges(in_mill, _collect_and_mark_edges(in_edges, $key_fold_cut), in_thick)

		# collect all loops that have inside edges
		inside_loops = _collect_and_mark_loops_on_face(in_faces, $key_inside_cut, true)
		millEdges(in_mill, _collect_and_mark_edges_from_loops(inside_loops, [$key_inside_cut,$key_tab_cut]), in_thick)

		# collect all loops that have outside edges
		outside_loops = _collect_and_mark_loops_on_face(in_faces, $key_outside_cut)
		millEdges(in_mill, _collect_and_mark_edges_from_loops(outside_loops, [$key_outside_cut,$key_tab_cut]), in_thick)

		# get plunge areas
		millEdges(in_mill, _collect_and_mark_edges(in_edges, $key_plunge_cut), in_thick)

		# get any remaining free edges that were missed
		millEdges(in_mill, _collect_and_mark_edges(in_edges, $key_inside_cut), in_thick)
		millEdges(in_mill, _collect_and_mark_edges(in_edges, $key_tab_cut), in_thick)
		millEdges(in_mill, _collect_and_mark_edges(in_edges, $key_outside_cut), in_thick)
	end

	def GcodeUtil.clear_edges_and_faces(in_edges, in_faces)
		unmark_objects(in_edges)
		in_faces.each do | face |
			unmark_objects(face.loops)
		end
	end

	def GcodeUtil.clear_groups(in_groups)
		in_groups.each do | group |
			group_entities = group.entities
			group_edges = group_entities.find_all { |e| e.kind_of?(Sketchup::Edge) }
			group_faces = group_entities.find_all { |e| e.kind_of?(Sketchup::Face) }
			clear_edges_and_faces(group_edges, group_faces)
		end
	end


	# collect and mark (unmarked) edges of a certain type on a loop
	# deprecated
	def GcodeUtil._collect_and_mark_edges_on_face_loop(in_edge_type_array)
		edges_of_type = Array.new
		entities = Sketchup.active_model.active_entities
		entities.each do | entity |
			if(entity.kind_of?(Sketchup::Face))
				loops = entity.loops
				loops.each do | loop |
					face_edges = loop.edges
					face_edges.each do | edge |
						if( not is_object_marked(edge))
							if(not is_edge_in_safe_area(edge))
								mark_object(edge)
							else
								edge_type = edge.get_attribute $dict_name, $dict_edge_type
								is_type = false
								0.upto(in_edge_type_array.length-1) do |t|
									if not is_type
										is_type = (edge_type == in_edge_type_array[t])
									end
								end
								if(is_type)
									edges_of_type << edge
									mark_object(edge)
									# TODO TEST
									#_clear_edge(edge)
									#UI.messagebox(edge_type+" "+edge.to_s+" "+edges_of_type.size.to_s)
								end
							end
						end
					end
				end
			end
		end
		return edges_of_type
	end

	# returns an array of loops that contain edges of this type
	def GcodeUtil._collect_and_mark_loops_on_face(in_faces, in_edge_type, in_accept_only_non_outer_loops=false)
		loops_of_type = Array.new
		in_faces.each do | face |
			loops = face.loops
			#UI.messagebox "loops.length="+loops.length.to_s
			loops.each do | loop |
				# test returning only loops with loop.outer? = false when looking for inner_cut loops
				if( not is_object_marked(loop))
					#UI.messagebox("loop is not marked "+loop.to_s+"   testing for type:"+in_edge_type+"  outer:"+loop.outer?.to_s)
					if(_test_loop(loop, in_edge_type, in_accept_only_non_outer_loops))
						#UI.messagebox("   marking loop "+loop.to_s)
						loops_of_type << loop
						mark_object(loop)
					end
				end
			end
		end
		return loops_of_type
	end

	# Test the loop for edges of the correct type
	def GcodeUtil._test_loop(loop, in_edge_type, in_accept_only_non_outer_loops=false)
		result = false
		if( (not in_accept_only_non_outer_loops) or (in_accept_only_non_outer_loops && (not loop.outer?)))
			loop_edges = loop.edges
			loop_edges.each do | edge |
				if not result
					#UI.messagebox(edge)
					edge_type = edge.get_attribute $dict_name, $dict_edge_type, ""
					#UI.messagebox(edge.to_s+" type="+edge_type)
					if edge_type == in_edge_type
						result = true
					end
				end
			end
		end
		#UI.messagebox(result)
		return result
	end

	def GcodeUtil._collect_and_mark_edges_from_loops(loops, in_edge_type_array)
		edges_of_type = Array.new
		loops.each do | loop |
			edgeuses = $reverse_loop_direction ? loop.edgeuses.reverse : loop.edgeuses
			edgeuses.each do | edgeuse |
				#UI.messagebox edgeuse.to_s+" "+edgeuse.reversed?.to_s
				edge = edgeuse.edge
				if( not is_object_marked(edge))
					mark_object(edge)
					if(is_edge_in_safe_area(edge))
						edge_type = edge.get_attribute $dict_name, $dict_edge_type, ""
						is_type = false
						0.upto(in_edge_type_array.length-1) do | t |
							if not is_type
								is_type = (edge_type == in_edge_type_array[t])
							end
						end
						if(is_type)
							rev = $reverse_loop_direction ^ edgeuse.reversed?
							edges_of_type << EdgeHolder.new(edge, rev)
							# TODO TEST - don't mark object (output all loops)
							
							# TODO TEST
							#_clear_edge(edge)
							#UI.messagebox(edge_type+" "+edge.to_s+" "+edges_of_type.size.to_s)
						end
					end
				end
			end
		end
		return edges_of_type
	end


	# collect and mark (unmarked) edges of a certain type on a loop
	def GcodeUtil._collect_and_mark_edges(in_edges, in_edge_type)
		edges_of_type = Array.new

		in_edges.each do | edge |
			if( not is_object_marked(edge))
				edgeType = edge.get_attribute $dict_name, $dict_edge_type
				if(not is_edge_in_safe_area(edge))
					mark_object(edge)
				elsif(edgeType == in_edge_type)
					edges_of_type << EdgeHolder.new(edge)
					mark_object(edge)
					# TODO TEST
					#_clear_edge(edge)
					#UI.messagebox(edgeType+" "+edge.to_s)
				end
			end
		end
		return edges_of_type
	end
		
	def GcodeUtil.mark_object(in_object)
		in_object.set_attribute $dict_name, $dict_object_mark, true
	end

	def GcodeUtil.unmark_object(in_object)
		in_object.set_attribute $dict_name, $dict_object_mark, false
	end

	def GcodeUtil.unmark_objects(in_objects)
		in_objects.each do | object |
			#UI.messagebox("unmarking "+object.to_s)
			unmark_object(object)
		end
	end

	def GcodeUtil.is_object_marked(in_object)
		value = in_object.get_attribute $dict_name, $dict_object_mark
		if(value != nil)
			return value
		else
			return false
		end
	end
	
	def GcodeUtil.millEdges(aMill, edges, material_thickness)
		if not edges.empty?
			begin
				mirror = get_safe_reflection_translation()
				trans = get_safe_origin_translation()
				trans = trans * mirror if $reflection_output
			
				x_save = nil
				y_save = nil
				cut_depth_save = nil
				aMill.retract()
				
				# See if there is any sorting to be done on the edges
				edgeMap = Hash.new
				edges.each do | wrapped_edge |
					edge_count = wrapped_edge.edge.get_attribute $dict_name, $dict_edge_count
					if edge_count != nil
						edgeMap.store(edge_count, wrapped_edge)
					end
				end
				# Assume that if there are any edges in the map, then all the edges (for this call) are in the map
				if not edgeMap.empty?
					edges.clear # empty out edges
					pairArray = edgeMap.sort # sort the array
					pairArray.each{ | pair | edges << pair[1] } # fill edges with results of sort
				end
				
				save_point = nil
				edges.each do | wrapped_edge |
					save_point = millFlatEdge(aMill, wrapped_edge, trans, save_point, material_thickness)
				end
			rescue
				UI.messagebox "Exception in millEdges "+$!
			end
		end
	end

	def GcodeUtil.millFlatEdge(aMill, in_wrapped_edge, in_trans, in_save_point, in_material_thickness)
		returnPoint = nil
		begin
			if in_save_point == nil
				x_save = nil
				y_save = nil
				cut_depth_save = nil
			else
				x_save = in_save_point.x
				y_save = in_save_point.y
				cut_depth_save = in_save_point.z
			end

			#factor = in_wrapped_edge.edge.get_attribute $dict_name, $dict_cut_depth_factor, 0.0 
			factor = in_wrapped_edge.getFactor()

			edgeType = in_wrapped_edge.edge.get_attribute $dict_name, $dict_edge_type
			if edgeType == $key_plunge_cut
				point = in_wrapped_edge.startPosition(in_trans)
				aMill.retract()
				###cut_depth = in_material_thickness
				factor = in_wrapped_edge.getFactor()
				point = in_wrapped_edge.startPosition(in_trans)
			
				cut_depth = -1.0 * in_material_thickness * factor

				aMill.plunge(point.x, point.y, cut_depth)
			else
				factor = in_wrapped_edge.getFactor()
				point = in_wrapped_edge.startPosition(in_trans)
				
				cut_depth = -1.0 * in_material_thickness * factor 
				#UI.messagebox(cut_depth)

				if x_save != point.x || y_save != point.y
					aMill.retract()
					aMill.move(point.x, point.y)
					aMill.plung(cut_depth)
				elsif cut_depth_save != cut_depth
					if cut_depth > cut_depth_save
						aMill.retract(cut_depth)   # I added if statement
					end 
					aMill.plung(cut_depth)
				end
			
				point = in_wrapped_edge.endPosition(in_trans)
				aMill.move(point.x,point.y)
			end

			returnPoint = Geom::Point3d.new(point.x, point.y, cut_depth)
		rescue
			UI.messagebox "Exception in millFlatEdge "+$!
		end
		return returnPoint
	end



end
