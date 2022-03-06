extends Control

signal pick_mutation;


# Called when the node enters the scene tree for the first time.
func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _process(delta):
	if Input.is_action_just_pressed("pause"):
			get_tree().paused = !get_tree().paused
			get_node("PauseMenu").visible = !get_node("PauseMenu").visible

func _on_MutationPicker_pick_mutation(mutation):
	emit_signal("pick_mutation", mutation)
