require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

SimpleCov.start

require(File.expand_path('../../lib/fix/protocol', __FILE__))

# Force all message type to be required so we can have reliable coverage data
# They're usually auto-loaded
Dir['lib/fix/protocol/messages/*.rb'].
  map { |s| s.match(/([^\/]+)\.rb$/)[1].split(/\_/).map(&:capitalize).join }.
  map { |k| FP::Messages.const_get(k) }

RSpec.configure do |config|
  config.mock_with :rspec
end

