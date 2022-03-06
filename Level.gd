extends Node

export(PackedScene) var next_scene

var fade
var count = 1
var anim_playing = false
# Called when the node enters the scene tree for the first time.
func _ready():
	
	count = 1
	anim_playing = false
	fade = get_node("LevelUI").get_node("Fade").get_node("AnimationPlayer")
	fade.play_backwards("Fade_in")


func _process(delta):
	print(name)
	var count = get_node("World").get_node("EnemyUnits").get_child_count()
	if count == 0 and not anim_playing:
		fade.play("Fade_in")
		anim_playing = true
	
		
	if anim_playing:
		if not fade.is_playing():
			get_tree().change_scene_to(next_scene)
	
	
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


func _on_AnimationPlayer_animation_finished(anim_name):
	if count == 0:
		get_tree().change_scene(next_scene)
