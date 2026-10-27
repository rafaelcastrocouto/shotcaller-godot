extends "res://goap/goap_system/goal_contract.gd"


func get_class_name() -> String:
	return "EnemyDefeated"


func is_valid(agent) -> bool:
	var unit = agent.get_unit()
	if (agent.get_state("ready_to_fight", true)):
		var target = unit.target
		if target: return true
	return false


func priority(_agent) -> int:
	return 6


func get_desired_state(_agent) -> Dictionary:
	return {"enemy_dead": true}
