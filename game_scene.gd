extends Node2D

@export_group("Game options")
@export var ant_scene: PackedScene

@onready var _ants_parent = $Ants

func _ready() -> void:
	for sugar in get_tree().get_nodes_in_group("sugars"):
		sugar.connect("sugar_picked_up", _on_sugar_picked_up)

func _on_sugar_picked_up() -> void:
	var ant_count = _ants_parent.get_child_count()
	for i in range(ant_count):
		var new_ant = ant_scene.instantiate()
		new_ant.position = _ants_parent.get_child(i).position
		_ants_parent.add_child(new_ant)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
