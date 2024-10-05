extends Node2D

@onready var _Area2D = $Area2D

signal sugar_picked_up

func _ready():
	_Area2D.connect("body_entered", _on_body_entered)
	pass

func _on_body_entered(body):
	if body is CharacterBody2D:
		sugar_picked_up.emit()
		queue_free()
