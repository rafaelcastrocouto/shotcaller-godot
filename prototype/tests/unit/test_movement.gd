extends RefCounted

const MoveAction = preload("res://goap/game_logic/actions/move_action.gd")
const Quadtree = preload("res://collision/quadtree.gd")


# These doubles expose only what MoveAction.step needs; no physics scene is required.
class TestAgent:
	extends RefCounted
	var state := {}

	func get_state(state_name: String, default_value = null):
		return state.get(state_name, default_value)


class TestUnit:
	extends Node2D
	var moves := true
	var current_step := Vector2.ZERO
	var current_destiny := Vector2.ZERO
	var speed := 10.0
	var level := 1
	var current_modifiers = Modifiers.new_modifiers()
	var animations: AnimationPlayer
	var collision_position := Vector2.ZERO
	var collision_radius := 8.0
	var collide := false
	var dead := false
	var agent = TestAgent.new()

	func mirror_look_at(_point: Vector2) -> void:
		pass

	func set_state(_new_state: String) -> void:
		pass


func run(harness) -> void:
	# Restore the shared quadtree after testing.
	var old_quadtree = Collisions.quad
	var old_max_collision_extent = Collisions.max_collision_extent
	var unit = TestUnit.new()
	unit.global_position = Vector2(32, 32)
	unit.current_destiny = Vector2(200, 32)
	Collisions.quad = Quadtree.new(
		Collisions, Rect2(Vector2.ZERO, Vector2(256, 256)), 16, 4
	)
	Collisions.quad.add_body(unit)

	Goap.get_action("MoveAction").step(unit, 1.0)
	harness.check_equal(
		unit.global_position,
		Vector2(42, 32),
		"Movement advances current_step by speed and delta."
	)

	Modifiers.add(unit, "speed", "test_speed", 5.0)
	Goap.get_action("MoveAction").step(unit, 1.0)
	harness.check_equal(
		unit.global_position,
		Vector2(57, 32),
		"Movement recalculates current_step with active speed modifiers."
	)
	Modifiers.remove(unit, "speed", "test_speed")
	unit.global_position = Vector2(32, 32)

	var blocker = TestUnit.new()
	blocker.collide = true
	blocker.global_position = Vector2(60, 32)
	blocker.collision_position = Vector2(6, 0)
	Collisions.max_collision_extent = (
		blocker.collision_position.length() + blocker.collision_radius
	)
	Collisions.quad = Quadtree.new(Collisions, Rect2(Vector2.ZERO, Vector2(256, 256)), 16, 4)
	Collisions.quad.add_body(unit)
	Collisions.quad.add_body(blocker)
	Goap.get_action("MoveAction").step(unit, 1.0)
	Goap.get_action("MoveAction").step(unit, 1.0)
	harness.check_equal(
		unit.global_position,
		Vector2(42, 32),
		"Quadtree blocking prevents movement into another unit."
	)

	blocker.global_position = Vector2(220, 220)
	Goap.get_action("MoveAction").step(unit, 1.0)
	harness.check_equal(
		unit.global_position,
		Vector2(52, 32),
		"Quadtree blocking permits unobstructed movement."
	)
	harness.check(
		Goap.get_action("MoveAction") != null,
		"MoveAction is registered with the GOAP action registry."
	)

	unit.free()
	blocker.free()
	Collisions.quad = old_quadtree
	Collisions.max_collision_extent = old_max_collision_extent
