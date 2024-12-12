extends Effect

@export var sounds: Array[AudioStreamMP3]
@export var effect_scene: PackedScene
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	_play_sound()
	super._ready()


func _play_sound():
	var rng = RandomNumberGenerator.new()
	var sound: AudioStreamMP3 = sounds.pick_random()
	audio_player.stream = sound
	var pitch_rng = rng.randf()*15/100 - 0.1
	audio_player.pitch_scale += rng.randf()*15/100 - 0.1
	audio_player.volume_db += rng.randf()*15/100 - 0.1
	audio_player.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_sound_wave_body_entered(body: Node2D) -> void:
	if is_instance_of(body, Player): #Checking for player
		var _player = body as Player
		if player != _player:
			var tea_time_effect: Effect = effect_scene.instantiate()
			tea_time_effect.apply(_player)
