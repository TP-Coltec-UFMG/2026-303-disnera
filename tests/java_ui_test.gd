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
	assert(escola.pontos.any(func(n): return n.titulo == "Duda"))
	escola.mudar_local("Exterior")
	assert(not escola.pontos.any(func(n): return n is NPC))
	escola.mudar_local("Laboratório da turma")
	assert(escola.tamanho_sala == Vector2(1600,1100))
	assert(escola.pontos.any(func(n): return n.titulo == "Leando Maia"))
	escola.jogador.global_position = Vector2(1150,900)
	escola._process(0)
	assert(escola.camera.position.y > 600)
	escola.mudar_local("Hall")
	escola._process(0)
	assert(escola.camera.position == Vector2(480,320))
	var aula = escola.aula_java
	var saldo = EstatisticasJogador.moedas
	for id in ["saida","debug"]:
		aula.iniciar(id)
		assert(escola.painel.tema == "java")
		aula.responder(2)
		assert(aula.etapa == 0)
		for i in range(3 if id == "saida" else 2):
			aula.mostrar()
			aula.responder(1 if id == "saida" else 0)
		aula.concluir()
		assert(EstatisticasJogador.feitos.has("java_"+id))
	aula.iniciar("ordem")
	aula.escolher(3)
	assert(aula.ordem.is_empty())
	for i in range(4):
		aula.escolher(i)
	assert(EstatisticasJogador.moedas == saldo+24)
	aula.concluir()
	assert(EstatisticasJogador.moedas == saldo+24)
	escola.painel.mochila()
	assert(escola.painel.tema == "diario")
	escola.painel.conversar("Duda")
	assert(escola.painel.tema == "conversa")
	escola.painel.circuito()
	assert(escola.painel.tema == "circuito")
	escola.painel.fechar()
	escola.mudar_local("Sala de metal")
	var prof = escola.pontos.filter(func(n): return n.titulo == "Professor Geovane")[0]
	assert(prof.sprite.material.get_shader_parameter("cabelo_claro") == Color("f3f2df"))
	prof.acao.call()
	assert(escola.painel.tema == "metal")
	escola.painel.fechar()
	escola.queue_free()
	await get_tree().process_frame
	print("PASS: hall, câmera e laboratório maior, professores, três exercícios Java, erro/retry, recompensas únicas e temas de interação")
	get_tree().quit()
