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

    def cop_for(name)
      cops.select { _1.name == name }.first
    end

    def active_cops
      cops.select { _1.active? }
    end

    def output_lines
      result = header.map(&:chomp)
      result << ""
      active_cops.each do |cop|
        result += cop.output_lines
        result << ""
      end
      result[0..-2]
    end

    def output
      output_lines.join("\n") + "\n"
    end

    def save!
      FileUtils.rm_f(filename)
      File.write(filename, output || "")
    end
  end
end
