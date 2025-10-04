require "./lib_raudio"

module Raudio
  # AudioStream represents a custom audio stream
  # Use this for procedural audio or custom audio processing
  class AudioStream
    def initialize(@handle : LibRaudio::AudioStream)
    end

    # Load audio stream (to stream raw audio pcm data)
    def self.load(sample_rate : UInt32, sample_size : UInt32, channels : UInt32) : self
      handle = LibRaudio.load_audio_stream(sample_rate, sample_size, channels)
      raise AudioDeviceError.new("Failed to load audio stream") unless ready?(handle)
      new(handle)
    end

    # Check if audio stream is ready
    def self.ready?(handle : LibRaudio::AudioStream) : Bool
      LibRaudio.is_audio_stream_ready(handle)
    end

    # Check if this audio stream is ready
    def ready? : Bool
      self.class.ready?(@handle)
    end

    # Update audio stream buffers with data
    def update(data : Pointer(Void), frame_count : Int32)
      LibRaudio.update_audio_stream(@handle, data, frame_count)
    end

    # Check if any audio stream buffers requires refill
    def processed? : Bool
      LibRaudio.is_audio_stream_processed(@handle)
    end

    # Play audio stream
    def play
      LibRaudio.play_audio_stream(@handle)
    end

    # Pause audio stream
    def pause
      LibRaudio.pause_audio_stream(@handle)
    end

    # Resume audio stream
    def resume
      LibRaudio.resume_audio_stream(@handle)
    end

    # Check if audio stream is playing
    def playing? : Bool
      LibRaudio.is_audio_stream_playing(@handle)
    end

    # Stop audio stream
    def stop
      LibRaudio.stop_audio_stream(@handle)
    end

    # Set volume for audio stream (1.0 is max level)
    def volume=(volume : Float32)
      LibRaudio.set_audio_stream_volume(@handle, volume)
    end

    # Set pitch for audio stream (1.0 is base level)
    def pitch=(pitch : Float32)
      LibRaudio.set_audio_stream_pitch(@handle, pitch)
    end

    # Set pan for audio stream (0.5 is center)
    def pan=(pan : Float32)
      LibRaudio.set_audio_stream_pan(@handle, pan)
    end

    # Default size for new audio streams
    def self.buffer_size_default=(size : Int32)
      LibRaudio.set_audio_stream_buffer_size_default(size)
    end

    # Attach audio stream processor to stream
    def attach_processor(processor : LibRaudio::AudioCallback)
      LibRaudio.attach_audio_stream_processor(@handle, processor)
    end

    # Detach audio stream processor from stream
    def detach_processor(processor : LibRaudio::AudioCallback)
      LibRaudio.detach_audio_stream_processor(@handle, processor)
    end

    # Attach audio stream processor to the entire audio pipeline
    def self.attach_mixed_processor(processor : LibRaudio::AudioCallback)
      LibRaudio.attach_audio_mixed_processor(processor)
    end

    # Detach audio stream processor from the entire audio pipeline
    def self.detach_mixed_processor(processor : LibRaudio::AudioCallback)
      LibRaudio.detach_audio_mixed_processor(processor)
    end

    # Clean up resources
    def finalize
      LibRaudio.unload_audio_stream(@handle)
    end

    # Get the underlying C struct
    def to_unsafe
      @handle
    end
  end
end
