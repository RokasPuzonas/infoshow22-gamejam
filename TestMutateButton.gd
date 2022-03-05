extends Button

func _ready():
	pass

func _pressed():
	visible = false
	$"../MutationPicker".show_picker()
