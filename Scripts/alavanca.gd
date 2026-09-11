extends Area2D

signal ativada

@onready var sprite: Sprite2D = $Sprite2D
@onready var prompt_e: Control = get_node_or_null("PromptE")

const TEXTURA_DESATIVADA = preload("res://Imagens/AlavancaDesativada.png")
const TEXTURA_ATIVADA = preload("res://Imagens/AlavancaAtivada.png")

var ligada: bool = false
var jogador_perto: bool = false


func _process(_delta: float) -> void:
	if jogador_perto and Input.is_action_just_pressed("interact"):
		ativar()


func ativar() -> void:
	ligada = not ligada

	if ligada:
		sprite.texture = TEXTURA_ATIVADA
		print(name, " ATIVADA")
	else:
		sprite.texture = TEXTURA_DESATIVADA
		print(name, " DESATIVADA")

	# Informa ao level_2.gd que houve mudança
	ativada.emit()


func resetar() -> void:
	ligada = false
	sprite.texture = TEXTURA_DESATIVADA


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		jogador_perto = true
		if prompt_e:
			prompt_e.visible = true
		print("Jogador está perto da ", name)


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		jogador_perto = false
		if prompt_e:
			prompt_e.visible = false
		print("Jogador saiu da ", name)
