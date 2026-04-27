class_name BatteryNegative extends CircuitTile

var wattage: float = 0
var desired_wattage: float = 0

var top_atlas_x: int = 4
var top_atlas_y: int = 0

var enabled_color: Color = Color("#418b24")
var disabled_color: Color = Color("#ffffff")

var enabled: bool = false

func _init(rot: int, desired_wattage) -> void:
	var atlas_x = 4
	var atlas_y = 1 
	var cons = [Vector2(-1, 0), Vector2(0, -1), Vector2(0, 1), Vector2(1, 0)]
	var resistance = 0
	super._init(atlas_x, atlas_y, rot, cons, resistance)
	self.desired_wattage = desired_wattage
