extends Node

@onready var score_label = $scoreLabel

var score = 0

func addPoint():
	score += 1
	score_label.text = "You made it! " + "You have collected \n" + str(score) + "/ 13 coins"
