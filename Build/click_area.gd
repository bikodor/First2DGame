extends Area2D

@onready var button: Button = $"../Button"
@export var shop_path: NodePath
@onready var shop: StaticBody2D = $".."
signal open_shop()

func _input_event(_viewport, event, _shape_idx):
	# Мышь
	if event is InputEventMouseButton:
		emit_signal("open_shop")

	# Палец (телефон)
	if event is InputEventScreenTouch:
		emit_signal("open_shop")
