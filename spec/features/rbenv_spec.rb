require "spec_helper"

RSpec.describe Autowow::Features::Rbenv do
  describe '.aliases' do
    it 'returns hash' do
      aliases = Autowow::Features::Rbenv.aliases
      expect(aliases).to be_kind_of(Hash)
    end
  end

  describe '.used_versions' do
    it 'returns array of rubies used by discoverable projects' do
      versions = Autowow::Features::Rbenv.used_versions
      expect(versions).to be_kind_of(Array)
      expect(versions.size).to be >= 1 unless Autowow::Command.exists?('rbenv')
    end
  end

  describe '.obsolete_versions' do
    it 'returns array' do
      versions = Autowow::Features::Rbenv.obsolete_versions
      expect(versions).to be_kind_of(Array)
    end
  end
end
