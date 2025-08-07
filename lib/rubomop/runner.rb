module Rubomop
  class Runner
    attr_accessor :number, :autocorrect_only, :run_rubocop, :filename, :todo_file, :verbose, :config,
      :options_from_command_line, :only, :except, :blocklist, :name, :directory

    NUM_STRING = "Number of cleanups to perform (default: 10)"
    NAME_STRING = "Name of cop to clean up. Choosing a name overrides choosing a number"
    AUTOCORRECT_STRING = "Only clean auto-correctable cops (default)"
    NO_AUTOCORRECT_STRING = "Clean all cops (not default)"
    RUBOCOP_STRING = "Run rubocop -aD after (default)"
    NO_RUBOCOP_STRING = "Don't run rubocop -aD after (not default)"
    FILENAME_STRING = "Name of todo file (default: ./.rubocop_todo.yml)"
    CONFIG_STRING = "Name of optional config file (default: .rubomop.yml)"
    ONLY_STRING = "String or regex of cops to limit removal do, can have multiple"
    EXCEPT_STRING = "String or regex of cops to not remove from, can have multiple"
    BLOCK_STRING = "String or regex of files to not touch, can have multiple"
    DIRECTORY_STRING = "Directory to work in (default: current directory)"

    def initialize
      @number = 10
      @autocorrect_only = true
      @run_rubocop = true
      @filename = ".rubocop_todo.yml"
      @config = ".rubomop.yml"
      @directory = "."
      @todo_file = TodoFile.new(filename: full_path(@filename))
      @verbose = true
      @options_from_command_line = []
      @only = []
      @except = []
      @blocklist = []
      @name = nil
    end

    def execute(args)
      load_options(args)
      run
    end

    def load_options(args)
      parse(args)
      load_from_file
      # Recreate todo_file with the correct directory after options are loaded
      @todo_file = TodoFile.new(filename: full_path(@filename))
    end

    def load_from_file
      config_path = full_path(config)
      return unless File.exist?(config_path)

      file_options = YAML.safe_load_file(config_path)
      file_options.each do |key, value|
        next if options_from_command_line.include?(key)

        send("#{key.underscore}=", value) if respond_to?("#{key.underscore}=")
      end
    rescue Psych::Exception
      nil
    end

    def parse(args)
      option_parser = OptionParser.new do |opts|
        opts.banner = "Usage: rubomop [options]"
        opts.on("-nNUMBER", "--number NUMBER", Integer, NUM_STRING) do |value|
          self.number = value
          @options_from_command_line << "number"
        end
        opts.on("-a", "--autocorrect-only", AUTOCORRECT_STRING) do
          self.autocorrect_only = true
          @options_from_command_line << "autocorrect-only"
        end
        opts.on("--no_autocorrect-only", NO_AUTOCORRECT_STRING) do
          self.autocorrect_only = false
          @options_from_command_line << "autocorrect-only"
        end
        opts.on("-r", "--run-rubocop", RUBOCOP_STRING) do
          self.run_rubocop = true
          @options_from_command_line << "run-rubocop"
        end
        opts.on("-fFILENAME", "--filename=FILENAME", FILENAME_STRING) do |value|
          self.filename = value
          @options_from_command_line << "filename"
        end
        opts.on("--no-run-rubocop", NO_RUBOCOP_STRING) do
          self.run_rubocop = false
          @options_from_command_line << "run-rubocop"
        end
        opts.on("-cCONFIG_FILE", "--config=CONFIG_FILE", CONFIG_STRING) do |value|
          self.config = value
          @options_from_command_line << "config"
        end
        opts.on("-dDIRECTORY", "--directory=DIRECTORY", "--dir=DIRECTORY", DIRECTORY_STRING) do |value|
          self.directory = value
          @options_from_command_line << "directory"
        end
        opts.on("--only=ONLY", ONLY_STRING) do |value|
          only << value
          @options_from_command_line << "only"
        end
        opts.on("--except=EXCEPT", ONLY_STRING) do |value|
          except << value
          @options_from_command_line << "except"
        end
        opts.on("--block=BLOCK", BLOCK_STRING) do |value|
          blocklist << value
          @options_from_command_line << "block"
        end
        opts.on("--name=NAME", NAME_STRING) do |value|
          self.name = value
          @options_from_command_line << "name"
        end
        opts.on("-h", "--help", "Prints this help") do
          puts opts
          exit
        end
      end
      option_parser.parse(args)
    end

    def mop
      if name
        NamedMop.new(
          todo_file:,
          name:,
          verbose:,
          run_rubocop:
        )
      else
        RandomMop.new(
          todo_file:,
          number:,
          autocorrect_only:,
          verbose:,
          run_rubocop:,
          only:,
          except:,
          blocklist:
        )
      end
    end

    def run
      self.todo_file = TodoFile.new(filename: full_path(filename))&.parse
      return if todo_file.nil?

      backup_existing_file
      mop.mop!
      todo_file&.save!
    end

    def backup_existing_file
      filename_path = full_path(filename)
      backup_path = "#{filename_path}.bak"
      FileUtils.rm(backup_path) if File.exist?(backup_path)
      FileUtils.mv(filename_path, backup_path)
    end

    private

    def full_path(file_path)
      File.join(directory, file_path)
    end
  end
end
