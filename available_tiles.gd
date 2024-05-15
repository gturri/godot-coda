extends TileMap

const nbColors := 2
const sourceId := 0
@export var maxValue := 11
@export var cardsPerRow := 5

func _ready():
	var cards: Array[Card] = []
	for v in maxValue:
		for c in nbColors:
			cards.append(Card.new(c, v))
	cards.shuffle()
	
	for i in cards.size():
		set_cell(0, cardId_to_cellPos(i), sourceId, card_to_tile(cards[i]))

func cardId_to_cellPos(id: int) -> Vector2i:
	return 2*Vector2i(id%cardsPerRow, id / cardsPerRow)

func card_to_tile(card: Card) -> Vector2i:
	return Vector2i(card.value, 2*card.color + 1)
