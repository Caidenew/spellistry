extends Control

const COLUMNS: int = 5
const ROWS: int = 4


class BeveledGameSlot extends Control:
	func _draw() -> void:
		if size.x < 4.0 or size.y < 4.0:
			return

		var right := size.x - 1.5
		var bottom := size.y - 1.5
		draw_rect(Rect2(Vector2(1.5, 1.5), size - Vector2(3.0, 3.0)), Color(0.96, 0.98, 0.96, 1.0), false, 2.0, true)
		draw_line(Vector2(4.0, bottom), Vector2(right, bottom), Color(0.66, 0.69, 0.67, 1.0), 1.0, true)
		draw_line(Vector2(right, 4.0), Vector2(right, bottom), Color(0.66, 0.69, 0.67, 1.0), 1.0, true)


var game_grid: GridContainer


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	game_grid = GridContainer.new()
	game_grid.columns = COLUMNS
	game_grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(game_grid)

	for row in range(ROWS):
		for column in range(COLUMNS):
			if row == ROWS - 1 and (column == 0 or column == COLUMNS - 1):
				var empty_corner := Control.new()
				empty_corner.mouse_filter = Control.MOUSE_FILTER_IGNORE
				game_grid.add_child(empty_corner)
				continue

			var slot := BeveledGameSlot.new()
			slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
			game_grid.add_child(slot)

	resized.connect(_layout_grid)
	call_deferred("_layout_grid")


func _layout_grid() -> void:
	if game_grid == null:
		return

	var horizontal_gap := int(clampf(size.x * 0.012, 8.0, 16.0))
	var vertical_gap := int(clampf(size.y * 0.018, 8.0, 14.0))
	var tile_side := floori(minf(
		(size.x - horizontal_gap * (COLUMNS - 1)) / COLUMNS,
		(size.y - vertical_gap * (ROWS - 1)) / ROWS
	))
	tile_side = maxi(tile_side, 1)

	game_grid.add_theme_constant_override("h_separation", horizontal_gap)
	game_grid.add_theme_constant_override("v_separation", vertical_gap)

	for child in game_grid.get_children():
		if child is BeveledGameSlot:
			child.custom_minimum_size = Vector2(tile_side, tile_side)
			child.queue_redraw()

	var grid_width := COLUMNS * tile_side + (COLUMNS - 1) * horizontal_gap
	var grid_height := ROWS * tile_side + (ROWS - 1) * vertical_gap
	game_grid.position = (size - Vector2(grid_width, grid_height)) / 2.0
	game_grid.size = Vector2(grid_width, grid_height)
