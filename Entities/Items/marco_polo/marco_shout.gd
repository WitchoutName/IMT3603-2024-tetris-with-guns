extends Label

var animation_duration = 0.75

func _ready():
	animate_float_up()

func animate_float_up():
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(0, -50), animation_duration)
	tween.tween_property(self, "modulate:a", 0.0, animation_duration) 
	tween.connect("finished", Callable(self, "_on_animation_finished")) 

func _on_animation_finished():
	queue_free()
