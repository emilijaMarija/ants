extends Node2D

@export_group("Game options")
@export var ant_scene: PackedScene
@export var sugar_scene: PackedScene

@onready var _ants_parent = $Ants
@onready var _sugars_parent = $Sugars
@onready var _cam = $Camera2D

@onready var _sugar_spawn_timer = $"Sugar spawn timer"

const max_sugars = 20

func correct_zoom() -> void:
	var ant_count = _ants_parent.get_child_count()
	var max_ants_zoom = 30.0
	var x = clamp(ant_count, 0, max_ants_zoom)
	_cam.zoom = Vector2(1, 1) * (2.0 - (2.0 / max_ants_zoom) * x)

func generate_sugar_position() -> Vector2:
	var random_x = randf_range(32, 1000)
	var random_y = randf_range(32, -2000)
	
	return Vector2(random_x, random_y)

func spawn_sugar() -> void:
	if _sugars_parent.get_child_count() >= max_sugars:
		return
	var instance = sugar_scene.instantiate()
	instance.position = generate_sugar_position()
	instance.add_to_group("sugars")
	_sugars_parent.add_child(instance)
	instance.connect("sugar_picked_up", _on_sugar_picked_up)

func on_ant_eaten(body: Node2D) -> void:
	correct_zoom()

func _ready() -> void:
	_sugar_spawn_timer.connect("timeout", spawn_sugar)
	events.ant_eaten.connect(on_ant_eaten)
	for i in 10:
		spawn_sugar()
	for sugar in get_tree().get_nodes_in_group("sugars"):
		sugar.connect("sugar_picked_up", _on_sugar_picked_up)

func _on_sugar_picked_up() -> void:
	var ant_count = _ants_parent.get_child_count()
	correct_zoom()
	for i in range(max(1, ant_count * 0.1)):
		var new_ant = ant_scene.instantiate()
		new_ant.position = _ants_parent.get_child(i).position
		new_ant.add_to_group("ants")
		_ants_parent.add_child(new_ant)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var avg_pos = Vector2(0, 0)
	var ant_count = _ants_parent.get_child_count()
	for i in range(ant_count):
		avg_pos += _ants_parent.get_child(i).position
	if ant_count > 0:
		avg_pos /= ant_count
	_cam.position = avg_pos * 0.8 + get_global_mouse_position() * 0.2
	if ant_count == 0:
		get_tree().quit()
