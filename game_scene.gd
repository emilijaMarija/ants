extends Node2D

@export_group("Game options")
@export var ant_scene: PackedScene

@onready var _ants_parent = $Ants
@onready var _cam = $Camera2D

func _ready() -> void:
	for sugar in get_tree().get_nodes_in_group("sugars"):
		sugar.connect("sugar_picked_up", _on_sugar_picked_up)

func _on_sugar_picked_up() -> void:
	var ant_count = _ants_parent.get_child_count()
	_cam.zoom *=0.9
	for i in range(ant_count):
		var new_ant = ant_scene.instantiate()
		new_ant.position = _ants_parent.get_child(i).position
		_ants_parent.add_child(new_ant)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var avg_pos = Vector2(0, 0)
	var ant_count = _ants_parent.get_child_count()
	for i in range(ant_count):
		avg_pos += _ants_parent.get_child(i).position
	if ant_count > 0:
		avg_pos /= ant_count
	_cam.position = avg_pos
