extends "res://Scripts/adventure_point.gd"

var aparencia := 0
var rota: Array[Vector2] = []
var velocidade := 23.0
var tocando := false
var instrumento := ""
var indice := 0
var espera := 0.0
var relogio := 0.0
var sprite: AnimatedSprite2D
var ultima_direcao := Vector2.DOWN
var base_y := 0.0

func _ready() -> void:
	super._ready()
	mostrar_nome = false
	var modelo := preload("res://scenes/Player.tscn").instantiate()
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = modelo.get_node("Player/AnimatedSprite2D").sprite_frames
	modelo.free()
	sprite.show_behind_parent = true
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2(2, 2)
	sprite.position.y = -12
	base_y = sprite.position.y
	var paletas := [
		["452e2c", "705044", "c58a60", "955b3c", "dbaf52", "ac7b34", "765125", "438b83", "2c6265"],
		["352c30", "5a4544", "edbd91", "bd865c", "7eabd0", "4c79a0", "345572", "464f70", "30364d"],
		["282a32", "414350", "dfac80", "ae7956", "edf1df", "c2d1bd", "879c8b", "417768", "2b514c"],
		["29252a", "4d3936", "b57a50", "805033", "e8a165", "bd6c3e", "87472d", "6c7554", "464f3d"]
	]
	var nomes := ["cabelo_escuro", "cabelo_claro", "pele_clara", "pele_sombra", "roupa_clara", "roupa_media", "roupa_sombra", "calca_clara", "calca_sombra"]
	var material_paleta := ShaderMaterial.new()
	material_paleta.shader = preload("res://Shaders/npc_palette.gdshader")
	for i in range(nomes.size()):
		material_paleta.set_shader_parameter(nomes[i], Color(paletas[aparencia % 4][i]))
	sprite.material = material_paleta
	add_child(sprite)
	sprite.play("parado_down")

func _physics_process(delta: float) -> void:
	relogio += delta
	if tocando:
		sprite.position.y = base_y - absf(sin(relogio * 5.24)) * 2.0
		sprite.play("parado_down")
		queue_redraw()
		return
	if rota.is_empty() or (is_instance_valid(jogador) and global_position.distance_to(jogador.global_position) < 75):
		_animar(false, ultima_direcao)
		return
	espera = maxf(0.0, espera - delta)
	if espera > 0:
		_animar(false, ultima_direcao)
		return
	var alvo := rota[indice]
	var dir := alvo - position
	if dir.length() < 3:
		indice = (indice + 1) % rota.size()
		espera = 0.8
	else:
		position = position.move_toward(alvo, velocidade * delta)
		ultima_direcao = dir.normalized()
		_animar(true, ultima_direcao)

func _animar(andando: bool, direcao: Vector2) -> void:
	var prefixo := "correr" if andando else "parado"
	var lado := "down"
	if absf(direcao.x) > absf(direcao.y):
		lado = "right"
		sprite.flip_h = direcao.x < 0
	else:
		lado = "up" if direcao.y < 0 else "down"
		sprite.flip_h = false
	sprite.play(prefixo + "_" + lado)

func _draw() -> void:
	if not tocando:
		return
	# Pequenos acentos animados sobre os instrumentos pintados no palco.
	var acento := sin(relogio * 10.48) * 3.0
	if instrumento == "guitarra":
		draw_circle(Vector2(0, -8), 6, Color("9c512d"))
		draw_line(Vector2(2, -10), Vector2(17, -22), Color("dcb876"), 4)
		draw_line(Vector2(-3, -9), Vector2(4, -7 + acento), Color("f1c491"), 2)
	elif instrumento == "bateria":
		draw_line(Vector2(-7, -11), Vector2(-14, -22 + acento), Color("e5ca90"), 2)
		draw_line(Vector2(7, -11), Vector2(14, -22 - acento), Color("e5ca90"), 2)
	elif instrumento == "teclado":
		draw_line(Vector2(-6, -10), Vector2(-7, -4 + acento), Color("e6bc8b"), 3)
		draw_line(Vector2(6, -10), Vector2(7, -4 - acento), Color("e6bc8b"), 3)
