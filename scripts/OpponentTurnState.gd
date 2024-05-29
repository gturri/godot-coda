extends BaseState
class_name OpponentTurnState

var opponentPickedCardTextureRect

func _init(context_p):
	context = context_p

func on_enter_state() -> void:
	context.get_node("InfoArea").log_info("It is the turn of your opponent")

func on_game_ended() -> void:
	context.set_state(GameOverState.new(context, false))

func opponent_picked_card_at_the_beginning_of_the_turn(card: Card, initialPosition: Vector2) -> void:
		opponentPickedCardTextureRect = TextureRect.new()
		opponentPickedCardTextureRect.set_texture(context.get_node("AvailableTiles").get_card_texture(card, false))
		opponentPickedCardTextureRect.position = initialPosition
		context.add_child(opponentPickedCardTextureRect)
		var tween = context.get_tree().create_tween()
		tween.tween_property(opponentPickedCardTextureRect, "position", context.get_node("OpponentPickedCardOverviewPosition").position, 0.5)

func _notification(notif):
	if notif == NOTIFICATION_PREDELETE: # Destructor; see https://docs.godotengine.org/en/4.2/tutorials/best_practices/godot_notifications.html
		if opponentPickedCardTextureRect:
			opponentPickedCardTextureRect.queue_free()
