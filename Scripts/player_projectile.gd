extends "res://Scripts/poison_projectile.gd"

func _ready() -> void:
	collision_layer = 0
	collision_mask = 6
	super._ready()

func _on_body_entered(body: Node2D) -> void:
	if not ativo or body.name == "Player":
		return
	ativo = false
	if body.has_method("take_damage"):
		body.take_damage(dano, global_position - direcao * 20.0)
	queue_free()
