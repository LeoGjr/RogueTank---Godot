extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	get_parent().connect("player_entered", self, "on_player_entered")

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
func get_target():
	if $sight.is_colliding():
		return $sight.get_collider()
		
		
func on_player_entered(n):
	if n:
		$sight.enabled = true