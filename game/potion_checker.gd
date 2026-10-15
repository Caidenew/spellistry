extends Control

const BACKGROUND := Color("#080d09")
const PANEL := Color("#111b14")
const PANEL_RAISED := Color("#17251b")
const GREEN := Color("#40e878")
const PALE := Color("#e5f1e7")
const MUTED := Color("#9aafa0")
const GOLD := Color("#e9c66b")

var completed_tests: Dictionary = {}
var evidence: Array[String] = []


class CustomerPortrait extends Control:
	func _draw() -> void:
		var unit := minf(size.x, size.y)
		var center := size / 2.0
		var skin := Color("#e8b889")
		var hair := Color("#39241b")
		var coat := Color("#29563a")
		var face_radius := unit * 0.22

		draw_circle(center, unit * 0.46, Color("#101a13"))
		draw_arc(center, unit * 0.46, 0.0, TAU, 64, Color("#40e878"), 2.0, true)

		draw_colored_polygon(PackedVector2Array([
			Vector2(center.x - unit * 0.34, center.y + unit * 0.38),
			Vector2(center.x - unit * 0.28, center.y + unit * 0.18),
			Vector2(center.x - unit * 0.14, center.y + unit * 0.11),
			Vector2(center.x + unit * 0.14, center.y + unit * 0.11),
			Vector2(center.x + unit * 0.28, center.y + unit * 0.18),
			Vector2(center.x + unit * 0.34, center.y + unit * 0.38),
		]), coat)

		var head := center + Vector2(0.0, -unit * 0.09)
		draw_circle(head, face_radius, skin)
		draw_colored_polygon(PackedVector2Array([
			head + Vector2(-face_radius, -face_radius * 0.05),
			head + Vector2(-face_radius * 0.82, -face_radius * 0.86),
			head + Vector2(-face_radius * 0.24, -face_radius * 1.13),
			head + Vector2(face_radius * 0.57, -face_radius * 0.96),
			head + Vector2(face_radius, -face_radius * 0.35),
			head + Vector2(face_radius * 0.55, -face_radius * 0.49),
			head + Vector2(0.0, -face_radius * 0.42),
		]), hair)

		draw_circle(head + Vector2(-face_radius * 0.36, 0.0), unit * 0.018, Color("#231c18"))
		draw_circle(head + Vector2(face_radius * 0.36, 0.0), unit * 0.018, Color("#231c18"))
		draw_arc(
			head + Vector2(0.0, face_radius * 0.12),
			unit * 0.07,
			0.2 * PI,
			0.8 * PI,
			20,
			Color("#8a4937"),
			2.0,
			true
		)


func _ready() -> void:
	_show_customer()


func _new_page(title: String, subtitle: String) -> VBoxContainer:
	for child in get_children():
		child.queue_free()

	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = BACKGROUND
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 42)
	margin.add_theme_constant_override("margin_right", 42)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_bottom", 26)
	add_child(margin)

	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 16)
	margin.add_child(page)

	var heading := VBoxContainer.new()
	heading.add_theme_constant_override("separation", 3)
	page.add_child(heading)
	heading.add_child(_label(title, 30, GREEN, true))
	heading.add_child(_label(subtitle, 15, MUTED))

	return page


func _show_customer() -> void:
	var page := _new_page("POTION CHECKER", "FRONT DESK  /  A NEW CUSTOMER")
	page.add_child(_label("CASE 001  •  MOONLIGHT TONIC", 13, GOLD, true))

	var card_body := HBoxContainer.new()
	card_body.add_theme_constant_override("separation", 28)
	card_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var card := _panel_with(card_body)
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(card)

	var portrait := CustomerPortrait.new()
	portrait.custom_minimum_size = Vector2(210, 250)
	portrait.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	card_body.add_child(portrait)

	var conversation := VBoxContainer.new()
	conversation.add_theme_constant_override("separation", 12)
	conversation.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	conversation.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	card_body.add_child(conversation)
	conversation.add_child(_label("MIRA  •  CUSTOMER", 14, GREEN, true))
	conversation.add_child(_label(
		"“I found these crystals settled at the bottom of my moonlight tonic. Before I mix it with water, can you tell me what I should expect? I’m worried it might fizz or warm up.”",
		22,
		PALE
	))
	conversation.add_child(_label(
		"She hands over a sealed sample vial and waits for your advice.",
		16,
		MUTED
	))

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_END
	page.add_child(actions)
	var lab_button := _button("Bring the potion to the back room  →", true)
	lab_button.pressed.connect(_show_lab)
	actions.add_child(lab_button)


