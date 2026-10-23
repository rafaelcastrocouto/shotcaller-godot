extends "res://goap/goap_system/action_contract.gd"

const _wait_regen_bonus = 10


func get_class_name() -> String:
	return "WaitForRegeneration"


func is_valid(agent) -> bool:
	var unit = agent.get_unit()
	return agent.get_state("arrived_at_retreat", false) and unit.regen > 0


func get_effects() -> Dictionary:
	return {"ready_to_fight": true}


func enter(agent):
	Goap.get_action("Move").stop(agent.get_unit())
	agent.set_state("is_retreating", false)


func perform(agent, _delta) -> bool:
	var unit = agent.get_unit()
	var hp = Modifiers.get_value(unit, "hp")
	return unit.current_hp > hp * 0.8


func on_every_second(agent) :
	var unit = agent.get_unit()
	unit.regenerate(_wait_regen_bonus)


func exit(agent):
	agent.set_state("ready_to_fight", true)
