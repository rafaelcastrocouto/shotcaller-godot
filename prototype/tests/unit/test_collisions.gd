extends RefCounted

const Quadtree = preload("res://collision/quadtree.gd")


func run(harness) -> void:
	# A low split threshold forces the quadtree to create child quadrants.
	var tree = Quadtree.new(Collisions, Rect2(Vector2.ZERO, Vector2(256, 256)), 1, 4)
	var near_unit = Node2D.new()
	near_unit.global_position = Vector2(32, 32)
	var middle_unit = Node2D.new()
	middle_unit.global_position = Vector2(96, 96)
	var far_unit = Node2D.new()
	far_unit.global_position = Vector2(224, 224)
	tree.add_body(near_unit)
	tree.add_body(middle_unit)
	tree.add_body(far_unit)

	var nearby = tree.get_units_in_radius(Vector2(32, 32), 16)
	harness.check(nearby.has(near_unit), "Quadtree radius queries include nearby units.")
	harness.check(not nearby.has(far_unit), "Quadtree radius queries omit distant units.")
	var reusable_results: Array = [far_unit]
	tree.get_units_in_radius_into(Vector2(32, 32), 16, reusable_results)
	harness.check(
		reusable_results.size() == 1 and reusable_results[0] == near_unit,
		"Quadtree queries reuse and replace caller-provided result buffers."
	)
	var quadrant_count = tree._quadrants.size()
	tree.clear()
	harness.check_equal(
		tree._quadrants.size(), quadrant_count, "Clearing the quadtree preserves its subdivision."
	)
	tree.add_body(near_unit)
	harness.check(
		tree.get_units_in_radius(Vector2(32, 32), 16).has(near_unit),
		"Rebuilt quadtree branches return bodies after a clear."
	)

	tree.clear()
	near_unit.free()
	middle_unit.free()
	far_unit.free()

	# Geometry helpers treat tangency as non-overlap, matching their strict '<' checks.
	harness.check(
		Utils.circle_point_collision(Vector2(9, 0), Vector2.ZERO, 10),
		"Circle-point checks include points inside the radius."
	)
	harness.check(
		not Utils.circle_point_collision(Vector2(10, 0), Vector2.ZERO, 10),
		"Circle-point checks exclude points on the radius boundary."
	)
	harness.check(
		Utils.circle_collision(Vector2.ZERO, 5, Vector2(9, 0), 5),
		"Circle collision detects overlapping circles."
	)
	harness.check(
		not Utils.circle_collision(Vector2.ZERO, 5, Vector2(10, 0), 5),
		"Circle collision excludes tangent circles."
	)
