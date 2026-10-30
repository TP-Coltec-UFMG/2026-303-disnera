extends Node
const NPC = preload("res://Scripts/school_npc.gd")
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("run")
func run() -> void:
	EstatisticasJogador.reset()
	var escola = load("res://scenes/coltec.tscn").instantiate()
	add_child(escola)
	escola.painel.fechar()
	assert(escola.pontos.filter(func(n): return n is NPC and n.tocando).all(func(n): return n.titulo == "Toquempé"))
	escola.mudar_local("Laboratório da turma")
	var turma: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/turma.json"))
	var alunos = escola.pontos.filter(func(n): return n is NPC and n.titulo != "Leando Maia")
	assert(alunos.size() == turma.size() and turma.size() == 38)
	for aluno in alunos:
		assert(aluno.titulo in turma)
		escola.jogador.global_position = aluno.global_position
		assert(aluno.mais_proximo())
		aluno.acao.call()
		assert(escola.painel.titulo.text == aluno.titulo)
		escola.painel.fechar()
	escola.mudar_local("Hall")
	assert(escola.pontos.filter(func(n): return n is NPC and not n.tocando).size() == 5)
	for p in escola.pontos:
		if p is NPC and not p.tocando:
			assert(not p.tocando and not p.rota.is_empty())
	escola.mudar_local("Quadra")
	var futebol = escola.decoracao.get_children().filter(func(n): return n.get_script() == preload("res://Scripts/football.gd"))[0]
	var moedas = EstatisticasJogador.moedas
	futebol.iniciar()
	for i in range(5):
		futebol.defesa_rival = 0
		futebol.mira = 1
		futebol.forca = 0.7
		futebol.chutar()
		assert(futebol.fase == "defesa")
		seed(303)
		var lado = randi_range(0,2)
		seed(303)
		futebol.defender(lado)
		if i < 4:
			futebol.preparar_chute()
	assert(futebol.gols == 5 and futebol.rival == 0)
	futebol.terminar()
	assert(EstatisticasJogador.moedas == moedas + 15)
	futebol.terminar()
	assert(EstatisticasJogador.moedas == moedas + 15)
	escola.painel.fechar()
	escola.queue_free()
	await get_tree().process_frame
	var jogo = load("res://scenes/main_game_play.tscn").instantiate()
	get_tree().root.add_child(jogo)
	get_tree().current_scene = jogo
	await get_tree().physics_frame
	var player = jogo.painel.jogador
	player.set_physics_process(false)
	player.timer_invencibilidade.stop()
	var hp = EstatisticasJogador.vida
	assert(player.aparar())
	player.tomar_dano(20)
	assert(EstatisticasJogador.vida == hp and player.aparou)
	assert(not player.aparar())
	player.aparo_tempo = 0
	player.tomar_dano(10)
	assert(EstatisticasJogador.vida == hp - 10)
	for i in range(3):
		player.is_hit = false
		player.hit()
	assert(player.combo == 3 and player.forca == 42)
	player.is_hit = false
	player.recarga = 0
	player.energia = 34
	assert(not player.iniciar_forte())
	player.energia = 100
	assert(player.iniciar_forte() and player.energia == 65)
	player.carga_forte = 0
	var alvo = load("res://scenes/escorpiao.tscn").instantiate()
	jogo.add_child(alvo)
	var alvo_corpo = alvo.get_node("Escorpiao")
	alvo_corpo.set_physics_process(false)
	alvo_corpo.global_position = player.global_position + Vector2(35,0)
	player.last_direction = Vector2.RIGHT
	var vida_alvo = alvo_corpo.vida
	player._soltar_forte()
	assert(alvo_corpo.vida < vida_alvo)
	assert(player.recarga == 0.9)
	alvo.queue_free()
	EstatisticasJogador.arma = "Estilingue"
	player._soltar_forte()
	var tiros = jogo.get_children().filter(func(n): return n.get_script() == preload("res://Scripts/player_projectile.gd"))
	assert(tiros.size() == 3)
	assert(tiros[0].direcao != tiros[1].direcao and tiros[1].direcao != tiros[2].direcao)
	EstatisticasJogador.arma = "Caco"
	var esc = load("res://scenes/escorpiao.tscn").instantiate()
	jogo.add_child(esc)
	var corpo = esc.get_node("Escorpiao")
	corpo.set_physics_process(false)
	corpo.target = player
	corpo.global_position = player.global_position + Vector2(100,0)
	corpo.tiro_tempo = 0
	corpo._physics_process(0.01)
	assert(corpo.preparando)
	corpo._physics_process(0.7)
	assert(not corpo.preparando and corpo.rajadas == 1)
	corpo.tiro_tempo = 0
	corpo._physics_process(0.01)
	corpo.stunned = true
	corpo._physics_process(0.01)
	assert(not corpo.preparando)
	var bat = load("res://scenes/morcego.tscn").instantiate()
	jogo.add_child(bat)
	var morcego = bat.get_node("Morcego")
	morcego.set_physics_process(false)
	morcego.target = player
	morcego.global_position = player.global_position + Vector2(100,0)
	morcego.cooldown_mergulho = 0
	morcego._physics_process(0.01)
	assert(morcego.estado == morcego.AVISANDO)
	var direcao = morcego.direcao_mergulho
	player.global_position += Vector2(0,50)
	morcego._physics_process(0.4)
	assert(morcego.direcao_mergulho == direcao)
	jogo.queue_free()
	await get_tree().process_frame
	await get_tree().create_timer(1.0).timeout
	print("PASS: 38 alunos acessíveis, 5 amigos andando, Toquempé, pênaltis e recompensa única, combo, energia, aparo, forte, avisos e interrupção dos inimigos")
	get_tree().quit()
