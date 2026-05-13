extends Node2D

@onready var title = $Title
@onready var tile_bg = $TileBackground
@onready var credits = $Credits
@onready var positive = $Positive
@onready var negative = $Negative
@onready var final_message = $FinalMessage

var time = 0.0
var credits_y = 192

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title.visible = false
	tile_bg.visible = false
	positive.visible = false
	negative.visible = false
	final_message.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()
	time += delta 
	if time > 1.0:
		title.visible = true
		tile_bg.visible = true
	if time > 1.5:
		credits_y = 192 - (time-1.5)*80
		if credits_y < 65:
			credits_y = 65
		credits.position = Vector2(90, credits_y)
	if time > 3.5:
		positive.visible = true
		negative.visible =  true
	if time > 4.5:
		final_message.visible = true
