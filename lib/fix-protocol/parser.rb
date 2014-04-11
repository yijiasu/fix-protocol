require 'polyglot'
require 'treetop'

require 'fix-protocol/grammar'

module Fix

  #
  # Wrapper for the FIX parser emitted by treetop
  #
  class Parser

    @@parser = FixParser.new

    #
    # Parses a FIX message string into a +Treetop::Runtime::SyntaxNode+ AST
    #
    def self.parse(str)
      @@parser.parse(str)
    end

  end
end
