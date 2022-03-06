extends Button
func _pressed():
	get_tree().paused = !get_tree().paused
	get_parent().visible = !get_parent().visible
