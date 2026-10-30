extends Node2D

var ambiente := "Hall"
var ativo := false
var exterior := false
var tempo := 0.0
var gotas: Array[Vector2] = []
var som: AudioStreamPlayer
var placa: Label

func _ready() -> void:
	z_index = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	var rng := RandomNumberGenerator.new()
	rng.seed = 303
	for i in range(165):
		gotas.append(Vector2(rng.randf_range(0, 1000), rng.randf_range(-30, 650)))
	placa = Label.new()
	placa.add_theme_font_size_override("font_size", 15)
	placa.add_theme_color_override("font_color", Color("b5bac1"))
	placa.add_theme_color_override("font_shadow_color", Color("202738"))
	placa.add_theme_constant_override("shadow_offset_x", 2)
	placa.add_theme_constant_override("shadow_offset_y", 2)
	add_child(placa)
	# Ruído de chuva original, sem amostras externas. Loop e volume respeitam o bus.
	var bytes := PackedByteArray()
	bytes.resize(16000 * 4 * 2)
	var suave := 0.0
	for i in range(16000 * 4):
		var ruido := rng.randf_range(-1, 1)
		suave = lerpf(suave, ruido, 0.18)
		bytes.encode_s16(i * 2, int((suave * 0.65 + ruido * 0.12) * 26000))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 16000
	stream.data = bytes
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = 64000
	som = AudioStreamPlayer.new()
	som.stream = stream
	som.bus = &"Efeitos Sonoros"
	add_child(som)

func configurar(local: String, epilogo: bool) -> void:
	ambiente = local
	ativo = epilogo
	exterior = local in ["Exterior", "Quadra"]
	visible = ativo
	placa.visible = ativo and local == "Hall"
	placa.text = "TURMA FORMADA\nAté qualquer dia."
	placa.position = Vector2(375, 78)
	som.volume_db = -16.0 if exterior else -30.0
	if ativo and not som.playing:
		som.play()
	elif not ativo:
		som.stop()
	queue_redraw()

func _process(delta: float) -> void:
	if not ativo:
		return
	tempo += delta
	if exterior:
		for i in range(gotas.size()):
			gotas[i] += Vector2(-65, 330) * delta
			if gotas[i].y > 650:
				gotas[i].y = -20
			if gotas[i].x < 0:
				gotas[i].x += 960
		queue_redraw()

func _draw() -> void:
	if not ativo:
		return
	if exterior:
		for gota in gotas:
			draw_line(gota, gota + Vector2(-2, 12), Color(0.64, 0.73, 0.83, 0.48), 1)
		for i in range(12):
			var pos := Vector2(190 + (i * 71) % 580, 330 + (i * 31) % 110)
			var raio := fmod(tempo * 10.0 + i, 13.0) + 2.0
			draw_arc(pos, raio, 0, TAU, 12, Color(0.65, 0.72, 0.8, 0.12), 1)
	else:
		# Papéis esquecidos e fitas caídas; só no retorno de dezembro.
		for i in range(8):
			var pos := Vector2(260 + (i * 83) % 420, 280 + (i * 39) % 170)
			draw_rect(Rect2(pos, Vector2(9, 6)), Color("8f9294"))
			draw_line(pos + Vector2(2, 3), pos + Vector2(7, 3), Color("5c6670"), 1)
		if ambiente == "Hall":
			draw_line(Vector2(345, 76), Vector2(620, 90), Color("777c89"), 1)
			for i in range(6):
				var x := 350.0 + i * 48
				draw_colored_polygon(PackedVector2Array([Vector2(x, 80), Vector2(x + 18, 81), Vector2(x + 9, 96)]), Color("696b83"))

func _exit_tree() -> void:
	if is_instance_valid(som):
		som.stop()
