extends Area2D

signal selectedCard(card: Card)

var card: Card

func _input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("select_card"):
		selectedCard.emit(card)

func apply_shader(shader: Shader) -> void:
	$TextureRect.material = ShaderMaterial.new()
	$TextureRect.material.set_shader(shader)
