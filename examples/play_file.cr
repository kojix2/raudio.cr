#!/usr/bin/env crystal
# Play an audio file from the command line

require "../src/raudio"

abort "Usage: #{PROGRAM_NAME} <audio-file>" if ARGV.empty?

source_path = File.expand_path(ARGV.first)

Raudio::AudioDevice.init

Signal::INT.trap do
  STDERR.puts "\nStopping..."
  Raudio::AudioDevice.close
  exit
end

begin
  music = Raudio::Music.load(source_path)
  music.looping = false

  puts "Playing #{source_path}"
  puts "Length: #{music.length.round(2)} seconds"

  music.play

  last_sec = -1
  while music.playing?
    music.update
    current = music.time_played
    sec = current.to_i
    if sec != last_sec
      puts "Time: #{current.round(2)} / #{music.length.round(2)}"
      last_sec = sec
    end
    sleep 10.milliseconds
  end

  puts "Done"
  music.release
rescue ex : Raudio::MusicLoadError
  STDERR.puts "Failed to load music: #{ex.message}"
  STDERR.puts "Supported formats: WAV, OGG, MP3, FLAC, XM, MOD, QOA"
ensure
  Raudio::AudioDevice.close
end
