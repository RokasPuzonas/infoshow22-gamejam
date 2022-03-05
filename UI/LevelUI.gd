extends Control

signal pick_mutation;


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_MutationPicker_pick_mutation(mutation):
	emit_signal("pick_mutation", mutation)
