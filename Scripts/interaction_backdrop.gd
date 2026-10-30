extends Control
var tema := "conversa"
func _draw() -> void:
	var w := size.x
	var h := size.y
	if tema == "diario":
		draw_rect(Rect2(0,0,w,h),Color("ead9b1"))
		draw_rect(Rect2(0,0,24,h),Color("805139"))
		for y in range(38,int(h)-12,28):
			draw_line(Vector2(38,y),Vector2(w-18,y),Color(0.38,0.48,0.55,0.19),1)
		for y in range(20,int(h)-15,35):
			draw_arc(Vector2(22,y),8,0,TAU,12,Color("473b35"),2)
		draw_line(Vector2(48,0),Vector2(48,h),Color(0.7,0.3,0.25,0.3),1)
	elif tema == "conversa":
		draw_colored_polygon(PackedVector2Array([Vector2(65,h-2),Vector2(75,h+20),Vector2(105,h-2)]),Color("f3e9cf"))
	elif tema == "java":
		draw_rect(Rect2(8,8,w-16,27),Color("233d49"))
		for x in [22,36,50]:
			draw_circle(Vector2(x,21),4,Color("80b9aa"))
		for x in range(20,int(w)-12,24):
			draw_line(Vector2(x,h-28),Vector2(x+16,h-28),Color("446972"),3)
	elif tema == "musica":
		for x in range(15,int(w)-20,32):
			draw_rect(Rect2(x,h-42,29,32),Color("e5ddc2"))
			if x % 3 != 0:
				draw_rect(Rect2(x+18,h-42,10,18),Color("342c42"))
	elif tema == "circuito" or tema == "metal":
		for x in [12,w-12]:
			for y in [12,h-12]:
				draw_circle(Vector2(x,y),4,Color("a3b6b5"))
		for i in range(4):
			var x := 55.0+i*(w-110)/3
			draw_line(Vector2(x,h-38),Vector2(x+45,h-38),Color("77a995"),3)
			draw_arc(Vector2(x,h-38),12,0,TAU,16,Color("d1bc7d"),3)
	elif tema == "futebol":
		draw_rect(Rect2(12,12,w-24,h-24),Color(0.8,0.9,0.7,0.2),false,2)
		draw_arc(Vector2(w/2,h-38),24,0,TAU,20,Color(0.8,0.9,0.7,0.25),2)
	elif tema == "memorias":
		for i in range(5):
			draw_rect(Rect2(35+i*100,h-35,65,20),Color("c9b9a0"))
