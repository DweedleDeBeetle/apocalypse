extends Control
var max_reload = 10
var max_unload = 10
var max_ammo = 8
var max_damage = 5
var max_artifacts = 3

var reload_cost = 10
var unload_cost = 10
var ammo_cost = 10
var damage_cost = 20
var artifact_cost = 50

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("exit") or Input.is_action_just_pressed("interact"):
		queue_free()
	$labels/scraps.text = "Scraps: "+str(Globals.scraps)
	#reload speed
	if Globals.reloads_up > 0:
		reload_cost = ((Globals.reloads_up+5)**3)
	else:
		reload_cost = 10
	$cost/reload.text = str(reload_cost)
	$labels/reload.text = "Reload Speed \n"+str(Globals.reload_speed)
	$bars/reload.value = Globals.reloads_up
	#unload speed
	if Globals.unloads_up > 0:
		unload_cost = (((Globals.unloads_up+2)*2)**3)
	else:
		unload_cost = 10
	$cost/unload.text = str(unload_cost)
	$labels/unload.text = "Firing Speed \n"+str(Globals.unload_speed)
	$bars/unload.value = Globals.unloads_up
	#ammo
	if Globals.ammos_up > 0:
		ammo_cost = ((Globals.ammos_up*3)**3)
	else:
		ammo_cost = 10
	$cost/ammo.text = str(ammo_cost)
	$labels/ammo.text = "Max Ammo\n"+str(Globals.ammo)
	$bars/ammo.value = Globals.ammos_up
	#damage
	if Globals.damages_up > 0:
		damage_cost = (((Globals.damages_up+1)*2)**4)
	else:
		damage_cost = 20
	$cost/damage.text = str(damage_cost)
	$labels/damage.text = "Damage\n"+str(Globals.damage)
	$bars/damage.value = Globals.damages_up
	#artifacts
	if Globals.artifacts_up == 0:
		artifact_cost = 1000
	elif Globals.artifacts_up == 1:
		artifact_cost = 10000
	else:
		artifact_cost = (50**(Globals.artifacts_up+1))
	$cost/artifacts.text = str(artifact_cost)
	$labels/artifacts.text = "Artifacts\n"+str(Globals.artifacts)
	$bars/artifacts.value = Globals.artifacts_up

func _on_reload_pressed() -> void:
	if max_reload > Globals.reloads_up and Globals.scraps >= reload_cost:
		Globals.reloads_up += 1
		Globals.scraps -= reload_cost
		Globals.reload_speed -= 0.15

func _on_unload_pressed() -> void:
	if max_unload > Globals.unloads_up and Globals.scraps >= unload_cost:
		Globals.unloads_up += 1
		Globals.scraps -= unload_cost
		Globals.unload_speed -= 0.05

func _on_ammo_pressed() -> void:
	if max_ammo > Globals.ammos_up and Globals.scraps >= ammo_cost:
		Globals.ammos_up += 1
		Globals.scraps -= ammo_cost
		Globals.ammo += Globals.ammos_up

func _on_damage_pressed() -> void:
	if max_damage > Globals.damages_up and Globals.scraps >= damage_cost:
		Globals.damages_up += 1
		Globals.scraps -= damage_cost
		Globals.damage += .5

func _on_artifacts_pressed() -> void:
	if max_artifacts > Globals.artifacts_up and Globals.scraps >= artifact_cost:
		Globals.artifacts_up += 1
		Globals.scraps -= artifact_cost
		Globals.artifacts += 1
