extends Area2D

var raio := 38.0
var dano := 20
var aviso := 0.8
var ativo := false

func configurar(novo_raio: float, novo_dano: int, novo_aviso: float) -> void:
	raio = novo_raio
	dano = novo_dano
	aviso = novo_aviso

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	z_index = 3
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = raio
	shape.shape = circle
	add_child(shape)
	queue_redraw()
	_disparar()

func _draw() -> void:
	var cor := Color(0.7, 0.08, 0.12, 0.22) if not ativo else Color(1.0, 0.22, 0.08, 0.72)
	draw_circle(Vector2.ZERO, raio, cor)
	draw_arc(Vector2.ZERO, raio, 0.0, TAU, 48, Color(1.0, 0.25, 0.15, 0.95), 2.5)
	if not ativo:
		draw_circle(Vector2.ZERO, raio * 0.28, Color(1.0, 0.45, 0.25, 0.42))

func _disparar() -> void:
	await get_tree().create_timer(aviso).timeout
	if not is_inside_tree():
		return
	ativo = true
	queue_redraw()
	for body in get_overlapping_bodies():
		if body.name == "Player" and body.has_method("tomar_dano"):
			body.tomar_dano(dano)
	await get_tree().create_timer(0.18).timeout
	queue_free()
