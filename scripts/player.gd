extends CharacterBody2D

@onready var cayote_timer = $cayoteTimer
@onready var animated_sprite = $AnimatedSprite2D
@onready var health_bar = $healthBar
@onready var marker = $Marker2D

const DEFAULT_SPEED = 130.0
const JUMP_VELOCITY = -250.0
const EXTRA_JUMPS = 1
const MAX_HEALTH = 3

# General vars
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var health = MAX_HEALTH
var dead = false
var speed = DEFAULT_SPEED
var jumps = EXTRA_JUMPS
var last_direction = 1
var on_sign = false

# Bow vars
var bow_equiped = true

func player():
	#yes im too bored to do classes deal with it<3
	pass

func _ready():
	health_bar.init_health(health)

func _physics_process(delta):
	if !is_on_floor():
		velocity.y += GRAVITY * delta

	handle_movement_and_jump()
	handle_animation()
	handle_attack()
	handle_move_and_slide()
	if health <= 0 and !dead:
		die()
	handle_dev_tools()

func handle_movement_and_jump():
	var direction = Input.get_axis("move_left", "move_right")
	if direction != 0:
		last_direction = direction
	
	velocity.x = direction * speed

	# Handle jump logic
	if Input.is_action_just_pressed("jump") and !dead and !on_sign:
		if is_on_floor() or !cayote_timer.is_stopped(): # Coyote jump allowed
			velocity.y = JUMP_VELOCITY
			cayote_timer.stop()  # Disable coyote jump once used
		elif jumps > 0: # Allow double jump
			velocity.y = JUMP_VELOCITY
			jumps -= 1

	# Reset jumps if player is on the floor
	if is_on_floor():
		jumps = EXTRA_JUMPS
		cayote_timer.stop()  # No need for coyote timing when on the floor


func handle_animation():
	# Handle animations based on the player's state
	if dead:
		update_animation("death")
	else:
		animated_sprite.flip_h = last_direction < 0
		var animation_name = "idle" if is_on_floor() and velocity.x == 0 else "run" if is_on_floor() else "jump"
		update_animation(animation_name)

func update_animation(animation_name):
	if animated_sprite.animation != animation_name:
		animated_sprite.play(animation_name)

func handle_attack():
	# Position and rotation of Marker2D based on last direction
	marker.position.x = 10 if last_direction > 0 else -10
	marker.rotation = deg_to_rad(0) if last_direction > 0 else deg_to_rad(180)

	if dead:
		marker.lastUsed(0)
		return

	# Prevent attacking while another action is in progress
	if marker.attacking:
		return
	
	# Handle attack inputs
	if Input.is_action_just_pressed("attack"):
		marker.attack()
		marker.lastUsed(1)
	elif Input.is_action_just_pressed("shoot") and bow_equiped:
		marker.shoot()
		marker.lastUsed(2)

func die():
	dead = true
	speed = 0
	velocity.x = 0
	Engine.time_scale = 0.5
	await get_tree().create_timer(1.1).timeout
	Engine.time_scale = 1
	get_tree().reload_current_scene()

func damage(amount):
	health -= amount
	health_bar.health = health

func heal(amount):
	health += amount
	health_bar.health = health

func handle_move_and_slide():
	# Move and handle coyote timer for jumping
	var was_on_floor = is_on_floor()
	move_and_slide()
	if was_on_floor and !is_on_floor():
		cayote_timer.start()

func handle_dev_tools():
	# Developer tool shortcuts
	if Input.is_action_just_pressed("reset"):
		Engine.time_scale = 1
		get_tree().reload_current_scene()
	elif Input.is_action_just_pressed("heal"):
		heal(MAX_HEALTH)
