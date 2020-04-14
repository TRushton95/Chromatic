extends PanelContainer

#Scenes
var entity_option_scene = preload("EntityOption.tscn")

#Fields
onready var container = get_node("VBoxContainer")


#Methods
func set_options(entity_options: Array):
	if !entity_options || entity_options.size() <= 0:
		print("No entity options")
	
	for entity_option in entity_options:
		if !entity_option:
			continue
		
		if !entity_option is Entity:
			print("Option is not an entity")
			continue
			
		var option = entity_option_scene.instance()
		option.set_text(entity_option.name)
		container.add_child(option)
