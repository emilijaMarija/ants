extends Node2D

@export_group("Game options")
@export var ant_scene: PackedScene
@export var sugar_scene: PackedScene
@export var apple_scene: PackedScene

@onready var _ants_parent = $Ants
@onready var _sugars_parent = $Sugars
@onready var _apples_parent = $Apples
@onready var _cam = $Camera2D

@onready var _sugar_spawn_timer = $"Sugar spawn timer"

const max_sugars = 25
const max_apples = 25

func multiply_ants(count: int) -> void:
	var ant_count = _ants_parent.get_child_count()
	correct_zoom()
	for i in range(max(1, count)):
		var new_ant = ant_scene.instantiate()
		new_ant.position = _ants_parent.get_child(i).position
		new_ant.add_to_group("ants")
		_ants_parent.add_child(new_ant)

func _on_pumpkin_picked_up(pumpkin: Node2D, ant: Node2D) -> void:
	print("should multiply")
	multiply_ants(5)

func _on_apple_picked_up(apple: Node2D, ant: Node2D) -> void:
	multiply_ants(3)
	
func _on_sugar_picked_up() -> void:
	multiply_ants(1)

func _ready() -> void:
	correct_zoom()
	_sugar_spawn_timer.connect("timeout", spawn_sugar)
	events.ant_eaten.connect(on_ant_eaten)
	events.apple_eaten.connect(_on_apple_picked_up)
	events.pumpkin_eaten.connect(_on_pumpkin_picked_up)
	for i in 25:
		spawn_sugar()
		_spawn_apple()
	for sugar in get_tree().get_nodes_in_group("sugars"):
		sugar.connect("sugar_picked_up", _on_sugar_picked_up)

func correct_zoom() -> void:
	var ant_count = _ants_parent.get_child_count()
	_cam.zoom = Vector2(1, 1) * max(pow(0.98, ant_count) * 2, 0.6)
	#_cam.zoom = Vector2(1, 1) * 0.4

func generate_sugar_position() -> Vector2:
	var random_x = randf_range(32, 1000)
	var random_y = randf_range(-1080, 1080)
	
	return Vector2(random_x, random_y)
	

func generate_apple_position() -> Vector2:
	var random_x = randf_range(1200, 3200)
	var random_y = randf_range(-1000, 1000)
	
	return Vector2(random_x, random_y)

func spawn_sugar() -> void:
	if _sugars_parent.get_child_count() >= max_sugars:
		return
	var instance = sugar_scene.instantiate()
	instance.position = generate_sugar_position()
	instance.add_to_group("sugars")
	_sugars_parent.add_child(instance)
	instance.connect("sugar_picked_up", _on_sugar_picked_up)
	
func _spawn_apple() -> void:
	if get_tree().get_nodes_in_group("apples").size() >= max_apples:
		return
	var instance = apple_scene.instantiate()
	instance.position = generate_apple_position()
	instance.add_to_group("apples")
	_apples_parent.add_child(instance)

func on_ant_eaten(body: Node2D) -> void:
	correct_zoom()

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
