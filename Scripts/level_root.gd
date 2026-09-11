extends Node2D

signal progresso(inimigos_faltando: int, inimigos_total: int)
signal fase_final_concluida

@export var final_level := false

var _inimigo_nodes: Array[Node] = []
var _inimigos_faltando := 0
var _inimigos_total := 0
var _progresso_pronto := false
var _final_emitido := false

func _ready() -> void:
	call_deferred("_setup_progresso")

func _setup_progresso() -> void:
	var conteiner_inimigos := get_node_or_null("Enemies")
	if conteiner_inimigos == null:
		push_error("O nó Enemies não foi encontrado na fase.")
		return
	_inimigo_nodes = conteiner_inimigos.find_children("*", "CharacterBody2D", true, false)
	_inimigos_total = _inimigo_nodes.size()
	var callback := Callable(self, "_on_enemy_removed")
	for inimigo in _inimigo_nodes:
		if not inimigo.tree_exited.is_connected(callback):
			inimigo.tree_exited.connect(callback)
	_progresso_pronto = true
	_atualizar_progresso()

func _on_enemy_removed() -> void:
	call_deferred("_atualizar_progresso")

func _atualizar_progresso() -> void:
	_inimigos_faltando = 0
	for inimigo in _inimigo_nodes:
		if is_instance_valid(inimigo) and not inimigo.is_queued_for_deletion():
			_inimigos_faltando += 1
	progresso.emit(_inimigos_faltando, _inimigos_total)
	if final_level and _progresso_pronto and _inimigos_faltando == 0 and not _final_emitido:
		_final_emitido = true
		fase_final_concluida.emit()

func pode_sair() -> bool:
	return _progresso_pronto and _inimigos_faltando == 0

func objetivo_texto() -> String:
	if final_level:
		if pode_sair():
			return "RATÃO DERROTADO!"
		return "Derrote o RATÃO!"
	if pode_sair():
		return "PORTÃO LIBERADO!\nVá até a saída."
	return "Inimigos faltando: %d" % _inimigos_faltando

func mensagem_saida() -> String:
	if _inimigos_faltando > 0:
		return "Ainda faltam %d inimigo(s)." % _inimigos_faltando
	return ""
