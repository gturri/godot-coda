extends TileMap

var cardFoundShader = load("res://cardFound.gdshader")

var cards: Array[Card] = []
const sourceId := 0
@export var isCurrentPlayer := true
signal cardAdded()
signal selectedCard(cardIndex: int)

var cardsToArea2D := {}
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
	if isCurrentPlayer:
		cardsToArea2D[card].apply_shader(cardFoundShader)
	else:
		var currentCardScene = cardsToArea2D[card]
		var newCardScene = create_card_scene(card, currentCardScene.position)
		cardsToArea2D[card] = newCardScene
		currentCardScene.queue_free()

func paint(initialPositionNewCard: Vector2) -> void:
	cardsToId.clear()
	for i in cards.size():
		var card = cards[i]
		cardsToId[card] = i
		var cardPosition = __cardId_to_position(i)
		var cardScene = cardsToArea2D.get(card)
		if not cardScene:
			cardScene = create_card_scene(card, initialPositionNewCard)
			cardsToArea2D[card] = cardScene
			var cardTween = get_tree().create_tween()
			cardTween.tween_property(cardScene, "position", cardPosition, transitionDurationInSecond)

			if isCurrentPlayer and card.isVisible:
				cardsToArea2D[card].apply_shader(cardFoundShader)
			elif not isCurrentPlayer and i == opponentSelectedCardIndex:
				var overlay := create_overlay()
				overlay.position = initialPositionNewCard
				cardsToOverlay[i] = overlay
				add_child(overlay)
				var overlayTween = get_tree().create_tween()
				overlayTween.tween_property(overlay, "position", cardPosition, transitionDurationInSecond)
		else:
			var cardTween = get_tree().create_tween()
			cardTween.tween_property(cardScene, "position", cardPosition, transitionDurationInSecond)
			var overlay = cardsToOverlay.get(i)
			if overlay:
				var overlayTween = get_tree().create_tween()
				overlayTween.tween_property(overlay, "position", cardPosition, transitionDurationInSecond)

func create_card_scene(card: Card, cardPosition: Vector2) -> Area2D:
	var scene := cardInPlayerHandScene.instantiate()
	scene.selectedCard.connect(card_selected)
	scene.get_node("TextureRect").set_texture(create_card_texture(card))
	scene.position = cardPosition
	scene.card = card
	add_child(scene)
	return scene

func create_card_texture(card: Card) -> Texture:
	var source: TileSetAtlasSource = get_tileset().get_source(sourceId)
	var textureRegion: Rect2i = source.get_tile_texture_region(Vector2i(card.value, 2*card.color + (0 if isCurrentPlayer or card.isVisible else 1)))
	var tileImage: Image = source.texture.get_image().get_region(textureRegion)
	return ImageTexture.create_from_image(tileImage)

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
