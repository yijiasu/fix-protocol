require 'fix/protocol/message_part'

module Fix
  module Protocol
    class MessageHeader < MessagePart

      field :version,         tag: 8,   required: true,                   default: 'FIX.4.4'
      field :body_length,     tag: 9
      field :msg_type,        tag: 35,  required: true
      field :sender_comp_id,  tag: 49,  required: true
      field :target_comp_id,  tag: 56,  required: true
      field :msg_seq_num,     tag: 34,  required: true, type: :integer
      field :sending_time,    tag: 52,  required: true, type: :timestamp, default: proc { Time.now }

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
