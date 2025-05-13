extends Node3D
var time = 10.0
func _process(delta):
	time -= delta
	if time <= 0:
		queue_free()
