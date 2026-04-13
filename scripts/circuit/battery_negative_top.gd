class_name BatteryNegativeTop extends CircuitTile

func _init(rot: int) -> void:
	var atlas_x = 3
	var atlas_y = 0 
	var cons = []
	var resistance = 0
	super._init(atlas_x, atlas_y, rot, cons, resistance)
