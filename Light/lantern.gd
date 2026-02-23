extends PointLight2D

@onready var timer: Timer = $Timer
var day_state = 0

func _ready() -> void:
	signals.connect("day_time", Callable(self, "_on_time_changed"))
	signals.connect("light_is_loaded", Callable(self, "_on_light_is_loaded"))
	light_off()

var tween = Tween


func _on_timer_timeout() -> void:
	if day_state == 3:
		timer.wait_time = randf_range(0.4, 0.6)
		var rng = randf_range(0.8, 1.2)
		tween = get_tree().create_tween()
		tween.parallel().tween_property(self, "texture_scale", rng, timer.wait_time)
		tween.parallel().tween_property(self, "energy", rng, timer.wait_time)
	
func _on_time_changed(state, _day_count):
	day_state = state
	if state == 0 or state == 1:
		light_off()
	elif state == 2 or state == 3:
		light_on()

func light_on():
	tween = get_tree().create_tween()
	tween.tween_property(self, "energy", 1.5, randi_range(10, 20))

func light_off():
	tween = get_tree().create_tween()
	tween.tween_property(self, "energy", 0, randi_range(10, 20))

func _on_light_is_loaded(state):
	if state == 0 or state == 1:
		light_off()
	elif state == 2 or state == 3:
		light_on()
	if state == 3 or state == 4:
		timer.wait_time = randf_range(0.4, 0.6)
		var rng = randf_range(0.8, 1.2)
		tween = get_tree().create_tween()
		tween.parallel().tween_property(self, "texture_scale", rng, timer.wait_time)
		tween.parallel().tween_property(self, "energy", rng, timer.wait_time)
