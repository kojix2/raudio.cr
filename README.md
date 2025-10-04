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

## Examples

See `examples/` directory.

## License

MIT
