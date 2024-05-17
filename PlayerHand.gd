extends TileMap

var cards: Array[Card] = []
const sourceId := 0
@export var isCurrentPlayer := true

func add_card(card: Card) -> void:
	cards.append(card)
	cards.sort_custom(Card.compare)
	paint()

func paint() -> void:
	for i in cards.size():
		var card = cards[i]
		set_cell(0, Vector2i(i, 0), sourceId, Vector2i(card.value, 2*card.color if isCurrentPlayer or card.isVisible else 2*card.color+1))
