class_name Card

var color : int
var value : int
var isVisible := false

func _init(color_p, value_p):
	self.color = color_p
	self.value = value_p

static func compare(a: Card, b: Card) -> bool:
	if a.value < b.value:
		return true
	if a.value > b.value:
		return false
	return a.color == 0


