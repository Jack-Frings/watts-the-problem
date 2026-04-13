class_name RightAngleConnector extends CircuitTile

func _init(rot: int) -> void:
	var atlas_x = 0
	var atlas_y = 1
	var cons = [Vector2(-1, 0), Vector2(0, -1)]
	var resistance = 1
	super._init(atlas_x, atlas_y, rot, cons, resistance)
