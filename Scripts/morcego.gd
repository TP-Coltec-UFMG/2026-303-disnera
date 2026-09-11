extends "res://Scripts/rato.gd"

@export var distancia_voo := 125.0
@export var velocidade_mergulho := 330.0
@export var tempo_aviso := 0.32
@export var duracao_mergulho := 0.38
@export var recuperacao := 0.62
@export var intervalo_mergulho := 1.25

const VOANDO := 0
const AVISANDO := 1
const MERGULHANDO := 2
const RECUPERANDO := 3

var estado := VOANDO
var estado_tempo := 0.0
var cooldown_mergulho := 0.7
var direcao_mergulho := Vector2.RIGHT
var acertou_no_mergulho := false
var orbit_phase := 0.0

@onready var silhueta: CanvasItem = get_node_or_null("SilhuetaMorcego")

func _physics_process(delta: float) -> void:
	if morto:
		return
	cooldown_mergulho = maxf(0.0, cooldown_mergulho - delta)
	orbit_phase += delta * 2.2
	if stunned:
		move_and_slide()
		return
	if not is_instance_valid(target):
		velocity = Vector2.ZERO
		move_and_slide()
		return

	match estado:
		VOANDO:
			_voar_perto(delta)
			if cooldown_mergulho <= 0.0 and global_position.distance_to(target.global_position) < 230.0:
				estado = AVISANDO
				estado_tempo = tempo_aviso
				velocity = Vector2.ZERO
		AVISANDO:
			velocity = Vector2.ZERO
			if silhueta:
				silhueta.modulate = Color(1.35, 0.65, 0.75, 1.0)
			estado_tempo -= delta
			if estado_tempo <= 0.0:
				direcao_mergulho = (target.global_position - global_position).normalized()
				if direcao_mergulho == Vector2.ZERO:
					direcao_mergulho = Vector2.RIGHT
				acertou_no_mergulho = false
				if silhueta:
					silhueta.modulate = Color.WHITE
				estado = MERGULHANDO
				estado_tempo = duracao_mergulho
		MERGULHANDO:
			velocity = direcao_mergulho * velocidade_mergulho
			estado_tempo -= delta
			if not acertou_no_mergulho and global_position.distance_to(target.global_position) < 34.0:
				target.tomar_dano(forca)
				acertou_no_mergulho = true
			if estado_tempo <= 0.0:
				estado = RECUPERANDO
				estado_tempo = recuperacao
		RECUPERANDO:
			var fuga := (global_position - target.global_position).normalized()
			velocity = fuga * speed * 1.25
			estado_tempo -= delta
			if estado_tempo <= 0.0:
				estado = VOANDO
				if silhueta:
					silhueta.modulate = Color.WHITE
				cooldown_mergulho = intervalo_mergulho

	if animated_sprite_2d and absf(velocity.x) > 0.1:
		animated_sprite_2d.flip_h = velocity.x < 0
	move_and_slide()

func _voar_perto(_delta: float) -> void:
	var offset := Vector2(cos(orbit_phase), sin(orbit_phase * 0.85)) * distancia_voo
	var destino := target.global_position + offset
	var direcao := (destino - global_position).normalized()
	velocity = direcao * speed

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target = body
		if estado == MERGULHANDO and not acertou_no_mergulho:
			body.tomar_dano(forca)
			acertou_no_mergulho = true

func _on_timer_ataque_timeout() -> void:
	pass

func _on_hitbox_body_exited(_body: Node2D) -> void:
	pass
