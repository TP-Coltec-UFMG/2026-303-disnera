extends Node2D
var painel: CanvasLayer
var jogadores: Array[AnimatedSprite2D] = []
var bases: Array[Vector2] = []
var bola := Vector2(480, 325)
var tempo := 0.0
var fase := "assistir"
var rodada := 0
var gols := 0
var rival := 0
var mira := 1
var defesa_rival := 1
var forca := 0.0
var medidor: ProgressBar
var placar: Label
var geracao := -1

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var modelo = preload("res://scenes/Player.tscn").instantiate()
	var frames = modelo.get_node("Player/AnimatedSprite2D").sprite_frames
	modelo.free()
	for i in range(10):
		var atleta := AnimatedSprite2D.new()
		atleta.sprite_frames = frames
		atleta.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		atleta.scale = Vector2(1.7, 1.7)
		atleta.modulate = Color("91b9fa") if i < 5 else Color("f8b38b")
		var base := Vector2(190 + (i % 5) * 125, 265 if i < 5 else 390)
		bases.append(base)
		atleta.position = base
		atleta.play("correr_right")
		add_child(atleta)
		jogadores.append(atleta)
	placar = Label.new()
	placar.position = Vector2(225, 148)
	placar.add_theme_font_size_override("font_size", 18)
	placar.text = "TORNEIO FINAL   ·   Dinsara × Estelionatários"
	add_child(placar)

func _process(delta: float) -> void:
	if not get_tree().paused:
		tempo += delta
		bola = Vector2(480 + sin(tempo * 0.85) * 290, 325 + sin(tempo * 1.7) * 70)
		for i in range(jogadores.size()):
			jogadores[i].position = bases[i] + Vector2(sin(tempo * 1.4 + i) * 34, cos(tempo + i) * 21)
			jogadores[i].flip_h = cos(tempo * 1.4 + i) < 0
		queue_redraw()
	if fase == "chute" and painel.geracao == geracao and painel.painel.visible:
		forca = fmod(forca + delta * 0.65, 1.0)
		if is_instance_valid(medidor):
			medidor.value = forca * 100

func _draw() -> void:
	draw_rect(Rect2(110, 185, 740, 285), Color("386951"))
	for x in range(110, 850, 92):
		draw_rect(Rect2(x, 185, 46, 285), Color("3e7058"))
	draw_rect(Rect2(130, 205, 700, 245), Color("d6d5b0"), false, 2)
	draw_line(Vector2(480, 205), Vector2(480, 450), Color("d6d5b0"), 2)
	draw_arc(Vector2(480,327),45,0,TAU,24,Color("d6d5b0"),2)
	for x in [130, 750]:
		draw_rect(Rect2(x,265,80,125),Color("d6d5b0"),false,2)
	for x in [110, 830]:
		draw_rect(Rect2(x,290,20,75),Color("d5d7cd"),false,3)
		for y in range(295,365,10):
			draw_line(Vector2(x,y),Vector2(x+20,y),Color("939c95"),1)
	draw_rect(Rect2(bola-Vector2(5,5),Vector2(10,10)),Color("eeeadb"))
	draw_rect(Rect2(bola-Vector2(2,2),Vector2(4,4)),Color("343a40"))

func abrir() -> void:
	fase = "menu"
	painel.abrir("Torneio final · Dinsara × Estelionatários", "A partida está rolando! Entre na decisão por pênaltis pela Dinsara.\n\nCinco cobranças para cada time. Escolha o canto e chute com a força entre 55 e 85. Depois, escolha onde defender. Empate permite revanche.")
	painel.botao("Jogar a decisão", iniciar)
	painel.botao("Só assistir", painel.fechar)

func iniciar() -> void:
	rodada = 0
	gols = 0
	rival = 0
	preparar_chute()

func preparar_chute() -> void:
	fase = "chute"
	forca = 0.0
	defesa_rival = randi_range(0,2)
	mira = 1
	painel.abrir("Cobrança %d / 5 · Dinsara %d × %d Estelionatários" % [rodada+1,gols,rival], "Escolha o canto. Clique em CHUTAR quando a força estiver entre 55 e 85.\nMira: centro")
	geracao = painel.geracao
	medidor = ProgressBar.new()
	medidor.custom_minimum_size = Vector2(320,25)
	painel.lista.add_child(medidor)
	for i in range(3):
		painel.botao(["Esquerda","Centro","Direita"][i], escolher_mira.bind(i))
	painel.botao("CHUTAR", chutar)
	painel.botao("Sair da decisão", sair)

func escolher_mira(lado: int) -> void:
	mira = lado
	painel.conteudo.text = "Chute com força entre 55 e 85.\nMira: " + ["esquerda","centro","direita"][lado]

func chutar() -> void:
	if fase != "chute":
		return
	var gol := forca >= 0.55 and forca <= 0.85 and mira != defesa_rival
	if gol:
		gols += 1
	fase = "defesa"
	painel.abrir("Agora você é o goleiro", ("GOOOL da Dinsara!" if gol else "A bola não entrou!") + "\n\nEstelionatários vai cobrar. Para onde você vai saltar?")
	for i in range(3):
		painel.botao(["Esquerda","Centro","Direita"][i], defender.bind(i))
	painel.botao("Sair da decisão", sair)

func defender(lado: int) -> void:
	if fase != "defesa":
		return
	var cobrou := randi_range(0,2)
	if lado != cobrou:
		rival += 1
	rodada += 1
	fase = "intervalo"
	painel.abrir("Dinsara %d × %d Estelionatários" % [gols,rival], "Defesa da Dinsara!" if lado == cobrou else "Gol do Estelionatários.")
	painel.botao("Próxima cobrança" if rodada < 5 else "Resultado", preparar_chute if rodada < 5 else terminar)

func terminar() -> void:
	fase = "fim"
	var resultado := "Dinsara campeã!" if gols > rival else ("Estelionatários venceu!" if rival > gols else "Empate! Que tal uma revanche?")
	if gols > rival:
		EstatisticasJogador.registrar("torneio_final", "Dinsara venceu o Estelionatários no torneio final do COLTEC.", 15)
	painel.abrir("Fim da decisão · %d × %d" % [gols,rival], resultado + "\nA primeira vitória rende 15 sucatas e uma lembrança.")
	painel.botao("Revanche", iniciar)
	painel.botao("Voltar à quadra", sair)

func sair() -> void:
	fase = "assistir"
	painel.fechar()
