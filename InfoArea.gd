extends RichTextLabel

@export var timeUntilMessageIsntConsideredRecentAnymore_inSecond = 3
var allEntries := [] # TODO: create an ad hoc Entry class

func log_info(message: String) -> void:
	add_message(message, "info")

func log_warning(message: String) -> void:
	add_message(message, "warning")

func add_message(message: String, severity: String) -> void:
	allEntries.append([add_pre_and_postfix(message), severity, true])
	print_entries()
	var currentSize = allEntries.size()
	get_tree().create_timer(timeUntilMessageIsntConsideredRecentAnymore_inSecond).timeout.connect(func (): mark_message_as_not_recent_anymore(currentSize-1))

func add_pre_and_postfix(message: String) -> String:
	return "- " + message + "\n"

func mark_message_as_not_recent_anymore(entryIndex: int) -> void:
	allEntries[entryIndex][2] = false
	print_entries()

func print_entries() -> void:
	var allText = ""
	for entry in allEntries:
		var message = entry[0]
		var severity = entry[1]
		var isRecentMessage: bool = entry[2]
		var optionalOpeningTags := ""
		var optionalClosingTags := ""
		if severity == "warning":
			optionalOpeningTags += "[color=yellow]"
			optionalClosingTags += "[/color]"
		if isRecentMessage:
			optionalOpeningTags += "[shake]" #TODO: find something more user friendly (see eg https://forum.godotengine.org/t/trying-to-make-the-highlight-of-a-richtextlabel-blink/38042 )
			optionalClosingTags = "[/shake]" + optionalClosingTags
		allText += optionalOpeningTags + message + optionalClosingTags
	set_text(allText)

