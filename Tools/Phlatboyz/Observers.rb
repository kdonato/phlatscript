require 'sketchup.rb'

class AppChangeObserver < Sketchup::AppObserver
 	def onNewModel(model)
		set_model_options(model)
		model.add_observer(ModelChangeObserver.new)
	end
	def onOpenModel(model)
		set_model_options(model)
		model.add_observer(ModelChangeObserver.new)
		#UI.messagebox("onOpenModel() "+Sketchup.template.to_s)
	end
end

class ModelChangeObserver < Sketchup::ModelObserver
 	def onSaveModel(model)
		#UI.messagebox("onSaveModel()")
		set_model_options(model)
	end
end

