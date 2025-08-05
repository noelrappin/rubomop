module Rubomop
  RSpec.describe NamedMop do
    let(:filename) { "spec/fixtures/sample_todo.yml" }
    let(:todo_file) { TodoFile.new(filename: filename).parse }

    describe "happy path" do
      let(:mop) do
        Rubomop::NamedMop.new(
          todo_file:,
          name: "Lint/DuplicateMethods",
          verbose: false,
          run_rubocop: false
        )
      end

      it "correctly updates objects" do
        mop.mop!
        expect(todo_file.active_cops.map { _1.name })
          .to eq(%w[Layout/ArgumentAlignment Lint/RedundantStringCoercion])
      end
    end
  end
end
