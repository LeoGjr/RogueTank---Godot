extends StaticBody2D

const PRE_FRAGMENTS = preload("res://Scripts/Scenes/fragments/box_fragments.tscn")
var last_hit_node
func _ready():
	$area_obstacle.connect("hitted", self, "on_area_hitted")
	$area_obstacle.connect("destroyd", self, "on_area_destroyd")



func on_area_hitted(damage, health, node):
	last_hit_node = node
	if damage > 5:
		$anim.play("big_hit")
	else:
		$anim.play("small_hit")

func on_area_destroyd():
	var fragments = PRE_FRAGMENTS.instance()
	fragments.global_position = global_position
	get_parent().add_child(fragments)
	GAME.add_score(50)
	queue_free()