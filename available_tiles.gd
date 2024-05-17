extends TileMap

const nbColors := 2
const sourceId := 0
@export var maxValue := 11
@export var cardsPerRow := 5
var cards: Array[Card] = []
signal cardPicked(card: Card)

func _ready():
	if not multiplayer.is_server():
		print("We're not the server, we don't create the deck")
		return

	draw_cards()
	initialize_cards_remotely.rpc(CardSerializer.serialize_deck(cards))
	paint()

func draw_cards() -> void:
	for v in maxValue:
		for c in nbColors:
			cards.append(Card.new(c, v))
	cards.shuffle()

@rpc("authority", "call_remote", "reliable")
func initialize_cards_remotely(cardsSerialized: String) -> void:
	cards = CardSerializer.deserialize_deck(cardsSerialized)
	paint()

func paint() -> void:
	for i in cards.size():
		var tile_pos: Vector2i = cardId_to_cellPos(i)
		if cards[i]:
			set_cell(0, tile_pos, sourceId, card_to_tile(cards[i]))
		else:
			erase_cell(0, tile_pos)

func cardId_to_cellPos(id: int) -> Vector2i:
	@warning_ignore("integer_division")
	return Vector2i(id%cardsPerRow, id / cardsPerRow)

func cellPos_to_cardId(cell_pos: Vector2i) -> int:
	return cell_pos.y*cardsPerRow + cell_pos.x

func card_to_tile(card: Card) -> Vector2i:
#	return Vector2i(card.value, 2*card.color) # for manual debug: display the card values
	return Vector2i(card.value, 2*card.color + 1)

func _input(event):
	if event.is_action_pressed("select_card"):
		var click_pos: Vector2 = get_global_mouse_position()
		var cell_pos: Vector2i = local_to_map(click_pos-position)
		var card_id: int = cellPos_to_cardId(cell_pos)
		if card_id < 0 or card_id > cards.size() or not cards[card_id]:
			print("click was not on a card, we ignore it")
			return
		cardPicked.emit(cards[card_id])
		player_picked_card.rpc(card_id)


@rpc("any_peer", "call_local", "reliable")
func player_picked_card(card_id: int) -> void:
	cards[card_id] = null
	paint()
