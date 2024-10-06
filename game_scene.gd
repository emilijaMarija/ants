extends Node2D

@export_group("Game options")
@export var ant_scene: PackedScene
@export var sugar_scene: PackedScene
@export var apple_scene: PackedScene

@onready var _ants_parent = $Ants
@onready var _sugars_parent = $Sugars
@onready var _apples_parent = $Apples
@onready var _cam = $Camera2D
@onready var _scoreboard = $Scoreboard
@onready var _initial_ant = $Ants/Ant
@onready var _menu = $Menu

@onready var _sugar_spawn_timer = $"Sugar spawn timer"

const max_sugars = 25
const max_apples = 25

enum {STATE_PRE_START, STATE_FIRST_SUGAR, STATE_MENU, STATE_GAMEPLAY}

var state = STATE_PRE_START

func change_state(state: int) -> void:
	self.state = state
	if state == STATE_MENU:
		begin_menu()
	elif state == STATE_GAMEPLAY:
		begin_game()
	elif state == STATE_PRE_START:
		begin_pre_start()
	elif state == STATE_FIRST_SUGAR:
		begin_first_sugar()
	elif state == STATE_MENU:
		begin_menu()
	

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
	
func _on_sugar_picked_up(sugar: Node2D, apple: Node2D) -> void:
	if state == STATE_FIRST_SUGAR:
		change_state(STATE_MENU)
	else:
		multiply_ants(1)

func begin_pre_start() -> void:
	_initial_ant.follow_mouse = false
	
func begin_first_sugar() -> void:
	_initial_ant.follow_mouse = true

func begin_menu() -> void:
	_menu.visible = true

func begin_game() -> void:
	_scoreboard.visible = true
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
		
func process_game(delta: float) -> void:
	var avg_pos = Vector2(0, 0)
	var ant_count = _ants_parent.get_child_count()
	for i in range(ant_count):
		avg_pos += _ants_parent.get_child(i).position
	if ant_count > 0:
		avg_pos /= ant_count
	_cam.position = avg_pos * 0.8 + get_global_mouse_position() * 0.2
	if ant_count == 0:
		get_tree().quit()
		
func _unhandled_key_input(event):
	if event.is_pressed() and state == STATE_PRE_START:
		change_state(STATE_FIRST_SUGAR)
		
func _input(event: InputEvent) -> void:
	if state == STATE_PRE_START and event is InputEventMouseButton:
		change_state(STATE_FIRST_SUGAR)

func process_menu(delta: float) -> void:
	pass

func _ready() -> void:
	_sugar_spawn_timer.connect("timeout", spawn_sugar)
	events.ant_eaten.connect(on_ant_eaten)
	events.apple_eaten.connect(_on_apple_picked_up)
	events.sugar_eaten.connect(_on_sugar_picked_up)
	change_state(STATE_PRE_START)

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
	if state != STATE_GAMEPLAY:
		return
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
	if state == STATE_GAMEPLAY:
		process_game(delta)
	elif state == STATE_MENU:
		process_menu(delta)
