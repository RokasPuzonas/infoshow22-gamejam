extends Node

onready var dialogSystem = get_tree().get_root().get_node("/root/DialogSystem")
onready var transitionSystem = get_tree().get_root().get_node("/root/TransitionSystem")

func _ready():
	dialogSystem.clear_messages()
	dialogSystem.show_message("Pathetic.", "The Game Master")

func _on_Retry_pressed():
	transitionSystem.change_scene("res://Levels/Level1.tscn")

func _on_Quit_pressed():
	get_tree().quit()
