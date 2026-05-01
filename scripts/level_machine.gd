class_name LevelMachine

var cur: String
var levels: Dictionary

func _init(cur: int) -> void:
	self.cur = str(cur)
	self.levels = read_level_json()
	
func level_setup(circuit_grid: CircuitGrid, comp_lib: ComponentLib):
	circuit_grid.refresh()
	for tile in self.levels[self.cur]["circuit"]:
		circuit_grid.edit_tile(tile["x"], tile["y"], get_tile(tile), tile["locked"])
	
	var tiles = Array()
	var tile_counts = Array()
	for tile in self.levels[self.cur]["component_lib"]:
		tiles.append(get_tile(tile))
		tile_counts.append((int)(tile["count"]))
	comp_lib.refresh(tiles, tile_counts)
		
func get_tile(tile) -> CircuitTile:
	var type = tile["type"]
	var rot = (int)(tile["rot"])
	if type == "StraightConnector":
		return StraightConnector.new(rot)
	if type == "RightAngleConnector":
		return RightAngleConnector.new(rot)
	if type == "ThreeWayConnector":
		return ThreeWayConnector.new(rot)
	if type == "FourWayConnector":
		return FourWayConnector.new(rot)
	if type == "Diode":
		return Diode.new(rot)
	if type == "Resistor":
		return Resistor.new(rot)
	if type == "BatteryNegative":
		return BatteryNegative.new(rot, tile["wattage"])
	if type == "BatteryPositive":
		return BatteryPositive.new(rot)
		
	return null
		
	
func next_level(circuit_grid: CircuitGrid, comp_lib: ComponentLib):
	self.cur = str((int)(self.cur) + 1)
	level_setup(circuit_grid, comp_lib)

func get_level() -> String:
	return self.cur
	
func read_level_json() -> Dictionary:
	var path = "res://levels.json"
	if not FileAccess.file_exists(path):
		push_error("File not found: %s" % path)
		return {}
	var f = FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("Failed to open: %s" % path)
		return {}
	var text := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)

	return parsed
