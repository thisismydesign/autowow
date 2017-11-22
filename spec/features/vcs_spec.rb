require "spec_helper"

RSpec.describe Autowow::Features::Vcs do
  let(:file_name) { 'delete_me' }
  let(:branch) { 'new_branch' }

  before :all do
    @start_branch = described_class.working_branch
  end

  describe '.branch_pushed' do
    it 'returns boolean' do
      expect(described_class.branch_pushed(@start_branch)).to be_in([true, false])
    end
  end

  describe '.branches' do
    it 'returns array' do
      branches = described_class.branches
      expect(branches).to be_kind_of(Array)
      expect(branches.size).to be >= 1
      expect(branches).to include(@start_branch)
    end
  end

  describe '.keep_changes' do

    context 'when there are changes' do
      before do
        File.open(file_name, "w+") { |file| file.write(file_name) }
        Autowow::Executor.quiet.run(['git', 'add', file_name])
      end

      after do
        File.delete(file_name)
      end

      it 'stashes changes before executing block and pops stash afterwards' do
        described_class.keep_changes do
          expect(File.file?(file_name)).to be_falsey
        end
        expect(File.file?(file_name)).to be_truthy
      end

      it 'pops stash if error occurs in block' do
        described_class.keep_changes do
          raise 'error'
        end rescue nil
        expect(File.file?(file_name)).to be_truthy
      end
    end

    context 'when there are no changes' do
      before do
        File.open(file_name, "w+") { |file| file.write(file_name) }
        Autowow::Executor.quiet.run(['git', 'add', file_name])
        Autowow::Executor.quiet.run(['git', 'stash'])
      end

      after do
        Autowow::Executor.quiet.run(['git', 'stash', 'pop'])
        Autowow::Executor.quiet.run(['git', 'reset', file_name])
        File.delete(file_name)
      end

      it 'does not pop stash' do
        described_class.keep_changes
        expect(File.file?(file_name)).to be_falsey
      end
    end
  end

  describe '.git_projects' do
    it 'returns an array' do
      expect(described_class.git_projects).to be_kind_of(Array)
    end
  end

  describe '.branch_merged' do
    before do
      Autowow::Executor.quiet.run(['git', 'checkout', '-b', branch]) rescue nil
    end

    after do
      Autowow::Executor.quiet.run(['git', 'branch', '-D', branch]) rescue nil
      Autowow::Executor.quiet.run(described_class.checkout(@start_branch))
    end

    it 'returns to master and removes working branch' do
      described_class.branch_merged
      expect(described_class.working_branch).to eq('master')
      expect(described_class.branches.include?(branch)).to be_falsey
    end

    context 'when there are changes' do
      before do
        File.open(file_name, "w+") { |file| file.write(file_name) }
        Autowow::Executor.quiet.run(['git', 'add', file_name])
      end

      after do
        Autowow::Executor.quiet.run(['git', 'reset', file_name])
        File.delete(file_name)
      end

      it 'carries over the changes to master' do
        described_class.branch_merged
        expect(File.file?(file_name)).to be_truthy
      end
    end
  end

  describe '.greet' do
    it 'does not fail' do
      expect { described_class.greet }.to_not raise_error
    end
  end

  describe '.working_branch' do
    it 'returns current branch' do
      expect(described_class.working_branch).to eq(@start_branch)
    end
  end

  describe '.on_branch' do

    after do
      Autowow::Executor.quiet.run(['git', 'branch', '-D', branch]) rescue nil
    end

    it 'switches to branch, executes block and switches back to start branch' do
      described_class.on_branch(branch) do
        expect(described_class.working_branch).to eq(branch)
      end
      expect(described_class.working_branch).to eq(@start_branch)
    end

    it 'switches back to start branch if error occurs in block' do
      described_class.on_branch(branch) do
        raise 'error'
      end rescue nil
      expect(described_class.working_branch).to eq(@start_branch)
    end
  end

  describe '.update_project' do
    after do
      Autowow::Executor.quiet.run(['git', 'branch', '-D', branch]) rescue nil
    end

    it 'does not fail' do
      expect { described_class.update_project }.to_not raise_error
      # Try via changing branch because there might be local changes on master
      described_class.on_branch(branch) do
        expect { described_class.update_project }.to_not raise_error
      end
    end
  end

  describe '.clear_branches' do
    before do
      Autowow::Executor.quiet.run(['git', 'branch', branch, 'master']) rescue nil
    end

    context 'unused local branch' do
      after do
        Autowow::Executor.quiet.run(['git', 'branch', '-D', branch]) rescue nil
      end

      it 'removes branch' do
        expect(Autowow::Executor.quiet.run(['git', 'branch']).out).to include(branch)
        described_class.clear_branches
        expect(Autowow::Executor.quiet.run(['git', 'branch']).out).to_not include(branch)
      end
    end

    context 'pushed branch' do
      before do
        Autowow::Executor.quiet.run(described_class.set_upstream(branch)) rescue nil
      end

      after do
        Autowow::Executor.quiet.run(['git', 'branch', '-D', branch]) rescue nil
        Autowow::Executor.quiet.run(['git', 'push', '-d', 'origin', branch]) rescue nil
      end

      it 'removes branch' do
        expect(Autowow::Executor.quiet.run(['git', 'branch']).out).to include(branch)
        described_class.clear_branches
        expect(Autowow::Executor.quiet.run(['git', 'branch']).out).to_not include(branch)
      end
    end
  end

  describe ".origin_push_url" do
    let(:expected) { 'https://github.com/thisismydesign/autowow' }

    it 'matches http format' do
      remote = 'origin	https://github.com/thisismydesign/autowow (push)'
      expect(described_class.origin_push_url(remote)).to eq(expected)
    end

    it 'matches http .git format' do
      remote = 'origin	https://github.com/thisismydesign/autowow.git (push)'
      expect(described_class.origin_push_url(remote)).to eq(expected)
    end

    it 'matches ssh format' do
      remote = 'origin	git@github.com:thisismydesign/autowow (push)'
      expect(described_class.origin_push_url(remote)).to eq(expected)
    end

    it 'matches ssh .git format' do
      remote = 'origin	git@github.com:thisismydesign/autowow.git (push)'
      expect(described_class.origin_push_url(remote)).to eq(expected)
    end

    it 'matches dashes' do
      remote = 'origin	git@github.com:thisismydesign/auto-wow.git (push)'
      expect(described_class.origin_push_url(remote)).to eq('https://github.com/thisismydesign/auto-wow')
    end

    it 'matches underscores' do
      remote = 'origin	git@github.com:thisismydesign/auto_wow.git (push)'
      expect(described_class.origin_push_url(remote)).to eq('https://github.com/thisismydesign/auto_wow')
    end

    it 'matches origin' do
      remote = 'upstream	git@github.com:thisismydesign/autowow.git (push)'
      expect(described_class.origin_push_url(remote)).to_not be
    end

    it 'matches push' do
      remote = 'origin	git@github.com:thisismydesign/autowow.git (pull)'
      expect(described_class.origin_push_url(remote)).to_not be
    end

    it 'matches single example' do
      remote = "origin	git@github.com:thisismydesign/autowow.git (pull)\norigin	git@github.com:thisismydesign/autowow.git (push)"
      expect(described_class.origin_push_url(remote)).to eq(expected)
    end
  end

  describe '.add_upstream' do
    it 'does not fail' do
      expect {  described_class.add_upstream }.to_not raise_error
    end
  end

  describe '.hi' do
    it 'does not fail' do
      expect {  described_class.hi }.to_not raise_error
    end
  end

  describe '.hi!' do
    it 'does not fail' do
      expect {  described_class.hi! }.to_not raise_error
    end
  end

  context 'test suite' do
    it 'does not change working branch' do
      expect(described_class.working_branch).to eq(@start_branch)
    end
  end
end
