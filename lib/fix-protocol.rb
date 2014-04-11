require 'treetop'

require 'fix-protocol/message'
require 'fix-protocol/version'

#
# Main Fix namespace
#
module Fix

  #
  # Parses a string into a Fix::Message instance
  #
  # @param str [String] A FIX message string
  # @return [Fix::Message] A +Fix::Message+ instance, or a +Fix::ParseFailure+ in case of failure
  #
  def self.parse(str)
    Message.parse(str)
  end

end

