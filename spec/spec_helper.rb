require 'simplecov'
require(File.expand_path('../../lib/fix-protocol', __FILE__))

SimpleCov.start

RSpec.configure do |config|
  config.mock_with :rspec
end
