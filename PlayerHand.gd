extends TileMap

var cards: Array[Card] = []
const sourceId := 0
@export var isCurrentPlayer := true
signal cardAdded()
signal selectedCard(cardIndex: int)

var cardsToTextures := {}
var cardsToOverlay := {}
var cardsToId := {}
var opponentSelectedCardIndex
@export var transitionDurationInSecond :float = 0.5
var cardInPlayerHandScene = preload("res://CardInPlayerHand.tscn")

@rpc("any_peer", "call_remote", "reliable")
func add_card_remotely(serializedCard: String, initialPositionOnTheBoard) -> void:
	add_card(CardSerializer.deserialize_card(serializedCard), initialPositionOnTheBoard)

func add_card(card: Card, initialPositionOnTheBoard: Vector2) -> void:
	cards.append(card)
	cards.sort_custom(Card.compare)
	paint(initialPositionOnTheBoard-position)
	cardAdded.emit()

func has_hidden_cards() -> bool:
	for i in cards.size():
		if not cards[i].isVisible:
			return true
	return false

func make_card_visible(cardId: int) -> void:
	var card = cards[cardId]
	card.isVisible = true
	var currentCardTextureRect = cardsToTextures[cards[cardId]]
	var newCardTextureRect = get_card_textureRect(card)
	newCardTextureRect.position = currentCardTextureRect.position
	cardsToTextures[card] = newCardTextureRect
	add_child(newCardTextureRect)
	currentCardTextureRect.queue_free()

func paint(initialPositionNewCard: Vector2) -> void:
	cardsToId.clear()
	for i in cards.size():
		var card = cards[i]
		cardsToId[card] = i
		var cardPosition = __cardId_to_position(i)
		var cardTextureRect = cardsToTextures.get(card)
		if not cardTextureRect:
			cardTextureRect = get_card_textureRect(card)
			cardTextureRect.card = card
			cardsToTextures[card] = cardTextureRect
			cardTextureRect.position = initialPositionNewCard
			add_child(cardTextureRect)
			var cardTween = get_tree().create_tween()
			cardTween.tween_property(cardTextureRect, "position", cardPosition, transitionDurationInSecond)

			if (isCurrentPlayer and card.isVisible) or (not isCurrentPlayer and i == opponentSelectedCardIndex):
				var overlay := create_overlay()
				overlay.position = initialPositionNewCard
				cardsToOverlay[i] = overlay
				add_child(overlay)
				var overlayTween = get_tree().create_tween()
				overlayTween.tween_property(overlay, "position", cardPosition, transitionDurationInSecond)
		else:
			var cardTween = get_tree().create_tween()
			cardTween.tween_property(cardTextureRect, "position", cardPosition, transitionDurationInSecond)
			var overlay = cardsToOverlay.get(i)
			if overlay:
				var overlayTween = get_tree().create_tween()
				overlayTween.tween_property(overlay, "position", cardPosition, transitionDurationInSecond)

func get_card_textureRect(card: Card):
	var rect := cardInPlayerHandScene.instantiate()
	rect.selectedCard.connect(card_selected)
	var source: TileSetAtlasSource = get_tileset().get_source(sourceId)
	var textureRegion: Rect2i = source.get_tile_texture_region(Vector2i(card.value, 2*card.color + (0 if isCurrentPlayer or card.isVisible else 1)))
	var tileImage: Image = source.texture.get_image().get_region(textureRegion)
	rect.get_node("TextureRect").set_texture(ImageTexture.create_from_image(tileImage))
	return rect

func create_overlay() -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = load("res://imgs/circle.svg")
	return rect

func __cardId_to_position(cardId: int) -> Vector2:
	var startXPos :float = -(cards.size()-1)/2.0
	return Vector2(tile_set.tile_size.x*(startXPos+cardId), 0)

func set_opponent_selected_card(selectedCardIndex: int) -> void:
	clear_opponent_selected_card()
	opponentSelectedCardIndex = selectedCardIndex
	var overlay := create_overlay()
	overlay.position = __cardId_to_position(opponentSelectedCardIndex)
	cardsToOverlay[opponentSelectedCardIndex] = overlay
	add_child(overlay)

func clear_opponent_selected_card() -> void:
	var overlay = cardsToOverlay.get(opponentSelectedCardIndex)
	if overlay:
		overlay.queue_free()
		cardsToOverlay.erase(opponentSelectedCardIndex)
	opponentSelectedCardIndex = null

func card_selected(card: Card):
	selectedCard.emit(cardsToId[card])
