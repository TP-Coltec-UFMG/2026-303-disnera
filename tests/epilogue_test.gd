extends Node
const NPC = preload("res://Scripts/school_npc.gd")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("run")

func run() -> void:
	EstatisticasJogador.reset()
	EstatisticasJogador.nome = "Teste"
	var jogo = load("res://scenes/main_game_play.tscn").instantiate()
	get_tree().root.add_child(jogo)
	get_tree().current_scene = jogo
	await get_tree().process_frame
	jogo.level = 5
	jogo.carregar_fase(5)
	await get_tree().process_frame
	var chefes = jogo.fase_atual.find_children("*", "CharacterBody2D", true, false).filter(func(n): return n.has_signal("derrotado"))
	assert(chefes.size() == 1)
	chefes[0].die()
	await get_tree().create_timer(2.0).timeout
	var escola = get_tree().current_scene
	assert(escola.scene_file_path == "res://scenes/coltec.tscn")
	assert(EstatisticasJogador.epilogo and escola.epilogo)
	assert(EstatisticasJogador.nome == "Teste")
	assert(EstatisticasJogador.vida == EstatisticasJogador.max_vida)
	escola.painel.fechar()
	for local in ["Hall", "Laboratório", "Laboratório da turma", "Exterior", "Quadra"]:
		escola.mudar_local(local)
		await get_tree().process_frame
		assert(not escola.banda.playing)
		assert(escola.clima.som.playing)
		assert(escola.clima.exterior == (local in ["Exterior", "Quadra"]))
		assert(escola.pontos.all(func(n): return not n is NPC))
		assert(escola.pontos.all(func(n): return n.titulo != "Túnel do esgoto"))
	var m = escola.memorias
	var moedas = EstatisticasJogador.moedas
	m.iniciar("coltec")
	m.escolher_papel(2)
	assert(escola.painel.conteudo.text.contains("datas"))
	m.iniciar("coltec")
	for i in range(3):
		m.escolher_papel(i)
	assert(EstatisticasJogador.feitos.has("epilogo_coltec"))
	var registros = EstatisticasJogador.diario.size()
	m.concluir()
	assert(EstatisticasJogador.diario.size() == registros)
	m.iniciar("melodia")
	await get_tree().create_timer(3.6).timeout
	for n in m.ordem.duplicate():
		m.tocar(n)
	assert(EstatisticasJogador.feitos.has("epilogo_melodia"))
	m.iniciar("disnara")
	for valor in range(3):
		for i in range(m.cartas.size()):
			if m.cartas[i] == valor:
				m.virar(i)
	assert(EstatisticasJogador.feitos.has("epilogo_disnara"))
	assert(EstatisticasJogador.moedas == moedas)
	m.iniciar("melodia")
	escola.painel.fechar()
	escola.painel.mochila()
	var texto = escola.painel.conteudo.text
	await get_tree().create_timer(3.6).timeout
	assert(escola.painel.conteudo.text == texto)
	escola.painel.fechar()
	escola.queue_free()
	await get_tree().process_frame
	EstatisticasJogador.reset()
	assert(not EstatisticasJogador.epilogo)
	escola = load("res://scenes/coltec.tscn").instantiate()
	add_child(escola)
	escola.painel.fechar()
	escola.mudar_local("Hall")
	var nomes = escola.pontos.filter(func(n): return n is NPC and not n.tocando).map(func(n): return n.titulo)
	nomes.sort()
	assert(nomes == ["Duda", "PH", "Pedro Silva Freitas", "Saci", "Tigas"])
	escola.mudar_local("Hall")
	assert(escola.banda.playing and not escola.clima.ativo)
	escola.queue_free()
	await get_tree().process_frame
	print("PASS: morte do Ratão, retorno automático, escola vazia, chuva, três memórias, diário sem duplicação, cancelamento e cinco nomes")
	get_tree().quit()
