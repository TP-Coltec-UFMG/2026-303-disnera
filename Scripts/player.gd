extends CharacterBody2D

signal vida_mudou(nova_vida: int)
signal morto

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var espada: AudioStreamPlayer2D = $Espada
@onready var hitbox: Area2D = $Hitbox
@onready var timer_invencibilidade: Timer = $"../TimerInvencibilidade"

const SPEED := 150.0
const DASH_SPEED := 390.0
const DASH_DURATION := 0.16
const DASH_COOLDOWN := 0.85

var combate_habilitado := true
var energia := 100.0
var carga_forte := 0.0
var aparo_tempo := 0.0
var aparo_recarga := 0.0
var combo := 0
var combo_tempo := 0.0
var efeito_tempo := 0.0
var aparou := false

var last_direction := Vector2.RIGHT
var is_hit := false
var hitbox_offset: Vector2
var forca := 28
var recarga := 0.0
var vivo := true
var max_vida: int
var vida: int
var dash_time := 0.0
var dash_cooldown := 0.0
var dash_direction := Vector2.RIGHT

func _ready() -> void:
	for entrada in [["ataque_forte", KEY_F], ["aparar", KEY_R]]:
		if not InputMap.has_action(entrada[0]):
			InputMap.add_action(entrada[0])
			var tecla := InputEventKey.new()
			tecla.physical_keycode = entrada[1]
			InputMap.action_add_event(entrada[0], tecla)
	vida = EstatisticasJogador.vida
	max_vida = EstatisticasJogador.max_vida
	hitbox_offset = hitbox.position

func _physics_process(delta: float) -> void:
	if not vivo:
		return

	energia = minf(100.0, energia + delta * 19.0)
	aparo_tempo = maxf(0.0, aparo_tempo - delta)
	aparo_recarga = maxf(0.0, aparo_recarga - delta)
	combo_tempo = maxf(0.0, combo_tempo - delta)
	efeito_tempo = maxf(0.0, efeito_tempo - delta)
	queue_redraw()
	if carga_forte > 0.0:
		carga_forte -= delta
		velocity = Vector2.ZERO
		if carga_forte <= 0.0:
			_soltar_forte()
		return
	if combate_habilitado and not EstatisticasJogador.epilogo:
		if Input.is_action_just_pressed("aparar"):
			aparar()
		if Input.is_action_just_pressed("ataque_forte") and iniciar_forte():
			return
	recarga = maxf(0.0, recarga - delta)
	dash_cooldown = maxf(0.0, dash_cooldown - delta)

	if dash_time > 0.0:
		dash_time -= delta
		velocity = dash_direction * DASH_SPEED
		move_and_slide()
		return

	if Input.is_action_just_pressed("dash") and dash_cooldown <= 0.0 and not is_hit:
		_start_dash()
		return

	if Input.is_action_just_pressed("hit") and not is_hit and recarga <= 0.0:
		hit()
		return

	if is_hit:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	process_movement()
	_process_animation()
	move_and_slide()

func _start_dash() -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	dash_direction = input_dir.normalized() if input_dir != Vector2.ZERO else last_direction.normalized()
	if dash_direction == Vector2.ZERO:
		dash_direction = Vector2.RIGHT
	last_direction = dash_direction
	dash_time = DASH_DURATION
	dash_cooldown = DASH_COOLDOWN
	# Pequena invulnerabilidade durante o dash.
	timer_invencibilidade.start(DASH_DURATION)

func process_movement() -> void:
	var direcao := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direcao != Vector2.ZERO:
		velocity = direcao * SPEED
		last_direction = direcao
		update_hitbox_offset()
	else:
		velocity = Vector2.ZERO

func _process_animation() -> void:
	if is_hit:
		return
	if velocity != Vector2.ZERO:
		play_animation("correr", last_direction)
	else:
		play_animation("parado", last_direction)

func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x != 0:
		animated_sprite_2d.flip_h = dir.x < 0
		animated_sprite_2d.play(prefix + "_right")
	elif dir.y < 0:
		animated_sprite_2d.play(prefix + "_up")
	elif dir.y > 0:
		animated_sprite_2d.play(prefix + "_down")

