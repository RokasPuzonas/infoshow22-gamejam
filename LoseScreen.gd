extends Node

onready var dialogSystem = get_tree().get_root().get_node("/root/DialogSystem")
var current_dialog

func _ready():
	dialogSystem.clear_messages()
	dialogSystem.show_message("Pathetic.", "The Game Master")

