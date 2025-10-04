require "../src/raudio"

# Simple example: Play a sound effect
# This demonstrates basic sound loading and playback

Raudio::AudioDevice.open do
  puts "Audio device initialized"
  puts "Master volume: #{Raudio::AudioDevice.master_volume}"

  # Set master volume to 50%
  Raudio::AudioDevice.master_volume = 0.5

  # Load and play a sound with automatic cleanup
  begin
    Raudio::Sound.load("resources/sound.wav") do |sound|
      puts "Playing sound..."
      sound.play

      # Wait while sound is playing
      while sound.playing?
        sleep 0.01
      end

      puts "Sound finished"
    end
  rescue ex : Raudio::AudioDeviceError
    puts "Error: #{ex.message}"
    puts "Make sure you have a sound file at examples/resources/sound.wav"
  end
end

puts "Audio device closed"
