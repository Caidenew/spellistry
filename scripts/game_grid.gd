extends Control

const COLUMNS: int = 5
const ROWS: int = 4
const TILE_WIDTH_RATIO: float = 1.08
const TILE_HEIGHT_RATIO: float = 0.88


class BeveledGameSlot extends Control:
	var outline_style: StyleBoxFlat

	func _ready() -> void:
		outline_style = StyleBoxFlat.new()
		outline_style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
		outline_style.border_color = Color(0.96, 0.98, 0.96, 1.0)
		outline_style.set_border_width_all(2)
		outline_style.set_corner_radius_all(8)

	func _draw() -> void:
		if size.x < 4.0 or size.y < 4.0 or outline_style == null:
			return

		draw_style_box(outline_style, Rect2(Vector2.ZERO, size))

		var right := size.x - 1.5
		var bottom := size.y - 1.5
		draw_line(Vector2(9.0, bottom), Vector2(right - 9.0, bottom), Color(0.66, 0.69, 0.67, 1.0), 1.0, true)
		draw_line(Vector2(right, 9.0), Vector2(right, bottom - 9.0), Color(0.66, 0.69, 0.67, 1.0), 1.0, true)


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
	var base_side := floori(minf(
		(size.x - horizontal_gap * (COLUMNS - 1)) / (COLUMNS * TILE_WIDTH_RATIO),
		(size.y - vertical_gap * (ROWS - 1)) / (ROWS * TILE_HEIGHT_RATIO)
	))
	base_side = maxi(base_side, 1)
	var tile_width := floori(base_side * TILE_WIDTH_RATIO)
	var tile_height := floori(base_side * TILE_HEIGHT_RATIO)

	game_grid.add_theme_constant_override("h_separation", horizontal_gap)
	game_grid.add_theme_constant_override("v_separation", vertical_gap)

	for child in game_grid.get_children():
		if child is BeveledGameSlot:
			child.custom_minimum_size = Vector2(tile_width, tile_height)
			child.queue_redraw()

	var grid_width := COLUMNS * tile_width + (COLUMNS - 1) * horizontal_gap
	var grid_height := ROWS * tile_height + (ROWS - 1) * vertical_gap
	game_grid.position = (size - Vector2(grid_width, grid_height)) / 2.0
	game_grid.size = Vector2(grid_width, grid_height)
