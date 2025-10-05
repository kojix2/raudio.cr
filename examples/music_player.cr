require "../src/raudio"

# Music streaming example
# Demonstrates streaming playback for long audio files

Raudio::AudioDevice.init

begin
  music = Raudio::Music.load(
    File.expand_path("../ext/raudio/examples/resources/country.mp3", __DIR__)
  )

  puts "Music loaded"
  puts "Length: #{music.length} seconds"

  # Configure playback
  music.volume = 0.8
  music.looping = false

  # Start playing
  music.play
  puts "Playing music... (press Ctrl+C to stop)"

  # Update loop - required for streaming
  sec = 0
  loop do
    music.update

    # Print progress every second
    if (s = music.time_played.to_i) > sec
      puts "Time: #{music.time_played.round(2)} / #{music.length.round(2)}"
      sec = s
    end

    break unless music.playing?
    sleep 10.milliseconds
  end

  puts "Music finished"
rescue ex : Raudio::MusicLoadError
  puts "Error: #{ex.message}"
ensure
  Raudio::AudioDevice.close
end
