extends Node

onready var Dialog = load("res://Dialog.tscn")
var current_dialog

func _ready():
	play_dialog("res://assets/Dialog/DialogDeath.json")

func play_dialog(path):
	
	current_dialog = Dialog.instance()
	current_dialog.dialogPath = path
	add_child(current_dialog)

