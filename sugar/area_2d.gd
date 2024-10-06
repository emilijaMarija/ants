extends Node2D

@onready var _Area2D = $Area2D

func _ready():
	_Area2D.connect("body_entered", _on_body_entered)
	pass

func _on_body_entered(body: Node2D):
	if body.is_in_group("ants"):
		events.sugar_eaten.emit(self, body)
		queue_free()
