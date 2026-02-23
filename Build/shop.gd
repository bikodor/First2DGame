extends StaticBody2D

@onready var button: Button = $"../../CanvasLayer/Button"
@onready var shop_menu: Control = $"../../CanvasLayer/ShopMenu"
@onready var camera_2d: Camera2D = $"../../Player/Player/Camera2D"

@onready var health_bar = $MobHealth/HealthBar
@onready var damage_text = $MobHealth/DamageText
@onready var anim_player = $MobHealth/AnimationPlayer

@export var max_health = 2000

signal shop_is_attacked()

signal shop_destroyed()

var health = 2000:
	set(value):
		health = clamp(value, 0, max_health)
		health_bar.value = health
		if health <= 0:
			health_bar.visible = false
		else:
			health_bar.visible = true

func _ready() -> void:
	signals.connect("enemy_attack_buildings", Callable(self, "_on_damage_recieved"))
	damage_text.modulate.a = 0
	health_bar.max_value = max_health
	health = max_health
	health_bar.visible = false

func _on_damage_recieved(enemy_damage):
	health -= enemy_damage
	$AudioStreamPlayer.play()
	damage_text.text = str(enemy_damage)
	if health > 0:
		anim_player.stop()
		anim_player.play("damage_text")
		emit_signal("shop_is_attacked")
	else:
		anim_player.play("damage_text")
		await anim_player.animation_finished
		damage_text.visible = false
		emit_signal("shop_destroyed")

func _on_shop_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		button.show()


func _on_shop_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		button.hide()


func _on_button_pressed() -> void:
	shop_menu.show()
	$"../../Buttons".play()
	$"../../CanvasLayer/ActionUI".hide()
	$"../../CanvasLayer/MoveUI".hide()
	$"../../CanvasLayer/MenuButton".hide()


func _on_close_button_pressed() -> void:
	shop_menu.hide()
	$"../../Buttons".play()
	$"../../CanvasLayer/ActionUI".show()
	$"../../CanvasLayer/MoveUI".show()
	$"../../CanvasLayer/MenuButton".show()


func _on_add_food_button_pressed() -> void:
	$"../../Buttons".play()
	if global.gold > 0:
		global.gold -= 1
		global.food += 1


func _on_add_wood_button_pressed() -> void:
	$"../../Buttons".play()
	if global.gold > 0:
		global.gold -= 1
		global.wood += 1


func _on_add_materials_button_pressed() -> void:
	$"../../Buttons".play()
	if global.gold > 0:
		global.gold -= 1
		global.materials += 1


func _on_wood_button_pressed() -> void:
	$"../../Buttons".play()
	global.wood -= 1
	health += 50
