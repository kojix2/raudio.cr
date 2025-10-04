require "../src/raudio"

# Music streaming example
# This demonstrates how to play music files with streaming

Raudio::AudioDevice.init

begin
  music = Raudio::Music.load("resources/music.mp3")

  puts "Music loaded"
  puts "Length: #{music.length} seconds"

  # Set volume to 80%
  music.volume = 0.8

  # Start playing
  music.play
  puts "Playing music... (press Ctrl+C to stop)"

  # Update loop - must be called regularly when playing music
  loop do
    music.update

    # Print current position every second
    if music.time_played.to_i % 1 == 0
      puts "Time: #{music.time_played.round(2)} / #{music.length.round(2)}"
      sleep 1.second
    end

    break unless music.playing?
    sleep 10.milliseconds
  end

  puts "Music finished"
rescue ex : Raudio::AudioDeviceError
  puts "Error: #{ex.message}"
  puts "Make sure you have a music file at examples/resources/music.mp3"
ensure
  Raudio::AudioDevice.close
end
