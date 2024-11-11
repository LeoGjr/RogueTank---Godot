extends Node2D

func _ready():
	$timer_queue.wait_time = rand_range(8, 16)
	$timer_queue.start()

func _on_timer_queue_timeout():
	$anim.play("fade")
	yield($anim, "animation_finished")
	queue_free()
