extends Node2D

@onready var health_bar = $CanvasLayer/TextureProgressBar


func _ready() -> void:
	health_bar.value = global.player_health
