module Raudio
  {% if flag?(:msvc) %}
    @[Link("raudio", ldflags: "/LIBPATH:#{__DIR__}\\..\\..\\ext")]
  {% else %}
    @[Link("raudio", ldflags: "-L#{__DIR__}/../../ext")]
  {% end %}
  lib LibRaudio
    # Type alias for AudioCallback
    alias AudioCallback = Proc(Pointer(Void), UInt32, Void)

    # Wave, audio wave data
    struct Wave
      frame_count : UInt32 # Total number of frames (considering channels)
      sample_rate : UInt32 # Frequency (samples per second)
      sample_size : UInt32 # Bit depth (bits per sample): 8, 16, 32 (24 not supported)
      channels : UInt32    # Number of channels (1-mono, 2-stereo, ...)
      data : Pointer(Void) # Buffer data pointer
    end

    # Opaque structs
    type RAudioBuffer = Void*
    type RAudioProcessor = Void*

    # AudioStream, custom audio stream
    struct AudioStream
      buffer : RAudioBuffer       # Pointer to internal data used by the audio system
      processor : RAudioProcessor # Pointer to internal data processor, useful for audio effects
      sample_rate : UInt32        # Frequency (samples per second)
      sample_size : UInt32        # Bit depth (bits per sample): 8, 16, 32 (24 not supported)
      channels : UInt32           # Number of channels (1-mono, 2-stereo, ...)
    end

    # Sound
    struct Sound
      stream : AudioStream # Audio stream
      frame_count : UInt32 # Total number of frames (considering channels)
    end

    # Music, audio stream, anything longer than ~10 seconds should be streamed
    struct Music
      stream : AudioStream     # Audio stream
      frame_count : UInt32     # Total number of frames (considering channels)
      looping : Bool           # Music looping enable
      ctx_type : Int32         # Type of music context (audio filetype)
      ctx_data : Pointer(Void) # Audio context data, depends on type
    end

    # Audio device management functions
    fun init_audio_device = InitAudioDevice : Void
    fun close_audio_device = CloseAudioDevice : Void
    fun is_audio_device_ready = IsAudioDeviceReady : Bool
    fun set_master_volume = SetMasterVolume(volume : Float32) : Void
    fun get_master_volume = GetMasterVolume : Float32

    # Wave/Sound loading/unloading functions
    fun load_wave = LoadWave(file_name : UInt8*) : Wave
    fun load_wave_from_memory = LoadWaveFromMemory(file_type : UInt8*, file_data : UInt8*, data_size : Int32) : Wave
    fun is_wave_ready = IsWaveReady(wave : Wave) : Bool
    fun load_sound = LoadSound(file_name : UInt8*) : Sound
    fun load_sound_from_wave = LoadSoundFromWave(wave : Wave) : Sound
    fun load_sound_alias = LoadSoundAlias(source : Sound) : Sound
    fun is_sound_ready = IsSoundReady(sound : Sound) : Bool
    fun update_sound = UpdateSound(sound : Sound, data : Pointer(Void), frame_count : Int32) : Void
    fun unload_wave = UnloadWave(wave : Wave) : Void
    fun unload_sound = UnloadSound(sound : Sound) : Void
    fun unload_sound_alias = UnloadSoundAlias(alias : Sound) : Void
    fun export_wave = ExportWave(wave : Wave, file_name : UInt8*) : Bool
    fun export_wave_as_code = ExportWaveAsCode(wave : Wave, file_name : UInt8*) : Bool

    # Wave/Sound management functions
    fun play_sound = PlaySound(sound : Sound) : Void
    fun stop_sound = StopSound(sound : Sound) : Void
    fun pause_sound = PauseSound(sound : Sound) : Void
    fun resume_sound = ResumeSound(sound : Sound) : Void
    fun is_sound_playing = IsSoundPlaying(sound : Sound) : Bool
    fun set_sound_volume = SetSoundVolume(sound : Sound, volume : Float32) : Void
    fun set_sound_pitch = SetSoundPitch(sound : Sound, pitch : Float32) : Void
    fun set_sound_pan = SetSoundPan(sound : Sound, pan : Float32) : Void
    fun wave_copy = WaveCopy(wave : Wave) : Wave
    fun wave_crop = WaveCrop(wave : Wave*, init_sample : Int32, final_sample : Int32) : Void
    fun wave_format = WaveFormat(wave : Wave*, sample_rate : Int32, sample_size : Int32, channels : Int32) : Void
    fun load_wave_samples = LoadWaveSamples(wave : Wave) : Float32*
    fun unload_wave_samples = UnloadWaveSamples(samples : Float32*) : Void

    # Music management functions
    fun load_music_stream = LoadMusicStream(file_name : UInt8*) : Music
    fun load_music_stream_from_memory = LoadMusicStreamFromMemory(file_type : UInt8*, data : UInt8*, data_size : Int32) : Music
    fun is_music_ready = IsMusicReady(music : Music) : Bool
    fun unload_music_stream = UnloadMusicStream(music : Music) : Void
    fun play_music_stream = PlayMusicStream(music : Music) : Void
    fun is_music_stream_playing = IsMusicStreamPlaying(music : Music) : Bool
    fun update_music_stream = UpdateMusicStream(music : Music) : Void
    fun stop_music_stream = StopMusicStream(music : Music) : Void
    fun pause_music_stream = PauseMusicStream(music : Music) : Void
    fun resume_music_stream = ResumeMusicStream(music : Music) : Void
    fun seek_music_stream = SeekMusicStream(music : Music, position : Float32) : Void
    fun set_music_volume = SetMusicVolume(music : Music, volume : Float32) : Void
    fun set_music_pitch = SetMusicPitch(music : Music, pitch : Float32) : Void
    fun set_music_pan = SetMusicPan(music : Music, pan : Float32) : Void
    fun get_music_time_length = GetMusicTimeLength(music : Music) : Float32
    fun get_music_time_played = GetMusicTimePlayed(music : Music) : Float32

    # AudioStream management functions
    fun load_audio_stream = LoadAudioStream(sample_rate : UInt32, sample_size : UInt32, channels : UInt32) : AudioStream
    fun is_audio_stream_ready = IsAudioStreamReady(stream : AudioStream) : Bool
    fun unload_audio_stream = UnloadAudioStream(stream : AudioStream) : Void
    fun update_audio_stream = UpdateAudioStream(stream : AudioStream, data : Pointer(Void), samples_count : Int32) : Void
    fun is_audio_stream_processed = IsAudioStreamProcessed(stream : AudioStream) : Bool
    fun play_audio_stream = PlayAudioStream(stream : AudioStream) : Void
    fun pause_audio_stream = PauseAudioStream(stream : AudioStream) : Void
    fun resume_audio_stream = ResumeAudioStream(stream : AudioStream) : Void
    fun is_audio_stream_playing = IsAudioStreamPlaying(stream : AudioStream) : Bool
    fun stop_audio_stream = StopAudioStream(stream : AudioStream) : Void
    fun set_audio_stream_volume = SetAudioStreamVolume(stream : AudioStream, volume : Float32) : Void
    fun set_audio_stream_pitch = SetAudioStreamPitch(stream : AudioStream, pitch : Float32) : Void
    fun set_audio_stream_pan = SetAudioStreamPan(stream : AudioStream, pan : Float32) : Void
    fun set_audio_stream_buffer_size_default = SetAudioStreamBufferSizeDefault(size : Int32) : Void
    fun set_audio_stream_callback = SetAudioStreamCallback(stream : AudioStream, callback : AudioCallback) : Void

    fun attach_audio_stream_processor = AttachAudioStreamProcessor(stream : AudioStream, processor : AudioCallback) : Void
    fun detach_audio_stream_processor = DetachAudioStreamProcessor(stream : AudioStream, processor : AudioCallback) : Void

    fun attach_audio_mixed_processor = AttachAudioMixedProcessor(processor : AudioCallback) : Void
    fun detach_audio_mixed_processor = DetachAudioMixedProcessor(processor : AudioCallback) : Void
  end
end
