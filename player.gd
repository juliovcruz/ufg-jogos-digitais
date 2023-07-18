extends CharacterBody2D
class_name Player

@onready var rayCastRight = $RayCastRight
@onready var rayCastLeft = $RayCastLeft

var SCORE = 1

const SPEED = 500.0
const JUMP_VELOCITY = -600.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var screen_size

var canMove = true

func _ready():
	screen_size = get_viewport_rect().size

func _process(delta):
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

func _physics_process(delta):
	# Gravidade
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if canMove:
		## Altera a direção dos sprites
		if Input.is_action_pressed("move_right") || Input.is_action_pressed("move_right_jump"):
			$AnimatedSprite2D.flip_h = false
		elif Input.is_action_pressed("move_left") || Input.is_action_pressed("move_left_jump"):
			$AnimatedSprite2D.flip_h = true
		
		# Sprites de acordo com a movimentação e pulo
		if (Input.is_action_just_pressed("move_up") || Input.is_action_pressed("move_left_jump") || Input.is_action_pressed("move_right_jump")) and is_on_floor():
			$AnimatedSprite2D.play("jump")
			velocity.y = JUMP_VELOCITY
		elif (Input.is_action_pressed("move_right") || Input.is_action_pressed("move_right_jump")) and is_on_floor():
			$AnimatedSprite2D.play("move")
			
		elif (Input.is_action_pressed("move_left") || Input.is_action_pressed("move_left_jump")) and is_on_floor():
			$AnimatedSprite2D.play("move")
		elif is_on_floor():
			$AnimatedSprite2D.play("idle")

		# Movimento para direita e esquerda
		var direction = Input.get_axis("move_left", "move_right")
		if Input.is_action_pressed("move_left_jump") || Input.is_action_pressed("move_right_jump"): 
			direction = Input.get_axis("move_left_jump", "move_right_jump")
		
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Lógica de colisão com os blocos
	if rayCastRight.is_colliding():
		if rayCastRight.get_collider() is Block:
			var block = rayCastRight.get_collider() as Block
			block.push(1, position.x, position.y)
	elif !velocity.is_zero_approx(): 
		# Resolve bug do player não conseguir andar por que está colidindo com o bloco da diagonal inferior
		position.y -= 0.2
	
	if rayCastLeft.is_colliding():
		if rayCastLeft.get_collider() is Block:
			var block = rayCastLeft.get_collider() as Block
			block.push(-1, position.x, position.y)
	elif !velocity.is_zero_approx(): 
		# Resolve bug do player não conseguir andar por que está colidindo com o bloco da diagonal inferior
		position.y -= 0.2

	move_and_slide()
	
func pausePlayer():
	canMove = !canMove
