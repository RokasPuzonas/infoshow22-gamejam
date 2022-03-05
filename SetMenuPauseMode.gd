extends Control
export var play_anim = false
var fade
func _ready():
	play_anim = false
	fade = get_node("TextureRect").get_node("Fade").get_node("AnimationPlayer")
	pause_mode = Node.PAUSE_MODE_PROCESS
	
func _process(delta):
	if play_anim:
		fade.play("Fade_in")
		play_anim = false

func _on_AnimationPlayer_animation_finished(anim_name):
	get_tree().change_scene("res://Level1.tscn")
