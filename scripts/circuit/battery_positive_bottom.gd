class_name BatteryPositiveBottom extends CircuitTile

var path: Array
var path_resistance: int = 100
var voltage: float = 5.0

func _init(rot: int) -> void:
	var atlas_x = 2
	var atlas_y = 1 
	var cons = [Vector2(-1, 0), Vector2(0, 1), Vector2(1, 0)]
	var resistance = 0
	super._init(atlas_x, atlas_y, rot, cons, resistance)
