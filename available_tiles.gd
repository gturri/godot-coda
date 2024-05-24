extends TileMap

const nbColors := 2
const sourceId := 0
@export var maxValue := 11
@export var cardsPerRow := 5
var cards: Array[Card] = []
signal cardDrawn(card: Card, card_id: int)

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

func is_empty() -> bool:
	for c in cards:
		if c:
			return false
	return true

@rpc("authority", "call_remote", "reliable")
func initialize_cards_remotely(cardsSerialized: String) -> void:
	cards = CardSerializer.deserialize_deck(cardsSerialized)
	paint()

func paint() -> void:
	for i in cards.size():
		var tile_pos: Vector2i = cardId_to_cellPos(i)
		if cards[i]:
			set_cell(0, tile_pos, sourceId, card_to_tile(cards[i], false))
		else:
			erase_cell(0, tile_pos)

func cardId_to_cellPos(id: int) -> Vector2i:
	@warning_ignore("integer_division")
	return Vector2i(id%cardsPerRow, id / cardsPerRow)

func cellPos_to_cardId(cell_pos: Vector2i):
	if cell_pos.x < 0 or cell_pos.x >= cardsPerRow:
		return null
	return cell_pos.y*cardsPerRow + cell_pos.x

func card_to_tile(card: Card, visibleSide: bool) -> Vector2i:
	return Vector2i(card.value, 2*card.color + (0 if visibleSide else 1))

func _input(event):
	if event.is_action_pressed("select_card"):
		var click_pos: Vector2 = get_global_mouse_position()
		var cell_pos: Vector2i = local_to_map(click_pos-position)
		var card_id = cellPos_to_cardId(cell_pos)
		if card_id == null or card_id < 0 or card_id >= cards.size() or not cards[card_id]:
			return
		cardDrawn.emit(cards[card_id], card_id)

@rpc("any_peer", "call_local", "reliable")
func player_picked_card(card_id: int) -> void:
	cards[card_id] = null
	paint()

func get_card_texture(card: Card) -> Texture2D:
	var source: TileSetAtlasSource = get_tileset().get_source(sourceId)
	var textureRegion: Rect2i = source.get_tile_texture_region(card_to_tile(card, true))
	var tileImage: Image = source.texture.get_image().get_region(textureRegion)
	return ImageTexture.create_from_image(tileImage)
