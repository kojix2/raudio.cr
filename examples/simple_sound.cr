require "../src/raudio"

# Simple sound playback example with embedded audio data

EMBED_TARGET_OGG = {{ read_file("ext/raudio/examples/resources/target.ogg") }}
EMBED_WEIRD_WAV  = {{ read_file("ext/raudio/examples/resources/weird.wav") }}

Raudio::AudioDevice.open do
  Raudio::AudioDevice.master_volume = 0.5

  data, file_type = rand < 0.5 ? {EMBED_TARGET_OGG, ".ogg"} : {EMBED_WEIRD_WAV, ".wav"}

  wave = Raudio::Wave.load_from_memory(file_type, data.to_slice)
  sound = Raudio::Sound.from_wave(wave)
  wave.release

  sound.play

  while sound.playing?
    sleep 10.milliseconds
  end

  sound.release
end
