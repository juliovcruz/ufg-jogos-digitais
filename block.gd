extends CharacterBody2D
class_name Block

@onready var rayCastRight = $RayCastRight
@onready var rayCastLeft = $RayCastLeft
@onready var rayCastTop = $RayCastTop
@onready var rayCastBottom = $RayCastBottom

const SPEED = 100 # Velocidade do bloco
const SIZE = 128 # Tamanho do bloco
const HALF_SIZE = (Block.SIZE / 2) # Meta do bloco

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
var maxX = position.x # Indica o X máximo que o bloco deve alcançar após o "empurrão"
var minX = position.x # Indica o X mínimo que o bloco deve alcançar após o "empurrão"

var blockUp: Block # Indica o bloco que está em cima
var blockDown: Block # Indica o bloco que está em baixo
var blockRight: Block # Indica o bloco que está do lado direito
var blockLeft: Block # Indica o bloco que está do lado esquerdo
var color: int = 1 # Indica a cor do bloco

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var screen_size

func _ready():
	screen_size = get_viewport_rect().size

func _process(delta):
	# Se o bloco chegar ao topo o jogador perde
	if is_on_floor() and position.y < HALF_SIZE:
		print("YOU LOSE")
		free()
	
	if pushed_one_time:
		# Se a velocidade do bloco estiver zero ele continua se movendo até chegar no max X
		if velocity.is_zero_approx():
			velocity.x += SPEED * last_direction_player
			move_and_slide()

		position.x = clamp(position.x, minX, maxX)
		if position.x >= maxX || position.x <= minX:
			can_push = true

func _physics_process(delta):
	# Adicionando gravidade
	if not is_on_floor():
		velocity.y += gravity * delta
		
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
	#if position.x < maxX:	
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
			print(spawn_x[i])
			if spawn_x[i] < positionX:
				return spawn_x[i]
