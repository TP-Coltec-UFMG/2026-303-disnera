extends Node2D

@onready var hud: CanvasLayer = $HUD

var painel: CanvasLayer
var level := 1
var fase_atual: Node = null
var trocando_de_fase := false
var fases: Dictionary = {}
var jogo_finalizado := false

func _ready() -> void:
	painel = preload("res://Scripts/adventure_panel.gd").new()
	add_child(painel)
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
		painel.jogador = jogador
		painel.local_atual = "Esgotos / setor %d" % level
		if not fase.has_node("Refugio"):
			var abrigo = preload("res://Scripts/adventure_point.gd").new()
			abrigo.name = "Refugio"
			abrigo.titulo = "Refúgio / oficina"
			abrigo.position = jogador.global_position + Vector2(55, 0)
			abrigo.jogador = jogador
			abrigo.acao = _abrir_refugio
			abrigo.disponivel = fase.sala_limpa
			fase.add_child(abrigo)
		if jogador.has_signal("morto") and not jogador.morto.is_connected(_jogador_morreu):
			jogador.morto.connect(_jogador_morreu)

	for inimigo in fase.find_children("*", "CharacterBody2D", true, false):
		if inimigo.has_signal("derrotado") and not inimigo.derrotado.is_connected(_fase_final_concluida):
			inimigo.derrotado.connect(_fase_final_concluida)

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
	trocando_de_fase = true
	painel.fechar()
	fase_atual.process_mode = Node.PROCESS_MODE_DISABLED
	EstatisticasJogador.iniciar_epilogo()
	hud.atualiza_objetivo("O barulho parou. Você reconhece o caminho de volta.")
	await hud.fade(1.0)
	get_tree().change_scene_to_file("res://scenes/coltec.tscn")

func _jogador_morreu() -> void:
	if trocando_de_fase or jogo_finalizado:
		return
	trocando_de_fase = true
	await get_tree().create_timer(0.8).timeout
	await hud.fade(1.0)
	# Retorna ao refúgio da fase atual, preservando compras e memórias.
	EstatisticasJogador.vida = EstatisticasJogador.max_vida
	var perdida: Node = fase_atual
	fases.erase(level)
	remove_child(perdida)
	perdida.queue_free()
	fase_atual = null
	carregar_fase(level)
	fase_atual.process_mode = Node.PROCESS_MODE_DISABLED
	await hud.fade(0.0)
	fase_atual.process_mode = Node.PROCESS_MODE_INHERIT
	trocando_de_fase = false

func _abrir_refugio() -> void:
	if not is_instance_valid(fase_atual) or not fase_atual.sala_limpa() or jogo_finalizado:
		return
	painel.abrir("Refúgio · setor %d" % level, "Um intervalo entre os túneis. Ao morrer, você retorna à entrada deste setor com seus equipamentos e memórias.\nA cura do refúgio pode ser usada uma vez por setor.")
	painel.botao("Descansar", func():
		var id := "descanso_%d" % level
		if not EstatisticasJogador.feitos.has(id) and painel.jogador.curar(100):
			EstatisticasJogador.registrar(id, "Encontrei um refúgio no setor %d." % level)
		painel.fechar())
	painel.botao("Oficina / loja", painel.loja)
	painel.botao("Ouvir o rato albino", func(): painel.conversar("Rato albino"))
	painel.botao("Mochila e diário", painel.mochila)
	painel.botao("Seguir", painel.fechar)

func _exit_tree() -> void:
	# Fases visitadas ficam fora da árvore; liberar também essas instâncias.
	for fase in fases.values():
		if is_instance_valid(fase) and not fase.is_inside_tree():
			fase.free()
