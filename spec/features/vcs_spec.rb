require "spec_helper"

RSpec.describe Autowow::Features::Vcs do
  let(:file_name) { 'delete_me' }

  describe '.branch_pushed' do
    it 'returns boolean' do
      expect(described_class.branch_pushed('master')).to be_in([true, false])
    end
  end

  describe '.branches' do
    it 'returns array' do
      branches = described_class.branches
      expect(branches).to be_kind_of(Array)
      expect(branches.size).to be >= 1
      expect(branches).to include('master')
    end
  end

  describe '.keep_changes' do

    context 'when there are changes' do
      before do
        File.open(file_name, "w+") { |file| file.write(file_name) }
        Autowow::Command.run_dry(['git', 'add', file_name])
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
        Autowow::Command.run_dry(['git', 'add', file_name])
        Autowow::Command.run_dry(['git', 'stash'])
      end

      after do
        Autowow::Command.run_dry(['git', 'stash', 'pop'])
        Autowow::Command.run_dry(['git', 'reset', file_name])
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
    let(:working_branch) { 'new_branch' }

    before do
      Autowow::Command.run_dry(['git', 'checkout', '-b', working_branch]) rescue nil
    end

    after do
      Autowow::Command.run_dry(['git', 'branch', '-D', working_branch]) rescue nil
    end

    it 'returns to master and removes working branch' do
      described_class.branch_merged
      expect(Autowow::Command.run_dry(Autowow::Commands::Vcs.current_branch).out.strip).to eq('master')
      expect(described_class.branches.include?(working_branch)).to be_falsey
    end

    context 'when there are changes' do
      before do
        File.open(file_name, "w+") { |file| file.write(file_name) }
        Autowow::Command.run_dry(['git', 'add', file_name])
      end

      after do
        Autowow::Command.run_dry(['git', 'reset', file_name])
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
end
