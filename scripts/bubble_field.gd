extends Control

const BUBBLE_COUNT: int = 32
const POP_CHANCE_PER_SECOND: float = 0.012
const POP_DURATION: float = 0.18

var bubbles: Array[Dictionary] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	randomize()

	for _index in range(BUBBLE_COUNT):
		var start_y := randf_range(-size.y, size.y)
		bubbles.append(_make_bubble(start_y))


func _process(delta: float) -> void:
	for index in range(bubbles.size()):
		var bubble: Dictionary = bubbles[index]
		var radius: float = bubble["radius"]

		if bool(bubble["popping"]):
			var time_left := maxf(float(bubble["pop_timer"]) - delta, 0.0)
			bubble["pop_timer"] = time_left
			if time_left <= 0.0:
				bubble = _make_bubble(size.y + radius)
		else:
			var position: Vector2 = bubble["position"]
			position.y -= float(bubble["speed"]) * delta

			if position.y < -radius:
				bubble = _make_bubble(size.y + radius)
			elif randf() < POP_CHANCE_PER_SECOND * delta:
				bubble["popping"] = true
				bubble["pop_timer"] = POP_DURATION
			else:
				bubble["position"] = position

		bubbles[index] = bubble

	queue_redraw()


func _draw() -> void:
	for bubble in bubbles:
		var position: Vector2 = bubble["position"]
		var radius: float = bubble["radius"]
		var alpha: float = bubble["alpha"]
		var green := Color(0.12, 0.9, 0.36, alpha)
		var pop_progress := 0.0

		if bool(bubble["popping"]):
			pop_progress = 1.0 - float(bubble["pop_timer"]) / POP_DURATION

		var bubble_scale := 1.0 - pop_progress
		var visible_radius := radius * bubble_scale
		var visible_alpha := alpha * bubble_scale

		draw_circle(
			position,
			visible_radius,
			Color(green.r, green.g, green.b, visible_alpha * 0.16)
		)
		draw_arc(position, visible_radius, 0.0, TAU, 32, Color(
			green.r, green.g, green.b, visible_alpha
		), 1.5, true)

		if bool(bubble["popping"]):
			var ring_radius := radius * (0.9 + pop_progress * 1.5)
			draw_arc(
				position,
				ring_radius,
				0.0,
				TAU,
				32,
				Color(0.55, 1.0, 0.68, visible_alpha),
				2.0,
				true
			)

		if pop_progress < 0.55:
			draw_circle(
				position + Vector2(-radius * 0.32, -radius * 0.32),
				radius * 0.13 * bubble_scale,
				Color(0.78, 1.0, 0.82, visible_alpha * 0.72)
			)


func _make_bubble(start_y: float) -> Dictionary:
	var radius := randf_range(6.0, 20.0)
	return {
		"position": Vector2(randf_range(0.0, maxf(size.x, 1.0)), start_y),
		"radius": radius,
		"speed": randf_range(24.0, 62.0),
		"alpha": randf_range(0.32, 0.78),
		"popping": false,
		"pop_timer": 0.0,
	}
