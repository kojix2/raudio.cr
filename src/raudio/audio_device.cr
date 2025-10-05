require "./lib_raudio"

module Raudio
  # Audio device management (singleton pattern)
  # Handles initialization and cleanup of the audio device
  #
  # Note: AudioDevice operations are thread-safe, but audio playback
  # operations (Sound, Music, AudioStream) should be performed from
  # a single dedicated thread.
  class AudioDevice
    @@mutex = Mutex.new
    @@initialized = false

    # Initialize the audio device
    # This is automatically called when using the block form
    # Thread-safe: Can be safely called from any thread
    def self.init : Nil
      @@mutex.synchronize do
        return if @@initialized
        LibRaudio.init_audio_device
        @@initialized = true
      end
      at_exit { close }
    end

    # Close the audio device
    # This is automatically called at program exit if init was called
    # Thread-safe: Can be safely called from any thread
    def self.close : Nil
      @@mutex.synchronize do
        return unless @@initialized
        LibRaudio.close_audio_device
        @@initialized = false
      end
    end

    # Check if audio device is ready
    # Thread-safe: Can be safely called from any thread
    def self.ready? : Bool
      @@mutex.synchronize do
        LibRaudio.is_audio_device_ready
      end
    end

    # Set master volume (listener)
    # Thread-safe: Can be safely called from any thread
    def self.master_volume=(volume : Float32) : Nil
      @@mutex.synchronize do
        LibRaudio.set_master_volume(volume)
      end
    end

    # Get master volume (listener)
    # Thread-safe: Can be safely called from any thread
    def self.master_volume : Float32
      @@mutex.synchronize do
        LibRaudio.get_master_volume
      end
    end

    # Open audio device with automatic cleanup
    # This is the recommended way to use the audio device
    # Thread-safe: Can be safely called from any thread
    #
    # Example:
    # ```
    # AudioDevice.open do
    #   # Use audio here
    # end
    # ```
    def self.open(&)
      init
      begin
        yield
      ensure
        close
      end
    end
  end
end
