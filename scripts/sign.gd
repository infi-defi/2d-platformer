extends Area2D

var player_near_sign = false

func _on_body_entered(body):
	player_near_sign = true
	body.on_sign = true 

func _on_body_exited(body):
	player_near_sign = false
	body.on_sign = false


func _process(delta):
	if player_near_sign and Input.is_action_just_pressed("jump"):
		Dialogic.start("sign")
