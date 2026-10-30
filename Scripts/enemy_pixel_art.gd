extends Node2D
@export var especie := "morcego"
var tempo := 0.0
const PALETA = {"o": Color("211d2d"), "p": Color("544461"), "l": Color("8b7491"), "r": Color("e9a17c"), "b": Color("966344"), "s": Color("c99c60"), "v": Color("98b970"), "w": Color("eee1ba")}
func _process(delta: float) -> void:
	tempo += delta
	queue_redraw()

func pintar(linhas: Array, origem: Vector2, pixel := 2.0) -> void:
	for y in range(linhas.size()):
		for x in range(linhas[y].length()):
			var cor: String = linhas[y][x]
			if PALETA.has(cor):
				draw_rect(Rect2(origem + Vector2(x,y)*pixel, Vector2.ONE*pixel),PALETA[cor])

func _draw() -> void:
	var corpo = get_parent()
	var aviso: bool = (corpo.get("estado") == 1) if especie == "morcego" else bool(corpo.get("preparando"))
	if aviso:
		draw_arc(Vector2.ZERO, 31, 0, TAU, 20, Color("f2c66d"), 2)
	if especie == "morcego":
		var asa := [".......oo",".....oopo","...oopplo",".ooppllpo","opplllppo","oppppppo.","o..oppo..","....oo..."]
		var batida := -6.0 if int(tempo * 9) % 2 == 0 else 1.0
		draw_line(Vector2(-5,-7), Vector2(-12,-10+batida), Color("544461"), 4)
		pintar(asa,Vector2(-26,-15+batida))
		draw_set_transform(Vector2.ZERO,0,Vector2(-1,1))
		draw_line(Vector2(-5,-7), Vector2(-12,-10+batida), Color("544461"), 4)
		pintar(asa,Vector2(-26,-15+batida))
		draw_set_transform(Vector2.ZERO)
		pintar([".oo...oo.",".opo.opo.",".oppo ppo".replace(" ",""),"..opppo..",".oplllpo.",".orpopro.",".opwwwpo.","..opppo..","...ooo..."],Vector2(-9,-16))
	else:
		var passo := 2.0 if int(tempo*8)%2 == 0 else 0.0
		for lado in [-1,1]:
			for i in range(3):
				var p := Vector2(lado*9, -3+i*7)
				draw_line(p,p+Vector2(lado*11,4+passo),Color("211d2d"),4)
				draw_line(p,p+Vector2(lado*10,3+passo),Color("966344"),2)
		draw_rect(Rect2(4,-16,6,12),Color("966344"))
		pintar(["...oooo...","..obssbo..",".obssssbo.",".obsssbbo.",".obbbbbbo.","..obbbbo..","...oooo..."],Vector2(-10,-8))
		pintar(["..ooo....",".obvbo...","..obbo...","...obo...","...obbo..","....obbo.","...obbo..","..obbo..."],Vector2(0,-30))
		for lado in [-1,1]:
			draw_set_transform(Vector2.ZERO,0,Vector2(lado,1))
			draw_line(Vector2(6,-2),Vector2(18,-8),Color("966344"),4)
			pintar([".oo..oo.","obs..sbo","obssssbo",".obbbbo.","..obbo..","...obo.."],Vector2(11,-19))
		draw_set_transform(Vector2.ZERO)
		draw_rect(Rect2(-6,-7,3,3),Color("eee1ba"))
		draw_rect(Rect2(3,-7,3,3),Color("eee1ba"))
