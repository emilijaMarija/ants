extends Node2D

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if !body.is_in_group("ants"):
		return
	events.pumpkin_eaten.emit(self, body)
	print("emitting event")
	queue_free()
