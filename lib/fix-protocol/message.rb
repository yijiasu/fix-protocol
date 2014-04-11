require 'treetop'
require 'fix-protocol/parse_failure'

module Fix

  #
  # Represents an instance of a FIX message
  #
  class Message < Treetop::Runtime::SyntaxNode

    #
    # Parses a string into a Fix::Message instance
    #
    # @param str [String] A FIX message string
    # @return [Fix::Message] A +Fix::Message+ instance, or a +Fix::ParseFailure+ in case of failure
    #
    def self.parse(str)
      parsed_msg = Parser.parse(str)

      if parsed_msg
        from_ast(parsed_msg)
      else
        ParseFailure.new
      end
    end


    #
    # Turns an abstract syntax tree in a proper +Fix::Message+ instance
    #
    # @param ast [Treetop::Runtime::SyntaxNode] A Treetop AST
    # @return [Fix::Message] A +Fix::Message+ instance, or a +Fix::ParseFailure+ in case of failure
    #
    def from_ast(ast)

      # TODO

    end

  end
end
