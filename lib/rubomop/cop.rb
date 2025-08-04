module Rubomop
  class Cop
    attr_accessor :offense_count, :name, :files, :autocorrect, :comments
    attr_reader :raw_lines

    def self.create_and_parse(raw_lines)
      result = new(raw_lines)
      result.parse
      result
    end

    def initialize(raw_lines)
      @raw_lines = raw_lines
      @files = []
      @autocorrect = false
      @comments = []
    end

    def parse
      raw_lines.each { parse_one_line(_1) }
    end

    OFFENSE_COUNT_REGEX = /\A# Offense count: (\d*)/
    COP_NAME_REGEX = /\A(.*):/
    FILE_NAME_REGEX = /- '(.*)'/
    AUTOCORRECT_REGEX = /\A# Cop supports --auto-correct./
    GENERAL_COMMENT_REGEX = /\A#/
    EXCLUDE_REGEX = /Exclude:/

    def parse_one_line(line)
      case line
      when OFFENSE_COUNT_REGEX
        self.offense_count = line.match(OFFENSE_COUNT_REGEX)[1].to_i
      when AUTOCORRECT_REGEX
        self.autocorrect = true
      when GENERAL_COMMENT_REGEX
        comments << line.chomp
      when EXCLUDE_REGEX
        # no-op
      when COP_NAME_REGEX
        self.name = line.match(COP_NAME_REGEX)[1]
      when FILE_NAME_REGEX
        files << line.match(FILE_NAME_REGEX)[1]
      end
    end

    def output
      output_lines.join("\n")
    end

    def output_lines
      result = ["# Offense count: #{offense_count}"]
      result << "# Cop supports --auto-correct." if autocorrect
      result += comments
      result << "#{name}:"
      result << "  Exclude:"
      result + files.map { "    - '#{_1}'" }
    end

    def delete!(filename)
      files.delete(filename)
    end

    def subtract!(offense_count)
      self.offense_count -= offense_count
    end
  end
end
