extends Node

func _ready() -> void:
	call_deferred("capturar")

func capturar() -> void:
	var escola = load("res://scenes/coltec.tscn").instantiate()
	add_child(escola)
	escola.painel.fechar()
	DirAccess.make_dir_recursive_absolute("res://output/coltec")
	for ambiente in [["Hall", "hall"], ["Laboratório", "laboratorio"], ["Laboratório da turma", "laboratorio_turma"], ["Exterior", "exterior"], ["Quadra", "quadra"]]:
		escola.mudar_local(ambiente[0])
		for i in range(8):
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://output/coltec/" + ambiente[1] + ".png")
	escola.mudar_local("Laboratório da turma")
	escola.jogador.global_position = Vector2(1050,850)
	for i in range(4):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://output/coltec/computadores.png")
	escola.mudar_local("Quadra")
	var jogo = escola.decoracao.get_children().filter(func(n): return n.get_script() == preload("res://Scripts/football.gd"))[0]
	jogo.iniciar()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://output/coltec/penaltis.png")
	escola.painel.fechar()
	escola.mudar_local("Hall")
	for par in [["morcego", Vector2(380,350)], ["escorpiao", Vector2(580,350)]]:
		var inimigo = load("res://scenes/" + par[0] + ".tscn").instantiate()
		escola.decoracao.add_child(inimigo)
		inimigo.position = par[1]
		inimigo.scale = Vector2(2,2)
		var corpo = inimigo.get_node("Morcego" if par[0] == "morcego" else "Escorpiao")
		corpo.set_physics_process(false)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://output/coltec/inimigos.png")
	escola.mudar_local("Hall")
	escola.evento()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://output/coltec/evento.png")
	escola.painel.fechar()
	for caso in ["diario","conversa","java","metal","circuito"]:
		match caso:
			"diario": escola.painel.mochila()
			"conversa": escola.painel.conversar("Duda")
			"java": escola.aula_java.iniciar("saida")
			"metal": escola._aula_metal()
			"circuito": escola.painel.circuito()
		for i in range(3):
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://output/coltec/ui_"+caso+".png")
		escola.painel.fechar()
	escola.queue_free()
	await get_tree().create_timer(0.2).timeout
	EstatisticasJogador.iniciar_epilogo()
	escola = load("res://scenes/coltec.tscn").instantiate()
	add_child(escola)
	escola.painel.fechar()
	for ambiente in [["Hall", "hall"], ["Exterior", "exterior"], ["Laboratório da turma", "sala"]]:
		escola.mudar_local(ambiente[0])
		for i in range(8):
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://output/coltec/epilogo_" + ambiente[1] + ".png")
	escola.queue_free()
	await get_tree().process_frame
	get_tree().quit()
