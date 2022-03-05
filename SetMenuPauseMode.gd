extends Control


func _ready():
	pause_mode =Node.PAUSE_MODE_PROCESS
	
	var music = load("res://BackgroundMusic.tscn").instance()
	get_tree().get_root().call_deferred("add_child", music)
