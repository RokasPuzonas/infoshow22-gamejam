extends Control

export(int) var mutation_count = 3
onready var tween_out = get_node("Tween")

signal picked_mutation

var all_mutations = [
	load("res://Mutations/RangeMutation.tscn"),
	load("res://Mutations/AttackMutation.tscn"),
	load("res://Mutations/HealthMutation.tscn"),
	load("res://Mutations/BetterRangeMutation.tscn"),
	load("res://Mutations/BetterAttackMutation.tscn"),
	load("res://Mutations/BetterHealthMutation.tscn")
]

func _ready():
	visible = false;

func show_picker():
	visible = true;
	$AudioStreamPlayer.play()
	$AudioStreamPlayer.volume_db = -40
	
	for child in $MutationContainer.get_children():
		child.queue_free()
	
	for i in range(mutation_count):
		var rand_index = randi() % all_mutations.size()
		var Mutation = all_mutations[rand_index]
		var mutation = Mutation.instance()
		mutation.connect("apply_pressed", self, "selected_mutation")
		$MutationContainer.add_child(mutation);
	$MutationContainer.notification(Container.NOTIFICATION_SORT_CHILDREN);

func hide_picker():
	visible = false;
	tween_out.interpolate_property($AudioStreamPlayer, "volume_db", -40, -80, 1.00, 1, Tween.EASE_IN, 0)
	tween_out.start()

func selected_mutation(mutation):
	emit_signal("picked_mutation", mutation)
	#get_node("../../World")._on_MutationPicker_pick_mutation(mutation)
	hide_picker()

func _on_Tween_tween_all_completed(object, key):
	object.stop()
