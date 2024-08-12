extends CharacterBody2D

@onready var cayoteTimer = $cayoteTimer
@onready var animated_sprite = $AnimatedSprite2D
@onready var cooldown = $sword/Cooldown
@onready var collision_shape_2d = $sword/CollisionShape2D



const DEFAULT_SPEED = 130.0
const JUMP_VELOCITY = -250.0
const EXTRA_JUMPS = 1

var attacking = false
var dead = false
var speed = DEFAULT_SPEED
var jumps = EXTRA_JUMPS
var last_direction = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Main function
func _physics_process(delta):
	# Add gravity if not on the floor.
	if !is_on_floor():
		velocity.y += gravity * delta
	
	# Handle movement and animation.
	movement()
	animation()
	attack()
	devTools()
	
	var was_on_floor = is_on_floor()
	move_and_slide()
	
	# Start cayote timer when leaving the floor.
	if was_on_floor && !is_on_floor():
		cayoteTimer.start()

func update_animation(animation_name: String):
	if animated_sprite.animation != animation_name:
		animated_sprite.play(animation_name)

func animation():
	var direction = Input.get_axis("move_left", "move_right")
	
	# Update the last direction based on input
	if direction != 0:
		last_direction = direction
	
	# Flip sprite based on last direction
	if !dead:
		if last_direction < 0:
			animated_sprite.flip_h = true
			collision_shape_2d.position.x = -16
		elif last_direction > 0:
			animated_sprite.flip_h = false
			collision_shape_2d.position.x = 16

	if dead:
		update_animation("death")
		return
	
	if attacking:
		update_animation("jump")
		return
	
	if is_on_floor():
		if direction == 0:
			update_animation("idle")
		else:
			update_animation("run")
	else:
		update_animation("jump")

func movement():
	jump()
	handle_horizontal_movement()

func jump():
	if Input.is_action_just_pressed("jump"):
		# Directly handle the jump logic here.
		if !dead && (is_on_floor() || !cayoteTimer.is_stopped() || jumps > 0):
			velocity.y = JUMP_VELOCITY
			jumps -= 1
		if is_on_floor():
			jumps = EXTRA_JUMPS

func handle_horizontal_movement():
	var direction = Input.get_axis("move_left", "move_right")
	if velocity.x != direction * speed:  # Optional check to avoid unnecessary updates
		velocity.x = direction * speed

func attack():
	var overalapping_objects = $sword.get_overlapping_areas()
	
	if Input.is_action_just_pressed("attack") &&  !dead && attacking == false:
		attacking = true
		for area in overalapping_objects:
			var parent = area.get_parent()
			# Check if the parent has the 'die' method
			if parent.has_method("damage"):
				parent.damage()
		cooldown.start()


func _on_cooldown_timeout():
	attacking = false

func die():
	dead = true
	speed = 0
	velocity.x = 0


func devTools():
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()


