extends "res://goap/goap_system/goal_contract.gd"


func get_class_name() -> String:
	return "WalkLane"


func is_valid(agent) -> bool:
	var unit = agent.get_unit()
	var lane = agent.get_state("lane", "")
	if (
		unit.target
		or not unit.moves
		or unit.dead
		or lane not in WorldState.get_state("lanes")
		or agent.get_state("has_player_command", false)
		or agent.get_state("is_retreating", false)
		or not agent.get_state("ready_to_fight", true)
		or agent.get_state("is_channeling", false)
		or agent.get_state("lane_route_finished", false)):
		return false

	return unit.current_path.is_empty() or unit.current_destiny == Vector2.ZERO



func priority(_agent) -> int:
	return 2


func get_desired_state(_agent) -> Dictionary:
	return {"lane_route_finished": true}


func on_arrive(agent) -> void:
	# todo save lane_final_destination state and check distance
	var route_finished = agent.get_unit().current_path.is_empty()
	Goap.get_goal("ArriveAtDestination").on_arrive(agent)
	if route_finished:
		agent.set_state("lane_route_finished", true)
