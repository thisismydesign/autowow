require "spec_helper"

RSpec.describe Autowow::Features::Gem do
  describe ".gem_clean" do
    it "does not fail" do
      expect { described_class.gem_clean }.to_not raise_error
    end
  end

  describe ".bundle_exec" do
    it "prefixes command with bundle exec" do
      expect(Autowow::Executor.pretty_with_output).to receive(:run).with(["bundle", "exec", "cmd", "--param"])
      described_class.bundle_exec(["cmd", "--param"])
    end
  end
end
