class_name BatteryNegativeBottom extends CircuitTile

var wattage: float = 0
var desired_wattage: float = 0

var top_atlas_x = 4
var top_atlas_y = 0

func _init(rot: int) -> void:
	var atlas_x = 4
	var atlas_y = 1 
	var cons = [Vector2(-1, 0), Vector2(0, -1), Vector2(0, 1), Vector2(1, 0)]
	var resistance = 0
	super._init(atlas_x, atlas_y, rot, cons, resistance)
