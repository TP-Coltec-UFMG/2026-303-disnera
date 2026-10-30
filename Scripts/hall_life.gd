extends Node2D
var tempo := 0.0
func _process(delta: float) -> void:
	tempo += delta
	queue_redraw()
func _draw() -> void:
	for i in range(13):
		var x := 170+i*51
		draw_line(Vector2(x,72),Vector2(x+51,74),Color("6c5544"),1)
		draw_colored_polygon(PackedVector2Array([Vector2(x,74),Vector2(x+20,74),Vector2(x+10,93)]), [Color("bd7855"),Color("d5bc6c"),Color("6f9f91")][i%3])
	for i in range(6):
		var pos := Vector2(370+i*43,220-fmod(tempo*16+i*17,60))
		draw_circle(pos,3,Color("d5b76f"))
		draw_line(pos, pos+Vector2(0,-10),Color("d5b76f"),2)
