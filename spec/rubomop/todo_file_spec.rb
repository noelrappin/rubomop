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

    it "finds cops by name" do
      expect(todo.cop_for("Lint/DuplicateMethods").name).to eq("Lint/DuplicateMethods")
    end

    it "returns active cops" do
      expect(todo.active_cops.map { _1.name })
        .to eq(%w[Layout/ArgumentAlignment Lint/DuplicateMethods Lint/RedundantStringCoercion])
      todo.cop_for("Lint/DuplicateMethods").deactivate
      expect(todo.active_cops.map { _1.name })
        .to eq(%w[Layout/ArgumentAlignment Lint/RedundantStringCoercion])
    end

    it "correctly outputs if cops are deactivated" do
      todo.cop_for("Lint/DuplicateMethods").deactivate
      expect(todo.output).to eq(File.read("spec/fixtures/active_test_todo.yml"))
    end
  end
end
