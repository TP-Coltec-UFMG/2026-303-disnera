extends VBoxContainer

@export var master_slider: HSlider
@export var music_slider: HSlider
@export var efeito_slider: HSlider

@onready var Fundo: AudioStreamPlayer = $"../AudioStreamPlayer"

const MAX_DC = 0.0
const MIN_DC = -60.0

func _ready() -> void:
	_sync_sliders()
	
	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	efeito_slider.value_changed.connect(_on_efeitos_volume_changed)

func _sync_sliders():
	master_slider.value = _db_to_slider(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	music_slider.value = _db_to_slider(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	efeito_slider.value = _db_to_slider(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Efeitos")))


func _slider_to_db(valor: float) -> float:
	if valor <= 0.0:
		return MIN_DC
	
	var linear = valor / 100
	var db = linear_to_db(linear)
	return clamp(db, MIN_DC, MAX_DC)

func _db_to_slider(db: float) -> float:
	if db <= MIN_DC:
		return 0.0
	
	var linear	= db_to_linear(db)
	return clamp(linear * 100.0, 0.0, 100.0)
	
func defineVolume(bus_name: String, valor: float):
	var db = _slider_to_db(valor)
	var bus_index = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_index, db)
	AudioServer.set_bus_mute(bus_index, db <= MIN_DC)
	
func _on_master_volume_changed(valor: float):
	defineVolume("Master", valor)
func _on_music_volume_changed(valor: float):
	defineVolume("Music", valor)
func _on_efeitos_volume_changed(valor: float):
	defineVolume("Efeitos", valor)
	
	
