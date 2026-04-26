class_name CircuitGrid

var map = Array()
var locked_table = Array()

var width: int 
var height: int
var battery_top_rendering_layer
var rendering_layer
var icon_rendering_layer

# Ends of the batteries
var positives = Array()
var negatives = Array()

func _init(rendering_layer, battery_top_rendering_layer, icon_rendering_layer, width: int, height: int) -> void:
	self.rendering_layer = rendering_layer
	self.battery_top_rendering_layer = battery_top_rendering_layer
	self.icon_rendering_layer = icon_rendering_layer
	var row = Array()
	var locked_row = Array()
	for x in range(width):
		row.append(null)
		locked_row.append(false)
	for y in range(height):
		self.map.append(row.duplicate(true))
		self.locked_table.append(locked_row.duplicate(true))
		
	self.width = width 
	self.height = height
	
func render() -> void:
	for positive in positives:
		var tile = self.map[positive.y][positive.x]
		self.rendering_layer.set_cell(Vector2i(positive.x, positive.y-1), tile.source_id, Vector2i(tile.top_atlas_x, tile.top_atlas_y), tile.get_rotation())

	for negative in negatives:
		var tile = self.map[negative.y][negative.x]
		self.rendering_layer.set_cell(Vector2i(negative.x, negative.y-1), tile.source_id, Vector2i(tile.top_atlas_x, tile.top_atlas_y), tile.get_rotation())

		
	for y in range(len(self.map)):
		for x in range(len(self.map[y])):
			var tile = self.map[y][x]
			if tile == null:
				self.rendering_layer.erase_cell(Vector2i(x, y))
			else:
				self.rendering_layer.set_cell(Vector2i(x, y), tile.source_id, Vector2i(tile.atlas_x, tile.atlas_y), tile.get_rotation())
				if tile is BatteryPositiveBottom or tile is BatteryNegativeBottom:
					self.battery_top_rendering_layer.set_cell(Vector2i(x, y-1), tile.source_id, Vector2i(tile.top_atlas_x, tile.top_atlas_y), tile.get_rotation())

			
			if self.locked_table[y][x]:
				self.icon_rendering_layer.set_cell(Vector2i(x, y), 1, Vector2i(0, 0))
				
func erase_tile(x: int, y:int):
	edit_tile(x, y, null)
		
func edit_tile(input_x: int, input_y: int, input_tile, locked: bool = false):
	if not self.locked_table[input_y][input_x]:
		self.map[input_y][input_x] = input_tile
		self.locked_table[input_y][input_x] = locked
		
		if input_tile is BatteryPositiveBottom:
			positives.append(Vector2i(input_x, input_y))
		if input_tile is BatteryNegativeBottom:
			negatives.append(Vector2i(input_x, input_y))
		
		update_grid_logic()
			
func update_grid_logic():
	for y in range(len(self.map)):
		for x in range(len(self.map[y])):
			if self.map[y][x] != null:
				self.map[y][x].source_id = 1 # defaulting to off
				
	for positive in positives:
		self.map[positive.y][positive.x].paths = Array()
		self.map[positive.y][positive.x].path_resistance = 1000
		
	for negative in negatives:
		self.map[negative.y][negative.x].wattage = 0
				
	for positive in positives:
		var min_resistance_paths = Array()
		var min_resistance: float = -1
		for negative in negatives:
			var paths = get_paths_of_least_resistance(positive, negative)
			for path in paths:
				if path.size() > 0:
					var resistance = get_resistance(path)
					if resistance < min_resistance or min_resistance == -1:
						min_resistance_paths.clear()
						min_resistance_paths.append(path)
						min_resistance = resistance
					elif resistance == min_resistance:
						min_resistance_paths.append(path)
						min_resistance = resistance
				
		if min_resistance != -1:
			if min_resistance < self.map[positive.y][positive.x].path_resistance:
				self.map[positive.y][positive.x].paths = min_resistance_paths.duplicate(true)
				self.map[positive.y][positive.x].path_resistance = min_resistance
				for path in min_resistance_paths:
					var x = path[-1][0]
					var y = path[-1][1]
					self.map[y][x].wattage += (self.map[positive.y][positive.x].voltage**2) / (float) (min_resistance*min_resistance_paths.size())

	for positive in positives:
		for path in self.map[positive.y][positive.x].paths:
			for tile in path:
				var x = tile[0]
				var y = tile[1]
				self.map[y][x].source_id = 0 # turn tiles on the path of least resistance on

func get_paths_of_least_resistance(positive: Vector2i, negative: Vector2i) -> Array:
	var paths = find_all_routes(positive.x, positive.y, negative.x, negative.y)
	if paths.is_empty():
		return []

	var min = get_resistance(paths[0])
	var paths_of_least_resistance = [paths[0]]
	
	for path in paths:
		var resistance = get_resistance(path)
		if resistance < min:
			min = resistance
			paths_of_least_resistance = [path]
		elif resistance == min:
			paths_of_least_resistance.append(path)
			
	return paths_of_least_resistance

func get_resistance(path) -> int:
	var resistance = 0
	for coords in path:
		var x = coords[0]
		var y = coords[1]
		var tile = self.map[y][x]
		resistance += tile.resistance
	return resistance
		
func find_all_routes(start_x: int, start_y: int, end_x: int, end_y: int) -> Array:
	var all_paths = [] 
	var current_path = [[start_x, start_y]]
	var visited = {}
	visited[Vector2(start_x, start_y)] = true 
	dfs(start_x, start_y, end_x, end_y, current_path, visited, all_paths)
	return all_paths
	
func dfs(x: int, y: int, end_x: int, end_y: int, path: Array, visited: Dictionary, all_paths: Array) -> void:
	if x == end_x and y == end_y:
		all_paths.append(path.duplicate(true))
		return 
	for neighbor in get_neighbor_conections(x, y):
		var neighbor_x = neighbor[0]
		var neighbor_y = neighbor[1]
		var key = Vector2(neighbor_x, neighbor_y)
		if not visited.has(key):
			visited[key] = true
			path.append([neighbor_x, neighbor_y]) 
			dfs(neighbor_x, neighbor_y, end_x, end_y, path, visited, all_paths)
			path.pop_back()
			visited.erase(key)
			
func get_neighbor_conections(x: int, y: int) -> Array:
	var center = self.map[y][x]
	var neighbors = []
	if center == null: 
		return neighbors
		
	for con in center.cons:
		var neighbor_x = x + int(con.x)
		var neighbor_y = y + int(con.y)
		
		if neighbor_x < 0 or neighbor_x >= self.width or neighbor_y < 0 or neighbor_y >= self.height:
			continue
			
		var neighbor = self.map[neighbor_y][neighbor_x]
		if neighbor == null: continue
		
		var points_back = false
		for neighbor_con in neighbor.cons:
			if int(neighbor_con.x) == -int(con.x) and int(neighbor_con.y) == -int(con.y):
				points_back = true
				break
				
		if points_back:
			neighbors.append([neighbor_x, neighbor_y]) 
			
	return neighbors
