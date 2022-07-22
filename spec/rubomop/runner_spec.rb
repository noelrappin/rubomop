module Rubomop
  RSpec.describe Runner do
    let(:runner) { Runner.new }

    describe "options" do
      it "parses n" do
        runner.parse(["-n2"])
        expect(runner.number).to eq(2)
        expect(runner.mop.number).to eq(2)
      end

      it "parses number" do
        runner.parse(["--number=2"])
        expect(runner.number).to eq(2)
      end

      it "parses autocorrect" do
        runner.parse(["-a"])
        expect(runner.autocorrect_only).to eq(true)
        expect(runner.mop.autocorrect_only).to eq(true)
      end

      it "parses autocorrect long" do
        runner.parse(["--autocorrect-only"])
        expect(runner.autocorrect_only).to eq(true)
      end

      it "parses no autocorrect long" do
        runner.parse(["--no_autocorrect-only"])
        expect(runner.autocorrect_only).to eq(false)
        expect(runner.mop.autocorrect_only).to eq(false)
      end

      it "parses run rubocop" do
        runner.parse(["-r"])
        expect(runner.run_rubocop).to eq(true)
      end

      it "parses run rubocop long" do
        runner.parse(["--run-rubocop"])
        expect(runner.run_rubocop).to eq(true)
      end

      it "parses no run rubocop long" do
        runner.parse(["--no_run-rubocop"])
        expect(runner.run_rubocop).to eq(false)
      end
    end

    describe "backup existing file" do
      before(:example) do
        FileUtils.cp("spec/fixtures/sample_todo.yml", ".rubocop_todo.yml")
      end

      after(:example) do
        FileUtils.rm(".rubocop_todo.yml.bak")
      end

      it "does a backup of the existing file" do
        runner.backup_existing_file
        expect(File.exist?(".rubocop_todo.yml.bak")).to be_truthy
        expect(File.exist?(".rubocop_todo.yml")).to be_falsy
      end
    end

    describe "save file" do
      after(:example) do
        FileUtils.rm(".rubocop_todo.yml")
      end

      it "saves a file" do
        runner.save_new_file
        expect(File.exist?(".rubocop_todo.yml")).to be_truthy
      end
    end

    describe "run rubocop" do
      before(:example) do
        allow(runner).to receive("system")
      end

      it "calls if rubocop is true" do
        runner.run_rubocop = true
        runner.rubocop_runner
        expect(runner).to have_received("system").with("bundle exec rubocop -aD")
      end

      it "does not call if rubocop is false" do
        runner.run_rubocop = false
        runner.rubocop_runner
        expect(runner).not_to have_received("system")
      end
    end
  end
end
