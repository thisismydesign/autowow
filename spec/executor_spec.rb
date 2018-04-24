require "spec_helper"

RSpec.describe Autowow::Executor do
  describe "pretty_with_output.run" do
    it "fails silently on command error" do
      expect { described_class.pretty_with_output.run(["exit", "1"]) }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(1)
      end
    end
end

describe "pretty.run" do
    it "raises on command error" do
      expect { described_class.pretty.run(["exit", "1"]) }.to raise_error(TTY::Command::ExitError)
    end
  end
end
