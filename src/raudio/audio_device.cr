require "./lib_raudio"

module Raudio
  # Audio device management (singleton pattern)
  # Handles initialization and cleanup of the audio device
  #
  # Note: AudioDevice lifetime operations are synchronized for use from
  # multiple fibers/threads. Individual audio resources should still be
  # owned and updated from a dedicated audio/game context.
  class AudioDevice
    @@mutex = Mutex.new
    @@initialized = false
    @@open_count = 0
    @@at_exit_registered = false

    # Initialize the audio device
    # This is automatically called when using the block form
    # Thread-safe: Can be safely called from any thread
    def self.init : Nil
      @@mutex.synchronize do
        return if @@initialized
        LibRaudio.init_audio_device
        @@initialized = true
      end
      register_at_exit
    end

    # Close the audio device
    # This is automatically called at program exit if init was called
    # Thread-safe: Can be safely called from any thread
    def self.close : Nil
      @@mutex.synchronize do
        return unless @@initialized
        return if @@open_count > 0
        LibRaudio.close_audio_device
        @@initialized = false
        @@open_count = 0
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
      acquire
      begin
        yield
      ensure
        release_open
      end
    end

    private def self.acquire : Nil
      @@mutex.synchronize do
        unless @@initialized
          LibRaudio.init_audio_device
          @@initialized = true
        end
        @@open_count += 1
      end
      register_at_exit
    end

    private def self.register_at_exit : Nil
      @@mutex.synchronize do
        return if @@at_exit_registered
        @@at_exit_registered = true
      end

      at_exit { close }
    end

    private def self.release_open : Nil
      @@mutex.synchronize do
        return if @@open_count <= 0
        @@open_count -= 1
        return unless @@open_count == 0 && @@initialized
        LibRaudio.close_audio_device
        @@initialized = false
      end
    end
  end
end
