module Rubomop
  class RandomMop < Literal::Object
    prop :todo_file, TodoFile, reader: :public, writer: :public
    prop :number, Integer, reader: :public, writer: :public
    prop :autocorrect_only, _Boolean, reader: :public, writer: :public
    prop :verbose, _Boolean, reader: :public, writer: :public
    prop :run_rubocop, _Boolean, reader: :public, writer: :public
    prop :only, _Array(String), reader: :public, writer: :public
    prop :except, _Array(String), reader: :public, writer: :public
    prop :blocklist, _Array(String), reader: :public, writer: :public

    def cops
      todo_file.cops
    end

    def accept?(delete_option)
      return false if autocorrect_only && !delete_option.cop.any_autocorrect?
      unless except.empty?
        return except.none? { delete_option.cop.name.include?(_1) }
      end
      unless blocklist.empty?
        return blocklist.none? { delete_option.file.include?(_1) }
      end
      unless only.empty?
        return only.any? { delete_option.cop.name.include?(_1) }
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
      cop.files.map { DeleteOption.new(cop, _1, verbose, run_rubocop) }
    end

    def log(message)
      return unless verbose
      print message
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
      return unless run_rubocop
      todo_file.save!
      offense_count = delete_option.rubocop_runner || 0
      delete_option.subtract!(offense_count)
    end

    DeleteOption = Struct.new(:cop, :file, :verbose, :run_rubocop) do
      def print_message
        return unless verbose
        print "Deleting #{file} from #{cop.name}" if verbose
      end

      def delete!
        cop.delete!(file)
      end

      def subtract!(offense_count)
        cop.subtract!(offense_count)
      end

      def rubocop_runner
        return unless run_rubocop
        print "\nbundle exec rubocop #{file} -aD\n"
        IO.popen("bundle exec rubocop #{file} -aD") do |io|
          result_string = io.read
          puts result_string.split("\n").last
          puts "\n"
          parse_io(result_string)
        end
      end

      def parse_io(string)
        match_data = string.match(/(\d*) offense(s?) corrected/)
        return 0 if match_data.nil?
        match_data[1].to_i
      end
    end
  end
end
