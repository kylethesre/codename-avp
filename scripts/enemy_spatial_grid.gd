extends Node

## Spatial hash grid for fast neighbor lookups.
## Divides the world into cells. To find nearby enemies,
## only check the current cell + adjacent cells instead of ALL enemies.

const CELL_SIZE: float = 48.0 # Slightly larger than separation dist to catch all neighbors
const REFRESH_INTERVAL: float = 0.1

var _grid: Dictionary = {} # Vector2i -> Array of enemies
var _refresh_timer: float = 0.0

func _physics_process(delta: float) -> void:
	_refresh_timer -= delta
	if _refresh_timer <= 0:
		_refresh_timer = REFRESH_INTERVAL
		_rebuild()

func _rebuild() -> void:
	_grid.clear()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy):
			var cell = _pos_to_cell(enemy.global_position)
			if not _grid.has(cell):
				_grid[cell] = [enemy]
			else:
				_grid[cell].append(enemy)

func _pos_to_cell(pos: Vector2) -> Vector2i:
	return Vector2i(int(floor(pos.x / CELL_SIZE)), int(floor(pos.y / CELL_SIZE)))

## Returns nearby enemies from the 3x3 cell neighborhood around pos.
## Excludes the 'exclude' node (typically the caller itself).
func get_nearby(pos: Vector2, exclude: Node2D = null) -> Array:
	var center = _pos_to_cell(pos)
	var result: Array = []
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			var key = Vector2i(center.x + dx, center.y + dy)
			if _grid.has(key):
				for enemy in _grid[key]:
					if enemy != exclude and is_instance_valid(enemy):
						result.append(enemy)
	return result
