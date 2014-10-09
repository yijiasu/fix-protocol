module Fix
  module Protocol
    module Messages

      #
      # A FIX resend request message
      #
      class ResendRequest < Message

        has_field :begin_seq_no,  tag: 7,  required: true, type: :integer
        has_field :end_seq_no,    tag: 16, required: true, type: :integer, default: 0

        def validate(force = false)
          super(force)
          errors << "EndSeqNo must either be 0 (inifinity) or be >= BeginSeqNo" unless (end_seq_no.zero? || (end_seq_no >= begin_seq_no))
        end

      end
    end
  end
end


