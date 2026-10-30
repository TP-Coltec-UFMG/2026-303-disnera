extends "res://Scripts/rato.gd"

const PROJETIL = preload("res://scenes/poison_projectile.tscn")

@export var distancia_ideal := 190.0
@export var distancia_minima := 145.0
@export var alcance_tiro := 300.0
@export var cooldown_tiro := 2.00
@export var velocidade_projetil := 200.0
@export var dano_projetil := 5

var preparando := false
var aviso_tempo := 0.0
var direcao_tiro := Vector2.RIGHT
var rajadas := 0
var tiro_tempo := 0.7
var strafe_sign := 1.0

func _physics_process(delta: float) -> void:
	if morto:
		return
	tiro_tempo = maxf(0.0, tiro_tempo - delta)
	if stunned:
		preparando = false
		tiro_tempo = maxf(tiro_tempo, 0.7)
		queue_redraw()
		move_and_slide()
		return
	if not is_instance_valid(target):
		preparando = false
		queue_redraw()
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var to_player := target.global_position - global_position
	var distancia := to_player.length()
	var dir := to_player.normalized()
	if distancia < distancia_minima:
		velocity = -dir * speed * 1.15
	elif distancia > distancia_ideal + 45.0:
		velocity = dir * speed
	else:
		var lateral := Vector2(-dir.y, dir.x) * strafe_sign
		velocity = lateral * speed * 0.55

	if preparando:
		velocity = Vector2.ZERO
		aviso_tempo -= delta
		if aviso_tempo <= 0.0:
			preparando = false
			rajadas += 1
			if rajadas % 2 == 0:
				for angulo in [-0.24, 0.0, 0.24]:
					_atirar(direcao_tiro.rotated(angulo))
			else:
				_atirar(direcao_tiro)
			tiro_tempo = cooldown_tiro
			strafe_sign *= -1.0
	elif tiro_tempo <= 0.0 and distancia <= alcance_tiro:
		preparando = true
		aviso_tempo = 0.65
		direcao_tiro = dir
	queue_redraw()

	if animated_sprite_2d and absf(velocity.x) > 0.1:
		animated_sprite_2d.flip_h = velocity.x < 0
	move_and_slide()

func _atirar(dir: Vector2) -> void:
	var tiro := PROJETIL.instantiate()
	_world_parent().add_child(tiro)
	tiro.global_position = global_position + dir * 28.0
	tiro.configurar(dir, dano_projetil, velocidade_projetil)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target = body

func _on_timer_ataque_timeout() -> void:
	pass

func _on_hitbox_body_exited(_body: Node2D) -> void:
	pass


func _ready() -> void:
	super._ready()
	for child in get_children():
		if child is Polygon2D or child is Line2D:
			child.hide()
	var arte = preload("res://Scripts/enemy_pixel_art.gd").new()
	arte.especie = "escorpiao"
	add_child(arte)


func _draw() -> void:
	if preparando and not morto:
		for angulo in ([-0.24, 0.0, 0.24] if (rajadas + 1) % 2 == 0 else [0.0]):
			draw_line(Vector2.ZERO, direcao_tiro.rotated(angulo) * 100, Color(0.8,0.9,0.4,0.55), 2)
