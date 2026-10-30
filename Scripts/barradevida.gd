extends Node2D

@onready var vida_barra: Sprite2D = $vida
@onready var default_width: float = vida_barra.region_rect.size.x
@onready var default_height: float = vida_barra.region_rect.size.y

func update_vida(new_vida: int) -> void:
	# Garante que a vida fique entre 0 e 100
	new_vida = clamp(new_vida, 0, 100)

	# Calcula a nova largura da barra
	var new_width = (new_vida / 100.0) * default_width

	# Atualiza apenas a largura da região
	vida_barra.region_rect = Rect2(
		0,
		0,
		new_width,
		default_height
	)
