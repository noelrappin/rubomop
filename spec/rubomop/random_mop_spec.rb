module Rubomop
  RSpec.describe RandomMop do
    let(:filename) { "spec/fixtures/sample_todo.yml" }
    let(:todo_file) { TodoFile.new(filename: filename).parse }
    subject(:mop) do
      described_class.new(
        todo_file:,
        number: 2,
        autocorrect_only: true,
        verbose: false,
        run_rubocop: false,
        only: [],
        except: [],
        blocklist: []
      )
    end

    describe "deletion objects" do
      it "creates a delete option from a cop" do
        cop = todo_file.cops.first
        result = mop.delete_options_for(cop)
        expect(result).to have(2).items
        expect(result.first.cop).to eq(cop)
        expect(result.first.file).to eq("app/controllers/sample_controller.rb")
      end

      it "creates a list of all available removal options" do
        mop.autocorrect_only = false
        expect(mop.delete_options).to have(6).options
      end

      it "creates a list of all options that are autocorrect" do
        expect(mop.delete_options).to have(4).options
      end

      it "deletes one item" do
        mop.autocorrect_only = false
        thing_to_delete = mop.delete_options.find { _1[:file].end_with?("/oops.rb") }
        expect(mop.delete_options).to have(6).options
        mop.mop_once!(thing_to_delete)
        expect(mop.delete_options).to have(5).options
        expect(mop.delete_options.find { _1[:file].end_with?("/oops.rb") }).to be_nil
      end

      it "deletes multiple items" do
        expect(mop.delete_options).to have(4).options
        mop.mop!
        expect(mop.delete_options).to have(2).options
      end

      it "stops when it runs out of items" do
        mop.number = 100
        allow(mop).to receive(:mop_once!).and_call_original
        mop.mop!
        expect(mop.delete_options).to have(0).options
        expect(mop).to have_received(:mop_once!).exactly(4).times
      end
    end

    describe "running rubocop" do
      let(:thing_to_delete) do
        mop.delete_options.find { _1[:file].end_with?("sample_controller.rb") }
      end

      before(:example) do
        allow(IO).to receive("popen")
      end

      it "calls if rubocop is true" do
        mop.run_rubocop = true
        thing_to_delete.run_rubocop = true
        allow(mop.todo_file).to receive(:save!)
        mop.mop_once!(thing_to_delete)
        expect(IO).to have_received("popen")
          .with("bundle exec rubocop app/controllers/sample_controller.rb -aD")
      end

      it "does not call if rubocop is false" do
        mop.run_rubocop = false
        mop.mop_once!(thing_to_delete)
        expect(IO).not_to have_received("popen")
      end

      it "parses the result of a rubocop" do
        rubocop_string = "\nsomething\n\n1 file inspected, 14 offenses detected, 14 offenses corrected"
        expect(thing_to_delete.parse_io(rubocop_string)).to eq(14)
      end

      it "parses the result of a single error rubocop" do
        rubocop_string = "\nsomething\n\n1 file inspected, 1 offense detected, 1 offense corrected"
        expect(thing_to_delete.parse_io(rubocop_string)).to eq(1)
      end

      it "parses the result of bad result" do
        rubocop_string = "\nsomething\n\nglorp"
        expect(thing_to_delete.parse_io(rubocop_string)).to eq(0)
      end
    end

    describe "include / exclude of cops" do
      let(:good_cop) { Cop.create_and_parse(["Layout/ArgumentAlignment:"]) }
      let(:good_cop_option) { RandomMop::DeleteOption.new(good_cop, "oops.rb") }
      let(:bad_cop) { Cop.create_and_parse(["Lint/DuplicateMethods:"]) }
      let(:bad_cop_option) { RandomMop::DeleteOption.new(bad_cop, "") }

      it "when include is set to a string, match based on include" do
        mop.autocorrect_only = false
        mop.only = %w[Layout/ArgumentAlignment]
        expect(mop.accept?(good_cop_option)).to be_truthy
        expect(mop.accept?(bad_cop_option)).to be_falsey
      end

      it "also lets you set include to a substring" do
        mop.autocorrect_only = false
        mop.only = %w[Layout]
        expect(mop.accept?(good_cop_option)).to be_truthy
        expect(mop.accept?(bad_cop_option)).to be_falsey
      end

      it "when exclude is set, exclude based on string" do
        mop.autocorrect_only = false
        mop.except = %w[Layout/ArgumentAlignment]
        expect(mop.accept?(good_cop_option)).to be_falsey
        expect(mop.accept?(bad_cop_option)).to be_truthy
      end

      it "also lets you set exclude to a substring" do
        mop.autocorrect_only = false
        mop.except = %w[Layout]
        expect(mop.accept?(good_cop_option)).to be_falsey
        expect(mop.accept?(bad_cop_option)).to be_truthy
      end

      it "excludes if both exclude and include are set" do
        mop.autocorrect_only = false
        mop.only = %w[Layout/ArgumentAlignment]
        expect(mop.accept?(good_cop_option)).to be_truthy
        mop.except = %w[Layout/ArgumentAlignment]
        expect(mop.accept?(good_cop_option)).to be_falsey
      end

      it "excludes on a block file set to a string" do
        mop.autocorrect_only = false
        mop.only = %w[Layout/ArgumentAlignment]
        expect(mop.accept?(good_cop_option)).to be_truthy
        mop.blocklist = %w[oops.rb]
        expect(mop.accept?(good_cop_option)).to be_falsey
      end

      it "excludes on a block file set to a substring" do
        mop.autocorrect_only = false
        mop.only = %w[Layout/ArgumentAlignment]
        expect(mop.accept?(good_cop_option)).to be_truthy
        mop.blocklist = %w[oops]
        expect(mop.accept?(good_cop_option)).to be_falsey
      end
    end
  end
end
