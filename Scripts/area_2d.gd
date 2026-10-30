extends Area2D

func _on_body_entered(body):
	print("1")

	if body.name == ("Player"):
		print("2")

		var erro = get_tree().change_scene_to_file("res://scenes/level_2.tscn")

		print("3")
		print(erro)
