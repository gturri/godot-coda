extends TileMap

var cardFoundShader = load("res://cardFound.gdshader")

var cards: Array[Card] = []
const sourceId := 0
@export var isCurrentPlayer := true
signal cardAdded()
signal selectedCard(cardIndex: int)

var cardsToArea2D := {}
var selectedCardOverlay
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

	cardsToId.clear()
	for i in cards.size():
		cardsToId[cards[i]] = i

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
	for i in cards.size():
		var card = cards[i]
		var cardPosition = __cardId_to_position(i)
		var cardScene = cardsToArea2D.get(card)
		if not cardScene:
			cardScene = create_card_scene(card, initialPositionNewCard)
			cardsToArea2D[card] = cardScene
			if isCurrentPlayer and card.isVisible: cardScene.apply_shader(cardFoundShader)
		create_tween_to_move_card(cardScene, cardPosition)

func create_tween_to_move_card(cardScene: Area2D, finalPosition: Vector2) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(cardScene, "position", finalPosition, transitionDurationInSecond)

func create_card_scene(card: Card, cardPosition: Vector2) -> Area2D:
	var scene := cardInPlayerHandScene.instantiate()
	scene.selectedCard.connect(card_selected)
	scene.get_node("TextureRect").set_texture(create_card_texture(card))
	scene.position = cardPosition
	scene.card = card
	add_child(scene)
	return scene

func card_selected(card: Card):
	selectedCard.emit(cardsToId[card])

func create_card_texture(card: Card) -> Texture:
	var source: TileSetAtlasSource = get_tileset().get_source(sourceId)
	var textureRegion: Rect2i = source.get_tile_texture_region(Vector2i(card.value, 2*card.color + (0 if isCurrentPlayer or card.isVisible else 1)))
	var tileImage: Image = source.texture.get_image().get_region(textureRegion)
	return ImageTexture.create_from_image(tileImage)


func __cardId_to_position(cardId: int) -> Vector2:
	var startXPos :float = -(cards.size()-1)/2.0
	return Vector2(tile_set.tile_size.x*(startXPos+cardId), 0)

func set_opponent_selected_card(selectedCardIndex: int) -> void:
	clear_opponent_selected_card()
	opponentSelectedCardIndex = selectedCardIndex
	selectedCardOverlay = create_overlay(__cardId_to_position(opponentSelectedCardIndex))
	add_child(selectedCardOverlay)

func clear_opponent_selected_card() -> void:
	if selectedCardOverlay:
		selectedCardOverlay.queue_free()
		selectedCardOverlay = null
	opponentSelectedCardIndex = null

func create_overlay(overlayPosition: Vector2) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = load("res://imgs/circle.svg")
	rect.position = overlayPosition
	return rect
