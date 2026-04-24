class_name SoundController

const SOUND_SAMPLE_RATE: float = 44100.0
const SOUND_BUFFER_LENGTH: float = 0.2
const SOUND_DURATION_SEC: float = 0.03
const SOUND_VOLUME: float = 0.12

var sound_stream: AudioStreamGenerator
var sound_playback: AudioStreamGeneratorPlayback
var sound_phase: float = 0.0
var audio_stream_player: AudioStreamPlayer

func setup(player: AudioStreamPlayer) -> void:
	audio_stream_player = player
	_setup_sound_stream()

func play_sound(selected_index: int, sort_values: Array[SortBar], element_count: int, volume_scale: float) -> void:
	if selected_index < 0 or selected_index >= sort_values.size():
		return
	if sound_playback == null:
		_setup_sound_stream()
		if sound_playback == null:
			return

	var v: int = sort_values[selected_index].get_value()
	var min_hz: float = 220.0
	var max_hz: float = 880.0
	var t: float = float(v - 1) / float(max(1, element_count - 1))
	var frequency: float = lerpf(min_hz, max_hz, t)
	var frame_count: int = int(SOUND_SAMPLE_RATE * SOUND_DURATION_SEC)
	var fade_frames: int = int(frame_count * 0.2)
	if sound_playback.get_frames_available() < frame_count:
		return

	for i in range(frame_count):
		var envelope: float = 1.0
		if fade_frames > 0 and i < fade_frames:
			envelope = float(i) / float(fade_frames)
		elif fade_frames > 0 and i >= frame_count - fade_frames:
			envelope = float(frame_count - i - 1) / float(fade_frames)

		var sample: float = sin(sound_phase) * SOUND_VOLUME * volume_scale * max(envelope, 0.0)
		sound_playback.push_frame(Vector2(sample, sample))
		sound_phase += TAU * frequency / SOUND_SAMPLE_RATE
		if sound_phase >= TAU:
			sound_phase = fmod(sound_phase, TAU)

func _setup_sound_stream() -> void:
	if audio_stream_player == null:
		return
	sound_stream = AudioStreamGenerator.new()
	sound_stream.mix_rate = SOUND_SAMPLE_RATE
	sound_stream.buffer_length = SOUND_BUFFER_LENGTH
	audio_stream_player.stream = sound_stream
	audio_stream_player.play()
	sound_playback = audio_stream_player.get_stream_playback() as AudioStreamGeneratorPlayback
