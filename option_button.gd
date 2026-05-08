extends OptionButton

@onready var tema = preload("res://tema.tres")

func _ready():

	add_item("Pequeno")
	add_item("Médio")
	add_item("Grande")

	select(1)

	_aplicar_fonte(32)

	item_selected.connect(_on_item_selected)


func _on_item_selected(index):

	match index:
		0:
			_aplicar_fonte(24)

		1:
			_aplicar_fonte(32)

		2:
			_aplicar_fonte(40)


func _aplicar_fonte(tamanho):

	tema.set_font_size("font_size", "Label", tamanho)
	tema.set_font_size("font_size", "Button", tamanho)
	tema.set_font_size("font_size", "OptionButton", tamanho)
	tema.set_font_size("font_size", "CheckButton", tamanho)
	tema.set_font_size("font_size", "RichTextLabel", tamanho)

	get_tree().root.theme = tema
