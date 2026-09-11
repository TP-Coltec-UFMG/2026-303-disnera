extends Node

var vida: int = 100
var max_vida: int = 100

var fase_atual: int = 1


func reset() -> void:
	vida = max_vida
	fase_atual = 1
