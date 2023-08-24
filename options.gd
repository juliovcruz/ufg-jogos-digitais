extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	var y = Singleton.get_audio()
	if y == true:
		for node in get_tree().get_nodes_in_group("Audio"):
			node.set_volume_db(0)
	else:
		for node in get_tree().get_nodes_in_group("Audio"):
			node.set_volume_db(-100)
	preload("res://principal.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_option_button_item_selected(index):
	if index == 0:
		print(index)
		Singleton.set_nivel(1)
	elif index == 1:
		print(index)
		Singleton.set_nivel(3)
	elif  index == 2:
		print(index)
		Singleton.set_nivel(5)
	
	pass # Replace with function body.

func _on_back_pressed():
	get_tree().change_scene_to_file("res://principal.tscn")
	pass

func _on_check_button_toggled(button_pressed):
	if button_pressed == true:
		for node in get_tree().get_nodes_in_group("Audio"):
			node.set_volume_db(0)
		Singleton.set_audio(true)
	else:
		for node in get_tree().get_nodes_in_group("Audio"):
			node.set_volume_db(-100)
		Singleton.set_audio(false)


func _on_audio_stream_player_finished():
	get_node("AudioStreamPlayer").play()
	pass # Replace with function body.


func _on_play_pressed():
	get_tree().change_scene_to_file("res://game.tscn")
	pass # Replace with function body.
