extends Node2D

var titulo := ""
var acao: Callable
var disponivel: Callable
var jogador: Node2D
var legenda: Label
var raio := 62.0
var mostrar_nome := true
var dica := "[E] conversar / usar"

func _ready() -> void:
	add_to_group("interacoes")
	legenda = Label.new()
	legenda.position = Vector2(-100, -52)
	legenda.size = Vector2(200, 48)
	legenda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	legenda.add_theme_font_size_override("font_size", 13)
	legenda.add_theme_color_override("font_shadow_color", Color(0.05, 0.04, 0.02))
	legenda.add_theme_constant_override("shadow_offset_x", 2)
	legenda.add_theme_constant_override("shadow_offset_y", 2)
	legenda.z_index = 50
	legenda.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(legenda)
	visible = esta_disponivel()

func esta_disponivel() -> bool:
	return not disponivel.is_valid() or bool(disponivel.call())

func mais_proximo() -> bool:
	if not esta_disponivel() or not is_instance_valid(jogador):
		return false
	var distancia := global_position.distance_to(jogador.global_position)
	if distancia > raio:
		return false
	for ponto in get_tree().get_nodes_in_group("interacoes"):
		if ponto == self or not ponto.esta_disponivel() or ponto.jogador != jogador:
			continue
		var outra: float = ponto.global_position.distance_to(jogador.global_position)
		if outra <= ponto.raio and (outra < distancia or (is_equal_approx(outra, distancia) and ponto.get_instance_id() < get_instance_id())):
			return false
	return true

func _process(_delta: float) -> void:
	visible = esta_disponivel()
	if not visible:
		return
	var perto := mais_proximo()
	legenda.text = titulo + ("\n" + dica if perto else "")
	legenda.visible = mostrar_nome or perto

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not event.is_echo() and mais_proximo():
		get_viewport().set_input_as_handled()
		acao.call_deferred()
