class_name ComponentLib

var origin: Vector2i
var map = Array()
var width: int 
var height: int
var rendering_layer

func _init(rendering_layer, origin: Vector2i, width: int, height: int) -> void:
	self.rendering_layer = rendering_layer
	self.origin = origin
	self.width = width 
	self.height = height
	
	var row = Array()
	for x in range(width):
		row.append(null)
	for y in range(height):
		self.map.append(row.duplicate(true))
		
	# Connectors to Copy
	edit_tile(0, 0, StraightConnector.new(0))
	edit_tile(1, 0, RightAngleConnector.new(0))
	edit_tile(0, 1, ThreeWayConnector.new(0))
	edit_tile(1, 1, FourWayConnector.new(0))
	edit_tile(0, 2, Resistor.new(0))
	edit_tile(1, 2, Diode.new(0))
		
func edit_tile(input_x: int, input_y: int, input_tile):
	self.map[input_y][input_x] = input_tile
	
func render() -> void:
	for y in range(len(self.map)):
		for x in range(len(self.map[y])):
			var tile = self.map[y][x]
			if self.map[y][x] == null:
				self.rendering_layer.erase_cell(Vector2i(origin.x + x, origin.y + y))
			else:
				self.rendering_layer.set_cell(Vector2i(origin.x + x, origin.y + y), tile.source_id, Vector2i(tile.atlas_x, tile.atlas_y), tile.get_rotation())
