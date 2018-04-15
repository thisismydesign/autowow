require "spec_helper"

RSpec.describe Autowow::Features::Os do
  describe ".exists?" do
    it "returns whether specified command exists" do
      expect(described_class.exists?("git")).to be_truthy
      expect(described_class.exists?("ugrsfdsfghjkmjnbgv")).to be_falsey
    end
  end
end
