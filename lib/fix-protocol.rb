require 'fix-protocol/version'
require 'fix-protocol/parser'

#
# Main Fix namespace
#
module Fix

  #
  # Parses a string into a Fix::Message instance
  #
  # @param str [String] A FIX message string
  # @return [Fix::Message] A +Fix::Message+ instance, or nil in case of failure
  #
  def self.parse(str)
    Parser.parse(str)
  end

end

