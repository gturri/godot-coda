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

func serialize() -> String:
	return str(color) + "," + str(value) + "," + str(isVisible)

static func deserialize(data: String) -> Card:
	var splits := data.split(",")
	var card = Card.new(int(splits[0]), int(splits[1]))
	card.isVisible = (splits[2] == "true")
	return card

