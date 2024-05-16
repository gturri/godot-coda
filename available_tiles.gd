extends TileMap

const nbColors := 2
const sourceId := 0
@export var maxValue := 11
@export var cardsPerRow := 5
var cards: Array[Card] = []

func _ready():
	if not multiplayer.is_server():
		print("We're not the server, we don't create the deck")
		return

	initialize_cards()
	print_cards.rpc(serialize_deck())

func initialize_cards() -> void:
	for v in maxValue:
		for c in nbColors:
			cards.append(Card.new(c, v))
	cards.shuffle()

func serialize_deck() -> String:
	# a bit ugly but this rely on the knowledge that this char is not in the serialized card
	return "|".join(cards.map(func (c: Card): return c.serialize()))

func deserialize_deck(serializedCards: String) -> Array[Card]:
	var result: Array[Card] = []
	for serializedCard in serializedCards.split("|"):
		result.append(Card.deserialize(serializedCard))
	return result

@rpc("authority", "call_local", "reliable")
func print_cards(cardsSeralized: String) -> void:
	print("received cards to print")
	var cards = deserialize_deck(cardsSeralized)
	for i in cards.size():
		set_cell(0, cardId_to_cellPos(i), sourceId, card_to_tile(cards[i]))

func cardId_to_cellPos(id: int) -> Vector2i:
	return 2*Vector2i(id%cardsPerRow, id / cardsPerRow)

func card_to_tile(card: Card) -> Vector2i:
#	return Vector2i(card.value, 2*card.color) # for manual debug: display the card values
	return Vector2i(card.value, 2*card.color + 1)
