require "../src/raudio"

# Simple sound playback example
# Demonstrates basic sound loading and playback with automatic cleanup

Raudio::AudioDevice.open do
  puts "Audio device initialized"
  puts "Master volume: #{Raudio::AudioDevice.master_volume}"

  # Set master volume to 50%
  Raudio::AudioDevice.master_volume = 0.5

  # Load and play a sound with automatic cleanup
  begin
    Raudio::Sound.load(
      [File.expand_path("../ext/raudio/examples/resources/target.ogg", __DIR__),
       File.expand_path("../ext/raudio/examples/resources/weird.wav", __DIR__)].sample
    ) do |sound|
      puts "Playing sound..."
      sound.play

      # Wait while sound is playing
      while sound.playing?
        sleep 10.milliseconds
      end

      puts "Sound finished"
    end
  rescue ex : Raudio::SoundLoadError
    puts "Error: #{ex.message}"
  end
end

puts "Audio device closed"
