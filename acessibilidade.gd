extends VBoxContainer

@export var dificuldade: OptionButton

func _ready() -> void:
	dificuldade.add_item("Pacifico")
	dificuldade.add_item("Facil")
	dificuldade.add_item("Médio")
	dificuldade.add_item("Difícil")
