module Fix
  module Protocol
    module Messages

      #
      # A FIX session reject message
      #
      class Reject < Message

        has_field :ref_seq_num, tag: 45, position: 0, required: true, type: :integer
        has_field :text,        tag: 58, position: 1, required: true

      end
    end
  end
end

