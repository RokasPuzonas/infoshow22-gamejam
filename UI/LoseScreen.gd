extends Node

onready var dialogSystem = get_tree().get_root().get_node("/root/DialogSystem")
var current_dialog

func _ready():
	dialogSystem.clear_messages()
	dialogSystem.show_message("Pathetic.", "The Game Master")


func _on_Retry_pressed():
	get_tree().change_scene("res://Levels/Level1.tscn")


func _on_Quit_pressed():
	get_tree().quit()
