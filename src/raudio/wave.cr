require "./lib_raudio"

module Raudio
  # Wave represents raw audio data
  # Use this for loading and manipulating audio waveforms
  class Wave
    getter? released

    private def initialize(@handle : LibRaudio::Wave)
      @released = false
    end

    # Load wave data from file
    # Supported formats: WAV, OGG, MP3, FLAC, QOA
    def self.load(filename : String | Path) : self
      handle = LibRaudio.load_wave(filename.to_s)
      raise AudioDeviceError.new("Failed to load wave: #{filename}") unless ready?(handle)
      new(handle)
    end

    # Load wave from memory buffer
    def self.load_from_memory(file_type : String, data : Bytes) : self
      handle = LibRaudio.load_wave_from_memory(file_type, data, data.size)
      raise AudioDeviceError.new("Failed to load wave from memory") unless ready?(handle)
      new(handle)
    end

    # Check if wave data is ready
    def self.ready?(handle : LibRaudio::Wave) : Bool
      LibRaudio.is_wave_ready(handle)
    end

    # Check if this wave is ready
    def ready? : Bool
      self.class.ready?(@handle)
    end

    # Export wave data to file
    def export(filename : String) : Bool
      LibRaudio.export_wave(@handle, filename)
    end

    # Export wave data as code (.h)
    def export_as_code(filename : String) : Bool
      LibRaudio.export_wave_as_code(@handle, filename)
    end

    # Copy wave data
    def copy : Wave
      handle = LibRaudio.wave_copy(@handle)
      Wave.new(handle)
    end

    # Crop wave data to specified samples range
    def crop(init_sample : Int32, final_sample : Int32)
      LibRaudio.wave_crop(pointerof(@handle), init_sample, final_sample)
    end

    # Convert wave data to desired format
    def format(sample_rate : Int32, sample_size : Int32, channels : Int32)
      LibRaudio.wave_format(pointerof(@handle), sample_rate, sample_size, channels)
    end

    def release
      return if @released
      LibRaudio.unload_wave(@handle)
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
      wave = load(filename)
      begin
        yield wave
      ensure
        wave.release
      end
    end
  end
end
