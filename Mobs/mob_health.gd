extends Node2D

signal no_health()

signal damage_recieved()

@onready var health_bar = $HealthBar
@onready var damage_text = $DamageText
@onready var anim_player = $AnimationPlayer

@export var max_health = 100

var health = 100:
	set(value):
		health = value
		health_bar.value = health
		if health <= 0:
			health_bar.visible = false
		else:
			health_bar.visible = true


func _ready() -> void:
	damage_text.modulate.a = 0
	health_bar.max_value = max_health
	health = max_health
	health_bar.visible = false

func _on_hurt_box_area_entered(_area: Area2D) -> void:
	health -= global.player_damage
	damage_text.text = str(global.player_damage)
	if health > 0:
		anim_player.stop()
		anim_player.play("damage_text")
		emit_signal("damage_recieved")
	else:
		emit_signal("no_health")
		anim_player.play("damage_text")
		await anim_player.animation_finished
		damage_text.visible = false
