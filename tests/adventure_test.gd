extends Node

func _ready() -> void:
	call_deferred("run")

func run() -> void:
	EstatisticasJogador.reset()
	var escola = load("res://scenes/coltec.tscn").instantiate()
	add_child(escola)
	escola.painel.fechar()
	assert(escola.local == "Hall")
	assert(escola.pontos.size() == 12)
	assert(escola.banda.playing)
	await get_tree().physics_frame
	escola.jogador.global_position = Vector2(480, 300)
	var colisao = escola.jogador.move_and_collide(Vector2(0, -200))
	assert(colisao != null)
	assert(escola.jogador.global_position.y >= 185)
	escola.jogador.global_position = Vector2(160, 300)
	assert(escola.jogador.move_and_collide(Vector2(-200, 0)) != null)
	assert(escola.jogador.global_position.x >= 50)
	escola.jogador.global_position = Vector2(480, 490)
	escola.mudar_local("Hall")
	var lia = escola.pontos.filter(func(p): return p.titulo == "Duda")[0]
	assert(lia.sprite is AnimatedSprite2D)
	assert(lia.sprite.sprite_frames == escola.jogador.get_node("AnimatedSprite2D").sprite_frames)
	assert(lia.sprite.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST)
	lia._animar(true, Vector2.UP)
	assert(lia.sprite.animation == "correr_up")
	lia._animar(true, Vector2.LEFT)
	assert(lia.sprite.flip_h)
	var origem: Vector2 = lia.position
	lia._physics_process(0.2)
	lia._physics_process(1.0)
	lia._physics_process(1.0)
	assert(lia.position.distance_to(origem) > 5)
	escola.mudar_local("Hall")
	var porta = escola.pontos.filter(func(p): return p.titulo == "Laboratório da turma")[0]
	escola.jogador.global_position = porta.global_position + Vector2(0, 20)
	var e := InputEventAction.new()
	e.action = "interact"
	e.pressed = true
	porta._unhandled_input(e)
	await get_tree().process_frame
	assert(escola.local == "Laboratório da turma")
	assert(not escola.banda.playing)
	escola.mudar_local("Quadra")
	assert(escola.pontos.any(func(p): return p.titulo == "Voltar à escola"))
	escola.pontos.filter(func(p): return p.titulo == "Voltar à escola")[0].acao.call()
	assert(escola.local == "Exterior")
	assert(escola.pontos.any(func(p): return p.titulo == "Túnel do esgoto"))
	escola.descer()
	assert(escola.painel.conteudo.text.contains("alagada"))
	escola.painel.fechar()
	escola.mudar_local("Laboratório")
	escola.painel.circuito()
	# Solução: girar 3 e 4 (índices 2 e 3).
	escola.painel.lista.get_child(5).pressed.emit()
	escola.painel.lista.get_child(4).pressed.emit()
	assert(EstatisticasJogador.feitos.has("drenagem"))
	escola.painel.fechar()
	escola.mudar_local("Exterior")
	escola.descer()
	assert(escola.painel.conteudo.text.contains("baixou"))
	escola.painel.fechar()
	escola.mudar_local("Hall")
	assert(escola.banda.playing)
	escola.evento()
	assert(escola.painel.titulo.text.contains("Senta e Toca"))
	escola.painel.fechar()
	assert(EstatisticasJogador.moedas == 40)
	escola.painel.escolha("drenagem", "duplicado", 20)
	assert(EstatisticasJogador.moedas == 40)
	assert(EstatisticasJogador.comprar("Estilingue", 30))
	assert(not EstatisticasJogador.comprar("Estilingue", 30))
	assert(not EstatisticasJogador.comprar("Cano", 25))
	assert(EstatisticasJogador.moedas == 10)
	escola.painel.musica()
	escola.painel.revelando = false
	var notas = escola.painel.sequencia.duplicate()
	for n in notas:
		escola.painel.nota(n)
	assert(EstatisticasJogador.feitos.has("musica"))
	escola.painel.fechar()
	escola.queue_free()
	await get_tree().process_frame
	var jogo = load("res://scenes/main_game_play.tscn").instantiate()
	get_tree().root.add_child(jogo)
	get_tree().current_scene = jogo
	await get_tree().process_frame
	var jogador = jogo.painel.jogador
	jogador.hit()
	await get_tree().physics_frame
	assert(jogo.has_node("LevelRoot/Refugio"))
	var refugio = jogo.fase_atual.get_node("Refugio")
	assert(not refugio.esta_disponivel())
	jogo._abrir_refugio()
	assert(not jogo.painel.painel.visible)
	for inimigo in jogo.fase_atual._inimigo_nodes:
		inimigo.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	assert(refugio.esta_disponivel())
	jogo._abrir_refugio()
	assert(jogo.painel.painel.visible)
	jogo.painel.fechar()
	var chefe = load("res://scenes/ratao.tscn").instantiate()
	jogo.add_child(chefe)
	var corpo = chefe.find_children("*", "CharacterBody2D", true, false)[0]
	var antes = EstatisticasJogador.vida
	corpo._on_hitbox_body_entered(jogador)
	corpo._on_timer_ataque_timeout()
	assert(EstatisticasJogador.vida == antes)
	assert(corpo.dano_meteoro > 0 and corpo.dano_baforada > 0)
	chefe.queue_free()
	for numero in range(2, 6):
		jogo.level = numero
		jogo.carregar_fase(numero)
		await get_tree().process_frame
		assert(is_instance_valid(jogo.painel.jogador))
	jogo.level = 2
	jogo.carregar_fase(2)
	assert(jogo.fase_atual == jogo.fases[2])
	assert(not jogo.fase_atual.puzzle_resolvido)
	assert(not jogo.fase_atual.get_node("Refugio").esta_disponivel())
	for inimigo in jogo.fase_atual._inimigo_nodes:
		if is_instance_valid(inimigo):
			inimigo.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	assert(not jogo.fase_atual.pode_sair())
	assert(jogo.fase_atual.get_node("Refugio").esta_disponivel())
	await jogo._jogador_morreu()
	assert(jogo.level == 2)
	assert(not jogo.fase_atual.get_node("Refugio").esta_disponivel())
	assert(EstatisticasJogador.arma == "Estilingue")
	assert(EstatisticasJogador.vida == 100)
	jogo.queue_free()
	await get_tree().process_frame
	await get_tree().create_timer(4.0).timeout
	print("PASS: portas, NPCs andando, banda, túnel, minigames, compras, chefe, cinco fases, refúgio bloqueado/liberado, puzzle separado e respawn")
	get_tree().quit()
