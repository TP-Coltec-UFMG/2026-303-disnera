extends Node2D

const POINT = preload("res://Scripts/adventure_point.gd")
const NPC = preload("res://Scripts/school_npc.gd")
const PANEL = preload("res://Scripts/adventure_panel.gd")
const TAMANHO := Vector2(960, 640)
const FUNDOS = {
	"Hall": "res://Imagens/Coltec/hall_simples.png",
	"Sala de metal": "res://Imagens/Coltec/oficina_simples.png",
	"Laboratório da turma": "res://Imagens/Coltec/laboratorio_turma.png",
	"Exterior": "res://Imagens/Coltec/exterior_simples.png",
	"Quadra": "res://Imagens/Coltec/quadra_simples.png"
}
var painel: CanvasLayer
var jogador: Node2D
var local := "Hall"
var pontos: Array[Node] = []
var decoracao: Node2D
var atores: Node2D
var fundo: Sprite2D
var camera: Camera2D
var banda: AudioStreamPlayer
var faixa_evento: Label
var epilogo := false
var memorias: Node
var clima: Node2D
var aula_java: Node
var tamanho_sala := TAMANHO

func _ready() -> void:
	epilogo = EstatisticasJogador.epilogo
	var moldura := CanvasLayer.new()
	moldura.layer = -100
	add_child(moldura)
	var margem := ColorRect.new()
	margem.color = Color("171510")
	margem.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	moldura.add_child(margem)
	fundo = Sprite2D.new()
	fundo.centered = false
	fundo.z_index = -10
	add_child(fundo)
	decoracao = Node2D.new()
	add_child(decoracao)
	atores = Node2D.new()
	atores.y_sort_enabled = true
	add_child(atores)
	var personagem := preload("res://scenes/Player.tscn").instantiate()
	personagem.scale = Vector2(0.5, 0.5)
	atores.add_child(personagem)
	jogador = personagem.get_node("Player")
	jogador.combate_habilitado = false
	jogador.get_node("Camera2D").enabled = false
	camera = Camera2D.new()
	camera.position = TAMANHO / 2
	add_child(camera)
	_ajustar_camera()
	get_viewport().size_changed.connect(_ajustar_camera)
	painel = PANEL.new()
	add_child(painel)
	painel.jogador = jogador
	faixa_evento = Label.new()
	faixa_evento.position = Vector2(20, 16)
	faixa_evento.add_theme_font_size_override("font_size", 19)
	faixa_evento.add_theme_color_override("font_color", Color("ffe0a2"))
	faixa_evento.add_theme_color_override("font_shadow_color", Color("22160d"))
	faixa_evento.add_theme_constant_override("shadow_offset_x", 2)
	faixa_evento.add_theme_constant_override("shadow_offset_y", 2)
	painel.add_child(faixa_evento)
	painel.painel.visibility_changed.connect(func(): faixa_evento.visible = not painel.painel.visible)
	banda = AudioStreamPlayer.new()
	banda.stream = preload("res://Musica/Coltec/senta_e_toca.wav")
	banda.bus = &"Music"
	banda.process_mode = Node.PROCESS_MODE_ALWAYS
	banda.finished.connect(func():
		if local == "Hall" and not epilogo:
			banda.play())
	banda.volume_db = -9.0
	add_child(banda)
	memorias = preload("res://Scripts/epilogue_memories.gd").new()
	memorias.painel = painel
	add_child(memorias)
	aula_java = preload("res://Scripts/java_class.gd").new()
	aula_java.painel = painel
	add_child(aula_java)
	clima = preload("res://Scripts/epilogue_weather.gd").new()
	add_child(clima)
	mudar_local("Hall")
	if epilogo:
		painel.abrir("Dezembro · depois do último sinal", "Você voltou. A turma se formou. Todo mundo já foi embora.\n\nA faixa ficou pendurada. Os armários estão fechados. Do lado de fora, só a chuva.\n\nTalvez ainda exista alguma coisa para guardar daqui.")
		painel.botao("Andar pela escola", painel.fechar)
		return
	painel.abrir("COLTEC · antes da descida", "A prova acabou. No hall antigo, a banda já começou o Senta e Toca.\n\nConverse com os estudantes, visite as salas pelas portas e procure o túnel nos fundos da escola.\nWASD: andar · E: interagir · Tab: mochila\n\nComo você quer ser chamado?")
	var nome := LineEdit.new()
	nome.placeholder_text = "Seu nome"
	nome.max_length = 24
	painel.lista.add_child(nome)
	painel.botao("Entrar na escola", func():
		EstatisticasJogador.nome = nome.text.strip_edges() if not nome.text.strip_edges().is_empty() else "Estudante"
		painel.fechar())

