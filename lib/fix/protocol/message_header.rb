require 'fix/protocol/message_part'

module Fix
  module Protocol
    class MessageHeader < MessagePart

      @structure = [
        { name: :version, tag: 8, required: true, default: 'FIX.4.4' }
      ]

      def initialize



      end

    end
  end
end
