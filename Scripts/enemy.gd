extends CharacterBody2D

@export var speed := 75.0
@export var vida_max := 40
@export var forca := 8
@export var attack_interval := 0.9
@export var knockback_force := 230.0
@export var stun_time := 0.16
@export var boss := false

var vida: int
var target: Node2D = null
var stunned := false
var morto := false
var area_de_dano := false

@onready var animated_sprite_2d: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var take_damage_sound: AudioStreamPlayer2D = get_node_or_null("TakeDamage")
@onready var barradevida: Node2D = get_node_or_null("Barradevida")
@onready var timer_ataque: Timer = get_node_or_null("../TimerAtaque")

func _ready() -> void:
	vida = vida_max
	if timer_ataque:
		timer_ataque.wait_time = attack_interval
	if barradevida:
		barradevida.update_vida(100)

func _physics_process(_delta: float) -> void:
	if morto:
		return
	if stunned:
		move_and_slide()
		return
	if is_instance_valid(target):
		var direction := (target.global_position - global_position).normalized()
		velocity = direction * speed
		if animated_sprite_2d:
			if absf(direction.x) > 0.1:
				animated_sprite_2d.flip_h = direction.x < 0
			animated_sprite_2d.play("Rato")
	else:
		velocity = Vector2.ZERO
		if animated_sprite_2d:
			animated_sprite_2d.pause()
	move_and_slide()

func take_damage(dano: int, attacker_position: Vector2) -> void:
	if morto:
		return
	vida -= dano
	if barradevida:
		barradevida.update_vida(roundi((float(vida) / float(vida_max)) * 100.0))
	if take_damage_sound:
		take_damage_sound.play()
	if vida <= 0:
		die()
		return
	stunned = true
	var knockback_direction := (global_position - attacker_position).normalized()
	velocity = knockback_direction * knockback_force
	move_and_slide()
	await get_tree().create_timer(stun_time).timeout
	if not morto:
		velocity = Vector2.ZERO
		stunned = false

func die() -> void:
	morto = true
	queue_free()

func _on_sight_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target = body

func _on_sight_body_exited(body: Node2D) -> void:
	if body == target:
		target = null

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		area_de_dano = true
		target = body
		body.tomar_dano(forca)
		if timer_ataque:
			timer_ataque.start()

func _on_timer_ataque_timeout() -> void:
	if area_de_dano and is_instance_valid(target):
		target.tomar_dano(forca)

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		area_de_dano = false
		if timer_ataque:
			timer_ataque.stop()
