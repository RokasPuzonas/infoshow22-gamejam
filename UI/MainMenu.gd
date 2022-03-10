extends Control

export(PackedScene) var starting_level

onready var dialogSystem = get_tree().get_root().get_node("/root/DialogSystem")
onready var transitionSystem = get_tree().get_root().get_node("/root/TransitionSystem")

func _ready():
	dialogSystem.clear_messages()
	
func _on_Quit_pressed():
	get_tree().quit()

func _on_Play_pressed():
	transitionSystem.change_scene_to(starting_level)
