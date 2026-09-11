extends CheckButton

func _ready():
	toggled.connect(_on_toggled)

func _on_toggled(pressed):

	var theme = Theme.new()

	if pressed:
		theme.default_font_size = 40
	else:
		theme.default_font_size = 20

	get_tree().root.theme = theme
