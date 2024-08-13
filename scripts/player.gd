extends CharacterBody2D

@onready var cayote_timer = $cayoteTimer
@onready var animated_sprite = $AnimatedSprite2D
@onready var cooldown_timer = $sword/Cooldown
@onready var sword_collision_shape = $sword/CollisionShape2D
@onready var label = $Label

const DEFAULT_SPEED = 130.0
const JUMP_VELOCITY = -250.0
const EXTRA_JUMPS = 1

var health = 3
var attacking = false
var dead = false
var speed = DEFAULT_SPEED
var jumps = EXTRA_JUMPS
var last_direction = 1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
	
	
	handle_movement_and_jump()
	handle_animation()
	handle_attack()
	handle_move_and_slide()
	health_count()
	handle_dev_tools()
	

func handle_movement_and_jump():
	var direction = Input.get_axis("move_left", "move_right")
	last_direction = direction if direction != 0 else last_direction
	velocity.x = direction * speed

	if Input.is_action_just_pressed("jump") && !dead && (!cayote_timer.is_stopped() || jumps > 0):
		velocity.y = JUMP_VELOCITY
		jumps -= 1
	if is_on_floor():
		jumps = EXTRA_JUMPS

func handle_animation():
	if dead :
		update_animation("death")
	elif attacking:
		update_animation("attack")
	else:
		animated_sprite.flip_h = last_direction < 0
		sword_collision_shape.position.x = -10 if last_direction < 0 else 10
		update_animation("idle" if is_on_floor() && velocity.x == 0 else "run" if is_on_floor() else "jump")

func update_animation(animation_name: String):
	if animated_sprite.animation != animation_name:
		animated_sprite.play(animation_name)

func handle_attack():
	if Input.is_action_just_pressed("attack") && !dead && !attacking:
		attacking = true
		for area in $sword.get_overlapping_areas():
			if area.get_parent().has_method("damage"):
				area.get_parent().damage()
		cooldown_timer.start()

func _on_cooldown_timeout():
	attacking = false

func die():
	dead = true
	if health == 0:
		speed = 0
		velocity.x = 0
	else:
		health -= 1

func handle_move_and_slide():
	var was_on_floor = is_on_floor()
	move_and_slide()
	
	if was_on_floor && !is_on_floor():
		cayote_timer.start()

func health_count():
	label.text = str(health)

func handle_dev_tools():
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
