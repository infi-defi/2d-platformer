extends Marker2D

@onready var bow = $bow
@onready var sword_sprite = $sword/swordSprite
@onready var sword = $sword
@onready var sword_collision_shape = $sword/CollisionShape2D

var arrow = preload("res://scenes/arrow.tscn")
var attacking = false
var action_state = 0 # 0 = idle, 1 = sword, 2 = bow

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match action_state:
		0:
			# Both idle
			bow.play("off")
			sword_sprite.play("off")
		1:
			# Sword active, bow idle
			bow.play("off")
			if !attacking:
				sword_sprite.play("idle")
		2:
			# Bow active, sword idle
			sword_sprite.play("off")
			if !attacking:
				bow.play("idle")
	
	# Sync position/rotation of weapons with player
	bow.global_position = global_position
	bow.global_rotation = global_rotation
	sword_collision_shape.position.x = 22 if deg_to_rad(global_rotation) > -1 else -22
	if !attacking:
		sword_sprite.global_rotation = 0
		sword_sprite.global_position = global_position

func shoot():
	if attacking:
		return # Prevent shooting if currently attacking with the sword
	
	attacking = true
	action_state = 2 # Set state to bow action
	bow.play("shoot")

	await get_tree().create_timer(0.7).timeout

	# Create and fire the arrow
	var arrow_instance = arrow.instantiate()
	arrow_instance.rotation = global_rotation
	arrow_instance.global_position = global_position
	add_child(arrow_instance)

	attacking = false
	action_state = 0 # Return to idle state

func attack():
	if attacking:
		return # Prevent attacking if currently shooting the bow
	
	attacking = true
	action_state = 1 # Set state to sword action

	# Set sword rotation and position
	sword_sprite.global_rotation = deg_to_rad(90) if rad_to_deg(global_rotation) == 0 else deg_to_rad(270)
	sword_sprite.global_position.x = global_position.x + 12 if position.x > 0 else global_position.x - 12
	
	# Play attack animation
	sword_sprite.play("attack")
	
	# Deal damage to any overlapping areas
	for area in sword.get_overlapping_areas():
		if area.get_parent().has_method("damage"):
			area.get_parent().damage(1)

	await get_tree().create_timer(0.25).timeout

	attacking = false
	action_state = 0 # Return to idle state

func lastUsed(x):
	action_state = x
