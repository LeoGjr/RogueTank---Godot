tool
extends StaticBody2D

var bodys = [] 
var rot_vel = PI * .5
const PRE_BULLET = preload("res://Scripts/Scenes/turret_bullet.tscn")
export(float, 0, 360)var start_rot = 0.0 setget set_start_rot
export(float, 100, 1000)var sensor_radius = 100 setget set_sensor_radius
var first_draw = true
export var life = 100
onready var init_life = life
var dead = false
onready var cannon = $cannon
onready var game = get_node("/root/GAME")
signal player_entered(n)
signal player_exited(n)
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	if Engine.editor_hint:
		return
	if bodys.size():
		var angle = cannon.get_angle_to(bodys[0].global_position)
		if abs(angle) > .1:
			cannon.rotation += rot_vel * delta * sign(angle)
		if cannon.get_target() != bodys[0]:
			var oldbody = bodys[0]
			var newBodyIndex = bodys.find($cannon/sight.get_collider())
			bodys[0] = $cannon/sight.get_collider()
			bodys[newBodyIndex] = oldbody

func _draw():
	if dead:
		return
	if first_draw:
		$cannon.rotation = deg2rad(start_rot)
		var new_shape = CircleShape2D.new()
		new_shape.radius = sensor_radius
		$sensor/shape.shape = new_shape
		$cannon/sight.cast_to = Vector2(sensor_radius, 0)
		if !Engine.editor_hint:
			first_draw = false
	if bodys.size():
		draw_circle(Vector2(), $sensor/shape.shape.radius, Color(1,0,0, .1))
	draw_circle_arc(Vector2(), $sensor/shape.shape.radius, 0, 360, Color(1,0,0, .5))
	

func _on_sensor_body_entered(body):
	if !bodys.size():
		$shooter_timer.start()
	bodys.append(body)
	emit_signal("player_entered", bodys.size())
	update()

func set_sensor_radius(val):
	sensor_radius = val
	if Engine.editor_hint:
		update()


func _on_sensor_body_exited(body):
	var index = bodys.find(body)
	if index >=0:
		bodys.remove(index)
	if !bodys.size():
		$cannon/sight.enabled = false
		$shooter_timer.stop()
	update()


func _on_shooter_timer_timeout():
	if $cannon/sight.is_colliding():
		shoot()

func shoot():
	$cannon_anim.play("shoot")
	$shoot.play()
	var bullet = PRE_BULLET.instance()
	bullet.global_position = global_position
	bullet.dir = Vector2(cos($cannon.rotation), sin($cannon.rotation))
	bullet.max_dist = sensor_radius
	get_parent().add_child(bullet)
	
	
func set_start_rot(val):
	start_rot = val
	if Engine.editor_hint:
		update()
		
func draw_circle_arc(center, radius, angle_from, angle_to, color):
	var mb_points = 32
	var points_arc = PoolVector2Array()
	
	for i in range(mb_points+1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / mb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
		
	for index_point in range(mb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color)

func _on_weak_spot_damage(damage, node):
	life -= damage
	$stream_hit.play()
	$hp_bar.scale = float(life) / float(init_life)
	if life <= 0:
		set_process(false)
		$cannon.queue_free()
		$sensor.disconnect("body_exited", self, "_on_sensor_body_exited")
		$sensor.queue_free()
		$shooter_timer.queue_free()
		$weak_spot.queue_free()
		$hp_bar.queue_free()
		dead = true
		update()
		$explosion/anim.play("explode")
		$explode.play()
		get_tree().call_group("camera", "shake", 5, 1)
		game.add_score(250)
		remove_from_group("radar_entry")
