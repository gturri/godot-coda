extends Node2D

func on_card_drawn(card: Card):
	$CurrentPlayerHand.add_card(card)
	$OpponentHand.add_card_remotely.rpc(CardSerializer.serialize_card(card))
