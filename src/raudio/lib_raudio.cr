module Raudio
  {% if flag?(:msvc) %}
    @[Link("raudio", ldflags: "/LIBPATH:#{__DIR__}\\..\\..\\ext")]
  {% else %}
    @[Link("raudio", ldflags: "-L#{__DIR__}/../../ext")]
  {% end %}
  lib LibRaudio
  end
end
