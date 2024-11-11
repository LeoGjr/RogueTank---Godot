extends Camera2D

var intensity
var rot_ang = 0

func _ready():
	set_process(false)
	add_to_group("camera")
#	shake(10, 2)
	
func _process(delta):
	rot_ang += PI / 3
	offset = Vector2(sin(rot_ang), cos(rot_ang)) * intensity
	pass

func shake(intensity, duration):
	set_process(true)
	self.intensity = intensity
	get_tree().create_timer(duration).connect("timeout", self, "on_timeout")
	
func on_timeout():
	set_process(false)