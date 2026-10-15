extends RefCounted

const Pathfinder = preload("res://map/pathfind/jump_point_finder.gd")
const NavigateAction = preload("res://goap/game_logic/actions/navigate_action.gd")


class TestMap:
	extends Node2D
	var tile_size := 64
	var half_tile_size := 32
	var size := Vector2(320, 320)


func run(harness) -> void:
	var old_map = WorldState.get_state("map")
	var grid = Pathfinder.GridGD.new().Grid.new(5, 5)
	var finder = Pathfinder.JumpPointFinder.new()
	var open_path = finder.findPath(0, 0, 4, 4, grid.clone())
	harness.check(not open_path.is_empty(), "Pathfinder finds a route across open terrain.")
	if not open_path.is_empty():
		harness.check_equal(open_path.front(), [0, 0], "Open routes start at the source.")
		harness.check_equal(open_path.back(), [4, 4], "Open routes end at the destination.")

	for y in range(4):
		grid.setWalkableAt(2, y, false)
	# A single opening at the bottom should force the route around the wall.
	var route_around_wall = finder.findPath(0, 0, 4, 0, grid.clone())
	harness.check(
		not route_around_wall.is_empty(), "Pathfinder routes around a wall with an open passage."
	)
	if not route_around_wall.is_empty():
		harness.check(
			route_around_wall.any(func(point): return point[1] == 4),
			"Wall detours pass through the only open row."
		)

	grid.setWalkableAt(2, 4, false)
	var blocked_path = finder.findPath(0, 0, 4, 0, grid.clone())
	harness.check(blocked_path.is_empty(), "Pathfinder rejects a fully sealed wall.")

	var map = TestMap.new()
	harness.add_child(map)
	WorldState.set_state("map", map)
	# Each solve uses a cloned working grid, preserving the map's walkability data.
	var navigate_action = NavigateAction.new()
	navigate_action.path_grid = Pathfinder.GridGD.new().Grid.new(5, 5)
	navigate_action.path_finder = finder
	harness.check(
		not navigate_action.find(Vector2(96, 96), Vector2(224, 224)).is_empty(),
		"Navigation uses the custom jump-point pathfinder."
	)
	var start_node = navigate_action.path_grid.getNodeAt(1, 1)
	harness.check(
		not start_node.opened and not start_node.closed and start_node.parent == null,
		"Path searches leave the source walkability grid untouched."
	)
	harness.check(
		not navigate_action.find(Vector2(32, 32), Vector2(288, 288)).is_empty(),
		"Navigation supports paths that start at the grid boundary."
	)
	harness.check(
		not navigate_action.find(Vector2(224, 224), Vector2(96, 96)).is_empty(),
		"Repeated navigation solves remain valid on the same source grid."
	)
	map.free()
	WorldState.set_state("map", old_map)