func _show_lab() -> void:
	var page := _new_page("BACK ROOM  /  SAMPLE ANALYSIS", "Run small tests and collect evidence before advising Mira.")

	var request := _panel_with(_label(
		"MIRA’S QUESTION   “What are the crystals doing, and what should I expect if I add water?”",
		16,
		PALE
	))
	page.add_child(request)

	var tests_row := HBoxContainer.new()
	tests_row.add_theme_constant_override("separation", 12)
	tests_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(tests_row)

	var test_cards := [
		{
			"id": "appearance",
			"number": "01",
			"title": "Inspect the sample",
			"detail": "Look for layers, particles, and other physical clues.",
			"button": "Inspect appearance",
		},
		{
			"id": "density",
			"number": "02",
			"title": "Measure density",
			"detail": "Use the sample’s mass and volume to calculate density.",
			"button": "Measure mass & volume",
		},
		{
			"id": "water",
			"number": "03",
			"title": "Test with water",
			"detail": "Try a tiny amount and watch for dissolving, fizzing, or warmth.",
			"button": "Run a small water test",
		},
	]

	for test in test_cards:
		var card_body := VBoxContainer.new()
		card_body.add_theme_constant_override("separation", 10)
		card_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var card := _panel_with(card_body)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.size_flags_vertical = Control.SIZE_EXPAND_FILL
		tests_row.add_child(card)

		card_body.add_child(_label(str(test["number"]), 13, GOLD, true))
		card_body.add_child(_label(str(test["title"]), 20, PALE, true))
		var detail := _label(str(test["detail"]), 15, MUTED)
		detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
		card_body.add_child(detail)

		var test_id := str(test["id"])
		var test_button := _button(
			"✓  Evidence collected" if completed_tests.has(test_id) else str(test["button"]),
			false
		)
		test_button.disabled = completed_tests.has(test_id)
		test_button.pressed.connect(_complete_test.bind(test_id))
		card_body.add_child(test_button)

	var notebook_body := VBoxContainer.new()
	notebook_body.add_theme_constant_override("separation", 7)
	var notebook := _panel_with(notebook_body)
	page.add_child(notebook)
	notebook_body.add_child(_label(
		"LAB NOTEBOOK  •  %d / 3 observations" % evidence.size(),
		14,
		GREEN,
		true
	))
	if evidence.is_empty():
		notebook_body.add_child(_label("Your evidence will appear here as you run tests.", 15, MUTED))
	else:
		for note in evidence:
			notebook_body.add_child(_label("•  " + note, 14, PALE))

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	actions.alignment = BoxContainer.ALIGNMENT_END
	page.add_child(actions)

	var restart_button := _button("Reset case", false)
	restart_button.pressed.connect(_reset_case)
	actions.add_child(restart_button)

	var advice_button := _button("Write recommendation  →", evidence.size() == 3)
	advice_button.disabled = evidence.size() < 3
	advice_button.pressed.connect(_show_recommendation)
	actions.add_child(advice_button)


func _complete_test(test_id: String) -> void:
	if completed_tests.has(test_id):
		return

	var result_by_test := {
		"appearance": "Visible crystals settle under the green liquid: the sample is a non-uniform mixture.",
		"density": "Mass 18.0 g ÷ volume 15.0 mL = density 1.20 g/mL.",
		"water": "In a tiny sample, some crystals dissolve. No fizzing or warming is observed.",
	}
	if not result_by_test.has(test_id):
		return

	completed_tests[test_id] = true
	evidence.append(result_by_test[test_id])
	_show_lab()


func _show_recommendation() -> void:
	if evidence.size() < 3:
		return

	var page := _new_page("CUSTOMER REPORT", "CASE 001  /  EVIDENCE-BASED RECOMMENDATION")
	var card_body := HBoxContainer.new()
	card_body.add_theme_constant_override("separation", 26)
	card_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var card := _panel_with(card_body)
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(card)

	var portrait := CustomerPortrait.new()
	portrait.custom_minimum_size = Vector2(190, 230)
	portrait.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	card_body.add_child(portrait)

	var report := VBoxContainer.new()
	report.add_theme_constant_override("separation", 10)
	report.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	report.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	card_body.add_child(report)
	report.add_child(_label("YOUR FINDINGS", 14, GREEN, true))
	report.add_child(_label(
		"• The tonic is a non-uniform mixture with crystals settled at the bottom.\n"
		+ "• Its measured density is 1.20 g/mL (18.0 g ÷ 15.0 mL).\n"
		+ "• Some crystals dissolved in the small water test. No fizzing or warming was observed.",
		17,
		PALE
	))
	report.add_child(_label("YOUR ADVICE TO MIRA", 14, GOLD, true))
	report.add_child(_label(
		"“The crystals partly dissolve in water. Our small test didn’t fizz or warm up, but that only tells us what happened in this sample. If you decide to mix it, try a tiny amount first and watch for changes.”",
		18,
		PALE
	))

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_END
	page.add_child(actions)
	var next_button := _button("Finish case  ↻", true)
	next_button.pressed.connect(_reset_case)
	actions.add_child(next_button)


func _reset_case() -> void:
	completed_tests.clear()
	evidence.clear()
	_show_customer()


func _label(text: String, font_size: int, color: Color, bold: bool = false) -> Label:
	var result := Label.new()
	result.text = text
	result.add_theme_font_size_override("font_size", font_size)
	result.add_theme_color_override("font_color", color)
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if bold:
		result.add_theme_color_override("font_color", color)
	return result


func _button(text: String, primary: bool) -> Button:
	var result := Button.new()
	result.text = text
	result.custom_minimum_size = Vector2(190, 48)
	result.add_theme_font_size_override("font_size", 15)
	result.add_theme_color_override("font_color", PALE)
	result.add_theme_color_override("font_hover_color", Color.WHITE)
	result.add_theme_stylebox_override("normal", _button_style(PANEL_RAISED if primary else PANEL, GREEN if primary else MUTED))
	result.add_theme_stylebox_override("hover", _button_style(Color("#203427"), GREEN))
	result.add_theme_stylebox_override("pressed", _button_style(Color("#14271b"), GREEN))
	result.add_theme_stylebox_override("disabled", _button_style(Color("#172019"), Color("#647568")))
	result.size_flags_horizontal = Control.SIZE_SHRINK_END
	return result


func _button_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style


func _panel_with(content: Control) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style())
	panel.add_child(content)
	return panel


func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL
	style.border_color = Color("#2a3c2e")
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 18
	style.content_margin_bottom = 18
	return style
