module Fix
  module Protocol
    module Messages

      #
      # A FIX session reject message
      #
      class Reject < Message

        field :ref_seq_num, tag: 45, required: true, type: :integer
        field :text,        tag: 58, required: true

      end
    end
  end
end

