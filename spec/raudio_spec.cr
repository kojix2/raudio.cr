require "./spec_helper"

describe Raudio do
  it "has a version number" do
    Raudio::VERSION.should be_a(String)
  end

  describe Raudio::AudioDevice do
    it "can initialize and close audio device" do
      Raudio::AudioDevice.init
      Raudio::AudioDevice.ready?.should be_true
      Raudio::AudioDevice.close
    end

    it "can use block form for automatic initialization and cleanup" do
      device_was_ready = false
      Raudio::AudioDevice.open do
        device_was_ready = Raudio::AudioDevice.ready?
      end
      device_was_ready.should be_true
    end

    it "can set and get master volume" do
      Raudio::AudioDevice.open do
        Raudio::AudioDevice.master_volume = 0.5
        volume = Raudio::AudioDevice.master_volume
        volume.should be_close(0.5, 0.01)
      end
    end
  end
end
