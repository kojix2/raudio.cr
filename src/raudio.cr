require "./raudio/lib_raudio"

module Raudio
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}
end
