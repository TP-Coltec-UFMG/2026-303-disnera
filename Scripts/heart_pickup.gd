extends Area2D

@export var cura := 20
@export var tempo_de_vida := 12.0

var coletado := false
var tempo := 0.0
var base_y := 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	base_y = position.y

func _process(delta: float) -> void:
	tempo += delta
	position.y = base_y + sin(tempo * 4.0) * 2.0
	if tempo >= tempo_de_vida:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if coletado or body.name != "Player" or not body.has_method("curar"):
		return
	if body.call("curar", cura):
		coletado = true
		queue_free()
