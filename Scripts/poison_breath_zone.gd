extends Area2D

var comprimento := 250.0
var abertura := deg_to_rad(62.0)
var dano := 18
var aviso := 0.72
var ativo := false
var pontos := PackedVector2Array()

func configurar(novo_comprimento: float, nova_abertura: float, novo_dano: int, novo_aviso: float) -> void:
	comprimento = novo_comprimento
	abertura = nova_abertura
	dano = novo_dano
	aviso = novo_aviso

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	z_index = 4
	_criar_cone()
	queue_redraw()
	_disparar()

func _criar_cone() -> void:
	pontos = PackedVector2Array([Vector2.ZERO])
	var segmentos := 12
	for i in range(segmentos + 1):
		var t := float(i) / float(segmentos)
		var angulo := lerpf(-abertura * 0.5, abertura * 0.5, t)
		pontos.append(Vector2(cos(angulo), sin(angulo)) * comprimento)
	var col := CollisionPolygon2D.new()
	col.polygon = pontos
	add_child(col)

func _draw() -> void:
	var cor := Color(0.45, 0.05, 0.62, 0.2) if not ativo else Color(0.52, 0.0, 0.72, 0.68)
	draw_colored_polygon(pontos, cor)
	if pontos.size() > 2:
		draw_polyline(pontos, Color(0.83, 0.25, 1.0, 0.95), 2.5)

func _disparar() -> void:
	await get_tree().create_timer(aviso).timeout
	if not is_inside_tree():
		return
	ativo = true
	queue_redraw()
	for body in get_overlapping_bodies():
		if body.name == "Player" and body.has_method("tomar_dano"):
			body.tomar_dano(dano)
	await get_tree().create_timer(0.25).timeout
	queue_free()
