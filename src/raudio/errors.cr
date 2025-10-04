module Raudio
  # Base error
  class Error < Exception; end

  # Device related errors
  class AudioDeviceError < Error; end

  # Generic load error with optional path
  class LoadError < Error
    getter path

    def initialize(message = "Load error", @path : String? = nil)
      super(@path ? "#{message} (#{@path})" : message)
    end
  end

  class WaveLoadError < LoadError; end

  class SoundLoadError < LoadError; end

  class MusicLoadError < LoadError; end

  class AudioStreamError < Error; end

  # Operation attempted after release
  class ReleasedError < Error; end
end
