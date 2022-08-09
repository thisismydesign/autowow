require "spec_helper"

RSpec.describe Autowow::Features::Vcs do

  let(:test_project) { './spec/test_project' }

  around(:example) do |example|
    Dir.chdir(test_project) do
      Autowow::Executor.quiet.run!(['git', 'init'])
      example.run
      Autowow::Executor.quiet.run!(['rm', '-rf', '.git'])
    end
  end

  describe ".branches" do
    it "returns array" do
      expect(described_class.branches).to be_kind_of(Array)
    end
  end

  describe ".working_branch" do
    it "returns current branch" do
      expect(described_class.working_branch).to eq('master')
    end
  end

  describe ".default_branch" do
    it "returns default branch" do
      expect(described_class.working_branch).to eq('master')
    end
  end

  describe ".branch_pushed" do
    it "returns boolean" do
      branch = described_class.working_branch

      expect(described_class.branch_pushed(branch)).to be_in([true, false])
    end
  end

  describe ".git_projects" do
    it "returns an array" do
      expect(described_class.git_projects).to be_kind_of(Array)
    end
  end

  describe ".origin_push_url" do
    let(:expected) { "https://github.com/thisismydesign/autowow" }

    it "matches http format" do
      remote = "origin\thttps://github.com/thisismydesign/autowow (push)"
      expect(described_class.origin_push_url(remote)).to eq(expected)
    end

    it "matches http .git format" do
      remote = "origin\thttps://github.com/thisismydesign/autowow.git (push)"
      expect(described_class.origin_push_url(remote)).to eq(expected)
    end

    it "matches ssh format" do
      remote = "origin\tgit@github.com:thisismydesign/autowow (push)"
      expect(described_class.origin_push_url(remote)).to eq(expected)
    end

    it "matches ssh .git format" do
      remote = "origin\tgit@github.com:thisismydesign/autowow.git (push)"
      expect(described_class.origin_push_url(remote)).to eq(expected)
    end

    it "matches dashes" do
      remote = "origin\tgit@github.com:thisismydesign/auto-wow.git (push)"
      expect(described_class.origin_push_url(remote)).to eq("https://github.com/thisismydesign/auto-wow")
    end

    it "matches underscores" do
      remote = "origin\tgit@github.com:thisismydesign/auto_wow.git (push)"
      expect(described_class.origin_push_url(remote)).to eq("https://github.com/thisismydesign/auto_wow")
    end

    it "matches origin" do
      remote = "upstream\tgit@github.com:thisismydesign/autowow.git (push)"
      expect(described_class.origin_push_url(remote)).to_not be
    end

    it "matches push" do
      remote = "origin\tgit@github.com:thisismydesign/autowow.git (pull)"
      expect(described_class.origin_push_url(remote)).to_not be
    end

    it "matches single example" do
      remote = "origin	git@github.com:thisismydesign/autowow.git (pull)\norigin	git@github.com:thisismydesign/autowow.git (push)"
      expect(described_class.origin_push_url(remote)).to eq(expected)
    end
  end
end
