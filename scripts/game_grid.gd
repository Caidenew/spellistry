extends Control

const COLUMNS: int = 6
const ROWS: int = 3
const TILE_WIDTH_RATIO: float = 1.08
const TILE_HEIGHT_RATIO: float = 0.88
const HOVER_SCALE: float = 0.93
const HOVER_DURATION: float = 0.12


class BeveledGameSlot extends Control:
	var outline_style: StyleBoxFlat
	var hover_tween: Tween

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP

		outline_style = StyleBoxFlat.new()
		outline_style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
		outline_style.border_color = Color(0.96, 0.98, 0.96, 1.0)
		outline_style.set_border_width_all(2)
		outline_style.set_corner_radius_all(8)

		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)
		resized.connect(_update_pivot)
		_update_pivot()

	func _draw() -> void:
		if size.x < 4.0 or size.y < 4.0 or outline_style == null:
			return

		draw_style_box(outline_style, Rect2(Vector2.ZERO, size))

		var right := size.x - 1.5
		var bottom := size.y - 1.5
		var horizontal_inset := minf(9.0, size.x * 0.2)
		var vertical_inset := minf(9.0, size.y * 0.2)
		draw_line(
			Vector2(horizontal_inset, bottom),
			Vector2(right - horizontal_inset, bottom),
			Color(0.66, 0.69, 0.67, 1.0),
			1.0,
			true
		)
		draw_line(
			Vector2(right, vertical_inset),
			Vector2(right, bottom - vertical_inset),
			Color(0.66, 0.69, 0.67, 1.0),
			1.0,
			true
		)

	func _on_mouse_entered() -> void:
		_animate_scale(Vector2(HOVER_SCALE, HOVER_SCALE))

	func _on_mouse_exited() -> void:
		_animate_scale(Vector2.ONE)

	func _animate_scale(target: Vector2) -> void:
		if hover_tween != null and hover_tween.is_running():
			hover_tween.kill()

		hover_tween = create_tween()
		hover_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		hover_tween.tween_property(self, "scale", target, HOVER_DURATION)

	func _update_pivot() -> void:
		pivot_offset = size / 2.0


var slots: Array[BeveledGameSlot] = []
var merged_slot: BeveledGameSlot


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_slots()
	resized.connect(_layout_grid)
	call_deferred("_layout_grid")


func _build_slots() -> void:
	# Leave the center 2-by-2 area for one larger combined slot.
	for row in range(2):
		for column in range(COLUMNS):
			if column == 2 or column == 3:
				continue

			var slot := BeveledGameSlot.new()
			slots.append(slot)
			add_child(slot)

	merged_slot = BeveledGameSlot.new()
	add_child(merged_slot)

	# Three bottom slots stay centered in the wider six-column layout.
	for _index in range(3):
		var slot := BeveledGameSlot.new()
		slots.append(slot)
		add_child(slot)


func _layout_grid() -> void:
	var horizontal_gap := int(clampf(size.x * 0.012, 8.0, 16.0))
	var vertical_gap := int(clampf(size.y * 0.018, 8.0, 14.0))
	var base_side := floori(minf(
		(size.x - horizontal_gap * (COLUMNS - 1)) / (COLUMNS * TILE_WIDTH_RATIO),
		(size.y - vertical_gap * (ROWS - 1)) / (ROWS * TILE_HEIGHT_RATIO)
	))
	base_side = maxi(base_side, 1)
	var tile_width := floori(base_side * TILE_WIDTH_RATIO)
	var tile_height := floori(base_side * TILE_HEIGHT_RATIO)
	var pitch := Vector2(tile_width + horizontal_gap, tile_height + vertical_gap)
	var grid_size := Vector2(
		COLUMNS * tile_width + (COLUMNS - 1) * horizontal_gap,
		ROWS * tile_height + (ROWS - 1) * vertical_gap
	)
	var grid_origin := (size - grid_size) / 2.0

	var slot_index := 0
	for row in range(2):
		for column in range(COLUMNS):
			if column == 2 or column == 3:
				continue

			_place_slot(
				slots[slot_index],
				grid_origin + Vector2(column * pitch.x, row * pitch.y),
				Vector2(tile_width, tile_height)
			)
			slot_index += 1

	var merged_size := Vector2(2 * tile_width + horizontal_gap, 2 * tile_height + vertical_gap)
	_place_slot(
		merged_slot,
		grid_origin + Vector2(2 * pitch.x, 0.0),
		merged_size
	)

	var bottom_width := 3 * tile_width + 2 * horizontal_gap
	var bottom_x := grid_origin.x + (grid_size.x - bottom_width) / 2.0
	for index in range(3):
		_place_slot(
			slots[slot_index],
			Vector2(bottom_x + index * pitch.x, grid_origin.y + 2 * pitch.y),
			Vector2(tile_width, tile_height)
		)
		slot_index += 1


func _place_slot(slot: BeveledGameSlot, slot_position: Vector2, slot_size: Vector2) -> void:
	slot.position = slot_position
	slot.size = slot_size
	slot.pivot_offset = slot_size / 2.0
	slot.queue_redraw()
