require "spec_helper"

RSpec.describe Autowow::Features::Gem do
  describe '.gem_clean' do
    it 'does not fail' do
      expect { described_class.gem_clean }.to_not raise_error
    end
  end
end
