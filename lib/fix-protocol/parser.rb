require 'polyglot'
require 'treetop'

require 'fix-protocol/grammar'
require 'fix-protocol/message'

module Fix

  #
  # Wrapper for the FIX parser emitted by treetop
  #
  class Parser

    @@parser = FixParser.new

    #
    # Parses a FIX message string into a +Fix::Message+ instance
    #
    def self.parse(str)
      @@parser.parse(str)
    end

  end
end
