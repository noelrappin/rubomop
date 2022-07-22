module Rubomop
  class Mop
    attr_accessor :todo_file, :number, :autocorrect_only
    attr_accessor :verbose, :only, :except, :block

    def initialize(todo_file, number, autocorrect_only, verbose, only, except, blocklist)
      @todo_file = todo_file
      @number = number
      @autocorrect_only = autocorrect_only
      @verbose = verbose
      @only = only
      @except = except
      @block = blocklist
    end

    def cops
      todo_file.cops
    end

    def accept?(delete_option)
      return false if autocorrect_only && !delete_option.cop.autocorrect
      unless except.empty?
        return except.none? { %r{#{_1}}.match?(delete_option.cop.name) }
      end
      unless block.empty?
        return block.none? { %r{#{_1}}.match?(delete_option.file) }
      end
      unless only.empty?
        return only.any? { %r{#{_1}}.match?(delete_option.cop.name) }
      end
      true
      # return true unless autocorrect_only
      # cop.autocorrect
    end

    def delete_options
      cops.flat_map { delete_options_for(_1) }
        .select { accept?(_1) }
    end

    def delete_options_for(cop)
      cop.files.map { DeleteOption.new(cop, _1, verbose) }
    end

    def log(message)
      return unless verbose
      message
    end

    def mop!
      number.times do |i|
        options = delete_options
        next if options.empty?
        log("#{i + 1}:")
        mop_once!(options.sample)
        log("\n")
      end
    end

    def mop_once!(delete_option)
      delete_option.print_message if verbose
      delete_option.delete!
    end

    DeleteOption = Struct.new(:cop, :file, :verbose) do
      def print_message
        return unless verbose
        "Deleting #{file} from #{cop.name}"
      end

      def delete!
        cop.delete!(file)
      end
    end
  end
end
