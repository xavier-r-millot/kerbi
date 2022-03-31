require_relative 'consts'
require_relative 'helpers'

module HelloKerbi
  class Mixer < Kerbi::Mixer
    include Helpers

    def mix
      patched_with file("common/metadata") do
        push file("pod-and-service")
      end
    end
  end
end

Kerbi::Globals.default_version = 3
Kerbi::Globals.mixers << HelloKerbi::Mixer