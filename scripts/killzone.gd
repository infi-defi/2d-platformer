extends Area2D

@onready var timer = $Timer

func _on_body_entered(body):
	if body.has_method("damage") and not body.dead:
		calculate_damage(body)
		if body.health <= 0:
			kill(body)

func calculate_damage(body):
	match get_grandparent_name():
		"slime":
			body.damage(1)
		"root":
			kill(body)

func kill(body):
	print("you died")
	body.die()
	Engine.time_scale = 0.5
	timer.start()

func _on_timer_timeout():
	Engine.time_scale = 1
	get_tree().reload_current_scene()

func get_grandparent_name() -> String:
	return get_parent().get_parent().name
