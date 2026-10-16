extends "res://goap/goap_system/action_contract.gd"

var player_lane_priorities := {}
var enemy_lane_priorities := {}
var player_leader_priorities := {}
var enemy_leader_priorities := {}


func get_class_name() -> String:
	return "ChooseTarget"


func is_valid(_agent) -> bool:
	return false


func closest_enemy_unit(unit, enemies):
	var filtered = []
	for enemy in enemies:
		if can_hit(unit, enemy):
			filtered.append(enemy)
	var sorted = unit.sort_by_distance(filtered)
	if sorted:
		return sorted[0].unit


func select_target(unit, enemies):
	var filtered = []
	for enemy in enemies:
		if can_hit(unit, enemy):
			filtered.append(enemy)
	if filtered.is_empty():
		return null
	if filtered.size() == 1:
		return filtered[0]
	var sorted = unit.sort_by_distance(filtered)
	var closest_unit = sorted[0].unit
	
	return closest_unit


func can_hit(attacker, target) -> bool:
	if not is_instance_valid(attacker) or not is_instance_valid(target):
		return false
	return (
		target != attacker
		and target.team != attacker.team
		and target.type != "block"
		and not target.dead
		and not target.immune
	)


func in_range(attacker, target) -> bool:
	if not is_instance_valid(attacker) or not is_instance_valid(target):
		return false
	var att_pos = attacker.global_position + attacker.attack_hit_position
	var att_rad = Modifiers.get_value(attacker, "attack_range")
	var tar_pos = target.global_position + target.collision_position
	var tar_rad = target.collision_radius
	return Utils.circle_collision(att_pos, att_rad, tar_pos, tar_rad)


func is_valid_target(attacker, target) -> bool:
	return can_hit(attacker, target) and in_range(attacker, target)
