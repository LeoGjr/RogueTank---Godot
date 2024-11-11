extends Area2D

var dir = Vector2() setget set_dir
var vel = 200
var max_dist = 300
onready var init_pos = global_position

func _ready():
#	self.dir = Vector2(1,1)
	pass

func _physics_process(delta):
	translate(dir * vel * delta)
	if global_position.distance_to(init_pos) > max_dist:
		queue_free()
		
		
func set_dir(val):
	dir = val
	rotation = val.angle()

func _on_turret_bullet_area_entered(area):
	if area.has_method("hit"):
		area.hit(5, self)
		queue_free()
