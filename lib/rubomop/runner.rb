module Rubomop
  class Runner
    attr_accessor :number, :autocorrect_only, :run_rubocop, :filename, :todo
    NUM_STRING = "Number of cleanups to perform (default: 10)"
    AUTOCORRECT_STRING = "Only clean autocorrectable cops (default)"
    NO_AUTOCORRECT_STRING = "Clean all cops (not default)"
    RUBOCOP_STRING = "Run rubocop -aD after (default)"
    NO_RUBOCOP_STRING = "Don't run rubocop -aD after (not default)"
    FILENAME_STRING = "Name of todo file (default: ./.rubocop_todo.yml)"

    def initialize
      @number = 10
      @autocorrect_only = true
      @run_rubocop = true
      @filename = ".rubocop_todo.yml"
      @todo = nil
    end

    def execute(args)
      parse(args)
      run
    end

    def parse(args)
      option_parser = OptionParser.new do |opts|
        opts.banner = "Usage: rubomop [options]"
        opts.on("-nNUMBER", "--number NUMBER", Integer, NUM_STRING) do |value|
          self.number = value
        end
        opts.on("-a", "--autocorrect_only", AUTOCORRECT_STRING) do
          self.autocorrect_only = true
        end
        opts.on("--no_autocorrect_only", NO_AUTOCORRECT_STRING) do
          self.autocorrect_only = false
        end
        opts.on("-r", "--run_rubocop", RUBOCOP_STRING) do
          self.run_rubocop = true
        end
        opts.on("-fFILENAME", "--filename FILENAME", FILENAME_STRING) do |value|
          self.filename = value
        end
        opts.on("--no_run_rubocop", NO_RUBOCOP_STRING) do
          self.run_rubocop = false
        end
        opts.on("-h", "--help", "Prints this help") do
          puts opts
          exit
        end
      end
      option_parser.parse(args)
    end

    def run
      self.todo = TodoFile.new(filename: filename).parse
      number.times do|i|
        delete_options = todo.delete_options(autocorrect_only: autocorrect_only)
        next if delete_options.empty?
        object_to_delete = delete_options.sample
        print "#{i + 1}: Deleting #{object_to_delete[:file]} from #{object_to_delete[:cop].name}\n"
        todo.delete!(object_to_delete)
      end
      backup_existing_file
      save_new_file
      rubocop_runner
    end

    def backup_existing_file
      FileUtils.rm("#{filename}.bak") if File.exist?("#{filename}.bak")
      FileUtils.mv(filename, "#{filename}.bak")
    end

    def save_new_file
      File.open(filename, "w") do|f|
        f.write(todo.output)
      end
    end

    def rubocop_runner
      return unless run_rubocop
      print "Running bundle exec rubocop -aD"
      system("bundle exec rubocop -aD")
    end
  end
end
