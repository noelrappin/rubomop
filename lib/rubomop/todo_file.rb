module Rubomop
  class TodoFile
    attr_reader :filename
    attr_accessor :raw_lines, :header, :cops

    def initialize(filename:)
      @filename = filename
    end

    def parse
      self.raw_lines = File.readlines(filename)
      self.header, *raw_tasks = raw_lines.split("\n")
      self.cops = raw_tasks.map { Cop.create_and_parse(_1) }
      self
    end

    def output_lines
      result = header.map(&:chomp)
      result << ""
      cops.each do |cop|
        result += cop.output_lines
        result << ""
      end
      result[0..-2]
    end

    def output
      output_lines.join("\n") + "\n"
    end

    def delete_options(autocorrect_only: true)
      result = cops.flat_map(&:delete_options)
      result = result.select { _1[:cop].autocorrect } if autocorrect_only
      result
    end

    def delete!(delete_option)
      delete_option[:cop].delete!(delete_option[:file])
    end
  end
end
