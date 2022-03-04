extends Control

export(int) var mutation_count = 3

var all_mutations = [
	load("res://Mutations/RangeMutation.tscn"),
	load("res://Mutations/StrengthMutation.tscn"),
	load("res://Mutations/VitalityMutation.tscn")
]

signal pick_mutation;

func _ready():
	visible = false;

func show_picker():
	visible = true;
	
	for i in range(mutation_count):
		var rand_index = randi() % all_mutations.size()
		var Mutation = all_mutations[rand_index]
		var mutation = Mutation.instance()
		mutation.get_node("BaseMutation").connect("apply_pressed", self, "selected_mutation")
		$MutationContainer.add_child(mutation);
	$MutationContainer.notification(Container.NOTIFICATION_SORT_CHILDREN);

func hide_picker():
	visible = false;
	
	for child in $MutationContainer.get_children():
		$MutationContainer.remove_child(child)

func selected_mutation(mutation):
	hide_picker()
	emit_signal("pick_mutation", mutation)
