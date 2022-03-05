extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_World_phase_changed(phase):
	var turn_label = $"LevelUI/TurnLabel"
	
	if phase == TurnPhase.PHASE.PLAYER:
		turn_label.visible = true
		turn_label.text = "Your turn"
	elif phase == TurnPhase.PHASE.ENEMY:
		turn_label.visible = true
		turn_label.text = "Enemy turn"
	elif phase == TurnPhase.PHASE.COMBAT:
		turn_label.visible = true
		turn_label.text = "Combat phase"
	else:
		turn_label.visible = false
