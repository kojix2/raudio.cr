require "./lib_raudio"

module Raudio
  # Music represents a streaming audio source
  # Use this for long audio tracks (background music, etc.)
  # Music is streamed in chunks to save memory
  class Music
    getter? released

    private def initialize(@handle : LibRaudio::Music)
      @released = false
    end

    # Load music stream from file
    # Supported formats: WAV, OGG, MP3, FLAC, XM, MOD, QOA
    def self.load(filename : String | Path) : self
      handle = LibRaudio.load_music_stream(filename.to_s)
      raise MusicLoadError.new("Failed to load music", filename.to_s) unless ready?(handle)
      new(handle)
    end

    # Load music stream from memory data
    def self.from_memory(file_type : String, data : Bytes) : self
      handle = LibRaudio.load_music_stream_from_memory(file_type, data, data.size)
      raise MusicLoadError.new("Failed to load music from memory") unless ready?(handle)
      new(handle)
    end

    # Check if music stream is ready
    def self.ready?(handle : LibRaudio::Music) : Bool
      LibRaudio.is_music_ready(handle)
    end

    # Check if this music is ready
    def ready? : Bool
      self.class.ready?(@handle)
    end

    # Start music playing
    def play
      raise ReleasedError.new if released?
      LibRaudio.play_music_stream(@handle)
    end

    # Check if music is playing
    def playing? : Bool
      raise ReleasedError.new if released?
      LibRaudio.is_music_stream_playing(@handle)
    end

    # Update music buffer with new stream data
    # Call this regularly (every frame) when playing music
    def update
      raise ReleasedError.new if released?
      LibRaudio.update_music_stream(@handle)
    end

    # Stop music playing
    def stop
      raise ReleasedError.new if released?
      LibRaudio.stop_music_stream(@handle)
    end

    # Pause music playing
    def pause
      raise ReleasedError.new if released?
      LibRaudio.pause_music_stream(@handle)
    end

    # Resume paused music playing
    def resume
      raise ReleasedError.new if released?
      LibRaudio.resume_music_stream(@handle)
    end

    # Set volume for music (1.0 is max level)
    def volume=(volume : Float32)
      raise ReleasedError.new if released?
      LibRaudio.set_music_volume(@handle, volume)
    end

    # Set pitch for music (1.0 is base level)
    def pitch=(pitch : Float32)
      raise ReleasedError.new if released?
      LibRaudio.set_music_pitch(@handle, pitch)
    end

    # Set pan for music (0.5 is center)
    def pan=(pan : Float32)
      raise ReleasedError.new if released?
      LibRaudio.set_music_pan(@handle, pan)
    end

    # Get music time length in seconds
    def length : Float32
      raise ReleasedError.new if released?
      LibRaudio.get_music_time_length(@handle)
    end

    # Get current music time played in seconds
    def time_played : Float32
      raise ReleasedError.new if released?
      LibRaudio.get_music_time_played(@handle)
    end

    # Loop flag (default true in raudio)
    def looping? : Bool
      @handle.looping
    end

    # Enable/disable looping (set false to stop at end)
    def looping=(value : Bool)
      @handle.looping = value
    end

    # Seek music to a position in seconds
    def seek(position : Float32)
      raise ReleasedError.new if released?
      LibRaudio.seek_music_stream(@handle, position)
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

    # Get music context type
    def context_type : Int32
      @handle.ctx_type
    end

    def release
      return if @released
      LibRaudio.unload_music_stream(@handle)
      @released = true
    end

    def close
      release
    end

    def finalize
      release
    end

    # Get the underlying C struct
    def to_unsafe
      @handle
    end

    def self.load(filename : String | Path, &block)
      music = load(filename)
      begin
        yield music
      ensure
        music.release
      end
    end
  end
end
