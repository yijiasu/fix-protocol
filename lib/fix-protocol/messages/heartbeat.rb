module Fix

  module Messages

    #
    # A FIX heartbeat message
    #
    class Heartbeat < Message

      #
      # Parses a heartbeat message from a fields collection
      #
      # @param ast [Treetop::Runtime::SyntaxNode] An AST
      # @return [Fix::Messages::Heartbeat] A FIX heartbeat message instance
      #
      def self.from_fields(fields, str)
        inst = new(fields, str)
      end 

    end

  end
end
