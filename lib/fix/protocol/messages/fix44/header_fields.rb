require 'fix/protocol/message_part'
require 'fix/protocol/unordered_part'

module Fix
  module Protocol
    module Messages

      #
      # The header fields of a message
      #
      class HeaderFields < UnorderedPart
        field :msg_type,        tag: 35,    required: true
        field :sender_comp_id,  tag: 49,    required: true
        field :target_comp_id,  tag: 56,    required: true
        field :msg_seq_num,     tag: 34,    required: true, type: :integer
        field :sending_time,    tag: 52,    required: true, type: :timestamp, default: proc { Time.now }
        field :app_ver_id,      tag: 1128
      end

    end
  end
end
