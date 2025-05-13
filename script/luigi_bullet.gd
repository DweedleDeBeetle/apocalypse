extends Area3D

var speed : float = 125.0
var damage : int = 1
var time = 0.25
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var forward_dir = -global_transform.basis.z.normalized()
	global_translate(forward_dir * speed * delta)
	time -= delta
	if time <= 0:
		destroy()
	pass

func destroy():
	queue_free()


func _on_body_entered(body: Node3D) -> void:
	if "player" not in body.name:
		destroy()
	pass # Replace with function body.
