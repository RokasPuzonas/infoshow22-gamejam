extends Button


func _pressed():
	get_parent().get_parent().get_node("World").end_turn = true
