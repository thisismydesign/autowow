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
    let(:working_branch) { 'new_branch' }

    before do
      Autowow::Executor.quiet.run(['git', 'checkout', '-b', working_branch]) rescue nil
    end

    after do
      Autowow::Executor.quiet.run(['git', 'branch', '-D', working_branch]) rescue nil
    end

    it 'returns to master and removes working branch' do
      described_class.branch_merged
      expect(described_class.working_branch).to eq('master')
      expect(described_class.branches.include?(working_branch)).to be_falsey
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
      expect(described_class.working_branch).to eq('master')
    end
  end

  describe '.on_branch' do
    let(:branch) { 'new_branch' }

    after do
      Autowow::Executor.quiet.run(['git', 'branch', '-D', branch]) rescue nil
    end

    it 'switches to branch, executes block and switches back to start branch' do
      start_branch = described_class.working_branch
      described_class.on_branch(branch) do
        expect(described_class.working_branch).to eq(branch)
      end
      expect(described_class.working_branch).to eq(start_branch)
    end

    it 'switches back to start branch if error occurs in block' do
      start_branch = described_class.working_branch
      described_class.on_branch(branch) do
        raise 'error'
      end rescue nil
      expect(described_class.working_branch).to eq(start_branch)
    end
  end

  describe '.update_project' do
    let(:branch) { 'new_branch' }

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
    let(:branch) { 'new_branch' }

    context 'unused local branch' do
      before do
        Autowow::Executor.quiet.run(['git', 'branch', branch]) rescue nil
      end

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
        Autowow::Executor.quiet.run(['git', 'branch', branch]) rescue nil
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
end
