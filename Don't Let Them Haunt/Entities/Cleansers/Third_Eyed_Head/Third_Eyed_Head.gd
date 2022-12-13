extends Node2D


onready var attack = load("res://Entities/Cleansers/Third_Eyed_Head/Third_Eyed_Head_Attack.tscn")
onready var visual_detection = $Detection/Visual_Detection


var souls = []
var not_ground = []
var attack_state = 0
var on_ground = false
var attack_instance
var ready_to_show = false


var state_spawn_attack = true
var state_attack = false
var state_delete_attack = false
var state_cooldown = false
var dragging = false


func _ready():
	if Input.is_action_pressed("left_click"):
		dragging = true
	hide()
	show()
	if not(get_parent().to_string().substr(0,9) == "Main_Menu"):
		get_parent().get_node("Spawn_Tower_Menu").set("spawning_tower" , null)


func _physics_process(delta):
	if not(on_ground):                                                     # If tower not placed
		position.x = get_global_mouse_position().x
		position.y = get_global_mouse_position().y
		if dragging and Input.is_action_just_released("left_click"):       # If dragged to drop
			if not_ground == []:
				place()
				check_to_attack(delta)
			else:
				queue_free()
		elif not(dragging) and Input.is_action_just_pressed("left_click"): # If clicked to drop                                   
			if not_ground == []:
				place()
				check_to_attack(delta)
			else:
				queue_free()
	else:
		check_to_attack(delta)


func _on_Detection_area_entered(area):
	if area.is_in_group("Soul"):
		souls.append(area)


func _on_Detection_area_exited(area):
	if area.is_in_group("Soul"):
		souls.erase(area)


func _on_Footprint_area_entered(area):
	if area.is_in_group("No_Build"):
		not_ground.append(area)
		
		if not(on_ground):
			visual_detection.modulate.g8 = 0


func _on_Footprint_area_exited(area):
	if area.is_in_group("No_Build"):
		not_ground.erase(area)
		
	if not_ground == [] and not(on_ground):
		visual_detection.modulate.g8 = 255


func place():
	on_ground = true
	visual_detection.hide()


func check_to_attack(delta):
	if state_spawn_attack and souls != []: # Ready to attack
		attack_state += 60*delta
		attack_instance = attack.instance()
		add_child(attack_instance)
		
		state_spawn_attack = false
		state_attack = true
		
	elif state_attack: # Attack animation
		attack_state += 60*delta
		attack_instance.scale.x += 0.35*60*delta
		attack_instance.scale.y += 0.35*60*delta
		
		if attack_state >= 25:
			state_attack = false
			state_delete_attack = true
		
	elif state_delete_attack:
		attack_state += 60*delta
		attack_instance.queue_free()
		
		state_delete_attack = false
		state_cooldown = true
			
	elif state_cooldown: # Attack cooldown
		
		if attack_state >= 35:
			attack_state = 0
			
			state_cooldown = false
			state_spawn_attack = true
		
		else:
			attack_state += 60*delta


func drag(bool_value):
	dragging = bool_value
