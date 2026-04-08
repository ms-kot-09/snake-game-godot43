extends Node
# ─── AudioManager Autoload ────────────────────────────────────────────────────
# Generates all sound effects procedurally using PCM wave synthesis.
# No external audio files needed.

var _eat_player   : AudioStreamPlayer
var _die_player   : AudioStreamPlayer
var _click_player : AudioStreamPlayer
var _move_player  : AudioStreamPlayer
var _music_player : AudioStreamPlayer

const SAMPLE_RATE := 22050

func _ready() -> void:
	_eat_player   = _make_player()
	_die_player   = _make_player()
	_click_player = _make_player()
	_move_player  = _make_player()
	_music_player = _make_player()
	_music_player.volume_db = -6.0

	_eat_player.stream   = _gen_eat_sound()
	_die_player.stream   = _gen_die_sound()
	_click_player.stream = _gen_click_sound()
	_move_player.stream  = _gen_move_sound()

	_apply_volumes()

func _make_player() -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	add_child(p)
	return p

func _apply_volumes() -> void:
	var sfx := GameData.sfx_volume
	_eat_player.volume_db   = linear_to_db(sfx)
	_die_player.volume_db   = linear_to_db(sfx)
	_click_player.volume_db = linear_to_db(sfx)
	_move_player.volume_db  = linear_to_db(sfx * 0.3)

func play_eat() -> void:
	_apply_volumes()
	_eat_player.play()

func play_die() -> void:
	_apply_volumes()
	_die_player.play()

func play_click() -> void:
	_apply_volumes()
	_click_player.play()

func play_move() -> void:
	if GameData.sfx_volume < 0.05:
		return
	_apply_volumes()
	if not _move_player.playing:
		_move_player.play()

# ─── PCM Synthesis ────────────────────────────────────────────────────────────
func _make_wav(data: PackedFloat32Array) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format    = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate  = SAMPLE_RATE
	wav.stereo    = false
	var bytes := PackedByteArray()
	bytes.resize(data.size() * 2)
	for i in data.size():
		var s := int(clamp(data[i], -1.0, 1.0) * 32767.0)
		bytes[i * 2]     = s & 0xFF
		bytes[i * 2 + 1] = (s >> 8) & 0xFF
	wav.data = bytes
	return wav

func _sine(freq: float, t: float) -> float:
	return sin(TAU * freq * t)

func _gen_eat_sound() -> AudioStreamWAV:
	var dur    := 0.18
	var frames := int(SAMPLE_RATE * dur)
	var data   := PackedFloat32Array()
	data.resize(frames)
	for i in frames:
		var t    := float(i) / SAMPLE_RATE
		var env  := exp(-t * 12.0)
		var freq := lerp(440.0, 880.0, float(i) / frames)
		data[i]  = _sine(freq, t) * env * 0.6
	return _make_wav(data)

func _gen_die_sound() -> AudioStreamWAV:
	var dur    := 0.6
	var frames := int(SAMPLE_RATE * dur)
	var data   := PackedFloat32Array()
	data.resize(frames)
	for i in frames:
		var t   := float(i) / SAMPLE_RATE
		var env := exp(-t * 4.0)
		var f1  := lerp(300.0, 80.0,  float(i) / frames)
		var f2  := lerp(450.0, 120.0, float(i) / frames)
		data[i] = (_sine(f1, t) + _sine(f2, t) * 0.5) * env * 0.5
	return _make_wav(data)

func _gen_click_sound() -> AudioStreamWAV:
	var dur    := 0.06
	var frames := int(SAMPLE_RATE * dur)
	var data   := PackedFloat32Array()
	data.resize(frames)
	for i in frames:
		var t   := float(i) / SAMPLE_RATE
		var env := exp(-t * 40.0)
		data[i] = _sine(600.0, t) * env * 0.4
	return _make_wav(data)

func _gen_move_sound() -> AudioStreamWAV:
	var dur    := 0.04
	var frames := int(SAMPLE_RATE * dur)
	var data   := PackedFloat32Array()
	data.resize(frames)
	for i in frames:
		var t   := float(i) / SAMPLE_RATE
		var env := exp(-t * 60.0)
		data[i] = _sine(200.0, t) * env * 0.2
	return _make_wav(data)
