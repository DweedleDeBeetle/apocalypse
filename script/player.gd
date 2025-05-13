extends CharacterBody3D

@onready var gunray = $Camera3D/RayCast3D as RayCast3D
@onready var interact_ray = $Camera3D/RayCast3D2 as RayCast3D
var bullet_hole = preload("res://scenes/bullet_hole.tscn")
var worktable_ui = preload("res://scenes/worktableGUI.tscn")

var SPEED = Globals.speed
const JUMP_VELOCITY = 4.5

var mouseSensibility = 250
var mouse_relative_x = 0
var mouse_relative_y = 0

var escaped = false

var luigi_bullet = preload("res://scenes/luigi_bullet.tscn")
var smoke = preload("res://scenes/gun_smoke.tscn")

var current_unload_time = Globals.unload_speed
var unload_time = 0

var reload_speed = Globals.reload_speed
var reload_time = 0
var is_reloading = false

var max_ammo = Globals.ammo
var ammo = max_ammo

var damage = Globals.damage

var in_ui = false

func _physics_process(delta: float) -> void:
	#update from globals
	max_ammo = Globals.ammo
	reload_speed = Globals.reload_speed
	current_unload_time = Globals.unload_speed
	damage = Globals.damage
	SPEED = Globals.speed
	#timer
	if unload_time > 0:
		unload_time -= delta
	#shooting
	gunray.add_exception(self)
	var scene_root = get_tree().root.get_children()[0]
	if Input.is_action_pressed("lmb") and escaped == false and unload_time <= 0 and reload_time <= 0 and ammo > 0:
		shoot()
		var smoke_instance = smoke.instantiate()
		scene_root.add_child(smoke_instance)
		smoke_instance.global_transform = $Camera3D/Vicki_smoke_point.global_transform
		$Camera3D.add_child(smoke_instance)
	#updates gui
	$"weapon_GUI/ammo count".text = "Ammo\n"+str(ammo)+' | '+str(max_ammo)
	# handles reload
	if Input.is_action_just_pressed("reload") and is_reloading == false and ammo != max_ammo:
		is_reloading = true
		reload_time = reload_speed
	if ammo <=0 and is_reloading == false:
		is_reloading = true
		reload_time = reload_speed
	if reload_time > 0:
		reload_time -= delta
	elif reload_time <= 0 and is_reloading == true:
		ammo = max_ammo
		is_reloading = false
	#Interactions
	if Input.is_action_just_pressed("interact") and escaped == false and interact_ray.is_colliding():
		if "worktable" in interact_ray.get_collider().name:
			worktable()
	elif Input.is_action_just_pressed("interact") and in_ui == true:
		in_ui = false
		escaped = false
		$"weapon_GUI/ammo count".visible = true
	#pause menu
	if Input.is_action_just_pressed("exit") and in_ui == false:
		escaped = true
	elif Input.is_action_just_pressed("exit") and in_ui == true:
		in_ui = false
		escaped = false
		$"weapon_GUI/ammo count".visible = true
	if escaped == true:
		if in_ui == false:
			$GUI.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		$GUI.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and escaped == false:
		velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("a", "d", "w", "s")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and escaped == false:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

func _input(event):
	if event is InputEventMouseMotion and escaped == false:
		rotation.y -= event.relative.x / mouseSensibility
		$Camera3D.rotation.x -= event.relative.y / mouseSensibility
		$Camera3D.rotation.x = clamp($Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)

func shoot():
	unload_time = current_unload_time
	ammo -= 1
	if not gunray.is_colliding():
		return
	var bulletInst = bullet_hole.instantiate()
	bulletInst.set_as_top_level(true)
	get_parent().add_child(bulletInst)
	bulletInst.global_transform.origin = gunray.get_collision_point() as Vector3
	bulletInst.look_at((gunray.get_collision_point()+gunray.get_collision_normal()),Vector3.BACK)

func worktable():
	var scene_root = get_tree().root.get_children()[0]
	var worktable_instance = worktable_ui.instantiate()
	scene_root.add_child(worktable_instance)
	in_ui = true
	escaped = true
	$"weapon_GUI/ammo count".visible = false

func _on_back_to_game_pressed() -> void:
	escaped = false
