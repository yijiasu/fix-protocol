module Fix

  module Messages

    #
    # A FIX heartbeat message
    #
    class Heartbeat < Message

      #
      # Parses a heartbeat message from an AST
      #
      # @param ast [Treetop::Runtime::SyntaxNode] An AST
      # @return [Fix::Messages::Heartbeat] A FIX heartbeat message instance
      #
      def self.from_ast(ast, str)
        inst = new(ast, str)
      end 

    end

  end
end
