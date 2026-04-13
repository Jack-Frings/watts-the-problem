class_name FourWayConnector extends CircuitTile

func _init(rot: int) -> void:
	var atlas_x = 1
	var atlas_y = 0
	var cons = [Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0)]
	var resistance = 1
	super._init(atlas_x, atlas_y, rot, cons, resistance)
