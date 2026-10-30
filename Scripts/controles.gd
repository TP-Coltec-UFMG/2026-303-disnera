extends VBoxContainer

@export var cima: Button
@export var baixo: Button
@export var esquerda: Button
@export var direita: Button
@export var interagir: Button
@export var bater: Button
@export var dash: Button

const CONFIG_PATH := "user://disnera_controles.cfg"

const ACOES: Dictionary = {
	"cima": "move_up",
	"baixo": "move_down",
	"esquerda": "move_left",
	"direita": "move_right",
	"bater": "hit",
	"interagir": "interact",
	"dash": "dash"
}

var esperando_comando := ""


func _ready() -> void:
	_carregar_controles()
	_atualizar_textos_dos_botoes()

	cima.pressed.connect(
		_on_rebind_button_pressed.bind("cima")
	)

	baixo.pressed.connect(
		_on_rebind_button_pressed.bind("baixo")
	)

	esquerda.pressed.connect(
		_on_rebind_button_pressed.bind("esquerda")
	)

	direita.pressed.connect(
		_on_rebind_button_pressed.bind("direita")
	)

	bater.pressed.connect(
		_on_rebind_button_pressed.bind("bater")
	)

	interagir.pressed.connect(
		_on_rebind_button_pressed.bind("interagir")
	)

	dash.pressed.connect(
		_on_rebind_button_pressed.bind("dash")
	)


func _get_button(comando: String) -> Button:
	match comando:
		"cima":
			return cima
		"baixo":
			return baixo
		"esquerda":
			return esquerda
		"direita":
			return direita
		"bater":
			return bater
		"interagir":
			return interagir
		"dash":
			return dash
		_:
			return null


func _atualizar_texto_do_botao(comando: String) -> void:
	var acao: String = ACOES[comando]
	var eventos := InputMap.action_get_events(acao)
	var texto := "Não definido"

	if not eventos.is_empty():
		texto = _formatar_evento(eventos[0])

	var botao := _get_button(comando)

	if botao:
		botao.text = texto


func _atualizar_textos_dos_botoes() -> void:
	for comando in ACOES:
		_atualizar_texto_do_botao(comando)


func _formatar_evento(evento: InputEvent) -> String:
	if evento is InputEventMouseButton:
		match evento.button_index:
			MOUSE_BUTTON_LEFT:
				return "Mouse Esq."
			MOUSE_BUTTON_RIGHT:
				return "Mouse Dir."
			MOUSE_BUTTON_MIDDLE:
				return "Mouse Meio."
			_:
				return "Mouse " + str(evento.button_index)

	if evento is InputEventKey:
		var evento_tecla := evento as InputEventKey
		var codigo: int = int(evento_tecla.physical_keycode)

		if codigo == 0:
			codigo = int(evento_tecla.keycode)

		if codigo != 0:
			return OS.get_keycode_string(codigo)

	return "Não definido"


func _on_rebind_button_pressed(comando: String) -> void:
	esperando_comando = comando

	var botao := _get_button(comando)

	if botao:
		botao.text = "Pressione..."

	set_process_input(true)


func _input(evento: InputEvent) -> void:
	if esperando_comando == "":
		return

	var tecla_valida := false
	var mouse_valido := false

	if evento is InputEventKey:
		tecla_valida = evento.pressed and not evento.echo

	if evento is InputEventMouseButton:
		mouse_valido = evento.pressed

	if not tecla_valida and not mouse_valido:
		return

	get_viewport().set_input_as_handled()

	var acao: String = ACOES[esperando_comando]
	var novo_evento: InputEvent = evento.duplicate()

	InputMap.action_erase_events(acao)
	InputMap.action_add_event(acao, novo_evento)

	_salvar_controle(acao, novo_evento)
	_atualizar_texto_do_botao(esperando_comando)

	esperando_comando = ""
	set_process_input(false)


func _carregar_controles() -> void:
	var config := ConfigFile.new()

	if config.load(CONFIG_PATH) != OK:
		return

	for comando in ACOES:
		var acao: String = ACOES[comando]

		if not config.has_section_key("controles", acao):
			continue

		var dados = config.get_value("controles", acao)
		var evento := _criar_evento(dados)

		if evento:
			InputMap.action_erase_events(acao)
			InputMap.action_add_event(acao, evento)


func _salvar_controle(acao: String, evento: InputEvent) -> void:
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)

	var dados: Dictionary = {}

	if evento is InputEventKey:
		dados = {
			"tipo": "tecla",
			"keycode": evento.keycode,
			"physical_keycode": evento.physical_keycode
		}

	elif evento is InputEventMouseButton:
		dados = {
			"tipo": "mouse",
			"button_index": evento.button_index
		}

	if not dados.is_empty():
		config.set_value("controles", acao, dados)
		config.save(CONFIG_PATH)


func _criar_evento(dados) -> InputEvent:
	if not (dados is Dictionary):
		return null

	if dados.get("tipo", "") == "tecla":
		var evento_tecla := InputEventKey.new()
		evento_tecla.keycode = int(
			dados.get("keycode", 0)
		)
		evento_tecla.physical_keycode = int(
			dados.get("physical_keycode", 0)
		)
		return evento_tecla

	if dados.get("tipo", "") == "mouse":
		var evento_mouse := InputEventMouseButton.new()
		evento_mouse.button_index = int(
			dados.get("button_index", 0)
		)
		return evento_mouse

	return null
