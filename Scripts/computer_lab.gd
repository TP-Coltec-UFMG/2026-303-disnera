extends Node2D
func _ready() -> void:
	z_index = -5
	var quadro := Label.new()
	quadro.position = Vector2(540,95)
	quadro.add_theme_font_size_override("font_size",18)
	quadro.add_theme_constant_override("line_spacing",-4)
	quadro.add_theme_color_override("font_color",Color("e4e6cc"))
	quadro.text = "Leando Maia  /  PROGRAMAÇÃO EM JAVA\nint soma = 0;\nfor (int i = 1; i <= 3; i++) {\n    soma += i;\n}\nSystem.out.println(soma); // 6"
	add_child(quadro)
func _draw() -> void:
	draw_rect(Rect2(0,0,1600,1100),Color("99988b"))
	for x in range(0,1600,80):
		draw_line(Vector2(x,260),Vector2(x,1100),Color("8b8c83"),1)
	for y in range(260,1100,80):
		draw_line(Vector2(0,y),Vector2(1600,y),Color("8b8c83"),1)
	draw_rect(Rect2(0,0,1600,260),Color("c4ac76"))
	draw_rect(Rect2(510,80,580,180),Color("51483b"))
	draw_rect(Rect2(520,90,560,160),Color("304f43"))
	for x in [80,300,1160,1380]:
		draw_rect(Rect2(x,110,130,125),Color("5d453a"))
		draw_rect(Rect2(x+8,118,114,109),Color("879f9f"))
		draw_line(Vector2(x+65,118),Vector2(x+65,227),Color("5d453a"),5)
	for x in [250,700,1150]:
		draw_rect(Rect2(x,60,220,16),Color("e3dfbb"))
	draw_rect(Rect2(0,260,40,840),Color("695a46"))
	draw_rect(Rect2(1560,260,40,840),Color("695a46"))
	draw_rect(Rect2(700,1060,200,40),Color("874f38"))
