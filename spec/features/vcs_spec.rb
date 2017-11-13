require "spec_helper"

RSpec.describe Autowow::Features::Vcs do
  let(:file_name) { 'delete_me' }

  describe '.branch_pushed' do
    it 'returns boolean' do
      expect(Autowow::Features::Vcs.branch_pushed('master')).to be_in([true, false])
    end
  end

  describe '.branches' do
    it 'returns array' do
      branches = Autowow::Features::Vcs.branches
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
        Autowow::Features::Vcs.keep_changes do
          expect(File.file?(file_name)).to be_falsey
        end
        expect(File.file?(file_name)).to be_truthy
      end

      it 'pops stash if error occurs in block' do
        Autowow::Features::Vcs.keep_changes do
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
        File.delete(file_name)
      end

      it 'does not pop stash' do
        Autowow::Features::Vcs.keep_changes
        expect(File.file?(file_name)).to be_falsey
      end
    end
  end

  describe '.git_projects' do
    it 'returns an array' do
      expect(Autowow::Features::Vcs.git_projects).to be_kind_of(Array)
    end
  end

  describe '.branch_merged' do
    let(:working_branch) { 'new_branch' }

    before do
      Autowow::Command.run_dry(['git', 'checkout', '-b', working_branch])
    end

    it 'returns to master and removes working branch' do
      Autowow::Features::Vcs.branch_merged
      expect(Autowow::Command.run_dry(Autowow::Commands::Vcs.current_branch).out.strip).to eq('master')
      expect(Autowow::Features::Vcs.branches.include?(working_branch)).to be_falsey
    end

    context 'when there are changes' do
      before do
        File.open(file_name, "w+") { |file| file.write(file_name) }
        Autowow::Command.run_dry(['git', 'add', file_name])
      end

      after do
        File.delete(file_name)
      end

      it 'carries over the changes to master' do
        Autowow::Features::Vcs.branch_merged
        expect(File.file?(file_name)).to be_truthy
      end
    end
  end
end