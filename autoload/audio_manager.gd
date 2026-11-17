extends Node
## Procedural SFX + music (no asset files) and volume/haptic settings.

const RATE: int = 22050
const MUSIC_RATE: int = 11025
const VOICES: int = 6
const BASS: Array[float] = [110.0, 87.31, 130.81, 98.0]
const ARP: Array[float] = [440.0, 523.25, 659.25, 523.25, 392.0, 493.88, 587.33, 493.88]

var _players: Array[AudioStreamPlayer] = []
var _next: int = 0
var _sounds: Dictionary = {}
var _music: AudioStreamPlayer
var _audio_ok: bool = true


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_audio_ok = DisplayServer.get_name() != "headless"
	_ensure_bus("Music")
	_ensure_bus("SFX")
	_build_sounds()
	for i in VOICES:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		_players.append(player)
	_music = AudioStreamPlayer.new()
	_music.bus = "Music"
	_music.stream = _make_music()
	add_child(_music)
	SaveManager.settings_changed.connect(_apply_settings)
	_apply_settings()
	if _audio_ok:
		_music.play()


func play(sound: String) -> void:
	if not _audio_ok:
		return
	var stream: AudioStream = _sounds.get(sound)
	if stream == null:
		return
	var player: AudioStreamPlayer = _players[_next]
	_next = (_next + 1) % VOICES
	player.stream = stream
	player.play()


func _exit_tree() -> void:
	if _music != null:
		_music.stop()
		_music.stream = null
	for player in _players:
		player.stop()
		player.stream = null
	_sounds.clear()


func haptic(ms: int) -> void:
	if bool(SaveManager.settings.get("haptics", true)):
		Input.vibrate_handheld(ms)


func _build_sounds() -> void:
	_sounds["click"] = _melody([900.0], 0.05, 0.25, 1)
	_sounds["dig"] = _melody([140.0], 0.09, 0.5, 2)
	_sounds["deny"] = _melody([170.0, 120.0], 0.07, 0.3, 1)
	_sounds["sell"] = _melody([1047.0, 1568.0], 0.06, 0.35, 0)
	_sounds["upgrade"] = _melody([523.0, 659.0, 784.0], 0.07, 0.4, 0)
	_sounds["win"] = _melody([523.0, 659.0, 784.0, 1047.0], 0.13, 0.45, 0)
	_sounds["lose"] = _melody([330.0, 262.0, 196.0], 0.18, 0.3, 1)


func _melody(freqs: Array, note_dur: float, vol: float, kind: int) -> AudioStreamWAV:
	var per_note: int = int(RATE * note_dur)
	var bytes := PackedByteArray()
	bytes.resize(per_note * freqs.size() * 2)
	var idx: int = 0
	for freq in freqs:
		var phase: float = 0.0
		for i in per_note:
			var t: float = float(i) / float(per_note)
			phase += TAU * float(freq) / float(RATE)
			var env: float = (1.0 - t) * minf(1.0, float(i) / 100.0)
			var value: float = _wave(kind, phase) * env * vol
			bytes.encode_s16(idx * 2, int(clampf(value, -1.0, 1.0) * 32767.0))
			idx += 1
	return _wav(bytes, RATE, false)


func _wave(kind: int, phase: float) -> float:
	match kind:
		1:
			return 1.0 if sin(phase) >= 0.0 else -1.0
		2:
			return randf_range(-1.0, 1.0)
		_:
			return sin(phase)


func _make_music() -> AudioStreamWAV:
	var total: int = MUSIC_RATE * BASS.size()
	var bytes := PackedByteArray()
	bytes.resize(total * 2)
	for i in total:
		var t: float = float(i) / float(MUSIC_RATE)
		var note_t: float = fmod(t, 1.0)
		var bass_edge: float = minf(1.0, minf(note_t * 80.0, (1.0 - note_t) * 80.0))
		var bass: float = sin(TAU * BASS[int(t) % BASS.size()] * t) * exp(-3.0 * note_t) * bass_edge * 0.5
		var arp_t: float = fmod(t * 2.0, 1.0)
		var arp_edge: float = minf(1.0, minf(arp_t * 80.0, (1.0 - arp_t) * 80.0))
		var arp: float = sin(TAU * ARP[int(t * 2.0) % ARP.size()] * t) * exp(-5.0 * arp_t) * arp_edge * 0.18
		bytes.encode_s16(i * 2, int(clampf(bass + arp, -1.0, 1.0) * 32767.0 * 0.6))
	return _wav(bytes, MUSIC_RATE, true)


func _wav(bytes: PackedByteArray, rate: int, loop: bool) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.stereo = false
	wav.data = bytes
	if loop:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = int(bytes.size() / 2.0)
	return wav


func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) != -1:
		return
	AudioServer.add_bus()
	var idx: int = AudioServer.bus_count - 1
	AudioServer.set_bus_name(idx, bus_name)
	AudioServer.set_bus_send(idx, "Master")


func _apply_settings() -> void:
	_set_bus("SFX", float(SaveManager.settings.get("sfx", 0.8)))
	_set_bus("Music", float(SaveManager.settings.get("music", 0.6)))


func _set_bus(bus_name: String, linear: float) -> void:
	var idx: int = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_mute(idx, linear <= 0.001)
	AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(linear, 0.001)))
