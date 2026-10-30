extends Node2D
var indice := 0
func _draw() -> void:
	draw_rect(Rect2(-40,-18,80,34),Color("4b4036"))
	draw_rect(Rect2(-38,-18,76,29),Color("ad9265"))
	draw_rect(Rect2(-30,12,5,14),Color("514e48"))
	draw_rect(Rect2(25,12,5,14),Color("514e48"))
	draw_rect(Rect2(-20,-40,40,28),Color("303b3d"))
	draw_rect(Rect2(-17,-37,34,21),Color("548487"))
	draw_rect(Rect2(-4,-12,8,5),Color("303b3d"))
	draw_rect(Rect2(-24,-5,40,10),Color("cfcebb"))
	for x in range(-20,15,6):
		draw_line(Vector2(x,-3),Vector2(x,2),Color("7d8b84"),2)
	draw_rect(Rect2(23,-4,7,10),Color("383f40"))
	for i in range(3):
		draw_line(Vector2(-14,-33+i*5),Vector2(8-i*4,-33+i*5),Color("a1c4a7"),1)
