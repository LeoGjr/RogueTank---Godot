extends RigidBody2D

export var bouncing = .3

func _ready():
	randomize()
	bounce = bouncing
	gravity_scale = 0
	linear_damp = 1
	angular_velocity = randf() * 10
	var dir = randf() * (PI * 2)
	apply_impulse(Vector2(), Vector2(cos(dir), sin(dir)) * 200)
	$poly.scale = get_parent().scale
	$poly2.scale = get_parent().scale
	connect("sleeping_state_changed", self, "on_self_sleeping_state_changed")
	
	
func on_self_sleeping_state_changed():
	if sleeping:
		var t = get_tree().create_timer(randf() * 4 + 2)
		yield(t, "timeout")
		
		var tween = Tween.new()
		add_child(tween)
		tween.interpolate_method(self, "fade", Color(1,1,1,1), Color(1,1,1,0), 2.0, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
		tween.start()
		yield(tween, "tween_completed")
		queue_free()
	
func fade(val):
	$poly.modulate = val
