extends CharacterBody2D

@onready var cayoteTimer = $cayoteTimer
@onready var animated_sprite = $AnimatedSprite2D

const DEFUALT_SPEED = 130.0
const JUMP_VELOCITY = -250.0
const extra_jumps = 1
var dead = false
var SPEED = DEFUALT_SPEED
var jumps = extra_jumps

#Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#Main function
func _physics_process(delta):
	
	#Add the gravity.
	if !is_on_floor():
		velocity.y += gravity * delta
	
	#Get input direction: -1,0,1
	var direction = Input.get_axis("move_left", "move_right")
	
	#Flip sprite
	if !dead:
		if direction > 0:
			animated_sprite.flip_h = false
		elif direction < 0:
			animated_sprite.flip_h = true
	
	#Play animations
	if dead:
		$AnimatedSprite2D.play("death")
	else:
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		else:
			animated_sprite.play("jump")
	
	
	#Handle jump.
	if Input.is_action_just_pressed("jump"):
		jump()
	
	#Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	
	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	#Cayote timer for jumps.
	if was_on_floor && !is_on_floor():
		cayoteTimer.start()
	

func jump():
	if !dead && (is_on_floor() || !cayoteTimer.is_stopped() || jumps != 0):
		velocity.y = JUMP_VELOCITY
		jumps += -1
	if is_on_floor():
		jumps = extra_jumps

func die():
	dead = true
	SPEED = 0
	velocity.x = 0
