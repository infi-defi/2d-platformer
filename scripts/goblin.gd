extends CharacterBody2D

@onready var see_right = $seeRight
@onready var see_left = $seeLeft
@onready var ground_check_right = $ground_check_right
@onready var ground_check_left = $ground_check_left
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var marker = $Marker2D
@onready var health_bar = $healthBar

const SPEED = 75

var health = 3
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = 1  # 1 means moving right, -1 means moving left
var player_detected = false
var damaged = false
var dead = false
var knockback = false
var attacking = false

func _ready():
	health_bar.init_health(health)

func _physics_process(delta):
	print(health)
	apply_gravity(delta)
	update_movement(delta)
	attack()
	update_animation()
	move_and_slide()

# Applies gravity to the velocity.
func apply_gravity(delta):
	if !is_on_floor():
		velocity.y += gravity * delta

# Detect player and move towards them, but stop at edges
func update_movement(delta):
	player_detected = false
	
	if damaged:
		if !knockback:
			velocity.x = -direction * SPEED /2
			await get_tree().create_timer(0.2).timeout
			knockback = true
		else:
			velocity.x = 0
		return
	
	# Detect the player
	if see_right.is_colliding():
		var collider = see_right.get_collider()
		if collider is CharacterBody2D:
			player_detected = true
			direction = 1  # Move right

	elif see_left.is_colliding():
		var collider = see_left.get_collider()
		if collider is CharacterBody2D:
			player_detected = true
			direction = -1  # Move left

	if player_detected:
		
		# Check if there's ground ahead
		var ground_ahead = false
		if direction == 1:
			# Moving right
			if ground_check_right.is_colliding():
				ground_ahead = true
		elif direction == -1:
			# Moving left
			if ground_check_left.is_colliding():
				ground_ahead = true

		if ground_ahead:
			# Move towards the player
			velocity.x = direction * SPEED
		else:
			# Stop moving to prevent falling off the edge
			velocity.x = 0
	else:
		# Patrol logic
		var ground_ahead = false
		if direction == 1:
			if ground_check_right.is_colliding():
				ground_ahead = true
		elif direction == -1:
			if ground_check_left.is_colliding():
				ground_ahead = true

		if ground_ahead:
			# Continue moving in the current direction
			velocity.x = direction * SPEED
		else:
			# No ground ahead, turn around
			direction *= -1  # Reverse direction
			velocity.x = direction * SPEED

func attack():
	# Position and rotation of Marker2D based on last direction
	marker.position.x = 10 if direction > 0 else -10
	marker.rotation = deg_to_rad(0) if direction > 0 else deg_to_rad(180)

	if dead:
		marker.lastUsed(0)
		return

	# Prevent attacking while another action is in progress
	if marker.attacking || attacking:
		return
	
	if player_detected:
		marker.shoot()
		marker.lastUsed(2)
		attacking = true
		await get_tree().create_timer(2).timeout
		attacking = false

func update_animation():
	if direction == 1:
		animated_sprite_2d.flip_h = false
	else: 
		animated_sprite_2d.flip_h = true
	
	if damaged:
		return
	
	if velocity.x != 0:
		change_animation("run")
	else:
		change_animation("idle")

func change_animation(animation_name):
	if animated_sprite_2d.animation != animation_name:
		animated_sprite_2d.play(animation_name)

# Handles character damage.
func damage(amount):
	if !damaged:
		damaged = true
		health -= amount
		health_bar.health = health
		knockback = false
		change_animation("damage")
		await get_tree().create_timer(0.5).timeout
		if health <= 0:
			dead = true
			change_animation("death")
			await get_tree().create_timer(1).timeout
			queue_free()
		damaged = false
