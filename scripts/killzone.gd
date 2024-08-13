extends Area2D

@onready var timer = $Timer


func _on_body_entered(body):
	if body.has_method("die") && !body.dead:
		body.die()
		print("hurt")
		if body.health == 0 || body.position.y > 149:
			print("you died")
			body.die()
			Engine.time_scale = 0.5
			timer.start()
		else:
			body.dead = false


func _on_timer_timeout():
	Engine.time_scale = 1
	get_tree().reload_current_scene()
