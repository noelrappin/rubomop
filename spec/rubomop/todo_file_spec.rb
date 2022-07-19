module Rubomop
  RSpec.describe TodoFile do
    let(:filename) { "spec/fixtures/sample_todo.yml" }
    let(:todo) { described_class.new(filename: filename).parse }

    it "reads in the file" do
      expect(todo).to have(29).raw_lines
    end

    it "splits into a header and tasks" do
      expect(todo.header).to have(7).lines
      expect(todo).to have(3).cops
      expect(todo.cops.map(&:name)).to eq(
        %w[Layout/ArgumentAlignment Lint/DuplicateMethods Lint/RedundantStringCoercion]
      )
    end

    it "can create the same data as a file" do
      expect(todo.output_lines).to eq(File.readlines(filename).map(&:chomp))
      expect(todo.output).to eq(File.read(filename))
    end

    it "creates a list of all available removal options" do
      expect(todo.delete_options(autocorrect_only: false)).to have(6).options
    end

    it "creates a list of all options that are autocorrect" do
      expect(todo.delete_options(autocorrect_only: true)).to have(4).options
    end

    it "triggers a delete and causes things to be removed" do
      thing_to_delete = todo.delete_options(autocorrect_only: false)
        .find { _1[:file].end_with?("oops.rb") }
      todo.delete!(thing_to_delete)
      expect(todo.delete_options(autocorrect_only: false)).to have(5).options
      expect(todo.delete_options.find { _1[:file].end_with?("oops.rb") }).to be_nil
    end
  end
end
