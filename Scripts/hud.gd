extends CanvasLayer

const CORACAO_SIZE: int = 20
var player

const CORACAO_FULL = preload("res://Imagens/UI/Heart_cheio.png")
const CORACAO_METADE = preload("res://Imagens/UI/Heart_metade.png")
const CORACAO_VAZIO = preload("res://Imagens/UI/Heart_vazio.png")

@onready var fadeOut: ColorRect = $FadeOut
@onready var hearts_container: HBoxContainer = $Coracao
@onready var objetivo_label: Label = $ObjetivoPanel/Objetivo


func set_player(player):
	self.player = player

	if not player.vida_mudou.is_connected(_update_vida):
		player.vida_mudou.connect(_update_vida)

	_update_vida(player.vida)
		
func _update_vida(nova_vida: int) -> void:
	var coracoes = hearts_container.get_children()
	var max_coracoes = len(coracoes)
	var full = int(nova_vida / CORACAO_SIZE)
	var metade = 1 if(nova_vida % CORACAO_SIZE) > 0 else 0
	var vazio = max_coracoes - (full + metade)
	
	for i in full:
		coracoes[i].texture = CORACAO_FULL
	if metade:
		coracoes[full].texture = CORACAO_METADE
	for i in vazio:
		coracoes[len(coracoes) - 1 - i].texture = CORACAO_VAZIO
	
func atualiza_objetivo(texto: String) -> void:
	objetivo_label.text = texto

func fade(to_alpha: float) -> void:
	var tween:= create_tween()
	tween.tween_property(fadeOut, "modulate:a", to_alpha, 1.5)
	await tween.finished
