module Rubomop
  RSpec.describe Cop do
    subject(:cop) { Cop.new(lines) }

    describe "with a basic set of lines" do
      let(:lines) do
        <<~LINES
          # Offense count: 2
          Lint/DuplicateMethods:
            Exclude:
              - 'app/models/oops.rb'
              - 'app/models/another_oops.rb'
        LINES
          .split("\n")
      end

      it "parses the basic lines", :aggregate_failures do
        cop.parse
        expect(cop.offense_count).to eq(2)
        expect(cop.name).to eq("Lint/DuplicateMethods")
        expect(cop.autocorrect).to be_falsey
        expect(cop.files).to eq(%w[app/models/oops.rb app/models/another_oops.rb])
        expect(cop.comments).to eq([])
      end

      it "can output the lines" do
        cop.parse
        expect(cop.output_lines).to eq(lines)
        expect(cop.output.split("\n")).to eq(lines)
      end

      it "can create a list of deletion options" do
        cop.parse
        expect(cop.delete_options.map { _1[:file] }).to eq(cop.files)
        expect(cop.delete_options.map { _1[:cop] }).to eq([cop, cop])
      end
    end

    describe "with an autocorrect and comments" do
      let(:lines) do
        <<~LINES
          # Offense count: 2
          # Cop supports --auto-correct.
          # Configuration parameters: EnforcedStyle, IndentationWidth.
          # SupportedStyles: with_first_argument, with_fixed_indentation
          Layout/ArgumentAlignment:
            Exclude:
              - 'app/controllers/sample_controller.rb'
              - 'app/controllers/another_controller.rb'
        LINES
          .split("\n")
      end

      it "parses the lines", :aggregate_failures do
        cop.parse
        expect(cop.offense_count).to eq(2)
        expect(cop.name).to eq("Layout/ArgumentAlignment")
        expect(cop.autocorrect).to be_truthy
        expect(cop.files).to eq(%w[app/controllers/sample_controller.rb app/controllers/another_controller.rb])
        expect(cop.comments).to eq(
          [
            "# Configuration parameters: EnforcedStyle, IndentationWidth.",
            "# SupportedStyles: with_first_argument, with_fixed_indentation"
          ]
        )
      end

      it "deletes a given file" do
        cop.parse
        cop.delete!("app/controllers/sample_controller.rb")
        expect(cop.files).to eq(%w[app/controllers/another_controller.rb])
        expect(cop.offense_count).to eq(1)
      end
    end

    describe "parsing single lines" do
      let(:lines) { [] }

      it "parses an offense count line" do
        cop.parse_one_line("# Offense count: 2")
        expect(cop.offense_count).to eq(2)
      end

      it "parses an offense count line with a multi digit count" do
        cop.parse_one_line("# Offense count: 23")
        expect(cop.offense_count).to eq(23)
      end

      it "parses an offense count line with a three digit count" do
        cop.parse_one_line("# Offense count: 233")
        expect(cop.offense_count).to eq(233)
      end

      it "parses a name line" do
        cop.parse_one_line("Lint/DuplicateMethods:")
        expect(cop.name).to eq("Lint/DuplicateMethods")
      end

      it "ignores the exclude line" do
        cop.parse_one_line("  Exclude:")
        expect(cop.name).to eq(nil)
      end

      it "parses a file line" do
        cop.parse_one_line("    - 'app/models/oops.rb'")
        expect(cop.files).to eq(%w[app/models/oops.rb])
      end

      it "parses an auto correct line" do
        cop.parse_one_line("# Cop supports --auto-correct.")
        expect(cop.autocorrect).to be_truthy
      end

      it "parses a generic comment" do
        cop.parse_one_line("# Configuration parameters: EnforcedStyle, IndentationWidth.")
        expect(cop.comments).to eq(["# Configuration parameters: EnforcedStyle, IndentationWidth."])
      end
    end
  end
end
