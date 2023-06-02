extends CharacterBody2D
class_name Block

@onready var rayCastRight = $RayCastRight
@onready var rayCastLeft = $RayCastLeft
@onready var rayCastTop = $RayCastTop
@onready var rayCastBottom = $RayCastBottom

@onready var player = get_node("res://player.gd")

signal plusScore

const SPEED = 200 # Velocidade do bloco
const SIZE = 128 # Tamanho do bloco
const HALF_SIZE = (Block.SIZE / 2) # Meta do bloco
const TIME_TO_EXPLODE = 0.3

# Possiveis spawns de X para os blocos
var spawn_x = [ 
	HALF_SIZE, 
	HALF_SIZE * 3,
	HALF_SIZE * 5, 
	HALF_SIZE * 7, 
	HALF_SIZE * 9, 
	HALF_SIZE * 11, 
	HALF_SIZE * 13, 
	HALF_SIZE * 15,
	HALF_SIZE * 17,
	HALF_SIZE * 19,
	]

# Variáveis auxiliares para movimentação
var can_push = true  # Indica se o bloco pode ser empurrado novamente
var pushed_one_time = false # Indica se o bloco já foi empurrado pelo menos uma vez
var last_direction_player # Indica a ultima direção que o player estava quando empurrou o bloco pela última vez
var maxX = 1280 # Indica o X máximo que o bloco deve alcançar após o "empurrão"
var minX = 0 # Indica o X mínimo que o bloco deve alcançar após o "empurrão"
var moveDelay = 3
var moveElapsed = 0


var blockTop: Block # Indica o bloco que está em cima
var blockBottom: Block # Indica o bloco que está em baixo
var blockRight: Block # Indica o bloco que está do lado direito
var blockLeft: Block # Indica o bloco que está do lado esquerdo
var color: int = 1 # Indica a cor do bloco

var exploding: bool = false # Indica se o bloco está explodindo

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var screen_size

func _ready():
	# Define a cor do bloco
	color = randi_range(0, 0)
	match color:
		0:
			$AnimatedSprite2D.play("red")
		1: 
			$AnimatedSprite2D.play("blue")
		2: 
			$AnimatedSprite2D.play("yellow")
		3: 
			$AnimatedSprite2D.play("green")

	screen_size = get_viewport_rect().size

func _process(delta):
	# Se o bloco estiver explodindo, ele não deve realizar nada
	if exploding:
		return
	
	# Lógica para explodir os blocos da direita e abaixo
	verifyBlocksRight(self)
	verifyBlocksBottom(self)
	
	# Verifica se algum bloco adjacente que seja da mesma cor
	# está explodindo, caso positivo, este bloco deve explodir também 
	if verifyIfNeedExplode():
		explode()
		return
	
	# Se o bloco chegar ao topo o jogador perde
	if is_on_floor() and position.y < HALF_SIZE:
		print("YOU LOSE")
		explode()
		return
		
	if pushed_one_time:
		# Se a velocidade do bloco estiver zero ele continua se movendo até chegar no max X
		if velocity.is_zero_approx():
			velocity.x += SPEED * last_direction_player
			move_and_slide()

		#position.x = clamp(position.x, minX, maxX)
		
		if position.x >= maxX -1:
			position.x = maxX
			can_push = true
			
		if position.x <= minX + 1:
			position.x = minX
			can_push = true
	
	# Lógica para o bloco conhecer os que seus adjacentes
	
	if rayCastBottom.is_colliding():
		if rayCastBottom.get_collider() is Block:
			var block = rayCastBottom.get_collider() as Block
			blockBottom = block
	else:
		blockBottom = null
		
	if rayCastRight.is_colliding():
		if rayCastRight.get_collider() is Block:
			var block = rayCastRight.get_collider() as Block
			blockRight = block
	else:
		blockRight = null
		
	if rayCastLeft.is_colliding():
		if rayCastLeft.get_collider() is Block:
			var block = rayCastLeft.get_collider() as Block
			blockLeft = block
	else:
		blockLeft = null
		
	if rayCastTop.is_colliding():
		if rayCastTop.get_collider() is Block:
			var block = rayCastTop.get_collider() as Block
			blockTop = block
	else:
		blockTop = null

