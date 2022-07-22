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
  end
end
