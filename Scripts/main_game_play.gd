extends Node2D

@onready var hud: CanvasLayer = $HUD

var level := 1
var fase_atual: Node = null
var trocando_de_fase := false
var fases: Dictionary = {}
var jogo_finalizado := false

func _ready() -> void:
	fase_atual = $LevelRoot
	fases[1] = fase_atual
	_configurar_fase(fase_atual)

func _configurar_fase(fase: Node) -> void:
	var jogador = fase.get_node_or_null("Player/Player")
	if jogador:
		jogador.vida = EstatisticasJogador.vida
		jogador.max_vida = EstatisticasJogador.max_vida
		jogador.vida_mudou.emit(jogador.vida)
		hud.set_player(jogador)
		if jogador.has_signal("morto") and not jogador.morto.is_connected(_jogador_morreu):
			jogador.morto.connect(_jogador_morreu)

	var saida = fase.get_node_or_null("Exit")
	if saida and not saida.body_entered.is_connected(_entrou_na_saida):
		saida.body_entered.connect(_entrou_na_saida)
	var voltar = fase.get_node_or_null("Back")
	if voltar and not voltar.body_entered.is_connected(_voltou_para_fase_anterior):
		voltar.body_entered.connect(_voltou_para_fase_anterior)
	if fase.has_signal("progresso"):
		var cb := Callable(self, "atualizar_texto_do_objetivo")
		if not fase.is_connected("progresso", cb):
			fase.connect("progresso", cb)
	if fase.has_signal("fase_final_concluida"):
		var cb_final := Callable(self, "_fase_final_concluida")
		if not fase.is_connected("fase_final_concluida", cb_final):
			fase.connect("fase_final_concluida", cb_final)
	if fase.has_method("objetivo_texto"):
		hud.atualiza_objetivo(fase.call("objetivo_texto"))

func atualizar_texto_do_objetivo(_faltando: int, _total: int) -> void:
	if is_instance_valid(fase_atual) and fase_atual.has_method("objetivo_texto"):
		hud.atualiza_objetivo(fase_atual.call("objetivo_texto"))

func carregar_fase(numero_da_fase: int) -> void:
	if numero_da_fase > 5:
		return
	if fases.has(numero_da_fase):
		if fase_atual:
			remove_child(fase_atual)
		fase_atual = fases[numero_da_fase]
		add_child(fase_atual)
		_configurar_fase(fase_atual)
		return
	var caminho := "res://scenes/Level/level_%s.tscn" % numero_da_fase
	var arquivo = load(caminho)
	if arquivo == null:
		push_error("Não foi possível carregar: " + caminho)
		trocando_de_fase = false
		return
	if fase_atual:
		remove_child(fase_atual)
	fase_atual = arquivo.instantiate()
	fase_atual.name = "LevelRoot"
	fases[numero_da_fase] = fase_atual
	add_child(fase_atual)
	_configurar_fase(fase_atual)

func _entrou_na_saida(body: Node2D) -> void:
	if body.name != "Player" or trocando_de_fase or jogo_finalizado:
		return
	if level >= 5:
		return
	if not fase_atual.call("pode_sair"):
		hud.atualiza_objetivo(fase_atual.call("mensagem_saida"))
		return
	trocando_de_fase = true
	level += 1
	EstatisticasJogador.fase_atual = level
	call_deferred("carregar_fase", level)
	await get_tree().create_timer(0.25).timeout
	trocando_de_fase = false

func _voltou_para_fase_anterior(body: Node2D) -> void:
	if body.name != "Player" or trocando_de_fase or level <= 1 or jogo_finalizado:
		return
	trocando_de_fase = true
	level -= 1
	EstatisticasJogador.fase_atual = level
	call_deferred("carregar_fase", level)
	await get_tree().create_timer(0.25).timeout
	trocando_de_fase = false

func _fase_final_concluida() -> void:
	if jogo_finalizado:
		return
	jogo_finalizado = true
	hud.atualiza_objetivo("RATÃO DERROTADO!")
	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.82)
	var canvas := CanvasLayer.new()
	canvas.layer = 50
	add_child(canvas)
	canvas.add_child(overlay)
	var texto := Label.new()
	texto.text = "RATÃO DERROTADO!\n\nVocê limpou os esgotos.\n\nVoltando ao menu..."
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texto.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	texto.add_theme_font_size_override("font_size", 28)
	overlay.add_child(texto)
	await get_tree().create_timer(3.5).timeout
	EstatisticasJogador.reset()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _jogador_morreu() -> void:
	if trocando_de_fase:
		return
	trocando_de_fase = true
	await get_tree().create_timer(0.8).timeout
	await hud.fade(1.0)
	EstatisticasJogador.reset()
	for numero in fases:
		var fase = fases[numero]
		if is_instance_valid(fase):
			fase.queue_free()
	fases.clear()
	fase_atual = null
	level = 1
	var arquivo = load("res://scenes/Level/level_1.tscn")
	if arquivo == null:
		push_error("Não foi possível recarregar a Fase 1.")
		await hud.fade(0.0)
		trocando_de_fase = false
		return
	fase_atual = arquivo.instantiate()
	fase_atual.name = "LevelRoot"
	fases[1] = fase_atual
	add_child(fase_atual)
	_configurar_fase(fase_atual)
	await hud.fade(0.0)
	trocando_de_fase = false
