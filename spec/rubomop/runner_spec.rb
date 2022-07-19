module Rubomop
  RSpec.describe Runner do
    let(:runner) { Runner.new }

    describe "options" do
      it "parses n" do
        runner.parse(["-n2"])
        expect(runner.number).to eq(2)
      end

      it "parses number" do
        runner.parse(["--number=2"])
        expect(runner.number).to eq(2)
      end

      it "parses autocorrect" do
        runner.parse(["-a"])
        expect(runner.autocorrect_only).to eq(true)
      end

      it "parses autocorrect long" do
        runner.parse(["--autocorrect-only"])
        expect(runner.autocorrect_only).to eq(true)
      end

      it "parses no autocorrect long" do
        runner.parse(["--no_autocorrect-only"])
        expect(runner.autocorrect_only).to eq(false)
      end

      it "parses autocorrect" do
        runner.parse(["-r"])
        expect(runner.run_rubocop).to eq(true)
      end

      it "parses autocorrect long" do
        runner.parse(["--run-rubocop"])
        expect(runner.run_rubocop).to eq(true)
      end

      it "parses no autocorrect long" do
        runner.parse(["--no_run-rubocop"])
        expect(runner.run_rubocop).to eq(false)
      end
    end
  end
end
