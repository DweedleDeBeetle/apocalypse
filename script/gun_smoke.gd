extends Node3D
var time = 0.5
var light_time = .02
func _ready():
	$GPUParticles3D.emitting = true
func _process(delta):
	time -= delta
	light_time -= delta
	if time <= 0:
		queue_free()
	if light_time <= 0:
		$OmniLight3D.visible = false
