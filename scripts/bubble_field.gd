extends Control

const BUBBLE_COUNT: int = 32

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
		var position: Vector2 = bubble["position"]
		var radius: float = bubble["radius"]

		position.y -= float(bubble["speed"]) * delta
		if position.y < -radius:
			bubble = _make_bubble(size.y + radius)
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

		draw_circle(position, radius, Color(green.r, green.g, green.b, alpha * 0.16))
		draw_arc(position, radius, 0.0, TAU, 32, green, 1.5, true)
		draw_circle(
			position + Vector2(-radius * 0.32, -radius * 0.32),
			radius * 0.13,
			Color(0.78, 1.0, 0.82, alpha * 0.72)
		)


func _make_bubble(start_y: float) -> Dictionary:
	var radius := randf_range(6.0, 20.0)
	return {
		"position": Vector2(randf_range(0.0, maxf(size.x, 1.0)), start_y),
		"radius": radius,
		"speed": randf_range(24.0, 62.0),
		"alpha": randf_range(0.32, 0.78),
	}
