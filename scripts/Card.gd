class_name Card

var color : int
var value : int
var isVisible := false

func _init(color, value):
	self.color = color
	self.value = value

static func compare(a: Card, b: Card) -> bool:
	if a.value < b.value:
		return true
	if a.value > b.value:
		return false
	return a.color == 0