func _ajustar_camera() -> void:
	var tela := get_viewport_rect().size
	var zoom := minf(tela.x / TAMANHO.x, tela.y / TAMANHO.y)
	camera.zoom = Vector2.ONE * zoom

func ponto(texto: String, pos: Vector2, acao: Callable) -> Node2D:
	var p := POINT.new()
	p.titulo = texto
	p.position = pos
	p.jogador = jogador
	p.acao = acao
	atores.add_child(p)
	pontos.append(p)
	return p

func npc(nome: String, pos: Vector2, aparencia: int, rota: Array[Vector2], acao: Callable, instrumento := "") -> Node2D:
	if epilogo:
		return null
	var p := NPC.new()
	p.titulo = nome
	p.position = pos
	p.jogador = jogador
	p.acao = acao
	p.aparencia = aparencia
	p.rota = rota
	p.instrumento = instrumento
	p.tocando = not instrumento.is_empty()
	atores.add_child(p)
	pontos.append(p)
	return p

func porta(texto: String, pos: Vector2, destino: String, chegada: Vector2) -> void:
	var p := ponto(texto, pos, func(): mudar_local(destino, chegada))
	p.set_meta("porta", true)
	p.dica = "[E] abrir porta"
	p.raio = 62

func obstaculo(rect: Rect2) -> void:
	var corpo := StaticBody2D.new()
	corpo.collision_layer = 2
	corpo.collision_mask = 0
	corpo.position = rect.get_center()
	var forma := CollisionShape2D.new()
	var caixa := RectangleShape2D.new()
	caixa.size = rect.size
	forma.shape = caixa
	corpo.add_child(forma)
	decoracao.add_child(corpo)

