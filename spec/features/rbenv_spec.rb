require "spec_helper"

RSpec.describe Autowow::Features::Rbenv do
  skip do
    describe ".aliases" do
      it "returns hash" do
        aliases = described_class.ruby_aliases
        expect(aliases).to be_kind_of(Hash)
      end
    end

    describe ".used_versions" do
      it "returns array of rubies used by discoverable projects" do
        versions = described_class.used_versions
        expect(versions).to be_kind_of(Array)
        expect(versions.size).to be >= 1 unless Autowow::Features::Os.exists?("rbenv")
      end
    end

    describe ".obsolete_versions" do
      it "returns array" do
        versions = described_class.obsolete_versions
        expect(versions).to be_kind_of(Array)
      end
    end
  end
end
