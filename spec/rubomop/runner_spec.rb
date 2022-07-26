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

      it "parses filename" do
        runner.parse(["-ftodo.yml"])
        expect(runner.filename).to eq("todo.yml")
      end

      it "parses filename long" do
        runner.parse(["--filename=todo.yml"])
        expect(runner.filename).to eq("todo.yml")
      end

      it "parses only list" do
        runner.parse(["--only=Lint*"])
        expect(runner.only).to eq(%w[Lint*])
      end

      it "parses only list with multiples" do
        runner.parse(%w[--only=Lint* --only=Layout])
        expect(runner.only).to eq(%w[Lint* Layout])
      end

      it "parses except list" do
        runner.parse(["--except=Lint*"])
        expect(runner.except).to eq(%w[Lint*])
      end

      it "parses only list with multiples" do
        runner.parse(%w[--except=Lint* --except=Layout])
        expect(runner.except).to eq(%w[Lint* Layout])
      end

      it "parses block list" do
        runner.parse(["--block=oops*"])
        expect(runner.block).to eq(%w[oops*])
      end

      it "parses block list with multiples" do
        runner.parse(%w[--block=oops* --block=controller*])
        expect(runner.block).to eq(%w[oops* controller*])
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
      before(:example) do
        FileUtils.cp("spec/fixtures/sample_todo.yml", ".rubocop_todo.yml")
      end

      after(:example) do
        FileUtils.rm(".rubocop_todo.yml")
      end

      it "saves a file" do
        runner.todo = TodoFile.new(filename: ".rubocop_todo.yml").parse
        runner.todo.save!
        expect(File.exist?(".rubocop_todo.yml")).to be_truthy
      end
    end

    describe "reads from a configuration file" do
      before(:example) do
        FileUtils.cp("spec/fixtures/sample_rubomop.yml", ".rubomop.yml")
      end

      after(:example) do
        FileUtils.rm_f(".rubomop.yml")
        FileUtils.rm_f("mops.yml")
      end

      it "reads from the configuration file" do
        runner.load_from_file
        expect(runner.number).to eq(20)
        expect(runner.autocorrect_only).to be_falsey
        expect(runner.run_rubocop).to be_falsey
        expect(runner.only).to eq(%w[Lint Layout])
      end

      it "skips if the configuration file has a bad key" do
        File.open(".rubomop.yml", "a") do |f|
          f << "nothing: false"
        end
        runner.load_from_file
        expect(runner.number).to eq(20)
      end

      it "is fine if the file doesn't exist" do
        FileUtils.rm_f(".rubomop.yml")
        runner.load_from_file
        expect(runner.number).to eq(10)
      end

      it "it works if the file is malformed" do
        FileUtils.rm_f(".rubomop.yml")
        FileUtils.cp("spec/fixtures/bad_rubomop.yml", ".rubomop.yml")
        runner.load_from_file
        expect(runner.number).to eq(10)
      end

      it "takes an option to locate the configuration file" do
        FileUtils.mv(".rubomop.yml", "mops.yml")
        runner.load_options(["--config=mops.yml"])
        expect(runner.number).to eq(20)
      end

      it "command line options win" do
        runner.load_options(["-n30"])
        expect(runner.number).to eq(30)
      end
    end
  end
end
