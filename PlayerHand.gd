extends TileMap

var cards: Array[Card] = []
const sourceId := 0
@export var isCurrentPlayer := true
signal cardAdded()
signal selectedCard(cardIndex: int)

var textureRects : Array[TextureRect] = []
var opponentSelectedCardIndex

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
			add_overlay_on_card(i)
		if not isCurrentPlayer and i == opponentSelectedCardIndex:
			add_overlay_on_card(i)

func add_overlay_on_card(cardIndex: int) -> void:
	var rect := TextureRect.new()
	rect.texture = load("res://imgs/circle.svg")
	rect.position = Vector2i(tile_set.tile_size.x*cardIndex, 0)
	textureRects.append(rect)
	add_child(rect)

func set_opponent_selected_card(selectedCardIndex: int) -> void:
	opponentSelectedCardIndex = selectedCardIndex
	paint()

func clear_opponent_selected_card() -> void:
	opponentSelectedCardIndex = null
	paint()

func free_and_delete_previous_textureRects() -> void:
	for rect in textureRects:
		rect.queue_free()
	textureRects = []

func _input(event):
	if event.is_action_pressed("select_card"):
		var click_pos: Vector2 = get_global_mouse_position()
		var cell_pos: Vector2i = local_to_map(click_pos-position)
		if cell_pos.y != 0:
			return
		var card_id: int = cell_pos.x * tile_set.tile_size.x
		if card_id < 0 or card_id > cards.size():
			return
		selectedCard.emit(card_id)
