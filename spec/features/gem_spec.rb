require "spec_helper"

RSpec.describe Autowow::Features::Gem do
  describe ".bundle_exec" do
    it "prefixes command with bundle exec" do
      expect(Autowow::Executor.pretty_with_output).to receive(:run).with(["bundle", "exec", "cmd", "--param"])
      described_class.bundle_exec(["cmd", "--param"])
    end
  end
end
