# frozen_string_literal: true

require "active_support/core_ext/array"
require "active_support/core_ext/string/inflections"
require "awesome_print"
require "fileutils"
require "optparse"
require "yaml"
require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

module Rubomop
  class Error < StandardError; end
  # Your code goes here...
end
