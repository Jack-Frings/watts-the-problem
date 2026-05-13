extends Control

@onready var shader = $Shader
@onready var level_complete = $LevelComplete
@onready var button = $LevelButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shader.visible = false
	level_complete.visible = false
	button.visible = false
	button.disabled = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_main_level_completed() -> void:
	shader.visible = true
	level_complete.visible = true
	button.visible = true
	button.disabled = false


func _on_level_button_pressed() -> void:
	shader.visible = false
	level_complete.visible = false
	button.visible = false
	button.disabled = true
