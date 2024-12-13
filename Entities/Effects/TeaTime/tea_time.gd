extends Effect

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var sounds: Array[AudioStreamMP3]
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_play_sound()
	_play_animation()
	super._ready()


func _play_animation():
	var rng = RandomNumberGenerator.new()
	var anims = animation_player.get_animation_list()
	var anim = anims[rng.randi_range(0, len(anims)-1)]
	animation_player.speed_scale += rng.randf()*15/100 - 0.075
	animation_player.play(anim)

func _play_sound():
	var rng = RandomNumberGenerator.new()
	var sound: AudioStreamMP3 = sounds.pick_random()
	audio_player.stream = sound
	var pitch_rng = rng.randf()*15/100 - 0.1
	audio_player.pitch_scale += rng.randf()*15/100 - 0.1
	audio_player.volume_db += rng.randf()*15/100 - 0.1
	audio_player.play()


func apply(player: Player):
	super.apply(player)
	player.is_frosen = true
	
func remove():
	player.is_frosen = false
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_audio_stream_player_2d_finished() -> void:
	_play_sound()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	_play_animation()
