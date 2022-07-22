module Rubomop
  RSpec.describe Mop do
    let(:filename) { "spec/fixtures/sample_todo.yml" }
    let(:todo) { TodoFile.new(filename: filename).parse }
    subject(:mop) { described_class.new(todo, 2, true, false) }

    describe "deletion objects" do
      it "creates a delete option from a cop" do
        cop = todo.cops.first
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
  end
end
