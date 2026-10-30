extends Control

@onready var personagem: TextureRect = $Personagem
@onready var texto: Label = $Texto
@onready var buraco: ColorRect = $Buraco
var pulando := false

func _ready() -> void:
	texto.text = "Algo se move sob a cidade..."
	await get_tree().create_timer(1.2).timeout
	texto.text = "É hora de descer aos esgotos."
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(personagem, "position:y", buraco.position.y - 5.0, 2.0)
	tween.tween_property(personagem, "scale", Vector2(0.35, 0.35), 2.0)
	await tween.finished
	texto.text = ""
	var fade := create_tween()
	fade.tween_property(self, "modulate:a", 0.0, 0.65)
	await fade.finished
	get_tree().change_scene_to_file("res://scenes/main_game_play.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not pulando:
		pulando = true
		get_tree().change_scene_to_file("res://scenes/main_game_play.tscn")
