require 'treetop'

require 'fix/protocol/message'
require 'fix/protocol/version'

#
# Main Fix namespace
#
module Fix

  #
  # Main protocol namespace
  #
  module Protocol

    #
    # Parses a string into a Fix::Protocol::Message instance
    #
    # @param str [String] A FIX message string
    # @return [Fix::Protocol::Message] A +Fix::Protocol::Message+ instance, or a +Fix::Protocol::ParseFailure+ in case of failure
    #
    def self.parse(str)
      Message.parse(str)
    end

    #
    # Alias the +Fix::Protocol+ namespace to +FP+ if possible, because lazy is not necessarily dirty
    #
    def self.alias_namespace!
      Object.const_set(:FP, Protocol) unless Object.const_defined?(:FP)
    end

  end
end

Fix::Protocol.alias_namespace!

