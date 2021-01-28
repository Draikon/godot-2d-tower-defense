# Calculates a set of walkable positions between the start_point and the goal_point
extends TileMap

const DIRECTIONS := [
	Vector2.UP,
	Vector2.LEFT,
	Vector2.RIGHT,
	Vector2.DOWN
]

export var start_point := Vector2.ZERO
export var goal_point := Vector2.ZERO
export var offset := Vector2(32, 32)

var walkable_cells: PoolVector2Array

var _astar := AStar2D.new()


func get_walkable_path() -> PoolVector2Array:
	var walkable_path := PoolVector2Array()

	var astar_path = _get_astar_path()
	for cell in astar_path:
		var point := map_to_world(cell)
		walkable_path.append(to_global(point) + offset)
	return walkable_path


func _get_astar_path() -> PoolVector2Array:
	var astar_path: PoolVector2Array

	_create_astar_points()
	_connect_neighbor_cells()

	# Creates a walkable path from the start_point to the goal_point
	astar_path = _astar.get_point_path(0, _astar.get_point_count() - 1)
	return astar_path


func _create_astar_points() -> void:
	# Sets cells ID by iteration order 
	var cell_id := 0
	for cell in walkable_cells:
		_astar.add_point(cell_id, cell)
		cell_id += 1
	_astar.set_point_position(0, world_to_map(start_point))
	_astar.set_point_position(_astar.get_point_count() - 1, world_to_map(goal_point))


func _connect_neighbor_cells():
	# Turn the walkable_cells in an Array to find its elements indices
	var walkable_cells_array := Array(walkable_cells)

	for point in _astar.get_points():
		var cell = _astar.get_point_position(point)
		var neighbor_cells = []
		for direction in DIRECTIONS:
			neighbor_cells.append(cell + direction)

		for neighbor_cell in neighbor_cells:
			if not neighbor_cell in walkable_cells:
				continue
			var neighbor_cell_id := walkable_cells_array.find(neighbor_cell)
			if not point == neighbor_cell_id:
				_astar.connect_points(point, neighbor_cell_id)
