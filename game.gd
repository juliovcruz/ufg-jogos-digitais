extends Node2D

@onready var timerNode = $Timer
@onready var scoreLabel = $ScoreLabel

var block_scene = preload("res://block.tscn")
var halfBlockSize = (Block.SIZE / 2)

var spawn_x = [
	halfBlockSize, 
	halfBlockSize * 3,
	halfBlockSize * 5, 
	halfBlockSize * 7, 
	halfBlockSize * 9, 
	halfBlockSize * 11, 
	halfBlockSize * 13, 
	halfBlockSize * 15,
	halfBlockSize * 17,
	halfBlockSize * 19,
	]
var count = 0
var timer = 0

var score = 0

func _process(delta):
	timer += delta
	if timer > timerNode.wait_time:
		timer = 0
		_on_timer_timeout()
	pass

# Quando o timer chega ao fim, instancia um novo bloco
func _on_timer_timeout():
	var newBlock = block_scene.instantiate()
	var x_value = spawn_x[randi() % spawn_x.size()]
	newBlock.position = Vector2(x_value + 1, 0)
	add_child(newBlock)
	
	# Conecta o sinal de newBlock com a função scorePlus
	newBlock.plusScore.connect(scorePlus.bind())

func scorePlus(point):
	(scoreLabel as ScoreLabel).scorePlusInLabel(point)
