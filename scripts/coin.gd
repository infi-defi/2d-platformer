extends Area2D

@onready var game_manager = %"game manager"
@onready var animation_player = $AnimationPlayer

#Coin pickup func.
func _on_body_entered(body):
	if body.health < 3:
		body.health += 1
	game_manager.addPoint()
	animation_player.play("pickup")
	
