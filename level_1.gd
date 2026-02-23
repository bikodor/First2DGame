extends Node2D


@onready var light = $Light/DirectionalLight2D
@onready var day_text = $CanvasLayer/DayText
@onready var information_text: Label = $CanvasLayer/InformationText
@onready var anim_player_text = $CanvasLayer/DayText/AnimationPlayer
@onready var anim_player_info = $CanvasLayer/InformationText/AnimationPlayer
@onready var player = $Player/Player


var spawner_preload = preload("res://Build/spawner.tscn")
var direction_complete = 0
var state = MORNING
var day_count: int
var position_spawners = [0, 0]


enum {
	MORNING,
	DAY,
	EVENING,
	NIGHT
}


func _ready() -> void:
	signals.connect("spawner_dead", Callable(self, "_on_spawner_death"))
	signals.connect("enemy_spawned", Callable(self, "_on_enemy_spawned"))
	global.gold = 0
	global.food = 0
	global.wood = 0
	global.materials = 0
	global.damage_basic = 20
	global.player_health = 150
	global.first_spawner_hp = 10000
	global.first_spawner_max_hp = 10000
	global.second_spawner_hp = 10000
	global.second_spawner_max_hp = 10000
	global.mobs_in_level = 0
	global.all_mobs_on_day = 0
	light.enabled = true
	day_count = 1
	spawner_spawn(1200, 10000, 10000)
	spawner_spawn(-1200, 10000, 10000)
	morning_state()
	set_day_text("DAY " + str(day_count))
	day_text_fade()
	signals.emit_signal("day_time", state, day_count)

var tween = Tween

func spawner_spawn(position_x, hp, max_hp):
	var spawner = spawner_preload.instantiate()
	spawner.position = Vector2(position_x, 510)
	var mob_health = spawner.get_node("MobHealth")
	mob_health.max_health = max_hp
	$Spawners.add_child(spawner)
	mob_health.health = hp
	if position_x < 0:
		global.first_spawner_hp = hp
		global.first_spawner_max_hp = max_hp
		position_spawners[0] = position_x
	else:
		global.second_spawner_hp = hp
		global.second_spawner_max_hp = max_hp
		position_spawners[1] = position_x


func _on_spawner_death(position_x):
	if abs(position_x) <= 4000:
		if position_x > 0:
			if position_x == 1200:
				spawner_spawn(position_x + 1200, 20000, 20000)
			elif position_x == 2400:
				spawner_spawn(position_x + 1200, 30000, 30000)
			elif position_x == 3600:
				spawner_spawn(position_x + 1200, 40000, 40000)
		else:
			if position_x == -1200:
				spawner_spawn(position_x - 1200, 20000, 20000)
			elif position_x == -2400:
				spawner_spawn(position_x - 1200, 30000, 30000)
			elif position_x == -3600:
				spawner_spawn(position_x - 1200, 40000, 40000)
	else:
		if position_x < 0:
			position_spawners[0] = 0
			direction_complete = 1
		else:
			position_spawners[1] = 0
			direction_complete = 2
		if position_spawners[0] == 0 and position_spawners[1] == 0:
			$CanvasLayer/LoseText/Label.text = "You Win!"
			$CanvasLayer/LoseText.show()
			$CanvasLayer/MenuButton.hide()
			$CanvasLayer/ActionUI.hide()
			$CanvasLayer/MoveUI.hide()
			await get_tree().create_timer(3).timeout
			get_tree().change_scene_to_file("res://Menu.tscn")


func morning_state():
	tween = get_tree().create_tween()
	tween.tween_property(light, "energy", 0.2, 12)


func evening_state():
	tween = get_tree().create_tween()
	tween.tween_property(light, "energy", 0.95, 12)


func _on_day_night_timeout() -> void:
	if state < 3:
		state += 1
	else:
		global.all_mobs_on_day = 0
		global.mobs_in_level = 0
		state = MORNING
		day_count += 1
		set_day_text("DAY " + str(day_count))
		day_text_fade()
	match state:
		MORNING:
			morning_state()
		EVENING:
			evening_state()
	
	signals.emit_signal("day_time", state, day_count)


func day_text_fade():
	anim_player_text.play("day_text_fade_in")
	await get_tree().create_timer(3).timeout
	anim_player_text.play("day_text_fade_out")


func set_day_text(text):
	day_text.text = text


func set_information_text(text):
	information_text.text = text


func information_text_fade():
	anim_player_info.play("info_text_fade_in")
	await get_tree().create_timer(3).timeout
	anim_player_info.play("info_text_fade_out")


func _on_shop_shop_is_attacked() -> void:
	set_day_text("Enemies are attacking your Shop!")
	day_text_fade()


func _on_enemy_spawned():
	set_information_text("Enemies spawn, be careful!")
	information_text_fade()


func _on_manager_game_is_loaded() -> void:
	$Light/DayNight.stop()
	$Light/DayNight.start(40.0)
	set_day_text("DAY " + str(day_count))
	day_text_fade()
	tween.stop()
	if state == MORNING:
		light.energy = 0.2
	elif state == DAY:
		light.energy = 0.2
	elif state == EVENING:
		light.energy = 0.95
	else:
		light.energy = 0.95
	for child in $Spawners.get_children():
		child.queue_free()
	if position_spawners[0] == 0 or position_spawners[1] == 0:
		if position_spawners[0] == 0:
			spawner_spawn(position_spawners[1], global.second_spawner_hp, global.second_spawner_max_hp)
		else:
			spawner_spawn(position_spawners[0], global.first_spawner_hp, global.first_spawner_max_hp)
	else:
		spawner_spawn(position_spawners[0], global.first_spawner_hp, global.first_spawner_max_hp)
		spawner_spawn(position_spawners[1], global.second_spawner_hp, global.second_spawner_max_hp)
	for child in $Mobs.get_children():
		child.queue_free()
	if global.mobs_in_level == 0:
		pass
	elif global.mobs_in_level != 0 and global.all_mobs_on_day != global.mobs_in_level:
		signals.emit_signal("spawn_enemy", int(ceil(global.mobs_in_level / 2.0)), day_count)
	else:
		if state == 0:
			signals.emit_signal("day_time", state, day_count)
		else:
			signals.emit_signal("spawn_enemy", int(ceil(global.mobs_in_level / 2.0)), day_count)