func mudar_local(destino: String, chegada := Vector2.INF) -> void:
	# Aliases mantêm compatibilidade com o prólogo anterior.
	if destino == "Laboratório":
		destino = "Sala de metal"
	if destino == "Sala de música":
		destino = "Laboratório da turma"
	if destino in ["Pátio", "Corredor"]:
		destino = "Hall"
	if not FUNDOS.has(destino):
		return
	local = destino
	tamanho_sala = Vector2(1600,1100) if local == "Laboratório da turma" else TAMANHO
	for p in pontos:
		atores.remove_child(p)
		p.queue_free()
	pontos.clear()
	for item in decoracao.get_children():
		decoracao.remove_child(item)
		item.queue_free()
	fundo.texture = load(FUNDOS[local])
	fundo.scale = tamanho_sala / fundo.texture.get_size()
	fundo.visible = local != "Laboratório da turma"
	if chegada == Vector2.INF:
		chegada = Vector2(480, 370) if local == "Exterior" else Vector2(480, 490)
	if local == "Laboratório da turma":
		chegada = Vector2(800,310)
	jogador.global_position = chegada
	jogador.velocity = Vector2.ZERO
	jogador.dash_time = 0.0
	# Colisões seguem os limites e a mobília de cada novo fundo.
	obstaculo(Rect2(-40,-40,tamanho_sala.x+80,180))
	obstaculo(Rect2(-40,0,90,tamanho_sala.y+60))
	obstaculo(Rect2(tamanho_sala.x-50,0,90,tamanho_sala.y+60))
	obstaculo(Rect2(0,tamanho_sala.y-30,tamanho_sala.x,80))
	match local:
		"Hall":
			obstaculo(Rect2(350, 140, 260, 45))
			obstaculo(Rect2(240, 140, 110, 34))
			obstaculo(Rect2(610, 140, 110, 34))
			obstaculo(Rect2(50, 195, 33, 170))
			obstaculo(Rect2(877, 195, 33, 170))
			porta("Laboratório da turma", Vector2(200, 180), "Laboratório da turma", Vector2(480, 515))
			porta("Sala de metal", Vector2(755, 180), "Sala de metal", Vector2(480, 515))
			porta("Jardim / fundos da escola", Vector2(480, 590), "Exterior", Vector2(220, 230))
			npc("Duda",Vector2(220,330),0,[Vector2(220,330),Vector2(300,420)],func(): painel.conversar("Duda"))
			npc("Pedro Silva Freitas",Vector2(735,350),3,[Vector2(735,350),Vector2(760,460)],painel.loja)
			npc("PH",Vector2(390,370),1,[Vector2(390,370),Vector2(480,420)],func(): painel.conversar("PH"))
			npc("Saci",Vector2(610,330),3,[Vector2(610,330),Vector2(680,430)],_conversa_turma.bind("Saci",2))
			npc("Tigas",Vector2(300,480),2,[Vector2(300,480),Vector2(530,490)],func(): painel.conversar("Tigas"))
			if not epilogo:
				decoracao.add_child(preload("res://Scripts/hall_life.gd").new())
			for musico in [[398, 168, "guitarra"], [482, 145, "bateria"], [555, 149, "teclado"]]:
				npc("Toquempé", Vector2(musico[0], musico[1]), int(musico[0]) % 4, [], evento, musico[2])
			var palco := ponto("Toquempé", Vector2(480, 262), evento)
			palco.dica = "[E] ouvir / participar"
		"Sala de metal":
			var prof = npc("Professor Geovane",Vector2(420,280),2,[],_aula_metal)
			if prof:
				prof.mostrar_nome = true
				prof.sprite.material.set_shader_parameter("cabelo_escuro",Color("b9bdba"))
				prof.sprite.material.set_shader_parameter("cabelo_claro",Color("f3f2df"))
			obstaculo(Rect2(50, 140, 860, 70))
			obstaculo(Rect2(50, 160, 85, 380))
			obstaculo(Rect2(830, 160, 80, 380))
			porta("Voltar ao hall", Vector2(480, 585), "Hall", Vector2(755, 250))
			var circuito := ponto("Painel de drenagem", Vector2(580, 225), painel.circuito)
			circuito.dica = "[E] ajustar válvulas"
		"Laboratório da turma":
			obstaculo(Rect2(50,140,1500,120))
			var sala = preload("res://Scripts/computer_lab.gd").new()
			sala.modulate = Color(0.61,0.65,0.74) if epilogo else Color.WHITE
			decoracao.add_child(sala)
			var professor = npc("Leando Maia",Vector2(1060,290),1,[],aula_java.aula)
			if professor:
				professor.mostrar_nome = true
			porta("Voltar ao hall",Vector2(800,1040),"Hall",Vector2(200,250))
			_criar_turma()
			for pos in [Vector2(300,325),Vector2(1200,325),Vector2(1400,325)]:
				var terminal = preload("res://Scripts/study_desk.gd").new()
				terminal.position = pos
				decoracao.add_child(terminal)
			if not epilogo:
				ponto("Java · prever saída",Vector2(300,310),aula_java.iniciar.bind("saida"))
				ponto("Java · depurar",Vector2(1200,310),aula_java.iniciar.bind("debug"))
				ponto("Java · montar código",Vector2(1400,310),aula_java.iniciar.bind("ordem"))
			ponto("Mural dos desaparecidos",Vector2(1450,980),func(): painel.escolha("cartazes","Seis estudantes desapareceram. Retirar os cartazes não apaga a ausência.",8))
		"Exterior":
			obstaculo(Rect2(310, 140, 305, 158))
			obstaculo(Rect2(50, 140, 125, 232))
			obstaculo(Rect2(625, 400, 285, 160))
			obstaculo(Rect2(330, 460, 260, 160))
			obstaculo(Rect2(0, 555, 960, 70))
			porta("Quadra", Vector2(220, 525), "Quadra", Vector2(480, 515))
			porta("Porta da escola", Vector2(245, 215), "Hall", Vector2(480, 515))
			var tunel := ponto("Túnel do esgoto", Vector2(785, 210), descer)
			tunel.dica = "[E] examinar entrada"
		"Quadra":
			obstaculo(Rect2(50, 540, 370, 80))
			obstaculo(Rect2(550, 540, 360, 80))
			if not epilogo:
				var partida = preload("res://Scripts/football.gd").new()
				partida.painel = painel
				decoracao.add_child(partida)
				ponto("Torneio final · Dinsara × Estelionatários", Vector2(480, 510), partida.abrir)
			porta("Voltar à escola", Vector2(480, 585), "Exterior", Vector2(220, 460))
	if epilogo:
		_configurar_epilogo()
	clima.configurar(local, epilogo)
	fundo.modulate = Color(0.61, 0.65, 0.74) if epilogo else Color.WHITE
	painel.local_atual = ("Dezembro / " if epilogo else "COLTEC / ") + local
	faixa_evento.text = "TOQUEMPÉ  •  Senta e Toca\nGuitarra, teclado e bateria — chegue perto do palco" if local == "Hall" else "COLTEC  /  " + local
	if epilogo:
		faixa_evento.text = "DEPOIS DO ÚLTIMO SINAL  /  " + local
	if local == "Hall" and not epilogo:
		if not banda.playing:
			banda.play()
	else:
		banda.stop()

func evento() -> void:
	painel.abrir("Toquempé · Senta e Toca", "A Toquempé ocupa o palco com guitarra, teclado e bateria. Por alguns minutos, ninguém precisa acertar a vida inteira.\n\n“Quer entrar na próxima música? Escute a frase e devolva as notas.”")
	painel.botao("Participar · memória musical", painel.musica)
	painel.botao("Ficar para ouvir", func(): painel.escolha("senta_toca", "No Senta e Toca, ouvi a banda com os colegas. Um momento não precisa durar para sempre para valer a pena.", 5))
	painel.botao("Voltar ao hall", painel.fechar)

