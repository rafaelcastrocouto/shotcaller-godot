extends "res://goap/goap_system/goal_contract.gd"


func get_class_name() -> String:
	return "WalkLane"


func is_valid(agent) -> bool:
	var unit = agent.get_unit()
	var lane = agent.get_state("lane", "")
	if (
		not unit.moves
		or unit.dead
		or lane not in WorldState.get_state("lanes")
		or agent.get_state("has_player_command", false)
		or agent.get_state("is_retreating", false)
		or agent.get_state("is_channeling", false)
	):
		return false

	if agent.get_state("lane_route", "") != lane:
		agent.set_state("lane_route", lane)
		agent.erase_state("lane_route_finished")

	if agent.get_state("lane_route_finished", false):
		return false

	if unit.target:
		return false

	if unit.current_path.is_empty() and unit.current_destiny == Vector2.ZERO:
		var path = Navigation.new_lane_path(lane, unit.team)
		if path.is_empty():
			return false
		Goap.get_action("Navigate").setup_unit_path(unit, path)

	agent.set_state("has_path", not unit.current_path.is_empty())
	return not unit.current_path.is_empty() or unit.current_destiny != Vector2.ZERO


func priority(_agent) -> int:
	return 2


func get_desired_state(_agent) -> Dictionary:
	return {"arrived_at_destination": true}


func on_arrive(agent) -> void:
	var route_finished = agent.get_unit().current_path.is_empty()
	Goap.get_goal("ArriveAtDestination").on_arrive(agent)
	if route_finished:
		agent.set_state("lane_route_finished", true)
