#-----------------------------------------------------------------------------
# Name        :   PhlatBoyzTools
# Description :   A set of tools for marking up Phlatland Sketchup drawings and generating Phlatprinter g-code.
# Menu Item   :   
# Context Menu:   
# Usage       :   
# Date        :   19 Jan 2009
# Type        :   
# Version     :   0.911
#-----------------------------------------------------------------------------

require 'sketchup.rb'
require 'LangHandler.rb'

class SketchupExtension
    attr_accessor :name, :description, :version, :creator, :copyright

    # REVIEW: Passing the description in as an argument to new makes it hard to use
    # very descriptive descriptions.
    def initialize(name, filePath)
        @name = name
        @description = description
        @path = filePath
        
        @version = "0.911"
        @creator = "Phlatboyz"
        @copyright = "01/19/2009, Phlatboyz"
    end

    def load
        require @path
    end
end

$phlatboyzStrings = LanguageHandler.new("PhlatBoyz.strings")

puts "parsed strings"

#Register the Phlatboyz Tools with SU's extension manager
meshToolsExtension = SketchupExtension.new $phlatboyzStrings.GetString("Phlatboyz Tools"), "Phlatboyz/PhlatboyzMenus.rb"

puts "Created extension"
 
meshToolsExtension.description=$phlatboyzStrings.GetString("PhlatboyzDescription")

puts "extension description" 

Sketchup.register_extension meshToolsExtension, false

puts "registered extension" 
$edge_count = 0


