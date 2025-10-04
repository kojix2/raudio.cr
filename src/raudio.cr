require "./raudio/lib_raudio"
require "./raudio/errors"
require "./raudio/audio_device"
require "./raudio/wave"
require "./raudio/sound"
require "./raudio/music"
require "./raudio/audio_stream"

module Raudio
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}
end
