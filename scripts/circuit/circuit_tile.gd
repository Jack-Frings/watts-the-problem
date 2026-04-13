class_name CircuitTile

var source_id = 1
var atlas_x : int
var atlas_y : int

var rot : int
var cons
var resistance : int

func _init(atlas_x: int, atlas_y: int, rot: int, cons: Array, resistance: int) -> void:
	self.cons = []
	
	self.atlas_x = atlas_x
	self.atlas_y = atlas_y
	self.rot = rot
	
	self.resistance = resistance
	
	var valid_input = (self.rot == 0 or self.rot == 1 or self.rot == 2 or self.rot == 3)
	assert(valid_input, "Invalid Rotation") 
	
	for con in cons:
		self.cons.append(con.rotated(deg_to_rad(90*rot)))
	
func get_rotation():
	match self.rot:
			0: return 0
			1: return TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H
			2: return TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V
			3: return TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V
			_: return 0
	
func rot_cw() -> void:
	self.rot += 1 
	if self.rot > 3: self.rot -= 4
	
	for i in range(len(self.cons)):
		self.cons[i] = self.cons[i].rotated(deg_to_rad(90))

func rot_ccw() -> void:
	self.rot -= 1 
	if self.rot < 0: self.rot += 4 
	
	for i in range(len(self.cons)):
		self.cons[i] = self.cons[i].rotated(deg_to_rad(-90))
	
func duplicate() -> CircuitTile:
	var unrotated_cons = []
	for con in self.cons:
		unrotated_cons.append(con.rotated(deg_to_rad(-90*self.rot)))
	return get_script().new(self.rot)
