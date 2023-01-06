# frozen_string_literal: true

require 'simplecov'
require 'simplecov_json_formatter'

# Generate HTML and JSON reports
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
                                                                  SimpleCov::Formatter::HTMLFormatter,
                                                                  SimpleCov::Formatter::JSONFormatter
                                                                ])
SimpleCov.start do
  add_filter 'spec/'
end
