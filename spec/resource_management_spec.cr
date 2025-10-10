require "./spec_helper"

describe "Resource management (Sound/Music)" do
  resources_dir = File.expand_path("../ext/raudio/examples/resources", __DIR__)
  sound_path = File.join(resources_dir, "weird.wav")
  music_path = File.join(resources_dir, "country.mp3")

  if ENV["CI"]?
    pending "Device-dependent resource tests are skipped in CI"
  else
    it "releases Sound automatically in block form" do
      Raudio::AudioDevice.open do
        sound_ref : Raudio::Sound? = nil
        Raudio::Sound.load(sound_path) do |sound|
          sound_ref = sound
          sound.ready?.should be_true
        end

        # After block, resource should be released
        sound_ref.should_not be_nil
        sound_ref.not_nil!.released?.should be_true
        expect_raises(Raudio::ReleasedError) { sound_ref.not_nil!.volume = 0.5_f32 }
      end
    end

    it "releases Music automatically in block form" do
      Raudio::AudioDevice.open do
        music_ref : Raudio::Music? = nil
        Raudio::Music.load(music_path) do |music|
          music_ref = music
          music.ready?.should be_true
        end

        music_ref.should_not be_nil
        music_ref.not_nil!.released?.should be_true
        expect_raises(Raudio::ReleasedError) { music_ref.not_nil!.volume = 0.5_f32 }
      end
    end

    it "unloading a Sound alias does not release the source" do
      Raudio::AudioDevice.open do
        source = Raudio::Sound.load(sound_path)
        begin
          alias_sound = Raudio::Sound.alias(source)
          # Initially both should be unreleased
          source.released?.should be_false
          alias_sound.released?.should be_false

          # Unload alias only
          alias_sound.unload_alias
          alias_sound.released?.should be_true
          # Source remains valid
          source.released?.should be_false
        ensure
          source.release
        end
      end
    end

    it "persists Music looping flag across set/get" do
      Raudio::AudioDevice.open do
        music = Raudio::Music.load(music_path)
        begin
          # Default is library-defined; just verify setter/getter round-trip
          music.looping = false
          music.looping?.should be_false
          music.looping = true
          music.looping?.should be_true
        ensure
          music.release
        end
      end
    end
  end
end
