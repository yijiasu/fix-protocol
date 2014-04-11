require 'fix-protocol/message'

module Fix

  #
  # The message classes container module
  #
  module Messages

    #
    # A FIX heartbeat message
    #
    class Heartbeat

      #
      # Parses a heartbeat message
      #
      # @param ast [Treetop::Runtime::SyntaxNode] An AST
      # @return [Fix::Messages::Heartbeat] A FIX heartbeat message instance
      #
      def self.from_ast(ast, str)
        #validate_message

        # get and check version
        # check message body length
        # get message type
        # get sender comp id
        # get target comp id
        # get sequence number
        # get sending time
        
        #check_structure
        new
      end 

    end

  end
end
