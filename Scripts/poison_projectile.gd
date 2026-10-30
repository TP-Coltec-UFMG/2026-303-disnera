extends Area2D

@export var velocidade := 220.0
@export var dano := 12
@export var tempo_de_vida := 4.0

var direcao := Vector2.RIGHT
var ativo := true

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func configurar(nova_direcao: Vector2, novo_dano: int, nova_velocidade: float) -> void:
	direcao = nova_direcao.normalized()
	dano = novo_dano
	velocidade = nova_velocidade
	rotation = direcao.angle()

func _physics_process(delta: float) -> void:
	if not ativo:
		return
	global_position += direcao * velocidade * delta
	tempo_de_vida -= delta
	if tempo_de_vida <= 0.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if not ativo:
		return
	if body.name == "Player" and body.has_method("tomar_dano"):
		ativo = false
		body.tomar_dano(dano)
		queue_free()
	else:
		ativo = false
		queue_free()
