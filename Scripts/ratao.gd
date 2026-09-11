extends "res://Scripts/rato.gd"

const METEOR_ZONE = preload("res://Scripts/attack_zone.gd")
const BREATH_ZONE = preload("res://Scripts/poison_breath_zone.gd")

@export var cooldown_especial := 1.8
@export var dano_meteoro := 0
@export var dano_baforada := 0

var especial_tempo := 1.0
var conjurando := false
var alternar_especial := false

func _physics_process(delta: float) -> void:
	if morto:
		return
	especial_tempo = maxf(0.0, especial_tempo - delta)
	if stunned:
		move_and_slide()
		return
	if not is_instance_valid(target):
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if conjurando:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var to_player := target.global_position - global_position
	var distancia := to_player.length()
	var dir := to_player.normalized()
	if distancia > 72.0:
		velocity = dir * speed
	else:
		velocity = Vector2.ZERO

	if animated_sprite_2d and absf(dir.x) > 0.1:
		animated_sprite_2d.flip_h = dir.x < 0

	if especial_tempo <= 0.0:
		alternar_especial = not alternar_especial
		if alternar_especial:
			call_deferred("_ataque_meteoros")
		else:
			call_deferred("_ataque_baforada")
		var fase_feroz := vida <= int(vida_max * 0.5)
		especial_tempo = 1.35 if fase_feroz else cooldown_especial
	move_and_slide()

func _ataque_meteoros() -> void:
	if conjurando or morto or not is_instance_valid(target):
		return
	conjurando = true
	var quantidade := 6 if vida <= int(vida_max * 0.5) else 4
	for i in range(quantidade):
		var zona := METEOR_ZONE.new()
		zona.configurar(38.0, dano_meteoro, 0.8)
		_world_parent().add_child(zona)
		var dispersao := Vector2(randf_range(-115.0, 115.0), randf_range(-95.0, 95.0))
		if i == 0:
			dispersao = Vector2.ZERO
		zona.global_position = target.global_position + dispersao
	await get_tree().create_timer(0.92).timeout
	conjurando = false

func _ataque_baforada() -> void:
	if conjurando or morto or not is_instance_valid(target):
		return
	conjurando = true
	var dir := (target.global_position - global_position).normalized()
	var zona := BREATH_ZONE.new()
	zona.configurar(270.0, deg_to_rad(68.0), dano_baforada, 0.72)
	_world_parent().add_child(zona)
	zona.global_position = global_position
	zona.rotation = dir.angle()
	await get_tree().create_timer(0.82).timeout
	conjurando = false
