extends CanvasLayer

var painel: PanelContainer
var lista: VBoxContainer
var titulo: Label
var conteudo: Label
var jogador: Node
var sequencia: Array[int] = []
var entrada: Array[int] = []
var valvulas: Array[bool] = []
var revelando := false
var geracao := 0
var status: Label
var decoracao_ui: Control
var tema := "conversa"
var cor_texto := Color("302b28")
var local_atual := "Esgotos"

func _ready() -> void:
	layer = 60
	process_mode = Node.PROCESS_MODE_ALWAYS
	status = Label.new()
	status.position = Vector2(16, get_viewport().get_visible_rect().size.y - 85)
	status.add_theme_color_override("font_shadow_color", Color.BLACK)
	status.add_theme_constant_override("shadow_offset_x", 2)
	status.add_theme_constant_override("shadow_offset_y", 2)
	status.add_theme_font_size_override("font_size", 16)
	add_child(status)
	painel = PanelContainer.new()
	var fundo := StyleBoxFlat.new()
	fundo.bg_color = Color(0.06, 0.06, 0.06, 0.98)
	painel.add_theme_stylebox_override("panel", fundo)
	painel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	painel.offset_left = -310
	painel.offset_right = 310
	painel.offset_top = -270
	painel.offset_bottom = 270
	add_child(painel)
	var margem := MarginContainer.new()
	for lado in ["left", "top", "right", "bottom"]:
		margem.add_theme_constant_override("margin_" + lado, 18)
	painel.add_child(margem)
	var scroll := ScrollContainer.new()
	margem.add_child(scroll)
	lista = VBoxContainer.new()
	lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lista.add_theme_constant_override("separation", 10)
	scroll.add_child(lista)
	painel.hide()
	decoracao_ui = preload("res://Scripts/interaction_backdrop.gd").new()
	decoracao_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(decoracao_ui)
	# Decor on top is confined to edges, so content remains legible.
	get_viewport().size_changed.connect(_layout)

func _process(_delta: float) -> void:
	status.position = Vector2(16, get_viewport().get_visible_rect().size.y - 85)
	status.text = local_atual + "\n%d sucatas | %s | %d curativos\nTab: mochila / diário" % [EstatisticasJogador.moedas, EstatisticasJogador.arma, EstatisticasJogador.pocoes]

	if is_instance_valid(jogador) and jogador.combate_habilitado and not EstatisticasJogador.epilogo:
		status.text += "\nF: forte · R: aparar · Energia %d/100" % int(jogador.energia)
		status.position.y -= 25
	if EstatisticasJogador.epilogo:
		status.text = local_atual + "\nE: examinar lembranças · Tab: caderno"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_TAB:
			if painel.visible:
				fechar()
			elif is_instance_valid(jogador) and jogador.vivo:
				mochila()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE and painel.visible:
			fechar()
			get_viewport().set_input_as_handled()

func abrir(nome: String, texto: String, visual := "") -> void:
	geracao += 1
	revelando = false
	for filho in lista.get_children():
		lista.remove_child(filho)
		filho.queue_free()
	get_tree().paused = true
	painel.show()
	tema = visual if not visual.is_empty() else _tema_para(nome)
	_estilizar()
	titulo = Label.new()
	titulo.text = nome
	titulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	titulo.add_theme_color_override("font_color", cor_texto)
	titulo.add_theme_font_size_override("font_size", 24)
	lista.add_child(titulo)
	conteudo = Label.new()
	conteudo.text = texto
	conteudo.add_theme_color_override("font_color", cor_texto)
	conteudo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	conteudo.custom_minimum_size.x = minf(550, get_viewport().get_visible_rect().size.x - 100)
	lista.add_child(conteudo)

func botao(texto: String, acao: Callable) -> Button:
	var b := Button.new()
	b.text = texto
	b.custom_minimum_size.y = 38
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for estado in ["normal", "hover", "pressed", "focus", "disabled"]:
		var estilo := StyleBoxFlat.new()
		estilo.bg_color = Color(1,1,1,0.14) if tema not in ["conversa", "diario", "memorias"] else Color(0.25,0.18,0.1,0.09)
		if estado in ["hover", "focus"]:
			estilo.border_color = Color("cfa55f")
			estilo.set_border_width_all(2)
		estilo.set_corner_radius_all(6)
		b.add_theme_stylebox_override(estado, estilo)
	for estado in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(estado, cor_texto)

	lista.add_child(b)
	b.pressed.connect(acao)
	if lista.get_child_count() == 3:
		b.grab_focus()
	return b

