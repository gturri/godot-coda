extends TileMap

var hand: PlayerHand = PlayerHand.new()
const sourceId := 0

func add_card(card: Card) -> void:
	hand.add_card(card)
	paint()

func paint() -> void:
	for i in hand.cards.size():
		var card = hand.cards[i]
		set_cell(0, Vector2i(i, 0), sourceId, Vector2i(card.value, 2*card.color if card.isVisible else 2*card.color+1))
