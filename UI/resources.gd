extends CanvasLayer


@onready var gold_text: Label = $Control/PanelContainer/HBoxContainer/GoldText
@onready var food_text: Label = $Control/PanelContainer/HBoxContainer/FoodText
@onready var wood_text: Label = $Control/PanelContainer/HBoxContainer/WoodText
@onready var materials_text: Label = $Control/PanelContainer/HBoxContainer/RockText


func _process(_delta: float) -> void:
	gold_text.text = str(global.gold)
	food_text.text = str(global.food)
	wood_text.text = str(global.wood)
	materials_text.text = str(global.materials)
	if global.food > 0:
		$Control/PanelContainer/HBoxContainer/FoodIcon/FoodButton.show()
	else:
		$Control/PanelContainer/HBoxContainer/FoodIcon/FoodButton.hide()
	if global.wood > 0:
		$Control/PanelContainer/HBoxContainer/WoodIcon/WoodButton.show()
	else:
		$Control/PanelContainer/HBoxContainer/WoodIcon/WoodButton.hide()
	if global.materials > 0:
		$Control/PanelContainer/HBoxContainer/RockIcon/RockButton.show()
	else:
		$Control/PanelContainer/HBoxContainer/RockIcon/RockButton.hide()
		
