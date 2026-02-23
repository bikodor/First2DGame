extends Node

signal game_is_loaded()
signal stats_is_loaded()

@onready var pause_menu = $"../CanvasLayer/PauseMenu"
@onready var player: CharacterBody2D = $"../Player/Player"
@onready var buttons: AudioStreamPlayer = $"../Buttons"
@onready var level_1: Node2D = $".."
@onready var mobs: Node2D = $"../Mobs"
@onready var shop: StaticBody2D = $"../Buildings/Shop"



var game_paused: bool = false
var save_path := "user://save.dat"


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		game_paused = !game_paused
	
	if game_paused == true:
		get_tree().paused = true
		pause_menu.show()
	else:
		get_tree().paused = false
		pause_menu.hide()


func _on_resume_pressed() -> void:
	game_paused = !game_paused
	buttons.play()

func _on_quit_pressed() -> void:
	buttons.play()
	await buttons.finished
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Menu.tscn")


func _on_menu_button_pressed() -> void:
	game_paused = !game_paused
	buttons.play()
	
	

func save_game():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		print("SAVE ERROR:", FileAccess.get_open_error())
		return

	file.store_var(global.gold)
	file.store_var(player.position.x)
	file.store_var(player.position.y)
	file.store_var(global.food)
	file.store_var(global.wood)
	file.store_var(global.materials)
	file.store_var(global.damage_basic)
	file.store_var(level_1.day_count)
	file.store_var(level_1.direction_complete)
	file.store_var(level_1.position_spawners[0])
	file.store_var(level_1.position_spawners[1])
	file.store_var(level_1.state)
	file.store_var(global.first_spawner_max_hp)
	file.store_var(global.second_spawner_max_hp)
	file.store_var(global.first_spawner_hp)
	file.store_var(global.second_spawner_hp)
	file.store_var(global.mobs_in_level)
	file.store_var(global.all_mobs_on_day)
	file.store_var(global.player_health)
	file.store_var(global.player_stamina)
	file.store_var($"../Buildings/Shop".health)
	print(global.first_spawner_hp)
	print(global.second_spawner_hp)
	print(global.first_spawner_max_hp)
	print(global.second_spawner_max_hp)

func load_game():
	if not FileAccess.file_exists(save_path):
		print("NO SAVE FILE")
		return

	var file = FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		print("LOAD ERROR:", FileAccess.get_open_error())
		return

	global.gold = file.get_var()
	player.position.x = file.get_var()
	player.position.y = file.get_var()
	global.food = file.get_var()
	global.wood = file.get_var()
	global.materials = file.get_var()
	global.damage_basic = file.get_var()
	level_1.day_count = file.get_var()
	level_1.direction_complete = file.get_var()
	level_1.position_spawners[0] = file.get_var()
	level_1.position_spawners[1] = file.get_var()
	level_1.state = file.get_var()
	global.first_spawner_max_hp = file.get_var()
	global.second_spawner_max_hp = file.get_var()
	global.first_spawner_hp = file.get_var()
	global.second_spawner_hp = file.get_var()
	print(global.first_spawner_hp)
	print(global.second_spawner_hp)
	print(global.first_spawner_max_hp)
	print(global.second_spawner_max_hp)
	global.mobs_in_level = file.get_var()
	global.all_mobs_on_day = file.get_var()

	emit_signal("game_is_loaded")

	global.player_health = file.get_var()
	global.player_stamina = file.get_var()

	emit_signal("stats_is_loaded")

	$"../Buildings/Shop".health = file.get_var()
	signals.emit_signal("light_is_loaded", level_1.state)
	
	
	
	

func _on_save_pressed() -> void:
	save_game()
	game_paused = !game_paused
	buttons.play()


func _on_load_pressed() -> void:
	load_game()
	game_paused = !game_paused
	buttons.play()
