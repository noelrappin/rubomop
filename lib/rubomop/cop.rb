module Rubomop
  class Cop < Literal::Object
    prop :raw_lines, _Array(String), reader: :public, default: -> { [] }
    prop :files, _Array(String), reader: :public, writer: :public, default: -> { [] }
    prop :comments, _Array(String), reader: :public, writer: :public, default: -> { [] }
    prop :autocorrect, _Nilable(Symbol), reader: :public, writer: :public, default: :none
    prop :offense_count, Integer, reader: :public, writer: :public, default: 0
    prop :name, String, reader: :public, writer: :public, default: -> { "" }
    prop :active, _Boolean, reader: :public, writer: :public, default: true

    def self.create_and_parse(raw_lines)
      result = new(raw_lines:)
      result.parse
      result
    end

    def parse
      raw_lines.each { parse_one_line(_1) }
    end

    OFFENSE_COUNT_REGEX = /\A# Offense count: (\d*)/
    COP_NAME_REGEX = /\A(.*):/
    FILE_NAME_REGEX = /- '(.*)'/
    SAFE_AUTOCORRECT_REGEX = /\A# This cop supports safe autocorrection/
    UNSAFE_AUTOCORRECT_REGEX = /\A# This cop supports unsafe autocorrection/
    GENERAL_COMMENT_REGEX = /\A#/
    EXCLUDE_REGEX = /Exclude:/

    def parse_one_line(line)
      case line
      when OFFENSE_COUNT_REGEX
        self.offense_count = line.match(OFFENSE_COUNT_REGEX)[1].to_i
      when SAFE_AUTOCORRECT_REGEX
        self.autocorrect = :safe
      when UNSAFE_AUTOCORRECT_REGEX
        self.autocorrect = :unsafe
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
      result << "# This cop supports safe autocorrection (--autocorrect)." if autocorrect == :safe
      result << "# # This cop supports unsafe autocorrection (--autocorrect-all)." if autocorrect == :unsafe
      result += comments
      result << "#{name}:"
      result << "  Exclude:"
      result + files.map { "    - '#{_1}'" }
    end

    def any_autocorrect?
      autocorrect != :none
    end

    def autocorrect_inquiry
      autocorrect.to_s.inquiry
    end

    def autocorrect_verbiage
      case autocorrect
      when :safe then "safe autocorrect"
      when :unsafe then "unsafe autocorrect"
      else
        "no autocorrect"
      end
    end

    def autocorrect_option
      case autocorrect
      when :safe then "a"
      when :unsafe then "A"
      else
        ""
      end
    end

    def delete!(filename)
      files.delete(filename)
    end

    def subtract!(offense_count)
      self.offense_count -= offense_count
    end

    def activate
      self.active = true
    end

    def deactivate
      self.active = false
    end

    def active?
      active
    end
  end
end
