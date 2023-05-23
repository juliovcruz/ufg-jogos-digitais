extends CharacterBody2D

const SPEED = 500.0
const JUMP_VELOCITY = -600.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var screen_size

func _ready():
	screen_size = get_viewport_rect().size

func _process(delta):
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

func _physics_process(delta):
	#print(position.x)
	# Add the gravity.
	if not is_on_floor():
		#print(position.y)
		velocity.y += gravity * delta
		
	## Flip
	if Input.is_action_pressed("move_right"):
		$AnimatedSprite2D.flip_h = false
	elif Input.is_action_pressed("move_left"):
		$AnimatedSprite2D.flip_h = true

	# Handle Jump.
	if Input.is_action_just_pressed("move_up") and is_on_floor():
		$AnimatedSprite2D.play("jump")
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_pressed("move_right") and is_on_floor():
		$AnimatedSprite2D.play("move_right")
		
	elif Input.is_action_pressed("move_left") and is_on_floor():
		$AnimatedSprite2D.play("move_right")
	elif is_on_floor():
		$AnimatedSprite2D.play("idle")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		
		# print("Collided with: ", collision.get_collider().get_class())
		var ismovable = collision.get_collider() is RigidBody2D
		#print(ismovable)
		if ismovable:
			var movableBlock = collision.get_collider() as RigidBody2D
			movableBlock.apply_central_impulse(Vector2(30 * direction, 0))
			# movableBlock.apply_central_force(Vector2(10,0))
		var isCharacterBlock = collision.get_collider() is CharacterBlock
		if isCharacterBlock:
			var movableBlock = collision.get_collider() as CharacterBlock
			if movableBlock.blockDown != null:
				var character = movableBlock.blockDown as CharacterBody2D
				print(character.get_instance_id())
				
			movableBlock.moveX(direction, position.x, position.y)

	move_and_slide()


