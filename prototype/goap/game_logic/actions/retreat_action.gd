extends "res://goap/goap_system/action_contract.gd"


func get_class_name():
	return "Retreat"


func is_valid(agent) -> bool:
	return agent.get_unit().moves


func get_effects() -> Dictionary:
	return {"ready_to_fight": true}


func perform(agent, _delta) -> bool:
	return agent.get_state("arrived_at_retreat", false)


func enter(agent):
	var unit = agent.get_unit()
	agent.set_state("is_retreating", true)
	var lane = agent.get_state("lane")
	var path = WorldState.get_state("lanes")[lane].duplicate()
	if unit.team == "red":
		path.reverse()
	var recover_point = path[0]
	var half = WorldState.get_state("map").half_tile_size
	recover_point.x += (randf() * 2 * half) - half
	recover_point.y += (randf() * 2 * half) - half
	Goap.get_action("Navigate").navigate_to(unit, recover_point)
	

func on_arrive(agent):
	Goap.get_goal("ArriveAtDestination").on_arrive(agent)
	if (agent.get_state("arrived_at_destination", false)):
		agent.set_state("is_retreating", false)
		agent.set_state("arrived_at_retreat", true)
