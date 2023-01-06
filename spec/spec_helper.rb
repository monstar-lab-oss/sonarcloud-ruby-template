# frozen_string_literal: true

require 'simplecov'
require 'simplecov-json'

# Generate HTML and JSON reports
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
                                                                  SimpleCov::Formatter::HTMLFormatter,
                                                                  SimpleCov::Formatter::JSONFormatter
                                                                ])
SimpleCov.start
