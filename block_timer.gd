extends Timer

var my_array = [100, 190, 280, 370, 460, 550, 640, 730, 820, 910, 1000, 1090, 1180, 1270]

var scene = preload("res://character_bock.tscn")

var timer = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta
	if timer > wait_time:
		timer = 0
		_on_timeout()
	pass

func _on_timeout():
	var newBlock = scene.instantiate()
	var x_value = my_array[randi() % my_array.size()]
	newBlock.position = Vector2(x_value, 0)
	# print(newBlock.get_instance_id())
	add_child(newBlock)	

