extends "res://Scripts/level_root.gd"

@onready var alavanca1: Area2D = $Alavanca
@onready var alavanca2: Area2D = $Alavanca2
@onready var alavanca3: Area2D = $Alavanca3

var combinacao_correta: Array[bool] = [true, false, true]
var puzzle_resolvido: bool = false


func _ready() -> void:
	super._ready()

	if not alavanca1.ativada.is_connected(_verificar_puzzle):
		alavanca1.ativada.connect(_verificar_puzzle)

	if not alavanca2.ativada.is_connected(_verificar_puzzle):
		alavanca2.ativada.connect(_verificar_puzzle)

	if not alavanca3.ativada.is_connected(_verificar_puzzle):
		alavanca3.ativada.connect(_verificar_puzzle)

	print("Puzzle iniciado!")
	print("Combinação correta: ON - OFF - ON")
	
func _verificar_puzzle() -> void:
	if puzzle_resolvido:
		return

	var estado_atual: Array[bool] = [
		alavanca1.ligada,
		alavanca2.ligada,
		alavanca3.ligada
	]

	print("Estado atual: ", estado_atual)

	if estado_atual == combinacao_correta:
		puzzle_resolvido = true

		print("PUZZLE RESOLVIDO!")
	else:
		print("Combinação incorreta.")

func pode_sair() -> bool:
	return super.pode_sair() and puzzle_resolvido

func objetivo_texto() -> String:
	if not super.pode_sair():
		return super.objetivo_texto()
	if not puzzle_resolvido:
		return "Ache a combinação correta das alavancas"

	return "PORTÃO LIBERADO!\nVá até a saída."
