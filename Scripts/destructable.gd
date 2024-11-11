extends Area2D

signal hitted(damage, health, node)
signal destroyd()
export var health = 30




func hit(damage, node):
	health -= damage
	emit_signal("hitted", damage, health, node)
	if health <= 0:
		emit_signal("destroyd")