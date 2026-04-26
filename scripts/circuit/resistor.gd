class_name Resistor extends CircuitTile

func _init(rot: int) -> void:
	var atlas_x = 2
	var atlas_y = 0
	var cons = [Vector2(-1, 0), Vector2(1, 0)]
	var resistance = 5
	super._init(atlas_x, atlas_y, rot, cons, resistance)
