class_name BatteryNegativeBottom extends CircuitTile

var path_resistance: int = 0
var wattage: int = 0

func _init(rot: int) -> void:
	var atlas_x = 3
	var atlas_y = 1 
	var cons = [Vector2(-1, 0), Vector2(0, 1), Vector2(1, 0)]
	var resistance = 0
	super._init(atlas_x, atlas_y, rot, cons, resistance)
