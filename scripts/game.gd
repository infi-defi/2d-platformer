extends Node2D

@onready var pause_menu: Control = $player/Camera2D2/PauseMenu
@onready var player: CharacterBody2D = $player

var paused = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pauseMenu()

func pauseMenu():
	if paused:
		player.pause = false
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		player.pause = true
		pause_menu.show()
		Engine.time_scale = 0
	paused = !paused
