extends Label

func update_score() -> void:
	text = "SCORE: " + str(variables.score)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	variables.score_updated.connect(update_score)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
