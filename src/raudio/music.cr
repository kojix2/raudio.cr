require "./lib_raudio"

module Raudio
  # Music represents a streaming audio source
  # Use this for long audio tracks (background music, etc.)
  # Music is streamed in chunks to save memory
  class Music
    def initialize(@handle : LibRaudio::Music)
    end

    # Load music stream from file
    # Supported formats: WAV, OGG, MP3, FLAC, XM, MOD, QOA
    def self.load(filename : String) : self
      handle = LibRaudio.load_music_stream(filename)
      raise AudioDeviceError.new("Failed to load music: #{filename}") unless ready?(handle)
      new(handle)
    end

    # Load music stream from memory data
    def self.from_memory(file_type : String, data : Bytes) : self
      handle = LibRaudio.load_music_stream_from_memory(file_type, data, data.size)
      raise AudioDeviceError.new("Failed to load music from memory") unless ready?(handle)
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
      LibRaudio.play_music_stream(@handle)
    end

    # Check if music is playing
    def playing? : Bool
      LibRaudio.is_music_stream_playing(@handle)
    end

    # Update music buffer with new stream data
    # Call this regularly (every frame) when playing music
    def update
      LibRaudio.update_music_stream(@handle)
    end

    # Stop music playing
    def stop
      LibRaudio.stop_music_stream(@handle)
    end

    # Pause music playing
    def pause
      LibRaudio.pause_music_stream(@handle)
    end

    # Resume paused music playing
    def resume
      LibRaudio.resume_music_stream(@handle)
    end

    # Set volume for music (1.0 is max level)
    def volume=(volume : Float32)
      LibRaudio.set_music_volume(@handle, volume)
    end

    # Set pitch for music (1.0 is base level)
    def pitch=(pitch : Float32)
      LibRaudio.set_music_pitch(@handle, pitch)
    end

    # Set pan for music (0.5 is center)
    def pan=(pan : Float32)
      LibRaudio.set_music_pan(@handle, pan)
    end

    # Get music time length in seconds
    def length : Float32
      LibRaudio.get_music_time_length(@handle)
    end

    # Get current music time played in seconds
    def time_played : Float32
      LibRaudio.get_music_time_played(@handle)
    end

    # Seek music to a position in seconds
    def seek(position : Float32)
      LibRaudio.seek_music_stream(@handle, position)
    end

    # Clean up resources
    def finalize
      LibRaudio.unload_music_stream(@handle)
    end

    # Get the underlying C struct
    def to_unsafe
      @handle
    end

    # Load music with automatic cleanup
    #
    # Example:
    # ```
    # Music.load("bgm.mp3") do |music|
    #   music.play
    #   loop do
    #     music.update
    #     break unless music.playing?
    #     sleep 0.01
    #   end
    # end
    # ```
    def self.load(filename : String, &block)
      music = load(filename)
      begin
        yield music
      ensure
        music.finalize
      end
    end
  end
end
