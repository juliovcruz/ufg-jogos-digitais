extends CharacterBody2D
class_name CharacterBlock

const SPEED = 300.0

var can_move = true  # Indica se o bloco pode se mover novamente
var move_cooldown = 1  # Tempo de cooldown entre os movimentos em segundos
var current_cooldown = 0  # Tempo decorrido desde o último movimento

var moving = false

var blockUp: CharacterBlock
var blockDown: CharacterBlock
var blockRight: CharacterBlock
var blockLeft: CharacterBlock
var color: int = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _process(delta):
	if !can_move:
		current_cooldown += delta
		
	# Verifique se o cooldown terminou
	if current_cooldown >= move_cooldown:
		print("liberou")
		current_cooldown = 0
		can_move = true

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var isCharacterBlock = collision.get_collider() is CharacterBlock
		if isCharacterBlock:
			var movableBlock = collision.get_collider() as CharacterBlock
			if movableBlock.position.y > position.y:
				blockDown = movableBlock
			elif movableBlock.position.y < position.y:
				blockUp = movableBlock
			elif movableBlock.position.x > position.x:
				blockRight = movableBlock
			else:
				blockLeft = movableBlock

	move_and_slide()

func moveX(direction, playerX, playerY):
	if can_move && playerY < position.y:
		# velocity.x += 35 * direction
		position.x += 90 * direction
		move_and_slide()
	
		
		can_move = false
		current_cooldown = 0
	
func sleep(sec):
	await get_tree().create_timer(1).timeout
