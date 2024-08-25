extends CharacterBody2D

@onready var cayote_timer = $cayoteTimer
@onready var animated_sprite = $AnimatedSprite2D
@onready var cooldown_timer = $sword/Cooldown
@onready var sword_collision_shape = $sword/CollisionShape2D
@onready var health_bar = $healthBar

const DEFAULT_SPEED = 130.0
const JUMP_VELOCITY = -250.0
const EXTRA_JUMPS = 1
const MAX_HEALTH = 3

var health = MAX_HEALTH
var attacking = false
var dead = false
var speed = DEFAULT_SPEED
var jumps = EXTRA_JUMPS
var last_direction = 1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	health_bar.init_health(health)

func _physics_process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
	
	handle_movement_and_jump()
	handle_animation()
	handle_attack()
	die()
	handle_move_and_slide()
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
			print(get_parent().name)
			if area.get_parent().has_method("damage"):
				area.get_parent().damage()
		cooldown_timer.start()

func _on_cooldown_timeout():
	attacking = false

func die():
	if health <= 0:
		dead = true
		speed = 0
		velocity.x = 0

func damage(amount):
	health -= amount
	health_bar.health = health

func heal(amount):
	health += amount
	health_bar.health = health

func handle_move_and_slide():
	var was_on_floor = is_on_floor()
	move_and_slide()
	
	if was_on_floor && !is_on_floor():
		cayote_timer.start()

func handle_dev_tools():
	if Input.is_action_just_pressed("reset"):
		print("reload")
		Engine.time_scale = 1
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("heal"):
		health = MAX_HEALTH
		health_bar.health = health
