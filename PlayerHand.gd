extends TileMap

var cards: Array[Card] = []
const sourceId := 0
@export var isCurrentPlayer := true
signal cardAdded()

var textureRects : Array[TextureRect] = []

@rpc("any_peer", "call_remote", "reliable")
func add_card_remotely(serializedCard: String) -> void:
	add_card(CardSerializer.deserialize_card(serializedCard))

func add_card(card: Card) -> void:
	cards.append(card)
	cards.sort_custom(Card.compare)
	paint()
	cardAdded.emit()

func paint() -> void:
	free_and_delete_previous_textureRects()
	for i in cards.size():
		var card = cards[i]
		set_cell(0, Vector2i(i, 0), sourceId, Vector2i(card.value, 2*card.color if isCurrentPlayer or card.isVisible else 2*card.color+1))
		if isCurrentPlayer and card.isVisible:
			add_overlay_on_visible_cards(i)

func add_overlay_on_visible_cards(cardIndex: int) -> void:
	var rect := TextureRect.new()
	rect.texture = load("res://imgs/circle.svg")
	rect.position = Vector2i(tile_set.tile_size.x*cardIndex, 0)
	textureRects.append(rect)
	add_child(rect)

func free_and_delete_previous_textureRects() -> void:
	for rect in textureRects:
		rect.queue_free()
	textureRects = []