func descer() -> void:
	if epilogo:
		return
	painel.abrir("O túnel sob a escola", "A drenagem baixou a água. Entre o musgo e os tijolos, a entrada leva aos esgotos. Seus amigos esperam. Você ainda pode voltar para a escola." if EstatisticasJogador.feitos.has("drenagem") else "A entrada do túnel está alagada. Volte pela porta da escola e siga a anotação de Tigas na sala de metal para abrir as quatro válvulas.")
	if EstatisticasJogador.feitos.has("drenagem"):
		painel.botao("Entrar no túnel com os amigos", func():
			painel.fechar()
			get_tree().change_scene_to_file("res://scenes/intro_cutscene.tscn"))
	painel.botao("Continuar explorando", painel.fechar)

func _exit_tree() -> void:
	if is_instance_valid(banda):
		banda.stop()

func _configurar_epilogo() -> void:
	for p in pontos.duplicate():
		if not p.has_meta("porta"):
			pontos.erase(p)
			atores.remove_child(p)
			p.queue_free()
	match local:
		"Hall":
			ponto("Papéis da despedida", Vector2(475, 310), memorias.iniciar.bind("coltec"))
		"Laboratório da turma":
			ponto("A última melodia", Vector2(380, 280), memorias.iniciar.bind("melodia"))
		"Sala de metal":
			ponto("Arquivo molhado · Disnara", Vector2(580, 300), memorias.iniciar.bind("disnara"))
		"Exterior":
			ponto("O túnel ficou para trás", Vector2(785, 210), func():
				painel.abrir("Debaixo da chuva", "A água encobre o caminho. Você não precisa descer outra vez.")
				painel.botao("Voltar", painel.fechar))
		"Quadra":
			ponto("Última volta", Vector2(480, 400), func():
				painel.abrir("Até a próxima", "O ano acabou. Você pode ficar mais um pouco ou encerrar esta caminhada.")
				painel.botao("Ficar mais um pouco", painel.fechar)
				painel.botao("Encerrar e voltar ao menu", func():
					painel.fechar()
					get_tree().change_scene_to_file("res://scenes/main.tscn")))


func _criar_turma() -> void:
	var turma: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/turma.json"))
	for i in range(turma.size()):
		var coluna := i % 8
		var linha := i / 8
		var pos := Vector2(230 + coluna * 160, 440 + linha * 115)
		var mesa := preload("res://Scripts/study_desk.gd").new()
		mesa.position = pos
		mesa.indice = i
		decoracao.add_child(mesa)
		var estudante = npc(turma[i], pos + Vector2(0, 12), i % 4, [], _conversa_turma.bind(turma[i], i))
		if estudante:
			estudante.raio = 48
			estudante.dica = "[E] conversar"
			estudante.ultima_direcao = Vector2.UP
			estudante.sprite.play("parado_up")

func _conversa_turma(nome: String, indice: int) -> void:
	var falas := [
		"Estou revisando o circuito. Você já abriu as válvulas da oficina?",
		"A turma combinou de assistir Dinsara contra Estelionatários depois de estudar.",
		"A Toquempé está tocando no hall. Dá para ouvir daqui!",
		"Estou acompanhando o laço for. Leando Maia deixou três exercícios nos terminais da frente.",
		"Uma pausa, um pouco de conversa e depois a gente termina o relatório."
	]
	painel.abrir(nome, falas[indice % falas.size()])
	painel.botao("Até daqui a pouco", painel.fechar)


func _process(_delta: float) -> void:
	if not is_instance_valid(camera) or not is_instance_valid(jogador):
		return
	if local == "Laboratório da turma":
		var metade := get_viewport_rect().size / camera.zoom / 2
		camera.position = Vector2(clampf(jogador.global_position.x,metade.x,tamanho_sala.x-metade.x),clampf(jogador.global_position.y,metade.y,tamanho_sala.y-metade.y))
	else:
		camera.position = TAMANHO/2

func _aula_metal() -> void:
	painel.abrir("Professor Geovane · sala de metal","Antes de usar a bancada, vamos conferir a ordem do trabalho: medir a peça, marcar a linha e só então cortar.

Qual é a primeira etapa?","metal")
	painel.botao("Medir a peça",func():
		painel.abrir("Geovane · medida certa","Isso! Medir e marcar evitam desperdiçar material. Agora você pode estudar o circuito de drenagem.","metal")
		painel.botao("Abrir o circuito",painel.circuito)
		painel.botao("Voltar à bancada",painel.fechar))
	painel.botao("Cortar direto",func():
		painel.abrir("Geovane · vamos revisar","Ainda não. Confira a medida antes do corte.","metal")
		painel.botao("Tentar de novo",_aula_metal)
		painel.botao("Voltar",painel.fechar))
	painel.botao("Voltar à sala",painel.fechar)
