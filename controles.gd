extends VBoxContainer

@export var cima: Button
@export var baixo: Button
@export var esquerda: Button
@export var direita: Button
@export var interagir: Button
@export var bater: Button

const ACOES = {
	"cima" = "move_up",
	"baixo" = "move_down",
	"esquerda" = "move_left",
	"direita" = "move_right",
	"bater" = "hit",
	"interagir" = "interact"
}

var waiting_for_input: String = ""

func _ready():
	_updade_button_labels()
 
	cima.pressed.connect(_on_rebind_button_pressed.bind("cima"))
	baixo.pressed.connect(_on_rebind_button_pressed.bind("baixo"))
	esquerda.pressed.connect(_on_rebind_button_pressed.bind("esquerda"))
	direita.pressed.connect(_on_rebind_button_pressed.bind("direita"))
	bater.pressed.connect(_on_rebind_button_pressed.bind("bater"))
	interagir.pressed.connect(_on_rebind_button_pressed.bind("interagir"))

func _get_button(tecla: String) -> Button:
	match tecla:
		"cima": return cima 
		"baixo": return baixo
		"esquerda": return esquerda
		"direita": return direita
		"bater": return bater
		"interagir": return interagir
		_: return null
		
func _update_button_label(tecla: String):
	var acao = ACOES[tecla]
	var eventos = InputMap.action_get_events(acao)
	
	var label_texto = "Não definido"
	
	if eventos.size() > 0:
		var evento = eventos[0]
		if evento is InputEventMouseButton:
			match evento.button_index:
				MOUSE_BUTTON_LEFT: label_texto = "Mouse Esq."
				MOUSE_BUTTON_RIGHT: label_texto = "Mouse Dir."
				MOUSE_BUTTON_MIDDLE: label_texto = "Mouse Meio."
				_: label_texto = "Mouse " + str(evento.button_index)
		if evento is InputEventKey:
			if evento.keycode != 0:
				label_texto = OS.get_keycode_string(evento.keycode)
			elif evento.physical_keycode != 0:
				label_texto = OS.get_keycode_string(evento.physical_keycode)
	
	var btn = _get_button(tecla)
	btn.text = "%s" % [label_texto]
		
func _updade_button_labels():
	for dir in ACOES.keys():
		_update_button_label(dir)

func _on_rebind_button_pressed(tecla: String):
	waiting_for_input = tecla
	var btn = _get_button(tecla)
	btn.text = "..."
	set_process_input(true)

func _input(evento):
	if waiting_for_input == "":
		return
	var teclas = evento is InputEventKey and evento.pressed
	var mouse = evento is InputEventMouseButton and evento.pressed 
	if teclas or mouse:
		get_viewport().set_input_as_handled()
		
		var acao = ACOES[waiting_for_input]
		InputMap.action_erase_events(acao)
		InputMap.action_add_event(acao, evento)
 
		_update_button_label(waiting_for_input)
		waiting_for_input = ""
 
		waiting_for_input = ""
		set_process_input(false)
	
		