func fechar() -> void:
	geracao += 1
	painel.hide()
	decoracao_ui.hide()
	get_tree().paused = false

func mochila() -> void:
	if EstatisticasJogador.epilogo:
		abrir("Caderno de fim de ano", "\n\n".join(EstatisticasJogador.diario))
		botao("Continuar", fechar)
		return
	abrir("Mochila e memórias", "Sucatas: %d | Curativos: %d\nArma equipada: %s\nTampa: %s\n\n%s" % [EstatisticasJogador.moedas, EstatisticasJogador.pocoes, EstatisticasJogador.arma, "reduz 3 de dano" if EstatisticasJogador.protecao else "não adquirida", "\n\n".join(EstatisticasJogador.diario)])
	for arma in EstatisticasJogador.armas:
		botao("Equipar " + arma, func():
			EstatisticasJogador.arma = arma
			mochila())
	botao("Usar curativo (+35 vida)", func():
		if EstatisticasJogador.pocoes > 0 and is_instance_valid(jogador) and jogador.curar(35):
			EstatisticasJogador.pocoes -= 1
		mochila())
	botao("Continuar", fechar)

func loja() -> void:
	abrir("Oficina de trocas", "Troque sucata recolhida nos túneis. Saldo: %d\nCaco: rápido. Cano: forte e lento. Estilingue: à distância.\nOs equipamentos usam as animações e os efeitos já existentes." % EstatisticasJogador.moedas)
	for oferta in [["Cano", 25], ["Estilingue", 30], ["Poção", 10], ["Tampa", 35]]:
		var item: String = oferta[0]
		var preco: int = oferta[1]
		var adquirido: bool = item in EstatisticasJogador.armas or (item == "Tampa" and EstatisticasJogador.protecao)
		var b := botao("%s — %d sucatas%s" % [item, preco, " (adquirido)" if adquirido else ""], func():
			EstatisticasJogador.comprar(item, preco)
			loja())
		b.disabled = adquirido or EstatisticasJogador.moedas < preco
	botao("Voltar", fechar)

func conversar(pessoa: String) -> void:
	match pessoa:
		"Duda":
			abrir("Duda · hall do COLTEC", "Duas pessoas sumiram. Depois, outras quatro. A direção quer tirar os cartazes. Você assinaria um pedido para investigar?")
			botao("Apoiar a investigação", func(): escolha("lia", "Apoiei Duda: cuidar dos outros não exige controlar o resultado.", 12))
			botao("Ouvir antes de decidir", func(): escolha("lia", "Preferi ouvir: não preciso representar uma certeza que não tenho.", 12))
		"PH":
			abrir("PH · hall", "Depois da prova, eu só queria espairecer. Você sempre tenta acertar tudo. Vamos tocar alguma coisa antes de descer?")
			botao("Minigame: memória musical", musica)
			botao("Conversar sobre o patinete", func(): escolha("davi", "Um patinete, um farol, uma música interrompida. Memória ou presságio? PH também ouviu o ruído.", 8))
		"Tigas":
			abrir("Anotação de Tigas · drenagem", "Vou ficar por aqui. Deixei as instruções no painel da oficina. Cada válvula troca também a seguinte; deixe as quatro abertas.")
			botao("Minigame: circuito de drenagem", circuito)
		"Rato albino":
			abrir("Uma voz no esgoto", "“Você quer voltar ao momento certo? Que desperdício. Aqui podemos tentar para sempre.”\n\nA criatura sabe de uma lembrança que você nunca contou.")
			botao("Registrar a lembrança", func(): escolha("eco", "Disnara oferece permanência. Mas repetir a vida não devolve aquilo que foi perdido.", 0))
	botao("Encerrar conversa", fechar)

func escolha(id: String, texto: String, premio: int) -> void:
	var novo := EstatisticasJogador.registrar(id, texto, premio)
	abrir("Diário atualizado", texto + ("\n+%d sucatas" % premio if novo else "\nEsta conversa já está registrada."))
	botao("Continuar", fechar)

