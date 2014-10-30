module Fix
  module Protocol

    #
    # The fields in the header for which the order is not enforced
    #
    class HeaderFields < UnorderedPart

      field :msg_type,        tag: 35,  required: true
      field :sender_comp_id,  tag: 49,  required: true
      field :target_comp_id,  tag: 56,  required: true
      field :msg_seq_num,     tag: 34,  required: true, type: :integer
      field :sending_time,    tag: 52,  required: true, type: :timestamp, default: proc { Time.now }

    end

  end
end
