extends Node

var score = 0 setget set_score

signal score_changed

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func add_score(val):
	score += val
	emit_signal("score_changed")

func set_score(val):
	pass