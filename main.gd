extends Control

@export var menu: VBoxContainer
@export var settings: VBoxContainer
@export var controles: VBoxContainer
@export var acessibilidade: VBoxContainer
@export var audio: VBoxContainer
@export var comecar: VBoxContainer

# Botões de Navegação
@export var start: Button
@export var voltar: Button
@export var options: Button
@export var quit: Button

# Botões dentro do menu Settings
@export var acessibilidade_button: Button
@export var controles_button: Button
@export var som_button: Button

var nav_stack: Array[Control] = []
var painel_atual: Control

func _ready() -> void:
	_esconder_todos_paineis()
	painel_atual = menu
	painel_atual.visible = true
	_atualizar_botao_voltar()
	
	start.pressed.connect(_ir_para.bind(comecar))
	options.pressed.connect(_ir_para.bind(settings))
	quit.pressed.connect(func(): get_tree().quit())
	
	acessibilidade_button.pressed.connect(_ir_para.bind(acessibilidade))
	controles_button.pressed.connect(_ir_para.bind(controles))
	som_button.pressed.connect(_ir_para.bind(audio))
	
	voltar.pressed.connect(_voltar)

func _esconder_todos_paineis():
	menu.visible = false
	settings.visible = false
	controles.visible = false
	acessibilidade.visible = false
	audio.visible = false
	comecar.visible = false

func _atualizar_botao_voltar():
	voltar.visible = nav_stack.size() > 0
	
func _ir_para(proximo_painel: Control):
	if painel_atual:
		nav_stack.append(painel_atual) 
		painel_atual.visible = false
		
	painel_atual = proximo_painel
	painel_atual.visible = true
	_atualizar_botao_voltar()

func _voltar():
	if nav_stack.is_empty():
		return
		
	painel_atual.visible = false
	painel_atual = nav_stack.pop_back() 
	painel_atual.visible = true
	_atualizar_botao_voltar()
