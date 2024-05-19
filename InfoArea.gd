extends RichTextLabel

func log_info(message: String) -> void:
	append_text("- " + message + "\n")

func log_warning(message: String) -> void:
	push_color(Color.YELLOW)
	log_info(message)
	pop()
