# raudio.cr

:sound: [raudio](https://github.com/raysan5/raudio) - a simple audio library based on miniaudio - for Crystal

## Installation

Add to `shard.yml`:

```yaml
dependencies:
  raudio:
    github: kojix2/raudio.cr
```

Run `shards install`. The native library builds automatically.

## Usage

### Audio device

```crystal
require "raudio"

Raudio::AudioDevice.open do
  Raudio::AudioDevice.master_volume = 0.8
end
```

### Sound playback

```crystal
Raudio::AudioDevice.open do
  sound = Raudio::Sound.load("effect.wav")
  sound.volume = 0.5
  sound.play

  while sound.playing?
    sleep 10.milliseconds
  end
end
```

### Music streaming

```crystal
Raudio::AudioDevice.init

music = Raudio::Music.load("background.mp3")
music.volume = 0.8
music.looping = false  # Disable looping (enabled by default)
music.play

loop do
  music.update
  break unless music.playing?
  sleep 10.milliseconds
end

Raudio::AudioDevice.close
```

### Wave data

```crystal
Raudio::AudioDevice.open do
  wave = Raudio::Wave.load("audio.wav")
  sound = Raudio::Sound.from_wave(wave)
  sound.play
  wave.export("output.wav")
end
```

## Resource Management

Resources should be explicitly released when done, or use the block form for automatic cleanup.

### Recommended patterns:

```crystal
# Block form (automatic cleanup)
Raudio::Sound.load("effect.wav") do |sound|
  sound.play
end

# Manual release
sound = Raudio::Sound.load("effect.wav")
begin
  sound.play
ensure
  sound.release  # or sound.close
end
```

Finalizers are provided as a fallback but explicit cleanup is recommended.

## Supported formats

WAV, OGG, MP3, FLAC, QOA

## API

- `Raudio::AudioDevice` - audio device management
- `Raudio::Sound` - short audio clips
- `Raudio::Music` - streaming audio
- `Raudio::Wave` - raw waveform data
- `Raudio::AudioStream` - custom streaming

Low-level C bindings: `Raudio::LibRaudio`

## Development

```bash
make -C ext        # build native library
crystal spec       # run tests
```

## License

MIT

Dependencies (bundled single-header/native libraries):

- [raudio](https://github.com/raysan5/raudio) (C library) – zlib
  - [miniaudio](https://github.com/mackron/miniaudio) – Public Domain or MIT-0
  - [dr_wav](https://github.com/mackron/dr_libs) – Public Domain or MIT-0
  - [dr_mp3](https://github.com/mackron/dr_libs) – Public Domain or MIT-0
  - [dr_flac](https://github.com/mackron/dr_libs) – Public Domain or MIT-0
  - [stb_vorbis](https://github.com/nothings/stb) – Public Domain or MIT
  - [qoa](https://github.com/phoboslab/qoa) – MIT
  - [jar_xm](https://github.com/kd7tck/jar) – WTFPL v2 – (included in source)
  - [jar_mod](https://github.com/kd7tck/jar) – Public Domain (CC0 1.0) – (included in source)

Summary: Project code is MIT, bundled raudio is zlib, and all other bundled dependencies are permissive (Public Domain/Unlicense, MIT-0, CC0 1.0, WTFPL v2) with no copyleft obligations.
