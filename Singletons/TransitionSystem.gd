extends CanvasLayer

var queued_scene

func change_scene_to(target: PackedScene):
	if queued_scene == null:
		queued_scene = target
		$ColorRect/AnimationPlayer.play("Fade_in")
		$TransitionSound.play()

func change_scene(target: String):
	if queued_scene == null:
		queued_scene = target
		$ColorRect/AnimationPlayer.play("Fade_in")
		$TransitionSound.play()

func _on_AnimationPlayer_animation_finished(anim_name):
	if typeof(queued_scene) == TYPE_STRING:
		get_tree().change_scene(queued_scene)
		$ColorRect/AnimationPlayer.play("Fade_out")
		queued_scene = null
	elif queued_scene != null:
		get_tree().change_scene_to(queued_scene)
		$ColorRect/AnimationPlayer.play("Fade_out")
		queued_scene = null
