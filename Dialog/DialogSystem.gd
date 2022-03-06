extends CanvasLayer

export(float) var textSpeed = 0.05

var queued_messages: Array
var finished = false
var last_name = "???"

signal message_finished
 
func _ready():
	$Rect.visible = false
	queued_messages = []
	$Timer.wait_time = textSpeed
 
func _process(_delta):
	$Rect/Continue.visible = finished
	if Input.is_action_just_pressed("mouse_press_right"):
		if finished:
			show_next_message()
		else:
			$Rect/Text.visible_characters = len($Rect/Text.text)

func show_message(message, name):
	queued_messages.push_back([message, name])
	if !$Rect.visible:
		$Rect.visible = true
		show_next_message()
 
func clear_messages():
	queued_messages = []
	$Rect.visible = false
	$Timer.stop()

func show_next_message() -> void:
	if len(queued_messages) == 0:
		$Rect.visible = false
		return
	
	finished = false
	
	var entry = queued_messages.pop_front()
	var message = entry[0]
	var name = entry[1]
	if name == null:
		name = last_name
	last_name = name
	
	$Rect/Name.bbcode_text = name
	$Rect/Text.bbcode_text = message
	
	$Rect/Text.visible_characters = 0
	
	var last_talk = 0
	while $Rect/Text.visible_characters < len($Rect/Text.text):
		$Rect/Text.visible_characters += 1
		
		if randi() % 10 < 3 && last_talk > 0:
			$VoicePlayer.play()
			last_talk = 0
		else:
			last_talk += 1
		$Timer.start()
		yield($Timer, "timeout")
	
	finished = true
	emit_signal("message_finished")
	return
