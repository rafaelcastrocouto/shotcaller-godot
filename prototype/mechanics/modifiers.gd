extends Node


# self = Behavior.modifiers


var extra_retreat_speed = 10

var retreat_regen = 10

@export var hp_per_level : float = 10
@export var regen_per_level : float = 2
@export var damage_per_level : float = 2.5
@export var defense_per_level : float = 2
@export var attack_speed_per_level : float = 0.05


func new_modifiers():
	return {
		"hp": [],
		"regen": [],
		"vision": [],
		"speed":[],
		"damage": [],
		"attack_range": [],
		"attack_speed": [],
		"defense": [],
		"dot": []
	}


func get_value(unit, mod_str):
	var default = unit[mod_str]

	match mod_str:
		"speed": default = get_velocity(unit)
		"regen": default = get_regen(unit)
		"attack_range": default = get_att_range(unit)
	for modifier in unit.current_modifiers[mod_str]:
		default += modifier.value
	
	var level_bonus = unit.level - 1
	match mod_str:
		"hp": level_bonus *= hp_per_level
		"regen": level_bonus *= regen_per_level
		"damage": level_bonus *= damage_per_level
		"defense": level_bonus *= defense_per_level
		"attack_speed": level_bonus *= attack_speed_per_level
		
	return default + level_bonus


func get_dot(unit):
	var dot_effects = []
	if not unit.current_modifiers["dot"].is_empty():
		for modifier in unit.current_modifiers["dot"]:
			dot_effects.append(modifier.value)
		return dot_effects
	else:
		return null


func get_velocity(unit):
	var default = unit.speed
	
	if unit.agent.get_state("hunting") and not unit.target.agent.get_state("is_retreating"):
		default = unit.hunting_speed
		
	if unit.agent.get_state("is_retreating"):
		var bonus = Behavior.skills.get_value(unit, "bonus_retreat_speed")
		default += extra_retreat_speed + bonus
	
	default += Behavior.orders.tactics_extra_speed[unit.tactics]
	
	return default


func get_regen(unit):
	var default = unit.regen
	if unit.agent.get_state("is_retreating"):
		default += retreat_regen
	return default


func get_att_range(unit):
	return unit.attack_hit_radius * unit.attack_range



func add(unit, mod_str, mod_name, value):
	unit.current_modifiers[mod_str].append({
		"name": mod_name,
		"value": value
	})


func remove(unit, mod_str, mod_name):
	for modifier in unit.current_modifiers[mod_str]:
		if modifier.name == mod_name:
			unit.current_modifiers[mod_str].erase(modifier)
