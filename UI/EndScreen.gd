extends ColorRect

func _ready():
	$Fade.visible = true
	$Fade/AnimationPlayer.play("Fade_out")
