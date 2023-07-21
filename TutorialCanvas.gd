extends CanvasLayer

var timer = 0
@onready var timerNode = $TimerTutorial

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta
	if timer > timerNode.wait_time:
		timer = 0
		_on_timer_timeout()
	pass

func _on_timer_timeout():
	queue_free()
