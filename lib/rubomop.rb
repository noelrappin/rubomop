# frozen_string_literal: true

require "fileutils"
require "optparse"
require "awesome_print"
require "active_support/core_ext/array"
require_relative "rubomop/cop"
require_relative "rubomop/runner"
require_relative "rubomop/todo_file"
require_relative "rubomop/version"

module Rubomop
  class Error < StandardError; end
  # Your code goes here...
end
