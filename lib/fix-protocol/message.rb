require 'treetop'

require 'fix-protocol/parse_failure'
require 'fix-protocol/message_class_mapping'

module Fix

  #
  # Represents an instance of a FIX message
  #
  class Message

    #
    # Parses a string into a Fix::Message instance
    #
    # @param str [String] A FIX message string
    # @return [Fix::Message] A +Fix::Message+ instance, or a +Fix::ParseFailure+ in case of failure
    #
    def self.parse(str)
      ast = Parser.parse(str)

      if ast
        fields = ast.fields
        msg_klass = MessageClassMapping.get(fields[2][1])
        msg_klass.from_ast(ast, str)
      else
        ParseFailure.new
      end
    end


    private

    #
    # Reads the FIX header, validates the length of the message and its checksum
    #
    def validate_message
    end

  end
end
