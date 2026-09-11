extends CanvasLayer

@onready var color_rect = $ColorRect

func fade_in(duration := 2.0):
	color_rect.visible = true
	color_rect.modulate.a = 1.0

	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.0, duration)

	await tween.finished

	color_rect.visible = false


func fade_out(duration := 2.0):
	color_rect.visible = true
	color_rect.modulate.a = 0.0

	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, duration)

	await tween.finished
