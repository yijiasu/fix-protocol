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
     # def self.from_ast(ast, str)
     #   new(ast, str)
     # end 

      #
      # Returns the TestReqId property of the heartbeat message
      def test_req_id
        body_tag(112, 0)
      end

    end

  end
end
