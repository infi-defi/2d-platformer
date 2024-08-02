extends Area2D

@onready var timer = $Timer


func _on_body_entered(body):
	if body.has_method("die") && !body.dead:
		print("You died")
		body.die()
		Engine.time_scale = 0.5
		timer.start()

func _on_timer_timeout():
	Engine.time_scale = 1
	get_tree().reload_current_scene()
