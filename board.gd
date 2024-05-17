extends Node2D

var isInitializationPhase := true
@export var nbCardsInitially := 4

func on_card_drawn(card: Card, card_id: int):
	if isInitializationPhase:
		if $CurrentPlayerHand.cards.size() < nbCardsInitially:
			$AvailableTiles.player_picked_card.rpc(card_id)
			$CurrentPlayerHand.add_card(card)
			$OpponentHand.add_card_remotely.rpc(CardSerializer.serialize_card(card))
		else:
			print("User hand is already full")
			# TODO: display a warning to the player?
			return
	else:
		pass #TODO

func on_card_added_to_player_hand():
	if $CurrentPlayerHand.cards.size() == nbCardsInitially \
		and $OpponentHand.cards.size() == nbCardsInitially:
		isInitializationPhase = false
		print("initialization completed")