func hit() -> void:
	if EstatisticasJogador.epilogo or not combate_habilitado:
		return
	var dados: Dictionary = EstatisticasJogador.ARMAS[EstatisticasJogador.arma]
	combo = (combo % 3) + 1 if combo_tempo > 0 else 1
	combo_tempo = 1.2
	forca = int(dados.dano * (1.5 if combo == 3 else 1.0))
	recarga = float(dados.recarga)
	if EstatisticasJogador.arma == "Estilingue":
		var tiro = preload("res://scenes/poison_projectile.tscn").instantiate()
		tiro.set_script(preload("res://Scripts/player_projectile.gd"))
		tiro.configurar(last_direction, forca, 310.0)
		tiro.position = global_position + last_direction.normalized() * 20.0
		get_tree().current_scene.add_child(tiro)
		espada.play()
		return
	is_hit = true
	hitbox.monitoring = true
	espada.play()
	play_animation("ataque", last_direction)

func _on_animated_sprite_2d_animation_finished() -> void:
	if is_hit:
		is_hit = false
		hitbox.monitoring = false

func update_hitbox_offset() -> void:
	var x := hitbox_offset.x
	var y := hitbox_offset.y
	if absf(last_direction.x) >= absf(last_direction.y):
		hitbox.position = Vector2(x if last_direction.x >= 0 else -x, y)
	else:
		hitbox.position = Vector2(y, -x if last_direction.y < 0 else x)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_hit and body.has_method("take_damage"):
		body.take_damage(forca, global_position)

func tomar_dano(dano: int) -> void:
	if EstatisticasJogador.epilogo:
		return
	if aparo_tempo > 0.0:
		if not aparou:
			aparou = true
			energia = minf(100.0, energia + 12.0)
			efeito_tempo = 0.2
		return
	if not vivo or timer_invencibilidade.time_left > 0.0:
		return
	EstatisticasJogador.vida = maxi(0, EstatisticasJogador.vida - maxi(1, dano - (3 if EstatisticasJogador.protecao else 0)))
	vida = EstatisticasJogador.vida
	vida_mudou.emit(vida)
	if vida <= 0:
		morrer()
	else:
		timer_invencibilidade.start()

func curar(quantidade: int) -> bool:
	if not vivo or EstatisticasJogador.vida >= EstatisticasJogador.max_vida:
		return false
	EstatisticasJogador.vida = mini(EstatisticasJogador.max_vida, EstatisticasJogador.vida + quantidade)
	vida = EstatisticasJogador.vida
	vida_mudou.emit(vida)
	return true

func morrer() -> void:
	vivo = false
	velocity = Vector2.ZERO
	animated_sprite_2d.play("morrer")
	await animated_sprite_2d.animation_finished
	morto.emit()


func aparar() -> bool:
	if not combate_habilitado or EstatisticasJogador.epilogo or not vivo or is_hit or dash_time > 0 or carga_forte > 0 or aparo_recarga > 0 or energia < 20:
		return false
	energia -= 20
	aparo_tempo = 0.28
	aparo_recarga = 0.9
	aparou = false
	return true

func iniciar_forte() -> bool:
	if not combate_habilitado or EstatisticasJogador.epilogo or not vivo or is_hit or dash_time > 0 or recarga > 0 or energia < 35:
		return false
	energia -= 35
	carga_forte = 0.4
	return true

func _soltar_forte() -> void:
	recarga = 0.9
	efeito_tempo = 0.25
	espada.play()
	var dano := int(EstatisticasJogador.ARMAS[EstatisticasJogador.arma].dano * 1.8)
	if EstatisticasJogador.arma == "Estilingue":
		for angulo in [-0.18, 0.0, 0.18]:
			var tiro = preload("res://scenes/poison_projectile.tscn").instantiate()
			tiro.set_script(preload("res://Scripts/player_projectile.gd"))
			tiro.configurar(last_direction.rotated(angulo), dano / 2, 310.0)
			tiro.position = global_position + last_direction * 20
			get_tree().current_scene.add_child(tiro)
	else:
		for inimigo in get_tree().current_scene.find_children("*", "CharacterBody2D", true, false):
			if not inimigo.has_method("take_damage"):
				continue
			var offset: Vector2 = inimigo.global_position - global_position
			if offset.length() <= 95 and (offset.length() < 25 or last_direction.normalized().dot(offset.normalized()) > -0.1):
				var consulta := PhysicsRayQueryParameters2D.create(global_position, inimigo.global_position, 2)
				if get_world_2d().direct_space_state.intersect_ray(consulta).is_empty():
					inimigo.take_damage(dano, global_position)

func _draw() -> void:
	if not combate_habilitado or EstatisticasJogador.epilogo:
		return
	if carga_forte > 0 or efeito_tempo > 0:
		draw_arc(Vector2.ZERO, 38, last_direction.angle()-1.3, last_direction.angle()+1.3, 12, Color("edc370"), 3)
	if aparo_tempo > 0:
		draw_arc(Vector2.ZERO, 25, 0, TAU, 20, Color("99d5cf"), 3)
