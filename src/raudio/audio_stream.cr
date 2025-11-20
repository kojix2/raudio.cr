require "./lib_raudio"

module Raudio
  # AudioStream represents a custom audio stream
  # Use this for procedural audio or custom audio processing
  class AudioStream
    getter? released : Bool

    @processors : Array(Proc(Pointer(Void), UInt32, Nil))
    @stream_callback : Proc(Pointer(Void), UInt32, Nil)?

    # Global mixed processors retained to avoid GC
    # NOTE: This array is mutated from class methods and thus shared
    # across all threads. Protect it with a Mutex to avoid data races
    # when using -Dpreview_mt / ExecutionContext::Parallel.
    @@mixed_processors_mutex = Mutex.new
    @@mixed_processors = [] of Proc(Pointer(Void), UInt32, Nil)

    # NOOP callback retained to avoid GC (used when clearing callbacks)
    NOOP_CALLBACK = ->(buffer : Pointer(Void), frames : UInt32) { }
    @@noop_retained : Proc(Pointer(Void), UInt32, Nil) = NOOP_CALLBACK # Ensure it's never GC'd

    private def initialize(@handle : LibRaudio::AudioStream)
      @released = false
      @processors = [] of Proc(Pointer(Void), UInt32, Nil)
      @stream_callback = nil
    end

    # Load audio stream (to stream raw audio pcm data)
    def self.load(sample_rate : UInt32, sample_size : UInt32, channels : UInt32) : self
      handle = LibRaudio.load_audio_stream(sample_rate, sample_size, channels)
      raise AudioStreamError.new("Failed to load audio stream") unless ready?(handle)
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
      raise ReleasedError.new if released?
      LibRaudio.update_audio_stream(@handle, data, frame_count)
    end

    # Check if any audio stream buffers requires refill
    def processed? : Bool
      raise ReleasedError.new if released?
      LibRaudio.is_audio_stream_processed(@handle)
    end

    # Play audio stream
    def play
      raise ReleasedError.new if released?
      LibRaudio.play_audio_stream(@handle)
    end

    # Pause audio stream
    def pause
      raise ReleasedError.new if released?
      LibRaudio.pause_audio_stream(@handle)
    end

    # Resume audio stream
    def resume
      raise ReleasedError.new if released?
      LibRaudio.resume_audio_stream(@handle)
    end

    # Check if audio stream is playing
    def playing? : Bool
      raise ReleasedError.new if released?
      LibRaudio.is_audio_stream_playing(@handle)
    end

    # Stop audio stream
    def stop
      raise ReleasedError.new if released?
      LibRaudio.stop_audio_stream(@handle)
    end

    # Set volume for audio stream (1.0 is max level)
    def volume=(volume : Float32)
      raise ReleasedError.new if released?
      LibRaudio.set_audio_stream_volume(@handle, volume)
    end

    # Set pitch for audio stream (1.0 is base level)
    def pitch=(pitch : Float32)
      raise ReleasedError.new if released?
      LibRaudio.set_audio_stream_pitch(@handle, pitch)
    end

    # Set pan for audio stream (0.5 is center)
    def pan=(pan : Float32)
      raise ReleasedError.new if released?
      LibRaudio.set_audio_stream_pan(@handle, pan)
    end

    # Default size for new audio streams
    def self.buffer_size_default=(size : Int32)
      LibRaudio.set_audio_stream_buffer_size_default(size)
    end

    # Attach audio stream processor to stream
    def attach_processor(processor : LibRaudio::AudioCallback)
      raise ReleasedError.new if released?
      LibRaudio.attach_audio_stream_processor(@handle, processor)
      @processors << processor unless @processors.includes?(processor)
    end

    # Attach audio stream processor to stream (block form)
    def attach_processor(&block : Pointer(Void), UInt32 ->)
      attach_processor(block)
    end

    # Detach audio stream processor from stream
    def detach_processor(processor : LibRaudio::AudioCallback)
      raise ReleasedError.new if released?
      LibRaudio.detach_audio_stream_processor(@handle, processor)
      @processors.delete(processor)
    end

    # Set per-stream callback (single). Overwrites previous.
    def callback=(cb : LibRaudio::AudioCallback)
      raise ReleasedError.new if released?
      @stream_callback = cb
      LibRaudio.set_audio_stream_callback(@handle, cb)
    end

    # Set per-stream callback (block form). Overwrites previous.
    def set_callback(&block : Pointer(Void), UInt32 ->)
      self.callback = block
    end

    def clear_callback
      raise ReleasedError.new if released?
      @stream_callback = nil
      LibRaudio.set_audio_stream_callback(@handle, NOOP_CALLBACK)
    end

    # Attach audio stream processor to the entire audio pipeline
    def self.attach_mixed_processor(processor : LibRaudio::AudioCallback)
      @@mixed_processors_mutex.synchronize do
        LibRaudio.attach_audio_mixed_processor(processor)
        @@mixed_processors << processor unless @@mixed_processors.includes?(processor)
      end
    end

    # Attach audio stream processor to the entire audio pipeline (block form)
    def self.attach_mixed_processor(&block : Pointer(Void), UInt32 ->)
      attach_mixed_processor(block)
    end

    # Detach audio stream processor from the entire audio pipeline
    def self.detach_mixed_processor(processor : LibRaudio::AudioCallback)
      @@mixed_processors_mutex.synchronize do
        LibRaudio.detach_audio_mixed_processor(processor)
        @@mixed_processors.delete(processor)
      end
    end

    # Get sample rate
    def sample_rate : UInt32
      @handle.sample_rate
    end

    # Get sample size
    def sample_size : UInt32
      @handle.sample_size
    end

    # Get number of channels
    def channels : UInt32
      @handle.channels
    end

    def release
      return if @released
      # Detach retained callbacks so C side stops referencing them
      @processors.each do |p|
        LibRaudio.detach_audio_stream_processor(@handle, p)
      end
      if cb = @stream_callback
        LibRaudio.set_audio_stream_callback(@handle, NOOP_CALLBACK)
        @stream_callback = nil
      end
      LibRaudio.unload_audio_stream(@handle)
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
  end
end
