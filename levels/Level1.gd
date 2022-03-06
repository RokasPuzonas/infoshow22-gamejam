extends "res://levels/Level.gd"

var mutation_count = 0

var mutation_message_options = [
	"Oh, human, it is time for your wish once more! *laughs*",
	"Aren't they just beautiful?",
	"Doesn't this power just feel exquisite?"
]

func _ready():
	dialogSystem.clear_messages()
	dialogSystem.show_message("Greetings, human. I am glad you agreed to participate in my little game.", "???")
	dialogSystem.show_message("Well, you might not have agreed, but you ignored all those warnings...", "???")
	dialogSystem.show_message("Anyway, the game is rather simple. I grant you an army of sorts, you use them to kill the townsfolk.", "???")
	dialogSystem.show_message("In case you do well, I may grant you wishes that will make your newly gained followers transform into perfection.", "???")

func _on_mutation_enter():
	if mutation_count == 0:
		dialogSystem.show_message("Time for your first wish. Choose carefully *laughs*", "???")
	elif mutation_count == 1:
		dialogSystem.show_message("I did not introduce myself, did I? You may call me the Game Master for the time being.", "The Game Master")
	else:
		var message = mutation_message_options[randi() % len(mutation_message_options)]
		dialogSystem.show_message(message, "The Game Master")
	mutation_count += 1
