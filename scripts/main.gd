extends Node

@onready var circuit_layer = $"TileMap/CircuitLayer"

@onready var battery_transition_left_layer = $"TileMap/BatteryTransitionLayer/Left"
@onready var battery_transition_right_layer = $"TileMap/BatteryTransitionLayer/Right"
@onready var battery_transition_down_layer = $"TileMap/BatteryTransitionLayer/Down"

@onready var battery_top_layer = $"TileMap/BatteryTopLayer"
@onready var selection_layer = $"TileMap/SelectionLayer"
@onready var icon_layer =  $"TileMap/IconLayer"

var wattage_label_scene = preload("res://scenes/battery_wattage_label.tscn")

var tiles: Array = [StraightConnector.new(0), StraightConnector.new(1), \
					RightAngleConnector.new(0), RightAngleConnector.new(1), \
					RightAngleConnector.new(2), RightAngleConnector.new(3), \
					ThreeWayConnector.new(0), Resistor.new(0)]
					
var tile_counts =  [3, 5, \
					2, 2, \
					1, 4, \
					1, 10]

var circuit_grid
var component_lib

var circuit_width = 10
var circuit_height = 6

var abs_circuit_origin = Vector2i(4, 1)
var abs_component_lib_origin = Vector2i(1, 1)

var component_lib_origin = abs_component_lib_origin - abs_circuit_origin

var component_lib_width = 2
var component_lib_height = 6
var px = 0
var py = 0
var p_tile = null

enum WORKSPACE { CIRCUIT, COMPONENT_LIB }
var p_workspace = WORKSPACE.CIRCUIT

var move_timer_x = 0.0
var move_timer_y = 0.0
var move_delay = 0.3
var move_repeat = 0.15

var cursor_icon_shift_time = 0.0
var cursor_icon_shift_timer = 0.5
var cursor_icon_id = 0

func _ready() -> void:
	circuit_grid = CircuitGrid.new(circuit_layer, battery_top_layer, \
									battery_transition_left_layer, battery_transition_right_layer, battery_transition_down_layer, \
									icon_layer, circuit_width, circuit_height, wattage_label_scene, self)
									
	component_lib = ComponentLib.new(circuit_layer, icon_layer, component_lib_origin, component_lib_width, component_lib_height, \
										tiles, tile_counts, self)
			
	circuit_grid.edit_tile(4, 3, BatteryPositive.new(0), true)
	circuit_grid.edit_tile(3, 5, BatteryNegative.new(0, 1.7), true)
	circuit_grid.edit_tile(0, 3, BatteryNegative.new(0, 3.3), true)
	circuit_grid.edit_tile(8, 3, BatteryNegative.new(0, 3.3), true)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	player_action()
	circuit_grid.render()
	component_lib.render()
	cursor_render(delta)
	
func _input(event):
	var opx = px
	var opy = py
	var op_workspace = p_workspace
	
	if event is InputEventMouseMotion:
		var x = event.position.x
		var y = event.position.y
		if abs_circuit_origin.x*24 < x and x < (abs_circuit_origin.x+circuit_width)*24:
			if abs_circuit_origin.y*24 < y and y < (abs_circuit_origin.y+circuit_height)*24:
				px = ((int)(x) / 24) - abs_circuit_origin.x
				py = ((int)(y) / 24) - abs_circuit_origin.y
				p_workspace = WORKSPACE.CIRCUIT
				
		if abs_component_lib_origin.x*24 < x and x < (abs_component_lib_origin.x+component_lib_width)*24:
			if abs_component_lib_origin.y*24 < y and y < (abs_component_lib_origin.y+component_lib_height)*24:
				px = ((int)(x) / 24) - abs_circuit_origin.x
				py = ((int)(y) / 24) - abs_circuit_origin.y
				p_workspace = WORKSPACE.COMPONENT_LIB
				
		if opx != px or opy != py or op_workspace != p_workspace:
			self.selection_layer.erase_cell(Vector2i(opx, opy))
		
func cursor_render(delta: float) -> void:
	cursor_icon_shift_time += delta
	if cursor_icon_shift_time > cursor_icon_shift_timer:
		cursor_icon_shift_time = 0.0
		if cursor_icon_id == 0: cursor_icon_id = 1
		elif cursor_icon_id == 1: cursor_icon_id = 0
		
		
	if p_tile == null or p_workspace == WORKSPACE.COMPONENT_LIB:
		selection_layer.modulate = Color(1, 1, 1, 1)
		self.selection_layer.set_cell(Vector2i(px, py), cursor_icon_id, Vector2i(0, 0)) # selection-box icon
	else:
		selection_layer.modulate = Color(0.5, 0.5, 0.5, 0.5)
		self.selection_layer.set_cell(Vector2i(px, py),2, Vector2i(p_tile.atlas_x, p_tile.atlas_y), p_tile.get_rotation()) # grayed-out tile icon

	

func player_action() -> void:
	if Input.is_action_pressed("erase") and p_workspace == WORKSPACE.CIRCUIT:
		var tile = circuit_grid.map[py][px]
		component_lib.add_tile_to_parts(tile)
		circuit_grid.erase_tile(px, py)
		
		if p_tile == null: p_tile = tile
		
	if Input.is_action_pressed("select"):
		if p_workspace ==  WORKSPACE.COMPONENT_LIB:
			p_tile = component_lib.copy_tile(px-component_lib_origin.x, py-component_lib_origin.y)
		elif p_workspace == WORKSPACE.CIRCUIT:
			if not circuit_grid.locked_table[py][px]:
				if component_lib.remove_tile_from_parts(p_tile):
					component_lib.add_tile_to_parts(circuit_grid.map[py][px])
					circuit_grid.edit_tile(px, py, p_tile.duplicate())
					
					if component_lib.get_count(p_tile) <= 0:
						p_tile = null
		
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()
