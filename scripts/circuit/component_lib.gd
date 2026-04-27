class_name ComponentLib

var origin: Vector2i
var map = Array()
var width: int 
var height: int

var circuit_layer
var icon_layer

var tiles: Array
var tile_counts: Array

func _init(circuit_layer, icon_layer, origin: Vector2i, width: int, height: int, tiles: Array, tile_counts: Array, root_node) -> void:
	self.circuit_layer = circuit_layer
	self.icon_layer = icon_layer
	self.origin = origin
	self.width = width 
	self.height = height
	
	self.tiles = tiles
	self.tile_counts = tile_counts
	
	if len(self.tiles) != len(self.tile_counts):
		push_error("Component Lib Init: tiles length must equal tile_counts length")
		root_node.get_tree().quit()
	
	var row = Array()
	for x in range(width):
		row.append(null)
	for y in range(height):
		self.map.append(row.duplicate(true))
		
	var x = 0
	var y = 0
	for tile in self.tiles:
		self.map[y][x] = tile
		x += 1
		if x > width-1:
			x = 0
			y += 1
		
func add_tile_to_parts(tile: CircuitTile) -> void:
	if tile == null:
		return
	for i in range(len(self.tiles)):
		if self.tiles[i].equals(tile):
			self.tile_counts[i] += 1
			
func remove_tile_from_parts(new_tile) -> bool:
	for i in range(len(self.tiles)):
		var tile = self.tiles[i]
		if tile.equals(new_tile):
			if self.tile_counts[i] > 0:
				self.tile_counts[i] -= 1
				return true
			else:
				return false
				
	return false
			
func copy_tile(x, y) -> CircuitTile:
	if self.map[y][x] != null and self.tile_counts[y*self.width+x] > 0:
		return self.map[y][x].duplicate()
	return null
	
func get_count(other: CircuitTile) -> int:
	for i in range(len(self.tiles)):
		var tile = self.tiles[i]
		if tile.equals(other):
			return self.tile_counts[i]
			
	return 0
			
func render() -> void:
	var x = 0
	var y = 0
	for i in range(len(self.tiles)):
		var tile = self.tiles[i]
		var count = self.tile_counts[i]
		self.circuit_layer.set_cell(Vector2i(origin.x+x, origin.y+y), tile.source_id, Vector2i(tile.atlas_x, tile.atlas_y), tile.get_rotation())
		self.icon_layer.set_cell(Vector2i(origin.x+x, origin.y+y), 0, Vector2i(count % 10, count / 10))
		
		x += 1
		if x > width-1:
			x = 0
			y += 1
