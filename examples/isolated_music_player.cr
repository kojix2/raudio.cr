require "../src/raudio"

# Requires: crystal run -Dpreview_mt -Dexecution_context examples/isolated_music_player.cr
#
# This pattern is useful for games using ExecutionContext::Parallel elsewhere:
# keep raudio resources owned by one isolated audio context and communicate with
# it from worker contexts using Channel/WaitGroup/etc.
music_path = ARGV[0]? || File.expand_path("../ext/raudio/examples/resources/country.mp3", __DIR__)

audio_ctx = Fiber::ExecutionContext::Isolated.new("audio") do
  Raudio::AudioDevice.open do
    Raudio::Music.load(music_path) do |music|
      music.looping = true
      music.play

      until music.time_played >= music.length
        music.update
        sleep 0.01.seconds
      end
    end
  end
end

audio_ctx.wait
