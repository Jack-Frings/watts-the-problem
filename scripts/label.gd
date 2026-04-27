extends Label

var amplitude = 1
var period = 1.5

func _ready():
	var tween = create_tween().set_loops()
	tween.tween_property(self, "position:y", position.y - amplitude, period).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", position.y + amplitude, period).set_trans(Tween.TRANS_SINE)
