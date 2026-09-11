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

var last_direction := Vector2.RIGHT
var is_hit := false
var hitbox_offset: Vector2
var forca := 100
var vivo := true
var max_vida: int
var vida: int
var dash_time := 0.0
var dash_cooldown := 0.0
var dash_direction := Vector2.RIGHT

func _ready() -> void:
	vida = EstatisticasJogador.vida
	max_vida = EstatisticasJogador.max_vida
	hitbox_offset = hitbox.position

func _physics_process(delta: float) -> void:
	if not vivo:
		return

	dash_cooldown = maxf(0.0, dash_cooldown - delta)

	if dash_time > 0.0:
		dash_time -= delta
		velocity = dash_direction * DASH_SPEED
		move_and_slide()
		return

	if Input.is_action_just_pressed("dash") and dash_cooldown <= 0.0 and not is_hit:
		_start_dash()
		return

	if Input.is_action_just_pressed("hit") and not is_hit:
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
	if not vivo or timer_invencibilidade.time_left > 0.0:
		return
	EstatisticasJogador.vida = maxi(0, EstatisticasJogador.vida - dano)
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
