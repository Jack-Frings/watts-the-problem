extends Node
@onready var rendering_layer = $"TileMap/CircuitLayer"
@onready var selection_rendering_layer = $"TileMap/SelectionLayer"
@onready var icon_rendering_layer =  $"TileMap/IconLayer"

var straight_connector_count = 90
var right_angle_connector_count = 90
var three_way_connector_count = 90
var four_way_connector_count = 90

var circuit_grid
var component_lib

var circuit_width = 10
var circuit_height = 6

var component_lib_origin = Vector2i(-3, 0)
var component_lib_width = 2
var component_lib_height = 2

var px = 0
var py = 0
var p_tile = null

enum WORKSPACE { CIRCUIT, COMPONENT_LIB }
var p_workspace = WORKSPACE.CIRCUIT

var move_timer_x = 0.0
var move_timer_y = 0.0
var move_delay = 0.5
var move_repeat = 0.15


func _ready() -> void:
	print("check")
	circuit_grid = CircuitGrid.new(rendering_layer, icon_rendering_layer, circuit_width, circuit_height)
	component_lib = ComponentLib.new(rendering_layer, component_lib_origin, component_lib_width, component_lib_height)
			
	circuit_grid.edit_tile(0, 0, BatteryPositiveTop.new(0), true)
	circuit_grid.edit_tile(0, 1, BatteryPositiveBottom.new(0), true)
	circuit_grid.edit_tile(8, 4, BatteryNegativeTop.new(0), true)
	circuit_grid.edit_tile(8, 5, BatteryNegativeBottom.new(0), true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	player_movement(delta)
	player_action()
	circuit_grid.render()
	component_lib.render()
	
	display_part_count(0, 0, straight_connector_count)
	display_part_count(1, 0, right_angle_connector_count)
	display_part_count(0, 1, three_way_connector_count)
	display_part_count(1, 1, four_way_connector_count)
	
func display_part_count(x: int, y: int, count: int):
	icon_rendering_layer.set_cell(Vector2i(component_lib_origin.x+x, component_lib_origin.y+y), 0, Vector2i(count % 10, count / 10))

func player_action() -> void:
	if Input.is_action_pressed("erase") and p_workspace == WORKSPACE.CIRCUIT:
		add_tile_to_parts(circuit_grid.map[py][px])
		circuit_grid.erase_tile(px, py)
	
	if Input.is_action_just_pressed("rotate"):
		p_tile.rot_cw()
		
	if Input.is_action_pressed("select"):
		if p_workspace ==  WORKSPACE.COMPONENT_LIB:
			p_tile = component_lib.map[py - component_lib_origin.y][px - component_lib_origin.x].duplicate()
		elif p_workspace == WORKSPACE.CIRCUIT:
			if not circuit_grid.locked_table[py][px]:
				if remove_tile_from_parts(p_tile):
					add_tile_to_parts(circuit_grid.map[py][px])
					circuit_grid.edit_tile(px, py, p_tile.duplicate())
				
	if Input.is_action_just_pressed("drop"):
		p_tile = null
						
func add_tile_to_parts(tile: CircuitTile) -> void:
	if tile is StraightConnector: straight_connector_count += 1
	elif tile is RightAngleConnector: right_angle_connector_count += 1 
	elif tile is ThreeWayConnector: three_way_connector_count += 1
	elif tile is FourWayConnector: four_way_connector_count += 1
	else: pass
	
func remove_tile_from_parts(tile) -> bool:
	if tile is StraightConnector: 
		if straight_connector_count > 0:
			straight_connector_count -= 1
			return true
	elif tile is RightAngleConnector:
		if right_angle_connector_count > 0:
			right_angle_connector_count -= 1
			return true
	elif tile is ThreeWayConnector:
		if three_way_connector_count > 0:
			three_way_connector_count -= 1
			return true
	elif tile is FourWayConnector:
		if four_way_connector_count > 0:
			four_way_connector_count -= 1
			return true
			
	return false

func player_movement(delta: float) -> void:
	var opx = px
	var opy = py
	var op_workspace = p_workspace
	
	if Input.is_action_just_pressed("swap"):
		p_workspace = WORKSPACE.COMPONENT_LIB
		px = component_lib_origin.x
		py = component_lib_origin.y
	
	var dx = -int(Input.is_action_pressed("left")) + int(Input.is_action_pressed("right"))
	var dy = -int(Input.is_action_pressed("up")) + int(Input.is_action_pressed("down"))
	
	var x_just_pressed = Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right")
	var y_just_pressed = Input.is_action_just_pressed("up") or Input.is_action_just_pressed("down")
							
	var should_move_x = false
	if x_just_pressed:
		should_move_x = true
		move_timer_x = move_delay
	elif dx != 0:
		move_timer_x -= delta
		if move_timer_x <= 0:
			should_move_x = true
			move_timer_x = move_repeat
	else:
		move_timer_x = 0.0
		
	var should_move_y = false
	if y_just_pressed:
		should_move_y = true
		move_timer_y = move_delay
	elif dy != 0:
		move_timer_y -= delta
		if move_timer_y <= 0:
			should_move_y = true
			move_timer_y = move_repeat
	else:
		move_timer_y = 0.0
	
	if should_move_x or should_move_y:
		if p_workspace == WORKSPACE.CIRCUIT:
			if should_move_x:
				if dx < 0:
					if px > 0: 
						px -= 1
					elif px == 0:
						p_workspace = WORKSPACE.COMPONENT_LIB
						px = component_lib_origin.x + component_lib_width - 1
						if py <= component_lib_origin.y: 
							py = component_lib_origin.y
						elif py >= component_lib_origin.y + component_lib_height: 
							py = component_lib_origin.y + component_lib_height - 1
				elif dx > 0 and px < circuit_width - 1:
					px += 1
			if should_move_y:
				if dy < 0 and py > 0:
					py -= 1
				elif dy > 0 and py < circuit_height - 1:
					py += 1
				
		elif p_workspace == WORKSPACE.COMPONENT_LIB:
			if should_move_x:
				if dx < 0:
					if px > component_lib_origin.x:
						px -= 1
				elif dx > 0:
					if px < component_lib_origin.x + component_lib_width - 1:
						px += 1
					else:
						p_workspace = WORKSPACE.CIRCUIT
						px = 0
			if should_move_y:
				if dy < 0:
					if py > component_lib_origin.y:
						py -= 1
				elif dy > 0:
					if py < component_lib_origin.y + component_lib_height - 1:
						py += 1

	if opx != px or opy != py or p_workspace != op_workspace:
		self.selection_rendering_layer.erase_cell(Vector2i(opx, opy))
			
	if p_tile == null or p_workspace == WORKSPACE.COMPONENT_LIB:
		selection_rendering_layer.modulate = Color(1, 1, 1, 1)
		self.selection_rendering_layer.set_cell(Vector2i(px, py), 0, Vector2i(0, 0)) # selection-box icon
	else:
		selection_rendering_layer.modulate = Color(0.5, 0.5, 0.5, 0.5)
		self.selection_rendering_layer.set_cell(Vector2i(px, py), p_tile.source_id, Vector2i(p_tile.atlas_x, p_tile.atlas_y), p_tile.get_rotation()) # grayed-out tile icon
