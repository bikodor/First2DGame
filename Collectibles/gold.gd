extends CharacterBody2D

var can_pickup = false

func _ready() -> void:
	$Detector/CollisionShape2D2.disabled = true
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "velocity", Vector2(randi_range(-70, 70), -150), 0.3)

	
		
func _process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.x = 0
		$Detector/CollisionShape2D2.disabled = false
		
	move_and_slide()


func _on_detector_body_entered(body: Node2D) -> void:
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "velocity", Vector2(0, -150), 0.3)
	tween.parallel().tween_property(self, "modulate:a", 0, 0.5)
	global.gold += 1
	tween.tween_callback(queue_free)

	
