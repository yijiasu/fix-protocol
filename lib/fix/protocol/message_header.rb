require 'fix/protocol/message_part'
require 'fix/protocol/header_fields'

module Fix
  module Protocol

    #
    # The standard FIX message header
    #
    class MessageHeader < MessagePart

      extend Forwardable
      def_delegators :header_fields, :msg_type, :msg_type=, :sender_comp_id, :sender_comp_id=, :target_comp_id, 
        :target_comp_id=, :msg_seq_num, :msg_seq_num=, :sending_time, :sending_time=

      field :version,         tag: 8,   required: true,                   default: 'FIX.4.4'
      field :body_length,     tag: 9

      unordered :header_fields, klass: HeaderFields

      #
      # Returns the errors relevant to the message header
      #
      # @return [Array<String>] The errors on the message header
      #
      def errors
        if version == 'FIX.4.4'
          super
        else
          [super, "Unsupported version: <#{version}>"].flatten
        end
      end

    end
  end
end
