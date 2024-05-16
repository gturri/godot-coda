class_name CardSerializer

static func serialize_card(card: Card) -> String:
	return str(card.color) + "," + str(card.value) + "," + str(card.isVisible)

static func deserialize_card(data: String) -> Card:
	var splits := data.split(",")
	var card = Card.new(int(splits[0]), int(splits[1]))
	card.isVisible = (splits[2] == "true")
	return card

static func serialize_deck(cards: Array[Card]) -> String:
	return "|".join(cards.map(func (c: Card): return serialize_card(c)))

static func deserialize_deck(serializedCards: String) -> Array[Card]:
	var result: Array[Card] = []
	for serializedCard in serializedCards.split("|"):
		result.append(deserialize_card(serializedCard))
	return result
