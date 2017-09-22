require "spec_helper"

RSpec.describe Autowow::Vcs do
  describe ".origin_push_url" do
    let(:expected) { 'https://github.com/thisismydesign/autowow' }

    it 'matches http format' do
      remote = 'origin	https://github.com/thisismydesign/autowow (push)'
      expect(Autowow::Vcs.origin_push_url(remote)).to eq(expected)
    end

    it 'matches http .git format' do
      remote = 'origin	https://github.com/thisismydesign/autowow.git (push)'
      expect(Autowow::Vcs.origin_push_url(remote)).to eq(expected)
    end

    it 'matches ssh format' do
      remote = 'origin	git@github.com:thisismydesign/autowow (push)'
      expect(Autowow::Vcs.origin_push_url(remote)).to eq('https://github.com/thisismydesign/autowow')
    end

    it 'matches ssh .git format' do
      remote = 'origin	git@github.com:thisismydesign/autowow.git (push)'
      expect(Autowow::Vcs.origin_push_url(remote)).to eq(expected)
    end

    it 'matches dashes' do
      remote = 'origin	git@github.com:thisismydesign/auto-wow.git (push)'
      expect(Autowow::Vcs.origin_push_url(remote)).to eq('https://github.com/thisismydesign/auto-wow')
    end

    it 'matches origin' do
      remote = 'upstream	git@github.com:thisismydesign/autowow.git (push)'
      expect(Autowow::Vcs.origin_push_url(remote)).to_not be
    end

    it 'matches push' do
      remote = 'origin	git@github.com:thisismydesign/autowow.git (pull)'
      expect(Autowow::Vcs.origin_push_url(remote)).to_not be
    end

    it 'matches single example' do
      remote = "origin	git@github.com:thisismydesign/autowow.git (pull)\norigin	git@github.com:thisismydesign/autowow.git (push)"
      expect(Autowow::Vcs.origin_push_url(remote)).to eq(expected)
    end
  end
end
