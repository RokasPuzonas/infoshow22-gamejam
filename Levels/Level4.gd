extends "res://Levels/BaseLevel/BaseLevel.gd"

var started_ending = false

func _ready():
	force_stay_on_scene = true
	dialogSystem.show_message("You've finally come to see me face to face, huh?", "The Game Master?")
	dialogSystem.show_message("Well? Eldritch God got your tongue?", "The Game Master?")

func _process(delta):
	if current_turn == 1 && !started_ending:
		started_ending = true
		dialogSystem.show_message("I must agree, this was rather amusing, but you are starting to bore me.", "The Game Master?")
		$UI.visible = false
		$YouDied/AnimationPlayer.play("you-died")
		get_tree().get_root().get_node("/root/BackgroundMusic").stop()
		$YouDiedPlayer.play()
		var timer = get_tree().create_timer(10)
		timer.connect("timeout", self, "_on_AnimationPlayer_youdied_finished")
		
func _on_AnimationPlayer_youdied_finished():
	if started_ending:
		get_tree().get_root().get_node("/root/BackgroundMusic").play()
		transitionSystem.change_scene("res://UI/EndScreen.tscn")
