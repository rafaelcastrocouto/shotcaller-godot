extends Node

# self = Collisions

const Quadtree = preload("res://collision/quadtree.gd")

# COLLISION QUADTREES
var quad:Quadtree
var block_template:PackedScene = preload("res://collision/blocks/block_template.tscn")
var tile_size := 64
var half_tile_size := tile_size / 2
var current_map : Node2D
var max_collision_extent := 0.0



func create_quadtree(bounds, splitThreshold, splitLimit, currentSplit = 0):
	return Quadtree.new(self, bounds, splitThreshold, splitLimit, currentSplit)


func setup_quadtree(map):
	current_map = map
	tile_size = map.tile_size
	half_tile_size = map.half_tile_size
	var bound = Rect2(Vector2.ZERO, Vector2(map.size.x, map.size.y))
	quad = create_quadtree(bound, 16, 16)


func get_units_in_radius(pos: Vector2, rad: float) -> Array:
	return quad.get_units_in_radius(pos, rad)


func get_units_in_radius_into(pos: Vector2, rad: float, results: Array) -> Array:
	return quad.get_units_in_radius_into(pos, rad, results)


func create_block(x, y, team):
	var block = block_template.instantiate()
	block.selectable = false
	block.moves = false
	block.attacks = false
	block.collide = true
	if team == "blue": block.get_node("light").visible = true
	block.global_position = Vector2(half_tile_size + x * tile_size, half_tile_size + y * tile_size)
	current_map.block_container.add_child(block)
	setup(block)
	WorldState.get_state("all_units").append(block)
	return block


func setup(unit):
	var select = unit.get_node_or_null("collisions/select")
	if select:
		unit.selection_position = select.position
		if select.shape:
			unit.selection_radius = select.shape.radius
	
	var block = unit.get_node_or_null("collisions/block")
	var block_node = unit.get_node_or_null("block")
	if block:
		unit.collision_position = block.position
		if block.shape:
			unit.collision_radius = block.shape.radius
	elif block_node is CollisionShape2D:
		if block_node:
			unit.collision_position = block_node.position
			if block_node.shape:
				unit.collision_radius = block_node.shape.radius
	
	var attack = unit.get_node_or_null("collisions/attack")
	if attack:
		unit.attack_hit_position = attack.position
		if attack.shape:
			unit.attack_hit_radius = attack.shape.radius

	if unit is CollisionObject2D:
		unit.collision_layer = 0
		unit.collision_mask = 0



func physics_process(delta):
	quad.clear()
	max_collision_extent = 0.0
	var all_units = WorldState.get_state("all_units")
	
	for unit1 in all_units:
		if unit1.collide and not unit1.dead:
			quad.add_body(unit1)
			var collision_extent = unit1.collision_position.length() + unit1.collision_radius
			max_collision_extent = max(max_collision_extent, collision_extent)
	
	for unit1 in all_units:
		if unit1.projectiles.size():
			for projectile in unit1.projectiles:
				if is_instance_valid(projectile.node) and projectile.speed and projectile.stuck == false:
					var projectile_position = projectile.node.global_position + (projectile.speed * delta)
					# projectile out of range
					if projectile_position.distance_to(unit1.global_position + unit1.collision_position) > projectile.radius:
						Goap.get_action("RangeAttack").projectile_stuck(unit1, null, projectile)
					else:
						if projectile.target:
							if projectile.target.point_collision(projectile_position):
								Goap.get_goal("EnemyDefeated").take_hit(unit1, projectile.target, projectile)
						else: # pierces
							var targets = Collisions.get_units_in_radius(projectile_position, 1) 
							for target in targets:
								if (Goap.get_action("ChooseTarget").can_hit(unit1, target) and
										projectile.targets.find(target) < 0 and
										target.point_collision(projectile_position) ):
									Goap.get_goal("EnemyDefeated").take_hit(unit1, target, projectile)
						# move projectile
						if not projectile.stuck: Goap.get_action("RangeAttack").projectile_step(delta, projectile)
		
		unit1.next_event  = "" # default no event
		if not unit1.dead:
			if unit1.moves and unit1.state == "move":
				if Goap.get_goal("ArriveAtDestination").is_at_destination(unit1):
					unit1.next_event = "arrive"
				else:
					unit1.next_event = "move"

		match unit1.next_event:
			"move": unit1.on_move(delta)
			"arrive": unit1.on_arrive()
