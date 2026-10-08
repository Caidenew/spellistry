extends VBoxContainer

const TILE_DATA: Array[Dictionary] = [
	{"number": "16", "symbol": "S", "name": "Sulfur", "real": true},
	{"number": "15", "symbol": "P", "name": "Phosphorus", "real": true},
	{"number": "119", "symbol": "E", "name": "Elarite*", "real": false},
	{"number": "120", "symbol": "L", "name": "Lumium*", "real": false},
	{"number": "120", "symbol": "L", "name": "Lumium*", "real": false},
	{"number": "53", "symbol": "I", "name": "Iodine", "real": true},
	{"number": "16", "symbol": "S", "name": "Sulfur", "real": true},
	{"number": "121", "symbol": "T", "name": "Tetrinium*", "real": false},
	{"number": "122", "symbol": "R", "name": "Rhyllium*", "real": false},
	{"number": "39", "symbol": "Y", "name": "Yttrium", "real": true},
]


func _ready() -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 5)

	var tile_row := HBoxContainer.new()
	tile_row.alignment = BoxContainer.ALIGNMENT_CENTER
	tile_row.add_theme_constant_override("separation", 4)
	add_child(tile_row)

	for tile_data in TILE_DATA:
		tile_row.add_child(_make_tile(tile_data))

	var legend := Label.new()
	legend.text = "Real: S Sulfur · P Phosphorus · I Iodine · Y Yttrium\n* Fictional elements; numbers 119–122"
	legend.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	legend.add_theme_font_size_override("font_size", 10)
	legend.modulate = Color(0.72, 0.78, 0.73, 1.0)
	add_child(legend)


func _make_tile(tile_data: Dictionary) -> PanelContainer:
	var is_real: bool = tile_data["real"]
	var accent := Color(0.25, 0.88, 0.46, 1.0) if is_real else Color(0.48, 0.78, 0.63, 1.0)

	var tile := PanelContainer.new()
	tile.custom_minimum_size = Vector2(55, 76)
	tile.tooltip_text = "%s — %s (atomic number %s)" % [
		tile_data["symbol"],
		tile_data["name"].trim_suffix("*"),
		tile_data["number"],
	]

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.025, 0.075, 0.045, 0.94)
	panel_style.border_color = accent
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(5)
	panel_style.content_margin_left = 4
	panel_style.content_margin_right = 4
	panel_style.content_margin_top = 3
	panel_style.content_margin_bottom = 3
	tile.add_theme_stylebox_override("panel", panel_style)

	var contents := VBoxContainer.new()
	contents.add_theme_constant_override("separation", 0)
	tile.add_child(contents)

	var number := Label.new()
	number.text = str(tile_data["number"])
	number.add_theme_font_size_override("font_size", 10)
	number.modulate = accent
	contents.add_child(number)

	var symbol := Label.new()
	symbol.text = str(tile_data["symbol"])
	symbol.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	symbol.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	symbol.size_flags_vertical = Control.SIZE_EXPAND_FILL
	symbol.add_theme_font_size_override("font_size", 25)
	symbol.add_theme_color_override("font_color", Color(0.9, 1.0, 0.92, 1.0))
	contents.add_child(symbol)

	var element_name := Label.new()
	element_name.text = str(tile_data["name"])
	element_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	element_name.clip_text = true
	element_name.add_theme_font_size_override("font_size", 8)
	element_name.modulate = Color(0.76, 0.85, 0.78, 1.0)
	contents.add_child(element_name)

	return tile
