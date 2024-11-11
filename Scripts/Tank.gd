tool
extends KinematicBody2D

onready var BULLET_TANK_GROUP = "bullet-" + str(self)

const ROT_VEL = PI / 2
const DEAD_ZONE = 0.02
const MAX_SPEED = 200
var pre_bullet = preload("res://Scripts/Scenes/bullet.tscn")
var pre_track = preload("res://Scripts/Scenes/track.tscn")
var pre_mg_bullet = preload("res://Scripts/Scenes/mg_bullet.tscn")
var acell = 0
var can_mouse_look = false
var travel = 0
var loaded = true

signal cannon_shooted
signal hmg_shooted


export(int, "bigRed", "blue", "dark", "darkLarge", "green", "huge", "red", "sand") var bodie = 2 setget set_bodie
export(int, "tankBlue", "tankDark", "tankGreen", "tankRed", "tankSand", "specialBarrel2", "specialBarrel7", "specialBarrel5")  var barrel = 5 setget set_barrel

var bodies = ["res://sprites/sprites/tankBody_bigRed.png",
"res://sprites/sprites/tankBody_blue.png",
"res://sprites/sprites/tankBody_dark.png",
"res://sprites/sprites/tankBody_darkLarge.png",
"res://sprites/sprites/tankBody_green.png",
"res://sprites/sprites/tankBody_huge.png",
"res://sprites/sprites/tankBody_red.png",
"res://sprites/sprites/tankBody_sand.png"
]

var barrels = [
"res://sprites/sprites/tankBlue_barrel1_outline.png",
"res://sprites/sprites/tankDark_barrel1_outline.png",
"res://sprites/sprites/tankGreen_barrel1_outline.png",
"res://sprites/sprites/tankRed_barrel1_outline.png",
"res://sprites/sprites/tankSand_barrel1_outline.png",
"res://sprites/sprites/specialBarrel2_outline.png",
"res://sprites/sprites/specialBarrel7_outline.png",
"res://sprites/sprites/specialBarrel5_outline.png"
]
func _ready():
	pass

func _draw():
	$Sprite.texture = load(bodies[bodie])
	$barrel/sprite.texture = load(barrels[barrel])
	

func _input(event):
	if event is InputEventMouseMotion:
		can_mouse_look = true
		

func _physics_process(delta):
	if Engine.editor_hint:
		return
	
	var vel_mod = 1
	
	if get_tree().get_nodes_in_group(str(self) + "-oil").size() > 0:
		vel_mod = .3
#	var dirx = 0
#	var diry = 0
#	if Input.is_action_pressed("ui_right"):
#		dirx +=1
#	if Input.is_action_pressed("ui_left"):
#		dirx -=1
#	if Input.is_action_pressed("ui_up"):
#		diry -=1
#	if Input.is_action_pressed("ui_down"):
#		diry +=1
#
#
	if Input.is_action_just_pressed("ui_shoot") and loaded:
#		if get_tree().get_nodes_in_group(BULLET_TANK_GROUP).size() < 3:
		var bullet = pre_bullet.instance()
		bullet.global_position = $barrel/muzle.global_position
		bullet.dir = Vector2(cos($barrel.global_rotation), sin($barrel.global_rotation)).normalized()
		bullet.add_to_group(BULLET_TANK_GROUP)
		bullet.max_dist = $barrel/sight.position.x - $barrel/muzle.position.x
		bullet.shooter = self
		get_parent().add_child(bullet)
		$barrel/anim.play("fire")
		loaded = false
		$barrel/sight.update()
		$barrel/Timer_reload.start()
		$barrel/barrel_anim.play("shoot")
		emit_signal("cannon_shooted")
	
	if Input.is_action_just_pressed("machinegun"):
		shoot_mg()
		$timer_mg.start()
	
	if Input.is_action_just_released("machinegun"):
		$timer_mg.stop()
#
#	look_at(get_global_mouse_position())
#
#	move_and_slide(Vector2(dirx, 0) * speed)
	var rot = 0
	var dir = 0
	
	
	
	if Input.is_action_pressed("ui_right"):
		rot += 1
		
	if Input.is_action_pressed("ui_left"):
		rot -= 1
		
		
	if rot == 0:
		rot = Input.get_joy_axis(0, JOY_AXIS_0)
	if Input.is_action_pressed("ui_up"):
		dir += 1
		
		
	if Input.is_action_pressed("ui_down"):
		dir -= 1
		
	if dir == 0:
		dir = -Input.get_joy_axis(0, JOY_AXIS_1)
		
		
	rotate(ROT_VEL * rot * delta)
#	if dir != 0:
	acell = lerp(acell, MAX_SPEED * dir, .03)
	
	var move = move_and_slide(Vector2(cos(rotation), sin(rotation)) * acell * vel_mod)
	travel += move.length() * delta
	
	if travel > $Sprite.texture.get_size().y:
		travel = 0
		var track = pre_track.instance()
		track.global_position = global_position - Vector2(cos(rotation), sin(rotation)).normalized() * 5
		track.rotation = rotation
		track.z_index = z_index -1
		$"../".add_child(track)
	
	var r_hor_axis = Input.get_joy_axis(0, JOY_AXIS_2)
	
	if abs(r_hor_axis) < DEAD_ZONE:
		r_hor_axis = 0
	
	var r_ver_axis = Input.get_joy_axis(0, JOY_AXIS_3)
	
	if abs(r_ver_axis) < DEAD_ZONE:
		r_ver_axis = 0
	
	if r_hor_axis != 0 or r_ver_axis != 0:
		var vector = Vector2(r_hor_axis, r_ver_axis)
		if vector.length() > .95:
			$barrel.global_rotation = vector.normalized().angle()
			can_mouse_look = false
		
	
	if can_mouse_look:
		$barrel.look_at(get_global_mouse_position())


func set_bodie(val):
	bodie = val
	if Engine.editor_hint:
		update()

func set_barrel(val):
	barrel = val
	if Engine.editor_hint:
		update()

func _on_Timer_reload_timeout():
	loaded = true
	$barrel/sight.update()

func shoot_mg():
	var mg = pre_mg_bullet.instance()
	mg.global_position = $mg_muzlle.global_position
	mg.global_rotation = global_rotation
	mg.dir = Vector2(cos(global_rotation), sin(global_rotation)).normalized()
	mg.shooter = self
	get_parent().add_child(mg)
	emit_signal("hmg_shooted")


func _on_timer_mg_timeout():
	shoot_mg()


func _on_damage_area_destroyd():
	queue_free()
