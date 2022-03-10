extends "res://Levels/BaseLevel/BaseLevel.gd"

var mutation_message_options = [
	"Oh, human, it is time for your wish once more! *laughs*",
	"Aren't they just beautiful?",
	"Doesn't this power just feel exquisite?"
]

func _on_mutation_enter():
	var message = mutation_message_options[randi() % len(mutation_message_options)]
	dialogSystem.show_message(message, "The Game Master")

