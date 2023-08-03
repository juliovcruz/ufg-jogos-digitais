extends Node2D

@onready var timerNode = $Timer
@onready var scoreLabel = $ScoreLabel

var block_scene = preload("res://block.tscn")
var halfBlockSize = (Block.SIZE / 2)

var blocksAllowed = true

signal pauseTheGameSignal

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

var difficulty = 0

func _ready():
	pauseTheGameSignal.connect(get_node("Player").pausePlayer.bind())

func _process(delta):
	timer += delta
	if timer > timerNode.wait_time:
		timer = 0
		_on_timer_timeout()
	pass

# Quando o timer chega ao fim, instancia um novo bloco
func _on_timer_timeout():
	if !blocksAllowed:
		return
	
	var newBlock = block_scene.instantiate()
	var x_value = spawn_x[randi() % spawn_x.size()]
	newBlock.position = Vector2(x_value + 1, 0)
	add_child(newBlock)
	
	# Conecta o sinal de newBlock com a função scorePlus
	newBlock.plusScore.connect(scorePlus.bind())
	newBlock.gameOver.connect(gameOver.bind())

func scorePlus(point):
	score += point
	(scoreLabel as ScoreLabel).scorePlusInLabel(point)
	
	var TimerNode = get_node("Timer")
	
	if score > 10 && difficulty == 0:
		TimerNode.wait_time = 2.25
		difficulty = 1
	elif score > 20 && difficulty == 1:
		TimerNode.wait_time = 2
		difficulty = 2
	elif score > 30 && difficulty == 2:
		TimerNode.wait_time = 1.5
		difficulty = 3

func gameOver():	
	get_node("Button").set_visible(false)
	
	pauseTheGameSignal.emit()
	blocksAllowed = false
	var new_scene = load("res://game_over.tscn")
	var new_scene_instantiate = new_scene.instantiate()
	add_child(new_scene_instantiate)
	
	new_scene_instantiate.killGame.connect(killGame.bind())

func killGame():
	queue_free()

func pauseGame():
	pauseTheGameSignal.emit()
	blocksAllowed = !blocksAllowed
	
	get_node("Button").set_visible(false)
	
	var new_scene = load("res://game_pause.tscn")
	var new_scene_instantiate = new_scene.instantiate()
	add_child(new_scene_instantiate)
	
	new_scene_instantiate.unPauseGame.connect(unPauseGame.bind())

func _on_music_background_1_finished():
	get_node("MusicBackground1").play()

func unPauseGame():	
	pauseTheGameSignal.emit()
	blocksAllowed = !blocksAllowed
	get_node("Button").set_visible(true)

func _on_timer_tutorial_timeout():
	get_node("TouchScreenButtonLeft/Sprite2D").set_visible(false)
	get_node("TouchScreenButtonRight/Sprite2D").set_visible(false)
	get_node("TouchScreenButtonJump/Sprite2D").set_visible(false)
