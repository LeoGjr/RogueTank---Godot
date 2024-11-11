extends CanvasLayer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	GAME.connect("score_changed", self, "on_score_changed")
	write_score()
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
func on_score_changed():
	write_score()
	
	
func write_score():
	$score.text = str(GAME.score)