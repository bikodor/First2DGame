extends StaticBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var spawn_count = 0
var mushroom_preload = preload("res://Mobs/mushroom.tscn")
var skeleton_preload = preload("res://Mobs/skeleton.tscn")
var half_mobs_on_day = 0


func _ready() -> void:
	signals.connect("day_time", Callable(self, "_on_time_changed"))
	signals.connect("spawn_enemy", Callable(self, "_on_spawn_enemy"))


func enemy_spawn(hp):
	var rng = randi_range(1, 2)
	if rng == 1:
		mushroom_spawn(hp)
	elif rng == 2:
		skeleton_spawn(hp)


func skeleton_spawn(hp):
	var skeleton = skeleton_preload.instantiate()
	var mob_health = skeleton.get_node("MobHealth")
	mob_health.max_health = hp
	skeleton.position = Vector2(self.position.x, 480)
	$"../../Mobs".add_child(skeleton)


func mushroom_spawn(hp):
	var mushroom = mushroom_preload.instantiate()
	var mob_health = mushroom.get_node("MobHealth")
	mob_health.max_health = hp
	mushroom.position = Vector2(self.position.x, 480)
	$"../../Mobs".add_child(mushroom)


func _on_spawn_enemy(count, day_count):
	spawn_count = 0
	var hp_scale = (day_count - 1) / 5 + 1
	signals.emit_signal("enemy_spawned")
	for i in count:
		animation_player.play("Spawn")
		await animation_player.animation_finished
		enemy_spawn(day_count * 50 * hp_scale * 2)
		spawn_count += 1
	animation_player.play("Idle")


func _on_time_changed(state, day_count):
	spawn_count = 0
	var rng = randi_range(0, 2)
	var hp_scale = (day_count - 1) / 5 + 1
	if state == 0:
		half_mobs_on_day = day_count + rng
		global.all_mobs_on_day += half_mobs_on_day
		global.mobs_in_level += half_mobs_on_day
		signals.emit_signal("enemy_spawned")
		for i in (day_count + rng):
			animation_player.play("Spawn")
			await animation_player.animation_finished
			enemy_spawn((day_count * 50) * hp_scale * 2)
			spawn_count += 1
	if spawn_count == day_count + rng:
		animation_player.play("Idle")


func _on_mob_health_no_health() -> void:
	signals.emit_signal("spawner_dead", position.x)
	animation_player.play("Death")
	await animation_player.animation_finished
	queue_free()


func _on_mob_health_damage_recieved() -> void:
	animation_player.stop()
	animation_player.play("Hit")
