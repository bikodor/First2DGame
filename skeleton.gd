extends Enemy


func _on_mob_health_no_health() -> void:
	state = DEATH

func _on_mob_health_damage_recieved() -> void:
	state = IDLE
	state = DAMAGE
