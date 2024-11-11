extends Area2D

var vel = 400
var dir = Vector2()
var damage = 1
var shooter 
onready var init_pos = self.global_position

func _physics_process(delta):
	translate(dir * vel * delta)
	if global_position.distance_to(init_pos) > 150:
		autodestroy()

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_mg_bullet_body_entered(body):
	autodestroy()
	
	
func _on_bullet_area_entered(area):
	if area.has_method("hit"):
		area.hit(damage, self)
		autodestroy()

func autodestroy():
	queue_free()