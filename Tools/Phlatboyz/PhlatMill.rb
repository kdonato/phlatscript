require 'sketchup.rb'
require 'Phlatboyz/Constants.rb'


class PhlatMill

    def initialize(output_file_name=nil, min_max_array=nil)
		@cz = 0.0
		@cx = 0.0
		@cy = 0.0
		@cs = 0.0
		@cc = ""

		@max_x = 48.0
		@min_x = -48.0
		@max_y = 22.0
		@min_y = -22.0
		@max_z = 1.0
		@min_z = -1.0
		if(min_max_array != nil)
			@min_x = min_max_array[0]
			@max_x = min_max_array[1]
			@min_y = min_max_array[2]
			@max_y = min_max_array[3]
			@min_z = min_max_array[4]
			@max_z = min_max_array[5]
		end
		@no_move_count = 0

		@retract_depth = 0.05
		@mill_depth  = -0.35
		@speed_curr  = 500
		@speed_plung = 250
		
		@cmd_linear = "G1" # Linear interpolation
		@cmd_rapid = "G0" # Rapid positioning

		@output_file_name = output_file_name
		
		@mill_out_file = nil
	end
	
	def set_bit_diam(diameter)
		#@curr_bit.diam = diameter
	end
		
	def cncPrint(*args)
		if(@mill_out_file)
			args.each {|string| @mill_out_file.print string}
		else
			args.each {|string| print string}
			#print arg
		end

	end

	def job_start
		if(@output_file_name)
			done = false
			while !done do
				begin
					@mill_out_file = File.new(@output_file_name, "w+")
					done = true
				rescue
					button_pressed = UI.messagebox "Exception in PhlatMill.job_start "+$!, 5 #, RETRYCANCEL , "title"
					done = (button_pressed != 4) # 4 = RETRY ; 2 = CANCEL
					# TODO still need to handle the CANCEL case ie. return success or failure
				end
			end
		end
		cncPrint("%\n")
		cncPrint("G90\n") # G90 - Absolute programming (type B and C systems)
		cncPrint("G20\n") # G20 - Programming in inches
		cncPrint("G49\n") # G49 - Tool offset compensation cancel
		cncPrint("M3 S15000\n") # M3 - Spindle on (CW rotation)   S spindle speed
	end 

	def job_finish
		cncPrint("M05\n") # M05 - Spindle off
		cncPrint("G0 Z0\n") 
		cncPrint("M30\n") # M30 - End of program/rewind tape
		cncPrint("%\n")
		if(@mill_out_file)
			begin
				@mill_out_file.close()
				@mill_out_file = nil
				UI.messagebox("Output file stored: "+@output_file_name)
			rescue
				UI.messagebox "Exception in PhlatMill.job_finish "+$!
			end
		else
			UI.messagebox("Failed to store output file. (File may be opened by another application.)")
		end
	end 
  
	#def move(xo, yo=@cy, zo=@cz, so=@speed_curr, cmd=@cmd_linear)
	def move(xo, yo=@cy, zo=@cz, so=@speed_curr, cmd=@cmd_rapid) 
	    #print "( move xo=", xo, " yo=",yo,  " zo=", zo,  " so=", so, ")\n"
	    if (xo == @cx) && (yo == @cy) && (zo == @cz)
	       #print "(move - already positioned)\n"
	       @no_move_count += 1
	    else
			if (xo > @max_x)
				cncPrint "(move x=", sprintf("%8.3f",xo), " GT max of ", @max_x, ")\n"
				xo = @max_x
			elsif (xo < @min_x)
				cncPrint "(move x=", sprintf("%8.3f",xo), " LT min of ", @min_x, ")\n"
				xo = @min_x
			end

			if (yo > @max_y)
				cncPrint "(move y=", sprintf("%8.3f",yo), " GT max of ", @max_y, ")\n"
				yo = @max_y
			elsif (yo < @min_y)
				cncPrint "(move y=", sprintf("%8.3f",yo), " LT min of ", @min_y, ")\n"
				yo = @min_y
			end

			if (zo > @max_z)
				cncPrint "(move z=", sprintf("%8.3f",zo), " GT max of ", @max_z, ")\n"
				zo = @max_z
			elsif (zo < @min_z)
				cncPrint "(move x=", sprintf("%8.3f",zo), " LT min of ", @min_z, ")\n"
				zo = @min_z
			end
			
			command_out = ""
			command_out += cmd if (cmd != @cc)
			command_out += (sprintf(" X%8.3f", xo)) if (xo != @cx)
			command_out += (sprintf(" Y%8.3f", yo)) if (yo != @cy)
			command_out += (sprintf(" Z%8.3f", zo)) if (zo != @cz)
			command_out += (sprintf(" F%4i", so)) if (so != @cs)
			command_out += "\n"
			cncPrint command_out
			
			@cx = xo
			@cy = yo
			@cz = zo
			@cs = so
			@cc = cmd
		end
	end
     
	def retract(zo=@retract_depth, cmd=@cmd_rapid)
		if (zo == nil)
			zo = @retract_depth
		end
		if (@cz == zo)
			@no_move_count += 1
		else
			if (zo > @max_z)
				zo = @max_z
			elsif (zo < @min_z)
				zo = @min_z
			end

			command_out = ""
			command_out += cmd if (cmd != @cc)
			command_out += (sprintf(" Z%8.3f", zo)) if (zo != @cz)
			command_out += "\n"
			cncPrint command_out

			@cz = zo
			@cc = cmd
		end
	end


	def plung(zo=@mill_depth, so=@speed_plung, cmd=@cmd_linear)
		if (zo == @cz)
			@no_move_count += 1
		else
			if (zo > @max_z)
				zo = @max_z
			elsif (zo < @min_z)
				zo = @min_z
			end

			command_out = ""
			command_out += cmd if (cmd != @cc)
			command_out += (sprintf(" Z%8.3f", zo)) if (zo != @cz)
			command_out += (sprintf(" F%4i", so)) if (so != @cs)
			command_out += "\n"
			cncPrint command_out

			@cz = zo
			@cs = so
			@cc = cmd
		end
	end


	def home
		if (@cx == @retract_depth) && (@cy == 0) && (@cz == 0)
			@no_move_count += 1
		else
			retract
			cncPrint "G0 X0 Y0\n"
			@cx = 0
			@cy = 0
			@cz = 0
			@cs = 0
			@cc = ""
		end
	end
	
end