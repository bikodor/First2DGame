extends CharacterBody2D

enum {
	IDLE,
	MOVE,
	ATTACK,
	ATTACK2,
	ATTACK3,
	DAMAGE,
	BLOCK,
	SLIDE,
	DEATH,
	TELEPORT
}

const SPEED = 150.0
const JUMP_VELOCITY = -400.0

@onready var anim = $AnimatedSprite2D
@onready var anim_player = $AnimationPlayer
@onready var stats = $Stats
@onready var leafs: GPUParticles2D = $Leafs
@onready var smack: AudioStreamPlayer = $Sounds/Smack
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


var state = MOVE;
var run_speed = 1;
var combo = false
var attack_cooldown = false
var damage_multipier = 1
var recovery = false


func _ready() -> void:
	signals.connect("enemy_attack", Callable(self, "_on_damage_recieved_player"))


func _physics_process(delta: float) -> void:
	match state:
		MOVE:
			move_state()
		ATTACK:
			attack_state()
		ATTACK2:
			attack2_state()
		ATTACK3:
			attack3_state()
		BLOCK:
			block_state()
		SLIDE:
			slide_state()
		DAMAGE:
			damage_state()
		DEATH:
			death_state()
		TELEPORT:
			teleport_state()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

#	 Handle jump. ("ui_accept")
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		anim_player.play("Jump")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#var direction := Input.get_axis("left", "right")
	#if direction:
		#velocity.x = direction * SPEED
		#if velocity.y == 0:
			#anim_player.play("Run")
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#if velocity.y == 0:
			#anim_player.play("Idle")
		
	#if direction == 1:
		#anim_player.flip_h = false
	#elif direction == -1:
		#anim_player.flip_h = true

	if velocity.y > 0:
		anim_player.play("Fall")
	
	global.player_damage = int(floor(global.damage_basic * damage_multipier))
		
	global.player_pos = self.position
	
	
	move_and_slide()


func move_state():
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED * run_speed
		if velocity.y == 0:
			if run_speed == 1:
				anim_player.play("Walk")
			else:
				anim_player.play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			anim_player.play("Idle")
	if direction == 1:
		anim.flip_h = false
		$AttackDirection.rotation_degrees = 0
	elif direction == -1:
		anim.flip_h = true
		$AttackDirection.rotation_degrees = 180

	if Input.is_action_pressed("run") and not recovery:
		run_speed = 1.5
		stats.stamina -= stats.run_cost
	else:
		run_speed = 1
	if Input.is_action_pressed("block"):
		if run_speed <= 1:
			if recovery == false:
				velocity.x = 0
				if stats.stamina > 1:
					Input.action_release("block")
					state = BLOCK
		else:
			if recovery == false:
				stats.stamina_cost = stats.slide_cost
				if stats.stamina_cost <= stats.stamina:
					state = SLIDE
	
	if Input.is_action_pressed("teleport"):
		Input.action_release("teleport")
		state = TELEPORT
	
	if Input.is_action_pressed("attack"):
			if recovery == false:
				stats.stamina_cost = stats.attack_cost
				if attack_cooldown == false and stats.stamina_cost <= stats.stamina:
					Input.action_release("attack")
					state = ATTACK


func block_state():
	stats.stamina -= stats.block_cost
	velocity.x = 0
	anim_player.play("Block")
	await anim_player.animation_finished
	state = MOVE


func slide_state():
	anim_player.play("Slide")
	await anim_player.animation_finished
	state = MOVE


func attack_state():
	stats.stamina_cost = stats.attack_cost
	damage_multipier = 1
	if Input.is_action_pressed("attack") and combo == true and stats.stamina_cost <= stats.stamina:
		if recovery == false:
			Input.action_release("attack")
			state = ATTACK2
	velocity.x = 0
	anim_player.play("Attack")
	await anim_player.animation_finished
	attack_freeze()
	state = MOVE


func attack2_state():
	anim_player.play("Attack2")
	stats.stamina_cost = stats.attack_cost
	damage_multipier = 1.2
	if Input.is_action_pressed("attack") and combo == true and stats.stamina_cost <= stats.stamina:
		if recovery == false:
			Input.action_release("attack")
			state = ATTACK3
	await anim_player.animation_finished
	state = MOVE


func attack3_state():
	damage_multipier = 2
	anim_player.play("Attack3")
	await anim_player.animation_finished
	state = MOVE


func damage_state():
	anim_player.play("Damage")
	await anim_player.animation_finished
	state = MOVE


func death_state():
	var tree := get_tree()
	velocity.x = 0
	anim_player.play("Death")
	$"../../CanvasLayer/LoseText".show()
	$"../../CanvasLayer/MenuButton".hide()
	$"../../CanvasLayer/ActionUI".hide()
	$"../../CanvasLayer/MoveUI".hide()
	await anim_player.animation_finished
	queue_free()
	tree.change_scene_to_file("res://Menu.tscn")

func teleport_state():
		velocity.x = 0
		anim_player.play("Teleport")
		await anim_player.animation_finished
		position.x = 0
		state = MOVE
	

func combo1():
	combo = true
	await anim_player.animation_finished
	combo = false


func attack_freeze():
	attack_cooldown = true
	await get_tree().create_timer(0.5).timeout
	attack_cooldown = false


func _on_damage_recieved_player(enemy_damage):
	smack.play()
	if state == BLOCK:
		enemy_damage = int(floor(enemy_damage / 2.0))
	elif state == SLIDE:
		enemy_damage = 0
	else:
		state = DAMAGE
		damage_anim()
	stats.health -= enemy_damage
	if stats.health <= 0:
		stats.health = 0
		state = DEATH


func _on_stats_no_stamina() -> void:
	recovery = true
	await get_tree().create_timer(2).timeout
	recovery = false


func damage_anim():
	velocity.x = 0
	animated_sprite.modulate = Color(1.0, 0.0, 0.0, 1.0)
	if animated_sprite.flip_h == true:
		velocity.x += 200
	else:
		velocity.x -= 200
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "velocity", Vector2(0, 0), 0.1)
	tween.parallel().tween_property(animated_sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)


func steps():
	leafs.emitting = true
	leafs.one_shot = true


func _on_shop_shop_destroyed() -> void:
	state = DEATH
