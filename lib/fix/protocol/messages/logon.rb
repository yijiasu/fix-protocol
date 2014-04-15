module Fix
  module Protocol
    module Messages

      #
      # A FIX logon message
      #
      class Logon < Message

        has_field :encrypt_method,      tag: 98,    required: true
        has_field :heart_bt_int,        tag: 108,   required: true,   type: :integer
        has_field :username,            tag: 553,   required: true
        has_field :reset_seq_num_flag,  tag: 141

        #
        # Validates the correctness of a FIX logon message
        #
        def validate
          super
          errors << "Encryption is not supported, the transport level should handle it" unless (encrypt_method == '0')
          errors << "Heartbeat interval should be between 10 and 60 seconds"            unless (heart_bt_int.to_i <= 60 && heart_bt_int.to_i >= 30)
        end

      end
    end
  end
end