func _physics_process(delta):	
	if exploding:
		return
	
	if pushed_one_time:
		position.x = clamp(position.x, minX, maxX)
	
	# Adicionando gravidade
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if !can_push:
		moveElapsed += delta
		if moveElapsed >= moveDelay:
			can_push = true
			position.x = getNextX(position.x, last_direction_player)
		
	# TODO: lógica para caso o bloco caia sobre outro bloco que já está se movimentando
	# o bloco deve finalizar o movimento, e em seguida o bloco que está caindo deve cair
	if rayCastBottom.is_colliding():
		if rayCastBottom.get_collider() is Block:
			var block = rayCastBottom.get_collider() as Block
			if !block.can_push:
				position.y -= 100
		
		# Se o bloco atingir a cabeça do jogador, ele perde
		if rayCastBottom.get_collider() is Player:
			print("YOU LOSE")

	move_and_slide()

# Direction: -1 = esquerda, 1 = direita
func push(direction, playerX, playerY):	
	if !can_push || !is_on_floor() || rayCastTop.is_colliding():
		return
		
	# TODO:
	# 1. Bug as vezes o bloco mesmo colidindo com o rayCast ele está deixando ser empurrado
	
	# Player está a cima do bloco
	if (position.y - playerY) > SIZE:
		return
	
	maxX = getNextX(position.x + SIZE/2 * direction, direction)
	
	# Empurrando para direita
	if direction == 1:
		if rayCastRight.is_colliding():
			return
		minX = position.x
	# Empurrando para esquerda
	else:
		if rayCastLeft.is_colliding():
			return
		minX = maxX
		maxX = position.x
	
	pushed_one_time = true
	can_push = false
	
	last_direction_player = direction
	velocity.x += SPEED * direction
	
	move_and_slide()

func getNextX(positionX, direction):
	if direction == 1:
		for i in len(spawn_x):
			if spawn_x[i] > positionX:
				return spawn_x[i]
	else:
		for i in [9,8,7,6,5,4,3,2,1,0]:
			if spawn_x[i] < positionX:
				return spawn_x[i]

func verifyBlocksRight(block: Block, count: int = 1) -> bool:
	if count == 3:
		block.explodeEquals()
		return true 

	if block.blockRight == null:
		return false
	
	if block.blockRight.color == color:
		return verifyBlocksRight(block.blockRight, count + 1) 
	else:
		return false
 
func verifyBlocksBottom(block: Block, count: int = 1) -> bool:
	if count == 3:
		block.explodeEquals()
		return true 
	
	if block.blockBottom == null:
		return false
	
	if block.blockBottom.color == color:
		return verifyBlocksBottom(block.blockBottom, count + 1) 
	else:
		return false
  

func explodeEquals():
	if blockTop != null && blockTop.color == color:
		blockTop.explode()
		
	if blockBottom != null && blockBottom.color == color:
		blockBottom.explode()
	
	if blockRight != null && blockRight.color == color:
		blockRight.explode()
	
	if blockLeft != null && blockLeft.color == color:
		blockLeft.explode()

func explode():
	if exploding:
		return
	exploding = true
	
	# Quando o bloco explode emite um sinal para aumentar a pontuação
	# O paramêtro é a quantidade de pontos
	plusScore.emit(2)
	
	await get_tree().create_timer(TIME_TO_EXPLODE).timeout

	queue_free()

func verifyIfNeedExplode():
	if !is_on_floor():
		return false
	
	if blockRight != null && blockRight.exploding && blockRight.color == color:
		return true
	
	if blockBottom != null && blockBottom.exploding && blockBottom.color == color:
		return true
	
	if blockTop != null && blockTop.exploding && blockTop.color == color:
		return true
	
	if blockLeft != null && blockLeft.exploding && blockLeft.color == color:
		return true
