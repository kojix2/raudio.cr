require "./lib_raudio"

module Raudio
  # Sound represents a short audio clip loaded in memory
  # Use this for sound effects and short audio samples
  class Sound
    getter? released : Bool

    private def initialize(@handle : LibRaudio::Sound, @alias : Bool = false)
      @released = false
    end

    # Load sound from file
    # Supported formats: WAV, OGG, MP3, FLAC, QOA
    def self.load(filename : String | Path) : self
      handle = LibRaudio.load_sound(filename.to_s)
      raise SoundLoadError.new("Failed to load sound", filename.to_s) unless ready?(handle)
      new(handle)
    end

    # Load sound from wave data
    def self.from_wave(wave : Wave) : self
      handle = LibRaudio.load_sound_from_wave(wave.to_unsafe)
      raise SoundLoadError.new("Failed to load sound from wave") unless ready?(handle)
      new(handle)
    end

    # Load sound alias (uses same sample data as original)
    def self.alias(source : Sound) : self
      handle = LibRaudio.load_sound_alias(source.to_unsafe)
      new(handle, true)
    end

    # Check if sound data is ready
    def self.ready?(handle : LibRaudio::Sound) : Bool
      LibRaudio.is_sound_ready(handle)
    end

    # Check if this sound is ready
    def ready? : Bool
      self.class.ready?(@handle)
    end

    # Update sound buffer with new data
    def update(data : Pointer(Void), sample_count : Int32)
      raise ReleasedError.new if released?
      LibRaudio.update_sound(@handle, data, sample_count)
    end

    # Play the sound
    def play
      raise ReleasedError.new if released?
      LibRaudio.play_sound(@handle)
    end

    # Stop the sound
    def stop
      raise ReleasedError.new if released?
      LibRaudio.stop_sound(@handle)
    end

    # Pause the sound
    def pause
      raise ReleasedError.new if released?
      LibRaudio.pause_sound(@handle)
    end

    # Resume the paused sound
    def resume
      raise ReleasedError.new if released?
      LibRaudio.resume_sound(@handle)
    end

    # Check if sound is currently playing
    def playing? : Bool
      raise ReleasedError.new if released?
      LibRaudio.is_sound_playing(@handle)
    end

    # Set volume for the sound (1.0 is max level)
    def volume=(volume : Float32)
      raise ReleasedError.new if released?
      LibRaudio.set_sound_volume(@handle, volume)
    end

    # Set pitch for the sound (1.0 is base level)
    def pitch=(pitch : Float32)
      raise ReleasedError.new if released?
      LibRaudio.set_sound_pitch(@handle, pitch)
    end

    # Set pan for the sound (0.5 is center)
    def pan=(pan : Float32)
      raise ReleasedError.new if released?
      LibRaudio.set_sound_pan(@handle, pan)
    end

    # Get frame count
    def frame_count : UInt32
      @handle.frame_count
    end

    # Get sample rate
    def sample_rate : UInt32
      @handle.stream.sample_rate
    end

    # Get sample size
    def sample_size : UInt32
      @handle.stream.sample_size
    end

    # Get number of channels
    def channels : UInt32
      @handle.stream.channels
    end

    def release
      return if @released
      if @alias
        LibRaudio.unload_sound_alias(@handle)
      else
        LibRaudio.unload_sound(@handle)
      end
      @released = true
    end

    def close
      release
    end

    def unload_alias
      return unless @alias
      release
    end

    # GC fallback
    def finalize
      release
    end

    # Get the underlying C struct
    def to_unsafe
      @handle
    end

    def self.load(filename : String | Path, &block)
      sound = load(filename)
      begin
        yield sound
      ensure
        sound.release
      end
    end
  end
end