func musica() -> void:
	abrir("Memória musical", "Memorize as quatro notas. Depois, repita na mesma ordem.")
	sequencia.clear()
	entrada.clear()
	for i in range(4):
		sequencia.append(randi_range(0, 3))
	revelando = true
	var nomes := ["Dó", "Ré", "Mi", "Sol"]
	conteudo.text = " → ".join(sequencia.map(func(n): return nomes[n]))
	for i in range(4):
		botao(nomes[i], nota.bind(i))
	botao("Sair", fechar)
	var atual := geracao
	await get_tree().create_timer(3.0, true).timeout
	if atual == geracao and painel.visible:
		revelando = false
		conteudo.text = "Sua vez: 0 / 4"

func nota(n: int) -> void:
	if revelando:
		return
	entrada.append(n)
	if n != sequencia[entrada.size() - 1]:
		abrir("A melodia escapou", "Respire. Errar faz parte. Você pode tentar novamente.")
		botao("Tentar outra sequência", musica)
		botao("Voltar", fechar)
	elif entrada.size() == sequencia.size():
		escolha("musica", "Uma melodia me ancora no presente. Nem toda lembrança precisa ser corrigida.", 20)
	else:
		conteudo.text = "Sua vez: %d / 4" % entrada.size()

func circuito() -> void:
	valvulas = [false, true, false, true]
	mostrar_circuito()

func mostrar_circuito() -> void:
	abrir("Circuito de drenagem", "Cada válvula inverte a si mesma e a próxima (4 liga à 1). Abra todas.\n" + str(valvulas.map(func(v): return "ABERTA" if v else "fechada")))
	for i in range(4):
		botao("Girar válvula %d" % (i + 1), func():
			valvulas[i] = not valvulas[i]
			valvulas[(i + 1) % 4] = not valvulas[(i + 1) % 4]
			if valvulas.all(func(v): return v):
				escolha("drenagem", "Resolvi o circuito com Tigas. O caminho para o esgoto está aberto.", 20)
			else:
				mostrar_circuito())
	botao("Sair", fechar)


func _tema_para(nome: String) -> String:
	var n := nome.to_lower()
	if "java" in n or "terminal" in n or "compil" in n:
		return "java"
	if "caderno" in n or "mochila" in n or "diário" in n:
		return "diario"
	if "válvula" in n or "circuito" in n:
		return "circuito"
	if "geovane" in n or "metal" in n or "trocas" in n:
		return "metal"
	if "melodia" in n or "musical" in n or "toquempé" in n:
		return "musica"
	if "cobrança" in n or "goleiro" in n or "estelionatários" in n or "decisão" in n or "torneio" in n:
		return "futebol"
	if "papéis" in n or "arquivo" in n:
		return "memorias"
	return "conversa"

func _estilizar() -> void:
	var cores := {"conversa":"f3e9cf", "diario":"ead9b1", "java":"152e37", "metal":"34444b", "circuito":"28443f", "musica":"463551", "futebol":"295a43", "memorias":"dfd0b6"}
	cor_texto = Color("322c29") if tema in ["conversa","diario","memorias"] else Color("f4e9d3")
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(cores.get(tema,"f3e9cf"))
	estilo.set_corner_radius_all(22 if tema == "conversa" else 7)
	estilo.border_color = Color("73543c") if tema in ["conversa","diario"] else Color("8da8a4")
	estilo.set_border_width_all(3)
	estilo.shadow_color = Color(0,0,0,0.35)
	estilo.shadow_size = 10
	painel.add_theme_stylebox_override("panel",estilo)
	# Extra padding leaves room for binding, terminal header and themed footer.
	var margem = painel.get_child(0)
	margem.add_theme_constant_override("margin_left", 58 if tema == "diario" else 20)
	margem.add_theme_constant_override("margin_top", 42 if tema == "java" else 20)
	margem.add_theme_constant_override("margin_bottom", 52 if tema not in ["conversa","diario"] else 24)
	decoracao_ui.tema = tema
	decoracao_ui.show()
	_layout()
	# The diary drawing must be below the actual text.
	decoracao_ui.z_index = 1
	painel.get_child(0).z_index = 2

func _layout() -> void:
	if not is_instance_valid(decoracao_ui):
		return
	var tela := get_viewport().get_visible_rect().size
	var largura := minf(670, tela.x-40)
	var altura := minf(540 if tema != "conversa" else 340, tela.y-70)
	painel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	painel.position = Vector2((tela.x-largura)/2, (tela.y-altura)/2 if tema != "conversa" else tela.y-altura-35)
	painel.size = Vector2(largura,altura)
	decoracao_ui.position = painel.position
	decoracao_ui.size = painel.size
	decoracao_ui.queue_redraw()
