require_relative 'vcs'
require_relative 'command'

module Autowow
  class Gem
    def self.release
      ['rake', 'release']
    end

    def self.clean
      ['gem', 'clean']
    end
  end
end
