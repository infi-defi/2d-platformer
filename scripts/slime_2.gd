extends CharacterBody2D

# Nodes and Constants
@onready var raycast_right = $"Raycast right"
@onready var raycast_left = $"Raycast left"
@onready var animated_sprite = $AnimatedSprite2D
@onready var timer = $timer

const SPEED = 60
const DAMAGE_TIME = 1.0  # Duration of the damaged state in seconds

# Variables
var damaged = false
var health = 2
var direction = 1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	apply_gravity(delta)
	check_wall_collisions()
	update_movement()
	move_and_slide()

# Applies gravity to the velocity.
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

# Checks for wall collisions and updates direction.
func check_wall_collisions():
	if raycast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	elif raycast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false

# Updates movement based on the damaged state.
func update_movement():
	if damaged:
		velocity.x = 0
	else:
		velocity.x = direction * SPEED

# Handles character damage.
func damage():
	if not damaged:  # Prevent multiple damage processing.
		damaged = true
		health -= 1
		play_damage_animation()
		timer.start()

# Plays the appropriate animation based on health.
func play_damage_animation():
	if health > 0:
		animated_sprite.play("hurt")
	else:
		animated_sprite.play("death")

# Called when the timer times out.
func _on_timer_timeout():
	if health > 0:
		animated_sprite.play("default")
		damaged = false
	else:
		queue_free()
