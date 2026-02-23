extends CharacterBody2D
class_name Enemy


enum {
	IDLE,
	ATTACK,
	CHASE,
	DAMAGE,
	DEATH,
	RECOVER
}
var state: int = 0:
	set(value):
		state = value
		match state:
			IDLE:
				idle_state()
			ATTACK:
				attack_state()
			DAMAGE:
				damage_state()
			DEATH:
				death_state()
			RECOVER:
				recover_state()
	

@onready var anim_player = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D

var player = Vector2.ZERO
var direction = Vector2.ZERO
var damage = 20
var move_speed = 50

func _ready() -> void:
	state = CHASE


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if state == CHASE:
		chase_state()
	
	move_and_slide()
	
	

func _on_attack_range_body_entered(_body: Node2D) -> void:
	state = ATTACK
	
func idle_state():
	velocity.x = 0
	anim_player.play("Idle")
	state = CHASE

func attack_state():
	velocity.x = 0
	anim_player.play("Attack")
	await anim_player.animation_finished
	state = RECOVER

func chase_state():
	anim_player.play("Run")
	if global.player_pos == null:
		return
	direction = (global.player_pos - self.position).normalized()
	if direction.x < 0:
		sprite.flip_h = true
		$AttackDirection.rotation_degrees = 180
	else:
		sprite.flip_h = false
		$AttackDirection.rotation_degrees = 0
	velocity.x = direction.x * move_speed
		
func damage_state():
	velocity.x = 0
	damage_anim()
	anim_player.play("Damage")
	await anim_player.animation_finished
	state = IDLE
	

func death_state():
	velocity.x = 0
	anim_player.play("Death")
	await anim_player.animation_finished
	signals.emit_signal("enemy_died", position)
	if global.mobs_in_level > 0:
		global.mobs_in_level -= 1
	else:
		global.mobs_in_level = 0
		global.all_mobs_on_day = 0
	queue_free()
	
func recover_state():
	velocity.x = 0
	anim_player.play("Recover")
	await anim_player.animation_finished
	if $AttackDirection/AttackRange.has_overlapping_bodies():
		state = ATTACK
	else:
		state = IDLE

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.collision_layer == 16:
		signals.emit_signal("enemy_attack", damage)
	else:
		signals.emit_signal("enemy_attack_buildings", damage)


func damage_anim():
	direction = (global.player_pos - self.position).normalized()
	velocity.x = 0
	if direction.x < 0:
		velocity.x += 100
	elif direction.x > 0:
		velocity.x -= 100
	var tween = get_tree().create_tween()
	tween.tween_property(self, "velocity", Vector2(0, 0), 0.1)


func _on_run_timeout() -> void:
	move_speed = move_toward(move_speed, randi_range(120, 170), 100)
