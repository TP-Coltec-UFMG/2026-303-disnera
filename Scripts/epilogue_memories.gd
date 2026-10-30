extends Node

var painel: CanvasLayer
var dados: Dictionary = {}
var atual := ""
var ordem: Array[int] = []
var resposta: Array[int] = []
var cartas: Array[int] = []
var abertas: Array[int] = []
var resolvidas: Array[int] = []
var mostrando := false
var ocupada := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	dados = JSON.parse_string(FileAccess.get_file_as_string("res://data/epilogue_memories.json"))

func iniciar(id: String) -> void:
	atual = id
	resposta.clear()
	abertas.clear()
	resolvidas.clear()
	mostrando = false
	ocupada = false
	match id:
		"coltec":
			ordem = [2, 0, 1]
			mostrar_papeis()
		"melodia":
			ordem.clear()
			for i in range(4):
				ordem.append(randi_range(0, 3))
			mostrar_melodia()
		"disnara":
			cartas = [0, 0, 1, 1, 2, 2]
			cartas.shuffle()
			mostrar_cartas()

func cabecalho(texto: String) -> void:
	painel.abrir(dados[atual].titulo, texto)

func sair() -> void:
	painel.botao("Deixar para depois", painel.fechar)

func mostrar_papeis() -> void:
	cabecalho(dados[atual].instrucao + "\n\nFolhas organizadas: %d / 3" % resposta.size())
	for i in ordem:
		var b: Button = painel.botao(dados[atual].fragmentos[i], escolher_papel.bind(i))
		b.disabled = i in resposta
	sair()

func escolher_papel(indice: int) -> void:
	if indice != resposta.size():
		falhou("As datas não se encaixam. Tente começar pela última aula.")
		return
	resposta.append(indice)
	if resposta.size() == 3:
		concluir()
	else:
		mostrar_papeis()

func mostrar_melodia() -> void:
	cabecalho(dados[atual].instrucao)
	var notas := ["Dó", "Ré", "Mi", "Sol"]
	painel.conteudo.text += "\n\n" + " → ".join(ordem.map(func(n): return notas[n]))
	mostrando = true
	for i in range(4):
		painel.botao(notas[i], tocar.bind(i))
	sair()
	var versao: int = painel.geracao
	await get_tree().create_timer(3.5, true).timeout
	if painel.geracao == versao and painel.painel.visible:
		mostrando = false
		painel.conteudo.text = "Agora você. 0 / 4 notas."

func tocar(nota: int) -> void:
	if mostrando:
		return
	if nota != ordem[resposta.size()]:
		falhou("A nota se perdeu no barulho da chuva. Você pode tentar de novo.")
		return
	resposta.append(nota)
	if resposta.size() == ordem.size():
		concluir()
	else:
		painel.conteudo.text = "%d / 4 notas lembradas." % resposta.size()

func mostrar_cartas() -> void:
	cabecalho(dados[atual].instrucao + "\n\nPares encontrados: %d / 3" % (resolvidas.size() / 2))
	for i in range(cartas.size()):
		var texto := "Folha %d · ?" % (i + 1)
		if i in abertas or i in resolvidas:
			texto = dados[atual].simbolos[cartas[i]]
		var b: Button = painel.botao(texto, virar.bind(i))
		b.disabled = ocupada or i in abertas or i in resolvidas
	sair()

func virar(indice: int) -> void:
	if ocupada or indice in resolvidas or indice in abertas:
		return
	abertas.append(indice)
	if abertas.size() == 2:
		if cartas[abertas[0]] == cartas[abertas[1]]:
			resolvidas.append_array(abertas)
			abertas.clear()
			if resolvidas.size() == cartas.size():
				concluir()
				return
		else:
			ocupada = true
	mostrar_cartas()
	if ocupada:
		var versao: int = painel.geracao
		await get_tree().create_timer(1.0, true).timeout
		if painel.geracao == versao and painel.painel.visible:
			abertas.clear()
			ocupada = false
			mostrar_cartas()

func falhou(texto: String) -> void:
	cabecalho(texto)
	painel.botao("Tentar novamente", iniciar.bind(atual))
	sair()

func concluir() -> void:
	var registro: String = dados[atual].registro
	var lore: String = dados[atual].get("lore", "")
	if not lore.is_empty():
		registro += "\n\n" + lore
	EstatisticasJogador.registrar("epilogo_" + atual, registro)
	cabecalho(registro)
	painel.botao("Guardar no caderno", painel.fechar)
