require "./lib_raudio"

module Raudio
  # Audio device management (singleton pattern)
  # Handles initialization and cleanup of the audio device
  class AudioDevice
    @@initialized = false

    # Initialize the audio device
    # This is automatically called when using the block form
    def self.init
      return if @@initialized
      LibRaudio.init_audio_device
      @@initialized = true
      at_exit { close }
    end

    # Close the audio device
    # This is automatically called at program exit if init was called
    def self.close
      return unless @@initialized
      LibRaudio.close_audio_device
      @@initialized = false
    end

    # Check if audio device is ready
    def self.ready? : Bool
      LibRaudio.is_audio_device_ready
    end

    # Set master volume (listener)
    def self.master_volume=(volume : Float32)
      LibRaudio.set_master_volume(volume)
    end

    # Get master volume (listener)
    def self.master_volume : Float32
      LibRaudio.get_master_volume
    end

    # Open audio device with automatic cleanup
    # This is the recommended way to use the audio device
    #
    # Example:
    # ```
    # AudioDevice.open do
    #   # Use audio here
    # end
    # ```
    def self.open(&block)
      init
      begin
        yield
      ensure
        close
      end
    end
  end
end
