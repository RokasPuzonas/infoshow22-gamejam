extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_World_phase_changed(phase):
	if phase == TurnPhase.PHASE.PLAYER:
		$"LevelUI/TurnLabel".visible = true
		$"LevelUI/TurnLabel".text = "Your turn"
	elif phase == TurnPhase.PHASE.ENEMY:
		$"LevelUI/TurnLabel".visible = true
		$"LevelUI/TurnLabel".text = "Enemy turn"
	else:
		$"LevelUI/TurnLabel".visible = false
